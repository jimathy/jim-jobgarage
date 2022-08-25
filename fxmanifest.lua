name "Jim-JobGarage"
author "Jimathy"
version "v1.2"
description "Job Garage Script By Jimathy"
fx_version "cerulean"
game "gta5"

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
	'client.lua',
}

server_scripts { 'server.lua', }
shared_scripts { 'config.lua', 'functions.lua' }

lua54 'yes'
