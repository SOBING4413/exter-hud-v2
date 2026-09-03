fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'exter-hud-v2'
author 'exter'
description 'Modern, premium, framework-agnostic HUD + interaction pack for FiveM (Progressbar, Notify, Alert/Confirm, Help prompts)'
version '3.0.0'

ui_page 'web/build/index.html'

shared_scripts {
    'config.lua',
    'shared/utils.lua',
}

client_scripts {
    'bridge/framework/*.lua',
    'bridge/fuel/*.lua',
    'bridge/voice/*.lua',
    'bridge/status/*.lua',
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

files {
    'web/build/index.html',
    'web/build/assets/*.js',
    'web/build/assets/*.css',
    'web/build/assets/*.svg',
    'locales/*.json',
}

dependencies {
    -- none hard-required; everything is optional and auto-detected at runtime
}
