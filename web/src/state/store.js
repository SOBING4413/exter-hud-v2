import { create } from 'zustand'

// Sensible browser-preview defaults so `npm run dev` shows a populated HUD
// without needing a live FiveM client attached.
const initialState = {
  booted: !window.invokeNative, // true in plain-browser dev mode
  hudVisible: true,
  paused: false,

  health: 100,
  armor: 0,
  bleeding: false,

  hunger: 100,
  thirst: 100,
  stress: 0,
  stamina: 100,
  oxygen: 100,
  oxygenSeconds: null,
  underwater: false,
  swimming: false,
  diving: false,
  parachuting: false,

  hasWeapon: false,
  weapon: null,

  voice: { talking: false, mode: 'normal', radioActive: false, radioChannel: null },

  heading: 0,
  street: '',
  zone: '',
  playerId: 1,

  inVehicle: false,
  speed: 0,
  rpm: 0,
  gear: 1,
  handbrake: false,
  fuel: 100,
  engineHealth: 100,
  bodyHealth: 100,
  engineOn: false,
  lightsOn: false,
  highBeams: false,
  locked: false,
  doors: {},
  engineTemp: null,
  seatbelt: false,
  cruiseControl: false,

  notifications: [],
  notifSettings: { position: 'top-right', maxVisible: 4 },

  progress: { active: false, label: '', duration: 0, canCancel: true, key: 0 },
  dialog: { open: false, mode: null, title: '', message: '', confirmLabel: '', cancelLabel: '', danger: false },
  help: { visible: false, text: '', key: '' },

  settingsOpen: false,

  theme: {
    primaryColor: '#5B8DEF',
    dangerColor: '#EF5B5B',
    warningColor: '#F2B84B',
    successColor: '#4BD37B',
    backgroundOpacity: 0.55,
    borderRadius: 14,
    animationSpeed: 220,
  },
  themeName: 'default',
  layout: 'modern',
  speedUnit: 'kmh',
  language: 'en',
  safezone: { top: 2, right: 2, bottom: 2, left: 2 },
  dynamicVisibility: {
    ammoOnlyWithWeapon: true,
    oxygenOnlyUnderwater: true,
    vehicleHudOnlyInVehicle: true,
    radioOnlyWhenActive: true,
    hideStressIfUnused: true,
  },

  // HUD editor: per-element {x, y, scale} overrides, keyed by element id
  positions: {},
  hiddenElements: {},
  editMode: false,
}

let idCounter = 0

export const useHud = create((set, get) => ({
  ...initialState,

  applyUpdate: (action, data) => {
    if (action === 'boot') {
      set({ ...data, booted: true })
      return
    }
    if (action === 'notify') {
      const id = ++idCounter
      const duration = data.duration || 4000
      set((s) => {
        const max = s.notifSettings.maxVisible || 4
        const next = [...s.notifications, { id, duration, ...data }]
        return { notifications: next.length > max ? next.slice(next.length - max) : next }
      })
      setTimeout(() => {
        set((s) => ({ notifications: s.notifications.filter((n) => n.id !== id) }))
      }, duration)
      return
    }
    if (action === 'progress:start') {
      set((s) => ({ progress: { active: true, label: data.label, duration: data.duration, canCancel: data.canCancel !== false, key: s.progress.key + 1 } }))
      return
    }
    if (action === 'progress:finish' || action === 'progress:cancel') {
      set((s) => ({ progress: { ...s.progress, active: false } }))
      return
    }
    if (action === 'dialog:show') {
      set({ dialog: { open: true, mode: 'confirm', ...data } })
      return
    }
    if (action === 'dialog:alert') {
      const alertId = ++idCounter
      set({ dialog: { open: true, mode: 'alert', alertId, ...data } })
      setTimeout(() => {
        set((s) => (s.dialog.alertId === alertId ? { dialog: { ...s.dialog, open: false } } : {}))
      }, data.duration || 3500)
      return
    }
    if (action === 'help:show') {
      set({ help: { visible: true, text: data.text, key: data.key || 'E' } })
      return
    }
    if (action === 'help:hide') {
      set({ help: { visible: false, text: '', key: '' } })
      return
    }
    if (action === 'openSettings') {
      set({ settingsOpen: true })
      return
    }
    if (action === 'settings:loaded') {
      if (data) set({ positions: data.positions || {}, hiddenElements: data.hiddenElements || {}, themeName: data.themeName || get().themeName, layout: data.layout || get().layout, theme: data.theme || get().theme })
      return
    }
    if (action.startsWith('update:custom:')) {
      const id = action.replace('update:custom:', '')
      set((s) => ({ custom: { ...(s.custom || {}), [id]: data } }))
      return
    }
    if (action.startsWith('update:')) {
      const key = action.replace('update:', '')
      set({ [key]: data })
    }
  },

  closeSettings: () => set({ settingsOpen: false }),

  setPosition: (id, pos) => set((s) => ({ positions: { ...s.positions, [id]: { ...s.positions[id], ...pos } } })),
  toggleElement: (id) => set((s) => ({ hiddenElements: { ...s.hiddenElements, [id]: !s.hiddenElements[id] } })),
  setThemeName: (name) => set({ themeName: name }),
  setLayout: (layout) => set({ layout }),
  setThemeColor: (key, value) => set((s) => ({ theme: { ...s.theme, [key]: value } })),
  setEditMode: (v) => set({ editMode: v }),
}))
