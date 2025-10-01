fx_version 'cerulean'
game 'gta5'

name 'string_removevehicle'
description 'Vehicle removal system for Qbox - Remove player vehicles from database in real-time'
author 'Stringfellow_Gaming'
version '1.0.0'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'qbx_core',
    'oxmysql'
}

lua54 'yes'