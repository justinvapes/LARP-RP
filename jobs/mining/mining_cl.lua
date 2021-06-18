local table_insert = table.insert
local string_format = string.format
local math_randomseed = math.randomseed
local math_random = math.random
local math_ceil = math.ceil
local minerals = {
  "Iron", "Gold", "Diamond", "Emerald", "Aluminum", "Steel", "Titanium Ore", "Titanium Crystal" -- Why is this even here?  Deprecate it.
}
local minespots = {}
local smeltspots = {
  {pos = vec3(1109.857, -2013.186, 35.454)} --/teleport 1109 -2013 35
}
local sellspots = {
  {pos = vec3(245.789, 359.173, 105.957), type = 1, dname = "Iron", bdesc = "Iron Seller"}, -- iron /teleport 245 359 105
  {pos = vec3(-1459.462, -414.197, 35.727), type = 2, dname = "Gold", bdesc = "Gold Seller"}, -- gold /teleport -1459 -414 35
  {pos = vec3(340.915, -964.252, 29.427), type = 3, dname = "Jewels", bdesc = "Jewels Seller"}, -- diamonds, emeralds /teleport 340 -964 29
  {pos = vec3(-81.717, -1326.119, 29.265), type = 4, dname = "Aluminum", bdesc = "Aluminum Seller"}, -- aluminum /teleport -81.717 -1326.119 29.265
  {pos = vec3(511.450, -1950.895, 24.985), type = 5, dname = "Steel", bdesc = "Steel Seller"}, -- steel /teleport 511.450 -1950.895 24.985
}

local miningblips = {}
local smeltingblips = {}
local sellingblips = {}
local mining = false
local smelting = false
local lastsmelt = 0
local distwarn = false
local mtime = 0
local mduration = 10000
local sduration = 90000 -- change to 90000
local stime = 0
local miningAllow = false
local mineraldeposits = {}
local localdeposits = {[1] = {}, [2] = {}}
local showminerals = false
local curprop = {}
local manim = {dict = "melee@large_wpn@streamed_core", anim = "ground_attack_on_spot"}
local mpfx = {
  {pfx = "ent_dst_concrete_large"},
  {pfx = "ent_brk_metal_frag"}
}
local miningswings = {cur = 0, max = 5}
local xrftool = {name = "XRF Mineral Analyzer", price = 30000}
local hasrftool = false
local closestrock = nil
local clindex = {key = "", index = 0, spot = 1}
local radiation = {active = false, level = 0}

function drawMiningText(text)
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
  DrawText(0.475, 0.88)
end

function setupMiningBlips()
  smeltingblips = {}
  sellingblips = {}
  
  for _,v in pairs(smeltspots) do
    local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
  
    SetBlipSprite(blip, 436)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 17)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Metals Smelter")
    EndTextCommandSetBlipName(blip)
    
    table_insert(smeltingblips, blip)
  end

  for _,v in pairs(sellspots) do
    if (not v.hideblip) then
      local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
    
      SetBlipSprite(blip, 431)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 1.0)
      SetBlipColour(blip, 17)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(v.bdesc)
      EndTextCommandSetBlipName(blip)
      
      table_insert(sellingblips, blip)
    end
  end
end

function finishMining()
  local ped = PlayerPedId()
  local dead = IsPedDeadOrDying(ped)

  if (not closestrock or clindex.index == 0 or dead) then
    mining = false
    radiation.active = false

    if (dead) then
      exports.pnotify:SendNotification({text = "You have been incapacitated.  If your health is not fine, thou shalt not mine."})
    else
      exports.pnotify:SendNotification({text = "You have moved too far away from the rock and the materials were wasted."})
    end
  else
    TriggerServerEvent("bms:jobs:mining:finishMining", {clindex = clindex})
  end
end

function startSmelting()
  smelting = true
  
  stime = 0
  local ped = PlayerPedId()
    
  Citizen.CreateThread(function()
    while smelting do
      Wait(1000)

      stime = stime + 1000

      if (stime == sduration) then
        TriggerServerEvent("bms:jobs:mining:finishSmelting")
      end
    end
  end)
end

function spawnMiningEntities(ldindex)
  if (not localdeposits[ldindex]) then
    localdeposits[ldindex] = {}
  end
  
  localdeposits[ldindex].spawned = true

  if (localdeposits[ldindex] and localdeposits[ldindex].entities) then
    for _,v in pairs(localdeposits[ldindex].entities) do
      DeleteEntity(v)
    end
  end

  localdeposits[ldindex].entities = {}

  for k,positions in pairs(mineraldeposits) do
    for _,v in pairs(positions) do
      if (v.spot == ldindex) then
        print(string_format("creating %s at %s, %s, %s [Mine Spot %s]", k, v.pos.x, v.pos.y, v.pos.z, v.spot))
        local ent = CreateObject(GetHashKey(k), v.pos.x, v.pos.y, v.pos.z)

        if (v.rot and v.rot.x) then
          SetEntityRotation(ent, v.rot.y, v.rot.x, v.rot.z, 2)
        end
        
        FreezeEntityPosition(ent, true)
        localdeposits[ldindex].entities[ent] = ent
      end
    end
  end
end

function despawnMiningEntities(ldindex)
  if (localdeposits[ldindex].spawned) then
    if (localdeposits[ldindex] and localdeposits[ldindex].entities) then
      for _,v in pairs(localdeposits[ldindex].entities) do
        print(string_format("despawning entity for spot %s, %s", ldindex, v))
        DeleteEntity(v)
      end
    end

    localdeposits[ldindex].spawned = false
    localdeposits[ldindex].entities = {}
  end
end

function watchRadiation()
  math_randomseed(GetGameTimer())
  SendNUIMessage({showBiohazard = true})
  
  Citizen.CreateThread(function()
    while radiation.active do
      Wait(math_random(12000, 25000))
      radiation.level = radiation.level + 1

      if (radiation.level > 5) then
        radiation.level = 0

        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)

        SetEntityHealth(ped, health - 5)
      end
    end
  end)
end

RegisterNetEvent("bms:jobs:mining:activateMines")
AddEventHandler("bms:jobs:mining:activateMines", function(data)
  local st = data.switch
  local deposits = data.mineraldeposits
  
  minespots = data.minespots

  if (st == "on") then
    miningAllow = true
  else
    miningAllow = false
  end

  if (miningAllow and minespots) then
    if (#miningblips == 0) then
      for _,v in pairs(minespots) do
        if (not v.hidespot) then
          local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
        
          SetBlipSprite(blip, 314)
          SetBlipDisplay(blip, 4)
          SetBlipScale(blip, 1.0)
          SetBlipColour(blip, 3)
          SetBlipAsShortRange(blip, true)
          BeginTextCommandSetBlipName("STRING")
          AddTextComponentString("Mining Spot")
          EndTextCommandSetBlipName(blip)
          
          table_insert(miningblips, blip)
        end
      end
    end
  else
    if (#miningblips > 0) then
      for _,v in pairs(miningblips) do
        RemoveBlip(v)
      end

      miningblips = {}
      SendNUIMessage({hideMineProgress = true})
    end
  end

  if (not localdeposits[1].spawned) then
    mineraldeposits = deposits
  end

  hasrftool = data.hasrftool
end)

RegisterNetEvent("bms:jobs:mining:miningComplete")
AddEventHandler("bms:jobs:mining:miningComplete", function()
  local ped = PlayerPedId()  

  mining = false
  mtime = 0
  ClearPedTasks(ped)
  exports.inventory:setCanTrade(true)
end)

RegisterNetEvent("bms:jobs:mining:smeltingComplete")
AddEventHandler("bms:jobs:mining:smeltingComplete", function()
  smelting = false
  stime = 0
  
  local ped = PlayerPedId()
  
  SetTimeout(10000, function()
    exports.inventory:blockTrade(false)
    exports.inventory:blockInventoryOpen(false)
  end)
end)

RegisterNetEvent("bms:jobs:mining:sellingComplete")
AddEventHandler("bms:jobs:mining:sellingComplete", function(data)
  local profit = data.profit
  local dname = data.dname
  
  selling = false

  if (profit == 0) then
    exports.pnotify:SendNotification({text = "You do not have any items to sell."})
  else
    exports.pnotify:SendNotification({text = string_format("You have made <font color='skyblue'>$%s</font> from selling your %s.", profit, dname), timeout = 8000})
    TriggerServerEvent("bms:management:updateAnalytics", "Metals Sold", 1)
  end
end)

RegisterNetEvent("bms:jobs:mining:miningtweaked")
AddEventHandler("bms:jobs:mining:miningtweaked", function()
  local inregion = false
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)

  for _,v in pairs(minespots) do
    local dist = #(pos - v.pos)

    if (dist < 85.2) then
      inregion = true
      break
    end
  end

  if (inregion) then
    exports.pnotify:SendNotification({text = "The mines are undergoing layoffs and the ground has almost dried up.  <span style='color:lawngreen'>Try again at a later time.</span>", timeout = 20000})
  end
end)

RegisterNetEvent("bms:jobs:mining:showminerals")
AddEventHandler("bms:jobs:mining:showminerals", function(data)
  if (data) then
    mineraldeposits = data.mineraldeposits
    showminerals = not showminerals

    for k,_ in pairs(localdeposits) do
      if (localdeposits[k] and localdeposits[k].entities) then
        for _,v in pairs(localdeposits[k].entities) do
          DeleteEntity(v)
        end

        localdeposits[k].entities = {}
      end
    end

    if (showminerals) then
      for k,positions in pairs(mineraldeposits) do
        for _,v in pairs(positions) do
          print(string_format("creating %s at %s, %s, %s", k, v.pos.x, v.pos.y, v.pos.z))
          local ent = CreateObject(GetHashKey(k), v.pos.x, v.pos.y, v.pos.z)

          FreezeEntityPosition(ent, true)
          localdeposits[v.spot].entities[ent] = ent
        end
      end
    end
  end
end)

RegisterNetEvent("bms:jobs:mining:processMiningAudio")
AddEventHandler("bms:jobs:mining:processMiningAudio", function(data)
  if (data) then
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local spos = vec3(data.pos.x, data.pos.y, data.pos.z)
    local aseq = data.aseq
    local sounds = {"mining1", "mining2", "mining3"}
    local dist = #(pos - spos)
    local pickent = NetToObj(data.picknetid)
    
    if (dist < 30.0) then
      math_randomseed(GetGameTimer())
      Citizen.CreateThread(function()
        RequestNamedPtfxAsset("core")
        Wait(1250)
      
        for i = 1, #aseq do
          local p = mpfx[math_random(1, #mpfx)]

          UseParticleFxAssetNextCall("core")

          if (DoesEntityExist(pickent)) then
            local pfxpos = GetOffsetFromEntityInWorldCoords(pickent, 0.2, 0.0, 0.5)

            local pfx = StartParticleFxNonLoopedAtCoord(p.pfx, pfxpos.x, pfxpos.y, pfxpos.z, 0, 0, 0, 1.2, 0, 0, 0)
            Wait(2300)
            StopParticleFxLooped(pfx)
          end
        end

        RemoveNamedPtfxAsset("core")
      end)
      
      Citizen.CreateThread(function()
        Wait(1000)

        for i = 1, #aseq do
          local sound = sounds[aseq[i]]

          TriggerEvent("bms:soundmgr:playSoundDist", 0, 130.0, sound, -1, spos)
          Wait(2300)
        end
      end)
    end
  end
end)

RegisterNetEvent("bms:jobs:mining:updateMineralLevels")
AddEventHandler("bms:jobs:mining:updateMineralLevels", function(data)
  if (data) then
    local newminerals = data.mineraldeposits

    for k,positions in pairs(newminerals) do
      for i,v in pairs(positions) do
        if (mineraldeposits[k][i].curlevel) then
          mineraldeposits[k][i].curlevel = v.curlevel
        end
      end
    end

    if (closestrock and clindex.key ~= "" and clindex.index ~= 0) then
      if (newminerals[clindex.key][clindex.index].curlevel) then
        local clevel = newminerals[clindex.key][clindex.index].curlevel

        closestrock.curlevel = clevel
      end
    end
  end
end)

RegisterNetEvent("bms:jobs:mining:miningSkill")
AddEventHandler("bms:jobs:mining:miningSkill", function(data)
  if (data and data.sw) then
    miningswings.max = data.sw
  end
end)

AddEventHandler("bms:emotes:props:attachedNewProp", function(rcurprop)
  curprop = rcurprop
end)

AddEventHandler("onResourceStop", function(res)
  if (res == GetCurrentResourceName()) then
    for k,_ in pairs(localdeposits) do
      if (localdeposits[k] and localdeposits[k].entities) then
        for _,v in pairs(localdeposits[k].entities) do
          DeleteEntity(v)
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    if (#smeltingblips == 0) then
      setupMiningBlips()
    end

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    --if (miningAllow) then
    if (minespots and #minespots > 0) then
      for j,m in pairs(minespots) do
        if (not mining) then
          local dist = #(pos - m.pos)

          if (dist < 85.2) then
            if (not localdeposits[j]) then
              localdeposits[j] = {entities = {}}
            end
            
            if (not localdeposits[j].spawned) then
              spawnMiningEntities(j)
            end

            if (miningAllow) then
              local inveh = IsPedInAnyVehicle(ped, true)
              local handcuffed = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)
              local armed,_ = GetCurrentPedWeapon(ped, true)
              local dead = IsPedDeadOrDying(ped)
            
              if (not inveh and not handcuffed and not dead and not IsEntityDead(ped)) then
                if (not armed) then
                  for k,positions in pairs(mineraldeposits) do
                    for i,v in pairs(positions) do
                      local dist = #(pos - v.pos)

                      if (dist < 25.0 and dist > v.range) then
                        DrawMarker(42, v.pos.x, v.pos.y, v.pos.z + 1.2, 0, 0, 0, 0, 0, 0, 0.12, 0.12, 0.12, 0, 255, 160, 80, 0, 0, 0, true, 0, 0, 0)
                      end

                      if (dist < v.range) then
                        closestrock = v
                        clindex.key = k
                        clindex.index = i
                        clindex.spot = j
                        DrawMarker(42, v.pos.x, v.pos.y, v.pos.z + 1.2, 0, 0, 0, 0, 0, 0, 0.12, 0.12, 0.12, 180, 0, 160, 80, 0, 0, 0, true, 0, 0, 0)
                        
                        if (curprop.propid == "pickaxe") then
                          DisableControlAction(0, 24, true)

                          if (IsControlJustReleased(1, 24) or IsDisabledControlJustReleased(1, 24)) then -- left click
                            mining = true
                            exports.inventory:setCanTrade(false)

                            local aseq = {}

                            math_randomseed(GetGameTimer())
                            
                            for i = 1, miningswings.max do
                              table_insert(aseq, math_random(1, 3))
                            end

                            Citizen.CreateThread(function()
                              TaskTurnPedToFaceCoord(ped, v.pos.x, v.pos.y, v.pos.z, 1125)
                              Wait(1125)
                              TriggerServerEvent("bms:jobs:mining:miningStart", {aseq = aseq, maxsw = miningswings.max, pos = {x = pos.x, y = pos.y, z = pos.z}, picknetid = curprop.netid})

                              while (miningswings.cur < miningswings.max) do
                                Wait(1)

                                while (not HasAnimDictLoaded(manim.dict)) do
                                  RequestAnimDict(manim.dict)
                                  Wait(10)
                                end

                                TaskTurnPedToFaceCoord(ped, v.pos.x, v.pos.y, v.pos.z, 300)
                                Wait(300)
                                TaskPlayAnim(ped, manim.dict, manim.anim, 8.0, -8, -1, 80, 0, 0, 0, 0)
                                Wait(2000)
                                miningswings.cur = miningswings.cur + 1
                                print(string_format("miningswings >> %s", miningswings.cur))
                              end

                              miningswings.cur = 0
                              finishMining()
                              RemoveAnimDict(manim.dict)
                            end)
                          end
                        else
                          drawMiningText("~w~You must have a ~b~pickaxe~w~ to mine this.")
                        end

                        if (v.radiated and not radiation.active) then
                          radiation.active = true
                          watchRadiation()
                        end
                      end
                    end
                  end
                end
              end
            end
          else
            if (localdeposits[j] and localdeposits[j].spawned) then
              despawnMiningEntities(j)
            end
          end
        end
      end
    end

    if (closestrock) then
      local dist = #(pos - closestrock.pos)

      if (dist > closestrock.range) then
        closestrock = nil
        clindex = {key = "", index = 0}
        radiation.active = false
        SendNUIMessage({hideMineProgress = true})
        SendNUIMessage({hideBiohazard = true})
      end

      if (closestrock) then
        if (hasrftool) then
          local onscreen, scx, scy = GetScreenCoordFromWorldCoord(closestrock.pos.x, closestrock.pos.y, closestrock.pos.z + 0.789)
      
          if (onscreen) then
            SendNUIMessage({setMineProgressPosition = true, px = scx, py = scy})          
            SendNUIMessage({setMineProgressVal = true, value = closestrock.curlevel, max = closestrock.maxlevel})
          else
            SendNUIMessage({hideMineProgress = true})
          end
        else
          SendNUIMessage({hideMineProgress = true})
        end
      end
    elseif (radiation.active) then
      radiation.active = false
      SendNUIMessage({hideBiohazard = true})
    end

    for i,v in ipairs(smeltspots) do
      if (not smelting) then
        local dist = #(pos - v.pos)

        if (dist < 50) then
          DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.15, 255, 180, 50, 50, 0, 0, 0, 0, 0, 0, 0)

          if (dist < 1.25) then
            drawMiningText("~w~Press ~b~[E]~w~ to start smelting your metals.")

            if (IsControlJustReleased(1, 38)) then
              lastsmelt = i
              exports.inventory:blockTrade(true)
              exports.inventory:blockInventoryOpen(true)
              exports.management:TriggerServerCallback("bms:jobs:mining:checklimits", function(rdata)
                if (rdata) then
                  local skval = rdata.skval or 0
                  local items = rdata.minerals or {}

                  if (skval > 20) then
                    sduration = 70000
                  elseif (skval > 50) then
                    sduration = 50000
                  elseif (skval > 85) then
                    sduration = 40000
                  elseif (skval >= 100) then
                    sduration = 30000
                  end

                  if (rdata.allow) then
                    if (items and #items > 0) then
                      if (not smelting) then
                        startSmelting()
                      end
                    else
                      exports.inventory:blockTrade(false)
                      exports.inventory:blockInventoryOpen(false)
                      exports.pnotify:SendNotification({text = "You do not have any metals to smelt."})
                    end
                  else
                    exports.inventory:blockTrade(false)
                    exports.inventory:blockInventoryOpen(false)
                    exports.pnotify:SendNotification({text = "You can not smelt with any finished material higher than 75 in your inventory.  Sell them and try again."})
                  end
                end
              end, {minerals = minerals})
            end
          end
        end
      end
    end

    if (smelting) then
      drawMiningText(string_format("~w~Your ~b~metals~w~ are smelting.. Please wait for %s seconds.", math_ceil((sduration - stime) / 1000)))

      if (lastsmelt > 0) then
        local sspot = smeltspots[lastsmelt].pos
        local dist = #(pos - sspot)

        if (dist > 20) then
          if (not distwarn) then
            distwarn = true
            exports.pnotify:SendNotification({text = "If you move any further from the smelter your job will be cancelled."})
          end

          if (dist > 25) then
            exports.pnotify:SendNotification({text = "You have moved too far from the smelter and your job was cancelled."})
            distwarn = false
            smelting = false
            stime = 0
            exports.inventory:blockTrade(false)
            exports.inventory:blockInventoryOpen(false)
          end
        else
          distwarn = false
        end
      end
    end

    for _,v in pairs(sellspots) do
      if (not selling) then
        local dist = #(pos - v.pos)

        if (dist < 50) then
          DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.15, 255, 180, 50, 50, 0, 0, 0, 0, 0, 0, 0)

          if (dist < 0.6) then
            drawMiningText(string_format("~w~Press ~b~[E]~w~ to sell all of your %s.\nPress ~b~[H]~w~ to buy an XRF Analyzer for $%s.", v.dname, xrftool.price))

            if (IsControlJustReleased(1, 38)) then
              selling = true
              TriggerServerEvent("bms:jobs:mining:sellAllMetals", {type = v.type, dname = v.dname})
            elseif (IsControlJustReleased(1, 74)) then
              selling = true
              exports.management:TriggerServerCallback("bms:jobs:mining:buyXrfAnalyzer", function(rdata)
                if (rdata.success) then
                  exports.pnotify:SendNotification({text = string_format("You have purchased an <span style='color: skyblue'>%s</span> for <span color='lawngreen'>$%s</span>.", xrftool.name, xrftool.price)})
                  hasrftool = true
                else
                  if (rdata.msg) then
                    exports.pnotify:SendNotification({text = rdata.msg})
                  end
                end

                selling = false
              end)
            end
          end
        end
      end
    end

    if (showminerals) then -- debug draw
      for _,positions in pairs(mineraldeposits) do
        for _,v in pairs(positions) do
          local dist = #(pos - v.pos)

          if (dist < 50) then
            --print(string_format("drawing marker for %s, %s, %s", v.pos.x, v.pos.y, v.pos.z))
            DrawMarker(1, v.pos.x, v.pos.y, v.pos.z, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.15, 255, 180, 50, 50, 0, 0, 0, 0, 0, 0, 0)
          end
        end
      end
    end
  end
end)