local Provider = {}
local Qbox = nil

function Provider.Init()
    local ok, core = pcall(function()
        return exports.qbx_core
    end)
    if ok then Qbox = core end
end

function Provider.IsLoaded()
    return Qbox ~= nil
end

function Provider.GetPlayerData()
    if not Qbox then return {} end
    local ok, data = pcall(function() return Qbox:GetPlayerData() end)
    return ok and data or {}
end

function Provider.GetIdentifier()
    local pd = Provider.GetPlayerData()
    return pd and pd.citizenid
end

function Provider.OnPlayerLoaded(cb)
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', cb)
    if Provider.IsLoaded() then cb() end
end

Framework = Framework or {}
CreateThread(function()
    Framework.Register('qbox', Provider)
end)
