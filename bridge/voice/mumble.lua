local talking, mode = false, 'normal'

CreateThread(function()
    Wait(0)
    Voice.Register('mumble-voip', {
        GetState = function()
            return { talking = talking, mode = mode, radioActive = false, radioChannel = nil }
        end
    })

    while true do
        Wait(200)
        if Voice.active == 'mumble-voip' then
            talking = NetworkIsPlayerTalking(PlayerId())
        end
    end
end)
