#!/bin/bash

echo "🖼️ TESTE DE ENVIO DE IMAGENS VIA URL - WPPConnect Server"
echo "======================================================="
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

# URLs de imagens públicas para teste
TEST_IMAGE_URLS=(
  "https://via.placeholder.com/300x200/FF0000/FFFFFF?text=Teste+1"
  "https://via.placeholder.com/300x200/00FF00/000000?text=Teste+2"
  "https://via.placeholder.com/300x200/0000FF/FFFFFF?text=Teste+3"
)

echo "🖼️ Teste 1: Enviando imagem via URL pública"
echo "==========================================="

echo "Enviando primeira imagem..."
RESPONSE1=$(curl -s -X POST "$BASE_URL/api/$SESSION/send-image" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "'$TEST_PHONE'",
    "url": "'${TEST_IMAGE_URLS[0]}'",
    "filename": "test-image-1.png",
    "caption": "🖼️ Teste de envio de imagem via URL!"
  }')

echo "Resposta:"
echo $RESPONSE1 | jq .

STATUS1=$(echo $RESPONSE1 | jq -r '.status // "error"')
echo ""
echo "Status: $STATUS1"

if [ "$STATUS1" = "success" ]; then
    echo "✅ Imagem via URL enviada com sucesso!"
else
    echo "❌ Erro ao enviar imagem via URL"
fi

echo ""
echo "🖼️ Teste 2: Enviando imagem via URL com caption diferente"
echo "========================================================"

echo "Enviando segunda imagem..."
RESPONSE2=$(curl -s -X POST "$BASE_URL/api/$SESSION/send-image" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "'$TEST_PHONE'",
    "url": "'${TEST_IMAGE_URLS[1]}'",
    "filename": "test-image-2.png",
    "caption": "📸 Segunda imagem via URL com caption diferente!"
  }')

echo "Resposta:"
echo $RESPONSE2 | jq .

STATUS2=$(echo $RESPONSE2 | jq -r '.status // "error"')
echo ""
echo "Status: $STATUS2"

if [ "$STATUS2" = "success" ]; then
    echo "✅ Segunda imagem via URL enviada com sucesso!"
else
    echo "❌ Erro ao enviar segunda imagem via URL"
fi

echo ""
echo "🖼️ Teste 3: Enviando imagem via URL sem caption"
echo "=============================================="

echo "Enviando terceira imagem..."
RESPONSE3=$(curl -s -X POST "$BASE_URL/api/$SESSION/send-image" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "'$TEST_PHONE'",
    "url": "'${TEST_IMAGE_URLS[2]}'",
    "filename": "test-image-3.png"
  }')

echo "Resposta:"
echo $RESPONSE3 | jq .

STATUS3=$(echo $RESPONSE3 | jq -r '.status // "error"')
echo ""
echo "Status: $STATUS3"

if [ "$STATUS3" = "success" ]; then
    echo "✅ Terceira imagem via URL enviada com sucesso!"
else
    echo "❌ Erro ao enviar terceira imagem via URL"
fi

echo ""
echo "📊 RESUMO DOS TESTES:"
echo "===================="
echo "Teste 1 (URL com caption): $STATUS1"
echo "Teste 2 (URL com caption diferente): $STATUS2"
echo "Teste 3 (URL sem caption): $STATUS3"

SUCCESS_COUNT=0
if [ "$STATUS1" = "success" ]; then SUCCESS_COUNT=$((SUCCESS_COUNT + 1)); fi
if [ "$STATUS2" = "success" ]; then SUCCESS_COUNT=$((SUCCESS_COUNT + 1)); fi
if [ "$STATUS3" = "success" ]; then SUCCESS_COUNT=$((SUCCESS_COUNT + 1)); fi

echo ""
echo "✅ Sucessos: $SUCCESS_COUNT/3"

if [ "$SUCCESS_COUNT" -eq "3" ]; then
    echo ""
    echo "🎉 TODOS OS TESTES DE IMAGEM VIA URL PASSARAM!"
    echo "✅ Envio de imagens via URL funcionando"
    echo "✅ Caption funcionando"
    echo "✅ Envio sem caption funcionando"
    echo ""
    echo "💡 VANTAGENS DO ENVIO VIA URL:"
    echo "   • Mais eficiente que base64"
    echo "   • Escalável para grandes volumes"
    echo "   • Ideal para S3 e CDNs"
    echo "   • Menor uso de memória"
else
    echo ""
    echo "⚠️ Alguns testes falharam. Verifique os logs acima."
fi

echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo "1. ✅ Teste de envio de imagens via URL"
echo "2. 🔄 Implementar upload para S3"
echo "3. 🔄 Testar diferentes formatos (JPG, PNG, GIF)"
echo "4. 🔄 Configurar webhooks"
