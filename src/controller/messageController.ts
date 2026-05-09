/*
 * Copyright 2021 WPPConnect Team
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Request, Response } from 'express';

import { unlinkAsync } from '../util/functions';

function returnError(req: Request, res: Response, error: any) {
  req.logger.error(error);
  res.status(500).json({
    status: 'Error',
    message: 'Erro ao enviar a mensagem.',
    error: error,
  });
}

async function returnSucess(res: any, data: any) {
  res.status(201).json({ status: 'success', response: data, mapper: 'return' });
}

export async function sendMessage(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
    #swagger.requestBody = {
      required: true,
      "@content": {
        "application/json": {
          schema: {
            type: "object",
            properties: {
              phone: { type: "string" },
              isGroup: { type: "boolean" },
              isNewsletter: { type: "boolean" },
              isLid: { type: "boolean" },
              message: { type: "string" },
              options: { type: "object" },
            }
          },
          examples: {
            "Send message to contact": {
              value: { 
                phone: '5521999999999',
                isGroup: false,
                isNewsletter: false,
                isLid: false,
                message: 'Hi from WPPConnect',
              }
            },
            "Send message with reply": {
              value: { 
                phone: '5521999999999',
                isGroup: false,
                isNewsletter: false,
                isLid: false,
                message: 'Hi from WPPConnect with reply',
                options: {
                  quotedMsg: 'true_...@c.us_3EB01DE65ACC6_out',
                }
              }
            },
            "Send message to group": {
              value: {
                phone: '8865623215244578',
                isGroup: true,
                message: 'Hi from WPPConnect',
              }
            },
          }
        }
      }
     }
   */
  const { phone, message } = req.body;

  const options = req.body.options || {};

  try {
    const results: any = [];
    for (const contato of phone) {
      results.push(await req.client.sendText(contato, message, options));
    }

    if (results.length === 0) res.status(400).json('Error sending message');
    req.io.emit('mensagem-enviada', results);
    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function editMessage(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
    #swagger.requestBody = {
      required: true,
      "@content": {
        "application/json": {
          schema: {
            type: "object",
            properties: {
              id: { type: "string" },
              newText: { type: "string" },
              options: { type: "object" },
            }
          },
          examples: {
            "Edit a message": {
              value: { 
                id: 'true_5521999999999@c.us_3EB04FCAA1527EB6D9DEC8',
                newText: 'New text for message'
              }
            },
          }
        }
      }
     }
   */
  const { id, newText } = req.body;

  const options = req.body.options || {};
  try {
    const edited = await (req.client as any).editMessage(id, newText, options);

    req.io.emit('edited-message', edited);
    returnSucess(res, edited);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function sendFile(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
     #swagger.requestBody = {
      required: true,
      "@content": {
        "application/json": {
            schema: {
                type: "object",
                properties: {
                    "phone": { type: "string" },
                    "isGroup": { type: "boolean" },
                    "isNewsletter": { type: "boolean" },
                    "isLid": { type: "boolean" },
                    "filename": { type: "string" },
                    "caption": { type: "string" },
                    "base64": { type: "string" }
                }
            },
            examples: {
                "Default": {
                    value: {
                        "phone": "5521999999999",
                        "isGroup": false,
                        "isNewsletter": false,
                        "isLid": false,
                        "filename": "file name lol",
                        "caption": "caption for my file",
                        "base64": "<base64> string"
                    }
                }
            }
        }
      }
    }
   */
  const {
    phone,
    path,
    base64,
    filename = 'file',
    message,
    caption,
    quotedMessageId,
  } = req.body;

  const options = req.body.options || {};

  if (!path && !req.file && !base64)
    res.status(401).send({
      message: 'Sending the file is mandatory',
    });

  const pathFile = path || req.file?.path;
  const msg = message || caption;

  try {
    const results: any = [];
    for (const contact of phone) {
      if (base64) {
        // Se base64 for fornecido, usar sendImageFromBase64
        results.push(
          await req.client.sendImageFromBase64(
            contact,
            base64,
            msg || filename,
            {
              filename: filename,
              quotedMsg: quotedMessageId,
              ...options,
            }
          )
        );
      } else {
        // Se path for fornecido, usar sendFile
        results.push(
          await req.client.sendFile(contact, pathFile, {
            filename: filename,
            caption: msg,
            quotedMsg: quotedMessageId,
            ...options,
          })
        );
      }
    }

    if (results.length === 0) res.status(400).json('Error sending message');
    if (req.file) await unlinkAsync(pathFile);
    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function sendImage(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
     #swagger.requestBody = {
      required: true,
      "@content": {
        "application/json": {
            schema: {
                type: "object",
                properties: {
                    "phone": { type: "string" },
                    "isGroup": { type: "boolean" },
                    "isNewsletter": { type: "boolean" },
                    "isLid": { type: "boolean" },
                    "filename": { type: "string" },
                    "caption": { type: "string" },
                    "base64": { type: "string" }
                }
            },
            examples: {
                "Base64": {
                    value: {
                        "phone": "5521999999999",
                        "isGroup": false,
                        "filename": "image.png",
                        "caption": "Caption for image",
                        "base64": "<base64> string"
                    }
                }
            }
        }
      }
    }
   */
  const {
    phone,
    base64,
    filename = 'image.png',
    message,
    caption,
    quotedMessageId,
  } = req.body;

  const options = req.body.options || {};

  if (!base64)
    res.status(401).send({
      message: 'Sending the base64 image is mandatory',
    });

  const msg = message || caption;

  try {
    const results: any = [];
    
    // Converter base64 para arquivo temporário para contornar validação rigorosa da lib
    const fs = require('fs');
    const path = require('path');
    const os = require('os');
    
    // Criar arquivo temporário
    const tempDir = os.tmpdir();
    const tempFileName = `wppconnect_${Date.now()}_${Math.random().toString(36).substr(2, 9)}.${filename.split('.').pop() || 'png'}`;
    const tempFilePath = path.join(tempDir, tempFileName);
    
    try {
      // Escrever base64 para arquivo temporário
      const imageBuffer = Buffer.from(base64, 'base64');
      fs.writeFileSync(tempFilePath, imageBuffer);
      
      for (const contact of phone) {
        results.push(
          await req.client.sendFile(contact, tempFilePath, {
            filename: filename,
            caption: msg,
            quotedMsg: quotedMessageId,
            ...options,
          })
        );
      }
      
      // Limpar arquivo temporário
      fs.unlinkSync(tempFilePath);
      
    } catch (fileError) {
      // Se houver erro com arquivo temporário, tentar sendImageFromBase64 como fallback
      req.logger.warn('Erro com arquivo temporário, tentando sendImageFromBase64:', fileError);
      
      for (const contact of phone) {
        results.push(
          await req.client.sendImageFromBase64(
            contact,
            base64,
            msg || filename,
            {
              filename: filename,
              quotedMsg: quotedMessageId,
              ...options,
            }
          )
        );
      }
    }

    if (results.length === 0) res.status(400).json('Error sending message');
    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function sendVoice(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
     #swagger.requestBody = {
        required: true,
        "@content": {
            "application/json": {
                schema: {
                    type: "object",
                    properties: {
                        "phone": { type: "string" },
                        "isGroup": { type: "boolean" },
                        "path": { type: "string" },
                        "quotedMessageId": { type: "string" }
                    }
                },
                examples: {
                    "Default": {
                        value: {
                            "phone": "5521999999999",
                            "isGroup": false,
                            "path": "<path_file>",
                            "quotedMessageId": "message Id"
                        }
                    }
                }
            }
        }
    }
   */
  const {
    phone,
    path,
    filename = 'Voice Audio',
    message,
    quotedMessageId,
  } = req.body;

  try {
    const results: any = [];
    for (const contato of phone) {
      results.push(
        await req.client.sendPtt(
          contato,
          path,
          filename,
          message,
          quotedMessageId
        )
      );
    }

    if (results.length === 0) res.status(400).json('Error sending message');
    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function sendVoice64(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
     #swagger.requestBody = {
        required: true,
        "@content": {
            "application/json": {
                schema: {
                    type: "object",
                    properties: {
                        "phone": { type: "string" },
                        "isGroup": { type: "boolean" },
                        "base64Ptt": { type: "string" }
                    }
                },
                examples: {
                    "Default": {
                        value: {
                            "phone": "5521999999999",
                            "isGroup": false,
                            "base64Ptt": "<base64_string>"
                        }
                    }
                }
            }
        }
    }
   */
  const { phone, base64Ptt, quotedMessageId } = req.body;

  try {
    const results: any = [];
    for (const contato of phone) {
      results.push(
        await req.client.sendPttFromBase64(
          contato,
          base64Ptt,
          'Voice Audio',
          '',
          quotedMessageId
        )
      );
    }

    if (results.length === 0) res.status(400).json('Error sending message');
    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function sendLinkPreview(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
     #swagger.requestBody = {
        required: true,
        "@content": {
            "application/json": {
                schema: {
                    type: "object",
                    properties: {
                        "phone": { type: "string" },
                        "isGroup": { type: "boolean" },
                        "url": { type: "string" },
                        "caption": { type: "string" }
                    }
                },
                examples: {
                    "Default": {
                        value: {
                            "phone": "5521999999999",
                            "isGroup": false,
                            "url": "http://www.link.com",
                            "caption": "Text for describe link"
                        }
                    }
                }
            }
        }
    }
   */
  const { phone, url, caption } = req.body;

  try {
    const results: any = [];
    for (const contato of phone) {
      results.push(
        await req.client.sendLinkPreview(`${contato}`, url, caption)
      );
    }

    if (results.length === 0) res.status(400).json('Error sending message');
    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function sendLocation(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
     #swagger.requestBody = {
        required: true,
        "@content": {
            "application/json": {
                schema: {
                    type: "object",
                    properties: {
                        "phone": { type: "string" },
                        "isGroup": { type: "boolean" },
                        "lat": { type: "string" },
                        "lng": { type: "string" },
                        "title": { type: "string" },
                        "address": { type: "string" }
                    }
                },
                examples: {
                    "Default": {
                        value: {
                            "phone": "5521999999999",
                            "isGroup": false,
                            "lat": "-89898322",
                            "lng": "-545454",
                            "title": "Rio de Janeiro",
                            "address": "Av. N. S. de Copacabana, 25, Copacabana"
                        }
                    }
                }
            }
        }
    }
   */
  const { phone, lat, lng, title, address } = req.body;

  try {
    const results: any = [];
    for (const contato of phone) {
      results.push(
        await req.client.sendLocation(contato, {
          lat: lat,
          lng: lng,
          address: address,
          name: title,
        })
      );
    }

    if (results.length === 0) res.status(400).json('Error sending message');
    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function sendButtons(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA',
     }
     #swagger.requestBody = {
      required: true,
      "@content": {
        "application/json": {
          schema: {
            type: "object",
            properties: {
              phone: { type: "array", items: { type: "string" } },
              message: { type: "string" },
              title: { type: "string" },
              footer: { type: "string" },
              dynamic_reply: { type: "boolean" },
              buttons: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    id: { type: "string" },
                    text: { type: "string" }
                  }
                }
              }
            }
          },
          examples: {
            "Send interactive buttons": {
              value: {
                phone: ["5521999999999"],
                message: "Escolha uma opção:",
                title: "Menu Principal",
                footer: "Selecione uma opção",
                dynamic_reply: true,
                buttons: [
                  {
                    id: "sim",
                    text: "✅ Sim"
                  },
                  {
                    id: "nao",
                    text: "❌ Não"
                  },
                  {
                    id: "talvez",
                    text: "🤔 Talvez"
                  }
                ]
              }
            }
          }
        }
      }
     }
   */
  const {
    phone,
    message = null,
    title,
    footer = null,
    dynamic_reply = true,
    buttons,
  } = req.body;

  try {
    const results: any = [];

    for (const contact of phone) {
      console.log('🔘 Enviando botões para:', contact);
      console.log('🔘 Botões:', JSON.stringify(buttons, null, 2));
      
      const result = await req.client.sendMessageOptions(contact, message, {
        title: title,
        footer: footer,
        isDynamicReplyButtonsMsg: dynamic_reply,
        dynamicReplyButtons: buttons,
      });
      
      console.log('🔘 Resultado:', result);
      results.push(result);
    }

    if (results.length === 0)
      return returnError(req, res, 'Error sending message with buttons');

    returnSucess(res, results);
  } catch (error) {
    console.error('🔘 Erro ao enviar botões:', error);
    returnError(req, res, error);
  }
}

export async function sendListMessage(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA',
     }
     #swagger.requestBody = {
      required: true,
      "@content": {
        "application/json": {
          schema: {
            type: "object",
            properties: {
              phone: { type: "string" },
              isGroup: { type: "boolean" },
              description: { type: "string" },
              sections: { type: "array" },
              buttonText: { type: "string" },
            }
          },
          examples: {
            "Send list message": {
              value: { 
                phone: '5521999999999',
                isGroup: false,
                description: 'Desc for list',
                buttonText: 'Select a option',
                sections: [
                  {
                    title: 'Section 1',
                    rows: [
                      {
                        rowId: 'my_custom_id',
                        title: 'Test 1',
                        description: 'Description 1',
                      },
                      {
                        rowId: '2',
                        title: 'Test 2',
                        description: 'Description 2',
                      },
                    ],
                  },
                ],
              }
            },
          }
        }
      }
     }
   */
  const {
    phone,
    description = '',
    sections,
    buttonText = 'SELECIONE UMA OPÇÃO',
  } = req.body;

  try {
    const results: any = [];

    for (const contact of phone) {
      results.push(
        await req.client.sendListMessage(contact, {
          buttonText: buttonText,
          description: description,
          sections: sections,
        })
      );
    }

    if (results.length === 0)
      return returnError(req, res, 'Error sending list buttons');

    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function sendOrderMessage(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
    #swagger.requestBody = {
      required: true,
      "@content": {
        "application/json": {
          schema: {
            type: "object",
            properties: {
              phone: { type: "string" },
              isGroup: { type: "boolean" },
              items: { type: "object" },
              options: { type: "object" },
            }
          },
          examples: {
            "Send with custom items": {
              value: { 
                phone: '5521999999999',
                isGroup: false,
                items: [
                  {
                    type: 'custom',
                    name: 'Item test',
                    price: 120000,
                    qnt: 2,
                  },
                  {
                    type: 'custom',
                    name: 'Item test 2',
                    price: 145000,
                    qnt: 2,
                  },
                ],
              }
            },
            "Send with product items": {
              value: { 
                phone: '5521999999999',
                isGroup: false,
                items: [
                  {
                    type: 'product',
                    id: '37878774457',
                    price: 148000,
                    qnt: 2,
                  },
                ],
              }
            },
            "Send with custom items and options": {
              value: { 
                phone: '5521999999999',
                isGroup: false,
                items: [
                  {
                    type: 'custom',
                    name: 'Item test',
                    price: 120000,
                    qnt: 2,
                  },
                ],
                options: {
                  tax: 10000,
                  shipping: 4000,
                  discount: 10000,
                }
              }
            },
          }
        }
      }
     }
   */
  const { phone, items } = req.body;

  const options = req.body.options || {};

  try {
    const results: any = [];
    for (const contato of phone) {
      results.push(await req.client.sendOrderMessage(contato, items, options));
    }

    if (results.length === 0)
      res.status(400).json('Error sending order message');
    req.io.emit('mensagem-enviada', results);
    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function sendPollMessage(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
    #swagger.requestBody = {
        required: true,
        "@content": {
            "application/json": {
                schema: {
                    type: "object",
                    properties: {
                        phone: { type: "string" },
                        isGroup: { type: "boolean" },
                        name: { type: "string" },
                        choices: { type: "array" },
                        options: { type: "object" },
                    }
                },
                examples: {
                    "Default": {
                        value: {
                          phone: '5521999999999',
                          isGroup: false,
                          name: 'Poll name',
                          choices: ['Option 1', 'Option 2', 'Option 3'],
                          options: {
                            selectableCount: 1,
                          }
                        }
                    },
                }
            }
        }
    }
   */
  const { phone, name, choices, options } = req.body;

  try {
    const results: any = [];

    for (const contact of phone) {
      results.push(
        await req.client.sendPollMessage(contact, name, choices, options)
      );
    }

    if (results.length === 0)
      return returnError(req, res, 'Error sending poll message');

    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function sendStatusText(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
     #swagger.requestBody = {
      required: true,
      content: {
        'application/json': {
          schema: {
            type: 'object',
            properties: {
              phone: { type: 'string' },
              isGroup: { type: 'boolean' },
              message: { type: 'string' },
              messageId: { type: 'string' }
            },
            required: ['phone', 'isGroup', 'message']
          },
          examples: {
            Default: {
              value: {
                phone: '5521999999999',
                isGroup: false,
                message: 'Reply to message',
                messageId: '<id_message>'
              }
            }
          }
        }
      }
    }
   */
  const { message } = req.body;

  try {
    const results: any = [];
    results.push(await req.client.sendText('status@broadcast', message));

    if (results.length === 0) res.status(400).json('Error sending message');
    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function replyMessage(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
     #swagger.requestBody = {
      required: true,
      "@content": {
        "application/json": {
          schema: {
            type: "object",
            properties: {
              "phone": { type: "string" },
              "isGroup": { type: "boolean" },
              "message": { type: "string" },
              "messageId": { type: "string" }
            }
          },
          examples: {
            "Default": {
              value: {
                "phone": "5521999999999",
                "isGroup": false,
                "message": "Reply to message",
                "messageId": "<id_message>"
              }
            }
          }
        }
      }
    }
   */
  const { phone, message, messageId } = req.body;

  try {
    const results: any = [];
    for (const contato of phone) {
      results.push(await req.client.reply(contato, message, messageId));
    }

    if (results.length === 0) res.status(400).json('Error sending message');
    req.io.emit('mensagem-enviada', { message: message, to: phone });
    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}

export async function sendMentioned(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
     #swagger.requestBody = {
  required: true,
  "@content": {
    "application/json": {
      schema: {
        type: "object",
        properties: {
          "phone": { type: "string" },
          "isGroup": { type: "boolean" },
          "message": { type: "string" },
          "mentioned": { type: "array", items: { type: "string" } }
        },
        required: ["phone", "message", "mentioned"]
      },
      examples: {
        "Default": {
          value: {
            "phone": "groupId@g.us",
            "isGroup": true,
            "message": "Your text message",
            "mentioned": ["556593077171@c.us"]
          }
        }
      }
    }
  }
}
   */
  const { phone, message, mentioned } = req.body;

  try {
    let response;
    for (const contato of phone) {
      response = await req.client.sendMentioned(
        `${contato}`,
        message,
        mentioned
      );
    }

    res.status(201).json({ status: 'success', response: response });
  } catch (error) {
    req.logger.error(error);
    res.status(500).json({
      status: 'error',
      message: 'Error on send message mentioned',
      error: error,
    });
  }
}
export async function sendImageAsSticker(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
     #swagger.requestBody = {
      required: true,
      "@content": {
        "application/json": {
          schema: {
            type: "object",
            properties: {
              "phone": { type: "string" },
              "isGroup": { type: "boolean" },
              "path": { type: "string" }
            },
            required: ["phone", "path"]
          },
          examples: {
            "Default": {
              value: {
                "phone": "5521999999999",
                "isGroup": true,
                "path": "<path_file>"
              }
            }
          }
        }
      }
    }
   */
  const { phone, path } = req.body;

  if (!path && !req.file)
    res.status(401).send({
      message: 'Sending the file is mandatory',
    });

  const pathFile = path || req.file?.path;

  try {
    const results: any = [];
    for (const contato of phone) {
      results.push(await req.client.sendImageAsSticker(contato, pathFile));
    }

    if (results.length === 0) res.status(400).json('Error sending message');
    if (req.file) await unlinkAsync(pathFile);
    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}
export async function sendImageAsStickerGif(req: Request, res: Response) {
  /**
   * #swagger.tags = ["Messages"]
     #swagger.autoBody=false
     #swagger.security = [{
            "bearerAuth": []
     }]
     #swagger.parameters["session"] = {
      schema: 'NERDWHATS_AMERICA'
     }
     #swagger.requestBody = {
      required: true,
      content: {
        'application/json': {
          schema: {
            type: 'object',
            properties: {
              phone: { type: 'string' },
              isGroup: { type: 'boolean' },
              path: { type: 'string' },
            },
            required: ['phone', 'path'],
          },
          examples: {
            'Default': {
              value: {
                phone: '5521999999999',
                isGroup: true,
                path: '<path_file>',
              },
            },
          },
        },
      },
    }
   */
  const { phone, path } = req.body;

  if (!path && !req.file)
    res.status(401).send({
      message: 'Sending the file is mandatory',
    });

  const pathFile = path || req.file?.path;

  try {
    const results: any = [];
    for (const contato of phone) {
      results.push(await req.client.sendImageAsStickerGif(contato, pathFile));
    }

    if (results.length === 0) res.status(400).json('Error sending message');
    if (req.file) await unlinkAsync(pathFile);
    returnSucess(res, results);
  } catch (error) {
    returnError(req, res, error);
  }
}
