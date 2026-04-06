

local function isPedFreemodeModel(ped)
    local model = GetEntityModel(ped)
    if model == `mp_m_freemode_01` then
        return 'male'
    elseif model == `mp_f_freemode_01` then
        return 'female'
    else
        return 'male'
    end
end

function SetupInventorySettings()
    local model = isPedFreemodeModel(cache.ped)
    local data = {
        gender = model,
        SpecialSlot = config.SpecialSlot,
        balcklistItem = config.blacklistitem
    }
    SendNUIMessage({
		action = 'setupInventorySettings',
		data = data
	})
end
function GetPlayerLicense()
    if GlobalState.fw == 'esx' then
        local license = lib.callback.await('ox_inventory:esxGetLicense', false)
        return license
    elseif GlobalState.fw == 'qb' then
        return QBCore.Functions.GetPlayerData().cid
    elseif GlobalState.fw == 'qbx' then
        return QBX.PlayerData.cid
    end
end
function checkBackpackInslot()
    local backpack = exports.ox_inventory:Search('slots', 'backpack')
    if backpack then
        for _, v in pairs(backpack) do
            if v.slot == 1 then 
                if LocalPlayer.state.backpack == nil then
                    LocalPlayer.state:set('backpack', {use = true, id = v.metadata.id}, true)
                end
                return true
            end
        end
        LocalPlayer.state:set('backpack', nil, true)
        return false
    else 
        LocalPlayer.state:set('backpack', nil, true)
        return false
    end
end
local function useArmor(metadata)
    local armor = metadata.value
    if armor > 0 then
        SetPedArmour(cache.ped, armor)
    end
end
function startArmour()
    for _, v in pairs(config.ArmorItem) do
        local item = exports.ox_inventory:Search('slots', v)
        if item then
            for i, k in pairs(item) do
                if k.slot == 2 then
                    return useArmor(k.metadata)
                else
                    SetPedArmour(cache.ped, 0)
                end
            end
        end
        Wait(100)
    end
end
function CheckArmorItem(item, lepas, to)
    if lepas then
        SetTimeout(500, function()
            local armor = GetPedArmour(cache.ped)
            TriggerServerEvent('ox_inventory:updateArmor', armor, to)
            Wait(100)
            SetPedArmour(cache.ped, 0)
            return
        end)
    else
        SetTimeout(1000, function()
            for _, v in pairs(config.ArmorItem) do
                if v == item then
                    local item = exports.ox_inventory:Search('slots', item)
                    if item then
                        for i, k in pairs(item) do
                            if k.slot == 2 then
                                return useArmor(k.metadata)
                            end
                        end
                    end
                end
            end
        end)
    end
end
function CheckParachuteItem(item, lepas)
    if lepas then
        return removeParachute()
    else
        SetTimeout(1000, function()
            if item == 'parachute' then
                local item = exports.ox_inventory:Search('slots', item)
                if item then
                    for i, k in pairs(item) do
                        if k.slot == 4 then
                            local chute = `GADGET_PARACHUTE`
                            SetPlayerParachuteTintIndex(PlayerData.id, -1)
                            GiveWeaponToPed(cache.ped, chute, 0, true, false)
                            SetPedGadget(cache.ped, chute, true)
                            lib.requestModel(1269906701)
                            client.parachute = {CreateParachuteBagObject(cache.ped, true, true), k?.metadata?.type or -1}
                            if k.metadata.type then
                                SetPlayerParachuteTintIndex(PlayerData.id, k.metadata.type)
                            end
                        end
                    end
                end
            end
        end)
    end
end
function SendGiveUI(data)
	SendNUIMessage({ action = 'UpdatePlayerList', data = data })
end