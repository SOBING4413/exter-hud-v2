-- Core client loop: player vitals + environment + dynamic visibility + NUI push.
-- Only ever SendNUIMessage with data that changed (see Utils.HasChanged).

local cache = {}
local hudVisible = true
local cinematicMode = false

local function push(action, payload)
    SendNUIMessage({ action = action, data = payload })
end

-- initial boot payload: config, theme, layout, locale
CreateThread(function()
    Wait(300)
    push('boot', {
        theme = Config.Theme,
        layout = Config.DefaultLayout,
        themeName = Config.DefaultTheme,
        speedUnit = Config.SpeedUnit,
        language = Config.Language,
        safezone = Config.Safezone,
        dynamicVisibility = Config.DynamicVisibility,
        notifSettings = { position = Config.Notifications.position, maxVisible = Config.Notifications.maxVisible },
    })
end)

-------------------------------------------------------------------
-- PLAYER VITALS (health / armor) — fast-ish, event would be ideal but
-- health/armor have no reliable native event, so short interval is used.
-------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(Config.Intervals.playerVital)
        if hudVisible and not cinematicMode then
            local ped = PlayerPedId()
            local health = math.max(0, GetEntityHealth(ped) - 100)
            local armor = GetPedArmour(ped)

            if Utils.HasChanged(cache, 'health', health) then push('update:health', health) end
            if Utils.HasChanged(cache, 'armor', armor) then push('update:armor', armor) end

            -- bleeding / injury heuristic: low health flashes a warning
            local bleeding = health <= 20
            if Utils.HasChanged(cache, 'bleeding', bleeding) then push('update:bleeding', bleeding) end
        end
    end
end)

-------------------------------------------------------------------
-- NEEDS (hunger / thirst / stress / stamina / oxygen) — slow interval,
-- pulled through the Status bridge so any framework works transparently.
-------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(Config.Intervals.playerNeeds)
        if hudVisible and not cinematicMode then
            local status = Status.Get()
            for key, enabled in pairs(Config.EnabledStatus) do
                if enabled and status[key] ~= nil then
                    if Utils.HasChanged(cache, key, math.floor(status[key])) then
                        push('update:' .. key, math.floor(status[key]))
                    end
                end
            end
        end
    end
end)

-------------------------------------------------------------------
-- OXYGEN (fast, only relevant underwater) + swimming/diving/parachute state
-------------------------------------------------------------------
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local underwater = IsPedSwimmingUnderWater(ped)
        local swimming = IsPedSwimming(ped)
        local diving = underwater
        local parachuting = IsPedInParachuteFreeFall(ped) or GetPedParachuteState(ped) > 0

        if Utils.HasChanged(cache, 'underwater', underwater) then push('update:underwater', underwater) end
        if Utils.HasChanged(cache, 'swimming', swimming) then push('update:swimming', swimming) end
        if Utils.HasChanged(cache, 'diving', diving) then push('update:diving', diving) end
        if Utils.HasChanged(cache, 'parachuting', parachuting) then push('update:parachuting', parachuting) end

        if underwater then
            local remaining = GetPlayerUnderwaterTimeRemaining(PlayerId())
            if Utils.HasChanged(cache, 'oxygenSeconds', Utils.Round(remaining, 1)) then
                push('update:oxygenSeconds', Utils.Round(remaining, 1))
            end
            Wait(150)
        else
            Wait(Config.Intervals.idleWhenHudHidden)
        end
    end
end)

-------------------------------------------------------------------
-- WEAPON / AMMO (dynamic visibility: only shown while holding a weapon)
-------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(300)
        local ped = PlayerPedId()
        local weaponHash = GetSelectedPedWeapon(ped)
        local hasWeapon = weaponHash ~= GetHashKey('WEAPON_UNARMED')

        if Utils.HasChanged(cache, 'hasWeapon', hasWeapon) then push('update:hasWeapon', hasWeapon) end

        if hasWeapon then
            local ammo = GetAmmoInPedWeapon(ped, weaponHash)
            local clip = GetMaxAmmoInClip(ped, weaponHash, true)
            local weaponData = { hash = weaponHash, ammo = ammo, clip = clip }
            local weaponKey = weaponHash .. ':' .. ammo .. ':' .. clip
            if Utils.HasChanged(cache, 'weaponKey', weaponKey) then
                push('update:weapon', weaponData)
            end
        end
    end
end)

-------------------------------------------------------------------
-- VOICE / RADIO
-------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(150)
        if Voice then
            local state = Voice.GetState()
            local key = tostring(state.talking) .. state.mode .. tostring(state.radioActive) .. tostring(state.radioChannel)
            if Utils.HasChanged(cache, 'voiceKey', key) then
                push('update:voice', state)
            end
        end
    end
end)

-------------------------------------------------------------------
-- ENVIRONMENT (compass / street / zone) — cheap, moderate interval
-------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(Config.Intervals.environment)
        if hudVisible and not cinematicMode then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = Utils.Round(GetEntityHeading(ped), 0)
            local streetHash, crossHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
            local street = GetStreetNameFromHashKey(streetHash)
            local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))

            if Utils.HasChanged(cache, 'heading', heading) then push('update:heading', heading) end
            if Utils.HasChanged(cache, 'street', street) then push('update:street', street) end
            if Utils.HasChanged(cache, 'zone', zone) then push('update:zone', zone) end
        end
    end
end)

-------------------------------------------------------------------
-- PLAYER ID / MISC ONE-SHOT INFO
-------------------------------------------------------------------
CreateThread(function()
    Wait(1000)
    push('update:playerId', GetPlayerServerId(PlayerId()))
end)

-------------------------------------------------------------------
-- PAUSE MENU DETECTION (hide HUD while the pause menu / map is open)
-------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(200)
        local paused = IsPauseMenuActive()
        if Utils.HasChanged(cache, 'paused', paused) then
            push('update:paused', paused)
        end
    end
end)

-------------------------------------------------------------------
-- EXPORTS for other resources (notifications, extension API, event hooks)
-------------------------------------------------------------------
exports('SetHudVisible', function(state)
    hudVisible = state
    push('update:hudVisible', state and not cinematicMode)
end)

exports('IsHudVisible', function() return hudVisible and not cinematicMode end)

exports('Notify', function(message, type, duration)
    push('notify', { message = message, type = type or 'info', duration = duration or Config.Notifications.duration })
end)

exports('SetCinematicMode', function(state)
    cinematicMode = state
    push('update:hudVisible', hudVisible and not cinematicMode)
end)

-- Generic hook so other resources can push arbitrary custom HUD elements
exports('PushCustomElement', function(id, payload)
    push('update:custom:' .. id, payload)
end)

RegisterNUICallback('ready', function(_, cb)
    cb('ok')
end)

RegisterNetEvent('exter-hud-v2:notify', function(message, type, duration)
    push('notify', { message = message, type = type or 'info', duration = duration or 4000 })
end)

Toggles = { hudVisible = function() return hudVisible end, cinematicMode = function() return cinematicMode end,
    setHudVisible = function(v) hudVisible = v; push('update:hudVisible', hudVisible and not cinematicMode) end,
    setCinematicMode = function(v) cinematicMode = v; push('update:hudVisible', hudVisible and not cinematicMode) end }
