-- Purely native-game values, used when no framework status system is present.
CreateThread(function()
    Wait(0)
    Status.Register('standalone', function()
        local ped = PlayerPedId()
        return {
            hunger  = 100,
            thirst  = 100,
            stress  = 0,
            stamina = GetPlayerSprintStaminaRemaining and GetPlayerSprintStaminaRemaining(PlayerId()) or 100,
            oxygen  = IsPedSwimmingUnderWater(ped) and math.max(0, 100 - (GetPlayerUnderwaterTimeRemaining(PlayerId()) or 0) * 10) or 100,
        }
    end)
end)
