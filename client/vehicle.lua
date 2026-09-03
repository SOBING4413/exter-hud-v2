-- Vehicle HUD: speed, RPM, gear, fuel, engine health, doors, lights, seatbelt,
-- cruise control, handbrake, nitro (if present), harness, lock status.
-- Dynamic visibility: this whole block only pushes while the player is in a vehicle.

local cache = {}
local inVehicle = false
local seatbeltOn = false
local cruiseControlOn = false

local function push(action, payload)
    SendNUIMessage({ action = action, data = payload })
end

local function getSpeed(vehicle)
    local ms = GetEntitySpeed(vehicle)
    if Config.SpeedUnit == 'mph' then
        return Utils.Round(Utils.MsToMph(ms), 0)
    end
    return Utils.Round(Utils.MsToKmh(ms), 0)
end

-------------------------------------------------------------------
-- FAST LOOP: speed / RPM / gear — only runs while driving
-------------------------------------------------------------------
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        local nowInVehicle = vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped

        if nowInVehicle ~= inVehicle then
            inVehicle = nowInVehicle
            push('update:inVehicle', inVehicle)
            if not inVehicle then cache = {} end
        end

        if inVehicle then
            local speed = getSpeed(vehicle)
            local rpm = Utils.Round(GetVehicleCurrentRpm(vehicle), 2)
            local gear = GetVehicleCurrentGear(vehicle)
            local handbrake = GetVehicleHandbrake(vehicle)

            if Utils.HasChanged(cache, 'speed', speed) then push('update:speed', speed) end
            if Utils.HasChanged(cache, 'rpm', rpm) then push('update:rpm', rpm) end
            if Utils.HasChanged(cache, 'gear', gear) then push('update:gear', gear) end
            if Utils.HasChanged(cache, 'handbrake', handbrake) then push('update:handbrake', handbrake) end

            Wait(Config.Intervals.fastVehicle)
        else
            Wait(Config.Intervals.idleWhenHudHidden)
        end
    end
end)

-------------------------------------------------------------------
-- SLOW LOOP: fuel / engine health / doors / lights / lock / nitro
-------------------------------------------------------------------
CreateThread(function()
    while true do
        if inVehicle then
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)

            local fuel = Utils.Round(Fuel.Get(vehicle), 0)
            local engineHealth = Utils.Round(GetVehicleEngineHealth(vehicle) / 10, 0)
            local bodyHealth = Utils.Round(GetVehicleBodyHealth(vehicle) / 10, 0)
            local engineOn = GetIsVehicleEngineRunning(vehicle)
            local lightsOn = GetVehicleLightsState and select(2, GetVehicleLightsState(vehicle)) == 1
            local highBeams = IsVehicleHighbeamsOn and IsVehicleHighbeamsOn(vehicle) or false
            local locked = GetVehicleDoorLockStatus(vehicle) >= 2
            local doorsOpen, doorsKeyParts = {}, {}
            for i = 0, 5 do
                local open = GetVehicleDoorAngleRatio(vehicle, i) > 0.1
                doorsOpen[i] = open
                doorsKeyParts[#doorsKeyParts + 1] = open and '1' or '0'
            end
            -- Nitro / engine temperature aren't native GTA concepts: they're read from
            -- statebags so any nitro/engine-temp resource can feed this HUD by setting
            -- vehicle state (`Entity(vehicle).state:set('nitroEnabled', true, true)` etc).
            local hasNitro = Entity(vehicle).state.nitroEnabled or false
            local engineTemp = Entity(vehicle).state.engineTemp

            if Utils.HasChanged(cache, 'fuel', fuel) then push('update:fuel', fuel) end
            if Utils.HasChanged(cache, 'engineHealth', engineHealth) then push('update:engineHealth', engineHealth) end
            if Utils.HasChanged(cache, 'bodyHealth', bodyHealth) then push('update:bodyHealth', bodyHealth) end
            if Utils.HasChanged(cache, 'engineOn', engineOn) then push('update:engineOn', engineOn) end
            if Utils.HasChanged(cache, 'lightsOn', lightsOn) then push('update:lightsOn', lightsOn) end
            if Utils.HasChanged(cache, 'highBeams', highBeams) then push('update:highBeams', highBeams) end
            if Utils.HasChanged(cache, 'locked', locked) then push('update:locked', locked) end
            if engineTemp and Utils.HasChanged(cache, 'engineTemp', engineTemp) then push('update:engineTemp', engineTemp) end
            if Utils.HasChanged(cache, 'hasNitro', hasNitro) then push('update:hasNitro', hasNitro) end

            local doorsKey = table.concat(doorsKeyParts, '')
            if Utils.HasChanged(cache, 'doorsKey', doorsKey) then push('update:doors', doorsOpen) end

            Wait(Config.Intervals.slowVehicle)
        else
            Wait(Config.Intervals.idleWhenHudHidden)
        end
    end
end)

-------------------------------------------------------------------
-- INTERNAL SEATBELT (optional — disable in config if another resource
-- already handles seatbelts, to avoid conflicting behaviour)
-------------------------------------------------------------------
if Config.InternalSeatbelt then
    RegisterCommand('exterhud:toggleseatbelt', function()
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle == 0 then return end
        seatbeltOn = not seatbeltOn
        push('update:seatbelt', seatbeltOn)
    end, false)
    RegisterKeyMapping('exterhud:toggleseatbelt', 'Toggle seatbelt', 'keyboard', 'B')

    -- Auto-unbuckle when leaving the vehicle so state never sticks incorrectly
    CreateThread(function()
        while true do
            Wait(1000)
            if not inVehicle and seatbeltOn then
                seatbeltOn = false
                push('update:seatbelt', false)
            end
        end
    end)
end

-------------------------------------------------------------------
-- INTERNAL CRUISE CONTROL (optional, same conflict-avoidance pattern)
-------------------------------------------------------------------
if Config.InternalCruiseControl then
    RegisterCommand('exterhud:togglecruise', function()
        if not inVehicle then return end
        cruiseControlOn = not cruiseControlOn
        push('update:cruiseControl', cruiseControlOn)
    end, false)
    RegisterKeyMapping('exterhud:togglecruise', 'Toggle cruise control', 'keyboard', 'X')
end

exports('SetSeatbeltState', function(state) seatbeltOn = state; push('update:seatbelt', state) end)
exports('GetSeatbeltState', function() return seatbeltOn end)
exports('IsInVehicle', function() return inVehicle end)
