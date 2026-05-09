import { Request, Response } from 'express';
import User from '../models/User';

// Simplificado - sem JWT por enquanto

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: Fazer login
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login realizado com sucesso
 */
export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        status: 'error',
        message: 'Email e senha são obrigatórios'
      });
    }

    // Buscar usuário
    const user = await User.findOne({ email: email.toLowerCase() });
    
    if (!user) {
      return res.status(401).json({
        status: 'error',
        message: 'Credenciais inválidas'
      });
    }

    // Verificar senha
    const isValid = await user.comparePassword(password);
    
    if (!isValid) {
      return res.status(401).json({
        status: 'error',
        message: 'Credenciais inválidas'
      });
    }

    // Gerar token simples (sem JWT)
    const token = Buffer.from(`${user._id}:${user.email}:${Date.now()}`).toString('base64');

    res.json({
      status: 'success',
      data: {
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          role: user.role,
          createdAt: user.createdAt
        },
        token
      }
    });

  } catch (error) {
    console.error('Erro no login:', error);
    res.status(500).json({
      status: 'error',
      message: 'Erro interno do servidor'
    });
  }
};

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Criar conta de usuário
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               name:
 *                 type: string
 *     responses:
 *       201:
 *         description: Conta criada com sucesso
 */
export const register = async (req: Request, res: Response) => {
  try {
    const { email, password, name } = req.body;

    if (!email || !password || !name) {
      return res.status(400).json({
        status: 'error',
        message: 'Email, senha e nome são obrigatórios'
      });
    }

    // Verificar se usuário já existe
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    
    if (existingUser) {
      return res.status(400).json({
        status: 'error',
        message: 'Usuário já existe'
      });
    }

    // Criar usuário (senha será hashada automaticamente pelo pre-save)
    const user = await User.create({
      email: email.toLowerCase(),
      password,
      name,
      role: req.body.role || 'user' // Aceitar role do request ou default 'user'
    });

    // Gerar token simples (sem JWT)
    const token = Buffer.from(`${user._id}:${user.email}:${Date.now()}`).toString('base64');

    res.status(201).json({
      status: 'success',
      data: {
        user: {
          id: user._id,
          email: user.email,
          name: user.name,
          role: user.role,
          createdAt: user.createdAt
        },
        token
      }
    });

  } catch (error) {
    console.error('Erro no registro:', error);
    res.status(500).json({
      status: 'error',
      message: 'Erro interno do servidor'
    });
  }
};

/**
 * @swagger
 * /api/auth/me:
 *   get:
 *     summary: Obter informações do usuário logado
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Informações do usuário
 */
export const getMe = async (req: Request, res: Response) => {
  try {
    // Pega o ID do token (se tiver middleware de auth)
    const userId = (req as any).user?.id;
    
    if (!userId) {
      return res.status(401).json({
        status: 'error',
        message: 'Não autenticado'
      });
    }

    const user = await User.findById(userId).select('-password');
    
    if (!user) {
      return res.status(404).json({
        status: 'error',
        message: 'Usuário não encontrado'
      });
    }

    res.json({
      status: 'success',
      data: user
    });

  } catch (error) {
    console.error('Erro ao obter usuário:', error);
    res.status(500).json({
      status: 'error',
      message: 'Erro interno do servidor'
    });
  }
};
