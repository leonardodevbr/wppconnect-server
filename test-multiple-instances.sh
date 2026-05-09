#!/bin/bash

echo "🧪 Testando Criação de Múltiplas Instâncias WhatsApp..."
echo ""

# Configurações
BASE_URL="http://localhost:3000"
SECRET_KEY="THISISMYSECURETOKEN"

echo "1️⃣ Listando instâncias existentes..."
curl -s -X GET "$BASE_URL/api/instances" | jq .
echo ""

echo "2️⃣ Criando primeira instância..."
INSTANCE1_RESPONSE=$(curl -s -X POST "$BASE_URL/api/create-instance" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "cliente-1",
    "webhook": "https://webhook.site/123"
  }')

echo "Resposta: $INSTANCE1_RESPONSE"
INSTANCE1_TOKEN=$(echo $INSTANCE1_RESPONSE | jq -r '.data.full')
echo "Token da Instância 1: $INSTANCE1_TOKEN"
echo ""

echo "3️⃣ Criando segunda instância..."
INSTANCE2_RESPONSE=$(curl -s -X POST "$BASE_URL/api/create-instance" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "cliente-2",
    "webhook": "https://webhook.site/456"
  }')

echo "Resposta: $INSTANCE2_RESPONSE"
INSTANCE2_TOKEN=$(echo $INSTANCE2_RESPONSE | jq -r '.data.full')
echo "Token da Instância 2: $INSTANCE2_TOKEN"
echo ""

echo "4️⃣ Criando terceira instância..."
INSTANCE3_RESPONSE=$(curl -s -X POST "$BASE_URL/api/create-instance" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "cliente-3"
  }')

echo "Resposta: $INSTANCE3_RESPONSE"
INSTANCE3_TOKEN=$(echo $INSTANCE3_RESPONSE | jq -r '.data.full')
echo "Token da Instância 3: $INSTANCE3_TOKEN"
echo ""

echo "5️⃣ Listando todas as instâncias..."
curl -s -X GET "$BASE_URL/api/instances" | jq .
echo ""

echo "6️⃣ Testando QR Code da primeira instância..."
curl -s -X GET "$BASE_URL/api/cliente-1/qrcode" \
  -H "Authorization: Bearer $INSTANCE1_TOKEN" | jq .
echo ""

echo "7️⃣ Testando QR Code da segunda instância..."
curl -s -X GET "$BASE_URL/api/cliente-2/qrcode" \
  -H "Authorization: Bearer $INSTANCE2_TOKEN" | jq .
echo ""

echo "8️⃣ Iniciando primeira instância..."
curl -s -X POST "$BASE_URL/api/cliente-1/start" \
  -H "Authorization: Bearer $INSTANCE1_TOKEN" | jq .
echo ""

echo "9️⃣ Iniciando segunda instância..."
curl -s -X POST "$BASE_URL/api/cliente-2/start" \
  -H "Authorization: Bearer $INSTANCE2_TOKEN" | jq .
echo ""

echo "🔟 Verificando status das instâncias..."
curl -s -X GET "$BASE_URL/api/instances" | jq .
echo ""

echo "✅ Testes de múltiplas instâncias concluídos!"
echo ""
echo "📱 Para conectar os WhatsApps:"
echo "   1. Execute os testes 6 e 7 para obter os QR Codes"
echo "   2. Escaneie cada QR Code com um WhatsApp diferente"
echo "   3. Aguarde as sessões ficarem conectadas"
echo ""
echo "📊 Para monitorar:"
echo "   • Swagger UI: $BASE_URL/api-docs"
echo "   • Health Check: $BASE_URL/healthz"
echo "   • Métricas: $BASE_URL/metrics"
echo ""
echo "🔧 Para testar webhooks individuais:"
echo "   • Instância 1: https://webhook.site/123"
echo "   • Instância 2: https://webhook.site/456"
echo "   • Instância 3: sem webhook configurado"
