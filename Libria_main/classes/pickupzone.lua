PickupZone = {
    new = function(weaponId, coord, blipId)
      local self = setmetatable({}, PickupZone)
  
      self.weaponId = weaponId
      self.coord = coord
      self.blipId = blipId
      return self
    end
  }
  