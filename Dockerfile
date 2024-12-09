# Etapa base para dependências de produção
FROM node:lts-alpine3.18 as base
WORKDIR /usr/src/wpp-server
# Variáveis de ambiente para o Puppeteer
ENV NODE_ENV=production PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Copiar arquivos de dependências e instalar pacotes essenciais
COPY package.json ./
RUN apk update && \
    apk add \
    vips-dev \
    fftw-dev \
    gcc \
    g++ \
    make \
    libc6-compat \
    chromium \
    && rm -rf /var/cache/apk/*

# Instalar dependências de produção e o Sharp
RUN yarn install --production --pure-lockfile && \
    yarn add sharp --ignore-engines && \
    yarn cache clean

# Etapa de build para dependências de desenvolvimento
FROM base as build
WORKDIR /usr/src/wpp-server

# Variável de ambiente para evitar o download do Chromium pelo Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# Copiar dependências para o ambiente de build
COPY package.json ./
RUN yarn install --production=false --pure-lockfile && yarn cache clean

# Copiar o código-fonte e compilar
COPY . .
RUN yarn build

# Etapa final para a aplicação pronta para produção
FROM base
WORKDIR /usr/src/wpp-server/

# Instalar `tsx` globalmente para o ambiente de execução
RUN yarn global add tsx

# Copiar o build da etapa anterior
COPY --from=build /usr/src/wpp-server/ /usr/src/wpp-server/

# Expor a porta da aplicação
EXPOSE 21465

# Comando de inicialização
ENTRYPOINT ["tsx", "dist/server.js"]
