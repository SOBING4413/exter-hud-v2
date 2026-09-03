import React, { useEffect } from 'react'
import { useHud } from './state/store'
import { useNuiEvent, nuiCallback } from './hooks/useNuiEvent'
import VitalsCluster from './components/VitalsCluster'
import VehicleHud from './components/VehicleHud'
import VoiceRadio from './components/VoiceRadio'
import Compass from './components/Compass'
import WeaponAmmo from './components/WeaponAmmo'
import PlayerId from './components/PlayerId'
import Notifications from './components/Notifications'
import SettingsPanel from './components/SettingsPanel'
import ProgressBar from './components/ProgressBar'
import ConfirmDialog from './components/ConfirmDialog'
import HelpPrompt from './components/HelpPrompt'

const THEME_PRESETS = {
  default: { panelOpacityMultiplier: 1, blur: 14 },
  dark:    { panelOpacityMultiplier: 1.3, blur: 10 },
  light:   { panelOpacityMultiplier: 0.6, blur: 18, textOverride: '#12141A' },
  transparent: { panelOpacityMultiplier: 0.15, blur: 6 },
  neon:    { panelOpacityMultiplier: 1, blur: 20, glow: true },
}

export default function App() {
  useNuiEvent()

  const {
    hudVisible, paused, theme, themeName, safezone, settingsOpen,
  } = useHud((s) => s)

  useEffect(() => {
    nuiCallback('ready')
  }, [])

  useEffect(() => {
    const preset = THEME_PRESETS[themeName] || THEME_PRESETS.default
    const root = document.documentElement.style
    root.setProperty('--primary', theme.primaryColor)
    root.setProperty('--danger', theme.dangerColor)
    root.setProperty('--warning', theme.warningColor)
    root.setProperty('--success', theme.successColor)
    root.setProperty('--radius', `${theme.borderRadius}px`)
    root.setProperty('--anim', `${theme.animationSpeed}ms`)
    root.setProperty('--bg-opacity', `${Math.min(0.95, theme.backgroundOpacity * preset.panelOpacityMultiplier)}`)
    if (preset.textOverride) root.setProperty('--text-primary', preset.textOverride)
    else root.setProperty('--text-primary', '#F2F4F8')
  }, [theme, themeName])

  useEffect(() => {
    function onKey(e) {
      if (e.key === 'Escape' && settingsOpen) {
        nuiCallback('closeSettings')
        useHud.setState({ settingsOpen: false, editMode: false })
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [settingsOpen])

  const visible = hudVisible && !paused

  return (
    <div
      className="hud-root"
      style={{
        padding: `${safezone.top}vh ${safezone.right}vw ${safezone.bottom}vh ${safezone.left}vw`,
        opacity: visible ? 1 : 0,
        transition: 'opacity 250ms ease',
      }}
    >
      {visible && (
        <>
          <VitalsCluster />
          <VehicleHud />
          <VoiceRadio />
          <Compass />
          <WeaponAmmo />
          <PlayerId />
          <ProgressBar />
          <HelpPrompt />
        </>
      )}
      <Notifications />
      <SettingsPanel />
      <ConfirmDialog />
    </div>
  )
}
