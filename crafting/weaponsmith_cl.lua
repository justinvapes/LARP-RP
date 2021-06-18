--stations: 
    --weapon smithing: gr_prop_gr_bench_01b
    --work table: gr_prop_gr_bench_02b
    --drill press: gr_prop_gr_speeddrill_01b
    --toolbox: gr_prop_gr_tool_draw_01a
    --cctv: prop_cctv_cam_01b

local table_insert = table.insert
local wsspots = {}
local wslegalspots = {
  {exit = {pos = vec3(1088.098, -3099.351, -38.999)}, entry = {pos = vec3(870.706, -2100.679, 30.459)}}
}
local props = {
  {model = "gr_prop_gr_tool_draw_01a", x = 1098.849, y = -3102.037, z = -38.999, heading = 181.684}
}
local sellto = {
  {x = -349.565, y = 1266.773, z = 332.913, dped = "u_m_m_jewelthief", dpos = {x = -351.604, y = 1332.918, z = 338.952}}
}
local lastsell = 1
local wscomphashes = { -- change in weaponsmith_cl too
  [1] = {name = "Supressor", hashes = {"COMPONENT_AT_PI_SUPP", "COMPONENT_AT_PI_SUPP_02", "COMPONENT_AT_AR_SUPP", "COMPONENT_AT_SR_SUPP", "COMPONENT_AT_AR_SUPP_02"}},
  [2] = {name = "Extended Magazine", hashes = {"COMPONENT_PISTOL_CLIP_02", "COMPONENT_COMBATPISTOL_CLIP_02", "COMPONENT_APPISTOL_CLIP_02", 
    "COMPONENT_PISTOL50_CLIP_02", "COMPONENT_MICROSMG_CLIP_02", "COMPONENT_SMG_CLIP_02", "COMPONENT_ASSAULTSMG_CLIP_02", "COMPONENT_ASSAULTRIFLE_CLIP_02",
    "COMPONENT_CARBINERIFLE_CLIP_02", "COMPONENT_ADVANCEDRIFLE_CLIP_02", "COMPONENT_MG_CLIP_02", "COMPONENT_COMBATMG_CLIP_02", "COMPONENT_ASSAULTSHOTGUN_CLIP_02",
    "COMPONENT_SNSPISTOL_CLIP_02", "COMPONENT_MINISMG_CLIP_02", "COMPONENT_HEAVYPISTOL_CLIP_02", "COMPONENT_SPECIALCARBINE_CLIP_02",
    "COMPONENT_BULLPUPRIFLE_CLIP_02", "COMPONENT_BULLPUPRIFLE_MK2_CLIP_02", "COMPONENT_MARKSMANRIFLE_MK2_CLIP_02", "COMPONENT_SNSPISTOL_MK2_CLIP_02",
    "COMPONENT_SPECIALCARBINE_MK2_CLIP_02", "COMPONENT_ASSAULTRIFLE_MK2_CLIP_02", "COMPONENT_CARBINERIFLE_MK2_CLIP_02", "COMPONENT_COMBATMG_MK2_CLIP_02", 
    "COMPONENT_HEAVYSNIPER_MK2_CLIP_02", "COMPONENT_PISTOL_MK2_CLIP_02", "COMPONENT_SMG_MK2_CLIP_02", "COMPONENT_VINTAGEPISTOL_CLIP_02",
    "COMPONENT_MACHINEPISTOL_CLIP_02", "COMPONENT_COMPACTRIFLE_CLIP_02", "COMPONENT_HEAVYSHOTGUN_CLIP_02", "COMPONENT_MARKSMANRIFLE_CLIP_02",
    "COMPONENT_COMBATPDW_CLIP_02", "COMPONENT_GUSENBERG_CLIP_02"}},
  [3] = {name = "Advanced Grip", hashes = {"COMPONENT_AT_AR_AFGRIP", "COMPONENT_AT_AR_AFGRIP_02"}},
  [4] = {name = "Scope", hashes = {"COMPONENT_AT_SCOPE_MACRO", "COMPONENT_AT_SCOPE_MACRO_02", "COMPONENT_AT_SCOPE_SMALL", "COMPONENT_AT_SCOPE_SMALL_02", "COMPONENT_AT_SCOPE_MEDIUM", "COMPONENT_AT_SCOPE_LARGE",
    0x8ED4BB70, 0xE502AB6B, 0x9FDB5652, 0x420FD713, 0x9D65907A}},
  [5] = {name = "Drum Magazine", hashes = {"COMPONENT_SMG_CLIP_03", "COMPONENT_ASSAULTRIFLE_CLIP_03", "COMPONENT_CARBINERIFLE_CLIP_03",
    "COMPONENT_SPECIALCARBINE_CLIP_03", "COMPONENT_MACHINEPISTOL_CLIP_03", "COMPONENT_COMPACTRIFLE_CLIP_03", "COMPONENT_HEAVYSHOTGUN_CLIP_03",
    "COMPONENT_COMBATPDW_CLIP_03"}},
  [6] = {name = "Flashlight", hashes = {"COMPONENT_AT_AR_FLSH", "COMPONENT_AT_PI_FLSH"}}
}
local blockinput = false
local activecraft
local crafting = false
local origttcsec = 900
local craftprogress = {ttcsec = 900, ttccur = 0}
local pickup = false
local haslicense = false
local dped
local dealerincoming = false
local cancalldealer = true
local dpedreturn = false
local lastStation = 0

function draw3DWsText(x, y, z, text)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, 0.55 * scale)
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

function spawnWepDealer(v)
  local ped = PlayerPedId()
  local hash = GetHashKey(v.dped)
    
  RequestModel(hash)
  
  while not HasModelLoaded(hash) do
    Wait(0)
  end

  dped = CreatePed(4, GetHashKey(v.dped), v.dpos.x, v.dpos.y, v.dpos.z, 0, true, 1)
  
  if (DoesEntityExist(dped)) then
    GiveWeaponToPed(dped, GetHashKey("weapon_assaultsmg"), 1000, 0, 1)
    --TaskWanderInArea(dped, v.dpos.x, v.dpos.y, v.dpos.z, 5.0, 0, 5)
    TaskGoToEntity(dped, ped, -1, 1.5, 10.0, 1073741824.0, 0)
    dealerincoming = true
    dealerWelfareCheck(dped)
  end

  SetModelAsNoLongerNeeded(hash)
end

function timeOutDealer()
  cancalldealer = false
  
  SetTimeout(120000, function()
    cancalldealer = true
  end)
end

function despawnDealer()
  if (dped and not IsPedDeadOrDying(dped)) then
    dpedreturn = true
    TaskGoToCoordAnyMeans(dped, sellto[lastsell].dpos.x, sellto[lastsell].dpos.y, sellto[lastsell].dpos.z, 4.0, 0, 0, 1073741824.0, 0)

    Citizen.CreateThread(function()
      local dpos = GetEntityCoords(dped)
      local dist = Vdist(dpos.x, dpos.y, dpos.z, sellto[lastsell].dpos.x, sellto[lastsell].dpos.y, sellto[lastsell].dpos.z)
      
      while dpedreturn do
        Wait(100)

        dpos = GetEntityCoords(dped)
        dist = Vdist(dpos.x, dpos.y, dpos.z, sellto[lastsell].dpos.x, sellto[lastsell].dpos.y, sellto[lastsell].dpos.z)

        if (dist < 1.8) then
          DeletePed(dped)
          dped = nil
          dpedreturn = false
        end
      end
    end)
  end
end

function startCrafting()
  exports.inventory:blockInventoryOpen(false)
  exports.inventory:blockTrade(false)
  crafting = true
  
  Citizen.CreateThread(function()
    while crafting do
      Wait(1000)

      craftprogress.ttccur = craftprogress.ttccur + 1

      if (craftprogress.ttccur >= craftprogress.ttcsec) then
        crafting = false
        craftprogress.ttcsec = origttcsec
        craftprogress.ttccur = 0
        pickup = true
        TriggerServerEvent("bms:crafting:weaponsmith:craftcomplete", activecraft)
      end
    end
  end)
end

--[[Dealer welfare check]]
function dealerWelfareCheck(dped)
  Citizen.CreateThread(function()
    while dealerincoming do
      Wait(100)

      local dead = IsPedDeadOrDying(dped)

      if (dead) then
        exports.pnotify:SendNotification({text = "The dealer was killed on his way to do business."})
        dealerincoming = false
        dped = nil
        timeOutDealer()
      end
    end
  end)
end

RegisterNetEvent("bms:crafting:weaponsmith:setinventory")
AddEventHandler("bms:crafting:weaponsmith:setinventory", function(data)
  if (data.inv) then
    local inv = {}
    
    SetNuiFocus(true, true)

    for k,v in pairs(data.inv) do
      table_insert(inv, {name = k, quantity = v})
    end

    SendNUIMessage({loadcrafts = true, wscrafts = data.wscrafts, stationType = lastStation.type})
    SendNUIMessage({setinventory = true, openshop = true, inventory = inv, wscrafts = data.wscrafts, money = data.money})
  end
end)

RegisterNetEvent("bms:crafting:weaponsmith:setactivecraft")
AddEventHandler("bms:crafting:weaponsmith:setactivecraft", function(data)
  local craft = data.craft
  local ctime = data.ctime
  
  if (craft) then
    activecraft = craft
    SetNuiFocus(false, false)
    SendNUIMessage({closeshop = true})
    craftprogress.ttcsec = ctime
    startCrafting()
  else
    print("craft was nil >> weaponsmith_cl.lua")
  end
end)

RegisterNetEvent("bms:crafting:weaponsmith:checklicense")
AddEventHandler("bms:crafting:weaponsmith:checklicense", function(data)
  if (data) then
    local haslic = data.haslic

    haslicense = haslic
  end
end)

RegisterNetEvent("bms:crafting:weaponsmith:loadstations")
AddEventHandler("bms:crafting:weaponsmith:loadstations", function(data)  
  if (not data) then
    print("bms:crafting:weaponsmith:loadstations >> data failed to load.")
    return
  end
  
  wsspots = data.wsspots
  
  for _,v in pairs(wsspots) do
    if (v.prop and v.prop.hash) then
      local o = CreateObjectNoOffset(GetHashKey(v.prop.hash), v.pos.x, v.pos.y, v.pos.z - 1.00001, 0, 0, 0)

      PlaceObjectOnGroundProperly(o)
      SetEntityHeading(o, v.prop.heading)
    end
  end

  for _,v in pairs(props) do
    local o = CreateObject(GetHashKey(v.model), v.x, v.y, v.z - 1.00001, 0, 0, 0)

    SetEntityHeading(o, v.heading)
  end

  local cip = data.crafts
  local time = data.time
  local char = data.charname

  if (cip and time and char) then
    for _,v in pairs(cip) do
      if (v.name == char) then
        local elapsedTime = time - v.starttime
        local timeRemSec = v.crafttime - elapsedTime

        activecraft = v
        craftprogress.ttcsec = timeRemSec
        startCrafting()
      end
    end
  end

  --SendNUIMessage({loadcrafts = true, wscrafts = data.wscrafts}) -- this will need to be on the fly now
end)

RegisterNetEvent("bms:crafting:weaponsmith:craftcomplete")
AddEventHandler("bms:crafting:weaponsmith:craftcomplete", function(craft)
  if (craft) then
    pickup = true
    blockinput = false
    exports.inventory:blockInventoryOpen(false)
    exports.inventory:blockTrade(false)
    exports.pnotify:SendNotification({text = string.format("You have successfully crafted a(n) <font color='skyblue'>%s</font>.  You can pick up your craft at a weapons smithing station.", craft.itemname)})
  end
end)

RegisterNetEvent("bms:crafting:weaponsmith:completepickup")
AddEventHandler("bms:crafting:weaponsmith:completepickup", function(craft)
  if (not craft) then
    blockinput = false
    return
  end
  
  local quantity = craft.quantity or 1
  
  pickup = false
  activecraft = nil
  blockinput = false

  if (craft.craftCycles and craft.craftCycles > 1) then
    local amount = quantity * craft.craftCycles
    
    exports.pnotify:SendNotification({text = string.format("You have picked up %s <font color='skyblue'>%s(s)</font>.", amount, craft.itemname)})
  else
    if (quantity > 1) then
      exports.pnotify:SendNotification({text = string.format("You have picked up %s <font color='skyblue'>%s(s)</font>.", quantity, craft.itemname)})
    else
      exports.pnotify:SendNotification({text = string.format("You have picked up a(n) <font color='skyblue'>%s</font>.", craft.itemname)})
    end
  end
end)

RegisterNetEvent("bms:crafting:weaponsmith:loaddealer")
AddEventHandler("bms:crafting:weaponsmith:loaddealer", function(data)
  if (data) then
    local allow = data.allow
    local items = data.items
    local msg = data.msg

    if (allow) then
      if (#items > 0) then
        exports.services:loadBsqMenu("crafting", "Black Market Arms Dealer", false, true, items, "bms:crafting:weaponsmith:bsexit")
      end
    else
      if (msg) then
        exports.pnotify:SendNotification({text = msg})
      end

      dealerincoming = false
    end
  end
end)

RegisterNetEvent("bms:crafting:weaponsmith:doattach")
AddEventHandler("bms:crafting:weaponsmith:doattach", function(data)
  local itemname = data.itemname
  local serial = data.serial
  local hasatt = false
  
  if (itemname) then
    local ped = PlayerPedId()
    local selwep = GetSelectedPedWeapon(ped)

    if (selwep and selwep ~= 0) then
      local supported = false
      local foundAtt = false
      local hashes = {}
      
      if (itemname == "Supressor") then
        hashes = wscomphashes[1].hashes
      elseif (itemname == "Extended Magazine") then
        hashes = wscomphashes[2].hashes
      elseif (itemname == "Advanced Grip") then
        hashes = wscomphashes[3].hashes
      elseif (itemname == "Scope") then
        hashes = wscomphashes[4].hashes
      elseif (itemname == "Drum Magazine") then
        hashes = wscomphashes[5].hashes
      elseif (itemname == "Flashlight") then
        hashes = wscomphashes[6].hashes
      end

      for _,v in pairs(hashes) do
        local att = v

        if (type(v) == "string") then
          att = GetHashKey(v)
        end
        
        supported = DoesWeaponTakeWeaponComponent(selwep, att)
        hasatt = HasPedGotWeaponComponent(ped, selwep, att)

        if (supported and not hasatt) then
          foundAtt = v

          break
        elseif (hasatt) then
          break
        end
      end

      TriggerServerEvent("bms:crafting:weaponsmith:attachComp", foundAtt, hasatt, {itemname = itemname, serial = serial, wep = selwep})
    else
      TriggerServerEvent("bms:crafting:weaponsmith:attachComp", false, false, {itemname = itemname, serial = serial, wep = selwep})
    end
  end
end)

--[[RegisterNetEvent("bms:dev:loaddealer")
AddEventHandler("bms:dev:loaddealer", function()
  TriggerServerEvent("bms:crafting:weaponsmith:loaddealer")
end)]]

RegisterNetEvent("bms:crafting:weaponsmith:sellitemscomplete")
AddEventHandler("bms:crafting:weaponsmith:sellitemscomplete", function()
  timeOutDealer()
  despawnDealer()
end)

RegisterNUICallback("bms:crafting:weaponsmith:closews", function()
  SetNuiFocus(false, false)
  exports.inventory:blockInventoryOpen(false)
  exports.inventory:blockTrade(false)
  blockinput = false
end)

RegisterNUICallback("bms:bsqmenu:processcb", function(data)
  local items = data.items
  
  if (items) then
    TriggerServerEvent("bms:crafting:weaponsmith:sellitems", items)
  end

  SetNuiFocus(false, false)
end)

RegisterNUICallback("bms:crafting:weaponsmith:createitem", function(data, cb)
  local id = tonumber(data.itemid)
  local craftCycles = tonumber(data.craftCycles)
  
  if (id and id > 0) then
    TriggerServerEvent("bms:crafting:weaponsmith:createitem", {id = id, craftCycles = craftCycles})
  else
    print("id was 0 or nil >> weaponsmith_cl.lua")
  end
end)

RegisterNUICallback("bms:crafting:weaponsmith:bsexit", function()
  -- todo: dealer walk off and despawn
  SetNuiFocus(false, false)
  timeOutDealer()
  despawnDealer()
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    if (dped and dealerincoming) then
      local dpos = GetEntityCoords(dped)
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local dist = Vdist(pos.x, pos.y, pos.z, dpos.x, dpos.y, dpos.z)

      if (dist < 2.0) then
        dealerincoming = false
        TriggerServerEvent("bms:crafting:weaponsmith:loaddealer")
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    for _,v in pairs(wsspots) do
      local ppos = vec3(v.pos.x, v.pos.y + 0.9, v.pos.z)
      local dist = #(pos - ppos)

      if (dist < 80) then
        DrawMarker(1, v.pos.x, v.pos.y + 0.9, v.pos.z - 1, 0, 0, 0, 0, 0, 0, 1.3, 1.3, 0.3, 0, 120, 120, 50, 0, 0, 0, 0, 0, 0, 0)

        if (not activecraft) then
          if (dist < 0.6) then
            local promptStr = string.format("Press ~b~[E]~w~ to use the %s.", v.desc)

            draw3DWsText(v.pos.x, v.pos.y + 0.9, v.pos.z + 0.25, promptStr)

            if (not blockinput) then
              if (IsControlJustReleased(1, 38)) then
                blockinput = true
                exports.inventory:blockInventoryOpen(true)
                exports.inventory:blockTrade(true)
                lastStation = v
                TriggerServerEvent("bms:crafting:weaponsmith:getinventory")
              end
            end
          end
        else
          if (crafting) then
            if (dist < 0.6) then
              local timerem = math.ceil((craftprogress.ttcsec - craftprogress.ttccur) / 60)

              if (timerem < 1) then
                draw3DWsText(v.pos.x, v.pos.y, v.pos.z + 0.25, string.format("~w~Crafting ~b~%s~w~. Time Left: ~b~Less than a minute~w~.", activecraft.itemname))
              else
                draw3DWsText(v.pos.x, v.pos.y, v.pos.z + 0.25, string.format("~w~Crafting ~b~%s~w~. Time Left: ~b~%s minutes~w~.", activecraft.itemname, timerem))
              end
            end
          elseif (pickup) then
            -- press E to pickup the attachment            
            if (dist < 0.6) then
              draw3DWsText(v.pos.x, v.pos.y + 0.9, v.pos.z + 0.25, string.format("~w~Press ~b~E~w~ to pick up your ~b~%s~w~.", activecraft.itemname))

              if (not blockinput) then
                if (IsControlJustReleased(1, 38)) then
                  blockinput = true
                  TriggerServerEvent("bms:crafting:weaponsmith:completepickup", activecraft)
                end
              end
            end
          end
        end
      end
    end

    for _,v in pairs(wslegalspots) do
      local dist = #(pos - v.entry.pos)

      if (dist < 40) then
        DrawMarker(1, v.entry.pos.x, v.entry.pos.y, v.entry.pos.z - 1.000001, 0, 0, 0, 0, 0, 0, 1.3, 1.3, 0.15, 120, 255, 70, 50, 0, 0, 0, 0, 0, 0, 0)

        if (dist < 0.6) then
          if (haslicense) then
            draw3DWsText(v.entry.pos.x, v.entry.pos.y, v.entry.pos.z + 0.25, "Press ~b~E~w~ to enter the smithing shop.")

            if (IsControlJustReleased(1, 38)) then
              Citizen.CreateThread(function()                
                TriggerServerEvent("bms:teleporter:teleportToPoint", ped, v.exit.pos)
              end)
            end
          else
            if (not licchecked) then
              licchecked = true
              TriggerServerEvent("bms:crafting:weaponsmith:checklicense")
            else
              draw3DWsText(v.entry.pos.x, v.entry.pos.y, v.entry.pos.z + 0.25, "You require a Weaponsmith License to enter this facility.")
            end
          end
        else
          licchecked = false
        end
      else
        local dist = #(pos - v.exit.pos)

        if (dist < 40) then
          DrawMarker(1, v.exit.pos.x, v.exit.pos.y, v.exit.pos.z - 1.000001, 0, 0, 0, 0, 0, 0, 1.3, 1.3, 0.15, 120, 255, 70, 50, 0, 0, 0, 0, 0, 0, 0)

          if (dist < 0.6) then
            draw3DWsText(v.exit.pos.x, v.exit.pos.y, v.exit.pos.z + 0.25, "Press ~b~E~w~ to exit the smithing shop.")
            
            if (IsControlJustReleased(1, 38)) then
              Citizen.CreateThread(function()
                TriggerServerEvent("bms:teleporter:teleportToPoint", ped, v.entry.pos)
              end)
            end
          end
        end
      end
    end
  end
end)