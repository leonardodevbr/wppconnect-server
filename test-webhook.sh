#!/bin/bash

echo "🔔 TESTANDO WEBHOOKS!"
echo "===================="

AUTH_TOKEN="\$2b\$10\$sRmYIsNESWyUvy6qi2TpSu..EbjsANVvsh7cgZRXAzHQtvxCGmXRy"

echo ""
echo "🔍 Verificando status da sessão..."
STATUS_RESPONSE=$(curl -s -X POST "http://localhost:3000/api/test-session/send-message" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": ["557488120795@c.us"],
    "message": "🔔 TESTE DE WEBHOOK - Esta mensagem deve disparar o webhook para https://webhook.sigvsa.com.br/1af145f9-2b0b-4103-97f3-c9ea1828610f"
  }')

echo "Resposta da mensagem:"
echo $STATUS_RESPONSE | jq .

STATUS=$(echo $STATUS_RESPONSE | jq -r '.status // "error"')
echo ""
echo "Status: $STATUS"

if [ "$STATUS" = "success" ]; then
  echo "✅ Mensagem enviada com sucesso!"
  echo ""
  echo "🔔 WEBHOOK DEVE TER SIDO DISPARADO!"
  echo "   Verifique em: https://webhook.sigvsa.com.br/1af145f9-2b0b-4103-97f3-c9ea1828610f"
  echo ""
  echo "📱 A mensagem deve aparecer no WhatsApp do número 557488120795"
  echo "🔔 E o webhook deve receber os dados da mensagem"
else
  echo "❌ Erro ao enviar mensagem"
  ERROR_MESSAGE=$(echo $STATUS_RESPONSE | jq -r '.message // "Erro desconhecido"')
  echo "Mensagem de erro: $ERROR_MESSAGE"
fi

echo ""
echo "⏳ Aguardando 5 segundos para você verificar o webhook..."
sleep 5

echo ""
echo "🔍 Verificando logs do container para erros de webhook..."
docker-compose logs --tail=10 wppconnect-server | grep -i "webhook\|error\|warn"

echo ""
echo "🏆 TESTE DE WEBHOOK COMPLETO!"
echo "============================="
