--------------------------------------------------------------------------------
--                               Libria                              --
--                            Client functions file                           --
--------------------------------------------------------------------------------

local itemBlips = {
    ["PICKUP_WEAPON_APPISTOL"] = 156,
    ["PICKUP_WEAPON_ASSAULTSHOTGUN"] = 158,
    ["PICKUP_WEAPON_ASSAULTSMG"] = 159,
    ["PICKUP_WEAPON_AUTOSHOTGUN"] = 158,
    ["PICKUP_WEAPON_BULLPUPSHOTGUN"] = 158,
    ["PICKUP_WEAPON_COMBATMG"] = 159,
    ["PICKUP_WEAPON_COMBATPDW"] = 159,
    ["PICKUP_WEAPON_COMBATPISTOL"] = 156,
    ["PICKUP_WEAPON_FLAREGUN"] = 156,
    ["PICKUP_WEAPON_DBSHOTGUN"] = 158,
    ["PICKUP_WEAPON_GRENADE"] = 152,
    ["PICKUP_WEAPON_GUSENBERG"] = 159,
    ["PICKUP_WEAPON_HEAVYPISTOL"] = 156,
    ["PICKUP_WEAPON_HEAVYSHOTGUN"] = 158,
    ["PICKUP_WEAPON_MACHINEPISTOL"] = 159,
    ["PICKUP_WEAPON_MARKSMANPISTOL"] = 156,
    ["PICKUP_WEAPON_MG"] = 159,
    ["PICKUP_WEAPON_MICROSMG"] = 159,
    ["PICKUP_WEAPON_MINISMG"] = 159,
    ["PICKUP_WEAPON_MOLOTOV"] = 155,
    ["PICKUP_WEAPON_PIPEBOMB"] = 152,
    ["PICKUP_WEAPON_PISTOL"] = 156,
    ["PICKUP_WEAPON_PISTOL50"] = 156,
    ["PICKUP_WEAPON_PROXMINE"] = 152,
    ["PICKUP_WEAPON_PUMPSHOTGUN"] = 158,
    ["PICKUP_WEAPON_REVOLVER"] = 156,
    ["PICKUP_WEAPON_RPG"] = 157,
    ["PICKUP_WEAPON_HOMINGLAUNCHER"] = 157,
    ["PICKUP_WEAPON_SAWNOFFSHOTGUN"] = 158,
    ["PICKUP_WEAPON_MUSKET"] = 158,
    ["PICKUP_WEAPON_SMG"] = 159,
    ["PICKUP_WEAPON_SMOKEGRENADE"] = 152,
    ["PICKUP_WEAPON_SNSPISTOL"] = 156,
    ["PICKUP_WEAPON_STICKYBOMB"] = 152,
    ["PICKUP_WEAPON_VINTAGEPISTOL"] = 156,
    ["PICKUP_WEAPON_ADVANCEDRIFLE"] = 150,
    ["PICKUP_WEAPON_ASSAULTRIFLE"] = 150,
    ["PICKUP_WEAPON_BULLPUPRIFLE"] = 150,
    ["PICKUP_WEAPON_CARBINERIFLE"] = 150,
    ["PICKUP_WEAPON_COMPACTLAUNCHER"] = 174,
    ["PICKUP_WEAPON_COMPACTRIFLE"] = 150,
    ["PICKUP_WEAPON_GRENADELAUNCHER"] = 174,
    ["PICKUP_WEAPON_HEAVYSNIPER"] = 160,
    ["PICKUP_WEAPON_MARKSMANRIFLE"] = 160,
    ["PICKUP_WEAPON_SNIPERRIFLE"] = 160,
    ["PICKUP_WEAPON_MINIGUN"] = 173,
    ["PICKUP_WEAPON_SPECIALCARBINE"] = 150,
    ["PICKUP_ARMOUR_STANDARD"] = 175,
    ["PICKUP_HEALTH_SNACK"] = 153,
    ["PICKUP_HEALTH_STANDARD"] = 153,
}

-- Prints help text (top left)
function showHelp(str)
  SetTextComponentFormat("STRING")
  AddTextComponentString(str)
  DisplayHelpTextFromStringLabel(0, 0, 0, -1)
end

-- Print notification (bottom left)
function showNotification(text)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(text)
  DrawNotification(true, false)
end

-- Print a text at coords
function showText(text, x, y, color, font, scale, center, shadow)
  color = color or conf.color.grey

  SetTextFont(font or 4)
  SetTextProportional(1)
  SetTextScale(scale or 0.0, scale or 0.5)
  SetTextColour(color.r, color.g, color.b, color.a or 255)

  if shadow then
    SetTextDropshadow(8, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    --SetTextDropShadow()
  else
    SetTextOutline()
  end

  if center then
    SetTextCentre(true)
  end

  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)


end

function getGroundZ(x, y, z)
  local result, groundZ = GetGroundZFor_3dCoord(x+0.0, y+0.0, z+0.0, Citizen.ReturnResultAnyway())
  return groundZ
end

-- Teleports current player to coords
function teleport(coords)
  Citizen.CreateThread(function()
    local playerPed = GetPlayerPed(-1)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    while not HasCollisionLoadedAroundEntity(playerPed) do
      RequestCollisionAtCoord(coords.x, coords.y, coords.z)
      Wait(0)
    end
    ClearPedTasksImmediately(playerPed)

    local groundZ = coords.z
    if groundZ == 0.0 then
      groundZ = getGroundZ(coords.x, coords.y, 1000.0)
    end
    SetEntityCoords(playerPed, coords.x, coords.y, groundZ)
    showNotification('Teleport success')
  end)
end



-- Change the skin of the player, from a predefined list
function changeSkin(skin)
  local model = (skin ~= '' and skin or getRandomNPCModel())
  Citizen.CreateThread(function()
    -- Get model hash.
    local modelhashed = GetHashKey(model)

    -- Request the model, and wait further triggering untill fully loaded.
    RequestModel(modelhashed)
    while not HasModelLoaded(modelhashed) do
      RequestModel(modelhashed)
      Wait(0)
    end
    -- Set playermodel.
    SetPlayerModel(PlayerId(), modelhashed)
    -- Set model no longer needed.
    SetModelAsNoLongerNeeded(modelhashed)
  end)
  return model
end

function secondsToMMSS(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00";
  else
    mins = string.format("%02.f", math.floor(seconds / 60));
    secs = string.format("%02.f", math.floor(seconds -  mins * 60));
    return mins..":"..secs
  end
end


local duration = 0
local step = 1
local CountdownRun = false
local startedAt = nil
function SetCountdown(d, s)

  duration = d
  step = s
  startedAt = GetGameTimer()
  CountdownRun = true
  print('SetCountdown')
end

function ResetCountdown()

  duration = 0
  step = 1
  startedAt = nil
  CountdownRun = false

end

--count down timer thread
Citizen.CreateThread(function()
      
  local color = nil
  local countdown = 0

while true do
  Wait(0)
  while CountdownRun and startedAt ~= nil do
    Wait(0)
  
    timeDiff = GetTimeDifference(GetGameTimer(), startedAt)
    countdown = duration - tonumber(round(timeDiff / (step * 1000)))

    local color = conf.color.white
    if countdown < (duration / 10) then
      color = conf.color.red
    end

    if not isPlayerInLobby() or isPlayerInSpectatorMode() then
      showText(secondsToMMSS(round(countdown)), 0.23, 0.9, { r = 255, g = 255, b = 255, a = 255 }, 1, 1.3, true, false)
    end

    if countdown <= 0 then
      CountdownRun = false
    end

  end

end

end)

-- Returns a random npc model from a predefined list
function getRandomNPCModel()
  return npc_models[GetRandomIntInRange(1, count(npc_models) + 1)]
end



function SetSafeZoneBlip(blip, cSafezoneCoord, cSafezoneRadius, color)
  local safeZoneBlip = AddBlipForRadius(cSafezoneCoord.x, cSafezoneCoord.y, cSafezoneCoord.z, cSafezoneRadius * 1.0)

  SetBlipColour(safeZoneBlip, color) -- Green
  SetBlipHighDetail(safeZoneBlip, true)
  SetBlipAlpha(safeZoneBlip, 90)
  SetBlipDisplay(safeZoneBlip, 10)


  if blip ~= nil then
    RemoveBlip(blip)
  end

  return safeZoneBlip
end





-- Returns true if the player is near coords
function isPlayerNearCoords(coords, min)
  if min == nil then min = 100.0 end

  if coords == nil then return false end

  local playerPos = GetEntityCoords(GetPlayerPed(PlayerId()))
  local distance = math.abs(GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, coords.x, coords.y, coords.z, true))

  return distance <= min
end

function drawInstructionalButtons(buttons)
  Citizen.CreateThread(function()
    local scaleform = RequestScaleformMovie('instructional_buttons')
    while not HasScaleformMovieLoaded(scaleform) do
      Wait(0)
    end

    PushScaleformMovieFunction(scaleform, 'CLEAR_ALL')
    PushScaleformMovieFunction(scaleform, 'TOGGLE_MOUSE_BUTTONS')
    PushScaleformMovieFunctionParameterBool(0)
    PopScaleformMovieFunctionVoid()

    for i,v in ipairs(buttons) do
      PushScaleformMovieFunction(scaleform, 'SET_DATA_SLOT')
      PushScaleformMovieFunctionParameterInt(i-1)
      Citizen.InvokeNative(0xE83A3E3557A56640, v.button)
      PushScaleformMovieFunctionParameterString(v.label)
      PopScaleformMovieFunctionVoid()
    end

    PushScaleformMovieFunction(scaleform, 'DRAW_INSTRUCTIONAL_BUTTONS')
    PushScaleformMovieFunctionParameterInt(-1)
    PopScaleformMovieFunctionVoid()
    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
  end)
end



function ChangeRandomModel()

  changeSkin('')
  SetPedCombatMovement(GetPlayerPed(-1), 0)
end


function StopWandering()

  local ped = GetPlayerPed(-1)

  SetCurrentPedWeapon(ped, GetHashKey('WEAPON_UNARMED'), true)
  ClearPedTasks(ped)
end


function StartWander()
  
Citizen.CreateThread(function()

  local wanderDisabledCountDown = 0
  local startWanderTime = nil
  local stopWandertimeDiff = 0

  TaskWanderStandard(GetPlayerPed(-1), 10, 10)

  while true do

  
      if not startWanderTime then startWanderTime = GetGameTimer()  end

      stopWandertimeDiff = GetTimeDifference(GetGameTimer(), startWanderTime)
      wanderDisabledCountDown = conf.stopWanderTimer - tonumber(round(stopWandertimeDiff / 1000))
      --showText(tostring(wanderDisabledCountDown) .. ' ' .. tostring(startWanderTime) .. ' ' .. tostring(stopWandertimeDiff) .. ' ' , 0.5, 0.125, conf.color.red, 7, 0.4, true, true)

      showText('To Start Controlling Character,  Start Pressing W \nAfter ' .. tostring(wanderDisabledCountDown) .. ' Seconds.  Character will stop wander', 0.5, 0.125, conf.color.red, 7, 0.6, true, false)

      if IsControlJustPressed(0, 32) or wanderDisabledCountDown < 0 then
        StopWandering()
        
        return
      end
    
  


    Citizen.Wait(0)
  end
end)

end



function SetForStartingGame()


  Citizen.CreateThread(function()
  
   
    

    DoScreenFadeOut(0)
    ChangeRandomModel()
  
    Citizen.Wait(3000)
    StartWander()
    GiveWeaponToPed(PlayerPedId(), GetHashKey(conf.startingWeapon), conf.weaponClipCount, false, false)
   
 
   
    DoScreenFadeIn(4)

  end)
end





function DrawTimerBar(value, maxvalue, r, g, b)
	local width = 0.2
	local height = 0.025
	local xvalue = 0.38
	local yvalue = 0.88
	local outlinecolour = {0, 0, 0, 150}
	local barcolour = {r, g, b}
	local minutes = math.floor(value/60)
	local time = ""..minutes.." minutes and "..math.floor(value - (minutes*60)).." seconds"
	DrawRect(xvalue + (width/2), yvalue, width + 0.004, height + 0.006705, outlinecolour[1], outlinecolour[2], outlinecolour[3], outlinecolour[4]) -- Box that creates outline
	DrawRect(xvalue + (width/2), yvalue, width, height, barcolour[1], barcolour[2], barcolour[3], 75) --  Static full bar
	DrawRect(xvalue + ((value/(maxvalue/width))/2), yvalue, value/(maxvalue/width), height, barcolour[1], barcolour[2], barcolour[3], 255) -- Moveable Bar  
end

