import React from 'react'
import { X, Move, Save } from 'lucide-react'
import { useHud } from '../state/store'
import { nuiCallback } from '../hooks/useNuiEvent'

const LAYOUTS = ['minimal', 'modern', 'compact', 'classic', 'dynamic']
const THEMES = ['default', 'dark', 'light', 'transparent', 'neon']
const ELEMENTS = [
  { id: 'vitals', label: 'Health / Needs' },
  { id: 'vehicle', label: 'Vehicle HUD' },
  { id: 'voice', label: 'Voice / Radio' },
  { id: 'compass', label: 'Compass / Street' },
  { id: 'ammo', label: 'Ammo' },
  { id: 'playerId', label: 'Player ID' },
]
const COLOR_KEYS = [
  { key: 'primaryColor', label: 'Primary' },
  { key: 'dangerColor', label: 'Danger' },
  { key: 'warningColor', label: 'Warning' },
  { key: 'successColor', label: 'Success' },
]

export default function SettingsPanel() {
  const {
    settingsOpen, closeSettings, layout, setLayout, themeName, setThemeName,
    theme, setThemeColor, hiddenElements, toggleElement, editMode, setEditMode,
    positions,
  } = useHud((s) => s)

  if (!settingsOpen) return null

  function save() {
    nuiCallback('saveSettings', { positions, hiddenElements, themeName, layout, theme })
  }

  function close() {
    setEditMode(false)
    closeSettings()
    nuiCallback('closeSettings')
  }

  return (
    <div style={{
      position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: 'rgba(0,0,0,0.35)', pointerEvents: 'auto',
    }}>
      <div className="panel fade-in" style={{ width: 380, padding: 20, maxHeight: '80vh', overflowY: 'auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
          <span className="value" style={{ fontSize: 16 }}>HUD Settings</span>
          <X size={18} style={{ cursor: 'pointer' }} onClick={close} />
        </div>

        <Section title="Layout">
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
            {LAYOUTS.map((l) => (
              <Chip key={l} active={layout === l} onClick={() => setLayout(l)}>{l}</Chip>
            ))}
          </div>
        </Section>

        <Section title="Theme">
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6 }}>
            {THEMES.map((t) => (
              <Chip key={t} active={themeName === t} onClick={() => setThemeName(t)}>{t}</Chip>
            ))}
          </div>
        </Section>

        <Section title="Colors">
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 12 }}>
            {COLOR_KEYS.map((c) => (
              <label key={c.key} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
                <input type="color" value={theme[c.key]} onChange={(e) => setThemeColor(c.key, e.target.value)} style={{ width: 32, height: 32, border: 'none', background: 'none' }} />
                <span className="label">{c.label}</span>
              </label>
            ))}
          </div>
        </Section>

        <Section title="Visible elements">
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {ELEMENTS.map((el) => (
              <label key={el.id} style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 13 }}>
                <input type="checkbox" checked={!hiddenElements[el.id]} onChange={() => toggleElement(el.id)} />
                {el.label}
              </label>
            ))}
          </div>
        </Section>

        <Section title="Positioning">
          <button
            onClick={() => setEditMode(!editMode)}
            style={{
              display: 'flex', alignItems: 'center', gap: 6, padding: '8px 12px', borderRadius: 8,
              background: editMode ? 'var(--primary)' : 'rgba(255,255,255,0.08)', color: '#fff', border: 'none', cursor: 'pointer', fontSize: 13,
            }}
          >
            <Move size={14} /> {editMode ? 'Exit drag mode' : 'Enable drag mode'}
          </button>
          <div className="label" style={{ marginTop: 6 }}>
            While drag mode is on, click and drag any HUD panel to reposition it.
          </div>
        </Section>

        <button
          onClick={save}
          style={{
            width: '100%', marginTop: 8, padding: '10px 0', borderRadius: 8, border: 'none',
            background: 'var(--success)', color: '#0b0e14', fontWeight: 600, display: 'flex',
            alignItems: 'center', justifyContent: 'center', gap: 6, cursor: 'pointer',
          }}
        >
          <Save size={14} /> Save settings
        </button>
      </div>
    </div>
  )
}

function Section({ title, children }) {
  return (
    <div style={{ marginBottom: 16 }}>
      <div className="label" style={{ marginBottom: 6, textTransform: 'uppercase', fontSize: 10 }}>{title}</div>
      {children}
    </div>
  )
}

function Chip({ active, onClick, children }) {
  return (
    <div
      onClick={onClick}
      style={{
        padding: '5px 10px', borderRadius: 8, fontSize: 12, cursor: 'pointer',
        background: active ? 'var(--primary)' : 'rgba(255,255,255,0.06)',
        color: active ? '#fff' : 'var(--text-muted)',
      }}
    >
      {children}
    </div>
  )
}
