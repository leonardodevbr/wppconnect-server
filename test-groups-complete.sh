#!/bin/bash

echo "🧪 TESTE COMPLETO: GRUPOS E PARTICIPANTES"
echo "========================================="
echo ""

# Configurações
BASE_URL="http://localhost:3000"
SECRET_KEY="THISISMYSECURETOKEN"
SESSION_NAME="test-session"
PHONE_NUMBER="557488120795"

echo "🔑 Gerando token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/$SECRET_KEY/generate-token" \
  -H "Content-Type: application/json" \
  -d '{"session": "'$SESSION_NAME'"}')

TOKEN_ONLY=$(echo $TOKEN_RESPONSE | jq -r '.token')
echo "✅ Token gerado: $TOKEN_ONLY"

echo ""
echo "1️⃣ Aguardando rate limit (60 segundos)..."
sleep 60

echo "2️⃣ Criando grupo de teste..."
GROUP_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/create-group" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "name": "🧪 Grupo Teste Participantes",
    "participants": ["'$PHONE_NUMBER'"]
  }')

echo "Resposta da criação:"
echo $GROUP_RESPONSE | jq .

GROUP_STATUS=$(echo $GROUP_RESPONSE | jq -r '.status')
if [[ "$GROUP_STATUS" == "success" ]]; then
  echo "✅ Grupo criado!"
  GROUP_ID=$(echo $GROUP_RESPONSE | jq -r '.response.groupInfo[0].id')
  echo "ID do grupo: $GROUP_ID"
  
  echo ""
  echo "3️⃣ Testando adicionar participante..."
  # Usando um número de teste
  TEST_PHONE="5511999999999"
  
  ADD_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/add-participant-group" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_ONLY" \
    -d '{
      "groupId": "'$GROUP_ID'",
      "phone": "'$TEST_PHONE'"
    }')
  
  echo "Resposta ao adicionar:"
  echo $ADD_RESPONSE | jq .
  
  echo ""
  echo "4️⃣ Testando remover participante..."
  REMOVE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/remove-participant-group" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_ONLY" \
    -d '{
      "groupId": "'$GROUP_ID'",
      "phone": "'$TEST_PHONE'"
    }')
  
  echo "Resposta ao remover:"
  echo $REMOVE_RESPONSE | jq .
  
  echo ""
  echo "5️⃣ Testando promover participante a admin..."
  PROMOTE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/promote-participant-group" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_ONLY" \
    -d '{
      "groupId": "'$GROUP_ID'",
      "phone": "'$PHONE_NUMBER'"
    }')
  
  echo "Resposta ao promover:"
  echo $PROMOTE_RESPONSE | jq .
  
  echo ""
  echo "6️⃣ Testando rebaixar participante..."
  DEMOTE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/demote-participant-group" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_ONLY" \
    -d '{
      "groupId": "'$GROUP_ID'",
      "phone": "'$PHONE_NUMBER'"
    }')
  
  echo "Resposta ao rebaixar:"
  echo $DEMOTE_RESPONSE | jq .
  
  echo ""
  echo "7️⃣ Verificando informações do grupo..."
  GROUP_INFO_RESPONSE=$(curl -s -X GET "$BASE_URL/api/$SESSION_NAME/group-info/$GROUP_ID" \
    -H "Authorization: Bearer $TOKEN_ONLY")
  
  echo "Informações do grupo:"
  echo $GROUP_INFO_RESPONSE | jq .
  
  echo ""
  echo "8️⃣ Removendo grupo de teste..."
  DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/$SESSION_NAME/group/$GROUP_ID" \
    -H "Authorization: Bearer $TOKEN_ONLY")
  
  echo "Resposta ao deletar grupo:"
  echo $DELETE_RESPONSE | jq .
  
else
  echo "❌ Falha ao criar grupo"
  echo "Status: $GROUP_STATUS"
fi

echo ""
echo "📊 RESUMO DOS TESTES"
echo "==================="
echo "✅ Funcionalidades testadas:"
echo "   - Criar grupo"
echo "   - Adicionar participante"
echo "   - Remover participante"
echo "   - Promover participante a admin"
echo "   - Rebaixar participante"
echo "   - Obter informações do grupo"
echo "   - Deletar grupo"
echo ""
echo "🎯 Teste completo de grupos realizado!"
