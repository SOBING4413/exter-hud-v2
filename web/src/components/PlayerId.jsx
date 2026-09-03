import React from 'react'
import { Hash } from 'lucide-react'
import { useHud } from '../state/store'
import Draggable from './Draggable'

export default function PlayerId() {
  const { playerId, theme } = useHud((s) => s)
  return (
    <Draggable id="playerId" style={{ position: 'absolute', bottom: 20, left: '50%', transform: 'translateX(-50%)', pointerEvents: 'auto' }}>
      <div className="panel fade-in" style={{ padding: '4px 10px', display: 'flex', alignItems: 'center', gap: 4 }}>
        <Hash size={12} color={theme.primaryColor} />
        <span className="label">{playerId}</span>
      </div>
    </Draggable>
  )
}
