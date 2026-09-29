# Flash Cards

Flash card app de JavaScript para practicar preguntas y respuestas. Cada tarjeta se muestra de una en una, se voltea para revelar la respuesta y hay una barra de progreso que indica por dónde vas.

## Requisitos

- **Node.js** 18 o superior (recomendado 20+). Comprueba con `node -v`
- **npm** 9 o superior. Comprueba con `npm -v`
- Un navegador moderno (Chrome, Firefox, Safari o Edge)

## Instalación

Clona el repositorio:

```bash
git clone https://github.com/javierjuanJJ/Flash-Cards-2.git
cd Flash-Cards-2
```

Instala las dependencias:

```bash
npm install
```

## Ejecución

Modo desarrollo (con recarga automática al guardar):

```bash
npm run dev
```

Abre la URL que aparece en la consola, normalmente:

```
http://localhost:5173
```

Para detener el servidor pulsa `Ctrl + C`.

## Otros comandos

| Comando         | Descripción                                        |
| --------------- | -------------------------------------------------- |
| `npm run dev`   | Servidor de desarrollo con hot reload               |
| `npm run build` | Genera la versión de producción en `dist/`           |
| `npm run preview` | Sirve localmente la build de `dist/` para probarla |
| `npm run lint`  | Revisa el código con ESLint                          |

## Docker

La app se publica como imagen en Docker Hub: [`jjal20021998/flash-cards`](https://hub.docker.com/r/jjal20021998/flash-cards)

```bash
docker pull jjal20021998/flash-cards
docker run -d -p 8080:80 jjal20021998/flash-cards
```

Abre <http://localhost:8080>

### Etiquetas disponibles

| Etiqueta         | Contenido                                                    |
| ---------------- | ------------------------------------------------------------ |
| `latest`         | JSON por defecto del repo (`public/flashcards.json`)          |
| `default`        | Igual que `latest`, para dejarlo explícito                    |
| `react-example`  | Ejemplo con el JSON de `examples/react-cards.json`            |

Puedes crear tus propias etiquetas a partir de las de ejemplo o construir desde el código.

### `CARDS_FILE`: tu JSON en build o en runtime

La app pide el fichero `flashcards.json` por HTTP al arrancar, así que el JSON se puede fijar en dos momentos distintos:

| Momento | Cómo | Cuándo usarlo |
| ------- | ---- | ------------- |
| **Build** | `--build-arg CARDS_FILE=...` | Quieres que la imagen ya salga con tus tarjetas y no depende de ficheros externos |
| **Runtime** | `-e CARDS_FILE=...` + `-v fichero:/ruta:ro` | Quieres una sola imagen y cambiar el temario al arrancar, sin reconstruir |

#### En runtime (`docker run`)

```bash
docker run -d -p 8080:80 \
  -e CARDS_FILE=/cards/mis-tarjetas.json \
  -v "$PWD/mis-tarjetas.json:/cards/mis-tarjetas.json:ro" \
  jjal20021998/flash-cards
```

`CARDS_FILE` es una ruta **dentro del contenedor**, por eso normalmente se combina con `-v` para montar tu fichero. El entrypoint lo copia sobre el `flashcards.json` que sirve nginx antes de arrancarlo.

| Valor de `CARDS_FILE`      | Comportamiento                                             |
| -------------------------- | ---------------------------------------------------------- |
| Sin definir (por defecto)  | Usa el JSON compilado en la imagen                           |
| Ruta a un fichero válido   | Usa ese JSON                                                 |
| Ruta a un fichero inexistente | Avisa por log y usa el JSON por defecto                   |
| Ruta a un JSON que no tiene `"flashcards"` | Avisa por log y usa el JSON por defecto |

Los avisos se ven en los logs del contenedor:

```bash
docker logs flashcards
# flash-cards: usando CARDS_FILE=/cards/mis-tarjetas.json
```

#### En build

```bash
# Con el JSON por defecto
docker build -t flash-cards:default .

# Con tu propio JSON (el fichero debe estar dentro del contexto de build)
docker build --build-arg CARDS_FILE=examples/react-cards.json -t flash-cards:mis-tarjetas .

docker run -d -p 8080:80 flash-cards:mis-tarjetas
```

El fichero debe respetar este formato:

```json
{
  "title": "Mi temario",
  "flashcards": [
    { "id": 1, "question": "¿Pregunta?", "answer": "Respuesta." }
  ]
}
```

En build el JSON se valida antes de compilar: si el fichero no existe, no tiene un array `flashcards` con elementos, o alguna tarjeta va sin `question` o `answer`, la build falla con un error claro en lugar de generar una imagen rota. En runtime no se puede validar con esas garantías (la imagen no lleva Node), así que el entrypoint avisa en el log y cae al JSON por defecto.

### Parámetros de build

| Parámetro   | Por defecto                 | Descripción                                                       |
| ----------- | --------------------------- | ----------------------------------------------------------------- |
| `CARDS_FILE` | `public/flashcards.json`   | JSON con las tarjetas compilado en la imagen. Dentro del contexto de build |
| `VCS_REF`  | `unknown`                   | Commit de git, se guarda como label OCI de la imagen               |

### Variables de entorno

| Variable     | Por defecto | Descripción                                              |
| ------------ | ----------- | -------------------------------------------------------- |
| `CARDS_FILE` | vacío       | Ruta **dentro del contenedor** al JSON a usar en runtime  |

### Opciones de `docker run`

| Opción                     | Ejemplo                                    | Descripción                          |
| -------------------------- | ------------------------------------------ | ------------------------------------ |
| `-p <host>:<cont>`         | `-p 8080:80`                               | Publica el puerto 80 de nginx        |
| `-e <VAR>=<valor>`         | `-e CARDS_FILE=/cards/mis.json`            | Variable de entorno del contenedor   |
| `-v <host>:<cont>[:ro]`    | `-v "$PWD/mis.json:/cards/mis.json:ro"`    | Monta tu JSON en el contenedor        |
| `--name <nombre>`          | `--name flashcards`                         | Nombre del contenedor                |
| `-d`                       | `-d`                                       | Ejecuta en segundo plano             |
| `--restart unless-stopped` |                                            | Reinicia el contenedor si se cae     |

Ejemplo completo:

```bash
docker run -d \
  --name flashcards \
  -p 8080:80 \
  --restart unless-stopped \
  -e CARDS_FILE=/cards/mis-tarjetas.json \
  -v "$PWD/mis-tarjetas.json:/cards/mis-tarjetas.json:ro" \
  jjal20021998/flash-cards
```

Detener y borrar el contenedor:

```bash
docker stop flashcards && docker rm flashcards
```

### Construir y subir tu propia imagen

```bash
# 1. Construir
docker build -t <tu-usuario>/flash-cards:mi-json \
  --build-arg CARDS_FILE=examples/react-cards.json \
  --build-arg VCS_REF=$(git rev-parse --short HEAD) .

# 2. Iniciar sesión (si no lo has hecho)
docker login

# 3. Subir
docker push <tu-usuario>/flash-cards:mi-json
```

### Detalles de la imagen

- Build en dos etapas: `node:20-alpine` compila con Vite y `nginx:1.27-alpine` sirve el resultado estático
- `docker-entrypoint.sh` resuelve el JSON de runtime antes de arrancar nginx
- Compresión gzip activada y caché de assets con hash (`immutable`)
- El JSON se sirve con `no-store` para que un cambio de temario se vea al instante
- `HEALTHCHECK` incluido, el contenedor pasa a `healthy` cuando nginx responde
- Expone el puerto `80`

## Estructura del proyecto

```
.
├── Dockerfile              # Build multi-etapa, CARDS_FILE en build y runtime
├── docker-entrypoint.sh    # Resuelve el JSON de runtime y arranca nginx
├── nginx.conf              # Configuración de nginx para la SPA
├── .dockerignore
├── index.html
├── package.json
├── vite.config.js
├── examples/
│   └── react-cards.json    # JSON de ejemplo para probar CARDS_FILE
├── public/
│   └── flashcards.json     # JSON por defecto (se sirve en /flashcards.json)
└── src/
    ├── main.jsx                 # Punto de entrada
    ├── App.jsx                  # Estado con useState, fetch del JSON y layout
    ├── styles.css               # Estilos de la aplicación
    └── components/
        ├── ProgressBar.jsx      # Barra de progreso
        ├── FlashCard.jsx        # Tarjeta que se voltea
        └── Controls.jsx         # Botones de navegación
```

## Cómo está hecho

- **React + Vite** como framework y bundler
- **Estado con `useState`**: en `App.jsx` se guardan las tarjetas, el índice de la tarjeta actual y si está volteada
- **El JSON se pide por HTTP** a `/flashcards.json` con `useEffect` al montar el componente, en vez de quedar embebido en el bundle. Eso es lo que permite cambiar el temario con `-e CARDS_FILE=...` sin reconstruir la imagen
- **Estados de carga y error**: mientras se descarga el JSON y si falla, la app muestra un mensaje en vez de romperse
- **Componentes reutilizables**: cada pieza de la interfaz (barra, tarjeta, botones) es un componente independiente que recibe sus datos por props
- **Navegación cíclica**: `Next` y `Previous` dan la vuelta a la lista al llegar al final
- **Voltear tarjeta**: con click, `Enter` o barra espaciadora (accesible con teclado)

## Añadir más tarjetas

Edita `public/flashcards.json` y añade un objeto más al array `flashcards`:

```json
{
  "id": 13,
  "question": "¿Tu pregunta?",
  "answer": "Tu respuesta."
}
```

La barra de progreso se actualiza sola con el nuevo total. Si estás usando la imagen de Docker, recuerda reconstruirla o montar el fichero nuevo:

```bash
# Localmente
npm run dev

# Con la imagen de Docker
docker run -d -p 8080:80 \
  -e CARDS_FILE=/cards/mis.json \
  -v "$PWD/public/flashcards.json:/cards/mis.json:ro" \
  jjal20021998/flash-cards
```

## Accesibilidad

- La barra de progreso expone `role="progressbar"` con los valores actuales
- La tarjeta es un `button` con `tabIndex`, activable con teclado
- Cada control tiene su `aria-label` correspondiente
