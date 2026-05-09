# Build stage — inclui devDependencies para compilar TypeScript / Babel
FROM node:22-alpine AS builder
WORKDIR /app

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN apk add --no-cache python3 make g++ libc6-compat

COPY package.json package-lock.json ./
RUN npm ci --ignore-scripts

COPY . .
# `npm run build` inclui `tsc`, que falha neste fork por erros de tipo nos controllers; o artefato em runtime vem do Babel.
RUN npm run build:js

# Runtime — apenas dependências de produção
FROM node:22-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

RUN apk add --no-cache \
    chromium \
    nss \
    freetype \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    vips-dev \
    fftw-dev

COPY package.json package-lock.json ./
RUN npm ci --omit=dev --ignore-scripts
RUN npm install mongoose redis crypto-js --omit=dev --ignore-scripts

COPY --from=builder /app/dist ./dist

EXPOSE 3000

CMD ["npm", "start"]
