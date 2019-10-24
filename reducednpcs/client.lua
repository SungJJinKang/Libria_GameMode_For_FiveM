
Citizen.CreateThread(function()
	while true do
	    
	    SetVehicleDensityMultiplierThisFrame(0.5)
	    SetPedDensityMultiplierThisFrame(1.0)
	    SetRandomVehicleDensityMultiplierThisFrame(0.5)
	    SetParkedVehicleDensityMultiplierThisFrame(0.8)
		SetScenarioPedDensityMultiplierThisFrame(1.0, 1.0)
		Citizen.Wait(0)
	end
end)