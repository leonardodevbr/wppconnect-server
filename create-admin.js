const mongoose = require('mongoose');

// Schema do usuário
const UserSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true },
  name: { type: String, required: true },
  role: { type: String, enum: ['admin', 'user'], default: 'user' },
  createdAt: { type: Date, default: Date.now }
});

// Importar bcrypt
const bcrypt = require('bcrypt');

async function createAdmin() {
  try {
    // Conectar ao MongoDB
    await mongoose.connect('mongodb://mongo:27017/wppconnect', {
      useNewUrlParser: true,
      useUnifiedTopology: true
    });
    
    console.log('Conectado ao MongoDB');
    
    // Verificar se usuário já existe
    const User = mongoose.model('User', UserSchema);
    const existingUser = await User.findOne({ email: 'admin@sigvsa.com' });
    
    if (existingUser) {
      console.log('Usuário admin já existe!');
      await mongoose.disconnect();
      return;
    }
    
    // Criar hash da senha
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('admin123', salt);
    
    // Criar usuário admin
    const admin = new User({
      email: 'admin@sigvsa.com',
      password: hashedPassword,
      name: 'Administrador',
      role: 'admin'
    });
    
    await admin.save();
    
    console.log('✅ Usuário admin criado com sucesso!');
    console.log('Email: admin@sigvsa.com');
    console.log('Senha: admin123');
    
    await mongoose.disconnect();
    
  } catch (error) {
    console.error('Erro ao criar admin:', error);
    process.exit(1);
  }
}

createAdmin();
