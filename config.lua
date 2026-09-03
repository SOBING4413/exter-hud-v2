Config = {}

-------------------------------------------------------------------
-- GENERAL
-------------------------------------------------------------------
Config.Debug          = false          -- verbose console output for integration detection
Config.DefaultLayout  = 'modern'       -- 'minimal' | 'modern' | 'compact' | 'classic' | 'dynamic'
Config.DefaultTheme   = 'default'      -- 'default' | 'dark' | 'light' | 'transparent' | 'neon' | custom key
Config.SaveMethod     = 'kvp'          -- 'kvp' | 'server'  (server = database via server/main.lua)
Config.SpeedUnit      = 'kmh'          -- 'kmh' | 'mph'
Config.Language       = 'en'           -- key of a file in locales/

-------------------------------------------------------------------
-- FRAMEWORK
-------------------------------------------------------------------
-- 'auto' scans running resources and picks the right bridge.
-- Force a value if auto-detection picks the wrong one.
Config.Framework = 'auto'              -- 'auto' | 'qbcore' | 'qbox' | 'esx' | 'standalone'

Config.FrameworkResourceNames = {
    qbcore = { 'qb-core' },
    qbox   = { 'qbx_core' },
    esx    = { 'es_extended' },
}

-------------------------------------------------------------------
-- FUEL BRIDGE
-------------------------------------------------------------------
-- 'auto' detects the first running resource from FuelResourceNames.
-- Set explicitly, or 'custom' to use Config.CustomFuel below.
Config.Fuel = 'auto'                   -- 'auto' | 'cdn-fuel' | 'ox_fuel' | 'qb-fuel' | 'LegacyFuel' | 'custom' | 'none'

Config.FuelResourceNames = {
    ['cdn-fuel']  = 'cdn-fuel',
    ['ox_fuel']   = 'ox_fuel',
    ['qb-fuel']   = 'qb-fuel',
    ['LegacyFuel'] = 'LegacyFuel',
}

-- Used only when Config.Fuel == 'custom'. Must return a number 0-100.
Config.CustomFuel = {
    getFuel = function(vehicle)
        return GetVehicleFuelLevel(vehicle)
    end,
}

-------------------------------------------------------------------
-- VOICE BRIDGE
-------------------------------------------------------------------
Config.Voice = 'auto'                  -- 'auto' | 'pma-voice' | 'mumble-voip' | 'none'
Config.VoiceResourceNames = {
    ['pma-voice']  = 'pma-voice',
    ['mumble-voip'] = 'mumble-voip',
}

-------------------------------------------------------------------
-- STATUS BRIDGE (hunger / thirst / stress / etc.)
-------------------------------------------------------------------
Config.Status = 'auto'                 -- 'auto' | 'qb' | 'esx' | 'standalone' | 'none'
Config.EnabledStatus = {
    hunger  = true,
    thirst  = true,
    stress  = true,
    stamina = true,
    oxygen  = true,
}

-------------------------------------------------------------------
-- INTERNAL VEHICLE FEATURE TOGGLES
-- Turn OFF anything already handled by another resource on your server.
-------------------------------------------------------------------
Config.InternalSeatbelt     = true
Config.InternalCruiseControl = true

-------------------------------------------------------------------
-- UPDATE INTERVALS (ms) — tune for performance
-------------------------------------------------------------------
Config.Intervals = {
    fastVehicle   = 100,   -- speed / RPM / gear while driving
    slowVehicle   = 1000,  -- fuel / engine health / doors while driving
    playerVital   = 500,   -- health / armor
    playerNeeds   = 3000,  -- hunger / thirst / stress
    environment   = 1000,  -- compass / street / zone
    idleWhenHudHidden = 2000,
}

-------------------------------------------------------------------
-- KEYBINDS (registered via RegisterKeyMapping — rebindable in F8 > Key Bindings > FiveM)
-------------------------------------------------------------------
Config.Keybinds = {
    toggleHud      = { key = 'F9',  description = 'Toggle HUD visibility' },
    toggleCinematic = { key = 'F10', description = 'Toggle cinematic mode' },
    openSettings   = { key = 'F7',  description = 'Open HUD settings / editor' },
}

Config.Commands = {
    toggleHud      = 'hud',
    toggleCinematic = 'cinematic',
    openSettings   = 'hudsettings',
}

-------------------------------------------------------------------
-- DYNAMIC VISIBILITY RULES
-------------------------------------------------------------------
Config.DynamicVisibility = {
    ammoOnlyWithWeapon   = true,
    oxygenOnlyUnderwater = true,
    vehicleHudOnlyInVehicle = true,
    radioOnlyWhenActive  = true,
    hideStressIfUnused   = true,
}

-------------------------------------------------------------------
-- THEME / COLOR DEFAULTS (sent to NUI on load; editable live from the HUD editor)
-------------------------------------------------------------------
Config.Theme = {
    primaryColor    = '#5B8DEF',
    dangerColor     = '#EF5B5B',
    warningColor    = '#F2B84B',
    successColor    = '#4BD37B',
    backgroundOpacity = 0.55,
    borderRadius    = 14,
    animationSpeed  = 220, -- ms
}

-------------------------------------------------------------------
-- SAFEZONE
-------------------------------------------------------------------
Config.Safezone = {
    top = 2, right = 2, bottom = 2, left = 2, -- percent
}

-------------------------------------------------------------------
-- NOTIFICATIONS
-------------------------------------------------------------------
Config.Notifications = {
    position    = 'top-right', -- 'top-right' | 'top-left' | 'bottom-right' | 'bottom-left' | 'top-center'
    maxVisible  = 4,           -- older ones are dropped once this many are on screen
    duration    = 4000,        -- default ms if a call doesn't specify one
}

-------------------------------------------------------------------
-- PROGRESSBAR
-------------------------------------------------------------------
Config.Progressbar = {
    position       = 'bottom-center', -- 'bottom-center' | 'bottom-left' | 'bottom-right'
    canCancel      = true,            -- allow the [X] control to cancel by default
    cancelControl  = 73,               -- INPUT_VEH_EXIT (X) — remap to any control id
    disableCombatByDefault = true,
}

-------------------------------------------------------------------
-- DIALOGS (Alert / Confirm)
-------------------------------------------------------------------
Config.Dialog = {
    alertDuration = 3500,
}

-------------------------------------------------------------------
-- HELP PROMPT (contextual "[E] Interact" pill)
-------------------------------------------------------------------
Config.HelpPrompt = {
    position = 'bottom-center',
}
