-- Status bridge: exposes Status.Get() -> { hunger, thirst, stress, stamina, oxygen }
-- Values are expected 0-100. Add a new provider by registering it below.

Status = {
    active = nil,
    Providers = {},
}

function Status.Register(name, getFn)
    Status.Providers[name] = getFn
end

local function detect()
    if Config.Status ~= 'auto' then return Config.Status end

    if Framework and Framework.active == 'qbcore' or Framework.active == 'qbox' then
        return 'qb'
    elseif Framework and Framework.active == 'esx' then
        return 'esx'
    end
    return 'standalone'
end

CreateThread(function()
    Wait(500) -- allow Framework bridge to resolve first
    Status.active = detect()
    Utils.Debug('status', 'active status provider ->', Status.active)
end)

function Status.Get()
    local provider = Status.Providers[Status.active]
    if provider then
        local ok, val = pcall(provider)
        if ok and val then return val end
    end
    return { hunger = 100, thirst = 100, stress = 0, stamina = 100, oxygen = 100 }
end
