local Provider = {}
local ESX = nil

function Provider.Init()
    local ok = pcall(function()
        ESX = exports['es_extended']:getSharedObject()
    end)
    if not ok then
        -- older ESX exposes it through an event instead of an export
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
end

function Provider.IsLoaded()
    return ESX ~= nil and ESX.IsPlayerLoaded and ESX.IsPlayerLoaded()
end

function Provider.GetPlayerData()
    if not ESX then return {} end
    return ESX.GetPlayerData()
end

function Provider.GetIdentifier()
    local pd = Provider.GetPlayerData()
    return pd and pd.identifier
end

function Provider.OnPlayerLoaded(cb)
    RegisterNetEvent('esx:playerLoaded', cb)
    if Provider.IsLoaded() then cb() end
end

Framework = Framework or {}
CreateThread(function()
    Framework.Register('esx', Provider)
end)
