function FlashCard({ card, isFlipped, onFlip }) {
  return (
    <div
      className={`flashcard ${isFlipped ? 'flashcard--flipped' : ''}`}
      onClick={onFlip}
      role="button"
      tabIndex={0}
      aria-pressed={isFlipped}
      aria-label={isFlipped ? 'Show question' : 'Show answer'}
      onKeyDown={(event) => {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault()
          onFlip()
        }
      }}
    >
      <div className="flashcard__inner">
        <div className="flashcard__face flashcard__face--front">
          <p className="flashcard__label">Question</p>
          <h2 className="flashcard__text">{card.question}</h2>
        </div>
        <div className="flashcard__face flashcard__face--back">
          <p className="flashcard__label">Answer</p>
          <p className="flashcard__text">{card.answer}</p>
        </div>
      </div>
    </div>
  )
}

export default FlashCard
