local npcSpawn = vector4(-539.3002, -207.8901, 37.6498, 130.7578) -- x, y, z, heading
local interactionRange = 3.0

local npcPed = nil
local isNearNpc = false

local canBuyTip = true 
local cooldownTime = 5 * 60 * 1000 -


Citizen.CreateThread(function()
    local model = GetHashKey("a_m_y_smartcaspat_01")
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end
    npcPed = CreatePed(4, model, npcSpawn.x, npcSpawn.y, npcSpawn.z - 1.0, npcSpawn.w, false, true)
    SetEntityHeading(npcPed, npcSpawn.w)
    SetEntityInvincible(npcPed, true)
    FreezeEntityPosition(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
end)

-- Marker zeichnen
-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)
--         DrawMarker(2, npcSpawn.x, npcSpawn.y, npcSpawn.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 255, 0, 150, false, false, 2, false, nil, nil, false)
--     end
-- end)

-- Nähe + Interaktion mit Cooldown-Check
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local dist = #(playerCoords - vector3(npcSpawn.x, npcSpawn.y, npcSpawn.z))

        if dist < interactionRange then
            if not isNearNpc then
                isNearNpc = true
            end

            SetTextComponentFormat("STRING")
            if canBuyTip then
                AddTextComponentString("Drücke ~INPUT_CONTEXT, um einen Tipp für $50.000 zu kaufen")
                --TriggerEvent('a_hud:HelpNotification', 'E', 'um einen Tipp für $50.000 zu kaufen') --- falls ihr dort nh notify haben wollt < 3
            else
                AddTextComponentString("Warte noch, bis du wieder einen Tipp kaufen kannst!")
                --ESX.ShowNotification("Warte noch, bis du wieder einen Tipp kaufen kannst!")
            end
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)

            if IsControlJustReleased(0, 38) and canBuyTip then
                TriggerServerEvent("npcTips:tryBuyTip")
            end
        else
            if isNearNpc then
                isNearNpc = false
            end
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent("npcTips:showNotify")
AddEventHandler("npcTips:showNotify", function(text, startCooldown)
    ESX.ShowNotification(text)
    if startCooldown then
        canBuyTip = false
        Citizen.SetTimeout(cooldownTime, function()
            canBuyTip = true
            ESX.ShowNotification("Du kannst jetzt wieder einen Tipp kaufen.")
        end)
    end
end)
