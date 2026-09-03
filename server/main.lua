-- Optional server-side persistence for HUD editor settings.
-- Only used when Config.SaveMethod == 'server'. Requires oxmysql (or swap
-- the two queries below for your own query library).

local function ensureTable()
    if Config.SaveMethod ~= 'server' then return end
    if not exports.oxmysql then
        print('^1[exter-hud-v2]^7 Config.SaveMethod is "server" but oxmysql was not found. Falling back to KVP client-side.')
        return
    end
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS exter_hud_settings (
            identifier VARCHAR(64) PRIMARY KEY,
            settings LONGTEXT
        )
    ]])
end

CreateThread(ensureTable)

RegisterNetEvent('exter-hud-v2:requestSettings', function()
    local src = source
    if Config.SaveMethod ~= 'server' or not exports.oxmysql then return end

    -- NOTE: replace with your framework's identifier getter server-side if needed
    local identifier = GetPlayerIdentifierByType(src, 'license')
    if not identifier then return end

    exports.oxmysql:execute('SELECT settings FROM exter_hud_settings WHERE identifier = ?', { identifier }, function(result)
        if result and result[1] then
            local ok, decoded = pcall(json.decode, result[1].settings)
            TriggerClientEvent('exter-hud-v2:receiveSettings', src, ok and decoded or nil)
        end
    end)
end)

RegisterNetEvent('exter-hud-v2:saveSettings', function(data)
    local src = source
    if Config.SaveMethod ~= 'server' or not exports.oxmysql then return end

    local identifier = GetPlayerIdentifierByType(src, 'license')
    if not identifier then return end

    exports.oxmysql:execute([[
        INSERT INTO exter_hud_settings (identifier, settings) VALUES (?, ?)
        ON DUPLICATE KEY UPDATE settings = VALUES(settings)
    ]], { identifier, json.encode(data) })
end)

-- Server-side export so other resources can push server-authoritative
-- notifications/toasts into every client's HUD.
exports('NotifyPlayer', function(playerId, message, type, duration)
    TriggerClientEvent('exter-hud-v2:notify', playerId, message, type or 'info', duration or 4000)
end)

-- Server-authoritative progress bar (fire-and-forget — the server can't wait
-- on the client's result; pair it with your own item/state check afterwards).
exports('ProgressbarPlayer', function(playerId, label, duration, options)
    TriggerClientEvent('exter-hud-v2:progressbar', playerId, label, duration, options)
end)

-- Server-authoritative alert toast.
exports('AlertPlayer', function(playerId, title, message, duration)
    TriggerClientEvent('exter-hud-v2:alert', playerId, title, message, duration)
end)

-- Server-authoritative help prompt.
exports('ShowHelpPlayer', function(playerId, text, key)
    TriggerClientEvent('exter-hud-v2:showHelp', playerId, text, key)
end)
exports('HideHelpPlayer', function(playerId)
    TriggerClientEvent('exter-hud-v2:hideHelp', playerId)
end)
