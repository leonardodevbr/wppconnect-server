import { Request, Response } from 'express';
import Token from '../util/tokenStore/model/token';

/**
 * @swagger
 * /api/{session}/config:
 *   get:
 *     summary: Obter configurações da instância
 *     tags: [Instance Config]
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
 *         description: Configurações obtidas com sucesso
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
 *                     webhook:
 *                       type: string
 *                       example: https://webhook.site/123
 *                     config:
 *                       type: object
 *       401:
 *         description: Token inválido
 *       404:
 *         description: Instância não encontrada
 */
export const getInstanceConfig = async (req: Request, res: Response) => {
  try {
    const { session } = req.params;
    
    const tokenData = await (Token as any).findOne({ sessionName: session });
    
    if (!tokenData) {
      return res.status(404).json({
        status: 'error',
        message: 'Instância não encontrada'
      });
    }

    const config = tokenData.config ? JSON.parse(tokenData.config) : {};
    
    return res.json({
      status: 'success',
      data: {
        webhook: tokenData.webhook || '',
        config: config
      }
    });
  } catch (error) {
    console.error('Erro ao obter configurações da instância:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Erro interno do servidor'
    });
  }
};

/**
 * @swagger
 * /api/{session}/config:
 *   post:
 *     summary: Salvar configurações da instância
 *     tags: [Instance Config]
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
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               webhook:
 *                 type: string
 *                 example: https://webhook.site/123
 *               config:
 *                 type: object
 *                 description: Configurações adicionais da instância
 *     responses:
 *       200:
 *         description: Configurações salvas com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 message:
 *                   type: string
 *                   example: Configurações salvas com sucesso
 *       401:
 *         description: Token inválido
 *       404:
 *         description: Instância não encontrada
 */
export const saveInstanceConfig = async (req: Request, res: Response) => {
  try {
    const { session } = req.params;
    const { webhook, config } = req.body;
    
    const tokenData = await (Token as any).findOne({ sessionName: session });
    
    if (!tokenData) {
      return res.status(404).json({
        status: 'error',
        message: 'Instância não encontrada'
      });
    }

    // Atualizar webhook
    if (webhook !== undefined) {
      tokenData.webhook = webhook;
    }

    // Atualizar configurações
    if (config !== undefined) {
      const currentConfig = tokenData.config ? JSON.parse(tokenData.config) : {};
      const updatedConfig = { ...currentConfig, ...config };
      tokenData.config = JSON.stringify(updatedConfig);
    }

    await tokenData.save();

    return res.json({
      status: 'success',
      message: 'Configurações salvas com sucesso'
    });
  } catch (error) {
    console.error('Erro ao salvar configurações da instância:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Erro interno do servidor'
    });
  }
};

/**
 * @swagger
 * /api/{session}/webhook:
 *   post:
 *     summary: Configurar webhook da instância
 *     tags: [Instance Config]
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
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               url:
 *                 type: string
 *                 example: https://webhook.site/123
 *                 description: URL do webhook
 *     responses:
 *       200:
 *         description: Webhook configurado com sucesso
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: success
 *                 message:
 *                   type: string
 *                   example: Webhook configurado com sucesso
 *       401:
 *         description: Token inválido
 *       404:
 *         description: Instância não encontrada
 */
export const setInstanceWebhook = async (req: Request, res: Response) => {
  try {
    const { session } = req.params;
    const { url } = req.body;
    
    const tokenData = await (Token as any).findOne({ sessionName: session });
    
    if (!tokenData) {
      return res.status(404).json({
        status: 'error',
        message: 'Instância não encontrada'
      });
    }

    tokenData.webhook = url;
    await tokenData.save();

    return res.json({
      status: 'success',
      message: 'Webhook configurado com sucesso'
    });
  } catch (error) {
    console.error('Erro ao configurar webhook da instância:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Erro interno do servidor'
    });
  }
};
