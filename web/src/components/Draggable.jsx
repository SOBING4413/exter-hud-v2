import { useRef } from 'react'
import { useHud } from '../state/store'

// Wraps any HUD panel so it can be repositioned in Edit Mode (opened via
// /hudsettings). Offsets persist through the HUD editor's save action.
export default function Draggable({ id, children, style }) {
  const editMode = useHud((s) => s.editMode)
  const hidden = useHud((s) => s.hiddenElements[id])
  const pos = useHud((s) => s.positions[id]) || { x: 0, y: 0, scale: 1 }
  const setPosition = useHud((s) => s.setPosition)
  const dragRef = useRef(null)

  if (hidden) return null

  function onPointerDown(e) {
    if (!editMode) return
    e.currentTarget.setPointerCapture(e.pointerId)
    dragRef.current = { startX: e.clientX, startY: e.clientY, origX: pos.x, origY: pos.y }
  }
  function onPointerMove(e) {
    if (!editMode || !dragRef.current) return
    const dx = e.clientX - dragRef.current.startX
    const dy = e.clientY - dragRef.current.startY
    setPosition(id, { x: dragRef.current.origX + dx, y: dragRef.current.origY + dy })
  }
  function onPointerUp(e) {
    dragRef.current = null
  }

  return (
    <div
      onPointerDown={onPointerDown}
      onPointerMove={onPointerMove}
      onPointerUp={onPointerUp}
      style={{
        ...style,
        transform: `translate(${pos.x}px, ${pos.y}px) scale(${pos.scale || 1})`,
        pointerEvents: editMode ? 'auto' : style?.pointerEvents,
        outline: editMode ? '1px dashed rgba(255,255,255,0.35)' : 'none',
        cursor: editMode ? 'grab' : 'default',
        borderRadius: 'var(--radius)',
      }}
    >
      {children}
    </div>
  )
}
