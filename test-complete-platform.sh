#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🧪 TESTE COMPLETO DA PLATAFORMA SIGVSA WhatsApp API"
echo "=================================================="
echo ""

# Configurações
BASE_URL="http://localhost:3000"
EMAIL="admin@sigvsa.com"
PASSWORD="admin123"

# Função para testar endpoint
test_endpoint() {
  local method=$1
  local url=$2
  local description=$3
  local data=$4
  
  if [ -z "$data" ]; then
    response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X $method "$url")
  else
    response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X $method "$url" \
      -H "Content-Type: application/json" \
      -d "$data")
  fi
  
  http_status=$(echo "$response" | grep "HTTP_STATUS" | cut -d: -f2)
  body=$(echo "$response" | grep -v "HTTP_STATUS")
  
  if [[ "$http_status" == "200" ]] || [[ "$http_status" == "201" ]]; then
    echo -e "${GREEN}✅ $description${NC} (Status: $http_status)"
    return 0
  else
    echo -e "${RED}❌ $description${NC} (Status: $http_status)"
    echo "Resposta: $body"
    return 1
  fi
}

# Contador de testes
passed=0
failed=0

# 1. TESTE DE HEALTH CHECK
echo "1️⃣ Testando Health Check..."
if test_endpoint "GET" "$BASE_URL/healthz" "Health Check"; then
  ((passed++))
else
  ((failed++))
fi
echo ""

# 2. TESTE DE LOGIN
echo "2️⃣ Testando Login..."
login_response=$(curl -s -X POST "$BASE_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

echo "$login_response" | jq . > /dev/null 2>&1
if [ $? -eq 0 ] && echo "$login_response" | jq -e '.status == "success"' > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Login funcionando${NC}"
  ((passed++))
  
  # Extrair token se disponível
  TOKEN=$(echo "$login_response" | jq -r '.data.token' 2>/dev/null)
  if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
    echo "   Token gerado: ✓"
  fi
else
  echo -e "${RED}❌ Login falhou${NC}"
  echo "Resposta: $login_response"
  ((failed++))
fi
echo ""

# 3. TESTE DE LISTAR INSTÂNCIAS
echo "3️⃣ Testando Listar Instâncias..."
if test_endpoint "GET" "$BASE_URL/api/instances" "Listar Instâncias"; then
  ((passed++))
  instances=$(curl -s "$BASE_URL/api/instances" | jq '.data | length')
  echo "   Instâncias encontradas: $instances"
else
  ((failed++))
fi
echo ""

# 4. TESTE DE GERAR TOKEN
echo "4️⃣ Testando Gerar Token..."
TOKEN_RESPONSE=$(curl -s -X POST "$BASE_URL/api/test-session/THISISMYSECURETOKEN/generate-token")
echo "$TOKEN_RESPONSE" | jq . > /dev/null 2>&1
if [ $? -eq 0 ] && echo "$TOKEN_RESPONSE" | jq -e '.status == "success"' > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Token gerado${NC}"
  ((passed++))
  
  # Extrair token completo
  FULL_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.full' 2>/dev/null)
  if [ -n "$FULL_TOKEN" ] && [ "$FULL_TOKEN" != "null" ]; then
    echo "   Token completo: $FULL_TOKEN"
  fi
else
  echo -e "${RED}❌ Falha ao gerar token${NC}"
  ((failed++))
fi
echo ""

# 5. TESTE DE CONFIGURAR WEBHOOK
echo "5️⃣ Testando Configurar Webhook..."
webhook_response=$(curl -s -X POST "$BASE_URL/api/test-session/webhook" \
  -H "Content-Type: application/json" \
  -d '{"url": "https://webhook.sigvsa.com.br/test"}')

echo "$webhook_response" | jq . > /dev/null 2>&1
if [ $? -eq 0 ] && echo "$webhook_response" | jq -e '.status == "success"' > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Webhook configurado${NC}"
  ((passed++))
else
  echo -e "${RED}❌ Falha ao configurar webhook${NC}"
  ((failed++))
fi
echo ""

# 6. TESTE DE BUSCAR CONFIGURAÇÕES
echo "6️⃣ Testando Buscar Configurações..."
if test_endpoint "GET" "$BASE_URL/api/test-session/config" "Buscar Configurações"; then
  ((passed++))
  config_webhook=$(curl -s "$BASE_URL/api/test-session/config" | jq -r '.data.webhook')
  echo "   Webhook atual: $config_webhook"
else
  ((failed++))
fi
echo ""

# 7. TESTE DE INICIAR INSTÂNCIA
echo "7️⃣ Testando Iniciar Instância..."
if test_endpoint "POST" "$BASE_URL/api/test-session/start" "" "Iniciar Instância"; then
  ((passed++))
  qrcode=$(curl -s -X POST "$BASE_URL/api/test-session/start" | jq -r '.data.qrcode' | grep -o "^data:" | wc -c)
  if [ $qrcode -gt 0 ]; then
    echo "   QR Code gerado: ✓"
  fi
else
  ((failed++))
fi
echo ""

# 8. TESTE DE QR CODE
echo "8️⃣ Testando QR Code..."
qrcode_response=$(curl -s "$BASE_URL/api/test-session/qrcode")
echo "$qrcode_response" | jq . > /dev/null 2>&1
if [ $? -eq 0 ] && echo "$qrcode_response" | jq -e '.status == "success"' > /dev/null 2>&1; then
  echo -e "${GREEN}✅ QR Code obtido${NC}"
  ((passed++))
else
  echo -e "${RED}❌ Falha ao obter QR Code${NC}"
  ((failed++))
fi
echo ""

# 9. TESTE DE PARAR INSTÂNCIA
echo "9️⃣ Testando Parar Instância..."
if test_endpoint "POST" "$BASE_URL/api/test-session/stop" "" "Parar Instância"; then
  ((passed++))
else
  ((failed++))
fi
echo ""

# 10. TESTE DE SESSÕES ATIVAS
echo "🔟 Testando Sessões Ativas..."
sessions_response=$(curl -s "$BASE_URL/api/THISISMYSECURETOKEN/show-all-sessions")
echo "$sessions_response" | jq . > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✅ Sessões listadas${NC}"
  ((passed++))
  session_count=$(echo "$sessions_response" | jq '.response | length')
  echo "   Sessões encontradas: $session_count"
else
  echo -e "${RED}❌ Falha ao listar sessões${NC}"
  ((failed++))
fi
echo ""

# RESUMO
echo "=================================================="
echo "📊 RESUMO DOS TESTES"
echo "=================================================="
echo -e "${GREEN}✅ Testes Passados: $passed${NC}"
echo -e "${RED}❌ Testes Falhados: $failed${NC}"
echo "Total: $((passed + failed))"
echo ""

if [ $failed -eq 0 ]; then
  echo -e "${GREEN}🎉 TODOS OS TESTES PASSARAM!${NC}"
  exit 0
else
  echo -e "${RED}⚠️ ALGUNS TESTES FALHARAM${NC}"
  exit 1
fi