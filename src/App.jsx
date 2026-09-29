import { useState } from 'react'
import data from './data/flashcards.json'
import ProgressBar from './components/ProgressBar'
import FlashCard from './components/FlashCard'
import Controls from './components/Controls'

function App() {
  const [cards] = useState(data.flashcards)
  const [currentIndex, setCurrentIndex] = useState(0)
  const [isFlipped, setIsFlipped] = useState(false)

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

  return (
    <main className="app">
      <h1 className="app__title">{data.title}</h1>

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
