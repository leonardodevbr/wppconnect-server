#!/bin/bash

echo "🧪 TESTE COMPLETO DAS FUNCIONALIDADES ESSENCIAIS"
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

echo "Status: $(echo $STATUS_RESPONSE | jq -r '.status')"
if [[ $(echo $STATUS_RESPONSE | jq -r '.status') == "CONNECTED" ]]; then
  echo "✅ Sessão conectada!"
else
  echo "❌ Sessão não conectada. Status: $(echo $STATUS_RESPONSE | jq -r '.status')"
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

if [[ $(echo $TEXT_RESPONSE | jq -r '.status') == "success" ]]; then
  echo "✅ Mensagem de texto enviada!"
  MESSAGE_ID=$(echo $TEXT_RESPONSE | jq -r '.response[0].id')
  echo "ID da mensagem: $MESSAGE_ID"
else
  echo "❌ Falha ao enviar mensagem de texto"
  echo $TEXT_RESPONSE | jq .
fi

echo ""
echo "2.2 - Enviando imagem..."
IMAGE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/send-image" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "phone": "'$PHONE_NUMBER'",
    "image": "https://via.placeholder.com/300x200/0066CC/FFFFFF?text=Teste+Imagem",
    "caption": "🧪 Teste: Imagem via API"
  }')

if [[ $(echo $IMAGE_RESPONSE | jq -r '.status') == "success" ]]; then
  echo "✅ Imagem enviada!"
else
  echo "❌ Falha ao enviar imagem"
  echo $IMAGE_RESPONSE | jq .
fi

echo ""
echo "2.3 - Enviando documento..."
DOC_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/send-document" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "phone": "'$PHONE_NUMBER'",
    "document": "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "filename": "teste.pdf",
    "caption": "🧪 Teste: Documento via API"
  }')

if [[ $(echo $DOC_RESPONSE | jq -r '.status') == "success" ]]; then
  echo "✅ Documento enviado!"
else
  echo "❌ Falha ao enviar documento"
  echo $DOC_RESPONSE | jq .
fi

echo ""
echo "2.4 - Editando mensagem..."
if [[ -n "$MESSAGE_ID" ]]; then
  sleep 2
  EDIT_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/$SESSION_NAME/edit-message" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_ONLY" \
    -d '{
      "messageId": "'$MESSAGE_ID'",
      "newText": "🧪 Mensagem editada com sucesso!"
    }')

  if [[ $(echo $EDIT_RESPONSE | jq -r '.status') == "success" ]]; then
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

if [[ $(echo $BUTTONS_RESPONSE | jq -r '.status') == "success" ]]; then
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

if [[ $(echo $LIST_RESPONSE | jq -r '.status') == "success" ]]; then
  echo "✅ Lista enviada!"
else
  echo "❌ Falha ao enviar lista"
  echo $LIST_RESPONSE | jq .
fi

echo ""
echo "👥 4️⃣ TESTANDO CONTATOS E CHATS"
echo "==============================="

echo "4.1 - Listando contatos..."
CONTACTS_RESPONSE=$(curl -s -X GET "$BASE_URL/api/$SESSION_NAME/contacts" \
  -H "Authorization: Bearer $TOKEN_ONLY")

CONTACTS_COUNT=$(echo $CONTACTS_RESPONSE | jq '.response | length')
if [[ $CONTACTS_COUNT -gt 0 ]]; then
  echo "✅ Contatos listados: $CONTACTS_COUNT contatos"
else
  echo "❌ Falha ao listar contatos"
  echo $CONTACTS_RESPONSE | jq .
fi

echo ""
echo "4.2 - Listando chats..."
CHATS_RESPONSE=$(curl -s -X GET "$BASE_URL/api/$SESSION_NAME/chats" \
  -H "Authorization: Bearer $TOKEN_ONLY")

CHATS_COUNT=$(echo $CHATS_RESPONSE | jq '.response | length')
if [[ $CHATS_COUNT -gt 0 ]]; then
  echo "✅ Chats listados: $CHATS_COUNT chats"
else
  echo "❌ Falha ao listar chats"
  echo $CHATS_RESPONSE | jq .
fi

echo ""
echo "4.3 - Informações do contato..."
CONTACT_INFO_RESPONSE=$(curl -s -X GET "$BASE_URL/api/$SESSION_NAME/contact/$PHONE_NUMBER" \
  -H "Authorization: Bearer $TOKEN_ONLY")

if [[ $(echo $CONTACT_INFO_RESPONSE | jq -r '.status') == "success" ]]; then
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

if [[ $(echo $GROUP_RESPONSE | jq -r '.status') == "success" ]]; then
  echo "✅ Grupo criado!"
  GROUP_ID=$(echo $GROUP_RESPONSE | jq -r '.response.id')
  echo "ID do grupo: $GROUP_ID"
else
  echo "❌ Falha ao criar grupo"
  echo $GROUP_RESPONSE | jq .
fi

echo ""
echo "5.2 - Informações do grupo..."
if [[ -n "$GROUP_ID" ]]; then
  GROUP_INFO_RESPONSE=$(curl -s -X GET "$BASE_URL/api/$SESSION_NAME/group-info/$GROUP_ID" \
    -H "Authorization: Bearer $TOKEN_ONLY")

  if [[ $(echo $GROUP_INFO_RESPONSE | jq -r '.status') == "success" ]]; then
    echo "✅ Informações do grupo obtidas!"
  else
    echo "❌ Falha ao obter informações do grupo"
    echo $GROUP_INFO_RESPONSE | jq .
  fi
else
  echo "⚠️ Pulando teste de informações do grupo (sem ID do grupo)"
fi

echo ""
echo "🔗 6️⃣ TESTANDO WEBHOOKS"
echo "======================="

echo "6.1 - Verificando configuração de webhook..."
WEBHOOK_RESPONSE=$(curl -s -X GET "$BASE_URL/api/$SESSION_NAME/webhook" \
  -H "Authorization: Bearer $TOKEN_ONLY")

if [[ $(echo $WEBHOOK_RESPONSE | jq -r '.status') == "success" ]]; then
  echo "✅ Configuração de webhook obtida!"
  echo "URL do webhook: $(echo $WEBHOOK_RESPONSE | jq -r '.response.url')"
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
echo "   - Mensagens básicas (texto, imagem, documento)"
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
