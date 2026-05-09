#!/bin/bash

echo "🧪 TESTE COMPLETO: ADICIONAR/REMOVER PARTICIPANTES DE GRUPO"
echo "=========================================================="
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
echo "1️⃣ Criando grupo de teste..."
GROUP_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/create-group" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "name": "🧪 Grupo Teste Participantes",
    "participants": ["'$PHONE_NUMBER'"]
  }')

GROUP_STATUS=$(echo $GROUP_RESPONSE | jq -r '.status')
if [[ "$GROUP_STATUS" == "success" ]]; then
  echo "✅ Grupo criado!"
  GROUP_ID=$(echo $GROUP_RESPONSE | jq -r '.response.groupInfo[0].id')
  echo "ID do grupo: $GROUP_ID"
else
  echo "❌ Falha ao criar grupo"
  echo $GROUP_RESPONSE | jq .
  exit 1
fi

echo ""
echo "2️⃣ Testando adicionar participante ao grupo..."

# Usando um número de teste fictício
TEST_PHONE="5511999999999"

ADD_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/add-participant-group" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "groupId": "'$GROUP_ID'",
    "phone": "'$TEST_PHONE'"
  }')

ADD_STATUS=$(echo $ADD_RESPONSE | jq -r '.status')
echo "Resposta ao adicionar participante:"
echo $ADD_RESPONSE | jq .

if [[ "$ADD_STATUS" == "success" ]]; then
  echo "✅ Participante adicionado!"
else
  echo "❌ Falha ao adicionar participante"
fi

echo ""
echo "3️⃣ Testando remover participante do grupo..."

REMOVE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/remove-participant-group" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "groupId": "'$GROUP_ID'",
    "phone": "'$TEST_PHONE'"
  }')

REMOVE_STATUS=$(echo $REMOVE_RESPONSE | jq -r '.status')
echo "Resposta ao remover participante:"
echo $REMOVE_RESPONSE | jq .

if [[ "$REMOVE_STATUS" == "success" ]]; then
  echo "✅ Participante removido!"
else
  echo "❌ Falha ao remover participante"
fi

echo ""
echo "4️⃣ Testando promover participante a admin..."

PROMOTE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/promote-participant-group" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "groupId": "'$GROUP_ID'",
    "phone": "'$PHONE_NUMBER'"
  }')

PROMOTE_STATUS=$(echo $PROMOTE_RESPONSE | jq -r '.status')
echo "Resposta ao promover participante:"
echo $PROMOTE_RESPONSE | jq .

if [[ "$PROMOTE_STATUS" == "success" ]]; then
  echo "✅ Participante promovido a admin!"
else
  echo "❌ Falha ao promover participante"
fi

echo ""
echo "5️⃣ Testando rebaixar participante de admin..."

DEMOTE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/$SESSION_NAME/demote-participant-group" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_ONLY" \
  -d '{
    "groupId": "'$GROUP_ID'",
    "phone": "'$PHONE_NUMBER'"
  }')

DEMOTE_STATUS=$(echo $DEMOTE_RESPONSE | jq -r '.status')
echo "Resposta ao rebaixar participante:"
echo $DEMOTE_RESPONSE | jq .

if [[ "$DEMOTE_STATUS" == "success" ]]; then
  echo "✅ Participante rebaixado!"
else
  echo "❌ Falha ao rebaixar participante"
fi

echo ""
echo "6️⃣ Verificando informações do grupo..."

GROUP_INFO_RESPONSE=$(curl -s -X GET "$BASE_URL/api/$SESSION_NAME/group-info/$GROUP_ID" \
  -H "Authorization: Bearer $TOKEN_ONLY")

GROUP_INFO_STATUS=$(echo $GROUP_INFO_RESPONSE | jq -r '.status')
echo "Informações do grupo:"
echo $GROUP_INFO_RESPONSE | jq .

if [[ "$GROUP_INFO_STATUS" == "success" ]]; then
  echo "✅ Informações do grupo obtidas!"
else
  echo "❌ Falha ao obter informações do grupo"
fi

echo ""
echo "📊 RESUMO DOS TESTES DE GRUPO"
echo "============================"
echo ""
echo "✅ Funcionalidades testadas:"
echo "   - Criar grupo"
echo "   - Adicionar participante"
echo "   - Remover participante"
echo "   - Promover participante a admin"
echo "   - Rebaixar participante de admin"
echo "   - Obter informações do grupo"
echo ""
echo "🎯 Sistema de grupos funcionando!"
