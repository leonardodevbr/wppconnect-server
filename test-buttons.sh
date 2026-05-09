#!/bin/bash

echo "🔥 TESTANDO BOTÕES INTERATIVOS! 🔥"
echo "=================================="

AUTH_TOKEN="\$2b\$10\$sRmYIsNESWyUvy6qi2TpSu..EbjsANVvsh7cgZRXAzHQtvxCGmXRy"

echo ""
echo "🔘 Testando botões simples..."
RESPONSE=$(curl -s -X POST "http://localhost:3000/api/test-session/send-buttons" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": ["557488120795@c.us"],
    "message": "🎯 Escolha uma opção abaixo:",
    "title": "Menu Principal",
    "footer": "Selecione uma das opções",
    "dynamic_reply": true,
    "buttons": [
      {
        "id": "btn1",
        "text": "📞 Falar com Atendente"
      },
      {
        "id": "btn2", 
        "text": "🛒 Ver Produtos"
      },
      {
        "id": "btn3",
        "text": "📋 Pedir Orçamento"
      }
    ]
  }')

echo "Resposta dos botões:"
echo $RESPONSE | jq .

STATUS_RESPONSE=$(echo $RESPONSE | jq -r '.status // "error"')
echo ""
echo "Status: $STATUS_RESPONSE"

if [ "$STATUS_RESPONSE" = "success" ]; then
  echo "🎉 SUCESSO! Botões enviados!"
else
  echo "❌ Erro ao enviar botões"
  ERROR_MESSAGE=$(echo $RESPONSE | jq -r '.message // "Erro desconhecido"')
  echo "Mensagem de erro: $ERROR_MESSAGE"
fi

echo ""
echo "⏳ Aguardando 3 segundos..."
sleep 3

echo ""
echo "📋 Testando lista de opções..."
RESPONSE_LIST=$(curl -s -X POST "http://localhost:3000/api/test-session/send-list-message" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": ["557488120795@c.us"],
    "isGroup": false,
    "description": "Escolha uma categoria de produtos:",
    "buttonText": "Ver Produtos",
    "sections": [
      {
        "title": "🏠 Casa e Decoração",
        "rows": [
          {
            "rowId": "casa_1",
            "title": "Sofás",
            "description": "Sofás confortáveis para sua casa"
          },
          {
            "rowId": "casa_2", 
            "title": "Mesas",
            "description": "Mesas para sala e jantar"
          }
        ]
      },
      {
        "title": "📱 Eletrônicos",
        "rows": [
          {
            "rowId": "eletro_1",
            "title": "Smartphones",
            "description": "Celulares e acessórios"
          },
          {
            "rowId": "eletro_2",
            "title": "Notebooks", 
            "description": "Computadores portáteis"
          }
        ]
      }
    ]
  }')

echo "Resposta da lista:"
echo $RESPONSE_LIST | jq .

STATUS_LIST=$(echo $RESPONSE_LIST | jq -r '.status // "error"')
echo ""
echo "Status da lista: $STATUS_LIST"

if [ "$STATUS_LIST" = "success" ]; then
  echo "🎉 SUCESSO! Lista enviada!"
else
  echo "❌ Erro ao enviar lista"
  ERROR_LIST=$(echo $RESPONSE_LIST | jq -r '.message // "Erro desconhecido"')
  echo "Mensagem de erro: $ERROR_LIST"
fi

echo ""
echo "⏳ Aguardando 3 segundos..."
sleep 3

echo ""
echo "🎠 Testando carrossel..."
RESPONSE_CAROUSEL=$(curl -s -X POST "http://localhost:3000/api/test-session/send-carousel" \
  -H "accept: */*" \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": ["557488120795@c.us"],
    "isGroup": false,
    "headerText": "🛍️ Nossos Produtos em Destaque!",
    "footerText": "Escolha o que mais te interessar",
    "cards": [
      {
        "id": "produto1",
        "title": "📱 iPhone 15 Pro",
        "description": "O mais novo iPhone com tecnologia avançada",
        "imageUrl": "https://via.placeholder.com/300x200/007AFF/FFFFFF?text=iPhone+15+Pro",
        "buttons": [
          {
            "id": "ver_iphone",
            "text": "Ver Detalhes",
            "type": "url",
            "value": "https://apple.com/iphone-15-pro"
          },
          {
            "id": "comprar_iphone",
            "text": "Comprar Agora",
            "type": "reply",
            "value": "comprar_iphone_15_pro"
          }
        ]
      },
      {
        "id": "produto2", 
        "title": "💻 MacBook Air M3",
        "description": "Notebook ultraportátil com chip M3",
        "imageUrl": "https://via.placeholder.com/300x200/34C759/FFFFFF?text=MacBook+Air+M3",
        "buttons": [
          {
            "id": "ver_macbook",
            "text": "Ver Detalhes", 
            "type": "url",
            "value": "https://apple.com/macbook-air-m3"
          },
          {
            "id": "comprar_macbook",
            "text": "Comprar Agora",
            "type": "reply", 
            "value": "comprar_macbook_air_m3"
          }
        ]
      }
    ]
  }')

echo "Resposta do carrossel:"
echo $RESPONSE_CAROUSEL | jq .

STATUS_CAROUSEL=$(echo $RESPONSE_CAROUSEL | jq -r '.status // "error"')
echo ""
echo "Status do carrossel: $STATUS_CAROUSEL"

if [ "$STATUS_CAROUSEL" = "success" ]; then
  echo "🎉 SUCESSO! Carrossel enviado!"
else
  echo "❌ Erro ao enviar carrossel"
  ERROR_CAROUSEL=$(echo $RESPONSE_CAROUSEL | jq -r '.message // "Erro desconhecido"')
  echo "Mensagem de erro: $ERROR_CAROUSEL"
fi

echo ""
echo "🏆 TESTE COMPLETO DOS BOTÕES INTERATIVOS!"
echo "=========================================="
