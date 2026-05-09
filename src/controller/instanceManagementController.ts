import { Request, Response } from 'express';
import { clientsArray } from '../util/sessionUtil';
import CreateSessionUtil from '../util/createSessionUtil';
import Token from '../util/tokenStore/model/token';
import bcrypt from 'bcrypt';

const createSessionUtil = new CreateSessionUtil();

/**
 * @swagger
 * /api/create-instance:
 *   post:
 *     summary: Criar nova instância WhatsApp
 *     tags: [Instance Management]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 example: minha-instancia-1
 *                 description: Nome único da instância
 *               webhook:
 *                 type: string
 *                 example: https://webhook.site/123
 *                 description: URL do webhook (opcional)
 *     responses:
 *       201:
 *         description: Instância criada com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 data:
 *                   type: object
 *                   properties:
 *                     name:
 *                       type: string
 *                     token:
 *                       type: string
 *                     qrcode:
 *                       type: string
 *       400:
 *         description: Nome já existe ou dados inválidos
 */
export const createInstance = async (req: Request, res: Response) => {
  try {
    const { name, webhook } = req.body;
    const secureToken = req.serverOptions.secretKey;

    if (!name || typeof name !== 'string' || name.trim().length === 0) {
      return res.status(400).json({
        status: 'error',
        message: 'Nome da instância é obrigatório'
      });
    }

    const instanceName = name.trim().toLowerCase().replace(/[^a-z0-9-]/g, '-');

    // Verificar se a instância já existe
    const existingInstance = await (Token as any).findOne({ sessionName: instanceName });
    if (existingInstance) {
      return res.status(400).json({
        status: 'error',
        message: 'Instância com este nome já existe'
      });
    }

    // Verificar se já existe uma sessão ativa com este nome
    if (clientsArray[instanceName]) {
      return res.status(400).json({
        status: 'error',
        message: 'Instância já está ativa'
      });
    }

    // Gerar token para a nova instância
    const token = await new Promise<string>((resolve, reject) => {
      bcrypt.hash(instanceName + secureToken, 10, (err, hash) => {
        if (err) reject(err);
        else resolve(hash.replace(/\//g, '_').replace(/\+/g, '-'));
      });
    });

    // Criar entrada no banco de dados
    const tokenData = new (Token as any)({
      sessionName: instanceName,
      webhook: webhook || '',
      config: JSON.stringify({
        waitQrCode: true,
        webhook: webhook || ''
      })
    });
    await tokenData.save();

    // Criar cliente WhatsApp para a nova instância
    const client = await createSessionUtil.startSession(req, instanceName, {
      session: instanceName,
      webhook: webhook || '',
      waitQrCode: true
    });

    return res.status(201).json({
      status: 'success',
      data: {
        name: instanceName,
        token: token,
        full: `${instanceName}:${token}`,
        qrcode: client?.qrcode || null,
        urlcode: client?.urlcode || null,
        status: client?.status || 'QRCODE'
      }
    });

  } catch (error) {
    console.error('Erro ao criar instância:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Erro interno do servidor'
    });
  }
};

/**
 * @swagger
 * /api/{session}/qrcode:
 *   get:
 *     summary: Obter QR Code da instância
 *     tags: [Instance Management]
 *     parameters:
 *       - in: path
 *         name: session
 *         required: true
 *         schema:
 *           type: string
 *         description: Nome da sessão
 *       - in: header
 *         name: Authorization
 *         required: true
 *         schema:
 *           type: string
 *         description: Token de autenticação
 *     responses:
 *       200:
 *         description: QR Code obtido com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 data:
 *                   type: object
 *                   properties:
 *                     qrcode:
 *                       type: string
 *                       description: QR Code em base64
 *                     urlcode:
 *                       type: string
 *                     sessionStatus:
 *                       type: string
 *       404:
 *         description: Instância não encontrada
 */
export const getInstanceQrCode = async (req: Request, res: Response) => {
  try {
    const { session } = req.params;
    const client = clientsArray[session];

    if (!client) {
      return res.status(404).json({
        status: 'error',
        message: 'Instância não encontrada'
      });
    }

    // Retornar APENAS QR Code REAL do WPPConnect
    // SEM gerar mock com QRCode.toDataURL
    return res.json({
      status: 'success',
      data: {
        qrcode: client.qrcode || null, // QR Code REAL ou null
        urlcode: client.urlcode || null,
        sessionStatus: client.status
      }
    });

  } catch (error) {
    console.error('Erro ao obter QR Code:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Erro interno do servidor'
    });
  }
};

/**
 * @swagger
 * /api/{session}/start:
 *   post:
 *     summary: Iniciar instância WhatsApp
 *     tags: [Instance Management]
 *     parameters:
 *       - in: path
 *         name: session
 *         required: true
 *         schema:
 *           type: string
 *         description: Nome da sessão
 *       - in: header
 *         name: Authorization
 *         required: true
 *         schema:
 *           type: string
 *         description: Token de autenticação
 *     responses:
 *       200:
 *         description: Instância iniciada com sucesso
 *       404:
 *         description: Instância não encontrada
 */
export const startInstance = async (req: Request, res: Response) => {
  try {
    const { session } = req.params;
    
    // Verificar se a instância existe no banco
    const tokenData = await (Token as any).findOne({ sessionName: session });
    if (!tokenData) {
      return res.status(404).json({
        status: 'error',
        message: 'Instância não encontrada'
      });
    }

    // Verificar se já está ativa
    if (clientsArray[session]) {
      return res.json({
        status: 'success',
        message: 'Instância já está ativa',
        data: {
          status: clientsArray[session].status,
          qrcode: clientsArray[session].qrcode
        }
      });
    }

    // Iniciar nova sessão
    const client = await createSessionUtil.startSession(req, session, {
      session: session,
      webhook: tokenData.webhook,
      waitQrCode: true
    });

    return res.json({
      status: 'success',
      message: 'Instância iniciada com sucesso',
      data: {
        status: client?.status || 'QRCODE',
        qrcode: client?.qrcode || null,
        urlcode: client?.urlcode || null
      }
    });

  } catch (error) {
    console.error('Erro ao iniciar instância:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Erro interno do servidor'
    });
  }
};

/**
 * @swagger
 * /api/{session}/stop:
 *   post:
 *     summary: Parar instância WhatsApp
 *     tags: [Instance Management]
 *     parameters:
 *       - in: path
 *         name: session
 *         required: true
 *         schema:
 *           type: string
 *         description: Nome da sessão
 *       - in: header
 *         name: Authorization
 *         required: true
 *         schema:
 *           type: string
 *         description: Token de autenticação
 *     responses:
 *       200:
 *         description: Instância parada com sucesso
 *       404:
 *         description: Instância não encontrada
 */
export const stopInstance = async (req: Request, res: Response) => {
  try {
    const { session } = req.params;
    const client = clientsArray[session];

    if (!client) {
      return res.status(404).json({
        status: 'error',
        message: 'Instância não encontrada ou não está ativa'
      });
    }

    // Parar a sessão
    await client.close();
    delete clientsArray[session];

    return res.json({
      status: 'success',
      message: 'Instância parada com sucesso'
    });

  } catch (error) {
    console.error('Erro ao parar instância:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Erro interno do servidor'
    });
  }
};

/**
 * @swagger
 * /api/instances:
 *   get:
 *     summary: Listar todas as instâncias
 *     tags: [Instance Management]
 *     responses:
 *       200:
 *         description: Lista de instâncias obtida com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       name:
 *                         type: string
 *                       status:
 *                         type: string
 *                       webhook:
 *                         type: string
 *                       createdAt:
 *                         type: string
 */
export const listInstances = async (req: Request, res: Response) => {
  try {
    const instances = await (Token as any).find({}, 'sessionName webhook config createdAt');
    
    const instancesWithStatus = instances.map((instance: any) => {
      const client = clientsArray[instance.sessionName];
      return {
        name: instance.sessionName,
        status: client ? (client as any).status : 'DISCONNECTED',
        webhook: instance.webhook || '',
        createdAt: instance.createdAt,
        isActive: !!client
      };
    });

    return res.json({
      status: 'success',
      data: instancesWithStatus
    });

  } catch (error) {
    console.error('Erro ao listar instâncias:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Erro interno do servidor'
    });
  }
};
