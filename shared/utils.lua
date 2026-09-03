Utils = {}

function Utils.Debug(tag, ...)
    if not Config.Debug then return end
    local args = { ... }
    local parts = {}
    for i = 1, #args do parts[i] = tostring(args[i]) end
    print(('^3[exter-hud-v2]^7 [%s] %s'):format(tag, table.concat(parts, ' ')))
end

function Utils.ResourceRunning(name)
    local state = GetResourceState(name)
    return state == 'started' or state == 'starting'
end

function Utils.Round(value, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor((value or 0) * mult + 0.5) / mult
end

-- Shallow diff so we only ever SendNUIMessage with what changed
function Utils.HasChanged(cache, key, value)
    if cache[key] == nil or cache[key] ~= value then
        cache[key] = value
        return true
    end
    return false
end

function Utils.MsToKmh(ms) return ms * 3.6 end
function Utils.MsToMph(ms) return ms * 2.23694 end
