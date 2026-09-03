CreateThread(function()
    Wait(0)
    Status.Register('esx', function()
        local pd = Framework.GetPlayerData()
        return {
            hunger  = pd.hunger or 100,
            thirst  = pd.thirst or 100,
            stress  = pd.stress or 0,
            stamina = 100,
            oxygen  = 100,
        }
    end)
end)
