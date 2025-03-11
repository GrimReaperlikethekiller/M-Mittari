ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function round(n)
    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
end

local numerovari = "#ffffff"
local kmhvari = "#ff00ee"
local bensavari = "#00ff00"
local bensanumvari = "#ffff00"
local naytaHUD = true
local bensa = 65
local bensanPoistoAjoittain = 30000

RegisterCommand("mittari", function()
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        ESX.ShowNotification("Et oo autos!")
    else
        local input = lib.inputDialog('Mittarin värit', {
            {type = 'color', label = 'Muokkaa numeron väriä', default = numerovari},
            {type = 'color', label = 'Muokkaa tekstin väriä', default = kmhvari},
            {type = 'color', label = 'Muokkaa bensan tekstin väriä', default = bensavari},
            {type = 'color', label = 'Muokkaa bensan numeron väriä', default = bensanumvari},
            {type = 'checkbox', label = 'Palauta Normivärit'}
        })

        if input then
            if input[5] then 
                numerovari, kmhvari, bensavari, bensanumvari = '#ffffff', '#ff00ee', '#00ff00', '#ffff00'
                TriggerEvent("PaivitaMittari", numerovari, kmhvari, bensavari, bensanumvari)
                lib.notify({
                    title = 'Värit palautettu',
                    description = 'Oletusvärit on nyt laitettu',
                    type = 'success'
                })
            else
                numerovari = input[1] or numerovari
                kmhvari = input[2] or kmhvari
                bensavari = input[3] or bensavari
                bensanumvari = input[4] or bensanumvari
                TriggerEvent("PaivitaMittari", numerovari, kmhvari, bensavari, bensanumvari)
                lib.notify({
                    title = 'Mittarin värit',
                    description = 'Mittarin värit on vaihdettu.',
                    type = 'success'
                })
            end
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if IsPedInAnyVehicle(PlayerPedId(), false) and naytaHUD then
            sleep = 5
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            local kmh = round(GetEntitySpeed(vehicle) * 3.6)
            local fuelLevel = round(GetVehicleFuelLevel(vehicle))

            local nr, ng, nb = hexToRGB(numerovari)
            local kr, kg, kb = hexToRGB(kmhvari)
            local br, bg, bb = hexToRGB(bensavari)
            local bnr, bng, bnb = hexToRGB(bensanumvari)

            drawText(7, 0.5, 0.93, 0.0, 0.0, tostring(kmh), 0.63, 0.63, nr, ng, nb, 255)
            drawText(7, 0.538, 0.93, 0.0, 0.0, "KM/H", 0.63, 0.63, kr, kg, kb, 255)
            drawText(7, 0.519, 0.96, 0.0, 0.0, "Bensa:", 0.4, 0.4, br, bg, bb, 255)
            drawText(7, 0.544, 0.96, 0.0, 0.0, tostring(fuelLevel), 0.4, 0.4, bnr, bng, bnb, 255)

            if fuelLevel <= 0 then
                SetVehicleEngineOn(vehicle, false, true, true)
                DisableControlAction(0, 71, true)
                DisableControlAction(0, 72, true)
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        Wait(bensanPoistoAjoittain)
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            local currentFuel = GetVehicleFuelLevel(vehicle)
            if currentFuel > 0 then
                SetVehicleFuelLevel(vehicle, currentFuel - 1)
            end
        end
    end
end)

function InitializeVehicleFuel(vehicle)
    if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
        SetVehicleFuelLevel(vehicle, bensa)
    end
end

AddEventHandler('entityCreated', function(entity)
    if DoesEntityExist(entity) and IsEntityAVehicle(entity) then
        InitializeVehicleFuel(entity)
    end
end)

function drawText(fontId, x, y, width, height, text, scaleX, scaleY, r, g, b, a)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextScale(scaleX, scaleY)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0 ,0 ,255)
    SetTextEdge(1 ,0 ,0 ,0 ,255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x ,y)
end

function hexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x"..hex:sub(1 ,2)), tonumber("0x"..hex:sub(3 ,4)), tonumber("0x"..hex:sub(5 ,6))
end

RegisterNetEvent("PaivitaMittari")
AddEventHandler("PaivitaMittari", function(numero ,kmh ,bensa ,bensanum)
    numerovari ,kmhvari ,bensavari ,bensanumvari = numero ,kmh ,bensa ,bensanum
end)
