Citizen.CreateThread(function() 
  -- Disable money displaying
  DisplayCash(false)

  

  local player = PlayerId()

  -- Disable cops
  SetPoliceIgnorePlayer(player, true)
  SetDispatchCopsForPlayer(player, false)
  SetMaxWantedLevel(0)

  while true do
    Citizen.Wait(0)


    -- Infinite stamina
    ResetPlayerStamina(player)

    -- Disable health regeneration
  SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
  end
end)

-- Auto restart
Citizen.CreateThread(function()
  local countdown = 0
  local gameEndedAt = nil
  local timeDiff = 0

  while true do
    Wait(0)
    if getIsGameEnded() then
      if not gameEndedAt then gameEndedAt = GetGameTimer() end

      timeDiff = GetTimeDifference(GetGameTimer(), gameEndedAt)
      countdown = conf.autostartTimer - tonumber(round(timeDiff / 1000))

      showHelp('Match starts in ' .. countdown .. '...')

      if countdown < 0 then
        setGameEnded(false)
        gameEndedAt = nil
        TriggerServerEvent('Libria:startGame')
      end
    else
      gameEndedAt = nil
    end
  end
end)

-- Set weather and time
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(33)

    NetworkOverrideClockTime(conf.time.hours, conf.time.minutes, conf.time.seconds)

    SetWeatherTypePersist(conf.weather)
    SetWeatherTypeNowPersist(conf.weather)
    SetWeatherTypeNow(conf.weather)
    SetOverrideWeather(conf.weather)
  end
end)


Citizen.CreateThread(function()
  local message

  while true do
    Wait(0)

    message = nil

    if (getIsGameStarted() and not isPlayerInLobby()) or (getIsGameStarted() and isPlayerInLobby() and isPlayerInSpectatorMode()) then
      message = 'Alive players:  ~o~' .. getPlayersRemaining()
    elseif not getIsGameEnded() and not getIsGameStarted() and isPlayerInLobby() then
      message = getPlayersRemainingToAutostart()..' player(s) left to autostart the match.'
    end

    if message then
      showHelp(message)
    end

    DisplayRadar(true)
  end
end)


Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    SetMpGamerTagVisibility(gamerTag, 0, false) -- GAMER_NAME
    SetMpGamerTagVisibility(gamerTag, 2, false) -- HEALTH/ARMOR
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    SetPlayerMayNotEnterAnyVehicle(PlayerId())
  end
end)



Citizen.CreateThread(function ()
  -- body
while true do 

  if IsEntityDead(PlayerPedId()) == false then
    showText('F5 : 에니메이션\nC : 뒤쪽 보기', 0.9, 0.05, conf.color.white, 7, 0.5, true, false)
  end
 
         
  Citizen.Wait(0)

end

  
end)


Citizen.CreateThread(function ()
  -- body
while true do 

  local playerId = PlayerId()
  local ped = GetPlayerPed(-1)

  PedSkipNextReloading(ped)
  ClearPedBloodDamage(ped)

  SetPlayerCanUseCover(playerId, false)

  --SetPedMoveRateOverride(ped,1.0)
  --SetRunSprintMultiplierForPlayer(playerId,1)

  
  SetEveryoneIgnorePlayer(playerId, true)
  Citizen.Wait(0)

end

end)

Citizen.CreateThread(function ()
  -- body
while true do 

  SetPlayerWeaponDamageModifier(PlayerId(), 10.0)
  Citizen.Wait(0)

end

end)









--Block Fist Attack
Citizen.CreateThread(function()

  while true do
    Citizen.Wait(0)

    local ped = GetPlayerPed(-1)
    local currentWeaponHash = GetSelectedPedWeapon(ped)

    if currentWeaponHash == -1569615261 or  GetAmmoInPedWeapon(ped, currentWeaponHash) == 0 then
      -- if currentWeapon is fist
     
      DisableControlAction(0, 142, true) 
      DisableControlAction(0, 25, true) 
      DisableControlAction(0, 140, true) 
      DisableControlAction(0, 24, true) 
      DisableControlAction(0, 257, true) 
      
      
    end



  end

end)


Citizen.CreateThread( function()


  while true do
    
    Citizen.Wait(0)
    local ped = GetPlayerPed(-1)
    if not GetPedConfigFlag(ped,78,1) then
    
      SetPedUsingActionMode(GetPlayerPed(-1), false, -1, 0)

    end

  end


end)

