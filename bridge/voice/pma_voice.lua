local talking, mode, radioActive, radioChannel = false, 'normal', false, nil

CreateThread(function()
    Wait(0)
    Voice.Register('pma-voice', {
        GetState = function()
            return { talking = talking, mode = mode, radioActive = radioActive, radioChannel = radioChannel }
        end
    })
end)

RegisterNetEvent('pma-voice:setTalkingMode', function(m)
    mode = ({ [0] = 'muted', [1] = 'normal', [2] = 'shout', [3] = 'whisper' })[m] or 'normal'
end)

AddStateBagChangeHandler('micClicks', ('player:%s'):format(GetPlayerServerId(PlayerId())), function(_, _, value)
    talking = value ~= nil
end)

RegisterNetEvent('pma-voice:radioActive', function(active)
    radioActive = active and true or false
end)

RegisterNetEvent('pma-voice:setRadioChannel', function(channel)
    radioChannel = (channel and channel ~= 0) and channel or nil
end)
