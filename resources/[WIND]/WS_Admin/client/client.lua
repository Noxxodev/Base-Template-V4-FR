ESX = exports["es_extended"]:getSharedObject()

RegisterKeyMapping('menuadmin', "Ouvrir le menu admin", 'keyboard', 'F10')

RegisterKeyMapping('adminnoclip', "noclip", 'keyboard', 'F9')

RegisterCommand('menuadmin', function()
    staff_menu()
end)

RegisterCommand('adminnoclip', function()
    noclip()
end)

function staff_menu()
    ESX.TriggerServerCallback('WS_Admin:getgroup', function(access)
        if access then
            lib.registerMenu({
                id = 'menu_staff',
                title = "Menu Staff",
                position = positionmenu,
                options = {
                    {label = "Me heal", icon = "heart-pulse", iconColor = "#ef4444"},
                    {label = "Me revive", icon = "user-plus", iconColor = "#22c55e"},
                    {label = "Ce TP au marker", icon = "location-arrow", iconColor = "#3b82f6"},
                    {label = "Ce sur un joueur", icon = "person-walking", iconColor = "#3b82f6"},
                    {label = "TP un joueur sur moi", icon = "people-arrows", iconColor = "#3b82f6"},
                    {label = "Faire spawn une voiture", icon = "car", iconColor = "#f59e0b"},
                    {label = "Réparer", icon = "screwdriver-wrench", iconColor = "#22c55e"},
                    {label = "Nettoyer", icon = "spray-can-sparkles", iconColor = "#60a5fa"},
                    {label = "Supprimer", icon = "trash", iconColor = "#dc2626"},
                }
            }, function(selected, scrollIndex, args)
                if selected == 1 then
                    ExecuteCommand("heal me")

                elseif selected == 2 then
                    local ped = PlayerPedId()
                    local coords = GetEntityCoords(ped)

                    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
                    SetEntityHealth(ped, 200)
                    ClearPedTasksImmediately(ped)
                    ClearPedBloodDamage(ped)
                    ResetPedVisibleDamage(ped)
                    ClearPedLastWeaponDamage(ped)

                    TriggerEvent('esx_basicneeds:resetStatus')
                    TriggerEvent('esx:onPlayerSpawn')

                elseif selected == 3 then
                    local playerped = PlayerPedId()
                    local markerpoint = GetFirstBlipInfoId(8)

                    if DoesBlipExist(markerpoint) then
                        Citizen.CreateThread(function()
                            local markercoords = GetBlipInfoIdCoord(markerpoint)
                            local foundGround, zCoords, zPos = false, -500.0, 0.0

                            while not foundGround do
                                zCoords = zCoords + 10.0
                                RequestCollisionAtCoord(markercoords.x, markercoords.y, zCoords)
                                Citizen.Wait(1)
                                foundGround, zPos = GetGroundZFor_3dCoord(markercoords.x, markercoords.y, zCoords)

                                if not foundGround and zCoords >= 2000.0 then
                                    foundGround = true
                                end
                            end

                            SetPedCoordsKeepVehicle(playerped, markercoords.x, markercoords.y, zPos)
                            ESX.ShowNotification("Vous vous êtes bien téléporté à votre marker.", "success")
                        end)
                    else
                        ESX.ShowNotification("Vous n'avez pas de marker.", "error")
                    end

                elseif selected == 4 then
                    local input = lib.inputDialog('TP sur un joueur', {
                        {type = 'number', label = 'ID :'},
                    })

                    if not input then return end
                    TriggerServerEvent('WS_Admin:gotoplayer', input[1])

                elseif selected == 5 then
                    local input = lib.inputDialog('TP un joueur sur moi', {
                        {type = 'number', label = 'ID :'},
                    })

                    if not input then return end
                    TriggerServerEvent('WS_Admin:bringplayer', input[1])

                elseif selected == 6 then
                    local input = lib.inputDialog('Spawn véhicule', {
                        {type = 'input', label = 'Nom :'},
                    })

                    if not input then return end
                    TriggerServerEvent('WS_Admin:spawncar', input[1])

                elseif selected == 7 then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

                    if vehicle and DoesEntityExist(vehicle) then
                        SetVehicleFixed(vehicle)
                        ESX.ShowNotification("Véhicule réparé.", "success")
                    else
                        ESX.ShowNotification("Aucun véhicule.", "error")
                    end

                elseif selected == 8 then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

                    if vehicle and DoesEntityExist(vehicle) then
                        SetVehicleDirtLevel(vehicle, 0.0)
                        ESX.ShowNotification("Véhicule nettoyé.", "success")
                    else
                        ESX.ShowNotification("Aucun véhicule.", "error")
                    end

                elseif selected == 8 then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)

                    if vehicle and DoesEntityExist(vehicle) then
                        DeleteEntity(vehicle)
                        ESX.ShowNotification("Véhicule supprimé.", "success")
                    else
                        ESX.ShowNotification("Aucun véhicule.", "error")
                    end
                end
            end)

            lib.showMenu('menu_staff')
        else
            ESX.ShowNotification("Vous n'avez pas la permission", "error")
        end
    end)
end



local active = false
local speed = 1.0

function noclip()
    ESX.TriggerServerCallback('WS_Admin:getgroup', function(access)
        if access then
            local ped = PlayerPedId()

            if active then 
                active = false
                activenoclip(false)

                SetEntityInvincible(ped, false)
                SetEntityVisible(ped, true, false)
                FreezeEntityPosition(ped, false)
                SetEntityCollision(ped, true, true)
                SetPedGravity(ped, true)

            else
                active = true
                activenoclip(true)

                SetEntityInvincible(ped, true)
                FreezeEntityPosition(ped, true)
                SetEntityCollision(ped, false, false)
                SetPedGravity(ped, false)
                SetEntityVisible(ped, false, false)

                ESX.ShowNotification("Noclip activé", "success")
            end
        else
            ESX.ShowNotification("Vous n'avez pas la permission", "error")
        end
    end)
end

function activenoclip(state)
    local ped = PlayerPedId()

    if not state then
        ESX.ShowNotification("Noclip désactivé", "error")
        return
    end

    Citizen.CreateThread(function()
        while active do
            local waitTime = 10000
            local entity = ped
            local x, y, z = table.unpack(GetEntityCoords(entity, true))
            local dx, dy, dz = GetCamDirection()
            
    
            local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(ped)
            SetEntityHeading(entity, heading)
    
            SetEntityVelocity(entity, 0.0, 0.0, 0.0)
            waitTime = 10  
    
            -- Déplacement Avant / Arrière
            if IsControlPressed(0, 71) then -- Avancer
                x = x + speed * dx
                y = y + speed * dy
                z = z + speed * dz
            end
    
            if IsControlPressed(0, 72) then -- Reculer
                x = x - speed * dx
                y = y - speed * dy
                z = z - speed * dz
            end
    
            -- Monter/Descendre
            if IsControlPressed(0, 22) then -- Monter
                z = z + speed
            end
    
            if IsControlPressed(0, 36) then -- Descendre
                z = z - speed
            end
    
            -- Gestion de la vitesse
            if IsControlJustPressed(1, 241) then
                speed = math.min(speed + 0.5, 10.0)
            end
            
            if IsControlJustPressed(1, 242) then
                speed = math.max(speed - 0.5, 0.1)
            end
    
            SetEntityCoordsNoOffset(entity, x, y, z, true, true, false)
    
            if not active then
                break
            end
    
            Wait(waitTime)
        end
    end)
    
end

function GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()

    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)

    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end

    return x, y, z
end