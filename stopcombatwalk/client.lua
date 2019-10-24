Citizen.CreateThread( function()


    while true do
      
      Citizen.Wait(0)
      local ped = GetPlayerPed(-1)
      if not GetPedConfigFlag(ped,78,1) then
      
        SetPedUsingActionMode(GetPlayerPed(-1), false, -1, 0)

      end

    end


end)