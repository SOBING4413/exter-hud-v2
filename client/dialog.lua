-- Alert (fire-and-forget toast-style modal) and Confirm (blocking yes/no,
-- returns a boolean) dialogs, both rendered as centered NUI modals.
--
--   exports['exter-hud-v2']:Alert('Vehicle impounded', 'Pay 500$ at the pound to retrieve it.')
--
--   local ok = exports['exter-hud-v2']:Confirm('Give item?', 'Hand over the lockpick?', {
--       confirmLabel = 'Give', cancelLabel = 'Keep', danger = false,
--   })
--   if ok then ... end

local pendingResolve = nil

exports('Alert', function(title, message, duration)
    SendNUIMessage({
        action = 'dialog:alert',
        data = { title = title, message = message, duration = duration or Config.Dialog.alertDuration },
    })
end)

exports('Confirm', function(title, message, options)
    if pendingResolve then
        -- a confirm is already open; resolve it as cancelled before opening a new one
        pendingResolve(false)
        pendingResolve = nil
    end

    options = options or {}
    local p = promise.new()

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'dialog:show',
        data = {
            title = title,
            message = message,
            confirmLabel = options.confirmLabel or 'Confirm',
            cancelLabel = options.cancelLabel or 'Cancel',
            danger = options.danger or false,
        },
    })

    pendingResolve = function(result) p:resolve(result) end

    local result = Citizen.Await(p)
    SetNuiFocus(false, false)
    return result
end)

RegisterNUICallback('dialog:result', function(data, cb)
    if pendingResolve then
        pendingResolve(data and data.confirmed == true)
        pendingResolve = nil
    end
    cb('ok')
end)

RegisterNetEvent('exter-hud-v2:alert', function(title, message, duration)
    exports['exter-hud-v2']:Alert(title, message, duration)
end)
