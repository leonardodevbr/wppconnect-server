# ── Etapa 1: builder ──────────────────────────────────────
FROM node:22-alpine AS builder

WORKDIR /app

# Instalar dependências de sistema para compilar módulos nativos (bcrypt, etc.)
RUN apk add --no-cache python3 make g++

COPY package*.json ./

# --legacy-peer-deps resolve conflito entre @typescript-eslint v7 e v8
RUN npm ci --legacy-peer-deps --ignore-scripts

COPY . .

RUN npm run build

# ── Etapa 2: runner ───────────────────────────────────────
FROM node:22-alpine AS runner

WORKDIR /app

# Runtime: Chromium/Puppeteer + ferramentas temporárias para compilar bcrypt (node-gyp)
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV CHROME_BIN=/usr/bin/chromium-browser

COPY package*.json ./

# npm ci com scripts executa prepare (husky), mas husky não existe com --omit=dev — usar ignore-scripts + npm rebuild bcrypt
RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
  && apk add --no-cache --virtual .build-deps python3 make g++ \
  && npm ci --omit=dev --legacy-peer-deps --ignore-scripts \
  && npm rebuild bcrypt \
  && apk del .build-deps

# Copiar build compilado
COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["node", "dist/server.js"]
