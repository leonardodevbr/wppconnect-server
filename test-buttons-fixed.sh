#!/bin/bash

echo "🔘 TESTANDO BOTÕES SIMPLES CORRIGIDOS!"
echo "======================================"

AUTH_TOKEN="\$2b\$10\$sRmYIsNESWyUvy6qi2TpSu..EbjsANVvsh7cgZRXAzHQtvxCGmXRy"

echo ""
echo "🔘 Testando botões simples (bug corrigido)..."
RESPONSE=$(curl -s -X POST "http://localhost:3000/api/test-session/send-buttons" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": ["557488120795@c.us"],
    "message": "🎯 Escolha uma opção rápida:",
    "title": "Menu Rápido",
    "footer": "Clique em uma opção",
    "dynamic_reply": true,
    "buttons": [
      {
        "id": "sim",
        "text": "✅ Sim"
      },
      {
        "id": "nao", 
        "text": "❌ Não"
      },
      {
        "id": "talvez",
        "text": "🤔 Talvez"
      }
    ]
  }')

echo "Resposta dos botões simples:"
echo $RESPONSE | jq .

STATUS_RESPONSE=$(echo $RESPONSE | jq -r '.status // "error"')
echo ""
echo "Status: $STATUS_RESPONSE"

if [ "$STATUS_RESPONSE" = "success" ]; then
  echo "🎉 SUCESSO! Botões simples enviados!"
  echo ""
  echo "📱 Verifique no WhatsApp se apareceram os botões interativos!"
  echo "   (Deve ser 3 botões diretos, não uma lista)"
  
  # Verificar se tem isDynamicReplyButtonsMsg: true
  IS_DYNAMIC=$(echo $RESPONSE | jq -r '.response[0].isDynamicReplyButtonsMsg // false')
  echo ""
  echo "🔍 isDynamicReplyButtonsMsg: $IS_DYNAMIC"
  
  if [ "$IS_DYNAMIC" = "true" ]; then
    echo "✅ Botões interativos ativados corretamente!"
  else
    echo "⚠️ Botões podem não estar funcionando como esperado"
  fi
else
  echo "❌ Erro ao enviar botões simples"
  ERROR_MESSAGE=$(echo $RESPONSE | jq -r '.message // "Erro desconhecido"')
  echo "Mensagem de erro: $ERROR_MESSAGE"
fi

echo ""
echo "🏆 TESTE DOS BOTÕES SIMPLES CORRIGIDOS!"
echo "======================================="
