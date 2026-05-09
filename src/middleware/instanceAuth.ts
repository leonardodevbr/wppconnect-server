import { Request, Response } from 'express';
import bcrypt from 'bcrypt';

// Função para verificar token manualmente
export const verifyTokenManually = (req: Request, res: Response, next: Function) => {
  const secureToken = req.serverOptions.secretKey;
  const { session } = req.params;
  const { authorization: token } = req.headers;
  
  if (!session) {
    return res.status(401).json({ message: 'Session not informed' });
  }

  if (!token || !token.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Token is not present. Check your header and try again' });
  }

  const tokenValue = token.split(' ')[1];
  if (!tokenValue) {
    return res.status(401).json({ message: 'Token is not present. Check your header and try again' });
  }

  try {
    // Decodificar o token (reverter a formatação)
    const tokenDecrypt = tokenValue.replace(/_/g, '/').replace(/-/g, '+');
    
    bcrypt.compare(session + secureToken, tokenDecrypt, function (err, result) {
      if (result) {
        req.session = session;
        req.token = tokenDecrypt;
        next();
      } else {
        return res.status(401).json({ error: 'Check that the Session and Token are correct' });
      }
    });
  } catch (error) {
    return res.status(401).json({ error: 'Check that the Session and Token are correct.' });
  }
};
