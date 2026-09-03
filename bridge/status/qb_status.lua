CreateThread(function()
    Wait(0)
    Status.Register('qb', function()
        local pd = Framework.GetPlayerData()
        local metadata = pd and pd.metadata or {}
        return {
            hunger  = metadata.hunger or 100,
            thirst  = metadata.thirst or 100,
            stress  = metadata.stress or 0,
            stamina = GetPlayerStamina and (GetPlayerStamina(PlayerId()) or 100) or 100,
            oxygen  = GetPlayerUnderwaterTimeRemaining and (GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10) or 100,
        }
    end)
end)
