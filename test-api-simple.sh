#!/bin/bash

echo "🧪 Testando API do WPPConnect Server..."
echo ""

# Configurações
BASE_URL="http://localhost:3000"
SECRET_KEY="THISISMYSECURETOKEN"
SESSION_NAME="test-session"

echo "1️⃣ Gerando token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/$SECRET_KEY/generate-token" \
  -H "Content-Type: application/json" \
  -d '{"session": "'$SESSION_NAME'"}')

echo "Resposta: $TOKEN_RESPONSE"

# Extrair token da resposta
TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
FULL_TOKEN="$SESSION_NAME:$TOKEN"

echo "Token completo: $FULL_TOKEN"
echo ""

echo "2️⃣ Verificando sessões existentes..."
curl -s -X GET "$BASE_URL/api/$SECRET_KEY/show-all-sessions" | jq .
echo ""

echo "3️⃣ Verificando status da sessão..."
curl -s -X GET "$BASE_URL/api/$SESSION_NAME/status-session" \
  -H "Authorization: Bearer $FULL_TOKEN" | jq .
echo ""

echo "4️⃣ Iniciando sessão..."
curl -s -X POST "$BASE_URL/api/$SESSION_NAME/start-session" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $FULL_TOKEN" \
  -d '{"session": "'$SESSION_NAME'"}' | jq .
echo ""

echo "5️⃣ Verificando QR Code..."
curl -s -X GET "$BASE_URL/api/$SESSION_NAME/qrcode" \
  -H "Authorization: Bearer $FULL_TOKEN" | jq .
echo ""

echo "6️⃣ Testando health check..."
curl -s -X GET "$BASE_URL/healthz" | jq .
echo ""

echo "✅ Testes concluídos!"
echo ""
echo "📱 Para conectar o WhatsApp:"
echo "   1. Execute o teste 4 para iniciar a sessão"
echo "   2. Execute o teste 5 para obter o QR Code"
echo "   3. Escaneie o QR Code com seu WhatsApp"
echo "   4. Aguarde a sessão ficar conectada"
echo ""
echo "📊 Para monitorar:"
echo "   • Swagger UI: $BASE_URL/api-docs"
echo "   • Health Check: $BASE_URL/healthz"
echo "   • Métricas: $BASE_URL/metrics"
