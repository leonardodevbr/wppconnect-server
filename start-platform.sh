#!/bin/bash

# Script para iniciar o ambiente completo (Backend + Frontend)

echo "🚀 Iniciando SIGVSA WhatsApp API Platform..."

# Verificar se o Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Inicie o Docker primeiro."
    exit 1
fi

# Iniciar backend (Docker)
echo "📦 Iniciando backend (Docker)..."
docker-compose up -d

# Aguardar backend estar pronto
echo "⏳ Aguardando backend estar pronto..."
sleep 10

# Verificar se o backend está rodando
if curl -s http://localhost:3000/api/THISISMYSECURETOKEN/show-all-sessions > /dev/null; then
    echo "✅ Backend iniciado com sucesso!"
else
    echo "❌ Erro ao iniciar backend"
    exit 1
fi

# Iniciar frontend
echo "🎨 Iniciando frontend..."
cd frontend-react

# Verificar se node_modules existe
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependências do frontend..."
    npm install
fi

echo "🌐 Frontend será iniciado em http://localhost:5173"
echo "🔧 Backend rodando em http://localhost:3000"
echo ""
echo "📋 Credenciais de teste:"
echo "   Email: admin@sigvsa.com"
echo "   Senha: admin123"
echo ""

# Iniciar frontend
npm run dev
