--------------------------------------------------------------------------------
--                               Libria                              --
--                                Spectator file                              --
--------------------------------------------------------------------------------

RegisterNetEvent('Libria:SetPlayerIsSpectator')

-- Spectator mode flag
local spectatorMode = false
local playerToSpec = nil

local spectatorBlips = { }

function isPlayerInSpectatorMode()
  return spectatorMode
end

function getSpectatingPlayer()
  return playerToSpec
end

function SetPlayerIsSpectator(enable)
  spectatorMode = enable

  print('SetPlayerIsSpectator : ' .. tostring(enable))

  playerPed = GetPlayerPed(PlayerId())


  if spectatorMode then

    exports.freecam:SetEnableFreeCam(true)

    FreezeEntityPosition(playerPed,  true)
    SetEntityVisible(playerPed, false)

  else 

    exports.freecam:SetEnableFreeCam(false)

    FreezeEntityPosition(playerPed,  false)
    SetEntityVisible(playerPed, true)
  end
end

AddEventHandler('Libria:SetPlayerIsSpectator', function(enable)

  SetPlayerIsSpectator(enable)

end)
