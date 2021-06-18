local table_insert = table.insert
local showInventory = false
local blockInput = false
local inventory = {}
local charmoney = 0
local candrop = true
local dropDisp = false
local giveDisp = false
local dropDispTime = 5000
local giveDispTime = 5000
local dropDispElapsed = 0
local giveDispElapsed = 0
local dropItems = {}
local giveItems = {}
local lastGiveChar = ""
local spamguard = false
local dspamguard = false
local dtime = 0
local dduration = 2000
local cantrade = true
local blockInv = false
local blockTradeDrop = false
local blockinvopen = false
local tradeblocked = false
local waitingtrade = false
local robbingBank = false
local vaultcoords = {
  {x = -105.44, y = 6471.79, z = 31.63}, -- Paleto Blvd                 /teleport -105.44 6471.79 31.63
  {x = 253.41, y = 228.33, z = 101.68}, -- Alta St with door            /teleport 253.41 228.33 101.68
  {x = -2956.77, y = 481.62, z = 15.70}, -- Great Ocean Hwy             /teleport -2956.77 481.62 15.70
  {x = 146.89, y = -1045.83, z = 29.37}, -- Vespucci Blvd & Elgin Ave   /teleport 146.89 -1045.83 29.37
  {x = 1176.25, y = 2712.68, z = 38.09}, -- Route 68                    /teleport 1176.25 2712.68 38.09
  {x = 311.27, y = -284.22, z = 54.16}, -- Meteor St & Hawick Ave       /teleport 311.27 -284.22 54.16
  {x = -1210.99, y = -336.39, z = 37.78} -- Boulevard Del Perro         /teleport -1210.99 -336.39 37.78
}
local droppedItems = {}
local genericItemPack = "prop_drug_package_02"
local itemPickupBlock = false
local pickupAnim = {dict = "random@domestic", anim = "pickup_low", flag = 48}
local closedTime = {cur = 0, time = 3000}

function getClosedTime()
  return closedTime
end

function setClosedTime(val)
  closedTime.cur = val
end

function file_exists(name)
  local so = LoadResourceFile("inventory", name)

  return so and so ~= ""
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function getClosestPlayer()
  local players = GetActivePlayers()
  local closestDistance = -1
  local closestPlayer = -1
  local ped = PlayerPedId()
  local ppos = GetEntityCoords(ped)

  for i=1,#players do
    local target = GetPlayerPed(players[i])

    if (target ~= ped) then
      local tpos = GetEntityCoords(target)
      local dist = #(tpos - ppos)
      
      if (closestDistance == -1 or closestDistance > dist) then
        closestPlayer = players[i]
        closestDistance = dist
      end
    end
  end

  return closestPlayer, closestDistance
end

function setCanTrade(val)
  cantrade = val
end

function getCanTrade()
  return cantrade
end

function itemExistsInInv(name, callback)
  local item

  for _,v in pairs(inventory) do
    if (v.name == name) then
      item = v
      break
    end
  end

  if (callback) then
    callback(item)
  end

  return item
end

--[[ Deprecated since the list is sent in full to the client instead of one by one. ]]
function addItemToInv(name, quantity)
  local item = itemExistsInInv(name)
  
  if (not item) then
    local newItem = {}

    newItem.name = name
    newItem.quantity = quantity
    table.insert(inventory, newItem)
  else
    item.quantity = quantity
  end
end

function remItemFromInv(name, quantity)
  --Citizen.Trace("remitem")
  local delidx = 0
  
  for i = 1, #inventory do
    if (inventory[i].name == name) then
      local newqty = inventory[i].quantity - quantity
      
      if (newqty <= 0) then
        delidx = i
      else
        inventory[i].quantity = newqty
      end
    end
  end
  
  if (delidx > 0) then
    table.remove(inventory, delidx)
  end
end

function getInventoryItem(name, callback)
  for _,v in pairs(inventory) do
    if (v.name == name) then
      if (callback) then
        callback(v)
      end
    end
  end
end

function getInventory(callback)
  if (inventory) then
    if (callback) then
      callback(inventory)
    end

    return inventory
  end
end

function setCharMoney(amount)
  charmoney = amount
end

function getCharMoney(cb)
  cb(charmoney)
end

function addDropItem(item, qty)
  if (item) then
    local exists = false
    
    for _,v in pairs(dropItems) do
      if (v.name == item) then
        if (v.quantity) then
          if (qty) then
            v.quantity = v.quantity + qty
          else
            v.quantity = v.quantity + 1
          end
        else
          if (qty) then
            v.quantity = qty
          else
            v.quantity = 1
          end
        end
        
        exists = true
      end
    end
    
    if (not exists) then
      local ditem

      if (qty) then
        ditem = {name = item, quantity = qty}
      else
        ditem = {name = item, quantity = 1}
      end

      table.insert(dropItems, ditem)      
    end
  end
end

function addGiveItem(item, quantity)
  if (item) then
    local exists = false
    
    for _,v in pairs(giveItems) do
      if (v.name == item) then
        if (v.quantity) then
          v.quantity = v.quantity + 1
        else
          v.quantity = 1
        end
        
        exists = true
      end
    end
    
    if (not exists) then
      local aitem = {name = item, quantity = quantity or 1}
      table.insert(giveItems, aitem)
    end
  end
end

function blockInventoryUse(toggle)
  blockInv = toggle
  SendNUIMessage({blockInvUse = true, toggle = toggle})
  --print(string.format("(fn) Item use blocked, toggle: %s, time %s", toggle, GetGameTimer()))
end

function blockInventoryOpen(toggle)
  blockinvopen = toggle
end

function unblockTransfer()
  SendNUIMessage({
    unblockTransfer = true
  })
end

function getWeaponAttachmentDetails(att, cb)
  local sup, mag, scp, grp, drm, fls
  
  exports.weaponshop:getWsCompHashes(function(wscomphashes)
    for _,a in pairs(att) do
      for _,v in pairs(wscomphashes) do
        for _,h in pairs(v.hashes) do
          local att = h

          if (type(h) == "string") then
            att = GetHashKey(h)
          end

          if (a.name == h) then
            if (v.name == "Supressor") then
              sup = true
              break
            elseif (v.name == "Extended Magazine") then
              mag = true
              break
            elseif (v.name == "Advanced Grip") then
              grp = true
              break
            elseif (v.name == "Scope") then
              scp = true
              break
            elseif (v.name == "Drum Magazine") then
              drm = true
              break
            elseif (v.name == "Flashlight") then
              fls = true
              break
            end

            break
          end
        end
      end
    end

    if (cb) then
      cb(sup, mag, scp, grp, drm, fls)
    end
  end)
end

function showTransfer(contents, inv, callback, itemtype, extra) -- type: 1 = vehicle,  2 = house
  blockinvopen = true
  blockTradeDrop = true
  exports.weaponshop:getWeaponsList(function(weps)
    local htmlstr = ""
    local contentsstr = ""
    local itemid = 0

    -- left side weapons
    for _,v in pairs(weps) do
      itemid = itemid + 1

      exports.weaponshop:getWeaponAttachmentDetails(v.name, function(data)
        local sup = data.sup
        local mag = data.mag
        local scp = data.scp
        local grp = data.grp
        local drm = data.drm
        local fls = data.fls

        if (sup or mag or scp or grp or drm) then
          local attstr = ""

          if (sup) then attstr = attstr .. "<span style='color: lawngreen'>SP</span>" end
          if (mag) then attstr = attstr .. "<span style='color: skyblue'>M</span>" end
          if (scp) then attstr = attstr .. "<span style='color: fuchsia'>SC</span>" end
          if (grp) then attstr = attstr .. "<span style='color: yellow'>G</span>" end
          if (drm) then attstr = attstr .. "<span style='color: red'>D</span>" end
          if (fls) then attstr = attstr .. "<span style='color: white'>F</span>" end

          attstr = string.format("&gt;%s&lt;", attstr)
          htmlstr = htmlstr .. string.format("<div class='transferItemLeft' data-name='%s' data-type='1' data-itemid='%s' data-quantity='1'>%s %s [1]</div>", v.name, itemid, v.name, attstr)
        else
          htmlstr = htmlstr .. string.format("<div class='transferItemLeft' data-name='%s' data-type='1' data-itemid='%s' data-quantity='1'>%s [1]</div>", v.name, itemid, v.name)
        end
      end)
    end

    -- left side inventory
    if (inv) then
      for _,v in pairs(inv) do
        itemid = itemid + 1
        local stolen = "false"

        if (v.stolen) then
          stolen = "true"
        end
        
        --print(string.format("%s", type(v.serial)))

        if (v.serial and tonumber(v.serial) > 0) then
          htmlstr = htmlstr .. string.format("<div class='transferItemLeft' data-name='%s' data-type='2' data-itemid='%s' data-quantity='%s' data-serial='%s' data-stolen='%s' data-cat='%s'>%s (SN:%s) [%s]</div>", v.name, itemid, v.quantity, v.serial, stolen, v.cat or 0, v.name, v.serial, v.quantity)
        else
          htmlstr = htmlstr .. string.format("<div class='transferItemLeft' data-name='%s' data-type='2' data-itemid='%s' data-quantity='%s' data-stolen='%s' data-cat='%s'>%s [%s]</div>", v.name, itemid, v.quantity, stolen, v.cat or 0, v.name, v.quantity)
        end
      end
    end

    -- right side contents
    itemid = 0

    for _,v in pairs(contents) do
      itemid = itemid + 1

      if (v.serial and v.serial > 0) then
        contentsstr = contentsstr .. string.format("<div class='transferItemRight' data-name='%s' data-type='3' data-itemid='%s' data-quantity='%s' data-serial='%s' data-cat='%s'>%s (SN:%s) [%s]</div>", v.name, itemid, v.quantity, v.serial, v.cat or 0, v.name, v.serial, v.quantity)
      else
        if (v.attachments) then -- is a weapon
          getWeaponAttachmentDetails(v.attachments, function(sup, mag, scp, grp, drm, fls)
            if (sup or mag or scp or grp or drm or fls) then
              local attstr = ""

              if (sup) then attstr = attstr .. "<span style='color: lawngreen'>SP</span>" end
              if (mag) then attstr = attstr .. "<span style='color: skyblue'>M</span>" end
              if (scp) then attstr = attstr .. "<span style='color: fuchsia'>SC</span>" end
              if (grp) then attstr = attstr .. "<span style='color: yellow'>G</span>" end
              if (drm) then attstr = attstr .. "<span style='color: red'>D</span>" end
              if (fls) then attstr = attstr .. "<span style='color: white'>F</span>" end

              attstr = string.format("&gt;%s&lt;", attstr)
              contentsstr = contentsstr .. string.format("<div class='transferItemRight' data-name='%s' data-type='3' data-itemid='%s' data-quantity='%s'>%s %s [%s]</div>", v.name, itemid, v.quantity, v.name, attstr, v.quantity)
            else
              contentsstr = contentsstr .. string.format("<div class='transferItemRight' data-name='%s' data-type='3' data-itemid='%s' data-quantity='%s'>%s [%s]</div>", v.name, itemid, v.quantity, v.name, v.quantity)
            end
          end)
        else
          contentsstr = contentsstr .. string.format("<div class='transferItemRight' data-name='%s' data-type='3' data-itemid='%s' data-cat='%s' data-quantity='%s'>%s [%s]</div>", v.name, itemid, v.cat or 0, v.quantity, v.name, v.quantity)
        end
      end
    end

    SendNUIMessage({
      openTransfer = true,
      leftitems = htmlstr,
      rightitems = contentsstr,
      callback = callback,
      transtype = itemtype,
      extra = extra or 0
    })
    
    SetNuiFocus(true, true)
  end)
end

function blockTrade(toggle)
  tradeblocked = toggle
  print(string.format("Trade blocked, toggle: %s, time %s", toggle, GetGameTimer()))
end

function getFishCount(cb)
  if (cb) then
    local fcount = 0

    for _,v in pairs(inventory) do
      if (string.find(v.name, "Fresh Fish")) then
        fcount = fcount + 1
      end
    end

    cb(fcount)
  end
end

function cleanFilename(name)
  return name:gsub("%W", "_")
end

function addInventorySorter(sorter)
  -- Check for existing file in /html/dinvicons

  for _,v in pairs(sorter) do
    if (not v.image) then
      local fname = cleanFilename(v.name:lower())
      local exists = file_exists("html/dinvicons/" .. fname .. ".png")

      if (exists) then
        v.image = fname
      end
    end
  end

  if (sorter) then
    SendNUIMessage({addInvSorter = true, sorter = sorter})
    TriggerEvent("bms:inventory:addInvSorterEx", {sorter = sorter})
  end
end

function isTradeBlocked(cb)
  if (cb) then
    cb(tradeblocked)
  end
  return tradeblocked
end

function getDisplayNameForHash(hash, wscomphashes, cb)
  for _,v in pairs(wscomphashes) do
    for _,h in pairs(v.hashes) do
      if (h == hash) then
        cb(v.name)
        break
      end
    end
  end
end

function createLocalItemProp(item)
  if (item) then
    local whash

    if (item.pickup) then
      whash = GetHashKey(item.pickup)
    else
      whash = GetHashKey(genericItemPack)
    end

    while (not HasModelLoaded(whash)) do
      RequestModel(whash)
      Wait(10)
    end

    local w = CreateObject(whash, item.pos.x, item.pos.y, item.pos.z, false, false, false)

    while (not DoesEntityExist(w)) do
      Wait(50)
    end

    PlaceObjectOnGroundProperly(w)

    if (not item.ignoreAdjustments) then
      SetEntityRotation(w, 90.0, 0, 0, 2, true)
    end
    
    if (not item.offset and not item.ignoreAdjustments) then
      local wpos = GetEntityCoords(w)
      
      SetEntityCoords(w, wpos.x, wpos.y, wpos.z - 0.045)
    end

    if (item.offset) then
      local wpos = GetEntityCoords(w)

      SetEntityCoords(w, wpos.x + item.offset.x, wpos.y + item.offset.y, wpos.z + item.offset.z)
    end
    
    SetModelAsNoLongerNeeded(whash)

    return w
  end
end

function draw3DItemText(x, y, z, text)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, 0.45 * scale)
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

RegisterNetEvent("bms:inventory:addInventorySorter")
AddEventHandler("bms:inventory:addInventorySorter", function(sorter)
  addInventorySorter(sorter)
end)

RegisterNetEvent("bms:inventory:blockInventoryUse")
AddEventHandler("bms:inventory:blockInventoryUse", function(toggle)
  print(string.format("(event) Item use blocked, toggle: %s, time %s", toggle, GetGameTimer()))
  blockInventoryUse(toggle)
end)

RegisterNetEvent("bms:inventory:blockTrade")
AddEventHandler("bms:inventory:blockTrade", function(toggle)
  blockTrade(toggle)
end)

RegisterNetEvent("bms:addInvItems")
AddEventHandler("bms:addInvItems", function(inv, weps, unblockUse, worldDroppables)
  if (inv) then
    inventory = inv

    exports.weaponshop:getDisplayNameForWeps(weps, function(ret)
      SendNUIMessage({addInvItems = true, inv = inv, weapons = ret, worldDroppables = worldDroppables})

      if (unblockUse) then
        blockInventoryUse(false)
      end
    end)
  end
end)

RegisterNetEvent("bms:clearInvItems")
AddEventHandler("bms:clearInvItems", function()
  inventory = {}
  SendNUIMessage({clearInv = true})
end)

RegisterNetEvent("bms:inv:listinv")
AddEventHandler("bms:inv:listinv", function()
  for _,v in pairs(inventory) do
    print(string.format("Item: %s (%s)", v.name, v.quantity))
  end
end)

RegisterNetEvent("bms:inv:giveItemComplete")
AddEventHandler("bms:inv:giveItemComplete", function(item, rchar, quantity)
  addGiveItem(item, quantity or 1)
  lastGiveChar = rchar
  exports.pnotify:SendNotification({text = string.format("You have given %s %s to %s", quantity or 1, item, rchar)})
end)

AddEventHandler("bms:inv:closeInventory", function()
  SendNUIMessage({hideInventory = true})
end)

AddEventHandler("bms:inv:closeInventoryProper", function(data, cb)
  closedTime.cur = GetGameTimer()
  showInventory = false
  SetNuiFocus(false, false)
  SendNUIMessage({hideInventory = true})
  exports.actionmenu:toggleBlockMenu(false)
end)

RegisterNUICallback("closeInventory", function(data, cb)
  closedTime.cur = GetGameTimer()
  showInventory = false
  SetNuiFocus(false, false)
  SendNUIMessage({hideInventory = true})
  exports.actionmenu:toggleBlockMenu(false)
end)

RegisterNetEvent("bms:inv:closeInventoryComplete")
AddEventHandler("bms:inv:closeInventoryComplete", function()
  closedTime.cur = GetGameTimer()
  showInventory = false
  SetNuiFocus(false, false)
  SendNUIMessage({hideInventory = true})
  exports.actionmenu:toggleBlockMenu(false)
end)

RegisterNUICallback("contextEvent", function(data)
  if (not data) then return end

  local pos = GetEntityCoords(PlayerPedId())
  data.pos = pos
  
  blockInventoryUse(true)
  TriggerServerEvent("bms:inv:inventoryContextEvent", data)
end)

RegisterNUICallback("weaponContextEvent", function(data)
  if (not data) then return end

  blockInventoryUse(true)
  TriggerServerEvent("bms:inv:inventoryWeaponContextEvent", data)
end)

RegisterNUICallback("dropItem", function(data, cb)
  if (not dspamguard and not tradeblocked and not blockTradeDrop) then
    local item = data.item
    local quantity = data.quantity
    local serial = data.serial

    if (item:match("Supressor")) then
      item = "Supressor"
    elseif (item:match("Scope")) then
      item = "Scope"
    elseif (item:match("Extended Magazine")) then
      item = "Extended Magazine"
    elseif (item:match("Advanced Grip")) then
      item = "Advanced Grip"
    elseif (item:match("Advanced Lockpick")) then
      item = "Advanced Lockpick"
    elseif (item:match("Drum Magazine")) then
      item = "Drum Magazine"
    elseif (item:match("Flashlight")) then
      item = "Flashlight"
    end      
    
    local ped = PlayerPedId()
    local pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)

    exports.management:TriggerServerCallback("bms:inventory:dropItemReq", function(data)
      if (not data.success) then
        exports.pnotify:SendNotification({text = data.msg})
      else
        local ped = PlayerPedId()
        
        Citizen.CreateThread(function()
          while (not HasAnimDictLoaded(pickupAnim.dict)) do
            RequestAnimDict(pickupAnim.dict)
            Wait(50)
          end

          TaskPlayAnim(ped, pickupAnim.dict, pickupAnim.anim, 8.0, -8.0, -1, pickupAnim.flag, 1, 0, 0, 0)
          RemoveAnimDict(pickupAnim.dict)
        end)
      end
    end, {item = item, quantity = quantity, serial = serial, pos = {x = pos.x, y = pos.y, z = pos.z}})
    
    dropDisp = true
    addDropItem(item, quantity)
    exports.pnotify:SendNotification({text = string.format("Dropped %s <font color='aqua'>%s</font>", quantity, item), layout = "bottomRight"})
      -- drop item and refresh inventory
    dtime = 0
    dspamguard = true
  end
end)

RegisterNUICallback("dropWepItem", function(data, cb)
  if (not dspamguard and not tradeblocked and not blockTradeDrop) then
    exports.lawenforcement:isPlayerOnDutyCop(function(onduty)
      if (onduty) then
        exports.pnotify:SendNotification({text = "You can not drop your service weapons.", layout = "bottomRight"})
      else
        local ped = PlayerPedId()
        local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)

        data.pickupOffset = offset
        TriggerServerEvent("dd6f247ac7419f6771205a2ef00e38d8", data)
        dtime = 0
        dspamguard = true
      end
    end)
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

RegisterNetEvent("bms:inv:addDropItems")
AddEventHandler("bms:inv:addDropItems", function(item, qty)
  if (qty) then
    dropDisp = true
    addDropItem(item, qty)
    exports.pnotify:SendNotification({text = string.format("Dropped %s <font color='aqua'>%s</font>", qty, item)})
    dtime = 0
  end
end)

--TriggerClientEvent("bms:inv:giveItemPrecheck", givepid, recpid, item, allow)
RegisterNetEvent("bms:inv:giveItemPrecheck")
AddEventHandler("bms:inv:giveItemPrecheck", function(recpid, item, serial, allow, quantity, cat)
  if (allow) then
    TriggerServerEvent("bms:inv:giveItem", GetPlayerServerId(PlayerId()), recpid, item, serial, quantity, cat)
    giveDisp = true
  else
    spamguard = false
    exports.pnotify:SendNotification({text = "That player has reached the limit for that item."})
    SendNUIMessage({unblockGive = true})
  end
end)

RegisterNetEvent("bms:inventory:tradeweaponcomplete")
AddEventHandler("bms:inventory:tradeweaponcomplete", function(data)
  if (data) then
    local success = data.success
    local msg = data.msg

    if (msg) then
      exports.pnotify:SendNotification({text = msg})
    end
  end
end)

RegisterNetEvent("bms:inventory:updateDroppedItems")
AddEventHandler("bms:inventory:updateDroppedItems", function(data)
  if (data) then
    Citizen.CreateThread(function()
      for _,v in pairs(droppedItems) do
        while (DoesEntityExist(v.entity)) do
          DeleteObject(v.entity)
          Wait(50)
        end
      end

      droppedItems = data.droppedItems or {}

      for _,v in pairs(droppedItems) do
        local w = createLocalItemProp(v)
        
        v.entity = w
      end
    end)
  end
end)

RegisterNUICallback("giveItem", function(data, cb)
  if (not blockInv and not spamguard and not tradeblocked and not blockTradeDrop) then
    blockInv = true
  --if (not spamguard and not tradeblocked and not blockTradeDrop) then
    spamguard = true
    local clplayer, cldist = getClosestPlayer()
    local sid = GetPlayerServerId(clplayer)
    local itemname = data.item
    local serial = tonumber(itemname:match("%[SN:(%d+)%]"))
    local quantity = data.quantity or 1
    local cat = data.cat or 0
    local item = getInventoryItem(itemname)

    if (serial and serial > 0) then
      local pospar = string.find(itemname, " %[SN:")

      if (pospar) then
        itemname = string.sub(itemname, 1, pospar - 1)
      end
    end
    
    if (clplayer and sid > 0 and cldist < 1.5) then
      blockTrade(true)
      blockInventoryUse(true)
      exports.vehicles:blockTrunk(true)

      exports.management:TriggerServerCallback("bms:inventory:sendTradeRequest", function(data)
        blockTrade(false)
        blockInventoryUse(false)
        exports.vehicles:blockTrunk(false)
        spamguard = false
        blockInv = false
        SendNUIMessage({unblockGive = true})
        tradeblocked = false

        if (data) then
          if (data.success) then
            giveDisp = true
            addGiveItem(itemname, quantity or 1)
            lastGiveChar = data.rcharname
          end
          exports.pnotify:SendNotification({text = data.msg})
        end
      end, {recipid = sid, item = itemname, qty = quantity, serial = serial or 0, cat = cat})

      --TriggerServerEvent("bms:inv:tradeconfirm", GetPlayerServerId(PlayerId()), sid, itemname, quantity, serial or 0, cat)
    else
      exports.pnotify:SendNotification({text = "No players were found nearby.", layout = "bottomRight"})
      spamguard = false
      blockInv = false
      SendNUIMessage({unblockGive = true})
      tradeblocked = false
    end
  end
end)

RegisterNUICallback("giveWeaponItem", function(data, cb)
  if (data) then
    local item = data.item
    local model = data.model

    if (spamguard or tradeblocked or blockTradeDrop) then
      exports.pnotify:SendNotification({text = "You can not trade items at this time.", layout = "bottomRight"})
      return
    end

    exports.lawenforcement:isPlayerOnDutyCop(function(onduty)
      if (onduty) then
        exports.pnotify:SendNotification({text = "You can not trade your service weapons.", layout = "bottomRight"})
        SendNUIMessage({unblockGive = true})
      elseif (cantrade) then
        if (item and model and not spamguard and not tradeblocked and not blockTradeDrop) then
          spamguard = true
          local clplayer, cldist = getClosestPlayer()
          local sid = GetPlayerServerId(clplayer)

          if (clplayer and sid > 0 and cldist < 1.5) then
            blockTrade(true)
            exports.vehicles:blockTrunk(true)

            local wep = GetHashKey(model)
            local ped = PlayerPedId()
            local has = HasPedGotWeapon(ped, wep)

            if (has) then
              local witem = {}

              witem.name = item
              witem.model = model
              witem.ammo = GetAmmoInPedWeapon(ped, wep)
              witem.clipammo = GetAmmoInClip(ped, wep)

              exports.weaponshop:getWsCompHashes(function(wscomphashes)
                for _,v in pairs(wscomphashes) do
                  for _,h in pairs(v.hashes) do
                    local att = h
          
                    if (type(h) == "string") then
                      att = GetHashKey(h)
                    end
          
                    local onwep = HasPedGotWeaponComponent(ped, wep, att)
          
                    if (onwep) then
                      if (data) then
                        local attname = data.itemname
                        local serial = data.serial
                                
                        getDisplayNameForHash(h, wscomphashes, function(h)
                          if (h == attname) then
                            table.insert(witem.attachments, {name = h, serial = serial})
                          end
                        end)
                        --[[if (getDisplayNameForHash(h) == attname) then
                          table.insert(witem.attachments, {name = h, serial = serial})
                        end]]
                      else
                        table.insert(witem.attachments, {name = h, serial = 0})
                      end
                    end
                  end
                end
              end)

              exports.management:TriggerServerCallback("bms:inventory:sendWeaponTradeRequest", function(data)
                spamguard = false
                waitingtrade = false
                blockTrade(false)
                exports.vehicles:blockTrunk(false)
                SendNUIMessage({unblockGive = true})

                if (data) then
                  exports.pnotify:SendNotification({text = data.msg})
                end
              end, {recipid = sid, wep = witem})
              --TriggerServerEvent("bms:inv:tradewepconfirm", GetPlayerServerId(PlayerId()), sid, witem)
            end
          else
            exports.pnotify:SendNotification({text = "No players were found nearby.", layout = "bottomRight"})
            spamguard = false
            SendNUIMessage({unblockGive = true})
          end
        end
      else
        exports.pnotify:SendNotification({text = "You can not trade items at this time.", layout = "bottomRight"})
      end
    end)
  end
end)

RegisterNetEvent("bms:inv:setwaitingtrade")
AddEventHandler("bms:inv:setwaitingtrade", function(tog)
  waitingtrade = tog
  spamguard = false
end)

RegisterNUICallback("moveItem", function(data, cb)
  if (not tradeblocked) then
    if (data) then
      TriggerEvent("bms:inventory:doServerPrecheckMoveItem", data)
    end
  else
    SendNUIMessage({
      unblockTransfer = true
    })

    if (data.transtype == 1) then
      exports.pnotify:SendNotification({text = "You can not use the trunk at this time."})
    else
      exports.pnotify:SendNotification({text = "You can not use your storage at this time."})
    end
  end
end)

RegisterNUICallback("playsound", function(data, cb)
  PlaySoundFrontend(-1, data.name, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end)

RegisterNUICallback("closeTransfer", function(data, cb)
  closedTime.cur = GetGameTimer()
  SetNuiFocus(false, false)

  local callback = data.callback

  if (callback and callback ~= "") then
    TriggerEvent(callback)
  end

  blockinvopen = false
  blockTradeDrop = false
end)

RegisterNUICallback("useitem", function(data, cb)
  local itemName = data.invitem
  local itemQty = data.invqty

  TriggerServerEvent("bms:characterUseItem", itemName, itemQty, false)
end)

RegisterNUICallback("debug", function(data, cb)
  if (data) then
    TriggerServerEvent("bms:serverprint", "debug: " .. tostring(data))
  else
    TriggerServerEvent("bms:serverprint", "debug: no data")
  end
end)

RegisterNUICallback("notifyClient", function(data)
  if (data and data.msg) then
    exports.pnotify:SendNotification({text = data.msg, layout = "bottomRight"})
  end
end)

-- debug
--[[RegisterNetEvent("bms:inventory:openTransfer")
AddEventHandler("bms:inventory:openTransfer", function()
  exports.weaponshop:getWeaponsList(function(weps)
    local htmlstr = ""
    
    for _,v in pairs(weps) do
      htmlstr = htmlstr .. string.format("<div class='transferItemLeft' data-name='%s'>%s</div>", v.name, v.name)
    end

    SendNUIMessage({
      openTransfer = true,
      items = htmlstr
    })
    
    SetNuiFocus(true, true)
  end)
end)]]

AddEventHandler("bms:inventory:doServerPrecheckMoveItem", function(data)
  if (data) then
    local ped = PlayerPedId()
    local dir = data.direction
    local name = data.name:gsub("&amp;", "&")
    --print("servermoveitem: " .. name)

    exports.weaponshop:getWeaponsInGame(function(weps)
      if (dir == 1) then
        local iswep = false
        
        for _,v in pairs(weps) do
          if (v.name == trim(name)) then
            iswep = true
            data.iswep = true
            data.wepammoclip = GetAmmoInClip(ped, GetHashKey(v.model or 0))
            data.wepammo = GetAmmoInPedWeapon(ped, GetHashKey(v.model or 0))
            data.model = v.model
            -- get attachments
            data.attachments = {}

            exports.weaponshop:getWsCompHashes(function(wscomphashes)
              for _,wc in pairs(wscomphashes) do
                for _,h in pairs(wc.hashes) do
                  local att = h

                  if (type(h) == "string") then
                    att = GetHashKey(h or 0)
                  end
                  
                  local onwep = HasPedGotWeaponComponent(ped, GetHashKey(v.model or 0), att)
        
                  if (onwep) then
                    table.insert(data.attachments, {name = h})
                  end
                end
              end
            end)

            RemoveWeaponFromPed(ped, GetHashKey(v.model)) -- enable after testing
            break
          end
        end
      elseif (dir == 2) then
        local iswep = false
        
        for _,v in pairs(weps) do
          --print(string.format("[%s], [%s]", v.name, name))
          if (v.name == trim(name)) then
            iswep = true
            data.iswep = true
            --GiveWeaponToPed(ped, GetHashKey(v.model), v.ammo, 0, false)

            break
          end
        end
      end
      
      data.name = name
      if (data.transtype == 1) then
        TriggerServerEvent("bms:vehiclestorage:moveItem", data)
      else
        TriggerServerEvent("bms:housing:moveItem", data)
      end
    end)
  end
end)

RegisterNetEvent("bms:clcharacterUseItem")
AddEventHandler("bms:clcharacterUseItem", function(itemName, quantity, autoremoved) -- if autoremoved is false, "bms:remCharacterInvItem" must be called manually
  local blockInvReactivate = false
  
  if (not blockInv) then
    blockInventoryUse(true)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped, true)
    local wspos = {x = pos.x, y = pos.y, z = pos.z}
    
    if (itemName == "Bandage") then -- restore some health
      exports.characters:doBandageSelf()
    elseif (itemName == "Small Packs of Weed") then
      -- trigger dealing
      TriggerEvent("bms:jobs:sd:activateStreetDeal", "Small Packs of Weed")
    elseif (itemName == "Lockpick") then
      TriggerEvent("bms:vehicles:useLockpick")
    elseif (itemName == "Fishing Pole") then
      TriggerServerEvent("bms:fishing:activateFishing")
    elseif (itemName == "Vehicle Repair Kit") then
      TriggerServerEvent("bms:vehicles:useRepairKit")
    elseif (itemName == "Joint") then
      TriggerEvent("bms:drugdealer:useJoint")
    elseif (itemName == "High Grade C4 (Prison Break Tool)") then
      TriggerEvent("bms:cuff:doPrisonBreak")
    elseif (itemName == "Rolling Papers") then
      TriggerServerEvent("bms:drugdealer:rollJoint")
    elseif (itemName == "Scuba Gear") then
      TriggerServerEvent("jobs:diving:toggleCivScuba")
    elseif (string.match(itemName, "Advanced Lockpick")) then
      for i = 1, #vaultcoords do
        local dist = Vdist(pos.x, pos.y, pos.z, vaultcoords[i].x, vaultcoords[i].y, vaultcoords[i].z)
        if dist < 1 then
          TriggerServerEvent("bms:banking:getNumCopsOnDuty")
        end
      end
    elseif (itemName == "Bottled Water") then
      -- temp hacky check for bottled water/farm proximity, the way this is checked will need to be more modular in the future
      exports.jobs:isNearWeedFarm(function(near)
        if (near) then
          TriggerServerEvent("bms:events:characterUsedItemEx", itemName, wspos)
        end
      end)
    else
      blockInvReactivate = true
      TriggerServerEvent("bms:events:characterUsedItem", itemName)
      Wait(10000) -- shitty workaround for items that have no use
      blockInventoryUse(false)
    end

    if (not blockInvReactivate) then
      Wait(500)
      blockInventoryUse(false)
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)
    
    if (not IsControlPressed(1, 21)) then -- Shift
      if (IsControlJustReleased(1, 311) and not blockInput) then -- K
        local iskb = GetLastInputMethod(2)
      
        if (iskb) then
          if (not blockinvopen and (closedTime.cur + closedTime.time) < GetGameTimer() or closedTime.cur == 0) then
            if (not showInventory) then
              exports.actionmenu:toggleBlockMenu(true)
              showInventory = true
              SetNuiFocus(true, true)
              SendNUIMessage({showInventory = true})
            end
          end

          if (blockinvopen and showInventory) then
            showInventory = false
            SetNuiFocus(false, false)
            SendNUIMessage({hideInventory = true})
            exports.actionmenu:toggleBlockMenu(false)
          end
        end
      end
    end

    for i,v in pairs(droppedItems) do
      if (v.entity and DoesEntityExist(v.entity)) then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local ipos = GetEntityCoords(v.entity)
        local dist = #(pos - ipos)

        if (dist < 1.5) then
          draw3DItemText(ipos.x, ipos.y, ipos.z + 0.2, string.format("Press ~b~E~w~ to pick up this %s (%s)", v.name, v.quantity))

          if (not itemPickupBlock) then
            if (IsControlJustReleased(1, 38)) then
              itemPickupBlock = true
              exports.management:TriggerServerCallback("bms:inventory:pickupDroppedItem", function(data)
                if (not data.success) then
                  if (data.msg) then
                    exports.pnotify:SendNotification({text = data.msg})
                  end
                else
                  Citizen.CreateThread(function()
                    while (not HasAnimDictLoaded(pickupAnim.dict)) do
                      RequestAnimDict(pickupAnim.dict)
                      Wait(50)
                    end

                    TaskPlayAnim(ped, pickupAnim.dict, pickupAnim.anim, 8.0, -8.0, -1, pickupAnim.flag, 1, 0, 0, 0)
                    RemoveAnimDict(pickupAnim.dict)
                  end)
                end

                itemPickupBlock = false
              end, {idx = i})
            end
          end
        end
      end
    end
  end
end)

-- drop spamguard
Citizen.CreateThread(function()
  while true do
    Wait(1000)

    if (dspamguard) then
      dtime = dtime + 1000

      if (dtime > dduration) then
        dtime = 0
        dspamguard = false
      end
    end
  end
end)

-- LOOP ONLY for the drop/give display
Citizen.CreateThread(function()
  while true do
    Wait(1000)
    
    if (dropDisp) then
      dropDispElapsed = dropDispElapsed + 1000
      
      if (dropDispElapsed > dropDispTime) then
        local sid = GetPlayerServerId(PlayerId())
        
        local dropStr = ""
        
        for _,v in pairs(dropItems) do
          dropStr = dropStr .. string.format("%s (%s) | ", v.name, v.quantity)
        end
        
        TriggerServerEvent("localChatAction", sid, -1, {0, 255, 0}, "dropped " .. dropStr)
        TriggerServerEvent("bms:inventory:dropevent", dropStr)
        dropItems = {}
        dropDisp = false
        dropDispElapsed = 0
      end
    end

    if (giveDisp) then
      giveDispElapsed = giveDispElapsed + 1000
      
      if (giveDispElapsed > giveDispTime) then
        local sid = GetPlayerServerId(PlayerId())
        
        local giveStr = ""
        
        for _,v in pairs(giveItems) do
          giveStr = giveStr .. string.format("%s (%s) | ", v.name, v.quantity)
        end
        
        TriggerServerEvent("localChatAction", sid, -1, {0, 255, 0}, string.format("has given %s to %s", giveStr, lastGiveChar))
        giveItems = {}
        giveDisp = false
        spamguard = false
        giveDispElapsed = 0
      end
    end
  end
end)
