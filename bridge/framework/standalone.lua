-- Fallback provider used when no supported framework is running.
local Provider = {}

function Provider.Init() end
function Provider.IsLoaded() return true end
function Provider.GetPlayerData() return { job = { name = 'unemployed', label = 'Unemployed' } } end
function Provider.GetIdentifier() return GetPlayerServerId(PlayerId()) and tostring(GetPlayerServerId(PlayerId())) end
function Provider.OnPlayerLoaded(cb) cb() end

Framework = Framework or {}
CreateThread(function()
    Framework.Register('standalone', Provider)
end)
