local Provider = {}
local QBCore = nil

function Provider.Init()
    local ok, core = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    if ok then QBCore = core end
end

function Provider.IsLoaded()
    return QBCore ~= nil and QBCore.Functions.GetPlayerData().citizenid ~= nil
end

function Provider.GetPlayerData()
    if not QBCore then return {} end
    return QBCore.Functions.GetPlayerData()
end

function Provider.GetIdentifier()
    local pd = Provider.GetPlayerData()
    return pd and pd.citizenid
end

function Provider.OnPlayerLoaded(cb)
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', cb)
    RegisterNetEvent('QBCore:Player:SetPlayerData', function() end)
    if Provider.IsLoaded() then cb() end
end

Framework = Framework or {}
CreateThread(function()
    Framework.Register = Framework.Register or function() end
    Framework.Register('qbcore', Provider)
end)
