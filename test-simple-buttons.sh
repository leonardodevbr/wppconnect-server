#!/bin/bash

echo "🔘 TESTANDO BOTÕES SIMPLES (NÃO LISTA)!"
echo "======================================="

AUTH_TOKEN="\$2b\$10\$sRmYIsNESWyUvy6qi2TpSu..EbjsANVvsh7cgZRXAzHQtvxCGmXRy"

echo ""
echo "🔘 Testando botões simples com sendMessageOptions..."
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
  echo "   (Não deve ser uma lista, mas botões diretos)"
else
  echo "❌ Erro ao enviar botões simples"
  ERROR_MESSAGE=$(echo $RESPONSE | jq -r '.message // "Erro desconhecido"')
  echo "Mensagem de erro: $ERROR_MESSAGE"
fi

echo ""
echo "⏳ Aguardando 5 segundos para você verificar no WhatsApp..."
sleep 5

echo ""
echo "🔍 Vamos também testar diretamente com sendMessageOptions..."
echo "   (Testando se a lib WPPConnect suporta botões simples)"

# Teste direto com sendMessageOptions
RESPONSE_DIRECT=$(curl -s -X POST "http://localhost:3000/api/test-session/send-message" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": ["557488120795@c.us"],
    "message": "🔘 Teste direto com sendMessageOptions",
    "options": {
      "title": "Botões Diretos",
      "footer": "Teste de botões",
      "isDynamicReplyButtonsMsg": true,
      "dynamicReplyButtons": [
        {
          "id": "opcao1",
          "text": "Opção 1"
        },
        {
          "id": "opcao2", 
          "text": "Opção 2"
        }
      ]
    }
  }')

echo "Resposta do teste direto:"
echo $RESPONSE_DIRECT | jq .

STATUS_DIRECT=$(echo $RESPONSE_DIRECT | jq -r '.status // "error"')
echo ""
echo "Status do teste direto: $STATUS_DIRECT"

if [ "$STATUS_DIRECT" = "success" ]; then
  echo "🎉 SUCESSO! Teste direto funcionou!"
else
  echo "❌ Erro no teste direto"
  ERROR_DIRECT=$(echo $RESPONSE_DIRECT | jq -r '.message // "Erro desconhecido"')
  echo "Mensagem de erro: $ERROR_DIRECT"
fi

echo ""
echo "🏆 TESTE COMPLETO DOS BOTÕES SIMPLES!"
echo "======================================"
