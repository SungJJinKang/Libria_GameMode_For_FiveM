local PlayingAnim = false

Citizen.CreateThread(function()
    
    WarMenu.CreateMenu('list', "Animation")
    WarMenu.SetSubTitle('list', 'Animation')
  

    while true do

        local ped = PlayerPedId()

        if not IsPedActiveInScenario(ped) and PlayingAnim then
            PlayingAnim = false
        end
            
        if WarMenu.IsMenuOpened('list') then

            if WarMenu.Button('~r~~h~Stop Animation') then
            ClearPedTasks(ped)
            end

            for theId,theItems in pairs(scens) do
                    if WarMenu.Button(theItems.label) then
                    TaskStartScenarioInPlace(ped, theItems.scen, 0, true)
                    PlayingAnim = true
                    end
                
            end

            WarMenu.Display()
        elseif IsControlJustReleased(0, control_key) then --f6
            WarMenu.OpenMenu('list')
        end

    

        Citizen.Wait(0)
    end
end)


