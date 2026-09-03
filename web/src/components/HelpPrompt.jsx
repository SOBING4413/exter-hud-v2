import React from 'react'
import { useHud } from '../state/store'

export default function HelpPrompt() {
  const help = useHud((s) => s.help)

  if (!help.visible) return null

  return (
    <div
      className="panel fade-in"
      style={{
        position: 'absolute', bottom: '6vh', left: '50%', transform: 'translateX(-50%)',
        display: 'flex', alignItems: 'center', gap: 8, padding: '6px 12px 6px 6px',
        pointerEvents: 'none',
      }}
    >
      <span
        style={{
          display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          minWidth: 22, height: 22, padding: '0 4px', borderRadius: 6,
          background: 'var(--primary)', color: '#fff', fontSize: 12, fontWeight: 700,
          fontFamily: 'var(--font-display)',
        }}
      >
        {help.key}
      </span>
      <span style={{ fontSize: 13 }}>{help.text}</span>
    </div>
  )
}
