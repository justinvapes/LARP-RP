local DrawMarker = DrawMarker

local stations = {}
local stationMarkers = {}
local playerstations = {}
local identifier = ""
local lasttp = 0
local fuelcanprice = 1500 -- change in server also
local blockfcbuy = false

function getStationInfo(index)
  for _,v in pairs(playerstations) do
    if (v.stationindex == index) then
      return v
    end
  end
end

function getPlayerStationNearCoords(data, cb)
  if (cb) then
    local mstation = 0
    local pos = data.pos
    
    for i,v in ipairs(stations) do
      if (not v.helirefuel) then
        local dist = Vdist(pos.x, pos.y, pos.z, v.ppos.x, v.ppos.y, v.ppos.z)

        if (dist < 50) then
          mstation = i
          break
        end
      end
    end

    if (mstation > 0) then
      cb(playerstations[mstation])
    else
      cb(0)
    end
  end
end

function drawStationText(text)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.32, 0.32)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.475, 0.88)
end

function drawStationText2(text)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.32, 0.32)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.475, 0.925)
end

RegisterNetEvent("bms:businesses:fuel:setstations")
AddEventHandler("bms:businesses:fuel:setstations", function(data)
  if (data.stations) then
    stations = data.stations
  end

  if (data.playerstations) then
    playerstations = data.playerstations
  end

  if (data.identifier) then
    identifier = data.identifier
  end
end)

RegisterNetEvent("bms:businesses:checkcanmanage")
AddEventHandler("bms:businesses:checkcanmanage", function(canmanage, manageid, managetime, funds)
  -- param: bool can manage
  if (canmanage) then
    local station = playerstations[manageid]
    local pfmtstr = ""
    local allow = json.decode(station.deliverallow)

    if (allow) then
      for _,v in pairs(allow) do
        pfmtstr = pfmtstr .. string.format("%s;", v)
      end
    else
      allow = ""
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
      showManager = true,
      manageid = manageid,
      stationname = station.stationname,
      thanksmessage = station.thanksmessage,
      fuelcost = station.fuelprice,
      deltype = station.delivertype,
      delbonus = station.delbonus,
      funds = funds,
      deliverylist = pfmtstr:sub(1, -2) -- remove trailing semicolon
    })
  else
    exports.pnotify:SendNotification({text = string.format("You can only manage this station once every hour.  You can manage this station again on <font color='skyblue'>%s</font>.", managetime)})
  end

  interactWait = false
end)

RegisterNetEvent("bms:businesses:getstationcash")
AddEventHandler("bms:businesses:getstationcash", function(payout)
  exports.pnotify:SendNotification({text = string.format("You have been paid <font color='skyblue'>$%s</font> from this station.", payout)})
  interactWait = false
end)

RegisterNetEvent("bms:businesses:sellstation")
AddEventHandler("bms:businesses:sellstation", function(data)
  local success = data.success
  local msg = data.msg

  if (success) then
    SendNUIMessage({
      closeManager = true
    })

    SetNuiFocus(false, false)
    TriggerEvent("chatMessage", "Sell Success", {0, 255, 0}, "The gas station has been sold.")
    exports.pnotify:SendNotification({text = string.format("Your gas station has been sold to <font color='limegreen'>%s</font>.", data.name)})
  else
    exports.pnotify:SendNotification({text = msg})
  end
end)

RegisterNetEvent("bms:businesses:purchasestation")
AddEventHandler("bms:businesses:purchasestation", function(data)
  if (data) then
    local success = data.success
    local sidx = data.stationindex

    if (success) then
      exports.pnotify:SendNotification({text = string.format("Congratulations on your gas station purchase! <font color='skyblue'>$%s</font> has been taken from your bank account.", data.sellprice)})
      --playerstations = data.playerstations
      TriggerServerEvent("bms:businesses:checkcanmanage", sidx)
    else
      exports.pnotify:SendNotification({text = data.msg})
      interactWait = false
    end
  end
end)

RegisterNetEvent("bms:businesses:teleporttobusiness")
AddEventHandler("bms:businesses:teleporttobusiness", function(station)
  if (station) then
    local ped = PlayerPedId()
    local pos = station.pos

    TriggerServerEvent("bms:teleporter:teleportToPoint", ped, pos)
  end
end)

RegisterNetEvent("bms:businesses:teleportgs")
AddEventHandler("bms:businesses:teleportgs", function()
  lasttp = lasttp + 1
  TriggerEvent("chatMessage", "GSTP", {255, 0, 0}, string.format("GS Index: %s", lasttp))

  local station = stations[lasttp]

  if (station) then
    local ped = PlayerPedId()
    local pos = station.pos

    TriggerServerEvent("bms:teleporter:teleportToPoint", ped, pos)
  end
end)

RegisterNetEvent("bms:businesses:stationfundschange")
AddEventHandler("bms:businesses:stationfundschange", function(data)
  if (data) then
    local success = data.success

    if (success) then
      SendNUIMessage({
        setFunds = true,
        stationmoney = data.amount
      })
    else
      local msg = data.msg

      SendNUIMessage({
        setStatus = true,
        text = msg
      })
    end
  end
end)

RegisterNUICallback("bms:businesses:manage", function(data, cb)
  local name = data.stationname
  local fuelcost = tonumber(data.fuelcost)
  local manageid = data.manageid

  if (name and fuelcost and manageid) then
    TriggerServerEvent("bms:businesses:changestation", data)
  end

  SetNuiFocus(false, false)
end)

RegisterNUICallback("bms:businesses:sellstation", function(data, cb)
  local sellname = data.sellname
  local manageid = data.manageid

  if (sellname and manageid) then
    TriggerServerEvent("bms:businesses:sellstation", data)
  end
end)

RegisterNUICallback("menuclosed", function(data, cb)
  SetNuiFocus(false, false)
end)

RegisterNUICallback("bms:businesses:addstationfunds", function(data, cb)
  local amount = data.amount
  local manageid = data.manageid

  if (amount and manageid) then
    TriggerServerEvent("bms:businesses:addstationfunds", data)
  end
end)

RegisterNUICallback("bms:businesses:remstationfunds", function(data, cb)
  local amount = data.amount
  local manageid = data.manageid

  if (amount and manageid) then
    TriggerServerEvent("bms:businesses:remstationfunds", data)
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    for _,v in pairs(stationMarkers) do
      DrawMarker(1, v.ppos.x, v.ppos.y, v.ppos.z - 1.2, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.4, 0, 255, 0, 130, 0, 0, 0, 0, 0, 0, 0)

      if (v.dist < 10) then
        local dist = #(pos - v.ppos)

        if (dist < 0.6) then
          local stationinfo = getStationInfo(v.idx)

          if (stationinfo) then
            --print(stationinfo.identifier)
            if (stationinfo.identifier == identifier) then
              drawStationText("Press ~b~E~s~ to manage your gas station.")
              
              if (not interactWait) then
                if (IsControlJustReleased(1, 38)) then
                  -- Check if enough time has passed.  Can manage once every 24 hours.
                  interactWait = true
                  TriggerServerEvent("bms:businesses:checkcanmanage", v.idx)
                end
              end
            else
              if (stationinfo.ownerchar == "") then
                drawStationText(string.format("This gas station is for sale for ~g~$%s~s~.  Press ~b~E~s~ to purchase it.", v.sellprice))

                if (not interactWait) then
                  if (IsControlJustReleased(1, 38)) then
                    interactWait = true
                    TriggerServerEvent("bms:businesses:purchasestation", v.idx)
                  end
                end
              else
                drawStationText(string.format("~g~%s\nOwner: %s", stationinfo.stationname, stationinfo.ownerchar))
                drawStationText2(string.format("~s~Press ~b~E~s~ to purchase a Gas Canister for ~g~$%s~s~.", fuelcanprice))

                if (not blockfcbuy) then
                  if (IsControlJustReleased(1, 38)) then
                    if (not HasPedGotWeapon(ped, GetHashKey("WEAPON_PETROLCAN"))) then
                      blockfcbuy = true
                      exports.management:TriggerServerCallback("bms:businesses:purchasefuelcan", function(msg)
                        if (msg) then
                          blockfcbuy = false
                          exports.pnotify:SendNotification({text = msg})
                        end
                      end, v.idx)
                    else
                      exports.pnotify:SendNotification({text = "You already have a gas canister in your inventory."})
                    end
                  end
                end
              end
            end
          else
            drawStationText(string.format("This gas station is for sale for ~g~$%s~s~.  Press ~b~E~s~ to purchase it.", v.sellprice))

            if (not interactWait) then
              if (IsControlJustReleased(1, 38)) then
                interactWait = true
                TriggerServerEvent("bms:businesses:purchasestation", v.idx)
              end
            end
          end
        end
      end
    end

  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1500)

    local pos = GetEntityCoords(PlayerPedId())
    local sMarkers = {}
    local iter = 0

    for i=1,#stations do
      if (stations[i].ppos) then
        local dist = #(pos - stations[i].ppos)

        if (dist < 65) then
          iter = iter + 1
          sMarkers[iter] = stations[i]
          sMarkers[iter].dist = dist
          sMarkers[iter].idx = i
        end
      end
    end

    stationMarkers = sMarkers

  end
end)
