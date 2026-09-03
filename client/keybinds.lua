-- All keybinds go through RegisterKeyMapping so players can rebind them
-- from FiveM's own Settings > Key Bindings > FiveM menu.

local function toggleHud()
    Toggles.setHudVisible(not Toggles.hudVisible())
end

local function toggleCinematic()
    Toggles.setCinematicMode(not Toggles.cinematicMode())
end

local function openSettings()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openSettings' })
end

RegisterCommand(Config.Commands.toggleHud, toggleHud, false)
RegisterCommand(Config.Commands.toggleCinematic, toggleCinematic, false)
RegisterCommand(Config.Commands.openSettings, openSettings, false)

RegisterKeyMapping(Config.Commands.toggleHud, Config.Keybinds.toggleHud.description, 'keyboard', Config.Keybinds.toggleHud.key)
RegisterKeyMapping(Config.Commands.toggleCinematic, Config.Keybinds.toggleCinematic.description, 'keyboard', Config.Keybinds.toggleCinematic.key)
RegisterKeyMapping(Config.Commands.openSettings, Config.Keybinds.openSettings.description, 'keyboard', Config.Keybinds.openSettings.key)

RegisterNUICallback('closeSettings', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)
