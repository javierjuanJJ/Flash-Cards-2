import { useEffect, useState } from 'react'
import ProgressBar from './components/ProgressBar'
import FlashCard from './components/FlashCard'
import Controls from './components/Controls'

const DATA_URL = `${import.meta.env.BASE_URL}flashcards.json`

function App() {
  const [cards, setCards] = useState([])
  const [title, setTitle] = useState('Flash Cards')
  const [status, setStatus] = useState('loading')
  const [error, setError] = useState(null)
  const [currentIndex, setCurrentIndex] = useState(0)
  const [isFlipped, setIsFlipped] = useState(false)

  useEffect(() => {
    let cancelled = false

    fetch(DATA_URL)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`)
        return response.json()
      })
      .then((data) => {
        if (cancelled) return
        if (!Array.isArray(data.flashcards) || data.flashcards.length === 0) {
          throw new Error('el fichero no contiene un array "flashcards" con tarjetas')
        }
        setCards(data.flashcards)
        if (data.title) setTitle(data.title)
        setStatus('ready')
      })
      .catch((err) => {
        if (cancelled) return
        setError(err.message)
        setStatus('error')
      })

    return () => {
      cancelled = true
    }
  }, [])

  const total = cards.length
  const currentCard = cards[currentIndex]

  function handleNext() {
    setCurrentIndex((index) => (index + 1) % total)
    setIsFlipped(false)
  }

  function handlePrevious() {
    setCurrentIndex((index) => (index - 1 + total) % total)
    setIsFlipped(false)
  }

  function handleFlip() {
    setIsFlipped((flipped) => !flipped)
  }

  function handleRestart() {
    setCurrentIndex(0)
    setIsFlipped(false)
  }

  if (status === 'loading') {
    return (
      <main className="app">
        <h1 className="app__title">{title}</h1>
        <p className="app__status">Loading flashcards…</p>
      </main>
    )
  }

  if (status === 'error') {
    return (
      <main className="app">
        <h1 className="app__title">No se pudieron cargar las flashcards</h1>
        <p className="app__status">
          Error al leer <code>{DATA_URL}</code>: {error}
        </p>
      </main>
    )
  }

  return (
    <main className="app">
      <h1 className="app__title">{title}</h1>

      <ProgressBar current={currentIndex + 1} total={total} />

      <FlashCard card={currentCard} isFlipped={isFlipped} onFlip={handleFlip} />

      <Controls
        onPrevious={handlePrevious}
        onNext={handleNext}
        onFlip={handleFlip}
        onRestart={handleRestart}
        isFlipped={isFlipped}
      />

      <p className="app__hint">Click the card (or press Enter) to flip it</p>
    </main>
  )
}

export default App
