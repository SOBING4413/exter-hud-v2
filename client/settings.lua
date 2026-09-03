-- Persists per-player HUD editor settings (layout positions, scale, theme,
-- visible elements) either via client KVP (default, zero setup) or by
-- delegating to the server (server/main.lua) for permanent DB storage.

local KVP_KEY = 'exterhud_v2_settings'

local function loadFromKvp()
    local raw = GetResourceKvpString(KVP_KEY)
    if not raw then return nil end
    local ok, decoded = pcall(json.decode, raw)
    return ok and decoded or nil
end

local function saveToKvp(tbl)
    SetResourceKvp(KVP_KEY, json.encode(tbl))
end

CreateThread(function()
    Wait(500)
    if Config.SaveMethod == 'kvp' then
        local saved = loadFromKvp()
        SendNUIMessage({ action = 'settings:loaded', data = saved })
    else
        TriggerServerEvent('exter-hud-v2:requestSettings')
    end
end)

RegisterNUICallback('saveSettings', function(data, cb)
    if Config.SaveMethod == 'kvp' then
        saveToKvp(data)
    else
        TriggerServerEvent('exter-hud-v2:saveSettings', data)
    end
    cb('ok')
end)

RegisterNetEvent('exter-hud-v2:receiveSettings', function(data)
    SendNUIMessage({ action = 'settings:loaded', data = data })
end)
