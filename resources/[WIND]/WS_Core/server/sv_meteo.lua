------------------ MODIFIEZ CECI -------------------

-- Mettez cette valeur sur false si vous ne voulez pas que la météo change automatiquement toutes les 10 minutes.
DynamicWeather = true

---------------------------------------------------
debugprint = false -- ne touchez pas à ceci sauf si vous savez ce que vous faites ou si Vespura vous a demandé d’activer cela.
---------------------------------------------------

-------------------- NE PAS MODIFIER --------------------
AvailableWeatherTypes = {
    'EXTRASUNNY', 
    'CLEAR', 
    'NEUTRAL', 
    'SMOG', 
    'FOGGY', 
    'OVERCAST', 
    'CLOUDS', 
    'CLEARING', 
    'RAIN', 
    'THUNDER', 
    'SNOW', 
    'BLIZZARD', 
    'SNOWLIGHT', 
    'XMAS', 
    'HALLOWEEN',
}
CurrentWeather = "EXTRASUNNY"
local baseTime = 0
local timeOffset = 0
local freezeTime = false
local blackout = false
local newWeatherTimer = 10

RegisterServerEvent('vSync:requestSync')
AddEventHandler('vSync:requestSync', function()
    TriggerClientEvent('vSync:updateWeather', -1, CurrentWeather, blackout)
    TriggerClientEvent('vSync:updateTime', -1, baseTime, timeOffset, freezeTime)
end)

function isAllowedToChange(player)
    local playerSRC = player
    local xPlayer = ESX.GetPlayerFromId(playerSRC)
    local rank = xPlayer.getGroup()    
    local allowed = false

    for k,needrank in pairs(Config.adminweather) do 
        if rank == needrank then
            allowed = true
        end
    end
    if allowed == false then
        TriggerClientEvent("esx:showNotification", playerSRC, "Vous n'avez pas l'autorisation d'utiliser cette commande.")
    end
    return allowed
end

RegisterCommand('freezetime', function(source, args)
    if source ~= 0 then
        if isAllowedToChange(source) then
            freezeTime = not freezeTime
            if freezeTime then
                TriggerClientEvent('esx:showNotification', source, 'Le temps est maintenant ~b~figé~s~.')
            else
                TriggerClientEvent('esx:showNotification', source, 'Le temps n’est ~y~plus figé~s~.')
            end
        else
            TriggerClientEvent('chatMessage', source, '', {255,255,255}, '^8Erreur : ^1Vous n’avez pas la permission d’utiliser cette commande.')
        end
    else
        freezeTime = not freezeTime
        print(freezeTime and "Le temps est maintenant figé." or "Le temps n’est plus figé.")
    end
end)

RegisterCommand('freezeweather', function(source, args)
    if source ~= 0 then
        if isAllowedToChange(source) then
            DynamicWeather = not DynamicWeather
            if not DynamicWeather then
                TriggerClientEvent('esx:showNotification', source, 'Les changements météo dynamiques sont maintenant ~r~désactivés~s~.')
            else
                TriggerClientEvent('esx:showNotification', source, 'Les changements météo dynamiques sont maintenant ~b~activés~s~.')
            end
        else
            TriggerClientEvent('chatMessage', source, '', {255,255,255}, '^8Erreur : ^1Vous n’avez pas la permission d’utiliser cette commande.')
        end
    else
        DynamicWeather = not DynamicWeather
        print(DynamicWeather and "La météo n’est plus figée." or "La météo est maintenant figée.")
    end
end)

RegisterCommand('weather', function(source, args)
    if source == 0 then
        local function isValidWeatherType(wtype)
            for _, type in ipairs(AvailableWeatherTypes) do
                if wtype == type then return true end
            end
            return false
        end

        if args[1] == nil then
            local errorMsg = (source == 0)
                and "Syntaxe invalide, utilisez : /weather <type_meteo>"
                or '^8Erreur : ^1Syntaxe invalide, utilisez ^0/weather <type_meteo> ^1!'
            print(errorMsg)
            return
        end

        local newWeather = string.upper(args[1])
        if not isValidWeatherType(newWeather) then
            local validList = table.concat(AvailableWeatherTypes, ' ')
            local errorMsg = (source == 0)
                and ("Type de météo invalide. Types valides :\n" .. validList)
                or '^8Erreur : ^1Type de météo invalide. Types valides : ^0\n' .. validList
            print(errorMsg)
            return
        end

        CurrentWeather = newWeather
        newWeatherTimer = 10
        TriggerEvent('vSync:requestSync')
        print("La météo a été mise à jour.")
    elseif isAllowedToChange(source) then 
        local function isValidWeatherType(wtype)
            for _, type in ipairs(AvailableWeatherTypes) do
                if wtype == type then return true end
            end
            return false
        end

        if args[1] == nil then
            local errorMsg = (source == 0)
                and "Syntaxe invalide, utilisez : /weather <type_meteo>"
                or '^8Erreur : ^1Syntaxe invalide, utilisez ^0/weather <type_meteo> ^1!'
            TriggerClientEvent('chatMessage', source, '', {255,255,255}, errorMsg)
            return
        end

        local newWeather = string.upper(args[1])
        if not isValidWeatherType(newWeather) then
            local validList = table.concat(AvailableWeatherTypes, ' ')
            local errorMsg = (source == 0)
                and ("Type de météo invalide. Types valides :\n" .. validList)
                or '^8Erreur : ^1Type de météo invalide. Types valides : ^0\n' .. validList
            TriggerClientEvent('chatMessage', source, '', {255,255,255}, errorMsg)
            return
        end

        CurrentWeather = newWeather
        newWeatherTimer = 10
        TriggerEvent('vSync:requestSync')
        TriggerClientEvent('esx:showNotification', source, 'La météo changera pour : ~y~' .. string.lower(args[1]) .. "~s~.")
    end
end, false)

RegisterCommand('blackout', function(source)
    blackout = not blackout
    if source == 0 then
        print(blackout and "Coupure de courant activée." or "Coupure de courant désactivée.")
    elseif isAllowedToChange(source) then
        TriggerClientEvent('esx:showNotification', source, blackout and 'Coupure de courant ~b~activée~s~.' or 'Coupure de courant ~r~désactivée~s~.')
        TriggerEvent('vSync:requestSync')
    end
end)

RegisterCommand('morning', function(source)
    if source == 0 then print('Pour la console, utilisez "/time <hh> <mm>"') return end
    if isAllowedToChange(source) then
        ShiftToMinute(0)
        ShiftToHour(9)
        TriggerClientEvent('esx:showNotification', source, 'L’heure a été réglée sur le ~y~matin~s~.')
        TriggerEvent('vSync:requestSync')
    end
end)

RegisterCommand('noon', function(source)
    if source == 0 then print('Pour la console, utilisez "/time <hh> <mm>"') return end
    if isAllowedToChange(source) then
        ShiftToMinute(0)
        ShiftToHour(12)
        TriggerClientEvent('esx:showNotification', source, 'L’heure a été réglée sur le ~y~midi~s~.')
        TriggerEvent('vSync:requestSync')
    end
end)

RegisterCommand('evening', function(source)
    if source == 0 then print('Pour la console, utilisez "/time <hh> <mm>"') return end
    if isAllowedToChange(source) then
        ShiftToMinute(0)
        ShiftToHour(18)
        TriggerClientEvent('esx:showNotification', source, 'L’heure a été réglée sur le ~y~soir~s~.')
        TriggerEvent('vSync:requestSync')
    end
end)

RegisterCommand('night', function(source)
    if source == 0 then print('Pour la console, utilisez "/time <hh> <mm>"') return end
    if isAllowedToChange(source) then
        ShiftToMinute(0)
        ShiftToHour(23)
        TriggerClientEvent('esx:showNotification', source, 'L’heure a été réglée sur la ~y~nuit~s~.')
        TriggerEvent('vSync:requestSync')
    end
end)

function ShiftToMinute(minute)
    timeOffset = timeOffset - (((baseTime + timeOffset) % 60) - minute)
end

function ShiftToHour(hour)
    timeOffset = timeOffset - ((((baseTime + timeOffset) / 60) % 24) - hour) * 60
end

RegisterCommand('time', function(source, args)
    local h, m = tonumber(args[1]), tonumber(args[2])
    if source == 0 then
        if h and m then
            ShiftToHour(math.min(h, 23))
            ShiftToMinute(math.min(m, 59))
            print("L’heure a été changée à " .. h .. ":" .. m .. ".")
            TriggerEvent('vSync:requestSync')
        else
            print("Syntaxe : /time <heure> <minute>")
        end
    elseif isAllowedToChange(source) then
        ShiftToHour(math.min(h or 0, 23))
        ShiftToMinute(math.min(m or 0, 59))
        TriggerClientEvent('esx:showNotification', source, "L’heure a été modifiée.")
        TriggerEvent('vSync:requestSync')
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local newBaseTime = os.time(os.date("!*t"))/2 + 360
        if freezeTime then
            timeOffset = timeOffset + baseTime - newBaseTime
        end
        baseTime = newBaseTime
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        TriggerClientEvent('vSync:updateTime', -1, baseTime, timeOffset, freezeTime)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        TriggerClientEvent('vSync:updateWeather', -1, CurrentWeather, blackout)
    end
end)

Citizen.CreateThread(function()
    while true do
        newWeatherTimer = newWeatherTimer - 1
        Citizen.Wait(60000)
        if newWeatherTimer == 0 then
            if DynamicWeather then
                NextWeatherStage()
            end
            newWeatherTimer = 10
        end
    end
end)

function NextWeatherStage()
    if CurrentWeather == "CLEAR" or CurrentWeather == "CLOUDS" or CurrentWeather == "EXTRASUNNY"  then
        local new = math.random(1,2)
        if new == 1 then
            CurrentWeather = "CLEARING"
        else
            CurrentWeather = "OVERCAST"
        end
    elseif CurrentWeather == "CLEARING" or CurrentWeather == "OVERCAST" then
        local new = math.random(1,6)
        if new == 1 then
            if CurrentWeather == "CLEARING" then CurrentWeather = "FOGGY" else CurrentWeather = "RAIN" end
        elseif new == 2 then
            CurrentWeather = "CLOUDS"
        elseif new == 3 then
            CurrentWeather = "CLEAR"
        elseif new == 4 then
            CurrentWeather = "EXTRASUNNY"
        elseif new == 5 then
            CurrentWeather = "SMOG"
        else
            CurrentWeather = "FOGGY"
        end
    elseif CurrentWeather == "THUNDER" or CurrentWeather == "RAIN" then
        CurrentWeather = "CLEARING"
    elseif CurrentWeather == "SMOG" or CurrentWeather == "FOGGY" then
        CurrentWeather = "CLEAR"
    end
    TriggerEvent("vSync:requestSync")
    if debugprint then
        print("[vSync] Un nouveau type de météo aléatoire a été généré : " .. CurrentWeather .. ".\n")
        print("[vSync] Le minuteur a été réinitialisé à 10 minutes.\n")
    end
end


