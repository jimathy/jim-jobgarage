name "Jim-JobGarage"
author "Jimathy"
version "1.4.4"
description "Job Garage Script By Jimathy"
fx_version "cerulean"
game "gta5"
lua54 'yes'

shared_scripts { 'config.lua', 'functions.lua', 'locales/*.lua' }
client_scripts { 'client.lua', }
server_scripts { 'server.lua', }

-- shared_scripts({ -- remove this if you are not using ESX
--     "@es_extended/imports.lua",
--     "@es_extended/locale.lua",
-- })
