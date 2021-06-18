local function deepCopyTable(object)
  local lookup_table = {}

  local function _copy(object)
    if type(object) ~= "table" then
        return object
    elseif lookup_table[object] then
        return lookup_table[object]
    end
    
    local new_table = {}

    lookup_table[object] = new_table
    
    for index, value in pairs(object) do
      new_table[_copy(index)] = _copy(value)
    end

    return setmetatable(new_table, getmetatable(object))
  end

  return _copy(object)
end

AddEventHandler("bms:inventory:addInvSorterEx", function(data)
  if (data and data.sorter) then
    SendNUIMessage({addInvSorter = true, sorter = data.sorter})
  end
end)

RegisterNetEvent("bms:inventory2:updatePlayerInventoryDisplay")
AddEventHandler("bms:inventory2:updatePlayerInventoryDisplay", function(data)
  if (not data or not data.inventory or not data.weapons) then return end

  local ped = PlayerPedId()

  if (data.remOrAddWeps) then
    for model,data in pairs(data.remOrAddWeps) do
      if (data.op == 1) then
        RemoveWeaponFromPed(ped, GetHashKey(model))
      elseif (data.op == 2) then
        local givewep = data.givewep

        if (not givewep) then return end

        GiveWeaponToPed(ped, GetHashKey(givewep.model), givewep.ammo, false, false)
        SetAmmoInClip(ped, GetHashKey(givewep.model), givewep.clipammo)

        if (givewep.attachments) then
          for _,v in pairs(givewep.attachments) do
            local att = v.name

            if (type(att) == "string") then
              att = GetHashKey(att)
            end

            GiveWeaponComponentToPed(ped, GetHashKey(givewep.model), att)
          end
        end
      end
    end
  end

  local weaponsList = deepCopyTable(exports.weaponshop:getWeaponsList())
  local wlist = {}

  for _,v in pairs(weaponsList) do
    wlist[v.model] = v
  end

  SendNUIMessage({updateInventoryItems = true, inventory = data.inventory, weapons = data.weapons, weaponNames = wlist})
  exports.actionmenu:toggleBlockMenu(true)
  SetNuiFocus(true, true)
end)

RegisterNetEvent("bms:inventory2:updatePlayerContainerDisplay")
AddEventHandler("bms:inventory2:updatePlayerContainerDisplay", function(data)
  if (not data or not data.items or not data.type) then
    print("bms:inventory2:updatePlayerContainerDisplay >> Not all data present in payload.")
    return
  end

  local weaponsList = exports.weaponshop:getWeaponsInGame()
  local wlist = {}

  for _,v in pairs(weaponsList) do
    if (v.model) then
      wlist[v.model] = v
    end
  end

  SendNUIMessage({updateTargetContainer = true, items = data.items, weaponNames = wlist, title = data.title, type = data.type})
end)

RegisterNetEvent("bms:inventory2:blockTransferToggle")
AddEventHandler("bms:inventory2:blockTransferToggle", function(val, redrawInventories, useSavedInventories)
  SendNUIMessage({blockTransferToggle = true, val = val})

  if (redrawInventories) then
    SendNUIMessage({redrawInventories = true})
  end

  if (useSavedInventories) then
    SendNUIMessage({redrawSavedInventories = true})
  end
end)

RegisterNetEvent("bms:inventory2:messageAlert")
AddEventHandler("bms:inventory2:messageAlert", function(data)
  if (data and data.msg) then
    SendNUIMessage({showMessageAlert = true, title = data.title, msg = data.msg})
  end
end)

RegisterNUICallback("getCompHashes", function(data, cb)
  if (cb) then
    local compHashes = deepCopyTable(exports.weaponshop:getWsCompHashes())

    for _,v in pairs(compHashes) do
      for _,h in pairs(v.hashes) do
        local att = h

        if (type(h) == "string") then
          h = GetHashKey(h)
        end
      end
    end
    
    cb(json.encode({compHashes = compHashes}))
  end
end)

RegisterNUICallback("bms:inventory2:closeInventory", function(data)
  exports.management:TriggerServerCallback("bms:inventory2:closeInventory", function()
    SetNuiFocus(false, false)
    exports.actionmenu:toggleBlockMenu(false)
  end, data)
end)

RegisterNUICallback("bms:inventory2:transferItem", function(data)
  exports.management:TriggerServerCallback("bms:inventory2:transferItem", function(rdata)
    if (rdata and rdata.success == false and rdata.msg) then
      exports.pnotify:SendNotification({text = rdata.msg, layout = "bottomRight"})
    end
  end, data)
end)