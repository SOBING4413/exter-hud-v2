# exter-hud-v2

Modern, premium, framework-agnostic HUD **+ interaction pack** for FiveM.
Works with **QBCore**, **ESX**, **Qbox**, or no framework at all
(**Standalone**) — auto-detected at boot, or forced manually in `config.lua`.

Beyond the HUD itself (vitals, needs, vehicle cluster, voice/radio, compass,
weapon/ammo, player ID, draggable layout editor), v3 ships a full **UI/UX kit**
that other resources on your server can call into — so you're not buying a
HUD, you're buying the interaction layer for your whole server:

- **HUD** — health/armor, hunger/thirst/stress/stamina, oxygen, vehicle
  cluster, voice/radio, compass, weapon/ammo, player ID, drag-and-drop editor
- **Progressbar** — blocking, cancellable, cancel-on-combat/-death/-move,
  optional animation, usable from any resource
- **Notify** — typed toast notifications (info/success/warning/error),
  configurable position, auto-expiring with a visible countdown
- **Alert / Confirm** — centered modal dialogs; `Alert` is fire-and-forget,
  `Confirm` blocks and returns `true`/`false`
- **Help prompt** — the classic "`[E]` Interact" contextual pill
- Full theme/layout editor players can open themselves (`F7`)

See **[docs/API.md](docs/API.md)** for the complete export/event reference
and copy-pasteable snippets, and **[docs/CHANGELOG.md](docs/CHANGELOG.md)**
for version history.

---

## 1. Installation

1. Drop the `exter-hud-v2` folder into your server's `resources` directory.
2. Build the frontend once (see section 2) — the repo ships without a
   `web/build` folder, since that's a generated artifact.
3. Add to your `server.cfg`:
   ```
   ensure exter-hud-v2
   ```
4. Open `config.lua` and adjust `Config.Framework`, `Config.Fuel`,
   `Config.Voice`, `Config.Status` if auto-detection doesn't pick what you
   expect (check console with `Config.Debug = true`).

No Node.js is required on the production server — only to build the UI once
on your own machine (step 2).

---

## 2. Building the React frontend

```bash
cd exter-hud-v2/web
npm install
npm run build       # outputs to web/build — this is what fxmanifest.lua ships
```

For live UI development with hot reload in a normal browser tab (no FiveM
needed — the store ships with mock default values):

```bash
npm run dev
```

Re-run `npm run build` any time you change something under `web/src` and
restart the resource.

---

## 3. Project structure

```
exter-hud-v2/
├─ fxmanifest.lua
├─ config.lua              -- every toggle: framework, fuel, voice, status,
│                              intervals, keybinds, theme, safezone
├─ shared/utils.lua        -- debug logging, diff-based NUI push helper
├─ bridge/
│  ├─ framework/           -- qbcore.lua, qbox.lua, esx.lua, standalone.lua
│  ├─ fuel/                -- cdn_fuel.lua, ox_fuel.lua, qb_fuel.lua, legacy_fuel.lua
│  ├─ voice/               -- pma_voice.lua, mumble.lua
│  └─ status/              -- qb_status.lua, esx_status.lua, standalone_status.lua
├─ client/
│  ├─ main.lua             -- vitals, needs, oxygen, weapon/ammo, voice, compass, exports
│  ├─ vehicle.lua          -- speed/RPM/gear/fuel/engine/lights/doors, internal seatbelt/cruise
│  ├─ keybinds.lua         -- RegisterKeyMapping-based binds (rebindable in FiveM settings)
│  ├─ settings.lua         -- KVP or server-side settings persistence
│  ├─ progressbar.lua      -- Progressbar / CancelProgressbar / IsProgressbarActive exports
│  ├─ dialog.lua           -- Alert / Confirm exports (modal dialogs)
│  └─ helpprompt.lua       -- ShowHelp / HideHelp exports ("[E] Interact" pill)
├─ server/main.lua         -- oxmysql-backed settings storage + NotifyPlayer /
│                              ProgressbarPlayer / AlertPlayer / ShowHelpPlayer exports
├─ locales/en.json         -- UI strings (add more languages here)
├─ docs/
│  ├─ API.md               -- full export/event reference with copy-paste snippets
│  └─ CHANGELOG.md
└─ web/                    -- React + Vite NUI frontend
   └─ src/
      ├─ state/store.js    -- zustand store, single source of truth for the UI
      ├─ hooks/useNuiEvent.js
      └─ components/       -- VitalsCluster, VehicleHud, VoiceRadio, Compass, WeaponAmmo,
                              PlayerId, Notifications, ProgressBar, ConfirmDialog,
                              HelpPrompt, SettingsPanel, Draggable
```

Every Lua file is scoped to one concern on purpose — nothing lives in one giant
file, so you can find (and safely change) exactly the piece you need.

---

## 4. Choosing a framework / integration manually

Auto-detection lives in `bridge/framework/init.lua`, `bridge/fuel/init.lua`,
`bridge/voice/init.lua`, and `bridge/status/init.lua`. To force a specific
choice instead of `'auto'`, edit `config.lua`:

```lua
Config.Framework = 'qbcore'   -- or 'qbox' | 'esx' | 'standalone'
Config.Fuel      = 'ox_fuel'  -- or 'cdn-fuel' | 'qb-fuel' | 'LegacyFuel' | 'custom' | 'none'
Config.Voice     = 'pma-voice' -- or 'mumble-voip' | 'none'
Config.Status    = 'qb'        -- or 'esx' | 'standalone'
```

Set `Config.Debug = true` to print which provider was resolved for each
bridge on resource start.

---

## 5. Adding a new fuel integration

1. Create `bridge/fuel/my_fuel.lua`:
   ```lua
   CreateThread(function()
       Wait(0)
       Fuel.Register('my-fuel-resource', function(vehicle)
           return exports['my-fuel-resource']:GetFuel(vehicle)
       end)
   end)
   ```
2. Add it to `fxmanifest.lua`'s `client_scripts` (already covered by the
   `bridge/fuel/*.lua` glob — no edit needed if you keep it in that folder).
3. Add its resource name to `Config.FuelResourceNames` in `config.lua` so
   `'auto'` can find it, or set `Config.Fuel = 'my-fuel-resource'` directly.

For a fully custom in-house fuel system with no dedicated resource, set
`Config.Fuel = 'custom'` and implement `Config.CustomFuel.getFuel(vehicle)`
in `config.lua` — no bridge file needed.

---

## 6. Adding a new status (needs) provider

1. Create `bridge/status/my_status.lua`:
   ```lua
   CreateThread(function()
       Wait(0)
       Status.Register('my-status', function()
           return { hunger = ..., thirst = ..., stress = ..., stamina = ..., oxygen = ... }
       end)
   end)
   ```
2. Set `Config.Status = 'my-status'` (status has no resource-name auto-detect
   by default — extend `bridge/status/init.lua`'s `detect()` if you want it
   picked automatically).

---

## 7. Adding a new HUD element / icon

The Lua side and the React side are decoupled by `SendNUIMessage({ action, data })`
messages, all funneled into one zustand store key (see `applyUpdate` in
`web/src/state/store.js`):

1. **Lua**: push your value with `push('update:myThing', value)` from any
   client script (or use the generic hook: `exports['exter-hud-v2']:PushCustomElement('myThing', value)`
   from another resource entirely — no core file edits required).
2. **React**: read it anywhere with `useHud((s) => s.myThing)` and render an
   icon/panel. Wrap it in `<Draggable id="myThing">` to make it repositionable
   in the HUD editor for free, and add an entry to the `ELEMENTS` array in
   `SettingsPanel.jsx` so players can show/hide it.

Icons come from [`lucide-react`](https://lucide.dev) — already a project
dependency, so `import { IconName } from 'lucide-react'` is all you need.

---

## 8. Interaction pack (Progressbar, Notify, Alert/Confirm, Help prompt)

These are called the same way from **any** resource on your server — the HUD
doesn't need to be the resource doing the calling. Full reference with more
options in **[docs/API.md](docs/API.md)**.

```lua
-- Progressbar — blocking, returns true if it finished, false if cancelled
local finished = exports['exter-hud-v2']:Progressbar('Picking the lock...', 8000, {
    canCancel = true,
    disableCombat = true,
    distanceCancel = 2.0,
})
if finished then
    -- give the item / open the door / etc.
end

-- Notify — typed toast
exports['exter-hud-v2']:Notify('Lockpick broke.', 'error')

-- Alert — fire-and-forget modal
exports['exter-hud-v2']:Alert('Vehicle impounded', 'Pay 500$ at the pound to retrieve it.')

-- Confirm — blocking modal, returns true/false
local ok = exports['exter-hud-v2']:Confirm('Give item?', 'Hand over the lockpick?', { danger = true })

-- Help prompt
exports['exter-hud-v2']:ShowHelp('Interact', 'E')
exports['exter-hud-v2']:HideHelp()
```

Server-side equivalents (`NotifyPlayer`, `ProgressbarPlayer`, `AlertPlayer`,
`ShowHelpPlayer`/`HideHelpPlayer`) exist for when the action needs to be
server-authoritative — see `server/main.lua`. `Confirm` has no server
wrapper on purpose: a promise can't cross the network boundary, so gate the
server action on the client's boolean result instead (send it back over a
regular `TriggerServerEvent`).

Notification position/limit and dialog timing are configurable in
`config.lua` under `Config.Notifications`, `Config.Progressbar`, and
`Config.Dialog`.

---

## 9. Performance notes

- Every value pushed to NUI passes through `Utils.HasChanged` (Lua) — nothing
  is sent unless it actually changed.
- Fast-changing vehicle data (speed/RPM/gear) only runs while you're in a
  vehicle, on `Config.Intervals.fastVehicle` (default 100ms); everything else
  backs off to `Config.Intervals.idleWhenHudHidden` when not applicable.
- Hunger/thirst/stress use the slower `Config.Intervals.playerNeeds` interval
  since they rarely need sub-second precision.

---

## 10. Cinematic mode & settings menu

- `/hud` (default `F9`) — toggle the whole HUD.
- `/cinematic` (default `F10`) — toggle cinematic mode (also hides the HUD;
  kept as a separate flag so other resources can distinguish "player hid it"
  from "we're filming a cutscene").
- `/hudsettings` (default `F7`) — opens the in-game HUD editor: layout,
  theme, per-element colors, show/hide toggles, and drag-to-reposition.

All three keybinds are registered through `RegisterKeyMapping`, so players
can rebind them from **Settings → Key Bindings → FiveM** without touching
config.

---

## 11. Known extension points left as-is on purpose

- `Config.SaveMethod = 'server'` persistence assumes **oxmysql**; swap the
  two queries in `server/main.lua` for your own query library if needed.
- Nitro / engine-temperature indicators read from vehicle statebags
  (`Entity(vehicle).state.nitroEnabled` / `.engineTemp`) so any resource that
  sets those state values is picked up automatically with zero HUD-side
  configuration.
