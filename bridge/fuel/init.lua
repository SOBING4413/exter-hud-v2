-- Fuel bridge: exposes Fuel.Get(vehicle) -> number 0-100
-- Add a new fuel resource by registering it below (see cdn_fuel.lua for the pattern).

Fuel = {
    active = nil,
    Providers = {},
}

function Fuel.Register(name, getFn)
    Fuel.Providers[name] = getFn
end

local function detect()
    if Config.Fuel ~= 'auto' then return Config.Fuel end

    for key, resourceName in pairs(Config.FuelResourceNames) do
        if Utils.ResourceRunning(resourceName) then
            return key
        end
    end
    return 'native' -- GetVehicleFuelLevel fallback, always available
end

CreateThread(function()
    Wait(0)
    Fuel.active = detect()
    Utils.Debug('fuel', 'active fuel provider ->', Fuel.active)
end)

function Fuel.Get(vehicle)
    if not vehicle or vehicle == 0 then return 0 end

    if Fuel.active == 'custom' and Config.CustomFuel and Config.CustomFuel.getFuel then
        local ok, val = pcall(Config.CustomFuel.getFuel, vehicle)
        if ok and val then return val end
    end

    if Fuel.active == 'none' then return 100 end

    local provider = Fuel.Providers[Fuel.active]
    if provider then
        local ok, val = pcall(provider, vehicle)
        if ok and val then return val end
    end

    -- native fallback, never errors out the HUD
    return GetVehicleFuelLevel(vehicle) or 0
end
