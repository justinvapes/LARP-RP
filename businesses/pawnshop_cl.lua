local DrawMarker = DrawMarker

local pawnshops = {}
local pawnshopMarkers = {}
local pawnblips = {}
local lastpawn = 1
local blocksell = false
local blockbuy = false
local blockmanage = false
local lc
local managetimeout = 10 -- set to 0.01 for testing

local function drawPawnText(text, x, y)
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
  EndTextCommandDisplayText(x, y)
end

function manageTimeout()
  SetTimeout(managetimeout * 1000, function()
    blockmanage = false
  end)
end

RegisterNetEvent("bms:businesses:pshop:updatePawnshops")
AddEventHandler("bms:businesses:pshop:updatePawnshops", function(data)
  if (data.pawnshops) then
    pawnshops = data.pawnshops
  end

  if (data.char) then
    lc = data.char
  end
end)

RegisterNetEvent("bms:businesses:setPsFunds")
AddEventHandler("bms:businesses:setPsFunds", function(amt)
  SendNUIMessage({setPsFunds = true, amount = amt})
end)

RegisterNetEvent("bms:businesses:pshop:resetManagement")
AddEventHandler("bms:businesses:pshop:resetManagement", function()
  blockmanage = false
end)

RegisterNUICallback("bms:businesses:pshop:pawnShopExit", function()
  local ps = pawnshops[lastpawn]

  if (ps) then
    exports.pnotify:SendNotification({text = string.format("<span style='color: skyblue;'>%s</span><br/>%s", ps.stationname, ps.thanksmessage)})
  end
  
  blocksell = false
  TriggerEvent("bms:nuiFocusDisable")
end)

RegisterNUICallback("bms:businesses:psChangeSettings", function(data)  
  if (data and data.markup) then
    TriggerServerEvent("bms:businesses:psChangeSettings", {markup = data.markup, shopname = data.name, thanks = data.thanks, pawnid = lastpawn})
    exports.pnotify:SendNotification({text = string.format("Shop settings successfully saved.  Income cut set to <span style='color: limegreen;'>%s percent</span>.", data.markup)})
  end

  SetNuiFocus(false, false)
  manageTimeout()
end)

RegisterNUICallback("bms:businesses:psExitManager", function(data)
  SetNuiFocus(false, false)
  blockmanage = false
end)

-- TODO change bms:bsqmenu:processcb to a dynamic event name in smartmenu.js
RegisterNUICallback("bms:businesses:pshop:processcb", function(items)
  exports.management:TriggerServerCallback("bms:businesses:pshop:sellPawnItems", function(data, income)
    if (data.failed) then
      exports.pnotify:SendNotification({text = data.msg})
    else
      local items = data
      local names = {}
      local sellstr = ""

      for _,v in pairs(items) do
        sellstr = sellstr .. string.format("%s (%s), ", v.name, v.quantity)
      end

      sellstr = sellstr:sub(1, -3)

      if (sellstr and sellstr ~= "") then
        exports.pnotify:SendNotification({text = string.format("You have been paid <span style='color: lawngreen'>$%s</span> for selling %s.", income, sellstr)})
      end
    end

    blocksell = false
    TriggerEvent("bms:nuiFocusDisable")
  end, {index = lastpawn, items = items.items})
end)

RegisterNUICallback("bms:businesses:psaddfunds", function(data)
  local amount = data.amount

  if (amount) then
    TriggerServerEvent("bms:businesses:psaddfunds", {pawnid = lastpawn, amount = amount})
  end
end)

RegisterNUICallback("bms:businesses:psremfunds", function(data)
  local amount = data.amount

  if (amount) then
    TriggerServerEvent("bms:businesses:psremfunds", {pawnid = lastpawn, amount = amount})
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local pos = GetEntityCoords(PlayerPedId())

    for _,v in pairs(pawnshopMarkers) do
      if (not blocksell) then
        DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.15, 120, 255, 70, 50, 0, 0, 0, 0, 0, 0, 0)

        if (v.dist < 10) then
          local dist = #(pos - v.pos)

          if (dist < 1) then
            -- multi-line 3D text looks really strange when you change camera zoom, we will use the old text draw type
            drawPawnText(v.stationname or "Pawn-It Proshop", 0.475, 0.82)

            if (v.ownerchar ~= lc) then
              drawPawnText("Press ~b~[E]~s~ to use the pawn shop.", 0.475, 0.84)
            else
              drawPawnText("Press ~b~[E]~s~ to ~b~manage~s~ this pawn shop.", 0.475, 0.84)
            end
            
            if (v.ownerchar == "") then
              drawPawnText(string.format("Press ~b~[H]~s~ to purchase this pawn shop for ~g~$%s~s~.", v.price), 0.475, 0.86)
            else
              drawPawnText(string.format("~w~Owned By: ~b~%s~s~.", v.ownerchar), 0.475, 0.86)
            end

            if (IsControlJustReleased(1, 74)) then
              if (v.ownerchar == "" and not blockbuy) then
                blockbuy = true
                exports.management:TriggerServerCallback("bms:businesses:pshop:buyPawnShop", function(data)
                  if (data.msg) then
                    exports.pnotify:SendNotification({text = data.msg})
                  end

                  blockbuy = false
                end, v.idx)
              end
            elseif (IsControlJustReleased(1, 38)) then
              if (v.ownerchar == lc) then
                lastpawn = v.idx
                if (not blockmanage) then
                  blockmanage = true
                  exports.management:TriggerServerCallback("bms:businesses:pshop:getManagement", function(data)
                    SendNUIMessage({showPsManage = true, cash = data.cash, markup = data.markup, itemprev = data.itemprev, shopname = data.shopname, thanksmessage = data.thanksmessage, takemod = data.takemod})
                    SetNuiFocus(true, true)
                  end, v.idx)
                else
                  exports.pnotify:SendNotification({text = "You can not manage this shop yet.  Try again in a little while."})
                end
              else
                blocksell = true
                lastpawn = v.idx
                exports.management:TriggerServerCallback("bms:businesses:pshop:getPawnableItems", function(items)
                  if (#items > 0) then
                    exports.services:loadBsqMenu("businesses", v.stationname or "Pawn-It Proshop", false, true, items, "bms:businesses:pshop:pawnShopExit", "bms:businesses:pshop:processcb")
                  else
                    exports.pnotify:SendNotification({text = "You do not have any pawnable items."})
                    blocksell = false
                  end
                end, v.idx)
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

    if (#pawnblips == 0) then
      for _,v in pairs(pawnshops) do
        local blip = AddBlipForCoord(v.pos)
        
        SetBlipSprite(blip, 374)
        SetBlipColour(blip, 51)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Pawn Shop")
        EndTextCommandSetBlipName(blip)
        
        table.insert(pawnblips, blip)
      end
    end

    local pMarkers = {}
    local iter = 0

    for i=1,#pawnshops do
      local dist = #(pos - pawnshops[i].pos)

      if (dist < 65) then
        iter = iter + 1
        pMarkers[iter] = pawnshops[i]
        pMarkers[iter].dist = dist
        pMarkers[iter].idx = i
      end
    end

    pawnshopMarkers = pMarkers
  end
end)
