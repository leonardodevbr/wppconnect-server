#!/bin/bash

echo "🖼️ TESTE DE ENVIO DE IMAGENS - WPPConnect Server"
echo "================================================"
echo ""

# Configurações
BASE_URL="http://localhost:3000"
AUTH_TOKEN="\$2b\$10\$sRmYIsNESWyUvy6qi2TpSu..EbjsANVvsh7cgZRXAzHQtvxCGmXRy"
SESSION="test-session"
TEST_PHONE="557488120795"

echo "📋 Configurações:"
echo "Base URL: $BASE_URL"
echo "Session: $SESSION"
echo "Test Phone: $TEST_PHONE"
echo ""

# Função para criar uma imagem base64 simples (1x1 pixel PNG)
create_test_image_base64() {
    # PNG de 1x1 pixel transparente em base64
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
}

echo "🖼️ Teste 1: Enviando imagem via base64"
echo "====================================="

# Criar imagem de teste em base64
TEST_IMAGE_BASE64=$(create_test_image_base64)

echo "Enviando imagem de teste..."
RESPONSE1=$(curl -s -X POST "$BASE_URL/api/$SESSION/send-image" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "'$TEST_PHONE'",
    "base64": "'$TEST_IMAGE_BASE64'",
    "filename": "test-image.png",
    "caption": "🖼️ Teste de envio de imagem via API WPPConnect!"
  }')

echo "Resposta:"
echo $RESPONSE1 | jq .

STATUS1=$(echo $RESPONSE1 | jq -r '.status // "error"')
echo ""
echo "Status: $STATUS1"

if [ "$STATUS1" == "success" ]; then
    echo "✅ Imagem enviada com sucesso!"
else
    echo "❌ Erro ao enviar imagem"
fi

echo ""
echo "🖼️ Teste 2: Enviando imagem com caption diferente"
echo "================================================="

RESPONSE2=$(curl -s -X POST "$BASE_URL/api/$SESSION/send-image" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "'$TEST_PHONE'",
    "base64": "'$TEST_IMAGE_BASE64'",
    "filename": "test-image-2.png",
    "caption": "📸 Segunda imagem de teste com caption diferente!"
  }')

echo "Resposta:"
echo $RESPONSE2 | jq .

STATUS2=$(echo $RESPONSE2 | jq -r '.status // "error"')
echo ""
echo "Status: $STATUS2"

if [ "$STATUS2" == "success" ]; then
    echo "✅ Segunda imagem enviada com sucesso!"
else
    echo "❌ Erro ao enviar segunda imagem"
fi

echo ""
echo "🖼️ Teste 3: Enviando imagem sem caption"
echo "======================================"

RESPONSE3=$(curl -s -X POST "$BASE_URL/api/$SESSION/send-image" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "'$TEST_PHONE'",
    "base64": "'$TEST_IMAGE_BASE64'",
    "filename": "test-image-no-caption.png"
  }')

echo "Resposta:"
echo $RESPONSE3 | jq .

STATUS3=$(echo $RESPONSE3 | jq -r '.status // "error"')
echo ""
echo "Status: $STATUS3"

if [ "$STATUS3" == "success" ]; then
    echo "✅ Imagem sem caption enviada com sucesso!"
else
    echo "❌ Erro ao enviar imagem sem caption"
fi

echo ""
echo "📊 RESUMO DOS TESTES:"
echo "===================="
echo "Teste 1 (com caption): $STATUS1"
echo "Teste 2 (caption diferente): $STATUS2"
echo "Teste 3 (sem caption): $STATUS3"

SUCCESS_COUNT=0
if [ "$STATUS1" == "success" ]; then SUCCESS_COUNT=$((SUCCESS_COUNT + 1)); fi
if [ "$STATUS2" == "success" ]; then SUCCESS_COUNT=$((SUCCESS_COUNT + 1)); fi
if [ "$STATUS3" == "success" ]; then SUCCESS_COUNT=$((SUCCESS_COUNT + 1)); fi

echo ""
echo "✅ Sucessos: $SUCCESS_COUNT/3"

if [ "$SUCCESS_COUNT" -eq "3" ]; then
    echo ""
    echo "🎉 TODOS OS TESTES DE IMAGEM PASSARAM!"
    echo "✅ Envio de imagens via base64 funcionando"
    echo "✅ Caption funcionando"
    echo "✅ Envio sem caption funcionando"
else
    echo ""
    echo "⚠️ Alguns testes falharam. Verifique os logs acima."
fi

echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo "1. ✅ Teste de envio de imagens"
echo "2. 🔄 Testar upload de arquivo real"
echo "3. 🔄 Testar diferentes formatos (JPG, PNG, GIF)"
echo "4. 🔄 Configurar webhooks"
