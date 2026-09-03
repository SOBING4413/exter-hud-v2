# Changelog

## 3.0.0 — Interaction pack

**Added**
- `Progressbar` / `CancelProgressbar` / `IsProgressbarActive` client exports
  (`client/progressbar.lua`) — blocking, cancellable progress bars with
  optional animation, movement freeze, combat/death/distance cancel
  conditions. Server wrapper: `ProgressbarPlayer`.
- `Alert` / `Confirm` client exports (`client/dialog.lua`) — centered modal
  dialogs; `Confirm` blocks and resolves to a boolean via NUI callback.
  Server wrapper: `AlertPlayer`.
- `ShowHelp` / `HideHelp` client exports (`client/helpprompt.lua`) —
  contextual "`[E]` Interact" pill. Server wrappers: `ShowHelpPlayer`,
  `HideHelpPlayer`.
- New React components: `ProgressBar.jsx`, `ConfirmDialog.jsx`,
  `HelpPrompt.jsx`.
- `Config.Notifications`, `Config.Progressbar`, `Config.Dialog`,
  `Config.HelpPrompt` blocks in `config.lua`.
- `docs/API.md` — full export/event reference.

**Changed**
- `Notifications.jsx` rewritten: per-type icons, configurable stack
  position (`Config.Notifications.position`), a max-visible cap
  (`Config.Notifications.maxVisible`), and a visible countdown bar per
  toast.
- Boot payload now includes `notifSettings` so the frontend picks up the
  configured notification position/limit without a rebuild.
- `exports('Notify', ...)` now defaults its duration to
  `Config.Notifications.duration` instead of a hardcoded `4000`.

**Notes**
- No breaking changes to existing exports, events, or the NUI message
  contract — v2 integrations keep working unmodified.
- `client/*.lua` is already globbed in `fxmanifest.lua`, so the three new
  client files are picked up automatically; no manifest edit needed if
  you're diffing a custom fork.

---

## 2.0.0

- Framework-agnostic bridges (QBCore, Qbox, ESX, Standalone).
- Fuel/voice/status bridges with auto-detection.
- Vehicle HUD, voice/radio, compass, weapon/ammo, player ID.
- Drag-and-drop HUD editor with theme/layout presets.
- Basic `Notify` toast notifications.
