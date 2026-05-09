/*
 * Copyright 2025 WPPConnect Team
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

interface CarouselCard {
  id: string;
  title: string;
  description: string;
  imageUrl: string;
  buttons: Array<{
    id: string;
    text: string;
    type: 'url' | 'call' | 'reply';
    value: string;
  }>;
}

interface CarouselMessage {
  phone: string[];
  isGroup?: boolean;
  headerText?: string;
  footerText?: string;
  cards: CarouselCard[];
}

async function returnSuccess(res: any, data: any) {
  res.status(200).json({ status: 'success', response: data });
}

async function returnError(req: any, res: any, error: any) {
  req.logger.error(error);
  res.status(500).json({ status: 'error', message: error });
}

export async function sendCarousel(req: Request, res: Response): Promise<any> {
  /**
   * #swagger.tags = ["Messages"]
   * #swagger.autoBody=false
   * #swagger.security = [{
   *        "bearerAuth": []
   * }]
   * #swagger.parameters["session"] = {
   *   schema: 'NERDWHATS_AMERICA'
   * }
   * #swagger.requestBody = {
   *   required: true,
   *   "@content": {
   *     "application/json": {
   *       schema: {
   *         type: "object",
   *         properties: {
   *           phone: { type: "array", items: { type: "string" } },
   *           isGroup: { type: "boolean" },
   *           headerText: { type: "string" },
   *           footerText: { type: "string" },
   *           cards: {
   *             type: "array",
   *             items: {
   *               type: "object",
   *               properties: {
   *                 id: { type: "string" },
   *                 title: { type: "string" },
   *                 description: { type: "string" },
   *                 imageUrl: { type: "string" },
   *                 buttons: {
   *                   type: "array",
   *                   items: {
   *                     type: "object",
   *                     properties: {
   *                       id: { type: "string" },
   *                       text: { type: "string" },
   *                       type: { type: "string", enum: ["url", "call", "reply"] },
   *                       value: { type: "string" }
   *                     }
   *                   }
   *                 }
   *               }
   *             }
   *           }
   *         }
   *       },
   *       examples: {
   *         "Send carousel": {
   *           value: {
   *             phone: ["5521999999999"],
   *             isGroup: false,
   *             headerText: "Confira nossos produtos!",
   *             footerText: "Escolha uma opção abaixo",
   *             cards: [
   *               {
   *                 id: "card1",
   *                 title: "Produto 1",
   *                 description: "Descrição do produto 1",
   *                 imageUrl: "https://example.com/image1.jpg",
   *                 buttons: [
   *                   {
   *                     id: "btn1",
   *                     text: "Ver Detalhes",
   *                     type: "url",
   *                     value: "https://example.com/produto1"
   *                   },
   *                   {
   *                     id: "btn2",
   *                     text: "Comprar",
   *                     type: "reply",
   *                     value: "comprar_produto1"
   *                   }
   *                 ]
   *               },
   *               {
   *                 id: "card2",
   *                 title: "Produto 2",
   *                 description: "Descrição do produto 2",
   *                 imageUrl: "https://example.com/image2.jpg",
   *                 buttons: [
   *                   {
   *                     id: "btn3",
   *                     text: "Ver Detalhes",
   *                     type: "url",
   *                     value: "https://example.com/produto2"
   *                   },
   *                   {
   *                     id: "btn4",
   *                     text: "Comprar",
   *                     type: "reply",
   *                     value: "comprar_produto2"
   *                   }
   *                 ]
   *               }
   *             ]
   *           }
   *         }
   *       }
   *     }
   *   }
   * }
   */
  const { phone, isGroup = false, headerText, footerText, cards }: CarouselMessage = req.body;

  try {
    const results: any = [];

    for (const contact of phone) {
      // Construir mensagem do carrossel
      let message = '';
      
      if (headerText) {
        message += `*${headerText}*\n\n`;
      }

      // Adicionar cada card
      cards.forEach((card, index) => {
        message += `*${card.title}*\n`;
        message += `${card.description}\n`;
        
        if (card.imageUrl) {
          message += `🖼️ Imagem: ${card.imageUrl}\n`;
        }

        // Adicionar botões
        card.buttons.forEach((button, btnIndex) => {
          const emoji = button.type === 'url' ? '🔗' : 
                       button.type === 'call' ? '📞' : '💬';
          message += `${emoji} ${button.text}\n`;
        });

        if (index < cards.length - 1) {
          message += '\n---\n\n';
        }
      });

      if (footerText) {
        message += `\n_${footerText}_`;
      }

      // Enviar mensagem com botões interativos
      const buttons = cards.flatMap(card => 
        card.buttons.map(button => ({
          id: button.id,
          text: button.text
        }))
      );

      const result = await req.client.sendMessageOptions(contact, message, {
        title: headerText || 'Carrossel de Produtos',
        footer: footerText || 'Escolha uma opção',
        isDynamicReplyButtonsMsg: true,
        dynamicReplyButtons: buttons
      });

      results.push(result);
    }

    if (results.length === 0) {
      return returnError(req, res, 'Error sending carousel message');
    }

    req.io.emit('carousel-sent', { cards, phone });
    return returnSuccess(res, results);
  } catch (error) {
    return returnError(req, res, error);
  }
}

export async function sendCarouselWithImages(req: Request, res: Response): Promise<any> {
  /**
   * #swagger.tags = ["Messages"]
   * #swagger.autoBody=false
   * #swagger.security = [{
   *        "bearerAuth": []
   * }]
   * #swagger.parameters["session"] = {
   *   schema: 'NERDWHATS_AMERICA'
   * }
   * #swagger.requestBody = {
   *   required: true,
   *   "@content": {
   *     "application/json": {
   *       schema: {
   *         type: "object",
   *         properties: {
   *           phone: { type: "array", items: { type: "string" } },
   *           isGroup: { type: "boolean" },
   *           headerText: { type: "string" },
   *           footerText: { type: "string" },
   *           cards: {
   *             type: "array",
   *             items: {
   *               type: "object",
   *               properties: {
   *                 id: { type: "string" },
   *                 title: { type: "string" },
   *                 description: { type: "string" },
   *                 imageBase64: { type: "string" },
   *                 buttons: {
   *                   type: "array",
   *                   items: {
   *                     type: "object",
   *                     properties: {
   *                       id: { type: "string" },
   *                       text: { type: "string" },
   *                       type: { type: "string", enum: ["url", "call", "reply"] },
   *                       value: { type: "string" }
   *                     }
   *                   }
   *                 }
   *               }
   *             }
   *           }
   *         }
   *       }
   *     }
   *   }
   * }
   */
  const { phone, isGroup = false, headerText, footerText, cards }: any = req.body;

  try {
    const results: any = [];

    for (const contact of phone) {
      // Enviar cada card como uma mensagem separada com imagem
      for (let i = 0; i < cards.length; i++) {
        const card = cards[i];
        
        let message = '';
        if (i === 0 && headerText) {
          message += `*${headerText}*\n\n`;
        }

        message += `*${card.title}*\n`;
        message += `${card.description}\n`;

        // Adicionar botões
        card.buttons.forEach((button: any) => {
          const emoji = button.type === 'url' ? '🔗' : 
                       button.type === 'call' ? '📞' : '💬';
          message += `${emoji} ${button.text}\n`;
        });

        if (i === cards.length - 1 && footerText) {
          message += `\n_${footerText}_`;
        }

        // Enviar imagem se disponível
        if (card.imageBase64) {
          const result = await req.client.sendImageFromBase64(
            contact,
            card.imageBase64,
            message,
            {
              title: card.title,
              footer: i === cards.length - 1 ? footerText : undefined,
              isDynamicReplyButtonsMsg: true,
              dynamicReplyButtons: card.buttons.map((btn: any) => ({
                id: btn.id,
                text: btn.text
              }))
            }
          );
          results.push(result);
        } else {
          // Enviar apenas texto com botões
          const result = await req.client.sendMessageOptions(contact, message, {
            title: card.title,
            footer: i === cards.length - 1 ? footerText : undefined,
            isDynamicReplyButtonsMsg: true,
            dynamicReplyButtons: card.buttons.map((btn: any) => ({
              id: btn.id,
              text: btn.text
            }))
          });
          results.push(result);
        }

        // Pequena pausa entre as mensagens
        if (i < cards.length - 1) {
          await new Promise(resolve => setTimeout(resolve, 1000));
        }
      }
    }

    if (results.length === 0) {
      return returnError(req, res, 'Error sending carousel with images');
    }

    req.io.emit('carousel-images-sent', { cards, phone });
    return returnSuccess(res, results);
  } catch (error) {
    return returnError(req, res, error);
  }
}
