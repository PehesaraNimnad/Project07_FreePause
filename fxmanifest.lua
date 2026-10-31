fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'Project07_FreePause'
author 'Project07'
description 'Free pause menu: cinematic text-only list, no admin panel, Discord log on quit'
version '1.0.0'

dependencies { 'ox_lib', 'Project7H_Lib' }

shared_scripts {
    '@ox_lib/init.lua',
    '@Project7H_Lib/imports.lua',
    'config.lua',
}

client_script 'client/main.lua'

server_scripts {
    'sv_config.lua',
    'server/main.lua',
}

ui_page 'web/build/pause.html'

files {
    'web/build/pause.html',
    'web/build/assets/*',
}
