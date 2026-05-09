// Script de inicialização do MongoDB
db = db.getSiblingDB('wppconnect');

// Criar usuário para a aplicação
db.createUser({
  user: 'wppconnect_user',
  pwd: 'wppconnect_pass',
  roles: [
    {
      role: 'readWrite',
      db: 'wppconnect'
    }
  ]
});

// Criar coleções iniciais
db.createCollection('tokens');
db.createCollection('sessions');
db.createCollection('messages');
db.createCollection('contacts');

// Criar índices para performance
db.tokens.createIndex({ sessionName: 1 }, { unique: true });
db.sessions.createIndex({ sessionId: 1 }, { unique: true });
db.messages.createIndex({ timestamp: 1 });
db.messages.createIndex({ from: 1 });
db.messages.createIndex({ to: 1 });

print('MongoDB inicializado com sucesso!');
