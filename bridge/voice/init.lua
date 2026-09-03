-- Voice bridge: exposes Voice.GetState() -> { talking, mode, radioActive, radioChannel }

Voice = {
    active = nil,
    Providers = {},
}

function Voice.Register(name, providerTable)
    Voice.Providers[name] = providerTable
end

local function detect()
    if Config.Voice ~= 'auto' then return Config.Voice end
    for key, resourceName in pairs(Config.VoiceResourceNames) do
        if Utils.ResourceRunning(resourceName) then return key end
    end
    return 'none'
end

CreateThread(function()
    Wait(0)
    Voice.active = detect()
    Utils.Debug('voice', 'active voice provider ->', Voice.active)
end)

function Voice.GetState()
    local provider = Voice.Providers[Voice.active]
    if not provider then
        return { talking = false, mode = 'normal', radioActive = false, radioChannel = nil }
    end
    local ok, state = pcall(provider.GetState)
    if ok and state then return state end
    return { talking = false, mode = 'normal', radioActive = false, radioChannel = nil }
end
