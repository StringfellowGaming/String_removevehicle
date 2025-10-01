local QBX = exports.qbx_core

local function removeVehicleFromDB(plate)
    local success = MySQL.query.await('DELETE FROM player_vehicles WHERE plate = ?', { plate })
    return success and success.affectedRows > 0
end

local function getVehicleOwner(plate)
    local result = MySQL.query.await('SELECT citizenid FROM player_vehicles WHERE plate = ?', { plate })
    if result and result[1] then
        return result[1].citizenid
    end
    return nil
end

local function getPlayerVehicles(citizenid)
    local result = MySQL.query.await('SELECT plate, vehicle FROM player_vehicles WHERE citizenid = ?', { citizenid })
    return result or {}
end

RegisterNetEvent('string_removevehicle:removeByPlate', function(targetCsn, targetPlate)
    local src = source
    local player = QBX:GetPlayer(src)
    
    if not player then return end
    
    if not QBX:HasPermission(src, Config.RequiredPermission) then
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission to use this command', 'error')
        return
    end
    
    if not targetCsn or targetCsn == '' then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid CSN provided', 'error')
        return
    end
    
    if not targetPlate or targetPlate == '' then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid plate provided', 'error')
        return
    end
    
    local ownerCitizenId = getVehicleOwner(targetPlate)
    if not ownerCitizenId then
        TriggerClientEvent('QBCore:Notify', src, 'Vehicle with plate ' .. targetPlate .. ' not found in database', 'error')
        return
    end
    
    if ownerCitizenId ~= targetCsn then
        TriggerClientEvent('QBCore:Notify', src, 'CSN does not match vehicle owner. Vehicle belongs to: ' .. ownerCitizenId, 'error')
        return
    end
    
    local success = removeVehicleFromDB(targetPlate)
    
    if success then
        print(string.format('[VEHICLE REMOVAL] Admin %s (ID: %s) removed vehicle with plate %s owned by %s (CSN: %s)', 
            player.PlayerData.name, src, targetPlate, ownerCitizenId, targetCsn))
        
        TriggerClientEvent('QBCore:Notify', src, 'Vehicle with plate ' .. targetPlate .. ' owned by ' .. targetCsn .. ' successfully removed from database', 'success')
        
        local ownerPlayer = QBX:GetPlayerByCitizenId(ownerCitizenId)
        if ownerPlayer then
            TriggerClientEvent('QBCore:Notify', ownerPlayer.PlayerData.source, 
                'One of your vehicles (Plate: ' .. targetPlate .. ') has been removed by an administrator', 'error')
        end
        
        TriggerClientEvent('string_removevehicle:deleteVehicle', -1, targetPlate)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to remove vehicle from database', 'error')
    end
end)

RegisterNetEvent('string_removevehicle:removePlayerVehicles', function(targetCitizenId)
    local src = source
    local player = QBX:GetPlayer(src)
    
    if not player then return end
    
    if not QBX:HasPermission(src, Config.RequiredPermission) then
        TriggerClientEvent('QBCore:Notify', src, 'You don\'t have permission to use this command', 'error')
        return
    end
    
    if not targetCitizenId or targetCitizenId == '' then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid citizen ID provided', 'error')
        return
    end
    
    local vehicles = getPlayerVehicles(targetCitizenId)
    
    if #vehicles == 0 then
        TriggerClientEvent('QBCore:Notify', src, 'No vehicles found for citizen ID: ' .. targetCitizenId, 'error')
        return
    end
    
    local success = MySQL.query.await('DELETE FROM player_vehicles WHERE citizenid = ?', { targetCitizenId })
    
    if success and success.affectedRows > 0 then
        print(string.format('[VEHICLE REMOVAL] Admin %s (ID: %s) removed %d vehicles from citizen ID %s', 
            player.PlayerData.name, src, success.affectedRows, targetCitizenId))
        
        TriggerClientEvent('QBCore:Notify', src, 
            'Successfully removed ' .. success.affectedRows .. ' vehicles from citizen ID: ' .. targetCitizenId, 'success')
        
        local ownerPlayer = QBX:GetPlayerByCitizenId(targetCitizenId)
        if ownerPlayer then
            TriggerClientEvent('QBCore:Notify', ownerPlayer.PlayerData.source, 
                'All your vehicles have been removed by an administrator', 'error')
        end
        
        for _, vehicle in ipairs(vehicles) do
            TriggerClientEvent('string_removevehicle:deleteVehicle', -1, vehicle.plate)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to remove vehicles from database', 'error')
    end
end)

print('^2[string_removevehicle] ^7Server script loaded successfully')