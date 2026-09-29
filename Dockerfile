# syntax=docker/dockerfile:1

# ---------- Stage 1: build ----------
FROM node:20-alpine AS builder

# Parámetro de BUILD: fichero JSON (dentro del contexto de build) que se compila
# como fuente por defecto en la imagen. Se puede sobrescribir al arrancar el
# contenedor con la variable de entorno CARDS_FILE (ver stage 2).
ARG CARDS_FILE=public/flashcards.json

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
    if [ "$CARDS_FILE" != "public/flashcards.json" ]; then \
      cp "$CARDS_FILE" public/flashcards.json; \
    fi; \
    node -e "const d=require('./public/flashcards.json'); \
      if(!Array.isArray(d.flashcards)||d.flashcards.length===0){console.error('ERROR: el JSON no contiene un array \"flashcards\" con tarjetas');process.exit(1)} \
      d.flashcards.forEach((c,i)=>{if(!c.question||!c.answer){console.error('ERROR: tarjeta '+i+' sin question/answer');process.exit(1)}}); \
      console.log('OK -> '+d.flashcards.length+' tarjetas desde $CARDS_FILE')"

RUN npm run build && test -f dist/flashcards.json

# ---------- Stage 2: runtime ----------
FROM nginx:1.27-alpine AS runtime

# Parámetro de RUNTIME: si se define, el contenedor usa este JSON en vez del
# que venía compilado en la imagen. Monta el fichero, p. ej.:
#   docker run -e CARDS_FILE=/cards/mis-tarjetas.json -v "$PWD/mis.json:/cards/mis-tarjetas.json:ro" ...
ENV CARDS_FILE=""

ARG BUILD_CARDS_FILE=public/flashcards.json
ARG VCS_REF=unknown

LABEL org.opencontainers.image.title="Flash Cards" \
      org.opencontainers.image.description="Flash card app de JavaScript con React, configurable con tu propio JSON en build o en runtime" \
      org.opencontainers.image.source="https://github.com/javierjuanJJ/Flash-Cards-2" \
      org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.licenses="MIT" \
      com.flashcards.build-cards-file="$BUILD_CARDS_FILE"

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

# 127.0.0.1 y no localhost: en Alpine "localhost" resuelve a ::1 y nginx escucha en IPv4
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://127.0.0.1/ || exit 1

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
