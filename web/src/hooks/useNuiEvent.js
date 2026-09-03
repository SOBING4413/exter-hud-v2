import { useEffect } from 'react'
import { useHud } from '../state/store'

// Wires window `message` events (SendNUIMessage from Lua) into the store.
export function useNuiEvent() {
  const applyUpdate = useHud((s) => s.applyUpdate)

  useEffect(() => {
    function onMessage(event) {
      const { action, data } = event.data || {}
      if (!action) return
      applyUpdate(action, data)
    }
    window.addEventListener('message', onMessage)
    return () => window.removeEventListener('message', onMessage)
  }, [applyUpdate])
}

export function nuiCallback(name, payload = {}) {
  const resourceName = window.GetParentResourceName ? window.GetParentResourceName() : 'exter-hud-v2'
  return fetch(`https://${resourceName}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(payload),
  }).catch(() => {})
}
