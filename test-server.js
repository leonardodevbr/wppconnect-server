const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

// Mock de dados
let instances = [
  {
    name: 'test-session',
    status: 'CONNECTED',
    webhook: '',
    createdAt: new Date().toISOString(),
    isActive: true
  }
];

// Health check
app.get('/healthz', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Listar instâncias
app.get('/api/instances', (req, res) => {
  res.json({
    status: 'success',
    data: instances
  });
});

// Criar instância
app.post('/api/create-instance', (req, res) => {
  const { name, webhook } = req.body;
  
  if (!name) {
    return res.status(400).json({
      status: 'error',
      message: 'Nome da instância é obrigatório'
    });
  }

  const newInstance = {
    name: name.toLowerCase().replace(/[^a-z0-9-]/g, '-'),
    status: 'QRCODE',
    webhook: webhook || '',
    createdAt: new Date().toISOString(),
    isActive: false
  };

  instances.push(newInstance);

  res.json({
    status: 'success',
    data: {
      name: newInstance.name,
      token: 'mock-token-' + Date.now(),
      full: newInstance.name + ':mock-token-' + Date.now(),
      qrcode: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
      urlcode: 'mock-url-code',
      status: 'QRCODE'
    }
  });
});

// Configurar webhook
app.post('/api/:session/webhook', (req, res) => {
  const { session } = req.params;
  const { url } = req.body;
  
  const instance = instances.find(i => i.name === session);
  if (!instance) {
    return res.status(404).json({
      status: 'error',
      message: 'Instância não encontrada'
    });
  }

  instance.webhook = url;

  res.json({
    status: 'success',
    message: 'Webhook configurado com sucesso'
  });
});

// QR Code
app.get('/api/:session/qrcode', (req, res) => {
  const { session } = req.params;
  
  res.json({
    status: 'success',
    data: {
      qrcode: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
      urlcode: 'mock-url-code',
      sessionStatus: 'QRCODE'
    }
  });
});

// Iniciar instância
app.post('/api/:session/start', (req, res) => {
  const { session } = req.params;
  
  const instance = instances.find(i => i.name === session);
  if (!instance) {
    return res.status(404).json({
      status: 'error',
      message: 'Instância não encontrada'
    });
  }

  instance.status = 'QRCODE';
  instance.isActive = true;

  res.json({
    status: 'success',
    message: 'Instância iniciada com sucesso',
    data: {
      status: 'QRCODE',
      qrcode: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
      urlcode: 'mock-url-code'
    }
  });
});

// Parar instância
app.post('/api/:session/stop', (req, res) => {
  const { session } = req.params;
  
  const instance = instances.find(i => i.name === session);
  if (!instance) {
    return res.status(404).json({
      status: 'error',
      message: 'Instância não encontrada'
    });
  }

  instance.status = 'DISCONNECTED';
  instance.isActive = false;

  res.json({
    status: 'success',
    message: 'Instância parada com sucesso'
  });
});

// Gerar token
app.post('/api/:session/:secretkey/generate-token', (req, res) => {
  const { session } = req.params;
  
  res.json({
    status: 'success',
    token: 'mock-token-' + Date.now(),
    full: session + ':mock-token-' + Date.now()
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Servidor de teste rodando na porta ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/healthz`);
  console.log(`🔧 API: http://localhost:${PORT}/api`);
});
