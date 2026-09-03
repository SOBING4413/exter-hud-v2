import React from 'react'
import { CheckCircle2, Info, AlertTriangle, XCircle } from 'lucide-react'
import { useHud } from '../state/store'

const COLORS = { info: 'var(--primary)', success: 'var(--success)', warning: 'var(--warning)', error: 'var(--danger)' }
const ICONS = { info: Info, success: CheckCircle2, warning: AlertTriangle, error: XCircle }

const POSITIONS = {
  'top-right':    { top: 70, right: 20 },
  'top-left':     { top: 70, left: 20 },
  'top-center':   { top: 70, left: '50%', transform: 'translateX(-50%)' },
  'bottom-right': { bottom: 20, right: 20 },
  'bottom-left':  { bottom: 20, left: 20 },
}

function Notification({ n }) {
  const Icon = ICONS[n.type] || ICONS.info
  const color = COLORS[n.type] || COLORS.info

  return (
    <div
      className="panel fade-in"
      style={{
        padding: '10px 14px', minWidth: 240, maxWidth: 320, borderLeft: `3px solid ${color}`,
        display: 'flex', gap: 10, alignItems: 'flex-start', overflow: 'hidden', position: 'relative',
      }}
    >
      <Icon size={16} color={color} style={{ marginTop: 1, flexShrink: 0 }} />
      <div style={{ flex: 1 }}>
        {n.title && <div style={{ fontSize: 13, fontWeight: 600, marginBottom: 2 }}>{n.title}</div>}
        <div style={{ fontSize: 13, color: n.title ? 'var(--text-muted)' : 'var(--text-primary)' }}>{n.message}</div>
      </div>
      <div
        style={{
          position: 'absolute', left: 0, bottom: 0, height: 2, background: color,
          width: '100%', transformOrigin: 'left', animation: `shrink ${n.duration}ms linear forwards`,
        }}
      />
    </div>
  )
}

export default function Notifications() {
  const notifications = useHud((s) => s.notifications)
  const notifSettings = useHud((s) => s.notifSettings)
  const pos = POSITIONS[notifSettings.position] || POSITIONS['top-right']
  const isBottom = notifSettings.position.startsWith('bottom')

  return (
    <div
      style={{
        position: 'absolute', display: 'flex', flexDirection: isBottom ? 'column-reverse' : 'column',
        gap: 8, pointerEvents: 'none', ...pos,
      }}
    >
      {notifications.map((n) => <Notification key={n.id} n={n} />)}
    </div>
  )
}
