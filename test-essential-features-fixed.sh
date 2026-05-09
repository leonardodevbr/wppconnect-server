#!/bin/bash

echo "🧪 TESTE CORRIGIDO DAS FUNCIONALIDADES ESSENCIAIS"
echo "================================================="
echo ""

# Configurações
BASE_URL="http://localhost:3000"
SECRET_KEY="THISISMYSECURETOKEN"
SESSION_NAME="test-session"
PHONE_NUMBER="557488120795"

echo "🔑 1️⃣ TESTANDO AUTENTICAÇÃO E SESSÕES"
echo "======================================"

echo "1.1 - Gerando token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/$SECRET_KEY/generate-token" \
  -H "Content-Type: application/json" \
  -d '{"session": "'$SESSION_NAME'"}')

TOKEN_ONLY=$(echo $TOKEN_RESPONSE | jq -r '.token')
echo "✅ Token gerado: $TOKEN_ONLY"

echo ""
echo "1.2 - Verificando status da sessão..."
STATUS_RESPONSE=$(curl -s -X GET "$BASE_URL/api/$SESSION_NAME/status-session" \
  -H "Authorization: Bearer $TOKEN_ONLY")

STATUS=$(echo $STATUS_RESPONSE | jq -r '.status')
echo "Status: $STATUS"
if [[ "$STATUS" == "CONNECTED" ]]; then
  echo "✅ Sessão conectada!"
else
  echo "❌ Sessão não conectada. Status: $STATUS"
  exit 1
fi

echo ""
echo "📱 2️⃣ TESTANDO MENSAGENS BÁSICAS"
echo "================================"

echo "2.1 - Enviando mensagem de texto..."
TEXT_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/send-message" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "phone": "'$PHONE_NUMBER'",
    "message": "🧪 Teste: Mensagem de texto básica"
  }')

TEXT_STATUS=$(echo $TEXT_RESPONSE | jq -r '.status')
if [[ "$TEXT_STATUS" == "success" ]]; then
  echo "✅ Mensagem de texto enviada!"
  MESSAGE_ID=$(echo $TEXT_RESPONSE | jq -r '.response[0].id')
  echo "ID da mensagem: $MESSAGE_ID"
else
  echo "❌ Falha ao enviar mensagem de texto"
  echo $TEXT_RESPONSE | jq .
fi

echo ""
echo "2.2 - Enviando imagem (testando com URL válida)..."
IMAGE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/send-image" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "phone": "'$PHONE_NUMBER'",
    "image": "https://httpbin.org/image/png",
    "caption": "🧪 Teste: Imagem via API"
  }')

IMAGE_STATUS=$(echo $IMAGE_RESPONSE | jq -r '.status')
if [[ "$IMAGE_STATUS" == "success" ]]; then
  echo "✅ Imagem enviada!"
else
  echo "❌ Falha ao enviar imagem"
  echo "Resposta: $IMAGE_RESPONSE"
fi

echo ""
echo "2.3 - Editando mensagem..."
if [[ -n "$MESSAGE_ID" && "$MESSAGE_ID" != "null" ]]; then
  sleep 2
  EDIT_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/$SESSION_NAME/edit-message" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_ONLY" \
    -d '{
      "messageId": "'$MESSAGE_ID'",
      "newText": "🧪 Mensagem editada com sucesso!"
    }')

  EDIT_STATUS=$(echo $EDIT_RESPONSE | jq -r '.status')
  if [[ "$EDIT_STATUS" == "success" ]]; then
    echo "✅ Mensagem editada!"
  else
    echo "❌ Falha ao editar mensagem"
    echo $EDIT_RESPONSE | jq .
  fi
else
  echo "⚠️ Pulando teste de edição (sem ID da mensagem)"
fi

echo ""
echo "🎯 3️⃣ TESTANDO INTERAÇÕES"
echo "========================="

echo "3.1 - Enviando botões..."
BUTTONS_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/send-buttons" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "phone": "'$PHONE_NUMBER'",
    "message": "🧪 Escolha uma opção:",
    "buttons": [
      {"buttonId": "1", "buttonText": "Opção 1"},
      {"buttonId": "2", "buttonText": "Opção 2"},
      {"buttonId": "3", "buttonText": "Opção 3"}
    ]
  }')

BUTTONS_STATUS=$(echo $BUTTONS_RESPONSE | jq -r '.status')
if [[ "$BUTTONS_STATUS" == "success" ]]; then
  echo "✅ Botões enviados!"
else
  echo "❌ Falha ao enviar botões"
  echo $BUTTONS_RESPONSE | jq .
fi

echo ""
echo "3.2 - Enviando lista..."
LIST_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/send-list" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "phone": "'$PHONE_NUMBER'",
    "message": "🧪 Escolha uma opção da lista:",
    "list": {
      "title": "Menu Principal",
      "description": "Selecione uma opção",
      "buttonText": "Ver Opções",
      "sections": [
        {
          "title": "Opções",
          "rows": [
            {"id": "1", "title": "Opção 1", "description": "Descrição da opção 1"},
            {"id": "2", "title": "Opção 2", "description": "Descrição da opção 2"}
          ]
        }
      ]
    }
  }')

LIST_STATUS=$(echo $LIST_RESPONSE | jq -r '.status')
if [[ "$LIST_STATUS" == "success" ]]; then
  echo "✅ Lista enviada!"
else
  echo "❌ Falha ao enviar lista"
  echo $LIST_RESPONSE | jq .
fi

echo ""
echo "👥 4️⃣ TESTANDO CONTATOS E CHATS"
echo "==============================="

echo "4.1 - Listando todos os contatos..."
CONTACTS_RESPONSE=$(curl -s -X GET "$BASE_URL/api/$SESSION_NAME/all-contacts" \
  -H "Authorization: Bearer $TOKEN_ONLY")

CONTACTS_STATUS=$(echo $CONTACTS_RESPONSE | jq -r '.status')
if [[ "$CONTACTS_STATUS" == "success" ]]; then
  CONTACTS_COUNT=$(echo $CONTACTS_RESPONSE | jq '.response | length')
  echo "✅ Contatos listados: $CONTACTS_COUNT contatos"
else
  echo "❌ Falha ao listar contatos"
  echo $CONTACTS_RESPONSE | jq .
fi

echo ""
echo "4.2 - Listando chats..."
CHATS_RESPONSE=$(curl -s -X GET "$BASE_URL/api/$SESSION_NAME/all-chats" \
  -H "Authorization: Bearer $TOKEN_ONLY")

CHATS_STATUS=$(echo $CHATS_RESPONSE | jq -r '.status')
if [[ "$CHATS_STATUS" == "success" ]]; then
  CHATS_COUNT=$(echo $CHATS_RESPONSE | jq '.response | length')
  echo "✅ Chats listados: $CHATS_COUNT chats"
else
  echo "❌ Falha ao listar chats"
  echo $CHATS_RESPONSE | jq .
fi

echo ""
echo "4.3 - Informações do contato..."
CONTACT_INFO_RESPONSE=$(curl -s -X GET "$BASE_URL/api/$SESSION_NAME/contact/$PHONE_NUMBER" \
  -H "Authorization: Bearer $TOKEN_ONLY")

CONTACT_INFO_STATUS=$(echo $CONTACT_INFO_RESPONSE | jq -r '.status')
if [[ "$CONTACT_INFO_STATUS" == "success" ]]; then
  echo "✅ Informações do contato obtidas!"
else
  echo "❌ Falha ao obter informações do contato"
  echo $CONTACT_INFO_RESPONSE | jq .
fi

echo ""
echo "🏢 5️⃣ TESTANDO GRUPOS"
echo "====================="

echo "5.1 - Criando grupo..."
GROUP_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/create-group" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "name": "🧪 Grupo Teste API",
    "participants": ["'$PHONE_NUMBER'"]
  }')

GROUP_STATUS=$(echo $GROUP_RESPONSE | jq -r '.status')
if [[ "$GROUP_STATUS" == "success" ]]; then
  echo "✅ Grupo criado!"
  GROUP_ID=$(echo $GROUP_RESPONSE | jq -r '.response.id')
  echo "ID do grupo: $GROUP_ID"
else
  echo "❌ Falha ao criar grupo"
  echo $GROUP_RESPONSE | jq .
fi

echo ""
echo "🔗 6️⃣ TESTANDO WEBHOOKS"
echo "======================="

echo "6.1 - Verificando configuração de webhook..."
WEBHOOK_RESPONSE=$(curl -s -X GET "$BASE_URL/api/$SESSION_NAME/webhook" \
  -H "Authorization: Bearer $TOKEN_ONLY")

WEBHOOK_STATUS=$(echo $WEBHOOK_RESPONSE | jq -r '.status')
if [[ "$WEBHOOK_STATUS" == "success" ]]; then
  echo "✅ Configuração de webhook obtida!"
  WEBHOOK_URL=$(echo $WEBHOOK_RESPONSE | jq -r '.response.url')
  echo "URL do webhook: $WEBHOOK_URL"
else
  echo "❌ Falha ao obter configuração de webhook"
  echo $WEBHOOK_RESPONSE | jq .
fi

echo ""
echo "📊 RESUMO DOS TESTES"
echo "==================="
echo ""
echo "✅ Funcionalidades testadas:"
echo "   - Autenticação e sessões"
echo "   - Mensagens básicas (texto, imagem)"
echo "   - Edição de mensagens"
echo "   - Interações (botões, listas)"
echo "   - Contatos e chats"
echo "   - Grupos"
echo "   - Webhooks"
echo ""
echo "🎯 Sistema pronto para integração básica!"
echo ""
echo "📋 Próximos passos sugeridos:"
echo "   1. Configurar webhook para receber mensagens"
echo "   2. Implementar processamento de eventos"
echo "   3. Testar recebimento de mensagens"
echo "   4. Integrar com seu sistema SIGVSA"
echo ""
echo "🔗 Swagger UI: http://localhost:3000/api-docs"
echo "🔑 Token para testes: $TOKEN_ONLY"
