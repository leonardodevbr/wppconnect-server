# 🚀 WPPConnect Server - Desenvolvimento Local

Este guia te ajudará a configurar e testar o WPPConnect Server localmente para desenvolvimento.

## 📋 Pré-requisitos

- Docker e Docker Compose instalados
- Node.js 18+ (para desenvolvimento sem Docker)
- Git

## 🛠️ Configuração Rápida

### Opção 1: Docker Compose (Recomendado)

```bash
# 1. Clone o repositório (se ainda não fez)
git clone <seu-repositorio>
cd wppconnect-server

# 2. Execute o script de inicialização
./start-dev.sh
```

### Opção 2: Instalação Manual

```bash
# 1. Instalar dependências
npm install

# 2. Configurar MongoDB local
# Instale MongoDB ou use MongoDB Atlas

# 3. Configurar Redis local
# Instale Redis ou use Redis Cloud

# 4. Copiar configurações
cp env.example .env
# Edite o arquivo .env com suas configurações

# 5. Iniciar o servidor
npm run dev
```

## 🔧 Configuração Detalhada

### Variáveis de Ambiente (.env)

```bash
# Configurações do Servidor
NODE_ENV=development
SECRET_KEY=THISISMYSECURETOKEN
HOST=http://localhost
PORT=3000

# MongoDB
MONGODB_URI=mongodb://wppconnect_user:wppconnect_pass@localhost:27017/wppconnect
MONGODB_USERNAME=wppconnect_user
MONGODB_PASSWORD=wppconnect_pass

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=redis123

# Webhook (opcional)
CALLBACK_URL=http://localhost:3000/webhook
```

### Serviços Incluídos

- **WPPConnect Server**: `http://localhost:3000`
- **Swagger UI**: `http://localhost:3000/api-docs`
- **Prometheus**: `http://localhost:9090`
- **Grafana**: `http://localhost:3001` (admin/admin123)
- **MongoDB**: `localhost:27017`
- **Redis**: `localhost:6379`

## 🧪 Testando a API

### 1. Teste Automático

```bash
# Execute o script de teste
./test-api.sh
```

### 2. Teste Manual

#### Gerar Token
```bash
curl -X POST "http://localhost:3000/api/minha-sessao/THISISMYSECURETOKEN/generate-token"
```

#### Iniciar Sessão
```bash
curl -X POST "http://localhost:3000/api/minha-sessao/start-session" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{"waitQrCode": true}'
```

#### Obter QR Code
```bash
curl -X GET "http://localhost:3000/api/minha-sessao/qrcode-session" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

#### Enviar Mensagem
```bash
curl -X POST "http://localhost:3000/api/minha-sessao/send-message" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": ["5511999999999"],
    "message": "Olá! Esta é uma mensagem de teste."
  }'
```

## 📊 Monitoramento

### Prometheus
- URL: `http://localhost:9090`
- Métricas: `http://localhost:3000/metrics`

### Grafana
- URL: `http://localhost:3001`
- Login: `admin` / `admin123`
- Dashboard pré-configurado para WPPConnect

## 🔍 Debugging

### Logs do Servidor
```bash
# Ver logs em tempo real
docker-compose -f docker-compose.dev.yml logs -f wppconnect-server

# Ou se rodando localmente
npm run dev
```

### Logs do MongoDB
```bash
docker-compose -f docker-compose.dev.yml logs -f mongodb
```

### Logs do Redis
```bash
docker-compose -f docker-compose.dev.yml logs -f redis
```

## 🛠️ Comandos Úteis

```bash
# Parar todos os serviços
docker-compose -f docker-compose.dev.yml down

# Reiniciar serviços
docker-compose -f docker-compose.dev.yml restart

# Ver status dos serviços
docker-compose -f docker-compose.dev.yml ps

# Limpar volumes (CUIDADO: apaga dados)
docker-compose -f docker-compose.dev.yml down -v

# Reconstruir containers
docker-compose -f docker-compose.dev.yml up --build
```

## 🚨 Solução de Problemas

### Erro de Conexão MongoDB
```bash
# Verificar se MongoDB está rodando
docker-compose -f docker-compose.dev.yml ps mongodb

# Verificar logs
docker-compose -f docker-compose.dev.yml logs mongodb
```

### Erro de Conexão Redis
```bash
# Verificar se Redis está rodando
docker-compose -f docker-compose.dev.yml ps redis

# Testar conexão
docker exec -it wppconnect-redis redis-cli ping
```

### Erro de Permissão Docker
```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER
# Fazer logout e login novamente
```

### Porta já em uso
```bash
# Verificar processos usando a porta
lsof -i :3000

# Parar processo específico
kill -9 PID_DO_PROCESSO
```

## 📱 Testando com WhatsApp

1. **Inicie uma sessão** usando a API
2. **Escaneie o QR code** que aparecerá
3. **Aguarde a conexão** ser estabelecida
4. **Teste envio de mensagens** para seu próprio número
5. **Monitore os logs** para ver mensagens recebidas

## 🔄 Próximos Passos

Após configurar o ambiente local:

1. **Implementar Dashboard Web** (React/Vue)
2. **Sistema de Templates** de mensagens
3. **Multi-tenancy** para múltiplos clientes
4. **Analytics Dashboard** com métricas
5. **Sistema de Campanhas** automatizadas

## 📞 Suporte

Se encontrar problemas:

1. Verifique os logs dos serviços
2. Confirme se todas as portas estão livres
3. Teste a conectividade dos bancos de dados
4. Verifique as configurações do arquivo .env

---

**🎯 Objetivo**: Ter um ambiente de desenvolvimento completo e funcional para implementar todas as funcionalidades necessárias para competir com Z-API!
