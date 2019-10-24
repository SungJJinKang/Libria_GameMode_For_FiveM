local pickupContainers = {} -- Local pickups data

RegisterNetEvent('ews:createPickups') -- Generates all the pickups
RegisterNetEvent('ews:createPickup') -- Generates all the pickups
RegisterNetEvent('ews:removePickup') -- Remove a pickup
RegisterNetEvent('ews:removeAllPickups') -- Remove a pickup

function RemovePickupContainer(pickupContainer)
  if pickupContainer.pickup ~= nil then
    RemovePickup(pickupContainer.pickup)
    pickupContainer.pickup = nil
  end

  if pickupContainer.blip ~= nil then
    RemoveBlip(pickupContainer.blip)
    pickupContainer.blip = nil
  end
end

function RemoveAllPickups()
  for k, pickupContainer in pairs(pickupContainers) do
    RemovePickupContainer(pickupContainer)
    pickupContainers[k] = nil
  end
end

AddEventHandler('ews:removeAllPickups', function()
  -- body
  RemoveAllPickups()
end)

AddEventHandler('ews:createPickups', function(pickUpDatas)

  print('pickup created')
  for _, p in pairs(pickUpDatas)  do
    CreatPickup(p.pickupItem, p.location, 1)
  end
  
  
end)

-- Create pickups which are the same for each player
AddEventHandler('ews:createPickup', function(pickupItem, location, amount)

  
  CreatPickup(pickupItem, location, amount)
  
end)

function CreatPickup(pickupItem, location, amount)   

  local pickupHash = GetHashKey(pickupItem.id)


  local newPickup = CreatePickupRotate(pickupHash, location.x, location.y, location.z - 0.4, 0.0, 0.0, 0.0, 512, amount)
  local newBlip = AddPickupBlip(pickupItem.blipId, location)

  table.insert( pickupContainers, {pickup = newPickup, blip = newBlip} )

end

-- Remove a pickup
AddEventHandler('ews:removePickup', function(pickupContainer)
  RemovePickupContainer(pickupContainer)
end)

-- https://marekkraus.sk/gtav/blips/list.html
function AddPickupBlip(id, coords)
  local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

  SetBlipSprite(blip, id)
  SetBlipHighDetail(blip, true)
  SetBlipAsShortRange(blip, true)

  return blip
end



-- Check pickup collection
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(50)

        for _, pickupContainer in pairs(pickupContainers) do
          if HasPickupBeenCollected(pickupContainer.pickup) then

            RemovePickupContainer(pickupContainer)
          end
        end
    
  end
end)

