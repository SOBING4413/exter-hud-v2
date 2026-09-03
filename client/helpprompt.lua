-- Small "[E] Interact" style pill for contextual prompts, driven entirely
-- from other resources — this file only exposes the two exports.
--
--   exports['exter-hud-v2']:ShowHelp('Interact', 'E')
--   exports['exter-hud-v2']:HideHelp()

exports('ShowHelp', function(text, key)
    SendNUIMessage({ action = 'help:show', data = { text = text, key = key or 'E' } })
end)

exports('HideHelp', function()
    SendNUIMessage({ action = 'help:hide' })
end)

RegisterNetEvent('exter-hud-v2:showHelp', function(text, key)
    exports['exter-hud-v2']:ShowHelp(text, key)
end)

RegisterNetEvent('exter-hud-v2:hideHelp', function()
    exports['exter-hud-v2']:HideHelp()
end)
