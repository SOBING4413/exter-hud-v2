-- Blocking, cancellable progress bar. Any resource can call:
--   local finished = exports['exter-hud-v2']:Progressbar('Picking lock...', 8000, {
--       canCancel = true,
--       disableCombat = true,
--       distanceCancel = 2.0,           -- cancel if the ped moves further than this (meters)
--       animation = { dict = 'anim@heists@narcotics@trash', anim = 'action_a', flag = 1 },
--   })
--   if finished then ... end
--
-- The export yields (Wait-loop) until the bar finishes or is cancelled, then
-- returns true/false — call it from inside another Citizen thread/coroutine.

local active = false

local function push(action, payload)
    SendNUIMessage({ action = action, data = payload or {} })
end

local function run(label, duration, options)
    if active then
        Utils.Debug('progressbar', 'rejected — one is already running')
        return false
    end

    options = options or {}
    active = true

    local ped = PlayerPedId()
    local startCoords = GetEntityCoords(ped)
    local canCancel = options.canCancel
    if canCancel == nil then canCancel = Config.Progressbar.canCancel end
    local disableCombat = options.disableCombat
    if disableCombat == nil then disableCombat = Config.Progressbar.disableCombatByDefault end

    push('progress:start', {
        label = label,
        duration = duration,
        canCancel = canCancel,
    })

    local animLoaded = false
    if options.animation and options.animation.dict then
        RequestAnimDict(options.animation.dict)
        local tries = 0
        while not HasAnimDictLoaded(options.animation.dict) and tries < 100 do
            Wait(10)
            tries = tries + 1
        end
        if HasAnimDictLoaded(options.animation.dict) then
            animLoaded = true
            TaskPlayAnim(ped, options.animation.dict, options.animation.anim,
                8.0, -8.0, -1, options.animation.flag or 1, 0, false, false, false)
        end
    end

    if options.disableMovement then
        FreezeEntityPosition(ped, true)
    end

    local completed = true
    local elapsed = 0
    local step = 50

    while elapsed < duration do
        Wait(step)
        elapsed = elapsed + step

        if IsEntityDead(ped) and not options.useWhileDead then
            completed = false
            break
        end

        if disableCombat and (IsPedShooting(ped) or IsPedInMeleeCombat(ped)) then
            completed = false
            break
        end

        if options.distanceCancel and #(GetEntityCoords(ped) - startCoords) > options.distanceCancel then
            completed = false
            break
        end

        if canCancel and IsControlJustPressed(0, Config.Progressbar.cancelControl) then
            completed = false
            break
        end
    end

    if options.disableMovement then
        FreezeEntityPosition(ped, false)
    end

    if animLoaded then
        ClearPedTasks(ped)
    end

    push(completed and 'progress:finish' or 'progress:cancel')
    active = false
    return completed
end

exports('Progressbar', function(label, duration, options)
    return run(label, duration, options)
end)

exports('CancelProgressbar', function()
    if not active then return end
    push('progress:cancel')
    active = false
end)

exports('IsProgressbarActive', function()
    return active
end)

-- Fire-and-forget variant for server-triggered bars where nothing needs the
-- boolean result back (see server/main.lua -> exter-hud-v2:progressbar).
RegisterNetEvent('exter-hud-v2:progressbar', function(label, duration, options)
    run(label, duration, options)
end)
