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

| Etiqueta         | Contenido                                              |
| ---------------- | ------------------------------------------------------ |
| `latest`         | JSON por defecto del repo (`src/data/flashcards.json`) |
| `default`        | Igual que `latest`, para dejarlo explícito              |
| `react-example`  | Ejemplo con el JSON de `examples/react-cards.json`      |

Puedes crear tus propias etiquetas a partir de las de ejemplo o construir desde el código.

### Parámetros de build

| Parámetro  | Por defecto                   | Descripción                                                          |
| ---------- | ----------------------------- | -------------------------------------------------------------------- |
| `CARDS_FILE` | `src/data/flashcards.json`   | Fichero JSON con las tarjetas, **dentro del contexto de build**        |
| `VCS_REF`  | `unknown`                     | Commit de git, se guarda como label OCI de la imagen                  |

Con `CARDS_FILE` eliges qué JSON se compila dentro del contenedor. Si no lo indicas, se usa el del propio repo.

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

Durante el build el JSON se valida: si el fichero no existe, no tiene un array `flashcards` con elementos, o alguna tarjeta va sin `question` o `answer`, la build falla con un error claro en lugar de generar una imagen rota.

> El JSON se compila dentro del bundle de JavaScript, así que cambiar las tarjetas requiere volver a construir la imagen. La barra de progreso se recalcula sola con el número de tarjetas de tu JSON.

### Opciones de `docker run`

| Opción                     | Ejemplo                  | Descripción                                |
| -------------------------- | ------------------------ | ------------------------------------------ |
| `-p <host>:<cont>`         | `-p 8080:80`             | Publica el puerto 80 de nginx              |
| `--name <nombre>`          | `--name flashcards`       | Nombre del contenedor                      |
| `-d`                       | `-d`                     | Ejecuta en segundo plano                   |
| `--restart unless-stopped` |                          | Reinicia el contenedor si se cae           |

Ejemplo completo:

```bash
docker run -d \
  --name flashcards \
  -p 8080:80 \
  --restart unless-stopped \
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
- Compresión gzip activada y caché de assets con hash (`immutable`)
- `HEALTHCHECK` incluido, el contenedor pasa a `healthy` cuando nginx responde
- Expone el puerto `80`

## Estructura del proyecto

```
.
├── Dockerfile              # Build multi-etapa con el parámetro CARDS_FILE
├── nginx.conf              # Configuración de nginx para la SPA
├── .dockerignore
├── index.html
├── package.json
├── vite.config.js
├── examples/
│   └── react-cards.json    # JSON de ejemplo para probar CARDS_FILE
└── src/
    ├── main.jsx                 # Punto de entrada
    ├── App.jsx                  # Estado con useState y layout
    ├── styles.css               # Estilos de la aplicación
    ├── data/
    │   └── flashcards.json      # Preguntas y respuestas (JSON por defecto)
    └── components/
        ├── ProgressBar.jsx      # Barra de progreso
        ├── FlashCard.jsx        # Tarjeta que se voltea
        └── Controls.jsx         # Botones de navegación
```

## Cómo está hecho

- **React + Vite** como framework y bundler
- **Estado con `useState`**: las tarjetas se cargan del JSON, y en `App.jsx` se controlan el índice de la tarjeta actual y si está volteada
- **Componentes reutilizables**: cada pieza de la interfaz (barra, tarjeta, botones) es un componente independiente que recibe sus datos por props
- **Navegación cíclica**: `Next` y `Previous` dan la vuelta a la lista al llegar al final
- **Voltear tarjeta**: con click, `Enter` o barra espaciadora (accesible con teclado)

## Añadir más tarjetas

Edita `src/data/flashcards.json` y añade un objeto más al array `flashcards`:

```json
{
  "id": 13,
  "question": "¿Tu pregunta?",
  "answer": "Tu respuesta."
}
```

La barra de progreso se actualiza sola con el nuevo total.

## Accesibilidad

- La barra de progreso expone `role="progressbar"` con los valores actuales
- La tarjeta es un `button` con `tabIndex`, activable con teclado
- Cada control tiene su `aria-label` correspondiente
