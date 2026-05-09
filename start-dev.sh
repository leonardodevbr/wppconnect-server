#!/bin/bash

# Script de inicialização robusto para desenvolvimento local
echo "🚀 Iniciando ambiente de desenvolvimento WPPConnect Server..."

# Verificar se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Inicie o Docker primeiro."
    exit 1
fi

# Criar arquivo .env se não existir
if [ ! -f .env ]; then
    echo "📝 Criando arquivo .env..."
    cp env.example .env
    echo "✅ Arquivo .env criado."
fi

# Criar diretórios necessários
echo "📁 Criando diretórios necessários..."
mkdir -p uploads userDataDir WhatsAppImages logs

# Parar containers existentes
echo "🛑 Parando containers existentes..."
docker-compose down -v

# Limpar imagens antigas
echo "🧹 Limpando imagens antigas..."
docker system prune -f

# Construir e iniciar serviços
echo "🔨 Construindo e iniciando serviços..."
docker-compose up --build -d

# Aguardar serviços ficarem prontos
echo "⏳ Aguardando serviços ficarem prontos..."
sleep 30

# Verificar status dos serviços
echo "🔍 Verificando status dos serviços..."
docker-compose ps

# Verificar logs se houver problemas
echo "📋 Verificando logs..."
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Alguns serviços não estão funcionando. Verificando logs..."
    docker-compose logs wppconnect-server
    exit 1
fi

echo ""
echo "✅ Ambiente de desenvolvimento iniciado com sucesso!"
echo ""
echo "📊 Serviços disponíveis:"
echo "  • WPPConnect Server: http://localhost:3000"
echo "  • Swagger UI: http://localhost:3000/api-docs"
echo "  • MongoDB: localhost:27017"
echo "  • Redis: localhost:6379"
echo ""
echo "📝 Comandos úteis:"
echo "  • Ver logs: docker-compose logs -f wppconnect-server"
echo "  • Parar: docker-compose down"
echo "  • Reiniciar: docker-compose restart"
echo ""
echo "🎯 Próximos passos:"
echo "  1. Acesse http://localhost:3000/api-docs"
echo "  2. Execute: ./test-api.sh"