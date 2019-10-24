--------------------------------------------------------------------------------
--                                   Libria                              --
--                              Main server file                              --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                                 Variables                                  --
--------------------------------------------------------------------------------

local players = {}
local safeZones = {}
local isGameStarted = false
local nbAlivePlayers = 0
local gameId = 0
local sqlDateFormat = '%Y-%m-%d %H:%M:%S'
local currentSafezoneIndex = 1
--------------------------------------------------------------------------------
--                                  Events                                    --
--------------------------------------------------------------------------------

RegisterServerEvent('Libria:playerSpawned')
RegisterServerEvent('Libria:saveCoords')
RegisterServerEvent('Libria:dropPlayer')
RegisterServerEvent('Libria:playerLoaded')
RegisterServerEvent('Libria:playerDied')
RegisterServerEvent('Libria:skinChanged')
--RegisterServerEvent('Libria:showScoreboard')
RegisterServerEvent('Libria:startGame')
RegisterServerEvent('Libria:stopGame')
RegisterServerEvent('Libria:stopGameClients')
RegisterServerEvent('Libria:clientGameStarted')
RegisterServerEvent('baseevents:onPlayerDied')
RegisterServerEvent('baseevents:onPlayerKilled')

--------------------------------------------------------------------------------
--                            Global functions                                --
--------------------------------------------------------------------------------

-- Loads a player from database, based on the source
-- add player to players local table
-- call by Libria:playerSpawned event(server.lua)
function loadPlayer(source)
  if players[source] == nil then
    local steamId = GetPlayerIdentifiers(source)[1]

    MySQL.Async.fetchAll('SELECT * FROM players WHERE steamid=@steamid LIMIT 1', {['@steamid'] = steamId}, function(playersDB) -- , 'status,eq,1'
      local player = playersDB[1]
      if player ~= nil then
        if player.status == 0 then
          print('Dropping player, banned : ' .. steamId .. ' (' .. source .. ')')
          TriggerEvent('Libria:dropPlayer', source, 'You are permanently banned from this server.')
          return
        end
        players[source] = Player.new(player.id, steamId, player.name, player.role, player.skin, source)
        -- TODO : Put this in the Player class
        players[source].rank = 0
        players[source].kills = 0
        players[source].spawn = {}
        players[source].weapon = ''

        TriggerEvent('Libria:playerLoaded', source, players[source])
        MySQL.Async.execute('UPDATE players SET last_login=@last_login WHERE id=@id', {['@last_login'] = os.date(sqlDateFormat), ['@id'] = player.id})
      else
          -- Insert data in DB and load player
          MySQL.Async.execute('INSERT INTO players (steamid, role, name, created, last_login, status) VALUES (@steamid, @role, @name, @created, @last_login, @status)',
            {['@steamid'] = steamId, ['@role'] = 'player', ['@name'] = GetPlayerName(source), ['@created'] = os.date(sqlDateFormat), ['@last_login'] = os.date(sqlDateFormat), ['@status'] = 1}, function()
              MySQL.Async.fetchScalar('SELECT id FROM players WHERE steamid=@steamid', {['@steamid'] = steamId}, function(id)
                players[source] = Player.new(id, steamId, GetPlayerName(source), 'player', '', source)
                players[source].rank = 0
                players[source].kills = 0
                players[source].spawn = {}
                players[source].weapon = ''

                TriggerEvent('Libria:playerLoaded', source, players[source])
              end)
          end)
      end

    end)
  end
end


-- Expose all connected players
function getPlayers()
  return players
end

-- Returns a Player object based on the source if it exists
-- false otherwise
function getPlayer(source)
  if players[source] ~= nil then
    return players[source]
  end

  return false
end


--remove disconnected player from players table
function removePlayer(source, reason)
  if players[source] ~= nil then
    -- Player dropped during a game
    if isGameStarted and players[source].alive then
      players[source].alive = false
      nbAlivePlayers = nbAlivePlayers - 1

      updateAlivePlayers(-1)
      if nbAlivePlayers == 1 then
        TriggerEvent('Libria:stopGame', true, false)
      end
    end

    sendSystemMessage(-1, players[source].name ..' left (' .. reason .. ')')

    players[source] = nil

    local nbPlayers = count(getPlayers())
    TriggerClientEvent('Libria:updateRemainingToStartPlayers', -1, math.max(conf.autostart - nbPlayers, 0))

    if nbPlayers == 0 then
      if isGameStarted then
          TriggerEvent('Libria:stopGame', false, true)
      end
      -- no more players on server, reset some stuff ?
    end
  end
end

-- Returns a player's name based on the source if it exists
-- 'no one' otherwise
function getPlayerName(source)
  local player = getPlayer(source)
  if player then
    return player.name
  end
  return 'no one'
end

function getPlayerWithName(name)

  for _, player in pairs(players) do
    if player.name == name then
      return player
    end
  end

  return nil

end

-- Returns a table containing all alive players
function getAlivePlayers()
  local alivePlayers = {}
  local index = 1

  for i, player in pairs(players) do
    if player.alive then
      alivePlayers[index] = player
      index = index +1
    end
  end

  return alivePlayers
end


-- isGameStarted ?
function getIsGameStarted()
  return isGameStarted
end

-- Update all clients with the new number of alive players
function updateAlivePlayers(source)
  local alivePlayers = {}
  local i = 1
  for k,v in pairs(players) do
    if v.alive then
      alivePlayers[i] = { -- index of alivePlayers is integer
        id = v.id,
        name = v.name,
        source = v.source,
      }
      i = i + 1
    end
  end
  TriggerClientEvent('Libria:updateAlivePlayers', source, alivePlayers) --send to dlient side
end

Citizen.CreateThread(function()
  math.randomseed(os.time())
end)

-- called by playerSpawned (client.lua)
AddEventHandler('Libria:playerSpawned', function()
  if not players[source] then
    loadPlayer(source)

    --TriggerClientEvent('Libria:setCurrentSafezone', source, ...)
  end
end)


function reload()
  -- body
  local players = GetPlayers()

  for i, v in pairs(players) do

    if(v ~= nil) then
      
      sendSystemMessage(-1, v)
    loadPlayer(v)
    end

  end

end

AddEventHandler('Libria:saveCoords', function(coords)
  MySQL.Async.execute('INSERT INTO coords (x, y, z) VALUES (@x, @y, @z)', {['@x'] = coords.x, ['@y'] = coords.y, ['@z'] = coords.z})
end)

AddEventHandler('Libria:getPlayerData', function(source, event, data)
  if players[source] ~= nil then
    local playerData = {
      id = players[source].id,
      name = players[source].name,
      source = players[source].source,
      rank = players[source].rank,
      kills = players[source].kills,
      skin = players[source].skin,
      admin = players[source]:isAdmin(),
    }
    TriggerEvent(event, playerData, data)
  end
end)
--[[
AddEventHandler('Libria:showScoreboard', function()
  local playersData = {}
  local globalData = {}

  for k,v in pairs(players) do
    if v.rank == nil then v.rank = 0 end
    if v.kills == nil then v.kills = 0 end

    playersData[k] = {
      name = v.name,
      source = v.source,
      rank = v.rank,
      kills = v.kills,
      admin = v:isAdmin(),
    }
  end

  MySQL.Async.fetchAll('SELECT players.name, SUM(players_stats.kills) AS \'kills\', COUNT(players_stats.gid) AS \'games\', game_stats.wins FROM players, players_stats, ( SELECT players.id AS id, COUNT(games.wid) AS wins FROM players, games WHERE players.id = games.wid GROUP BY players.id) AS game_stats WHERE players.id = players_stats.pid AND players.id = game_stats.id GROUP BY players.id ORDER BY wins DESC, kills DESC, games DESC LIMIT 10;', { }, function(globalData)
    TriggerClientEvent('Libria:showScoreboard', source, {players = playersData, global = globalData})
      end)
end)
--]]

--call by loadPlayer
AddEventHandler('Libria:playerLoaded', function(source, player)
  TriggerClientEvent('Libria:playerLoaded', source, {id = player.id, name = player.name, skin = player.skin, source = player.source})
  sendSystemMessage(-1, player.name .. ' joined.')
  TriggerEvent('chatMessage', source, player.name, '/help')

  if not isGameStarted then
    --if game dont start yet 

    local nbPlayers = count(getPlayers())
    if nbPlayers == conf.autostart or conf.debug then
      --restart game, meet requirment for starting game
      TriggerClientEvent('Libria:restartGame', -1)
    else
      TriggerClientEvent('Libria:updateRemainingToStartPlayers', -1, math.max(conf.autostart - nbPlayers, 0))
    end
  else
    --already game started
    --newly connected  player will spectate game
    updateAlivePlayers(source)
    TriggerClientEvent('Libria:setGameStarted', source)
  end

end)

AddEventHandler('Libria:skinChanged', function(newSkin)
  local player = getPlayer(source)
  player.skin = newSkin
end)


function TestSafeZone()
  -- body
  local md = mapData[1]
  safeZonesCoord = {
    
      x = md.zoneCoordX,
      y = md.zoneCoordY,
      z = md.zoneCoordZ,
      radius = md.zoneRadius
    


  }
  TriggerClientEvent('Libria:TestSafeZone', -1, safeZonesCoord)
end


--------------------------------------------------------------------------------
--                                START GAME                                  --

-- Auto restart Thread ( threads.lua )
-- -> Libria:startgame (server.lua)
-- -> Libria:startGame (client.lua) 

--------------------------------------------------------------------------------
AddEventHandler('Libria:startGame', function()
  if isGameStarted and conf.debug == false then return end

  print('StartGame')

  isGameStarted = true

  -- Generate first (smallest) safe zone
  local md = GetRandomMapData()

  table_clear(safeZones)

  table.insert( safeZones, 
    {
      x = md.zoneCoordX,
      y = md.zoneCoordY,
      z = md.zoneCoordZ,
      radius = md.zoneRadius
    }
  )

  
  
  --for i = 1, safeZones[i].radius - conf.decreasedRadius <= 20, 1 do

  local i = 1

  while safeZones[i].radius - conf.decreasedRadius >= conf.minRadius do

    local newCoord = GetRandomPointInCircle(safeZones[i], conf.decreasedRadius)

    table.insert( safeZones, 
    {
      
      radius = safeZones[i].radius - conf.decreasedRadius,
      x = newCoord.x, -- (math.random(previousRadius - (20 * i)) * (round(math.random()) * 2 - 1)),
      y = newCoord.y, -- (math.random(previousRadius - (20 * i)) * (round(math.random()) * 2 - 1)),
      z = newCoord.z,
      
    }
    )

    i = i + 1
  end
  --)


  -- Insert data in DB
  safeZonesJSON = json.encode(safeZones)

--[[
  MySQL.Async.execute('INSERT INTO games (safezones, created) VALUES (@safezones, @created)', {['@safezones'] = safeZonesJSON, ['@created'] = os.date(sqlDateFormat)}, function()
    MySQL.Async.fetchScalar('SELECT MAX(id) FROM games', { }, function(id) --TODO Ugly stuff
      gameId = id
    end)
  end)
--]]
  
  Players = getPlayers()
  nbAlivePlayers = count(Players)

  local spawnCoord = md.spawnCoord
  table_shuffle(spawnCoord)

  for i, player in pairs(Players) do
    
    TriggerClientEvent('Libria:startGame', player.source, nbAlivePlayers, spawnCoord[i])
    

  end


  ResetSafezoneStartTime()
  currentSafezoneIndex = 1
  TriggerClientEvent('Libria:setCurrentSafezone', -1, safeZones[currentSafezoneIndex])
  SetTargetSafeZone(currentSafezoneIndex) --  instantly set first next safe zone



  -- Create pickups
  local pickUpDatas = { }
  for i = 1, count(md.weaponPickupCoords) do
    table.insert(pickUpDatas, { pickupItem = pickupItems[math.random(#pickupItems)], location = md.weaponPickupCoords[i] })
  end
 
  TriggerClientEvent('ews:createPickups', -1, pickUpDatas)




end)

local SafezoneStartTime = nil
local timeDiff = 0
function ResetSafezoneStartTime()
  SafezoneStartTime = nil
end
-- Safezone Update thread
Citizen.CreateThread(function()

  while(true) do

    Wait(0)

    if (isGameStarted == true or conf.debug == true) and currentSafezoneIndex < #safeZones then
      if not SafezoneStartTime then SafezoneStartTime = GetGameTimer() end

      timeDiff =  GetGameTimer() - SafezoneStartTime
      if(timeDiff / 1000 > conf.safeZoneMaintainTime[currentSafezoneIndex]) then
        TriggerClientEvent('Libria:setCurrentSafezone', -1, safeZones[currentSafezoneIndex])
        SetTargetSafeZone(currentSafezoneIndex + 1)
        ResetSafezoneStartTime()
      end
      
    else
      ResetSafezoneStartTime()
    end

   

  end
 



end)

function SetTargetSafeZone(index)

  currentSafezoneIndex = index

      if(currentSafezoneIndex <= #safeZones) then

        for _, player in pairs(getPlayers())  do
          TriggerClientEvent('Libria:setTargetSafezone', player.source, safeZones[currentSafezoneIndex], conf.safeZoneMaintainTime[currentSafezoneIndex])
        end
      end

end


-- Game has started for client, saves the spawning point and weapon
AddEventHandler('Libria:clientGameStarted', function(stats)
  if players[source] ~= nil then
    players[source].spawn = stats.spawn
    players[source].weapon = stats.weapon
  end
end)

-- Stops the game
AddEventHandler('Libria:stopGame', function(restart, noWin)

  print('StopGame')

  -- Disable autorestart if nb players < autostart
  local nbPlayers = count(getPlayers())
  TriggerClientEvent('Libria:updateRemainingToStartPlayers', -1, math.max(conf.autostart - nbPlayers, 0))
  if nbPlayers < conf.autostart then restart = false end

  if not isGameStarted then
    TriggerClientEvent('Libria:stopGame', -1, nil, restart)
    return false
  end
  -- Get the winner
  local alivePlayers = getAlivePlayers()
  local winner = { id = nil, name = nil }
  if not noWin and count(alivePlayers) == 1 then
    winner = alivePlayers[1]
    winner.rank = 1
  end
  if conf.stats then
    for k,player in pairs(players) do
      if player.weapon ~= '' then
        MySQL.Async.execute('INSERT INTO players_stats (pid, gid, spawn, weapon, kills, rank) VALUES (@pid, @gid, @spawn, @weapon, @kills, @rank)',
          {['@pid'] = player.id, ['@gid'] = gameId, ['@spawn'] = json.encode(player.spawn), ['@weapon'] = player.weapon, ['@kills'] = player.kills, ['@rank'] = player.rank}, function()
            print('Players stats saved')
        end)
      end
    end
  end
  -- Update database
  isGameStarted = false
  MySQL.Async.execute('UPDATE games SET finished=@finished, wid=@wid WHERE id=@id', {['@finished'] = os.date(sqlDateFormat), ['@wid'] = winner.id, ['@id'] = gameId}, function()
    -- Send the event to the clients with the winner name
    if winner.id then
      print('trigger winnerScreen')
      TriggerClientEvent('Libria:winnerScreen', winner.source, winner.rank, winner.kills, restart)
    end

    SetTimeout(5000, function()
    
      TriggerClientEvent('Libria:stopGame', -1, winner.name, restart)
    
    end)
   
  end)

  -- Reset player stats in current round
  for _, player in pairs(players) do
    player.alive = true
    player.rank = 0
    player.kills = 0
    player.spawn = {}
    player.weapon = ''
  end

  ResetSafezoneStartTime()
end)

AddEventHandler('Libria:stopGameClients', function(name, restart)
  TriggerClientEvent('Libria:stopGame', -1, name, restart)
end)

AddEventHandler('Libria:dropPlayer', function(source, reason)
  DropPlayer(source, reason)
end)

AddEventHandler('Libria:playerDied', function(source, killer, suicide)
  players[source].rank = nbAlivePlayers;
  TriggerClientEvent('Libria:wastedScreen', source, players[source].rank, players[source].kills)

  nbAlivePlayers = nbAlivePlayers - 1
  players[source].alive = false
  updateAlivePlayers(-1)

  local message = ''
  local playerName = '~o~<C>'..getPlayerName(source)..'</C>~w~'

  if suicide then
    message = playerName..' commited suicide.'
  elseif killer then
    local killerName = '~o~<C>'..getPlayerName(killer)..'</C>~w~'
    message = killerName..'  Killed  '..playerName
  else
    message = playerName..' died.'
  end

  sendNotification(-1, message)

  if isGameStarted and nbAlivePlayers == 1 and count(getPlayers()) > 1 then
    TriggerEvent('Libria:stopGame', true, false)
  end
end)

-- called when player disconected
AddEventHandler('playerDropped', function(reason)
  removePlayer(source, reason)
end)

AddEventHandler('baseevents:onPlayerDied', function()
  TriggerEvent('Libria:playerDied', source, nil, true)
end)

AddEventHandler('baseevents:onPlayerKilled', function(killer)
  if killer ~= -1 then
    TriggerEvent('Libria:playerDied', source, killer)
  else
    TriggerEvent('Libria:playerDied', source)
  end

  if players[killer] ~= nil then
    players[killer].kills = players[killer].kills + 1;
  end
end)

