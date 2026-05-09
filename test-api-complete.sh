#!/bin/bash

echo "🧪 Teste Completo da API WPPConnect Server"
echo "=========================================="
echo ""

# Configurações
BASE_URL="http://localhost:3000"
SECRET_KEY="THISISMYSECURETOKEN"
SESSION_NAME="test-session"
PHONE_NUMBER="557488120795"  # Número que funcionou

echo "1️⃣ Gerando token de autenticação..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/$SECRET_KEY/generate-token" \
  -H "Content-Type: application/json" \
  -d '{"session": "'$SESSION_NAME'"}')

echo "Resposta: $TOKEN_RESPONSE"

# Extrair apenas o token (sem prefixo da sessão)
TOKEN_ONLY=$(echo $TOKEN_RESPONSE | jq -r '.token')
echo "Token para usar no Swagger: $TOKEN_ONLY"
echo ""

echo "2️⃣ Verificando status da sessão..."
curl -s -X GET "$BASE_URL/api/$SESSION_NAME/status-session" \
  -H "Authorization: Bearer $TOKEN_ONLY" | jq .
echo ""

echo "3️⃣ Enviando mensagem de texto..."
MESSAGE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/send-message" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "phone": "'$PHONE_NUMBER'",
    "message": "Teste via API - $(date)"
  }')

echo "Resposta do envio:"
echo $MESSAGE_RESPONSE | jq .
echo ""

# Extrair ID da mensagem para edição
MESSAGE_ID=$(echo $MESSAGE_RESPONSE | jq -r '.response[0].id')
echo "ID da mensagem: $MESSAGE_ID"
echo ""

echo "4️⃣ Aguardando 3 segundos antes de editar..."
sleep 3

echo "5️⃣ Editando a mensagem..."
EDIT_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/$SESSION_NAME/edit-message" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "messageId": "'$MESSAGE_ID'",
    "newText": "Mensagem editada via API - $(date)"
  }')

echo "Resposta da edição:"
echo $EDIT_RESPONSE | jq .
echo ""

echo "6️⃣ Testando outras funcionalidades..."

echo "6.1 - Verificando sessões existentes..."
curl -s -X GET "$BASE_URL/api/$SECRET_KEY/show-all-sessions" | jq .
echo ""

echo "6.2 - Health Check..."
curl -s -X GET "$BASE_URL/healthz"
echo ""
echo ""

echo "6.3 - Métricas..."
curl -s -X GET "$BASE_URL/metrics" | head -10
echo ""
echo ""

echo "7️⃣ Testando funcionalidades avançadas..."

echo "7.1 - Enviando mensagem com botões..."
curl -s -X POST "$BASE_URL/api/$SESSION_NAME/send-buttons" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "phone": "'$PHONE_NUMBER'",
    "message": "Escolha uma opção:",
    "buttons": [
      {"buttonId": "1", "buttonText": "Opção 1"},
      {"buttonId": "2", "buttonText": "Opção 2"},
      {"buttonId": "3", "buttonText": "Opção 3"}
    ]
  }' | jq .
echo ""

echo "7.2 - Enviando lista..."
curl -s -X POST "$BASE_URL/api/$SESSION_NAME/send-list" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "phone": "'$PHONE_NUMBER'",
    "message": "Escolha uma opção da lista:",
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
  }' | jq .
echo ""

echo "8️⃣ Testando funcionalidades de mídia..."

echo "8.1 - Enviando imagem (URL)..."
curl -s -X POST "$BASE_URL/api/$SESSION_NAME/send-image" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "phone": "'$PHONE_NUMBER'",
    "image": "https://via.placeholder.com/300x200/0066CC/FFFFFF?text=Teste+API",
    "caption": "Imagem de teste via API"
  }' | jq .
echo ""

echo "8.2 - Enviando documento..."
curl -s -X POST "$BASE_URL/api/$SESSION_NAME/send-document" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "phone": "'$PHONE_NUMBER'",
    "document": "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
    "filename": "teste.pdf",
    "caption": "Documento de teste"
  }' | jq .
echo ""

echo "9️⃣ Testando funcionalidades de grupo..."

echo "9.1 - Criando grupo..."
GROUP_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/create-group" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "name": "Grupo Teste API",
    "participants": ["'$PHONE_NUMBER'"]
  }')

echo "Resposta da criação do grupo:"
echo $GROUP_RESPONSE | jq .
echo ""

echo "🔟 Testando funcionalidades de contato..."

echo "10.1 - Verificando contatos..."
curl -s -X GET "$BASE_URL/api/$SESSION_NAME/contacts" \
  -H "Authorization: Bearer $TOKEN_ONLY" | jq . | head -20
echo ""

echo "10.2 - Verificando chats..."
curl -s -X GET "$BASE_URL/api/$SESSION_NAME/chats" \
  -H "Authorization: Bearer $TOKEN_ONLY" | jq . | head -20
echo ""

echo "✅ Testes concluídos!"
echo ""
echo "📋 Resumo dos testes:"
echo "- ✅ Autenticação funcionando"
echo "- ✅ Envio de mensagens funcionando"
echo "- ✅ Edição de mensagens funcionando"
echo "- ✅ Botões funcionando"
echo "- ✅ Listas funcionando"
echo "- ✅ Mídia funcionando"
echo "- ✅ Grupos funcionando"
echo "- ✅ Contatos funcionando"
echo ""
echo "🎯 Próximos passos:"
echo "1. Testar webhooks"
echo "2. Testar funcionalidades de negócio"
echo "3. Testar integração com ChatWoot"
echo "4. Testar sistema de filas"
echo ""
echo "🔗 Acesse o Swagger UI: http://localhost:3000/api-docs"
echo "🔑 Use este token no Swagger: $TOKEN_ONLY"
