local QBX = exports.qbx_core

local function deletePhysicalVehicle(plate)
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        if DoesEntityExist(vehicle) then
            local vehiclePlate = GetVehicleNumberPlateText(vehicle):gsub("%s+", "")
            local targetPlate = plate:gsub("%s+", "")
            
            if vehiclePlate == targetPlate then
                SetEntityAsMissionEntity(vehicle, true, true)
                DeleteVehicle(vehicle)
                return true
            end
        end
    end
    return false
end

RegisterCommand('removevehicle', function(source, args)
    local csn = args[1]
    local plate = args[2]
    
    if not csn or not plate then
        QBX:Notify('Usage: /removevehicle [CSN] [plate]', 'error')
        return
    end
    
    plate = plate:upper()
    TriggerServerEvent('string_removevehicle:removeByPlate', csn, plate)
end, false)

RegisterCommand('removeplayervehicles', function(source, args)
    local citizenid = args[1]
    
    if not citizenid then
        QBX:Notify('Usage: /removeplayervehicles [citizenid]', 'error')
        return
    end
    
    TriggerServerEvent('string_removevehicle:removePlayerVehicles', citizenid)
end, false)

RegisterNetEvent('string_removevehicle:deleteVehicle', function(plate)
    if deletePhysicalVehicle(plate) then
        print('^3[Vehicle Removed] ^7Physical vehicle with plate ' .. plate .. ' has been deleted')
    end
end)

TriggerEvent('chat:addSuggestion', '/removevehicle', 'Remove a vehicle from the database by CSN and plate', {
    { name = 'csn', help = 'Player\'s citizen ID (CSN)' },
    { name = 'plate', help = 'Vehicle license plate' }
})

TriggerEvent('chat:addSuggestion', '/removeplayervehicles', 'Remove all vehicles from a player', {
    { name = 'citizenid', help = 'Player\'s citizen ID' }
})

print('^2[string_removevehicle] ^7Client script loaded successfully')