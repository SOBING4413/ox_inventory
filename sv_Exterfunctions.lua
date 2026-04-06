

local core = 'qb_core'
local ESX, QBCore, QBX = nil, nil, nil

CreateThread(function()
    GlobalState.usebackpackItem = config.backpack.useitem
    GlobalState.staticbackpack = config.backpack.dynamic
    GlobalState.backpackSettings = {
        slot = config.backpack.slot,
        weight = config.backpack.maxWeight
    }

    Wait(5000)

    if GetResourceState('qbx_core') == 'started' then 
        core = 'qbx_core'
        QBX = exports['qb-core']:GetCoreObject()
        GlobalState.fw = 'qbx'

    elseif GetResourceState('qb_core') == 'started' then
        core = 'qb_core'
        QBCore = exports[config.CoreFolder]:GetCoreObject()
        GlobalState.fw = 'qb'

    elseif GetResourceState('es_extended') == 'started' then
        core = 'es_extended'
        ESX = exports[config.CoreFolder]:getSharedObject()
        GlobalState.fw = 'esx'
    end

    -- Cria stash da mochila se for dinâmica
    if not GlobalState.staticbackpack then 
        exports.ox_inventory:RegisterStash(
            'backpack',
            'Backpack',
            GlobalState.backpackSettings.slot,
            GlobalState.backpackSettings.weight,
            true
        )
    end
end)


-- Verifica se o jogador possui mochila em cache
lib.callback.register('ox_inventory:getbackpackitem', function(source, targetid)
    local TargetState = Player(targetid).state
    return TargetState.backpack ~= nil
end)


-- ESX: pega licença / identificador
lib.callback.register('ox_inventory:esxGetLicense', function(source)
    if ESX then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getIdentifier()
        end
    end
    return false
end)

-- Pega dinheiro do banco corretamente com export local
function getPlayerBankBalance(source)

    -- ESX
    if core == 'es_extended' then
        local ESX = exports[config.CoreFolder]:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.getAccount('bank').money
        end

    -- QBCore
    elseif core == 'qb_core' then
        local QBCore = exports[config.CoreFolder]:GetCoreObject()
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            return xPlayer.PlayerData.money["bank"]
        end

    -- QBX
    elseif core == 'qbx_core' then
        local QBX = exports[config.CoreFolder]:GetCoreObject()
        local player = QBX:GetPlayer(source)
        if player then
            return player.PlayerData.money.bank
        end
    end

    return 0
end


-- Remove dinheiro corretamente do banco
function RemoveMoney(source, amount)

    -- ESX
    if core == 'es_extended' then
        local ESX = exports[config.CoreFolder]:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.removeAccountMoney('bank', amount)
        end

    -- QBCore
    elseif core == 'qb_core' then
        local QBCore = exports[config.CoreFolder]:GetCoreObject()
        local xPlayer = QBCore.Functions.GetPlayer(source)
        if xPlayer then
            return xPlayer.Functions.RemoveMoney('bank', amount)
        end

    -- QBX
    elseif core == 'qbx_core' then
        local QBX = exports[config.CoreFolder]:GetCoreObject()
        local player = QBX:GetPlayer(source)
        if player then
            return player.Functions.RemoveMoney('bank', amount)
        end
    end

    return false
end

RegisterNetEvent('ox_inventory:removeParachute', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, 'parachute', 1)
end)

RegisterNetEvent('ox_inventory:updateArmor', function(value, slot)
    local src = source
    local armor = exports.ox_inventory:GetSlot(src, slot)
    armor.metadata.value = value
    exports.ox_inventory:SetMetadata(source, armor.slot, armor.metadata)
end)
