
function sendMessage(target, name, color, message)
  TriggerClientEvent('chatMessage', target, name, color, message)
  print(tostring(name) .. ' : ' .. message)
end

function sendSystemMessage(target, message)
  sendMessage(target, '', {0, 0, 0}, '^2* ' .. message)
end

function sendNotification(target, message)
  TriggerClientEvent('Libria:showNotification', target, message)
end

-- Returns a mapdata
function GetRandomMapData()

  if #mapData == 1 then
    return mapData[1]
  end

  local nbmapData = count(mapData)
  local randLocationIndex = math.random(nbmapData)
  return mapData[randLocationIndex]
end



