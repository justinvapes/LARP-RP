local DrawMarker = DrawMarker

local mechanicShops = {}
local mechanicMarkers = {}
local blockInput = false
local callbackBlock = false
local lastShop = 0

local function drawMechText(text, y)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.32, 0.32)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(0.485, y)
end

local function checkManage(index)
  if (index) then
    exports.management:TriggerServerCallback("bms:businesses:mech:retrieveManageInfo", function(data)
      if (data and data.owner and data.shop) then
        local shop = data.shop

        SetNuiFocus(true, true)
        SendNUIMessage({
          showMsManage = true, 
          cash = shop.cashwaiting, 
          markup = shop.data.markup or 1.0, 
          shopname = shop.stationname, 
          thanksmessage = shop.thanksmessage, 
          emps = shop.data.emps,
          upgrades = shop.data.upgrades,
          blipcolors = data.upgrades.blipcolors,
          prices = data.upgrades.prices
        })
      end

      blockInput = false
    end, index)
  end
end

local function checkToolShop(index)
  if (index) then
    exports.management:TriggerServerCallback("bms:businesses:mech:checkToolShopUse", function(data)
      if (data and data.valid and data.items) then
        exports.services:loadBsqMenu("businesses", "Mechanic Tool Shop", true, false, data.items, "bms:businesses:mech:toolShopExit", nil, "bms:businesses:mech:toolShopBuyConfirm")
      else
        exports.pnotify:SendNotification({text = "You can only open the <font color='skyblue'>Tool Shop</font> if you work here."})
        blockInput = false
      end
    end, index)
  end
end

RegisterNUICallback("bms:businesses:mech:toolShopExit", function()
  blockInput = false
  SetNuiFocus(false, false)
end)

RegisterNUICallback("bms:businesses:mech:toolShopBuyConfirm", function(data)
  exports.management:TriggerServerCallback("bms:businesses:mech:toolShopBuy", function(data)
    blockInput = false
    SetNuiFocus(false, false)

    if (data.success) then
      exports.pnotify:SendNotification({text = data.msg})

      if (data.fullMsg) then
        exports.pnotify:SendNotification({text = data.fullMsg})
      end
    else
      if (data.msg) then
        exports.pnotify:SendNotification({text = data.msg})
      end
    end
  end, {items = data.items})
end)

RegisterNUICallback("bms:businesses:mech:saveShopInfo", function(data)
  if (data) then
    exports.management:TriggerServerCallback("bms:businesses:mech:saveShopInfo", function(ret)
      if (ret.success) then
        SendNUIMessage({
          sendMechNotification = true,
          text = "Shop settings successfully <font color='limegreen'>saved</font>."
        })
      else
        SendNUIMessage({
          sendMechNotification = true,
          text = string.format("You cannot modify shop settings for <font color='red'>%s minutes</font>.", ret.canManage)
        })
      end
    end, {markup = data.markup, name = data.name, thanks = data.thanks, idx = lastShop})
  end
end)

RegisterNUICallback("bms:businesses:mech:hidePanel", function()
  SetNuiFocus(false, false)
  blockInput = false
end)

RegisterNUICallback("bms:businesses:mech:addFunds", function(data)
  local cash = data.cash

  if (cash and not callbackBlock) then
    callbackBlock = true

    exports.management:TriggerServerCallback("bms:businesses:mech:checkAddFunds", function(ret)
      if (ret.success) then
        SendNUIMessage({
          updateMechCash = true,
          cash = ret.newCash
        })
      else
        SendNUIMessage({
          sendMechNotification = true,
          text = ret.msg
        })
      end

      callbackBlock = false
    end, {cash = cash, idx = lastShop})
  end
end)

RegisterNUICallback("bms:businesses:mech:remFunds", function(data)
  local cash = data.cash

  if (cash and not callbackBlock) then
    callbackBlock = true

    exports.management:TriggerServerCallback("bms:businesses:mech:checkRemFunds", function(ret)
      if (ret.success) then
        SendNUIMessage({
          updateMechCash = true,
          cash = ret.newCash
        })
      else
        SendNUIMessage({
          sendMechNotification = true,
          text = ret.msg
        })
      end

      callbackBlock = false
    end, {cash = cash, idx = lastShop})
  end
end)

RegisterNUICallback("bms:businesses:mech:saveShopUpgrades", function(data)
  if (data) then
    callbackBlock = true

    exports.management:TriggerServerCallback("bms:businesses:mech:saveShopUpgrades", function(ret)
      if (ret.success) then
        SendNUIMessage({
          updateMechUpgrades = true,
          cash = ret.newCash,
          upgrades = ret.upgrades
        })
      else
        SendNUIMessage({
          sendMechNotification = true,
          text = ret.msg
        })
      end

      callbackBlock = false
    end, {blcolor = data.blcolor, customs = data.customs, idx = lastShop})
  end
end)

RegisterNUICallback("bms:businesses:mech:removeMechanic", function(name)
  print(name)
  TriggerServerEvent("bms:businesses:mech:removeMechanic", {name = name, idx = lastShop})
end)

RegisterNetEvent("bms:businesses:mech:sendShops")
AddEventHandler("bms:businesses:mech:sendShops", function(mechShops, empStatus, isOwner)
  if (isOwner) then
    exports.actionmenu:addAction("mechanic", "hiremech", "none", "Hire Mechanic (Closest Player)", 4, "")
  end

  if (mechanicShops and #mechanicShops == 0) then
    mechanicShops = mechShops
  end

  if (empStatus) then
    mechanicShops = mechShops

    for _,v in pairs(empStatus) do
      mechanicShops[v.idx].isOwner = v.isOwner
      mechanicShops[v.idx].isEmp = v.isEmp
    end

    TriggerEvent("bms:jobs:mech:sendEmployment", empStatus)
  else
    for i,v in ipairs(mechanicShops) do
      local isOwner = v.isOwner
      local isEmp = v.isEmp

      mechanicShops[i] = mechShops[i]
      mechanicShops[i].isOwner = isOwner
      mechanicShops[i].isEmp = isEmp
    end
  end
end)

AddEventHandler("bms:businesses:mech:repairSpotUsed", function(data)
  if (data and data.did and data.repCosts) then
    TriggerServerEvent("bms:businesses:mech:repairSpotUsed", {did = data.did, repCosts = data.repCosts})
  end
end)

AddEventHandler("bms:businesses:mech:hireMechanic", function(detPed)
  if (detPed and detPed > 0) then
    TriggerServerEvent("bms:businesses:mech:attemptHireMechanic", detPed)
  end
end)

RegisterNetEvent("bms:businesses:mech:attemptHireMechanic")
AddEventHandler("bms:businesses:mech:attemptHireMechanic", function(ownerName, ownerSrc)
  exports.vehshop:showHireDialog(ownerName, ownerSrc, "Repair Shop Mechanic", "bms:businesses:mech:hireDialogYes", "bms:cardealer:dialogNo")
end)

AddEventHandler("bms:businesses:mech:hireDialogYes", function(ownerSrc)
  TriggerServerEvent("bms:businesses:mech:hireMech", ownerSrc)
  SetNuiFocus(false, false)
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local pos = GetEntityCoords(PlayerPedId())

    for _,v in pairs(mechanicMarkers) do
      DrawMarker(1, v.manageSpot.x, v.manageSpot.y, v.manageSpot.z - 1.2, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.4, 193, 194, 214, 150, 0, 0, 0, 0, 0, 0, 0)

      if (v.dist < 10) then
        local dist = #(pos - v.manageSpot)

        if (dist < 0.9) then
          if (v.isOwner) then
            drawMechText("Press ~b~[E]~s~ to manage your ~g~repair business~s~.", 0.83)

            if (IsControlJustReleased(1, 38) and not blockInput) then -- E
              lastShop = v.idx
              blockInput = true
              checkManage(v.idx)
            end
          else
            drawMechText(string.format("~g~%s~s~\nOwner: ~b~%s", v.shopName, v.owner), 0.81)
          end

          drawMechText("Press ~b~[H]~s~ to open the ~b~Mechanic Tool Shop~s~.", 0.855)

          if (IsControlJustReleased(1, 74) and not blockInput) then -- H
            lastShop = v.idx
            blockInput = true
            checkToolShop(v.idx)
          end
        end
      else
        lastShop = 0
      end
    end

  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1500)

    local pos = GetEntityCoords(PlayerPedId())
    local mMarkers = {}
    local iter = 0

    for i=1,#mechanicShops do
      local dist = #(pos - mechanicShops[i].manageSpot)

      if (dist < 65) then
        iter = iter + 1
        mMarkers[iter] = mechanicShops[i]
        mMarkers[iter].dist = dist
        mMarkers[iter].idx = i

        if (mechanicShops[i].customs and mechanicShops[i].customs.prop and not mechanicShops[i].customs.spawnedProp) then
          local hash = GetHashKey(mechanicShops[i].customs.prop.obj)
          RequestModel(hash)
          while (not HasModelLoaded(hash)) do
            Wait(10)
          end
          
          local obj = CreateObject(hash, mechanicShops[i].customs.prop.pos, false, true, false)
          while (not DoesEntityExist(obj)) do
            Wait(10)
          end
          FreezeEntityPosition(obj, true)

          if (mechanicShops[i].customs.prop.heading) then
            SetEntityHeading(obj, mechanicShops[i].customs.prop.heading)
          end
          SetModelAsNoLongerNeeded(hash)
    
          mechanicShops[i].customs.spawnedProp = obj
        end
      elseif (mechanicShops[i].customs and mechanicShops[i].customs.prop and mechanicShops[i].customs.spawnedProp) then
        DeleteObject(mechanicShops[i].customs.spawnedProp)
        mechanicShops[i].customs.spawnedProp = nil
      end
    end

    mechanicMarkers = mMarkers

  end
end)
