#!/bin/bash

# Script de teste para validar funcionalidades básicas
# Execute este script após iniciar o ambiente de desenvolvimento

echo "🧪 Testando funcionalidades do WPPConnect Server..."

BASE_URL="http://localhost:3000"
SECRET_KEY="THISISMYSECURETOKEN"
SESSION_NAME="test-session"

# Função para fazer requisições HTTP
make_request() {
    local method=$1
    local url=$2
    local data=$3
    local headers=$4
    
    if [ -n "$data" ]; then
        curl -s -X $method "$url" \
            -H "Content-Type: application/json" \
            -H "$headers" \
            -d "$data"
    else
        curl -s -X $method "$url" \
            -H "$headers"
    fi
}

echo ""
echo "1️⃣ Testando geração de token..."
TOKEN_RESPONSE=$(make_request "POST" "$BASE_URL/api/$SESSION_NAME/$SECRET_KEY/generate-token")
echo "Resposta: $TOKEN_RESPONSE"

# Extrair token da resposta
TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
if [ -z "$TOKEN" ]; then
    echo "❌ Falha ao gerar token"
    exit 1
fi

echo "✅ Token gerado: $TOKEN"

echo ""
echo "2️⃣ Testando listagem de sessões..."
SESSIONS_RESPONSE=$(make_request "GET" "$BASE_URL/api/$SECRET_KEY/show-all-sessions")
echo "Resposta: $SESSIONS_RESPONSE"

echo ""
echo "3️⃣ Testando início de sessão..."
START_RESPONSE=$(make_request "POST" "$BASE_URL/api/$SESSION_NAME/start-session" '{"waitQrCode": true}' "Authorization: Bearer $TOKEN")
echo "Resposta: $START_RESPONSE"

echo ""
echo "4️⃣ Testando status da sessão..."
STATUS_RESPONSE=$(make_request "GET" "$BASE_URL/api/$SESSION_NAME/status-session" "" "Authorization: Bearer $TOKEN")
echo "Resposta: $STATUS_RESPONSE"

echo ""
echo "5️⃣ Testando QR Code..."
QR_RESPONSE=$(make_request "GET" "$BASE_URL/api/$SESSION_NAME/qrcode-session" "" "Authorization: Bearer $TOKEN")
echo "Resposta: $QR_RESPONSE"

echo ""
echo "6️⃣ Testando métricas..."
METRICS_RESPONSE=$(make_request "GET" "$BASE_URL/metrics")
echo "Métricas disponíveis: $(echo $METRICS_RESPONSE | wc -l) linhas"

echo ""
echo "7️⃣ Testando health check..."
HEALTH_RESPONSE=$(make_request "GET" "$BASE_URL/healthz")
echo "Resposta: $HEALTH_RESPONSE"

echo ""
echo "✅ Testes básicos concluídos!"
echo ""
echo "📱 Para testar envio de mensagens:"
echo "  1. Escaneie o QR code que apareceu no teste 5"
echo "  2. Aguarde a sessão ficar conectada"
echo "  3. Use o endpoint /api/$SESSION_NAME/send-message"
echo ""
echo "📊 Para monitorar:"
echo "  • Prometheus: http://localhost:9090"
echo "  • Grafana: http://localhost:3001"
echo "  • Swagger: http://localhost:3000/api-docs"
