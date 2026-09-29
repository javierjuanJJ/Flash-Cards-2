# syntax=docker/dockerfile:1

# ---------- Stage 1: build ----------
FROM node:20-alpine AS builder

# Parámetro de build: fichero JSON dentro del contexto de build que se usará
# como fuente de tarjetas. Por defecto, el JSON que ya viene en el proyecto.
ARG CARDS_FILE=src/data/flashcards.json

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# Valida el JSON y lo deja como fuente por defecto antes de compilar
RUN set -eux; \
    if [ ! -f "$CARDS_FILE" ]; then \
      echo "ERROR: no se encuentra el fichero '$CARDS_FILE'"; \
      echo " Debe existir dentro del contexto de build."; \
      exit 1; \
    fi; \
    if [ "$CARDS_FILE" != "src/data/flashcards.json" ]; then \
      cp "$CARDS_FILE" src/data/flashcards.json; \
    fi; \
    node -e "const d=require('./src/data/flashcards.json'); \
      if(!Array.isArray(d.flashcards)||d.flashcards.length===0){console.error('ERROR: el JSON no contiene un array \"flashcards\" con tarjetas');process.exit(1)} \
      d.flashcards.forEach((c,i)=>{if(!c.question||!c.answer){console.error('ERROR: tarjeta '+i+' sin question/answer');process.exit(1)}}); \
      console.log('OK -> '+d.flashcards.length+' tarjetas desde $CARDS_FILE')"

RUN npm run build

# ---------- Stage 2: runtime ----------
FROM nginx:1.27-alpine AS runtime

ARG CARDS_FILE=src/data/flashcards.json
ARG VCS_REF=unknown

LABEL org.opencontainers.image.title="Flash Cards" \
      org.opencontainers.image.description="Flash card app de JavaScript con React, customizable con tu propio JSON" \
      org.opencontainers.image.source="https://github.com/javierjuanJJ/Flash-Cards-2" \
      org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.licenses="MIT" \
      com.flashcards.cards-file="$CARDS_FILE"

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

# 127.0.0.1 y no localhost: en Alpine "localhost" resuelve a ::1 y nginx escucha en IPv4
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
