function Controls({ onPrevious, onNext, onFlip, onRestart, isFlipped }) {
  return (
    <div className="controls">
      <button type="button" className="btn" onClick={onPrevious}>
        ← Previous
      </button>

      <button type="button" className="btn btn--primary" onClick={onFlip}>
        {isFlipped ? 'Show Question' : 'Show Answer'}
      </button>

      <button type="button" className="btn" onClick={onNext}>
        Next →
      </button>

      <button type="button" className="btn btn--ghost" onClick={onRestart}>
        Restart
      </button>
    </div>
  )
}

export default Controls
