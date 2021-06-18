local scubaSpots = {
  {pos = vec3(-1593.023, 5202.957, 4.310)} --/teleport -1593.023 5202.957 4.310
}
local lastScubaSpot
local lastScubaActivated = 0
local scubaCost = 3000
local onBuyCd = false
local male = 1885233650
local female = -1667301416
local equippingScuba = false
local itemName = "Scuba Gear"
local scubaOnCooldown = false
local durationCivScuba = 1200000
local durationScubaCooldown = 1800000
local lastPedComponents
local oxygenWarning = false
local tankModel
local loadedprop
local lastprop = {}
local canActivateScuba = true

local hidepropdebug = false

function drawScubaText(x, y, z, text)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, 0.4 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
  end
end

local function setLastScubaActivated()
  lastScubaActivated = GetGameTimer()
  oxygenWarning = false
end

local function getLastPedComponents(ped)
  lastPedComponents = {}
  --print("~~~~~~~~~~~~ LIST PED COMPONENTS ~~~~~~~~~~~~")
  for i = 0, 11 do
    local did = GetPedDrawableVariation(ped, i)
    local tid = GetPedTextureVariation(ped, i)
    --print(string.format("%s, %s, %s", i, did, tid))
    table.insert(lastPedComponents, {d = did, t = tid})
  end
end

local function setLastPedComponents(ped)
  -- load components back in
  --print("~~~~~~~~~~~~ SET PED COMPONENTS ~~~~~~~~~~~~")
  ClearPedProp(ped, 1)
  ClearPedProp(ped, 0)
  for i,v in ipairs(lastPedComponents) do
    --print(string.format("%s, %s, %s", i - 1, v.d, v.t))
    SetPedComponentVariation(ped, i - 1, v.d, v.t, 2)
  end
end

function AttachEntityToPed(prop, boneId, x, y, z, rx, ry, rz)
  local ped = PlayerPedId()
  local boneidx = GetPedBoneIndex(ped, boneId)
  local obj = CreateObject(prop, 1729.73, 6403.90, 34.56, true, 0, 0)
      
  AttachEntityToEntity(obj, ped, boneidx, x, y, z, rx, ry, rz, false, false, false, false, 2, true)

  return obj
end

RegisterNetEvent("jobs:diving:addTankProp")
AddEventHandler("jobs:diving:addTankProp", function(prop, offx, offy, offz, xrot, yrot, zrot, hidedebug)
  hidepropdebug = true --hidedebug or false
  local ped = PlayerPedId()
  --local offx, offy, offz, xrot, yrot, zrot, hidedebug = 0.015, -0.20, 0, 180.0, 90.0, 0, false
  local prop = "p_s_scuba_tank_s"
  if (prop or preset) then
    if (loadedprop and not mod) then
      DeleteEntity(loadedprop)
      loadedprop = nil
      ClearPedTasks(ped)
    else
      if (mod) then
        DeleteEntity(loadedprop)
        loadedprop = nil
      end
      
      local ped = PlayerPedId()
      local boneId = 57597
      local mhash = GetHashKey(prop)
      
      RequestModel(mhash)
  
      while not HasModelLoaded(mhash) do
        Wait(100)
      end

      loadedprop = AttachEntityToPed(mhash, boneId, 0.015, -0.20, 0, 180.0, 90.0, 0)
      
      SetModelAsNoLongerNeeded(mhash)
    end
  end
end)

RegisterNetEvent("jobs:diving:clearScubaTank")
AddEventHandler("jobs:diving:clearScubaTank", function()
  local ped = PlayerPedId()
  if loadedprop ~= nil then
    DeleteEntity(loadedprop)
    loadedprop = nil
  end
end)

RegisterNetEvent("jobs:diving:expireScuba")
AddEventHandler("jobs:diving:expireScuba", function()
  local ped = PlayerPedId()
  TriggerEvent("jobs:diving:clearScubaTank")
  scubaOnCooldown = false
  SetEnableScuba(ped, false)
  SetPedMaxTimeUnderwater(ped, 5.00)
  setLastPedComponents(ped)
  exports.pnotify:SendNotification({text = "Your tank has ran out of <font color='lawngreen'>Oxygen</font>"})
end)

RegisterNetEvent("jobs:diving:toggleCivScuba")
AddEventHandler("jobs:diving:toggleCivScuba", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local genderEntityModel = GetEntityModel(ped)
  getLastPedComponents(ped)

  if (canActivateScuba) then
    Citizen.CreateThread(function()
      equippingScuba = true
      local equipTime = 10000
      while (equippingScuba) do
        Wait(1000)
        equipTime = equipTime - 1000
        
        if (equipTime <= 0) then
          SendNUIMessage({hideJobProgress = true})
          TriggerEvent("jobs:diving:addTankProp")
          SetEnableScuba(ped, true)
          SetPedMaxTimeUnderwater(ped, 200.00)
          ClearPedProp(ped, 1)
          ClearPedProp(ped, 0)
          if (genderEntityModel == male) then
            SetPedComponentVariation(ped, 1, 0, 0, 2)
            SetPedPropIndex(ped, 1, 26, 6, true)
          elseif (genderEntityModel == female) then
            SetPedComponentVariation(ped, 1, 0, 0, 2)
            SetPedPropIndex(ped, 1, 28, 6, true)
          else
            print("no gender")
          end
          exports.pnotify:SendNotification({text = string.format("You have equipped <font color='lawngreen'>%s</font>", itemName)})
          equippingScuba = false
        else
          SendNUIMessage({updateJobProgress = true, title = "Equipping Scuba Gear", maxvalue = 10, progvalue = equipTime / 1000})
        end
      end
    end)
    setLastScubaActivated()
    scubaOnCooldown = true
    canActivateScuba = false
    TriggerServerEvent("jobs:diving:removeScubaFromInventory")
  else
    exports.pnotify:SendNotification({text = "Your lungs can't handle another Scuba session yet."})
  end
end)

RegisterNetEvent("jobs:diving:toggleCopScuba")
AddEventHandler("jobs:diving:toggleCopScuba", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local offset = GetOffsetFromEntityInWorldCoords(ped, 0, 5.0, 0)
  local detVeh = getVehicleInDirection(pos, offset, ped)
  local cVeh = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 127)
  local genderEntityModel = GetEntityModel(ped)
  getLastPedComponents(ped)

  if (detVeh or cVeh) then
    local detModel = GetEntityModel(detVeh)
    local cModel = GetEntityModel(cVeh)
    local hasEmergencyVeh = false
    
    if ((GetVehicleClass(detVeh) == 18) or (GetVehicleClass(cVeh) == 18) or (GetEntityModel(detVeh) == GetHashKey("predator")) or (GetEntityModel(cVeh) == GetHashKey("predator"))) then
      hasEmergencyVeh = true
    end
    
    if (canActivateScuba) then
      if (hasEmergencyVeh) then
        Citizen.CreateThread(function()
          equippingScuba = true
          local equipTime = 8000
          while (equippingScuba) do
            Wait(1000)
            equipTime = equipTime - 1000
            if (equipTime <= 0) then
              SendNUIMessage({hideJobProgress = true})
              TriggerEvent("jobs:diving:addTankProp")
              SetEnableScuba(ped, true)
              SetPedMaxTimeUnderwater(ped, 400.00)
              ClearPedProp(ped, 0)
              ClearPedProp(ped, 1)
              if (genderEntityModel == male) then
                SetPedComponentVariation(ped, 1, 0, 0, 2)
                SetPedComponentVariation(ped, 3, 1, 0, 1)
                SetPedComponentVariation(ped, 4, 94, 2, 1)
                SetPedComponentVariation(ped, 5, 0, 0, 1)
                SetPedComponentVariation(ped, 6, 67, 13, 1)
                SetPedComponentVariation(ped, 7, 0, 0, 1)
                SetPedComponentVariation(ped, 8, 15, 0, 1)
                SetPedComponentVariation(ped, 9, 0, 0, 1)
                SetPedComponentVariation(ped, 10, 0, 0, 1)
                SetPedComponentVariation(ped, 11, 243, 2, 1)
                SetPedPropIndex(ped, 1, 26, 2, true)
              elseif (genderEntityModel == female) then
                SetPedComponentVariation(ped, 1, 0, 0, 2)
                SetPedComponentVariation(ped, 3, 3, 0, 1)
                SetPedComponentVariation(ped, 4, 97, 2, 1)
                SetPedComponentVariation(ped, 5, 0, 0, 1)
                SetPedComponentVariation(ped, 6, 70, 2, 1)
                SetPedComponentVariation(ped, 7, 0, 0, 1)
                SetPedComponentVariation(ped, 8, 3, 0, 1)
                SetPedComponentVariation(ped, 9, 0, 0, 1)
                SetPedComponentVariation(ped, 10, 0, 0, 1)
                SetPedComponentVariation(ped, 11, 251, 2, 1)
                SetPedPropIndex(ped, 1, 28, 2, true)
              else
                print("no gender detected")
              end
              
              exports.pnotify:SendNotification({text = string.format("You have equipped <font color='lawngreen'>%s</font>", itemName)})
              equippingScuba = false
              GiveWeaponToPed(ped, "WEAPON_KNIFE", 1000, 0, false)
            else
              SendNUIMessage({updateJobProgress = true, title = "Equipping Scuba Gear", maxvalue = 10, progvalue = equipTime / 1000})
            end
          end
        end)
        setLastScubaActivated()
        scubaOnCooldown = true
        canActivateScuba = false
      else
        exports.pnotify:SendNotification({text = "You must be near an emergency vehicle to grab your scuba gear."})
      end
    else
      exports.pnotify:SendNotification({text = "Your lungs can't handle another Scuba session yet."})
    end
  else
    exports.pnotify:SendNotification({text = "You must be near an emergency vehicle to grab your scuba gear."})
  end
end)

RegisterNetEvent("jobs:diving:buyScuba")
AddEventHandler("jobs:diving:buyScuba", function() 
  -- Check inventory and see if they already have Scuba
  local names = {}
  table.insert(names, "Scuba Gear")
  --table.insert(names, "Oxygen Tank")
  
  TriggerServerEvent("bms:inv:getItemsInInv", names, "bms:jobs:diving:getInventoryItemsForPurchase")              
end)


RegisterNetEvent("bms:jobs:diving:getInventoryItemsForPurchase")
AddEventHandler("bms:jobs:diving:getInventoryItemsForPurchase", function(items)
  local allowBuy = false
  
  Citizen.Trace(#items)
  
  if (#items > 0) then
    for _,v in pairs(items) do
      if (v.name == "Scuba Gear") then
        local qty = v.quantity
        
        if (qty < 1) then
          allowBuy = true
        end
      -- elseif (v.name == "Oxygen Tank") then
      --   allowBuy = false
      end
    end
    
    if (allowBuy) then
      local charmoney = 0
      
      exports.inventory:getCharMoney(function(amt)
        charmoney = amt
      end)
      
      if (charmoney >= scubaCost) then
        TriggerServerEvent("bms:jobs:diving:processScubaPurchase", scubaCost, 1)
        exports.pnotify:SendNotification({text = "You have purchased Scuba Gear."})
      else
        exports.pnotify:SendNotification({text = "You can not afford to buy this."})
      end
    else
      exports.pnotify:SendNotification({text = "You can have a maximum of 1 Scuba Gear in your inventory at a time."})
      onBuyCd = false
    end
  else -- doesnt exist in inv
    local charmoney = 0
      
    exports.inventory:getCharMoney(function(amt)
      charmoney = amt
    end)
    
    if (charmoney >= scubaCost) then
      TriggerServerEvent("bms:jobs:diving:processScubaPurchase", scubaCost, 1)
      exports.pnotify:SendNotification({text = "You have purchased Scuba Gear."})
    else
      exports.pnotify:SendNotification({text = "You can not afford to buy this."})
      onBuyCd = false
    end
  end
end)

RegisterNetEvent("bms:jobs:diving:buyProcessComplete")
AddEventHandler("bms:jobs:diving:buyProcessComplete", function()
  onBuyCd = false
end)


Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    --SetPedMaxTimeUnderwater(ped, 500.00)
    for _,v in pairs(scubaSpots) do
      local dist = #(pos - v.pos)

      if (dist < 25.0 and dist > 1.2) then
        drawScubaText(v.x, v.y, v.z, "Scuba Shop")
      end

      if (dist < 1.2) then
        drawScubaText(v.x, v.y, v.z, string.format("Purchase some Scuba Gear for $%s", scubaCost))

        if (IsControlJustReleased(1, 38)) then
          lastScubaSpot = v
          if (not onBuyCd) then
            onBuyCd = true
            TriggerEvent("jobs:diving:buyScuba")
          end
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1000)    
    local scubaTimeDiff = lastScubaActivated + durationCivScuba
    if (scubaOnCooldown) then
      if (GetGameTimer() >= scubaTimeDiff) then
        TriggerEvent("jobs:diving:expireScuba")
      elseif ((GetGameTimer() >= (scubaTimeDiff-60000) and not oxygenWarning)) then
        oxygenWarning = true
        exports.pnotify:SendNotification({text = "Your oxygen supply will run out in about a minute."})
      end
    elseif (GetGameTimer() >= (scubaTimeDiff + durationScubaCooldown)) then
      canActivateScuba = true
    end
  end
end)
