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

local numerovari = "#ffffff" --väri (valkoinen oletuksena)
local kmhvari = "#ff00ee" --väri (pinkki oletuksena)

RegisterCommand("mittari", function()
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        ESX.ShowNotification("Et oo autos!")
    else
    local input = lib.inputDialog('Mittarin värit', {
        {type = 'color', label = 'Muokkaa numeron väriä', default = numerovari},
        {type = 'color', label = 'Muokkaa tekstin väriä', default = kmhvari},
        {type = 'checkbox', label = 'Palauta Normivärit'}
    })

    if input then
        if input[3] then 
            numerovari = '#ffffff'
            kmhvari = '#ff00ee'

            TriggerEvent("PaivitaMittari", numerovari, kmhvari)

            lib.notify({
                title = 'Värit palautettu',
                description = 'Oletusvärit on nyt laitettu',
                type = 'success'
            })
        else
            local newNumeroColor = input[1]
            local newKmhColor = input[2]

            if (newNumeroColor and newNumeroColor ~= numerovari) or (newKmhColor and newKmhColor ~= kmhvari) then
                numerovari = newNumeroColor or numerovari
                kmhvari = newKmhColor or kmhvari
                TriggerEvent("PaivitaMittari", numerovari, kmhvari)
                lib.notify({
                    title = 'Mittarin värit',
                    description = 'Mittarin värit on vaihdettu.',
                    type = 'success'
                })
            end
        end
    end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            sleep = 5
            local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            local kmh = round(GetEntitySpeed(vehicle) * 3.6)

            local nr, ng, nb = hexToRGB(numerovari)
            local kr, kg, kb = hexToRGB(kmhvari)
            drawText(7, 0.489, 0.955, 0.0, 0.0, tostring(kmh), 0.5, 0.5, nr, ng, nb, 255)
            drawText(7, 0.5185, 0.955, 0.0, 0.0, "KM/H", 0.5, 0.5, kr, kg, kb, 255)
        end
        Wait(sleep)
    end
end)


function drawText(fontId, x, y, width, height, text, scale, scale1, r, g, b, a)
    SetTextFont(fontId)
    SetTextProportional(0)
    SetTextScale(scale, scale1)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow(1)
    SetTextCentre(1)
    SetTextOutline(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width / 2, y - height / 2 + 0.005)
end

function hexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

RegisterNetEvent("PaivitaMittari")
AddEventHandler("PaivitaMittari", function(numero, kmh)
    numerovari = numero
    kmhvari = kmh
end)