function ProgressBar({ current, total }) {
  const percentage = total === 0 ? 0 : Math.round((current / total) * 100)

  return (
    <div className="progress">
      <div className="progress__meta">
        <span>
          Card {current} of {total}
        </span>
        <span>{percentage}%</span>
      </div>
      <div
        className="progress__track"
        role="progressbar"
        aria-valuenow={current}
        aria-valuemin={1}
        aria-valuemax={total}
        aria-label="Flashcard progress"
      >
        <div className="progress__fill" style={{ width: `${percentage}%` }} />
      </div>
    </div>
  )
}

export default ProgressBar
