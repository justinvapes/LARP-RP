local DrawMarker = DrawMarker
local table_insert = table.insert
local math_random = math.random
local math_randomseed = math.randomseed
local math_ceil = math.ceil
local math_min = math.min
local string_format = string.format
local methspots = {}
local methsellspots = {}
local methblips = {}
local methsellblips = {}
local cancook = true
local cooking = false
local cduration = 180000
local mduration = 0
local ctime = 0
local lastSpot
local cansell = true
local selling = false
local lastSellSpot
local stime = 0
local sduration = 240000
local active = false
local activeSpot = 0
local methUseTime -- server controlled
local methHealAmount = 40
local methSettings = {screenFx = {tcmod = "BikerFilter", timeoutMin = 8}}
local methUseAnim = {dict = "timetable@trevor@smoking_meth@idle_a", anim = "idle_c"}

local function round(num, numDecimalPlaces)
  return tonumber(string_format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local function draw3DMethText(x, y, z, text, sc)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local camPos = GetGameplayCamCoords()
  local vpos = vec3(x, y, z)
  local dist = #(camPos - vpos)
  local scale = (1 / dist)
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, sc or 0.55 * scale)
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

function drawSellTxt(text, font, centre, x, y, scale, r, g, b, a)
  SetTextFont(font)
  SetTextProportional(0)
  SetTextScale(scale, scale)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(centre)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x , y) 
end

function setupMethBlips()
  methblips = {}
  
  for _,v in pairs(methspots) do
    local blip
    
    if (v.disppos) then
      blip = AddBlipForCoord(v.disppos.x, v.disppos.y, v.disppos.z)
    else
      blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
    end
  
    SetBlipSprite(blip, 499)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 6)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Meth Cook")
    EndTextCommandSetBlipName(blip)
    
    table_insert(methblips, blip)
  end
end

function doMethCook(skill, seed)
  ctime = 0
  math_randomseed(seed)
  cte = math_random(1, 100)

  local exbase = 95
  mduration = math_ceil(cduration - (skill * 300))
  exbase = exbase + (skill * 0.2)

  Citizen.CreateThread(function()
    while cooking do
      Wait(1000)

      local ped = PlayerPedId()
      ctime = ctime + 1000
      exports.inventory:setCanTrade(false)
            
      if (not IsEntityDead(ped)) then
        if (cte > exbase) then
          local pos = GetEntityCoords(ped)
          
          cooking = false
          TriggerServerEvent("bms:jobs:meth:sendexplosion")
          cancook = true
          exports.inventory:setCanTrade(true)
          exports.pnotify:SendNotification({text = "An explosion has occured while cooking the batch.  Higher skill level will decrease this chance."})

          local distToA = #(pos - methspots[1].pos)
          local distToB = #(pos - methspots[2].pos)

          address = nil
          if (distToA < 20) then
            pos = {x = pos.x, y = pos.y, z = pos.z}
          elseif (distToB < 20) then
            address = "Great Ocean Hwy & West Eclipse Blvd | The Famous Pipeline Inn Restaurant & Bar"
            pos = {x = methspots[2].disppos.x, y = methspots[2].disppos.y, z = methspots[2].disppos.z}
          end

          TriggerEvent("bms:characters:setcrimereport", 6, {pos = {x = pos.x, y = pos.y, z = pos.z}, address = address, desc = "[529] Explosion reported at location.", override = true})
        else
          if (ctime >= mduration) then
            cooking = false
            TriggerServerEvent("bms:jobs:meth:finishcooking")
          end
        end
      else
        cooking = false
        cancook = true
        exports.inventory:setCanTrade(true)
        exports.pnotify:SendNotification({text = "You were killed during the cook and the ingredients were ruined."})
      end
    end
  end)
end

function sellMeth()
  stime = 0
  local distwarn = false

  Citizen.CreateThread(function()
    while selling do
      Wait(1000)

      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      
      stime = stime + 1000

      if (not IsEntityDead(ped)) then
        if (stime >= sduration) then
          selling = false
          TriggerServerEvent("bms:jobs:meth:finishselling")
        end

        local pos = GetEntityCoords(ped)
        local dist = #(pos - lastSellSpot.pos)

        if (dist > 20) then
          if (dist > 30 and distwarn) then
            selling = false
            cansell = true
            exports.pnotify:SendNotification({text = "You moved too far away from the sell spot and the dealer was spooked."})
            exports.vehicles:blockTrunk(false)
            exports.inventory:setCanTrade(true)
          else
            distwarn = true
            exports.pnotify:SendNotification({text = "If you get too far away from the sell spot the deal will be cancelled."})
          end
        else
          distwarn = false
        end
      else
        selling = false
        cansell = true
        exports.pnotify:SendNotification({text = "You were killed during your wait and the dealer was spooked."})
        exports.vehicles:blockTrunk(false)
        exports.inventory:setCanTrade(true)
      end
    end
  end)
end

function screenEffectTimeout()
  SetTimeout(methSettings.screenFx.timeoutMin * 60000, function()
    TriggerEvent("bms:char:timecycleTransition", methSettings.screenFx.tcmod, 0.5, 0, 0.001, false, true)
  end)
end

RegisterNetEvent("bms:jobs:meth:init")
AddEventHandler("bms:jobs:meth:init", function(data)
  if (data) then
    if (data.methspots) then
      methspots = data.methspots
    end

    if (data.methsellspots) then
      methsellspots = data.methsellspots
    end

    if (data.methUseTime) then
      methUseTime = data.methUseTime
    end
  end
end)

RegisterNetEvent("bms:jobs:meth:setActive")
AddEventHandler("bms:jobs:meth:setActive", function(act)
  active = act
end)

RegisterNetEvent("bms:jobs:meth:precheckresult")
AddEventHandler("bms:jobs:meth:precheckresult", function(pass, skill, seed)  
  if (pass) then
    cooking = true
    doMethCook(skill, seed)
  else
    cancook = true
    exports.inventory:setCanTrade(true)
    exports.pnotify:SendNotification({text = "You need to have <span style='color: skyblue'>5 Acetone, 2 Antifreeze and 3 Sudafed</span> to cook a batch of meth here.", timeout = 8000})
  end
end)

RegisterNetEvent("bms:jobs:meth:cookcomplete")
AddEventHandler("bms:jobs:meth:cookcomplete", function()
  cooking = false
  cancook = true
  exports.inventory:setCanTrade(true)
  TriggerServerEvent("bms:management:updateAnalytics", "Meth Cooked", 1)
end)

RegisterNetEvent("bms:jobs:meth:playexplosion")
AddEventHandler("bms:jobs:meth:playexplosion", function()
  AddExplosion(GetEntityCoords(PlayerPedId()), 6, 1.0, 1, 0, 1)
end)

RegisterNetEvent("bms:jobs:meth:sellmeth")
AddEventHandler("bms:jobs:meth:sellmeth", function(sqty)
  if (sqty) then
    if (sqty == 0) then
      exports.pnotify:SendNotification({text = "You do not have any meth to sell."})
      cansell = true
      lastSellSpot = nil
      exports.inventory:setCanTrade(true)
    else
      exports.vehicles:blockTrunk(true, true)
      selling = true
      sellMeth(sqty)
    end
  end
end)

RegisterNetEvent("bms:jobs:meth:sellcomplete")
AddEventHandler("bms:jobs:meth:sellcomplete", function(qty, profit)
  cansell = true
  lastSellSpot = nil
  exports.inventory:setCanTrade(true)
  exports.vehicles:blockTrunk(false)
  exports.pnotify:SendNotification({text = string_format("You have made <span style='color: skyblue'>$%.0f</span> from selling <span style='color: skyblue'>%s</span> ounce(s) of Meth.", profit, qty)})
end)

RegisterNetEvent("bms:jobs:meth:spawnDealerProps")
AddEventHandler("bms:jobs:meth:spawnDealerProps", function()
  for _,v in pairs(methsellspots) do
    Citizen.CreateThread(function()
      local hash = GetHashKey(v.dped)
    
      while not HasModelLoaded(hash) do
        RequestModel(hash)
        Wait(10)
      end

      local dped = CreatePed(4, hash, v.dpos.x, v.dpos.y, v.dpos.z, v.heading, true, false)
      
      if (DoesEntityExist(dped)) then        
        if (v.wander) then
          TaskWanderInArea(dped, v.dpos.x, v.dpos.y, v.dpos.z, 5.0, 0, 5)
        end
      end

      SetModelAsNoLongerNeeded(hash)

      if (v.dveh) then
        hash = GetHashKey(v.dveh)
        
        while not HasModelLoaded(hash) do
          RequestModel(hash)
          Wait(10)
        end

        local dveh = CreateVehicle(hash, v.dvpos.x, v.dvpos.y, v.dvpos.z, v.dvpos.heading, true, false)

        if (DoesEntityExist(dveh)) then
          SetVehicleDoorOpen(dveh, 5, false, false)
          SetVehicleDoorsLockedForAllPlayers(dveh, true)
          SetVehicleEngineOn(dveh, true, true, 1)
        end

        SetModelAsNoLongerNeeded(hash)
      end
    end)
  end
end)

RegisterNetEvent("bms:jobs:meth:sendActiveMethSpot")
AddEventHandler("bms:jobs:meth:sendActiveMethSpot", function(spot)
  activeSpot = spot
end)

RegisterNetEvent("bms:jobs:meth:useMeth")
AddEventHandler("bms:jobs:meth:useMeth", function(skipb)
  Citizen.CreateThread(function()
    local ped = PlayerPedId()
    local dead = IsPedDeadOrDying(ped)

    if (not dead) then
      exports.emotes:setCanEmote(false)
      TriggerEvent("bms:char:timecycleTransition", methSettings.screenFx.tcmod, 0, 0.5, 0.001, true, false)
      screenEffectTimeout()
      TriggerEvent("bms:emotes:setForcedProp", "methbag")
      Wait(1000)
      TriggerEvent("bms:emotes:clearForcedProp")
      TriggerEvent("bms:emotes:setForcedProp", "methpipe")

      while (not HasAnimDictLoaded(methUseAnim.dict)) do
        RequestAnimDict(methUseAnim.dict)
        Wait(10)
      end

      TaskPlayAnim(ped, methUseAnim.dict, methUseAnim.anim, 2.0, 2.0, -1, 31)
      RemoveAnimDict(methUseAnim.dict)

      Wait(methUseTime)
      
      if (not skipb) then
        local health = GetEntityHealth(ped)
        local maxhealth = GetEntityMaxHealth(ped)

        if (health < maxhealth) then
          health = math_min(health + methHealAmount, maxhealth)
          SetEntityHealth(ped, health)
        end

        exports.pnotify:SendNotification({text = "You feel a bit healthier, but more hungry and thirsty."})
      end

      TriggerEvent("bms:emotes:clearForcedProp")
      StopAnimTask(ped, methUseAnim.dict, methUseAnim.anim, 1.0)
      exports.emotes:setCanEmote(true)
    end
  end)
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    if (active) then
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)

      for _,v in pairs(methspots) do
        if (not cooking and cancook) then
          local dist = #(pos - v.pos)

          if (dist < 50) then
            DrawMarker(27, v.pos.x, v.pos.y, v.pos.z - 0.9, 0, 0, 0, 0, 0, 0, 1.8, 1.8, 0.9, 240, 70, 70, 50, 0, 0, 0, true, 0, 0, 0)
            
            if (dist < 1.85 and not IsEntityDead(ped)) then
              draw3DMethText(v.pos.x, v.pos.y, v.pos.z + 0.25, "Press ~b~[E]~w~ to cook a batch of meth.", 0.29)

              if (IsControlJustReleased(1, 38)) then
                cancook = false
                lastSpot = v
                exports.inventory:setCanTrade(false)
                TriggerServerEvent("bms:jobs:meth:cookprecheck")
              end
            end
          end
        end
      end

      if (cooking and lastSpot) then
        local dist = #(pos - lastSpot.pos)

        if (dist > 20) then
          exports.pnotify:SendNotification({text = "You have moved too far away from the lab and the materials were ruined."})
          lastSpot = nil
          cooking = false
          cancook = true
        end
      end

      if (cansell) then
        if (activeSpot > 0) then
          local currPos = methsellspots[activeSpot]

          if (currPos) then
            local dist = #(pos - currPos.pos)

            if (dist < 50) then
              DrawMarker(1, currPos.pos.x, currPos.pos.y, currPos.pos.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.2, 255, 180, 50, 50, 0, 0, 0, 0, 0, 0, 0)

              if (dist < 0.6 and not IsEntityDead(ped) and not IsPedSittingInAnyVehicle(ped)) then
                draw3DMethText(currPos.pos.x, currPos.pos.y, currPos.pos.z + 0.25, "You see a note on the ground: `I have found jesus and will no longer buy your devil powder.`", 0.29)
                --[[draw3DMethText(currPos.pos.x, currPos.pos.y, currPos.pos.z + 0.25, "Press ~b~[E]~w~ to call the meth dealer.", 0.29)

                if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
                  cansell = false
                  lastSellSpot = currPos
                  exports.inventory:setCanTrade(false)
                  TriggerServerEvent("bms:jobs:meth:sellprecheck")
                end]]
              end
            end
          end
        end
      end

      if (cooking) then
        local ttc = round((mduration - ctime) / 60000, 1)
        
        if (ttc < 1) then
          drawSellTxt(string_format("~b~Less than a minute~w~ until the cook is complete.", ttc), 0, 1, 0.5, 0.89, 0.35, 255, 255, 255, 255)
        else
          drawSellTxt(string_format("~b~%s~w~ minutes until the cook is complete.", ttc), 0, 1, 0.5, 0.89, 0.35, 255, 255, 255, 255)
        end
      end
      
      if (selling) then
        local tts = round((sduration - stime) / 60000, 1)
        
        if (tts < 1) then
          drawSellTxt(string_format("~b~Less than a minute~w~ remaining until the dealer shows up.", tts), 0, 1, 0.5, 0.89, 0.35, 255, 255, 255, 255)
        else
          drawSellTxt(string_format("~b~%.0f~w~ minutes remaining until the dealer shows up.", tts), 0, 1, 0.5, 0.89, 0.35, 255, 255, 255, 255)
        end
      end
    end
  end
end)