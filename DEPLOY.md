# Deploy no Railway

## Pré-requisitos

- Repositório no GitHub: `leonardodevbr/wppconnect-server`
- Conta no Railway: railway.app

## Passo a passo

### 1. Criar projeto

- New Project → Deploy from GitHub Repo → `leonardodevbr/wppconnect-server`
- Railway detecta o Dockerfile automaticamente

### 2. Adicionar banco de dados

- + New → Database → MongoDB
- + New → Database → Redis

### 3. Variáveis de ambiente (no serviço Node)

Copiar de `env.example` e preencher:

```
SECRET_KEY=gerar_chave_forte_aqui
NODE_ENV=production
PORT=3000
MONGODB_URI=${{MongoDB.MONGO_URL}}
REDIS_HOST=${{Redis.REDIS_HOST}}
REDIS_PORT=${{Redis.REDIS_PORT}}
REDIS_PASSWORD=${{Redis.REDIS_PASSWORD}}
ALLOWED_ORIGINS=https://seu-frontend.vercel.app
```

A sintaxe `${{Plugin.VAR}}` é resolvida automaticamente pelo Railway.

Na UI do Railway, confira o nome exato da variável na aba **Variables** do plugin MongoDB (por exemplo `MONGO_URL`, `DATABASE_URL` ou `MONGO_PUBLIC_URL`) e referencie-a em `MONGODB_URI` se `${{MongoDB.MONGO_URL}}` não existir no teu projeto.

### 4. Deploy

- Railway faz deploy automático a cada push na branch `main`
- URL pública gerada automaticamente (ex: `wppconnect-server-production.up.railway.app`)

### 5. Criar usuário admin

Após o primeiro deploy, executar via Railway CLI ou terminal do serviço:

```bash
node create-admin.js
```

### 6. Frontend

- Separar `frontend-react/` em repositório próprio: `leonardodevbr/wppconnect-frontend`
- Deploy no Vercel apontando `VITE_API_URL` para a URL do Railway
- Adicionar a URL do Vercel no `ALLOWED_ORIGINS` do serviço Railway

## Desenvolvimento local

```bash
docker-compose up -d
npm run dev
```

Frontend:

```bash
cd frontend-react
npm run dev
```
