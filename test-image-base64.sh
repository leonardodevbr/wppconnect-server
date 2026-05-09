#!/bin/bash

echo "🖼️ Testando envio de imagem via base64..."

# Token de autenticação
AUTH_TOKEN="\$2b\$10\$sRmYIsNESWyUvy6qi2TpSu..EbjsANVvsh7cgZRXAzHQtvxCGmXRy"

# Número de teste
TEST_PHONE="557488120795@c.us"

# Ler o base64 do arquivo image.txt
echo "📄 Lendo imagem do arquivo image.txt..."
BASE64_IMAGE=$(cat image.txt | tr -d '\n\r')

if [ -z "$BASE64_IMAGE" ]; then
  echo "❌ Erro: Arquivo image.txt está vazio ou não encontrado"
  exit 1
fi

echo "✅ Imagem carregada! Tamanho: ${#BASE64_IMAGE} caracteres"

# Verificar se a sessão está conectada
echo "🔍 Verificando status da sessão..."
STATUS=$(curl -s -X GET "http://localhost:3000/api/test-session/status-session" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" | jq -r '.status')

echo "Status: $STATUS"

if [ "$STATUS" != "CONNECTED" ]; then
  echo "❌ Sessão não está conectada. Status: $STATUS"
  exit 1
fi

echo "✅ Sessão conectada! Enviando imagem..."

# Enviar imagem
RESPONSE=$(curl -s -X POST "http://localhost:3000/api/test-session/send-image" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "'$TEST_PHONE'",
    "base64": "'$BASE64_IMAGE'",
    "filename": "test-image.png",
    "caption": "🖼️ Teste de envio de imagem via base64!"
  }')

echo "Resposta:"
echo $RESPONSE | jq .

STATUS_RESPONSE=$(echo $RESPONSE | jq -r '.status // "error"')
echo ""
echo "Status: $STATUS_RESPONSE"

if [ "$STATUS_RESPONSE" = "success" ]; then
  echo "🎉 SUCESSO! Imagem enviada via base64!"
else
  echo "❌ Erro ao enviar imagem"
  ERROR_MESSAGE=$(echo $RESPONSE | jq -r '.message // "Erro desconhecido"')
  echo "Mensagem de erro: $ERROR_MESSAGE"
fi
