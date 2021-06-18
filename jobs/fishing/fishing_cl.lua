local table_insert = table.insert
local isFishing = false
local canfish = true
local justToggled = false
local curWaitTime = 5000
local caughtFish = false
local fishingPole
local fishTimer = {curWait = 0}
local fishboardshowing = false
local fishmax = 30
local baits = {}
local baitshops = {}
local baitShopBlips = {}
local lastbait
local sinkerprop = "prop_golf_ball_p2"
local sinker = 0
local line = 0
local cancatch = false
local pfx = {cat = "core", name = "ent_dst_gen_water_spray"}
local blinking = false
local unarmed = GetHashKey("WEAPON_UNARMED")
local inRefishTimeout = false
local watermats = {435688960, -1136057692, -273490167, 909950165}

function drawFishingText(text, r, g, b)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.32, 0.32)
  SetTextColour(r, g, b, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(0.475, 0.88)
end

function deletePoleAndProps(cb)
  Citizen.CreateThread(function()
    local ped = PlayerPedId()
    
    SetEnableHandcuffs(ped, false)
    ClearPedTasks(ped)

    local timeoutmax = 4000
    local timeout = 0

    while (not NetworkHasControlOfEntity(sinker) and timeout < timeoutmax) do
      NetworkRequestControlOfEntity(sinker)
      Wait(500)
      timeout = timeout + 500
    end

    timeout = 0

    while (DoesEntityExist(sinker) and timeout < timeoutmax) do
      DeleteEntity(sinker)
      Wait(500)
      timeout = timeout + 500
    end

    timeout = 0

    while (not NetworkHasControlOfEntity(fishingPole) and timeout < timeoutmax) do
      NetworkRequestControlOfEntity(fishingPole)
      Wait(500)
      timeout = timeout + 500
    end

    timeout = 0

    while (DoesEntityExist(fishingPole) and timeout < timeoutmax) do
      DeleteEntity(fishingPole)
      Wait(500)
      timeout = timeout + 500
    end

    SendNUIMessage({hideFishIcon = true})
    sinker = 0
    cancatch = false
    cb()
  end)
end

function renderBaitShopBlips()
  for _,v in pairs(baitshops) do
    local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
  
    SetBlipSprite(blip, 68)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 37)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Bait Shop")
    EndTextCommandSetBlipName(blip)
    
    table_insert(baitShopBlips, blip)
  end
end

function checkCaughtFish()
  fishTimer = {}
  isFishing = false
  caughtFish = false
  
  if (sinker and DoesEntityExist(sinker)) then
    local spos = GetEntityCoords(sinker)
    
    TriggerServerEvent("bms:jobs:fishing:startwaterpfx", {pos = {x = spos.x, y = spos.y, z = spos.z}})
    ApplyForceToEntity(sinker, 1, 0, 0, -1.0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
  end
  cancatch = true

  local cctimer = {cur = 0, max = 300}
  local cancelcc = false

  if (not blinking) then
    SendNUIMessage({showFishIcon = true})
  end

  Citizen.CreateThread(function()
    while (cancatch) do
      Wait(1)

      local ped = PlayerPedId()
      cctimer.cur = cctimer.cur + 1

      if (isGameControlPressed(1, 38)) then -- E
        cancatch = false
        local pos = GetEntityCoords(ped)
        local vpos = {x = pos.x, y = pos.y, z = pos.z}
        local boat = GetClosestVehicle(pos.x, pos.y, pos.z, 10.000, 0, 12294)
        local onveh = IsPedOnVehicle(ped)
        local onboat = false
        
        if (DoesEntityExist(boat)) then
          onboat = IsThisModelABoat(GetEntityModel(boat)) and IsEntityInWater(boat) and onveh
        end
        local data = {pos = vpos, bait = lastbait, onboat = onboat}

        --cctimer.cur = 0
        cancelcc = true
        exports.management:TriggerServerCallback("bms:jobs:fishing:catchFish", function(ret)
          if (ret.fail) then
            SendNUIMessage({hideFishIcon = true})
            playAnimOnPed(ped, "amb@world_human_stand_fishing@idle_a", "idle_a", 2.0)
            Wait(8000)
            exports.pnotify:SendNotification({text = ret.msg})
            StopAnimTask(ped, "amb@world_human_stand_fishing@idle_a", "idle_a", 2.0)
          elseif (ret.success) then
            -- todo notify of caught fish
            SendNUIMessage({hideFishIcon = true})
            playAnimOnPed(ped, "amb@world_human_stand_fishing@idle_a", "idle_c", 2.0)
            Wait(8000)
            exports.pnotify:SendNotification({text = string.format("You have caught a(n) <span style='color: skyblue'>%s</span> weighing <span style='color: skyblue'>%s</span> pounds.", ret.fname, ret.weight)})
            StopAnimTask(ped, "amb@world_human_stand_fishing@idle_a", "idle_c", 2.0)
          end

          isCatchWait = false
          deletePoleAndProps(function()
            canfish = true
            SetPedDiesInWater(ped, true)
            startRefishTimeout()
          end)
        end, data)
      end

      if (cctimer.cur >= cctimer.max and not cancelcc) then
        cctimer.cur = 0
        exports.pnotify:SendNotification({text = "You did not catch any fish."})
        deletePoleAndProps(function()
          canfish = true
          cancatch = false
          isCatchWait = false
          SetPedDiesInWater(ped, true)
          startRefishTimeout()
        end)
      end
    end
  end)
end

function startRefishTimeout()
  local timeout = {cur = 0, max = 3000}

  inRefishTimeout = true
  
  Citizen.CreateThread(function()
    while (inRefishTimeout) do
      Wait(1000)
      timeout.cur = timeout.cur + 1000

      if (timeout.cur > timeout.max) then
        inRefishTimeout = false
        exports.emotes:setCanEmote(true)
      end
    end
  end)
end

function playAnimOnPed(ped, anim, clip)
  Citizen.CreateThread(function()    
    while (not HasAnimDictLoaded(anim)) do
      RequestAnimDict(anim)
      Wait(1)
    end
    
    if (IsEntityPlayingAnim(ped, anim, clip, 3)) then
      ClearPedSecondaryTask(ped)
    else
      TaskPlayAnim(ped, anim, clip, 8.0, 1.0, -1, 49, 0, 0, 0, 0)
    end

    RemoveAnimDict(anim)
  end)
end

function AttachFishingPoleToPed(prop, boneidx, x, y, z, rx, ry, rz)
  local ped = PlayerPedId()
  boneidx = GetPedBoneIndex(ped, boneidx)
  local hash = GetHashKey(prop)

  while (not HasModelLoaded(hash)) do
    RequestModel(hash)
    Wait(10)
  end

  local obj = CreateObject(hash,  1729.73,  6403.90,  34.56, true,  true, true)

  AttachEntityToEntity(obj, ped, boneidx, x, y, z, rx, ry, rz, false, false, false, false, 2, true)
  SetModelAsNoLongerNeeded(hash)

  return obj
end

function createSinker(cb)
  local ped = PlayerPedId()
  local opos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
  local hash = GetHashKey(sinkerprop)

  if (sinker > 0) then
    DeleteEntity(sinker)
    sinker = 0
  end

  while (not HasModelLoaded(hash)) do
    RequestModel(hash)
    Wait(10)
  end

  sinker = CreateObject(hash, opos.x, opos.y, opos.z, true)
  SetModelAsNoLongerNeeded(hash)

  cb()
end

function isWaterInFront(ped)
  local foffset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
  local rayh = CastRayPointToPoint(foffset.x, foffset.y, foffset.z, foffset.x, foffset.y, foffset.z - 55.0, 1, ped, 0) -- ray shot downward from offset to detect water in front
  local _,_,_,_,matunder,_ = GetShapeTestResultEx(rayh)
  local match = false
  
  for _,v in pairs(watermats) do
    if (v == matunder) then
      match = true
      break
    end
  end
  
  return match
end

RegisterNetEvent("bms:fishing:activation")
AddEventHandler("bms:fishing:activation", function(data)
  if (data) then
    baits = data.baits
    baitshops = data.baitshops
  end
end)

RegisterNetEvent("bms:fishing:setIsFishing")
AddEventHandler("bms:fishing:setIsFishing", function()
  if (not lastbait) then
    exports.pnotify:SendNotification({text = "You must select a <span style='color: skyblue'>bait</span> in your inventory first.  You can buy various bait types from convenience stores.", layout = "bottomRight"})
    return
  end
  
  exports.inventory:getFishCount(function(fcount)
    if (fcount >= fishmax) then
      exports.pnotify:SendNotification({text = "You can not carry any more fish!  Sell the ones you are carrying first."})
    else
      if (canfish) then
        if (not isFishing) then
          canfish = false
          local ped = PlayerPedId()
          local inveh = IsPedInAnyVehicle(ped, false)
          local swimming = IsPedSwimming(ped)
          local inwater = IsEntityInWater(ped)
          local onveh = IsPedOnVehicle(ped)
          local posFishing = GetEntityCoords(ped)
          local boat = GetClosestVehicle(posFishing.x, posFishing.y, posFishing.z, 10.000, 0, 12294)
          local onboat = false
          local legionCheck = IsEntityInArea(ped, 159.14276, -980.24805, 20.09193, 205.32829, -962.78357, 34.98637, 0, 1, 0)
          local waterfront = isWaterInFront(ped)
          
          if DoesEntityExist(boat) then
            onboat = IsThisModelABoat(GetEntityModel(boat)) and IsEntityInWater(boat) and onveh
          end
          
          if (inveh) then
            exports.pnotify:SendNotification({text = "You can not fish from a vehicle."})
            canfish = true
          elseif (swimming) then
            exports.pnotify:SendNotification({text = "You can not fish while swimming in water."})
            canfish = true
          elseif (not (inwater or onboat or waterfront)) then
            exports.pnotify:SendNotification({text = "You must be in shallow water, have water in front of you, or be on a boat to go fishing."})
            canfish = true
          elseif (legionCheck) then
            exports.pnotify:SendNotification({text = "Leave the goldfish alone."}) 
            canfish = true
          else
            if (exports.inventory:itemExistsInInv("Fishing Pole")) then
              if (exports.inventory:itemExistsInInv(lastbait)) then
                isFishing = true
                justToggled = true
                SetRandomSeed(GetGameTimer())
                exports.emotes:setCanEmote(false)
              else
                exports.pnotify:SendNotification({text = "You do not have any bait.  Buy some bait at a convenience store."})
                canfish = true
              end
            end
          end
        else
          exports.pnotify:SendNotification({text = "You are already fishing!"})
        end
      else
        exports.pnotify:SendNotification({text = "You can not fish again yet."})
      end
    end
  end)
end)

RegisterNetEvent("bms:fishing:fishingcomplete")
AddEventHandler("bms:fishing:fishingcomplete", function(msg)
  if (msg) then
    exports.pnotify:SendNotification({text = msg})
  end

  canfish = true
  isCatchWait = false
  exports.emotes:setCanEmote(true)
end)

RegisterNetEvent("bms:fishing:setfishingboard")
AddEventHandler("bms:fishing:setfishingboard", function(htmlstr)
  if (htmlstr) then
    SendNUIMessage({showFishingBoard = true, htmlstr = htmlstr})
  end
end)

RegisterNetEvent("bms:jobs:fishing:startwaterpfx")
AddEventHandler("bms:jobs:fishing:startwaterpfx", function(data)
  if (data) then
    atpos = data.pos

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local dist = Vdist(pos.x, pos.y, pos.z, atpos.x, atpos.y, atpos.z)

    if (dist < 80) then
      RequestNamedPtfxAsset(pfx.cat)
      UseParticleFxAssetNextCall(pfx.cat)
      StartParticleFxNonLoopedAtCoord(pfx.name, atpos.x, atpos.y, atpos.z, 0, 0, 0, 1.5, 0, 0, 0)
      RemoveNamedPtfxAsset(pfx.cat)
    end
  end
end)

RegisterNetEvent("bms:jobs:fishing:initMenu")
AddEventHandler("bms:jobs:fishing:initMenu", function()
  exports.actionmenu:addAction("statistics", "fishinglb", "none", "Fishing Leaderboard", 7, -1)
end)

RegisterNetEvent("bms:jobs:fishing:toggleLeaderboard")
AddEventHandler("bms:jobs:fishing:toggleLeaderboard", function()
  fishboardshowing = not fishboardshowing

  if (fishboardshowing) then
    TriggerServerEvent("bms:fishing:getfishingboard")
  else
    SendNUIMessage({
      hideFishingBoard = true
    })
  end
end)

RegisterNetEvent("bms:fishing:setBait")
AddEventHandler("bms:fishing:setBait", function(bait)
  lastbait = bait
  exports.pnotify:SendNotification({text = string.format("<span style='color: lawngreen'>%s</span> selected as fishing <span style='color: skyblue;'>bait</span>.", bait), layout = "bottomRight"})
end)

RegisterNetEvent("bms:jobs:fishing:confirmBaitBuy")
AddEventHandler("bms:jobs:fishing:confirmBaitBuy", function(data)
  if (data) then
    exports.pnotify:SendNotification({text = string.format("You have purchased %s types of bait for <span style='color: lawngreen'>$%s</span>.", data.amount, data.price)})
  end

  TriggerEvent("bms:nuiFocusDisable")
end)

RegisterNUICallback("closeFishBoards", function(data, cb)
  fishboardshowing = false
  SetNuiFocus(false, false)
end)

RegisterNUICallback("bms:jobs:fishing:processBaitBuy", function(data)
  TriggerServerEvent("bms:jobs:fishing:processBaitBuy", data)
end)

RegisterNUICallback("bms:jobs:fishing:shopExit", function()
  TriggerEvent("bms:nuiFocusDisable")
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)
    
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if (#baitshops > 0 and #baitShopBlips == 0) then
      renderBaitShopBlips()
    end

    if (inRefishTimeout) then
      drawFishingText("~s~Press ~b~[E]~s~ to  fish  again.", 0, 150, 255)

      if (isGameControlPressed(1, 38)) then
        inRefishTimeout = false
        TriggerEvent("bms:fishing:setIsFishing")
      end
    end

    for _,v in pairs(baitshops) do
      local dist = Vdist(pos.x, pos.y, pos.z, v.pos.x, v.pos.y, v.pos.z)

      if (dist < 40) then
        DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.000001, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 0.15, 0, 180, 255, 50, 0, 0, 0, 0, 0, 0, 0)

        if (dist < 0.5) then
          draw3DTextGlobal(v.pos.x, v.pos.y, v.pos.z + 0.15, "Press ~b~E~w~ to purchase some bait.", 0.23)
          
          if (isGameControlPressed(1, 38)) then
            exports.management:TriggerServerCallback("bms:jobs:fishing:getBaits", function(data)
              if (data) then
                exports.services:loadBsqMenu("jobs", "Bait N' Tackle Shop", true, false, data, "bms:jobs:fishing:shopExit", nil, "bms:jobs:fishing:processBaitBuy")
              end
            end)
          end
        end
      end
    end

    if (justToggled) then            
      local wait = GetRandomIntInRange(5000, 30000)
      math.randomseed(GetGameTimer())
      
      fishTimer.waitTime = wait
      fishTimer.curWait = 0
      fishTimer.doTimer = function()
        Citizen.CreateThread(function()
          while (isFishing) do
            Citizen.Wait(1000)
            if (fishTimer.curWait ~= nil) then
              fishTimer.curWait = fishTimer.curWait + 1000
                
              if (fishTimer.curWait >= fishTimer.waitTime) then
                isFishing = false
                checkCaughtFish()
              end
            end
          end
        end)
      end
        
      fishTimer.doTimer()
      SetCurrentPedWeapon(ped, unarmed, true)
      SetEnableHandcuffs(ped, true)
      fishingPole = AttachFishingPoleToPed("prop_fishing_rod_01", 60309, 0, 0, 0, 0, 0, 0)
      createSinker(function()
        local heading = math.rad(GetEntityHeading(ped))
        local y = math.cos(heading)
        local x = math.sin(heading)

        if (sinker and DoesEntityExist(sinker)) then
          ApplyForceToEntity(sinker, 1, -0.12*x, 0.12*y, 0.375, 0.0, 0.0, 0.0, 0, 1, 0, 0, 0, 0)
        end
      end)
      playAnimOnPed(ped, "amb@world_human_stand_fishing@base", "base")
      
      justToggled = false
    end
    
    while (isFishing) do
      Wait(1)
      SetPedDiesInstantlyInWater(ped, false)
      SetPedDiesInWater(ped, false)
      
      -- checks for ped in vehicle, swimming, diving, falling, jumping, jumping out of vehicle, and running
      if (IsPedInAnyVehicle(ped, true) or IsPedSwimmingUnderWater(ped) or IsPedSwimming(ped) or IsPedDiving(ped) or 
          IsPedFalling(ped) or IsPedJumping(ped) or IsPedJumpingOutOfVehicle(ped) or IsPedRunning(ped) or IsPedRagdoll(ped) or
          IsPedFatallyInjured(ped) or IsPedInParachuteFreeFall(ped)) then
        isFishing = false
        fishTimer = {}
        ClearPedSecondaryTask(ped)
        playAnimOnPed(ped, "amb@world_human_stand_fishing@idle_a", "idle_a", 2.0)
        Wait(2000)
        StopAnimTask(ped, "amb@world_human_stand_fishing@idle_a", "idle_a", 2.0)
        deletePoleAndProps(function()
          SetEnableHandcuffs(ped, false)
          exports.emotes:setCanEmote(true)
          canfish = true
          exports.pnotify:SendNotification({text = "You scared the fish away!"})
          SetPedDiesInWater(ped, true)
        end)
      else
        if (not IsEntityPlayingAnim(ped, "amb@world_human_stand_fishing@base", "base", 3)) then
          TaskPlayAnim(ped, "amb@world_human_stand_fishing@base", "base", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
        end
      end

      if (not cancatch) then
        local atpos = GetEntityCoords(sinker)
        DrawSpotLight(atpos.x, atpos.y, atpos.z + 1.0, 0, 0, -1.0, 255, 255, 255, 100.0, 1.0, 0.0, 0.7, 1.0)
        drawFishingText("Press ~b~[E]~s~ to stop fishing.", 0, 150, 255)
        
        if (isGameControlPressed(1, 38)) then -- cancel fishing
          isFishing = false
          fishTimer = {}
          ClearPedSecondaryTask(ped)
          playAnimOnPed(ped, "amb@world_human_stand_fishing@idle_a", "idle_a")
          Wait(2000)
          StopAnimTask(ped, "amb@world_human_stand_fishing@idle_a", "idle_a", 2.0)
          deletePoleAndProps(function()
            SetEnableHandcuffs(ped, false)
            exports.emotes:setCanEmote(true)
            canfish = true
            SetPedDiesInWater(ped, true)
            startRefishTimeout()
          end)
        end
      end
    end

    if (cancatch) then
      local atpos = GetEntityCoords(sinker)

      DrawSpotLight(atpos.x, atpos.y, atpos.z + 1.0, 0, 0, -1.0, 255, 255, 255, 100.0, 1.0, 0.0, 0.7, 1.0)
      drawFishingText("[[[ Press E to try and snag the fish! ]]]", 0, 150, 255)
    end
  end
end)
