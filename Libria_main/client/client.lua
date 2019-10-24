--------------------------------------------------------------------------------
--                                                           --
--                              Main client file                              --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                                 Variables                                  --
--------------------------------------------------------------------------------
local nbPlayersRemaining = 0 -- Printed top left
local autostartPlayersRemaining = -1 -- Players remaining to start the Battle
local alivePlayers = {} -- A table with all alive players, during a game
local isGameStarted = false -- Is game started ?
local gameEnded = false -- True during restart
local playerInLobby = true -- Is the player in the lobby ? , player in lobby means player dont play in match
local player = {} -- Local player data

--------------------------------------------------------------------------------
--                                  Events                                    --
--------------------------------------------------------------------------------
RegisterNetEvent('Libria:playerLoaded') -- Player loaded from the server
RegisterNetEvent('Libria:playerTeleportation') -- Teleportation to coordinates
RegisterNetEvent('Libria:playerTeleportationToPlayer') -- Teleportation to another player
RegisterNetEvent('Libria:playerTeleportationToMarker') -- Teleportation to the marker - NOT WORKING
RegisterNetEvent('Libria:updateAlivePlayers') -- Track the remaining players in battle
RegisterNetEvent('Libria:showNotification') -- Shows a basic notification
RegisterNetEvent('Libria:updateRemainingToStartPlayers') -- Update remaining players count to autostart the Battle
RegisterNetEvent('Libria:setHealth') -- DEBUG : sets the current health (admin only)

RegisterNetEvent('Libria:wastedScreen') -- WASTED
RegisterNetEvent('Libria:winnerScreen') -- WINNER
RegisterNetEvent('Libria:setGameStarted') -- For players joining during battle
RegisterNetEvent('Libria:startGame') -- Starts a battle
RegisterNetEvent('Libria:stopGame') -- Stops a battle
RegisterNetEvent('Libria:restartGame') -- Enable restart
RegisterNetEvent('Libria:saveCoords') -- DEBUG : saves current coords (admin only)
RegisterNetEvent('Libria:wander')
RegisterNetEvent('Libria:stopwander')
RegisterNetEvent('Libria:changeRandomModel')
RegisterNetEvent('Libria:SetForStartingGame')
RegisterNetEvent('Libria:setDebug')
RegisterNetEvent('Libria:Killself')
--------------------------------------------------------------------------------
--                                 Functions                                  --
--------------------------------------------------------------------------------
AddEventHandler('Libria:setDebug', function()
  conf.debug = true
end)

AddEventHandler('Libria:Killself', function()
  ApplyDamageToPed(PlayerPedId(), 200, true)
end)

function getIsGameStarted()
  return isGameStarted
end

function setGameStarted(gameStarted)
  isGameStarted = gameStarted
end

function getLocalPlayer()
  return player
end



function getPlayersRemaining()
  return nbPlayersRemaining
end

function getPlayersRemainingToAutostart()
  return autostartPlayersRemaining
end

function getAlivePlayers()
  return alivePlayers
end



function isPlayerInLobby()
  return playerInLobby
end

function getIsGameEnded()
  return gameEnded
end

function setGameEnded(enable)
  gameEnded = enable
end
--------------------------------------------------------------------------------
--                              Event handlers                                --
--------------------------------------------------------------------------------
AddEventHandler('onClientMapStart', function()
  exports.spawnmanager:setAutoSpawn(false)
  exports.spawnmanager:spawnPlayer()
  -- Voice proximity
  NetworkSetTalkerProximity(15.0)
  NetworkSetVoiceActive(true)
end)

AddEventHandler('Libria:playerLoaded', function(playerData)
  player = playerData

  
end)

--called when player spawned
AddEventHandler('playerSpawned', function() -- playerSpawned은 기본적으로 client_side에서 존재함 https://docs.fivem.net/resources/spawnmanager/events/playerSpawned/

  -- Disable PVP
  SetCanAttackFriendly(PlayerPedId(), false, false)
  NetworkSetFriendlyFireOption(false)
  SetEntityCanBeDamaged(PlayerPedId(), false)

  playerInLobby = true

  TriggerServerEvent('Libria:playerSpawned')
end)



--Restart 할때 server.lua에서 players 테이블 다시 채워주기 위함
AddEventHandler('onClientResourceStart', function (resourceName)
  if(GetCurrentResourceName() ~= resourceName) then
    return
  end
  TriggerServerEvent('Libria:playerSpawned')
end)

-- Updates the current number of alive (remaining) players
AddEventHandler('Libria:updateAlivePlayers', function(players)
  nbPlayersRemaining = #players
  alivePlayers = players
end)

-- Teleports the player to coords
AddEventHandler('Libria:playerTeleportation', function(coords)
  teleport(coords)
end)

-- Teleports the player to another player
AddEventHandler('Libria:playerTeleportationToPlayer', function(target)
  local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(target)))
  teleport(coords)
end)

-- Teleports the player to the marker
-- UNSTABLE
AddEventHandler('Libria:playerTeleportationToMarker', function()
  local blip = GetFirstBlipInfoId(8)
  if not DoesBlipExist(blip) then
    return
  end
  local vector = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector())
  local coords = {
    x = vector.x,
    y = vector.y,
    z = 0.0,
  }
  teleport(coords)
end)

-- Show a notification
AddEventHandler('Libria:showNotification', function(message)
  showNotification(message)
end)

AddEventHandler('Libria:updateRemainingToStartPlayers', function(playersCount)
  autostartPlayersRemaining = playersCount
end)

-- Sets current player health
AddEventHandler('Libria:setHealth', function(health)
  SetEntityHealth(GetPlayerPed(-1), tonumber(health) + 100)
end)



-- Sets the game as started, when the player join the server during a battle
AddEventHandler('Libria:setGameStarted', function()
  isGameStarted = true
end)



-- Start the battle !
AddEventHandler('Libria:startGame', function(nbAlivePlayers, spawnCoord)
  setGameEnded(false)

  print('startGame')

  nbPlayersRemaining = nbAlivePlayers

  if isPlayerInSpectatorMode() then
    SetPlayerIsSpectator(false)
  end
 
  
  local ped = GetPlayerPed(-1)
 

  player.spawn = spawnCoord
  --showNotification(' x ' .. tostring(spawnCoord.x) .. ' y ' .. tostring(spawnCoord.y) .. ' z ' .. tostring(spawnCoord.z) )


  
  -- If player is dead, resurrect him on target
  if IsPedDeadOrDying(ped, true) then
    NetworkResurrectLocalPlayer(player.spawn.x, player.spawn.y, player.spawn.z, 1, true, true, false)
  else
    -- Else teleports player
    teleport(player.spawn)
  end

  playerInLobby = false

  -- Enable PVP
  SetCanAttackFriendly(ped, true, false)
  NetworkSetFriendlyFireOption(true)
  SetEntityCanBeDamaged(ped, true)

  -- Enable drop weapon after death
  SetPedDropsWeaponsWhenDead(ped, false)



  -- Set max health
  SetPedMaxHealth(ped, conf.playerMaxHealth) 
  SetEntityHealth(ped, conf.playerMaxHealth)
  -- Set game state as started
  isGameStarted = true





  TriggerServerEvent('Libria:clientGameStarted', {
    spawn = player.spawn,
    weapon = conf.startingWeapon,
  })

 
  ResetGame()

  
  SetForStartingGame()


end)





AddEventHandler('Libria:restartGame', function()
  if not isGameStarted then
    setGameEnded(true)
  end
end)

AddEventHandler('Libria:stopGame', function(winnerName, restart)
  isGameStarted = false
  -- Disable spectator mode
  

  if winnerName then
    showNotification('~g~<C>'..winnerName..'</C>~w~ has won the match.')
  else
    showNotification('No one has won the match.')
  end

  --[[
  exports.spawnmanager:spawnPlayer(false, function()
    player.skin = changeSkin(player.skin)
  end)
  --]]
 
  ResetGame()
  
  if restart then
    setGameEnded(true)
  else
    setGameEnded(false)
  end
end)

function ResetGame()
  TriggerEvent('ews:removeAllPickups')
  ResetCountdown()
  ResetSafezone()
end




-- Saves current player's coordinates
AddEventHandler('Libria:saveCoords', function()
  Citizen.CreateThread(function()
    local coords = GetEntityCoords(GetPlayerPed(-1))
    TriggerServerEvent('Libria:saveCoords', {x = coords.x, y = coords.y, z = coords.z})
  end)
end)

AddEventHandler('Libria:changeRandomModel', function()
  
  ChangeRandomModel()

end)


AddEventHandler('Libria:wander', function()
  StartWander()
end)


AddEventHandler('Libria:stopwander', function()
  StopWandering()
end)



Citizen.CreateThread(function()
  local countdown = 0
  local playerOutOfZone = false
  local playerOOZAt = nil
  local timeDiff = 0
  local lastZoneAt = nil
  local instantDeathCountdown = 0
  local timeDiffLastZone = 0


  while true do
    Wait(0)
    if isGameStarted and not playerInLobby and not IsEntityDead(PlayerPedId()) then
      
      
      if IsSetCurrentSafezone() then

        playerOutOfZone = isPlayerOutOfZone()

        if playerOutOfZone then
          if not playerOOZAt then 
            playerOOZAt = GetGameTimer() 
            StartScreenEffect("RaceTurbo", 0, true)
          end

          timeDiff = GetTimeDifference(GetGameTimer(), playerOOZAt)
          

          if (timeDiff / 1000) > conf.safeZoneDamageTime  then

            playerOOZAt = GetGameTimer() 

            local ped = PlayerPedId()
            
            ApplyDamageToPed(ped, 10, true)
          
            PlaySoundFrontend(-1, 'TIMER', 'HUD_FRONTEND_DEFAULT_SOUNDSET')
          end
          DrawTimerBar(conf.safeZoneDamageTime - timeDiff / 1000, conf.safeZoneDamageTime, 255, 0, 0)
          --showText('Get into the ~g~safe area~w~.' .. tostring((timeDiff / 1000)), 0.5, 0.95, conf.color.white, 0, 0.5, true, true)
          
        else
          playerOOZAt = nil
          timeDiff = 0
          StopScreenEffect("RaceTurbo")
          --showText('Take out the other ~o~players~w~.', 0.5, 0.95, conf.color.white, 0, 0.5, true, true)
        end

       
      end

      
     
    else
      StopScreenEffect("RaceTurbo")
    end

    
  end
end)


function updatePlayerNames()

     --[[

  -- re-run this function the next frame
  SetTimeout(0, updatePlayerNames)

  -- return if no template string is set
  if not templateStr then
      return
  end

  -- get local coordinates to compare to
  local localCoords = GetEntityCoords(PlayerPedId())

  -- for each valid player index
  for i = 0, 255 do
      -- if the player exists
      if NetworkIsPlayerActive(i) and i ~= PlayerId() then
          -- get their ped
          local ped = GetPlayerPed(i)
          local pedCoords = GetEntityCoords(ped)

          -- make a new settings list if needed
          if not mpGamerTagSettings[i] then
              mpGamerTagSettings[i] = makeSettings()
          end

          -- check the ped, because changing player models may recreate the ped
          -- also check gamer tag activity in case the game deleted the gamer tag
          if not mpGamerTags[i] or mpGamerTags[i].ped ~= ped or not IsMpGamerTagActive(mpGamerTags[i].tag) then
              local nameTag = formatPlayerNameTag(i, templateStr)

              -- remove any existing tag
              if mpGamerTags[i] then
                  RemoveMpGamerTag(mpGamerTags[i].tag)
              end

              -- store the new tag
              mpGamerTags[i] = {
                  tag = CreateMpGamerTag(GetPlayerPed(i), nameTag, false, false, '', 0),
                  ped = ped
              }
          end

          -- store the tag in a local
          local tag = mpGamerTags[i].tag

          -- should the player be renamed? this is set by events
          if mpGamerTagSettings[i].rename then
              SetMpGamerTagName(tag, formatPlayerNameTag(i, templateStr))
              mpGamerTagSettings[i].rename = nil
          end

          -- check distance
          local distance = #(pedCoords - localCoords)


         
          -- show/hide based on nearbyness/line-of-sight
          -- nearby checks are primarily to prevent a lot of LOS checks
          if distance < 250 and HasEntityClearLosToEntity(PlayerPedId(), ped, 17) then
              SetMpGamerTagVisibility(tag, gtComponent.GAMER_NAME, true)
              SetMpGamerTagVisibility(tag, gtComponent.healthArmour, IsPlayerTargettingEntity(PlayerId(), ped))
              SetMpGamerTagVisibility(tag, gtComponent.AUDIO_ICON, NetworkIsPlayerTalking(i))

              SetMpGamerTagAlpha(tag, gtComponent.AUDIO_ICON, 255)
              SetMpGamerTagAlpha(tag, gtComponent.healthArmour, 255)

              -- override settings
              local settings = mpGamerTagSettings[i]

              for k, v in pairs(settings.toggles) do
                  SetMpGamerTagVisibility(tag, gtComponent[k], v)
              end

              for k, v in pairs(settings.alphas) do
                  SetMpGamerTagAlpha(tag, gtComponent[k], v)
              end

              for k, v in pairs(settings.colors) do
                  SetMpGamerTagColour(tag, gtComponent[k], v)
              end

              if settings.wantedLevel then
                  SetMpGamerTagWantedLevel(tag, settings.wantedLevel)
              end

              if settings.healthColor then
                  SetMpGamerTagHealthBarColour(tag, settings.healthColor)
              end
          else
              SetMpGamerTagVisibility(tag, gtComponent.GAMER_NAME, false)
              SetMpGamerTagVisibility(tag, gtComponent.healthArmour, false)
              SetMpGamerTagVisibility(tag, gtComponent.AUDIO_ICON, false)
          end
          
      elseif mpGamerTags[i] then
          RemoveMpGamerTag(mpGamerTags[i].tag)

          mpGamerTags[i] = nil
      end
  end



  --]]
end

-- run this function every frame
--SetTimeout(0, updatePlayerNames)


--AddEventHandler('Libria:SetForStartingGame', SetForStartingGame())

