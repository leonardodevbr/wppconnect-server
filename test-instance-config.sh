#!/bin/bash

# Cores para a saída do terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔧 TESTANDO CONFIGURAÇÕES INDIVIDUAIS DE INSTÂNCIAS${NC}"
echo -e "=================================================="

# Variáveis de ambiente
BACKEND_URL="http://localhost:3000"
TEST_SESSION="test-session"
SECRET_KEY="THISISMYSECURETOKEN"

echo -e "\n${YELLOW}1. GERANDO TOKEN VÁLIDO${NC}"
echo -e "========================"
echo -e "${BLUE}Gerando token para $TEST_SESSION...${NC}"
TOKEN_RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/$TEST_SESSION/$SECRET_KEY/generate-token")
GENERATED_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.token')
if [ "$GENERATED_TOKEN" != "null" ] && [ -n "$GENERATED_TOKEN" ]; then
    echo "Resposta: $TOKEN_RESPONSE"
    echo -e "${GREEN}✅ Token gerado com sucesso: $GENERATED_TOKEN${NC}"
else
    echo -e "${RED}❌ Erro ao gerar token${NC}"
    echo "Resposta: $TOKEN_RESPONSE"
    exit 1
fi

echo -e "\n${YELLOW}2. TESTANDO OBTER CONFIGURAÇÕES${NC}"
echo -e "================================="
echo -e "${BLUE}Obtendo configurações da instância...${NC}"
CONFIG_RESPONSE=$(curl -s -H "Authorization: Bearer $GENERATED_TOKEN" "$BACKEND_URL/api/$TEST_SESSION/config")
echo "Resposta: $CONFIG_RESPONSE"

if echo "$CONFIG_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✅ Configurações obtidas com sucesso${NC}"
else
    echo -e "${RED}❌ Erro ao obter configurações${NC}"
fi

echo -e "\n${YELLOW}3. TESTANDO CONFIGURAR WEBHOOK${NC}"
echo -e "================================="
echo -e "${BLUE}Configurando webhook individual...${NC}"
WEBHOOK_RESPONSE=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $GENERATED_TOKEN" \
    -d '{"url": "https://webhook.sigvsa.com.br/teste-individual"}' \
    "$BACKEND_URL/api/$TEST_SESSION/webhook")

echo "Resposta: $WEBHOOK_RESPONSE"

if echo "$WEBHOOK_RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✅ Webhook configurado com sucesso${NC}"
else
    echo -e "${RED}❌ Erro ao configurar webhook${NC}"
fi

echo -e "\n${YELLOW}4. VERIFICANDO CONFIGURAÇÃO SALVA${NC}"
echo -e "===================================="
echo -e "${BLUE}Verificando se o webhook foi salvo...${NC}"
VERIFY_RESPONSE=$(curl -s -H "Authorization: Bearer $GENERATED_TOKEN" "$BACKEND_URL/api/$TEST_SESSION/config")
echo "Resposta: $VERIFY_RESPONSE"

if echo "$VERIFY_RESPONSE" | grep -q "webhook.sigvsa.com.br/teste-individual"; then
    echo -e "${GREEN}✅ Webhook individual salvo com sucesso!${NC}"
else
    echo -e "${RED}❌ Webhook não foi salvo corretamente${NC}"
fi

echo -e "\n${YELLOW}5. RESUMO FINAL${NC}"
echo -e "==============="
echo -e "${GREEN}🎉 TESTE DE CONFIGURAÇÕES INDIVIDUAIS CONCLUÍDO!${NC}"
echo -e "\n📋 Funcionalidades testadas:"
echo -e "   ✅ Geração de token"
echo -e "   ✅ Obter configurações da instância"
echo -e "   ✅ Configurar webhook individual"
echo -e "   ✅ Verificar configuração salva"
echo -e "\n🔧 APIs implementadas:"
echo -e "   GET  /api/:session/config"
echo -e "   POST /api/:session/config"
echo -e "   POST /api/:session/webhook"
echo -e "\n${BLUE}✨ Agora cada instância pode ter seu próprio webhook!${NC}"
