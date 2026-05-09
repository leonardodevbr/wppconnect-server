#!/bin/bash

echo "🧪 Testando APIs de Múltiplas Instâncias (Modo Simples)..."
echo ""

# Configurações
BASE_URL="http://localhost:3000"

echo "1️⃣ Testando health check..."
curl -s -w "Status: %{http_code}\n" "$BASE_URL/healthz"
echo ""

echo "2️⃣ Testando endpoint de listar instâncias..."
curl -s -w "Status: %{http_code}\n" "$BASE_URL/api/instances"
echo ""

echo "3️⃣ Testando criação de instância..."
curl -s -w "Status: %{http_code}\n" -X POST "$BASE_URL/api/create-instance" \
  -H "Content-Type: application/json" \
  -d '{"name": "test-instance", "webhook": "https://webhook.site/test"}'
echo ""

echo "4️⃣ Testando Swagger UI..."
curl -s -w "Status: %{http_code}\n" "$BASE_URL/api-docs"
echo ""

echo "✅ Testes básicos concluídos!"
echo ""
echo "Se todos os status forem 200, o servidor está funcionando."
echo "Se algum status for diferente, há um problema no servidor."
