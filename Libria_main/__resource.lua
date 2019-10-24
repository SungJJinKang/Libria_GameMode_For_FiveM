resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

--set gametype name
resource_type 'gametype' { name = 'Libria' }

description 'Libria'

--[[ dependencies {
  -- 'loadingscreen', -- DO NOT PUT A LOADING SCREEN HERE
  -- 'br_spawner', -- DO NOT PUT A MAP RESOURCE HERE
-- } ]]

dependency 'mysql-async'

server_script '@mysql-async/lib/MySQL.lua'

server_scripts {
  'server/config.lua',
  'server/pickups.lua',
  'lib/mapData.lua',
  'lib/functions_shared.lua',
  'lib/functions_server.lua',
  'classes/player.lua',
  'server/commands.lua',
  'server/server.lua',
 
}

export 'getIsGameStarted'
export 'isPlayerInLobby'
export 'isPlayerInSpectatorMode'
export 'showHelp'
export 'drawInstructionalButtons'
export 'addCommand'

client_scripts {
  'client/config.lua',
  'lib/npc_models.lua',
  'lib/functions_shared.lua',
  'lib/functions_client.lua',
  'client/client.lua',
  'client/threads.lua',
  'client/screens.lua',
  'client/spectator.lua',
  'client/spectatorMyPedWillControll.lua',
  'classes/pickupzone.lua',
  'lib/Enumerate.lua',
  'client/safezone.lua'
}
