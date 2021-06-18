local table_insert = table.insert
local table_remove = table.remove
local json_encode = json.encode
local math_ceil = math.ceil
local mushroomFarms = {}
local shroomSettings = {}
local closestBox = {index = 0, lastIndex = 0}
local nearShroomBoxes = {}
local placingBox = false
local maxBuildAngle = 0.675
local loggedIn = false
local disinfecting = false
local humidifying = false
local harvesting = false
local tempData
local copOnDuty = false
local trip = {active = false}
local badTrip = {active = false, lastTripRndEffect = 0}
local burning = false
local firePfx = {dict = "core", pfx = "fire_wrecked_plane_cockpit", activePfx = {}}
local showingZones = {active = false, blips = {}}
local mushroomGrowRegions = {}

local function getMushroomFarmById(id)
  for _,v in pairs(mushroomFarms) do
    if (v.id == id) then
      return v
    end
  end
end

local function removeMushroomFarmLocal(farmId)
  Citizen.CreateThread(function()
    local delIdx = 0
    
    for i,v in ipairs(mushroomFarms) do
      if (v.id == farmId) then
        delIdx = i
        break
      end
    end

    local farm = mushroomFarms[delIdx]
    local deleteTimeout = GetGameTimer() + 10000

    if (farm and farm.entities) then
      for _, ent in pairs(farm.entities) do
        while (DoesEntityExist(ent) and GetGameTimer() < deleteTimeout) do
          SetEntityAsMissionEntity(ent, true, true)
          DeleteEntity(ent)
          Wait(500)
        end
      end

      table_remove(mushroomFarms, delIdx)
      SendNUIMessage({hideMushroomProgress = true, destroy = true, boxId = farmId})
    end
  end)
end

local function changeMushroomFarmModel(farm, mIndex)
  --print(("changeMushroomFarmModel farm id: %s, mIndex: %s"):format(farm.id, mIndex))
  Citizen.CreateThread(function()
    local hash = GetHashKey(shroomSettings.stageModels[mIndex])
    local ent

    while (not HasModelLoaded(hash)) do
      RequestModel(hash)
      Wait(10)
    end

    if (farm.entities and #farm.entities > 0) then
      for _, ent in pairs(farm.entities) do
        while (DoesEntityExist(ent)) do
          SetEntityAsMissionEntity(ent, true, true)
          DeleteEntity(ent)
          Wait(10)
        end
      end
    end

    farm.entities = {}
    ent = CreateObject(hash, farm.pos)
    
    while (not DoesEntityExist(ent)) do
      Wait(10)
    end

    SetEntityRotation(ent, farm.rot, 2)
    FreezeEntityPosition(ent, true)
    table_insert(farm.entities, ent)
  end)
end

local function removeMushroomFarmModels(farm)
  for _, f in pairs(farm.entities) do
    SetEntityAsMissionEntity(f, true, true)
    DeleteEntity(f)
  end

  farm.entities = {}
  farm.changingModels = false
end

local function drawShroomBoxText(x, y, z, text, sc)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, sc or 0.52 * scale)
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

local function beginDisinfection(ped, farm)
  SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)

  Citizen.CreateThread(function()
    TriggerEvent("bms:emotes:setForcedProp", "disinfect")
    local animSet = shroomSettings.disinfectAnim
    
    while (not HasAnimDictLoaded(animSet.dict)) do
      RequestAnimDict(animSet.dict)
      Wait(5)
    end

    TaskTurnPedToFaceCoord(ped, farm.pos.x, farm.pos.y, farm.pos.z, 1000)
    Wait(1000)
    TaskPlayAnim(ped, animSet.dict, animSet.anim, 2.0, 2.0, -1, 1, 0, 0, 0, 0)
    RemoveAnimDict(animSet.dict)
    Wait(10000)
    StopAnimTask(ped, animSet.dict, animSet.anim, 1.1)
    TriggerEvent("bms:emotes:clearForcedProp")
    TriggerServerEvent("bms:jobs:shrooms:disinfectBox", farm)
    disinfecting = false
  end)
end

local function beginHumidify(ped, farm)
  local mist = {dict = "core", pfx = "ent_amb_snow_mist_base"}
  local timestamp = GetGameTimer()

  SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
  
  Citizen.CreateThread(function()
    TriggerEvent("bms:emotes:setForcedProp", "spraybottle")
    local animSet = shroomSettings.sprayAnim
    
    while (not HasAnimDictLoaded(animSet.dict)) do
      RequestAnimDict(animSet.dict)
      Wait(5)
    end

    TaskTurnPedToFaceCoord(ped, farm.pos.x, farm.pos.y, farm.pos.z, 1000)
    Wait(1000)
    TriggerServerEvent("bms:jobs:shrooms:humidifyPreAnim")
    TaskPlayAnim(ped, animSet.dict, animSet.anim, 2.0, 2.0, -1, 1, 0, 0, 0, 0)
    
    local sprayProp = exports.emotes:getCurrentForcedProp()

    RemoveAnimDict(animSet.dict)
    Wait(6000)
    StopAnimTask(ped, animSet.dict, animSet.anim, 1.1)
    TriggerEvent("bms:emotes:clearForcedProp")
    TriggerServerEvent("bms:jobs:shrooms:humidifyBox", farm)
    humidifying = false
  end)
end

local function playHarvestAnim(ped, farm, cb)
  Citizen.CreateThread(function()
    TaskTurnPedToFaceCoord(ped, farm.pos.x, farm.pos.y, farm.pos.z, 700)
    Wait(600)

    while (not HasAnimDictLoaded(shroomSettings.harvestAnim.dict)) do
      RequestAnimDict(shroomSettings.harvestAnim.dict)
      Wait(5)
    end

    TaskPlayAnim(ped, shroomSettings.harvestAnim.dict, shroomSettings.harvestAnim.anim, 2.0, 2.0, -1, 1, 0, 0, 0, 0)
    Wait(8000)
    StopAnimTask(ped, shroomSettings.harvestAnim.dict, shroomSettings.harvestAnim.anim, 1.0)
    RemoveAnimDict(shroomSettings.harvestAnim.dict)
    
    if (cb) then
      cb()
    end
  end)
end

local function renderPlantStatus(pos, farm, fIndex)
  if (farm.stage == 1) then
    local onScreen, scX, scY = GetScreenCoordFromWorldCoord(farm.pos.x, farm.pos.y, farm.pos.z + 0.1)

    if (onScreen) then
      SendNUIMessage({mushroomProgress = true, setPosition = true, px = scX, py = scY - 0.125, setGrowValue = true, gValue = farm.growPerc, setHumidValue = true, hValue = farm.humidity, boxId = farm.id})
    else
      SendNUIMessage({hideMushroomProgress = true, destroy = false, boxId = farm.id})
    end
  end
  
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local dist = #(pos - farm.pos)

  --print(("stage: %s, modelstage: %s, dist: %s"):format(farm.stage, farm.modelStage, dist))

  if (farm.stage > 1) then
    if (not harvesting) then
      if (dist < shroomSettings.actionDist) then
        drawShroomBoxText(farm.pos.x, farm.pos.y, farm.pos.z + 0.075, "Press [~b~E~w~] to harvest the mushrooms.", 0.35)
        SendNUIMessage({hideMushroomProgress = true, destroy = true, boxId = farm.id})

        if (isGameControlPressed(1, 38)) then
          harvesting = true
          exports.management:TriggerServerCallback("bms:jobs:shrooms:harvestBox", function(rdata)
            if (rdata) then
              if (rdata.success) then
                playHarvestAnim(ped, farm, function()
                  exports.management:TriggerServerCallback("bms:jobs:shrooms:harvestComplete", function(hdata)
                    if (hdata) then
                      if (hdata.msg) then
                        exports.pnotify:SendNotification({text = hdata.msg})
                      end
                    end

                    harvesting = false
                  end, {farmId = rdata.farmId})
                end)
              else
                if (rdata.msg) then
                  exports.pnotify:SendNotification({text = rdata.msg})
                end

                harvesting = false
              end
            else
              harvesting = false
            end
          end, farm)
        end
      else
        drawShroomBoxText(farm.pos.x, farm.pos.y, farm.pos.z + 0.075, "~b~Ready for Harvest.", 0.244)
        SendNUIMessage({hideMushroomProgress = true, destroy = true, boxId = farm.id})
      end
    end
  elseif (farm.modelStage == 2) then
    if (not farm.disinfected) then
      if (not disinfecting and dist < shroomSettings.actionDist) then
        drawShroomBoxText(farm.pos.x, farm.pos.y, farm.pos.z + 0.075, "Press [~b~E~w~] to disinfect the box.", 0.35)

        if (isGameControlPressed(1, 38)) then
          disinfecting = true
          exports.management:TriggerServerCallback("bms:jobs:shrooms:preDisinfect", function(rdata)
            if (not rdata.success) then
              exports.pnotify:SendNotification({text = rdata.msg})
              disinfecting = false
              return
            end

            beginDisinfection(ped, farm)
          end)
        end
      end
    end
  end
end

local function gasCanArmed()
  local wep_fuelcan = 0x34A67B97
  local ped = PlayerPedId()
  local _,weapon = GetCurrentPedWeapon(ped, true)

  if (weapon == wep_fuelcan) then
    return true
  end
end

function setBadTripEffectTimeout()
  startBadTripChecks()
  SetTimeout(shroomSettings.badTrip.timeMins * 60000, function()
    badTrip.active = false
    ClearTimecycleModifier()
    exports.pnotify:SendNotification({text = "You feel a bit better now."})
  end)
end

function setTripTimeout()
  SetTimeout(shroomSettings.trip.timeMins * 60000, function()
    trip.active = false
    ClearTimecycleModifier()
  end)
end

function playConsumeAnim(cb)
  local ped = PlayerPedId()

  exports.emotes:setCanEmote(false)
  Citizen.CreateThread(function()
    -- do animation / prop load
    while (not HasAnimDictLoaded(shroomSettings.breakdownAnim.dict)) do
      RequestAnimDict(shroomSettings.breakdownAnim.dict)
      Wait(5)
    end

    while (not HasAnimDictLoaded(shroomSettings.consumeAnim.dict)) do
      RequestAnimDict(shroomSettings.consumeAnim.dict)
      Wait(5)
    end

    TaskPlayAnim(ped, shroomSettings.breakdownAnim.dict, shroomSettings.breakdownAnim.anim, 2.0, 2.0, -1, 1)
    TriggerEvent("bms:emotes:setForcedProp", "mushroombag", true)
    Wait(6000)
    TaskPlayAnim(ped, shroomSettings.consumeAnim.dict, shroomSettings.consumeAnim.anim, 2.0, 2.0, -1, 2)
    Wait(1600)
    StopAnimTask(ped, shroomSettings.consumeAnim.dict, shroomSettings.consumeAnim.anim, 1.0)
    TriggerEvent("bms:emotes:clearForcedProp")

    if (msg) then
      exports.pnotify:SendNotification({text = msg})
    end

    exports.emotes:setCanEmote(true)
    if (cb) then
      cb()
    end
  end)
end

local function startBurnAnimation(cb)
  local ped = PlayerPedId()

  Citizen.CreateThread(function()
    while (not HasAnimDictLoaded(shroomSettings.burnAnim.dict)) do
      RequestAnimDict(shroomSettings.burnAnim.dict)
      Wait(10)
    end

    TaskPlayAnim(ped, shroomSettings.burnAnim.dict, shroomSettings.burnAnim.anims[1], 8.0, -8, -1, 50, 0, 0, 0, 0)
    Wait(1000)
    TaskPlayAnim(ped, shroomSettings.burnAnim.dict, shroomSettings.burnAnim.anims[2], 8.0, -8, -1, 49, 0, 0, 0, 0)
    Wait(5000)
    TaskPlayAnim(ped, shroomSettings.burnAnim.dict, shroomSettings.burnAnim.anims[3], 8.0, -8, -1, 50, 0, 0, 0, 0)
    Wait(1000)
    ClearPedTasks(ped)
    RemoveAnimDict(shroomSettings.burnAnim.dict)

    if (cb) then
      cb()
    end
  end)
end

local function doMushroomFarmBurn(farmId)
  local farm = getMushroomFarmById(farmId)
  
  Citizen.CreateThread(function()
    while (not HasNamedPtfxAssetLoaded(firePfx.dict)) do
      RequestNamedPtfxAsset(firePfx.dict)
      Wait(10)
    end
    
    UseParticleFxAssetNextCall(firePfx.dict)
    local pfx = StartParticleFxLoopedAtCoord(firePfx.pfx, farm.pos.x, farm.pos.y, farm.pos.z, 0, 0, 0, 2.25)
    firePfx.activePfx[pfx] = true
    
    RemoveNamedPtfxAsset(firePfx.dict)
    SetTimeout(35000, function()
      if (firePfx.activePfx[pfx]) then
        StopParticleFxLooped(pfx)
        firePfx.activePfx[pfx] = nil
      end      
    end)
  end)
end

local function renderLeoBurnText(pos, farm, delayburn)
  local dist = #(pos - farm.pos)

  if (dist < shroomSettings.burnDist) then
    if (gasCanArmed() and not farm.burning) then
      drawShroomBoxText(farm.pos.x, farm.pos.y, farm.pos.z + 0.25, "Press [~b~H~w~] to burn this mushroom box.")

      if (not delayburn) then
        if (not burning and isGameControlPressed(1, 74)) then
          burning = true
          startBurnAnimation(function()
            exports.management:TriggerServerCallback("bms:jobs:mushroomFarms:requestFarmBurn", function(rdata)
              if (rdata and rdata.msg) then
                exports.pnotify:SendNotification({text = rdata.msg})
              end
              
              burning = false
            end)
          end)
        end
      end
    end
  end
end

RegisterNetEvent("bms:jobs:shrooms:init")
AddEventHandler("bms:jobs:shrooms:init", function(data)
  if (not data) then return end

  shroomSettings = data.shroomSettings or {}
  mushroomGrowRegions = data.mushroomGrowRegions or {}
  doModelsCull()
end)

RegisterNetEvent("bms:jobs:shrooms:showGrowZones")
AddEventHandler("bms:jobs:shrooms:showGrowZones", function()  
  if (not showingZones.active) then
    showingZones.active = true
    
    for _,v in pairs(mushroomGrowRegions) do
      local bl = AddBlipForRadius(v.pos.x, v.pos.y, v.pos.z, v.radius)

      SetBlipSprite(bl,9)
      SetBlipColour(bl, 6)
      SetBlipAlpha(bl, 150)
      table_insert(showingZones.blips, bl)
    end
  else
    showingZones.active = false

    for _,v in pairs(showingZones.blips) do
      RemoveBlip(v)
    end

    showingZones.blips = {}
  end
end)

RegisterNetEvent("bms:jobs:shrooms:doShroomBoxBuild")
AddEventHandler("bms:jobs:shrooms:doShroomBoxBuild", function(data)
  if (placingBox or not shroomSettings or not shroomSettings.stageModels or not data) then return end

  if (data.fail) then
    if (data.msg) then
      exports.pnotify:SendNotification({text = data.msg})
    end
  else
    tempData = data
    placingBox = true
    exports.management:createBuildPreviewGrid(shroomSettings.stageModels[1], "Mushroom Box", 1, 1, 0, 0, "bms:jobs:shrooms:boxPlaced", "bms:jobs:shrooms:placeExit", mushroomGrowRegions, 1, true, maxBuildAngle)
  end
end)

RegisterNetEvent("bms:jobs:shrooms:shroomFarmsAll")
AddEventHandler("bms:jobs:shrooms:shroomFarmsAll", function(farms)
  loggedIn = true
  mushroomFarms = farms
end)

RegisterNetEvent("bms:jobs:shrooms:createOneShroomFarm")
AddEventHandler("bms:jobs:shrooms:createOneShroomFarm", function(data)
  --print(json_encode(data, {indent = true}))
  local farm = data.shroomFarm

  if (not farm) then return end

  local nFarm = {id = farm.id, pos = farm.pos, rot = farm.rot, ownerId = farm.ownerId, stage = farm.stage, entities = {}, growPerc = 0, humidity = 85.0, temperature = 74.0, modelStage = farm.modelStage}

  table_insert(mushroomFarms, nFarm)
end)

RegisterNetEvent("bms:jobs:shrooms:removeOneShroomFarm")
AddEventHandler("bms:jobs:shrooms:removeOneShroomFarm", function(farmId)
  --print(("bms:jobs:shrooms:removeOneShroomFarm [%s]"):format(farmId))
  if (not farmId) then return end

  removeMushroomFarmLocal(farmId)
end)

RegisterNetEvent("bms:jobs:shrooms:setReadyToHarvest")
AddEventHandler("bms:jobs:shrooms:setReadyToHarvest", function(data)
  Citizen.CreateThread(function()
    if (not data.farms) then return end

    for _, farm in pairs(mushroomFarms) do
      for _, f in pairs(data.farms) do
        if (f.id == farm.id) then
          farm.stage = 2
          Wait(500)
        end
      end
    end
  end)
end)

RegisterNetEvent("bms:jobs:mushroomFarms:burnFarm")
AddEventHandler("bms:jobs:mushroomFarms:burnFarm", function(farmId)
  local farm = getMushroomFarmById(farmId)

  if (not farm) then return end

  local pos = GetEntityCoords(PlayerPedId())
  local dist = #(pos - farm.pos)

  if (dist < 80) then
    doMushroomFarmBurn(farmId)
  end
end)

RegisterNetEvent("bms:jobs:shrooms:updateStats")
AddEventHandler("bms:jobs:shrooms:updateStats", function(data)
  if (not loggedIn or not data) then return end

  local farms = data.mushroomFarms

  for _, f in pairs(farms) do
    local farm = getMushroomFarmById(f.id)

    if (f and farm and f.growPerc) then
      local growPerc = math_ceil(f.growPerc)
      local humid = f.humidity

      farm.growPerc = growPerc
      farm.humidity = humid
    end
  end
end)

RegisterNetEvent("bms:jobs:shrooms:updateFarmStage")
AddEventHandler("bms:jobs:shrooms:updateFarmStage", function(farm)
  --print("bms:jobs:shrooms:updateFarmStage")
  --print(json_encode(farm, {indent = true}))
  if (not loggedIn or not farm) then return end

  for _, f in pairs(mushroomFarms) do
    if (f.id == farm.id) then
      f.modelStage = farm.modelStage
      changeMushroomFarmModel(f, farm.modelStage)
      break
    end
  end
end)

RegisterNetEvent("bms:jobs:shrooms:updateFarmDisinfected")
AddEventHandler("bms:jobs:shrooms:updateFarmDisinfected", function(id)
  for _, localFarm in pairs(mushroomFarms) do
    if (localFarm.id == id) then
      localFarm.disinfected = true
      break
    end
  end
end)

RegisterNetEvent("bms:jobs:shrooms:updateFarmHumidity")
AddEventHandler("bms:jobs:shrooms:updateFarmHumidity", function(farm)
  for _, localFarm in pairs(mushroomFarms) do
    if (localFarm.id == farm.id) then
      localFarm.humidity = farm.humidity
      break
    end
  end
end)

RegisterNetEvent("bms:jobs:shrooms:doHumidifyBox")
AddEventHandler("bms:jobs:shrooms:doHumidifyBox", function(farmId)
  local ped = PlayerPedId()
  local farm = getMushroomFarmById(farmId)

  if (farm) then
    beginHumidify(ped, farm)
  else
    print(("Farm not found by ID. [%s]"):format(farmId))
  end
end)

RegisterNetEvent("bms:jobs:shrooms:readyToHarvest")
AddEventHandler("bms:jobs:shrooms:readyToHarvest", function(data)
  if (not data) then return end

  Citizen.CreateThread(function()
    for _, farm in pairs(mushroomFarms) do
      for _, f in pairs(data.mushroomFarms) do
        if (farm.id == f.id) then
          farm.stage = 2
          Wait(500)
        end
      end
    end
  end)
end)

RegisterNetEvent("bms:jobs:shrooms:doPostBaggieAction")
AddEventHandler("bms:jobs:shrooms:doPostBaggieAction", function(data)
  local msg = data.msg
  local ped = PlayerPedId()

  exports.emotes:setCanEmote(false)
  Citizen.CreateThread(function()
    -- do animation / prop load
    while (not HasAnimDictLoaded(shroomSettings.breakdownAnim.dict)) do
      RequestAnimDict(shroomSettings.breakdownAnim.dict)
      Wait(5)
    end

    TaskPlayAnim(ped, shroomSettings.breakdownAnim.dict, shroomSettings.breakdownAnim.anim, 2.0, 2.0, -1, 1, 0, 0, 0, 0)
    TriggerEvent("bms:emotes:setForcedProp", "mushroombag", true)
    Wait(8000)
    StopAnimTask(ped, shroomSettings.breakdownAnim.dict, shroomSettings.breakdownAnim.anim, 1.0)
    Wait(600)
    TriggerEvent("bms:emotes:clearForcedProp")

    if (msg) then
      exports.pnotify:SendNotification({text = msg})
    end

    exports.emotes:setCanEmote(true)
  end)
end)

RegisterNetEvent("bms:jobs:shrooms:shroomConsume")
AddEventHandler("bms:jobs:shrooms:shroomConsume", function(data)
  badTrip.active = data.badTrip
  
  playConsumeAnim(function()
    if (badTrip.active) then
      exports.pnotify:SendNotification({text = "You do not feel so good.."})
      SetTimecycleModifier(shroomSettings.badTrip.timeCycle)
      setBadTripEffectTimeout()
    else
      trip.active = true
      SetTimecycleModifier(shroomSettings.trip.timeCycle)
      setTripTimeout()
    end
  end)
end)

RegisterNetEvent("bms:jobs:shrooms:tripEnd")
AddEventHandler("bms:jobs:shrooms:tripEnd", function()
  if (badTrip.active) then
    badTrip.active = false
    ClearTimecycleModifier()
  elseif (trip.active) then
    trip.active = false
    ClearTimecycleModifier()
  end
end)

AddEventHandler("bms:jobs:shrooms:placeExit", function()
  placingBox = false
  exports.inventory:blockInventoryUse(false)
end)

AddEventHandler("onResourceStop", function(res)
  if (res == GetCurrentResourceName()) then
    for _, fdata in pairs(mushroomFarms) do
      if (fdata and fdata.entities) then
        for _, ent in pairs(fdata.entities) do
          SetEntityAsMissionEntity(ent, true, true)
          DeleteObject(ent)
        end
      end
    end
  end
end)

AddEventHandler("bms:jobs:shrooms:boxPlaced", function(trans)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  
  exports.management:endBuildPreview()

  if (not trans) then return end

  local vpos = vec3(trans[1].x, trans[1].y, trans[1].z)
  local vrot = vec3(trans[1].rx, trans[1].ry, trans[1].rz)
  
  for _, box in pairs(mushroomFarms) do
    if (#(vpos - box.pos) < shroomSettings.maxRangeToOtherField) then
      exports.pnotify:SendNotification({text = "You are too close to another box, find a spot further away."})
      placingBox = false
      return
    end
  end

  exports.inventory:blockInventoryUse(true)
  exports.management:TriggerServerCallback("bms:jobs:shrooms:doShroomBoxBuild", function(rdata)    
    if (rdata) then
      if (rdata.pos) then
        Citizen.CreateThread(function()
          tempData = {}
          local ped = PlayerPedId()

          SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
          Wait(150)
          TriggerEvent("bms:emotes:setForcedProp", "syringe")
          exports.emotes:setCanEmote(false)

          -- play anim
          while (not HasAnimDictLoaded(shroomSettings.syringeAnim.dict)) do
            RequestAnimDict(shroomSettings.syringeAnim.dict)
            Wait(5)
          end

          TaskTurnPedToFaceCoord(ped, rdata.pos, 700)
          Wait(600)
          TaskPlayAnim(ped, shroomSettings.syringeAnim.dict, shroomSettings.syringeAnim.anim, 2.0, 2.0, -1, 1)
          Wait(10000)
          StopAnimTask(ped, shroomSettings.syringeAnim.dict, shroomSettings.syringeAnim.anim, 1.0)
          Wait(500)
          RemoveAnimDict(shroomSettings.syringeAnim.dict)
          TriggerEvent("bms:emotes:clearForcedProp")
          placingBox = false
          exports.emotes:setCanEmote(true)
        end)
      elseif (rdata.success == false) then
        if (rdata.msg ~= "") then
          exports.pnotify:SendNotification({text = rdata.msg})
        end

        tempData = {}
        placingBox = false
        exports.emotes:setCanEmote(true)
      end

      exports.inventory:blockInventoryUse(false)
    end
  end, {pos = vpos, rot = vrot, tempData = tempData})
end)

AddEventHandler("bms:lawenf:activedutyswitch", function(tog)
  copOnDuty = tog
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    for _, nfarm in pairs(nearShroomBoxes) do
      if (nfarm.dist < 5) then
        local dist = #(pos - nfarm.pos)

        if (dist < shroomSettings.dispHudDist) then
          closestBox.index = nfarm.idx
          closestBox.lastIndex = nfarm.idx

          if (not copOnDuty) then
            if (gasCanArmed()) then
              renderLeoBurnText(pos, nfarm, true)

              if (not burning and isGameControlPressed(1, 74)) then
                burning = true
                startBurnAnimation(function()
                  exports.management:TriggerServerCallback("bms:jobs:mushroomFarms:requestFarmBurn", function(rdata)
                    if (rdata and rdata.msg) then
                      exports.pnotify:SendNotification({text = rdata.msg})
                    end

                    burning = false
                  end)
                end)
              end
            else
              renderPlantStatus(pos, nfarm, nfarm.idx)
            end
          else
            renderLeoBurnText(pos, nfarm)
          end
        end
      end
    end

    if (closestBox.index > 0) then
      local box = mushroomFarms[closestBox.index]

      if (box) then
        local dist = #(pos - box.pos)

        if (dist > shroomSettings.dispHudDist) then
          SendNUIMessage({hideMushroomProgress = true, destroy = false, boxId = box.id})
          closestBox.index = 0
        end
      else
        SendNUIMessage({hideMushroomProgress = true, destroy = false, boxId = -1})
        closestBox.index = 0
      end
    elseif (closestBox.index == 0 and closestBox.lastIndex > 0) then
      SendNUIMessage({hideMushroomProgress = true, destroy = false, boxId = -1})
      closestBox.lastIndex = 0
    end
  end
end)

--[[ Culling Thread ]]
function doModelsCull()
  Citizen.CreateThread(function()
    while true do
      Wait(1500)

      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local nearBox = {}
      local iter = 0
      local nearFarm = false

      for fIndex, farm in ipairs(mushroomFarms) do
        if (farm) then
          local dist

          if (pos.z > 0) then
            dist = #(pos.xy - farm.pos.xy)
          else
            dist = #(pos - farm.pos)
          end

          if (dist < shroomSettings.modelCullDist) then
            if ((not farm.entities or #farm.entities == 0) and not farm.changingModels) then
              farm.changingModels = true
              changeMushroomFarmModel(farm, farm.modelStage)
            end

            nearFarm = true

            if (dist < 15) then
              iter = iter + 1
              nearBox[iter] = farm
              nearBox[iter].dist = dist
              nearBox[iter].idx = fIndex
            end
          elseif (dist > shroomSettings.modelCullDist and (farm.entities and #farm.entities > 0) and not farm.changingModels) then
            removeMushroomFarmModels(farm)
          end
        end
      end

      nearShroomBoxes = nearBox
      local nearCount = #nearShroomBoxes

      if (nearCount > 0) then
        nearFarm = true
        exports.emotes:objectScannerToggle(false)
        extCollectorsActive = false
      elseif (nearCount == 0 and not extCollectorsActive) then
        exports.emotes:objectScannerToggle(true)
        extCollectorsActive = true
        nearFarm = false
      end
    end
  end)
end

function startBadTripChecks()
  --[[ Bad trip checks]]
  Citizen.CreateThread(function()
    while badTrip.active do
      Wait(shroomSettings.badTrip.tripRandomsCheckTimeSec * 1000)

      local rnd = math.random()

      if (rnd < shroomSettings.badTrip.tripRandomsChance) then
        -- do random badTrip anim
        local anims = shroomSettings.badTrip.randomEventAnims
        local rndAnim = anims[math.random(1, #anims)]
        local ped = PlayerPedId()

        while (not HasAnimDictLoaded(rndAnim.dict)) do
          RequestAnimDict(rndAnim.dict)
          Wait(10)
        end

        TaskPlayAnim(ped, rndAnim.dict, rndAnim.anim, 2.0, 2.0, -1, 48)
        RemoveAnimDict(rndAnim.dict)
      end
    end
  end)
end