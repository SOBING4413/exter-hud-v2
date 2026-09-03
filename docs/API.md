# API Reference

All exports are called with the resource name `exter-hud-v2`:

```lua
exports['exter-hud-v2']:FunctionName(...)
```

Client exports must be called from **client-side** Lua; server exports from
**server-side** Lua. Calling one from the wrong side will error like any
normal FiveM export.

---

## HUD visibility

| Export | Side | Returns | Description |
|---|---|---|---|
| `SetHudVisible(state)` | client | — | Show/hide the whole HUD. |
| `IsHudVisible()` | client | `boolean` | Current visibility (accounts for cinematic mode). |
| `SetCinematicMode(state)` | client | — | Hides the HUD via a separate flag from `SetHudVisible`, so other resources can tell "player hid it" apart from "we're filming a cutscene". |
| `PushCustomElement(id, payload)` | client | — | Push an arbitrary value into the store at `custom.<id>` — use this to build your own HUD element without touching core files. |

---

## Notify

```lua
exports['exter-hud-v2']:Notify(message, type, duration)
```

| Param | Type | Default | Notes |
|---|---|---|---|
| `message` | string | — | required |
| `type` | `'info'`\|`'success'`\|`'warning'`\|`'error'` | `'info'` | controls icon + accent color |
| `duration` | number (ms) | `Config.Notifications.duration` (4000) | auto-dismiss time |

```lua
exports['exter-hud-v2']:Notify('Item added to inventory', 'success')
exports['exter-hud-v2']:Notify('You are bleeding out', 'error', 6000)
```

Server-side, to notify a specific player:

```lua
exports['exter-hud-v2']:NotifyPlayer(playerId, message, type, duration)
```

Position (`top-right` / `top-left` / `top-center` / `bottom-right` /
`bottom-left`) and the max number of stacked toasts are set once in
`Config.Notifications` in `config.lua`.

---

## Progressbar

```lua
local finished = exports['exter-hud-v2']:Progressbar(label, duration, options)
```

Blocking — call it from inside a thread/coroutine (e.g. a command handler or
`CreateThread`). Returns `true` if the bar completed, `false` if it was
cancelled.

| `options.` field | Type | Default | Notes |
|---|---|---|---|
| `canCancel` | boolean | `Config.Progressbar.canCancel` | player can cancel with the configured control (`X` by default) |
| `disableCombat` | boolean | `Config.Progressbar.disableCombatByDefault` | cancels if the player shoots or melees |
| `disableMovement` | boolean | `false` | freezes the ped for the duration |
| `distanceCancel` | number (meters) | `nil` (off) | cancels if the ped moves further than this from the start point |
| `useWhileDead` | boolean | `false` | if `false`, dying cancels the bar |
| `animation` | `{ dict, anim, flag }` | `nil` | plays a synced animation for the duration |

```lua
CreateThread(function()
    local ok = exports['exter-hud-v2']:Progressbar('Hot-wiring the car...', 12000, {
        disableMovement = true,
        animation = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', anim = 'machinic_loop_mechandplayer', flag = 1 },
    })
    if ok then
        -- start the engine
    else
        exports['exter-hud-v2']:Notify('Interrupted.', 'error')
    end
end)
```

Other exports: `CancelProgressbar()` (force-cancel from elsewhere, e.g. on
being downed) and `IsProgressbarActive()` (boolean, for guarding against
overlapping bars from your own scripts).

Server-side, fire-and-forget (no return value — pair it with your own
follow-up check, e.g. via a regular server event the client fires back):

```lua
exports['exter-hud-v2']:ProgressbarPlayer(playerId, label, duration, options)
```

---

## Alert / Confirm

```lua
exports['exter-hud-v2']:Alert(title, message, duration)
```
Fire-and-forget centered toast. `duration` defaults to `Config.Dialog.alertDuration` (3500ms).

```lua
local ok = exports['exter-hud-v2']:Confirm(title, message, options)
```
Blocking — opens NUI focus, shows a Yes/No modal, and returns `true`/`false`
once the player answers. `options`: `{ confirmLabel, cancelLabel, danger }`
(`danger = true` tints the modal and confirm button red — use for
destructive actions).

```lua
local give = exports['exter-hud-v2']:Confirm('Hand over wallet?', 'They are pointing a gun at you.', {
    confirmLabel = 'Hand it over', cancelLabel = 'Refuse', danger = true,
})
```

`Confirm` has **no server-side wrapper** — a promise can't be awaited across
the network. If the server needs the answer, trigger the client event that
calls `Confirm`, then have the client `TriggerServerEvent` back with the
boolean result.

Server-side alert:
```lua
exports['exter-hud-v2']:AlertPlayer(playerId, title, message, duration)
```

---

## Help prompt

```lua
exports['exter-hud-v2']:ShowHelp(text, key)   -- key defaults to 'E'
exports['exter-hud-v2']:HideHelp()
```

Server-side:
```lua
exports['exter-hud-v2']:ShowHelpPlayer(playerId, text, key)
exports['exter-hud-v2']:HideHelpPlayer(playerId)
```

Typical usage — call `ShowHelp` on entering a trigger zone and `HideHelp` on
leaving it, or on every frame while inside the zone and clear it once when
you exit.

---

## Events (alternative to exports)

Every client export above also has a matching net event you can
`TriggerClientEvent`/`TriggerEvent` directly, which is sometimes more
convenient from another resource's server-side code:

| Event | Args |
|---|---|
| `exter-hud-v2:notify` | `message, type, duration` |
| `exter-hud-v2:progressbar` | `label, duration, options` |
| `exter-hud-v2:alert` | `title, message, duration` |
| `exter-hud-v2:showHelp` | `text, key` |
| `exter-hud-v2:hideHelp` | — |

---

## Extending the HUD itself

See **README.md § 7** for adding brand-new HUD elements (health bars, custom
icons, etc.) via `PushCustomElement` + the zustand store — that mechanism is
unchanged in v3.
