#!/bin/bash

echo "🧪 Testando API do WPPConnect Server - Versão Simplificada"
echo ""

BASE_URL="http://localhost:3000"
SECRET_KEY="THISISMYSECURETOKEN"
SESSION_NAME="test-session"

echo "1️⃣ Gerando token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/$SECRET_KEY/generate-token" \
  -H "Content-Type: application/json" \
  -d '{"session": "'$SESSION_NAME'"}')

echo "Resposta: $TOKEN_RESPONSE"
echo ""

echo "2️⃣ Verificando sessões existentes..."
curl -s -X GET "$BASE_URL/api/$SECRET_KEY/show-all-sessions"
echo ""
echo ""

echo "3️⃣ Testando health check..."
curl -s -X GET "$BASE_URL/healthz"
echo ""
echo ""

echo "4️⃣ Verificando métricas..."
curl -s -X GET "$BASE_URL/metrics" | head -5
echo ""
echo ""

echo "5️⃣ Testando Swagger UI..."
curl -s -I "$BASE_URL/api-docs/" | head -3
echo ""

echo "✅ Testes básicos concluídos!"
echo ""
echo "📋 Para testar com autenticação:"
echo "   1. Acesse: $BASE_URL/api-docs"
echo "   2. Use o token gerado no passo 1"
echo "   3. Teste as rotas que precisam de autenticação"
echo ""
echo "🔧 Comandos úteis:"
echo "   • Ver logs: docker-compose logs -f wppconnect-server"
echo "   • Reiniciar: docker-compose restart wppconnect-server"
echo "   • Parar: docker-compose down"
echo "   • Iniciar: docker-compose up -d"
