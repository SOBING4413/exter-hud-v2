import React, { useEffect, useRef, useState } from 'react'
import { useHud } from '../state/store'

const POSITIONS = {
  'bottom-center': { bottom: '12vh', left: '50%', transform: 'translateX(-50%)' },
  'bottom-left':   { bottom: '12vh', left: '3vw' },
  'bottom-right':  { bottom: '12vh', right: '3vw' },
}

// Bar fills 0 -> 100% over `duration`ms purely via a CSS transition, so it
// stays perfectly in sync even if the tab throttles JS timers.
export default function ProgressBar() {
  const progress = useHud((s) => s.progress)
  const [width, setWidth] = useState(0)
  const rafRef = useRef(null)

  useEffect(() => {
    if (!progress.active) return
    setWidth(0)
    rafRef.current = requestAnimationFrame(() => {
      requestAnimationFrame(() => setWidth(100))
    })
    return () => cancelAnimationFrame(rafRef.current)
  }, [progress.key, progress.active])

  if (!progress.active) return null

  const pos = POSITIONS['bottom-center']

  return (
    <div
      className="panel fade-in"
      style={{
        position: 'absolute', ...pos, width: 320, padding: '10px 14px',
        pointerEvents: 'none',
      }}
    >
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
        <span className="label" style={{ textTransform: 'none' }}>{progress.label}</span>
        {progress.canCancel && <span className="label" style={{ opacity: 0.6 }}>hold X to cancel</span>}
      </div>
      <div style={{ height: 6, borderRadius: 4, background: 'rgba(255,255,255,0.1)', overflow: 'hidden' }}>
        <div
          style={{
            height: '100%', width: `${width}%`, background: 'var(--primary)',
            transition: `width ${progress.duration}ms linear`,
          }}
        />
      </div>
    </div>
  )
}
