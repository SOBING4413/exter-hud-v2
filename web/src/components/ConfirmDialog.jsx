import React from 'react'
import { AlertTriangle, Info } from 'lucide-react'
import { useHud } from '../state/store'
import { nuiCallback } from '../hooks/useNuiEvent'

export default function ConfirmDialog() {
  const dialog = useHud((s) => s.dialog)

  if (!dialog.open) return null

  function respond(confirmed) {
    useHud.setState((s) => ({ dialog: { ...s.dialog, open: false } }))
    nuiCallback('dialog:result', { confirmed })
  }

  return (
    <div
      style={{
        position: 'absolute', inset: 0, display: 'flex', alignItems: 'center',
        justifyContent: 'center', pointerEvents: dialog.mode === 'confirm' ? 'auto' : 'none',
        background: dialog.mode === 'confirm' ? 'rgba(6, 8, 12, 0.45)' : 'transparent',
      }}
    >
      <div
        className="panel fade-in"
        style={{
          width: 340, padding: 18, pointerEvents: 'auto',
          borderTop: `3px solid ${dialog.danger ? 'var(--danger)' : 'var(--primary)'}`,
        }}
      >
        <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginBottom: 8 }}>
          {dialog.danger ? <AlertTriangle size={16} color="var(--danger)" /> : <Info size={16} color="var(--primary)" />}
          <div style={{ fontFamily: 'var(--font-display)', fontWeight: 600, fontSize: 15 }}>{dialog.title}</div>
        </div>
        <div style={{ fontSize: 13, color: 'var(--text-muted)', marginBottom: dialog.mode === 'confirm' ? 16 : 0 }}>
          {dialog.message}
        </div>

        {dialog.mode === 'confirm' && (
          <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
            <button
              onClick={() => respond(false)}
              style={{
                padding: '7px 14px', borderRadius: 8, border: '1px solid var(--panel-border)',
                background: 'transparent', color: 'var(--text-primary)', cursor: 'pointer', fontSize: 13,
              }}
            >
              {dialog.cancelLabel}
            </button>
            <button
              onClick={() => respond(true)}
              style={{
                padding: '7px 14px', borderRadius: 8, border: 'none',
                background: dialog.danger ? 'var(--danger)' : 'var(--primary)', color: '#fff',
                cursor: 'pointer', fontSize: 13, fontWeight: 600,
              }}
            >
              {dialog.confirmLabel}
            </button>
          </div>
        )}
      </div>
    </div>
  )
}
