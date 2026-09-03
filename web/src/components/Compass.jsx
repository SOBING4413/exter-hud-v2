import React from 'react'
import { Navigation } from 'lucide-react'
import { useHud } from '../state/store'
import Draggable from './Draggable'

function headingToCardinal(h) {
  const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW']
  return dirs[Math.round(h / 45) % 8]
}

export default function Compass() {
  const { heading, street, zone, theme } = useHud((s) => s)

  return (
    <Draggable id="compass" style={{ position: 'absolute', top: 20, left: '50%', transform: 'translateX(-50%)', pointerEvents: 'auto' }}>
      <div className="panel fade-in" style={{ padding: '8px 18px', display: 'flex', flexDirection: 'column', alignItems: 'center', minWidth: 200 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <Navigation size={14} color={theme.primaryColor} style={{ transform: `rotate(${heading}deg)` }} />
          <span className="value" style={{ fontSize: 13 }}>{headingToCardinal(360 - heading)}</span>
        </div>
        <div className="label" style={{ marginTop: 2, textAlign: 'center' }}>
          {street}{zone ? ` — ${zone}` : ''}
        </div>
      </div>
    </Draggable>
  )
}
