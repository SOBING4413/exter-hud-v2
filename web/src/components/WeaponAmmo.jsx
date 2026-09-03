import React from 'react'
import { Crosshair } from 'lucide-react'
import { useHud } from '../state/store'
import Draggable from './Draggable'

export default function WeaponAmmo() {
  const { hasWeapon, weapon, theme, dynamicVisibility } = useHud((s) => s)

  if (dynamicVisibility.ammoOnlyWithWeapon && !hasWeapon) return null
  if (!weapon) return null

  return (
    <Draggable id="ammo" style={{ position: 'absolute', right: 20, top: 20, pointerEvents: 'auto' }}>
      <div className="panel fade-in" style={{ padding: '8px 14px', display: 'flex', alignItems: 'center', gap: 8 }}>
        <Crosshair size={16} color={theme.primaryColor} />
        <span className="value" style={{ fontSize: 16 }}>{weapon.ammo}</span>
        <span className="label">/ {weapon.clip}</span>
      </div>
    </Draggable>
  )
}
