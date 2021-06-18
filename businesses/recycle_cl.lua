local recycleCenters = {}
local recycleBlips = {}
local recycleMarkers = {}
local lastCenter = 0
local blockInput = false
local callbackBlock = false

local function checkManage(index)
  if (index) then
    exports.management:TriggerServerCallback("bms:businesses:recycle:retrieveManageInfo", function(data)
      if (data and data.owner and data.center) then
        local shop = data.center

        SetNuiFocus(true, true)
        SendNUIMessage({
          showRecycleManage = true, 
          cash = shop.cashwaiting, 
          prices = shop.data.prices or {plastic = 0, metal = 0, ceram = 0, elec = 0}, 
          centerName = shop.stationname, 
          thanksmessage = shop.thanksmessage, 
          upgrades = shop.data.upgrades,
          blipcolors = data.upgrades.blipcolors,
          upgradePrices = data.upgrades.prices,
          stock = shop.data.stock
        })
      end

      blockInput = false
    end, index)
  end
end

RegisterNUICallback("bms:businesses:recycle:hidePanel", function()
  SetNuiFocus(false, false)
  blockInput = false
end)

RegisterNUICallback("bms:businesses:recycle:saveCenterInfo", function(data)
  if (data and not callbackBlock) then
    callbackBlock = true
    
    exports.management:TriggerServerCallback("bms:businesses:recycle:saveCenterInfo", function(ret)
      if (ret.success) then
        SendNUIMessage({
          sendRecycleNotification = true,
          text = "Center settings successfully <font color='limegreen'>saved</font>."
        })
      else
        SendNUIMessage({
          sendRecycleNotification = true,
          text = string.format("You cannot modify center settings for <font color='red'>%s minutes</font>.", ret.canManage)
        })
      end

      callbackBlock = false
    end, {prices = data.prices, name = data.name, thanks = data.thanks, idx = lastCenter})
  end
end)

RegisterNUICallback("bms:businesses:recycle:addFunds", function(data)
  local cash = data.cash

  if (cash and not callbackBlock) then
    callbackBlock = true

    exports.management:TriggerServerCallback("bms:businesses:recycle:checkAddFunds", function(ret)
      if (ret.success) then
        SendNUIMessage({
          updateRecycleCash = true,
          cash = ret.newCash
        })
      else
        SendNUIMessage({
          sendRecycleNotification = true,
          text = ret.msg
        })
      end

      callbackBlock = false
    end, {cash = cash, idx = lastCenter})
  end
end)

RegisterNUICallback("bms:businesses:recycle:remFunds", function(data)
  local cash = data.cash

  if (cash and not callbackBlock) then
    callbackBlock = true

    exports.management:TriggerServerCallback("bms:businesses:recycle:checkRemFunds", function(ret)
      if (ret.success) then
        SendNUIMessage({
          updateRecycleCash = true,
          cash = ret.newCash
        })
      else
        SendNUIMessage({
          sendRecycleNotification = true,
          text = ret.msg
        })
      end

      callbackBlock = false
    end, {cash = cash, idx = lastCenter})
  end
end)

RegisterNUICallback("bms:businesses:recycle:saveCenterUpgrades", function(data)
  if (data and not callbackBlock) then
    callbackBlock = true

    exports.management:TriggerServerCallback("bms:businesses:recycle:saveCenterUpgrades", function(ret)
      if (ret.success) then
        SendNUIMessage({
          updateRecycleUpgrades = true,
          cash = ret.newCash,
          upgrades = ret.upgrades
        })
      else
        SendNUIMessage({
          sendRecycleNotification = true,
          text = ret.msg
        })
      end

      callbackBlock = false
    end, {blcolor = data.blcolor, idx = lastCenter})
  end
end)

RegisterNUICallback("bms:businesses:recycle:sellStock", function(data)
  if (data and not callbackBlock) then
    callbackBlock = true

    exports.management:TriggerServerCallback("bms:businesses:recycle:sellStock", function(ret)
      if (ret.success) then
        SendNUIMessage({
          updateRecycleCash = true,
          cash = ret.newCash
        })
        SendNUIMessage({
          zeroRecycleStock = true
        })
      else
        SendNUIMessage({
          sendRecycleNotification = true,
          text = ret.msg
        })
      end

      callbackBlock = false
    end, {idx = lastCenter})
  end
end)

RegisterNetEvent("bms:businesses:recycle:sendShops")
AddEventHandler("bms:businesses:recycle:sendShops", function(centers, ownIndex)
  recycleCenters = centers

  if (ownIndex) then
    recycleCenters[ownIndex].isOwner = true
  end
end)

RegisterNetEvent("bms:businesses:recycle:updateCenters")
AddEventHandler("bms:businesses:recycle:updateCenters", function(centers)
  local centers = centers

  for k,v in pairs(recycleCenters) do
    if (v.isOwner) then
      centers[k].isOwner = true
    end
  end

  recycleCenters = centers

  for _,v in pairs(recycleBlips) do
    RemoveBlip(v)
  end

  recycleBlips = {}
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local pos = GetEntityCoords(PlayerPedId())

    for _,v in pairs(recycleMarkers) do
      DrawMarker(1, v.manageSpot.x, v.manageSpot.y, v.manageSpot.z - 1.05, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.3, 242, 135, 5, 175, 0, 0, 0, 0, 0, 0, 0)

      for k,recyclePos in pairs(v.recycleSpots) do
        DrawMarker(1, recyclePos.pos.x, recyclePos.pos.y, recyclePos.pos.z - 1.2, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.4, 38, 179, 44, 175, 0, 0, 0, 0, 0, 0, 0)

        if (recyclePos.dist < 8) then
          local rdist = #(pos - recyclePos.pos)

          if (rdist < 0.9) then
            drawBusinessText(string.format("Press ~b~[E]~s~ to sell your ~y~%s~s~ for ~g~$%s~s~/item.", k, recyclePos.price))

            if (IsControlJustReleased(1, 38) and not blockInput) then -- E
              lastCenter = v.idx
              blockInput = true
              exports.vehicles:blockTrunk(true)
              exports.inventory:blockTrade(true)
              exports.inventory:blockInventoryUse(true)

              exports.management:TriggerServerCallback("bms:businesses:recycle:sellItems", function(ret)
                if (ret and ret.msg) then
                  exports.pnotify:SendNotification({text = ret.msg})
                end
                blockInput = false
                exports.vehicles:blockTrunk(false)
                exports.inventory:blockTrade(false)
                exports.inventory:blockInventoryUse(false)
              end, {item = k, idx = lastCenter})
            end
          end
        end
      end

      if (v.dist < 10) then
        local dist = #(pos - v.manageSpot)

        if (dist < 0.9) then
          if (v.isOwner) then
            drawBusinessText("Press ~b~[E]~s~ to manage your ~g~recycle center~s~.")

            if (IsControlJustReleased(1, 38) and not blockInput) then -- E
              lastCenter = v.idx
              blockInput = true
              checkManage(v.idx)
            end
          else
            drawBusinessText(string.format("~g~%s~s~\nOwner: ~b~%s", v.centerName, v.owner))
          end
        end
      else
        lastCenter = 0
      end
    end

  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1500)

    if (#recycleBlips == 0) then
      for _,v in pairs(recycleCenters) do
        local blip = AddBlipForCoord(v.manageSpot)
        
        SetBlipSprite(blip, 467)
        if (v.blcolor) then
          SetBlipColour(blip, v.blcolor)
        else
          SetBlipColour(blip, 69)
        end

        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.centerName)
        EndTextCommandSetBlipName(blip)
        
        table.insert(recycleBlips, blip)
      end
    end

    local pos = GetEntityCoords(PlayerPedId())
    local rMarkers = {}
    local iter = 0

    for i=1,#recycleCenters do
      local dist = #(pos - recycleCenters[i].manageSpot)

      if (dist < 65) then
        iter = iter + 1
        rMarkers[iter] = recycleCenters[i]
        rMarkers[iter].dist = dist
        rMarkers[iter].idx = i

        for _,spot in pairs(recycleCenters[i].recycleSpots) do
          spot.dist = #(pos - spot.pos)
        end
      end
    end

    recycleMarkers = rMarkers
  end
end)
