#!/bin/sh
# Resuelve el JSON de tarjetas en tiempo de ejecución.
# - Si CARDS_FILE apunta a un fichero existente, lo usa.
# - Si no, mantiene el JSON por defecto que viene compilado en la imagen.
set -eu

TARGET="/usr/share/nginx/html/flashcards.json"

if [ -z "${CARDS_FILE:-}" ]; then
    echo "flash-cards: CARDS_FILE no definido, usando el JSON por defecto de la imagen"
    exec "$@"
fi

if [ "$CARDS_FILE" = "$TARGET" ]; then
    echo "flash-cards: CARDS_FILE ya apunta al destino, se usa el JSON por defecto de la imagen"
    exec "$@"
fi

if [ ! -f "$CARDS_FILE" ]; then
    echo "flash-cards: AVISO no existe '$CARDS_FILE', se usa el JSON por defecto de la imagen"
    exec "$@"
fi

if ! grep -q '"flashcards"' "$CARDS_FILE"; then
    echo "flash-cards: AVISO '$CARDS_FILE' no parece un JSON de flashcards, se usa el por defecto"
    exec "$@"
fi

echo "flash-cards: usando CARDS_FILE=$CARDS_FILE"
cp "$CARDS_FILE" "${TARGET}.tmp"
mv -f "${TARGET}.tmp" "$TARGET"

exec "$@"
