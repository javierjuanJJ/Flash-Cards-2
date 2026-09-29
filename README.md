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

## Estructura del proyecto

```
.
├── index.html
├── package.json
├── vite.config.js
└── src/
    ├── main.jsx                 # Punto de entrada
    ├── App.jsx                  # Estado con useState y layout
    ├── styles.css               # Estilos de la aplicación
    ├── data/
    │   └── flashcards.json      # Preguntas y respuestas
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
