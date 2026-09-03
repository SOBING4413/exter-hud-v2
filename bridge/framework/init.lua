-- Framework bridge: exposes a single `Framework` table with a stable API
-- (GetPlayerData, GetJob, IsLoaded, OnPlayerLoaded, GetIdentifier ...)
-- regardless of which underlying framework is running.
--
-- To add a new framework: create bridge/framework/<name>.lua returning a table
-- with the same function signatures as bridge/framework/standalone.lua,
-- then register it below in Framework.Providers.

Framework = {
    active = nil,   -- 'qbcore' | 'qbox' | 'esx' | 'standalone'
    provider = nil, -- the resolved provider table
    Providers = {},
}

function Framework.Register(name, providerTable)
    Framework.Providers[name] = providerTable
end

local function detect()
    if Config.Framework ~= 'auto' then
        return Config.Framework
    end

    for _, res in ipairs(Config.FrameworkResourceNames.qbox or {}) do
        if Utils.ResourceRunning(res) then return 'qbox' end
    end
    for _, res in ipairs(Config.FrameworkResourceNames.qbcore or {}) do
        if Utils.ResourceRunning(res) then return 'qbcore' end
    end
    for _, res in ipairs(Config.FrameworkResourceNames.esx or {}) do
        if Utils.ResourceRunning(res) then return 'esx' end
    end
    return 'standalone'
end

CreateThread(function()
    -- allow every bridge/framework/*.lua file to register itself first
    Wait(0)
    local chosen = detect()
    Framework.active = chosen
    Framework.provider = Framework.Providers[chosen] or Framework.Providers['standalone']

    if Framework.provider and Framework.provider.Init then
        Framework.provider.Init()
    end

    Utils.Debug('framework', 'active framework ->', chosen)
end)

-- Thin proxies so callers never need to know which provider is active
function Framework.IsLoaded()
    return Framework.provider and Framework.provider.IsLoaded() or false
end

function Framework.GetPlayerData()
    return Framework.provider and Framework.provider.GetPlayerData() or {}
end

function Framework.GetIdentifier()
    return Framework.provider and Framework.provider.GetIdentifier() or nil
end

function Framework.OnPlayerLoaded(cb)
    if Framework.provider and Framework.provider.OnPlayerLoaded then
        Framework.provider.OnPlayerLoaded(cb)
    else
        cb()
    end
end
