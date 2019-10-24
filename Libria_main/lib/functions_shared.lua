function round(num, precision)
  return string.format("%." .. (precision or 0) .. "f", num)
end

function explode(str, sep)
  if sep == '' then return false end

  local pos,arr = 0,{}

  -- for each divider found
  for st,sp in function() return string.find(str, sep, pos, true) end do
    table.insert(arr, string.sub(str, pos, st-1)) -- Attach chars left of current divider
    pos = sp + 1 -- Jump past current divider
  end

  table.insert(arr, string.sub(str, pos)) -- Attach chars right of last divider
  return arr
end


-------------------------------
math.lerp = function(a, b, t)
  -- body
  return a + (b - a) * t
end

function coord_lerp(a, b, t)
  local lx = math.lerp(a.x, b.x, t)
  local ly = math.lerp(a.y, b.y, t)
  local lz = math.lerp(a.z, b.z, t)
  
  return {x = lx, y = ly, z = lz}
end


--------------------------------------------------

function table_reverse(t)

  if t == nil then return end
  
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable

    
end

function table_clear(t)
  
  if t == nil then return end
    

  for k in pairs (t) do
    t [k] = nil
end

end

function table_shuffle(t)

  local rand = math.random 
  assert(t, "table.shuffle() expected a table, got nil")
  local iterations = #t
  local j
  
  for i = iterations, 2, -1 do
      j = rand(i)
      t[i], t[j] = t[j], t[i]
  end
  
end

function count(array)
  if type(array) ~= 'table' then return false end

  local count = 0
  for k, v in pairs(array) do
    count = count + 1
  end
  return count
end


function GetWeaponName(id)

  for i,v in ipairs(pickupItems) do

    if v.id == id then 
      return v.name
    end
  end

  return ''

end


function GetRandomRot()
  return vector3(math.random(-100, 100) * 0.01, math.random(-100, 100) * 0.01, 0)
end


function GetRandomPointInCircle(point, radius)

  local angle = math.random() * math.pi * 2

  local ox = math.cos( angle ) * math.random() * radius
  local oy = math.sin( angle ) * math.random() * radius


  return 
  {
  x = point.x + ox, 
  y = point.y + oy, 
  z = point.z
  }
 
  

end