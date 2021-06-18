local DrawMarker = DrawMarker

local boatBuySpots = {
  {pos = vec3(-1798.683, -971.830, 2.503), prev = {x = -1838.221, y = -972.243, z = -0.224, heading = 30.465}, camprev = {x = -1822.311, y = -959.264, z = 3.749}, spawn = {x = -1807.021, y = -989.129, z = -0.331, heading = 129.209}}
}
local buyMarkers = {}
local boatDockSpots = {
  {pos = vec3(-734.323, -1338.177, 1.59), prev = {x = -728.572, y = -1352.823, z = 0.474, heading = 139.805}, camprev = {x = -730.077, y = -1342.832, z = 1.59}, spawn = {x = -732.667, y = -1344.807, z = -0.474, heading = 51.0}},
  {pos = vec3(1541.1800, 3913.5541, 31.7007), prev = {x = 1561.082, y = 3876.097, z = 31.7007, heading = 139.805}, camprev = {x = 1566.163, y = 3887.164, z = 36.9}, spawn = {x = 1526.9586, y = 3882.600, z = 31.937, heading = 95.0}},
  {pos = vec3(-1604.515, 5256.755, 2.075), prev = {x = -1607.963, y = 5216.564, z = 0.0, heading = 119.805}, camprev = {x = -1612.304, y = 5228.821, z = 2.071}, spawn = {x = -1598.532, y = 5259.595, z = 0.0, heading = 21.0}},
  {pos = vec3(4907.059, -5171.288, 2.456), prev = {x = 4934.432, y = -5165.815, z = 0.995, heading = 119.805}, camprev = {x = 4925.174, y = -5166.872, z = 3.353}, spawn = {x = 4908.258, y = -5159.042, z = 0.458, heading = 338.0}}
}
local dockMarkers = {}
local boatReturnSpots = {
  {pos = vec3(-1806.495, -1005.225, 0.171)},
  {pos = vec3(-713.521, -1339.243, 0.171)},
  {pos = vec3(1465.4007, 3795.6589, 30.747)},
  {pos = vec3(-1588.768, 5244.169, 0.120)},
  {pos = vec3(4939.883, -5143.506, 0)}
}
local returnMarkers = {}
local boats = {} -- obtained from server
local boatBuyBlips = {}
local boatDockBlips = {}
local boatReturnBlips = {}
local buyCam = -1
local spawnCam = -1
local lastBuySpot = 0
local lastDockSpot = 0
local blockReactivate = false
local showBoatList = false
local boatBuyActive = false
local boatDockActive = false
local previewedVehicle
local curBuyBoat = 1
local curSpawnBoat = 1
local canReturn = true
local clearInterval = 2000
local blockSiren = false
local soundids = {} -- soundid, entity
local togglingAnchor = false

function drawGarageText(text)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.62, 0.62)
  SetTextColour(125, 125, 255, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.5, 0.795)
end

function drawLoading()
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.55, 0.55)
  SetTextColour(255, 75, 75, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName("Loading Vehicle...")
  EndTextCommandDisplayText(0.5, 0.685)
end

function drawText(text)
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

function setupBuyBlips()
  for _,v in pairs(boatBuySpots) do
    local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
  
    SetBlipSprite(blip, 404)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Marine Emporium")
    EndTextCommandSetBlipName(blip)

    table.insert(boatBuyBlips, blip)
  end
end

function setupDockBlips()
  for _,v in pairs(boatDockSpots) do
    local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
  
    SetBlipSprite(blip, 404)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 3)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Boat Docks")
    EndTextCommandSetBlipName(blip)

    table.insert(boatDockBlips, blip)
  end
end

function setupReturnBlips()
  for _,v in pairs(boatReturnSpots) do
    local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
  
    SetBlipSprite(blip, 404)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 1)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Boat Return")
    EndTextCommandSetBlipName(blip)

    table.insert(boatReturnBlips, blip)
  end
end

function setupBuyCamera(enable)
  if (enable) then
    local ped = PlayerPedId()
    
    if (buyCam == -1) then
      buyCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", boatBuySpots[lastBuySpot].camprev.x, boatBuySpots[lastBuySpot].camprev.y, boatBuySpots[lastBuySpot].camprev.z, 0, 0, 0, GetGameplayCamFov(), 0, 0)
    end

    SetCamActive(buyCam, true)
    RenderScriptCams(1, 0, 3000, 1, 0)
  else
    if (buyCam > -1) then
      if (IsCamActive(buyCam)) then
        RenderScriptCams(0, 0, 3000, 1, 0)
        buyCam = -1
      end
    end
  end
end

function setupSpawnCamera(enable)
  if (enable) then
    local ped = PlayerPedId()
    
    if (spawnCam == -1) then
      spawnCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", boatDockSpots[lastDockSpot].camprev.x, boatDockSpots[lastDockSpot].camprev.y, boatDockSpots[lastDockSpot].camprev.z, 0, 0, 0, GetGameplayCamFov(), 0, 0)
    end

    SetCamActive(spawnCam, true)
    RenderScriptCams(1, 0, 3000, 1, 0)
  else
    if (spawnCam > -1) then
      if (IsCamActive(spawnCam)) then
        RenderScriptCams(0, 0, 3000, 1, 0)
        spawnCam = -1
      end
    end
  end
end

function initializeBuySpot()
  local vehmodel

  curBuyBoat = 1
  vehmodel = boats[curBuyBoat].hash
  
  spawnBuyBoatPreview(vehmodel)
end

function initializeSpawnSpot()
  local vehmodel = nil

  curSpawnBoat = 1
  if (boats[curSpawnBoat]) then
    vehmodel = boats[curSpawnBoat].model
  end
  
  spawnDockBoatPreview(vehmodel)
end

function activateBuySpot()
  if (not blockReactivate) then
    blockReactivate = true
    TriggerServerEvent("bms:boats:getBoatsList")
    boatBuyActive = true
  end
end

function activateDockSpot()
  if (not blockReactivate) then
    blockReactivate = true
    TriggerServerEvent("bms:boats:getBoatsForPlayer")
    boatDockActive = true
  end
end

function showCarMarker(pos)
  local remain = 400
  
  Citizen.CreateThread(function()
    while (remain > 0) do
      Wait(1)
      remain = remain - 1
      DrawMarker(1, pos.x, pos.y, pos.z - 1.0001, 0, 0, 0, 0, 0, 0, 3.5, 3.5, 0.3, 120, 255, 70, 50, false, false, 0, 0, 0, 0, 0)      
    end
  end)
end

function spawnBuyBoatPreview(name)
  Citizen.CreateThread(function()
    local hash = GetHashKey(name)

    RequestModel(hash)

    while not HasModelLoaded(hash) do
      Citizen.Wait(0)
      drawLoading()
    end
    
    local veh = CreateVehicle(hash, boatBuySpots[lastBuySpot].prev.x, boatBuySpots[lastBuySpot].prev.y, boatBuySpots[lastBuySpot].prev.z, boatBuySpots[lastBuySpot].prev.heading, false, false)

    while not DoesEntityExist(veh) do
      Citizen.Wait(0)
      drawLoading()
    end

    SetVehicleOnGroundProperly(veh)
    SetEntityInvincible(veh, true)
    FreezeEntityPosition(veh, true)
    SetVehicleDoorsLocked(veh, 4)
    SetVehicleDirtLevel(veh, 0.0)

    previewedVehicle = veh
    
    PointCamAtEntity(buyCam, veh, 0, 0, 0, 0)
    SetModelAsNoLongerNeeded(hash)
    blockpreview = false
    
    SendNUIMessage({
      unblockSwitch = true
    })
  end)
end

function spawnDockBoatPreview(name)
  Citizen.CreateThread(function()
    --print(name)
    if (name) then
      local hash = GetHashKey(name)
      
      RequestModel(hash)

      while not HasModelLoaded(hash) do
        Citizen.Wait(0)
        drawLoading()
      end
      
      local veh = CreateVehicle(hash, boatDockSpots[lastDockSpot].prev.x, boatDockSpots[lastDockSpot].prev.y, boatDockSpots[lastDockSpot].prev.z, boatDockSpots[lastDockSpot].prev.heading, false, false)

      while not DoesEntityExist(veh) do
        Citizen.Wait(0)
        drawLoading()
      end

      SetVehicleOnGroundProperly(veh)
      SetEntityInvincible(veh, true)
      FreezeEntityPosition(veh, true)
      SetVehicleDoorsLocked(veh, 4)
      SetVehicleDirtLevel(veh, 0.0)

      previewedVehicle = veh
      
      PointCamAtEntity(spawnCam, veh, 0, 0, 0, 0)
      SetModelAsNoLongerNeeded(hash)
      blockpreview = false
    end
    
    SendNUIMessage({
      unblockSwitch = true
    })
  end)
end

function spawnBoughtBoat(plate)
  local vehmodel
  
  vehmodel = boats[curBuyBoat].hash
    
  Citizen.CreateThread(function()
    local hash = GetHashKey(vehmodel)

    RequestModel(hash)

    while not HasModelLoaded(hash) do
      Citizen.Wait(0)
    end

    local spawn
      
    spawn = boatBuySpots[lastBuySpot].spawn
    
    local veh = CreateVehicle(hash, spawn.x, spawn.y, spawn.z, spawn.heading, true, false)
    
    while not DoesEntityExist(veh) do
      Wait(1)
    end
    
    SetVehicleOnGroundProperly(veh)
    SetVehicleNumberPlateText(veh, plate)    
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetVehicleDirtLevel(veh, 0.0)
        
    local id = NetworkGetNetworkIdFromEntity(veh)
    
    exports.vehicles:registerPulledVehicle(veh)
    exports.vehicles:registerPulledPlate(plate)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    SetModelAsNoLongerNeeded(hash)
  end)
end

function spawnDockBoat(plate)
  local vehmodel
  
  vehmodel = boats[curSpawnBoat].model
    
  Citizen.CreateThread(function()
    local hash = GetHashKey(vehmodel)

    RequestModel(hash)

    while not HasModelLoaded(hash) do
      Citizen.Wait(0)
    end

    local spawn

    spawn = boatDockSpots[lastDockSpot].spawn
    
    local veh = CreateVehicle(hash, spawn.x, spawn.y, spawn.z, spawn.heading, true, false)
    
    while not DoesEntityExist(veh) do
      Wait(1)
    end
    
    SetVehicleOnGroundProperly(veh)
    SetVehicleNumberPlateText(veh, plate)
    SetEntityAsMissionEntity(veh, true, true)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetVehicleDirtLevel(veh, 0.0)
        
    local id = NetworkGetNetworkIdFromEntity(veh)
    
    exports.vehicles:registerPulledVehicle(veh)
    exports.vehicles:registerPulledPlate(plate)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    SetModelAsNoLongerNeeded(hash)
  end)
end

function getReturnVehicles()
  local pulledPlates = {}
  local retvehs = {}

  exports.vehicles:getPulledVehiclePlates(function(pl)
    pulledPlates = pl
  end)
  
  if (#pulledPlates > 0) then
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local plate = GetVehicleNumberPlateText(veh)

    if (veh and plate) then
      TriggerServerEvent("bms:boats:returnBoats", plate)
      exports.vehicles:unregisterPulledVehicle(veh)
      exports.vehicles:deleteCar(veh)
      exports.pnotify:SendNotification({text = "Your marine vehicle has been returned.  Please leave the return area."})
    else
      exports.pnotify:SendNotification({text = "You must be in the marine vehicle you want to return."})
      canReturn = true
    end
  else
    exports.pnotify:SendNotification({text = "You must be in the marine vehicle you want to return."})
    canReturn = true
  end
end

function timeoutSiren()
  SetTimeout(2000, function()
    blockSiren = false
  end)
end

function soundPlayingOnEntity(vnetid)
  local playing = false
  
  for _,v in pairs(soundids) do
    if (v.entity == vnetid) then
      playing = true
      break
    end
  end

  return playing
end

RegisterNetEvent("bms:boats:setBoatsList")
AddEventHandler("bms:boats:setBoatsList", function(bt)
  if (bt) then
    boats = bt
    
    local itemstr = ""
    
    for _,v in ipairs(boats) do
      itemstr = itemstr .. string.format("<div class='vehoption' data-vehname='%s' data-vehplate=''><font>%s</font><font style='margin-left: auto; margin-right: 15px; color: aquamarine'>$%s</font></div>", v.name, v.name, v.price)
    end
    
    SendNUIMessage({
      addVehItems = true,
      items = itemstr
    })

    SendNUIMessage({
      showVehiclesList = true,
      title = "Marine Emporium",
      showBuy = true
    })
    
    showBoatList = true
    SetNuiFocus(true, true)

    curBuyBoat = 1
    maxBuyVehicles = #boats
    setupBuyCamera(true)
    initializeBuySpot()
  else
    print("bt was nil in setBoatsList")
  end
end)

RegisterNetEvent("bms:boats:buycomplete")
AddEventHandler("bms:boats:buycomplete", function(data)
  if (data) then
    local success = data.success
    local msg = data.msg
    local plate = data.plate

    if (success) then
      spawnBoughtBoat(plate)
      exports.pnotify:SendNotification({text = "You have purchased a boat.  Your boat has been registered with the state."})
    else
      exports.pnotify:SendNotification({text = msg})
    end
  end
end)

RegisterNetEvent("bms:boats:setBoatsForPlayer")
AddEventHandler("bms:boats:setBoatsForPlayer", function(bt)
  if (bt) then
    boats = bt

    local itemstr = ""
    
    for _,v in ipairs(boats) do
      itemstr = itemstr .. string.format("<div class='vehoption' data-vehname='%s' data-vehplate='%s' data-vehprice='%s'><font>%s</font><font style='margin-left: auto; margin-right: 15px; color: aquamarine'>%s</font></div>", v.name, v.plate, v.price, v.name, string.upper(v.plate))
    end

    SendNUIMessage({
      addVehItems = true,
      items = itemstr
    })

    SendNUIMessage({
      showVehiclesList = true,
      title = "Your Boat Dock",
      showSpawn = true
    })

    showBoatList = true
    SetNuiFocus(true, true)
    curSpawnBoat = 1
    --maxSpawnVehicles = #boats
    setupSpawnCamera(true)
    initializeSpawnSpot()
  end
end)

RegisterNetEvent("bms:boats:boatReturnComplete")
AddEventHandler("bms:boats:boatReturnComplete", function()
  canReturn = true
end)

RegisterNetEvent("bms:boats:syncBoatSiren")
AddEventHandler("bms:boats:syncBoatSiren", function(vehid, enable)
  if (vehid) then
    local exists = soundPlayingOnEntity(vehid)

    if (enable) then
      if (not exists) then
        local sid = {}
        local soundid = GetSoundId()
        
        sid = {soundid = soundid, entity = vehid}
        table.insert(soundids, sid)

        PlaySoundFromEntity(soundid, "VEHICLES_HORNS_SIREN_1", NetToVeh(vehid))
      end
    else
      if (exists) then
        local sididx = 0
        local soundid

        for i,v in ipairs(soundids) do
          if (v.entity == vehid) then
            sididx = i
            break
          end
        end

        if (sididx > 0) then
          local sid = soundids[sididx]

          if (sid) then
            StopSound(sid.soundid)
            ReleaseSoundId(sid.soundid)
            table.remove(soundids, sididx)
          end
        end
      end
    end
  end
end)

RegisterNUICallback("buyBoat", function(data, cb)
  local veh = boats[curBuyBoat]

  if (veh) then
    TriggerServerEvent("bms:boats:buyBoat", veh.name, veh.price)
  else
    print("veh was nil in buyBoat NUI callback")
  end
end)

RegisterNUICallback("spawnBoat", function(data, cb)
  local veh = boats[curSpawnBoat]

  if (veh.name) then
    --print(string.format("spawnBoat, boats_cl.lua %s, %s, %s", veh.model, veh.name, veh.plate))
    TriggerServerEvent("bms:boats:boatSpawned", veh.model, veh.name, veh.plate)
    spawnDockBoat(veh.plate)
    setupSpawnCamera(false)
    SetNuiFocus(false, false)
  end
end)

RegisterNUICallback("playsound", function(data, cb)
  if (data) then
    PlaySoundFrontend(-1, data.name, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
  
    if (cb) then
      cb("ok")
    end
  end
end)

RegisterNUICallback("menuClosed", function(data, cb)
  showBoatList = false
  blockReactivate = false
  SetNuiFocus(false, false)
  setupBuyCamera(false)
  setupSpawnCamera(false)
  
  --maxGarageVehicles = 1
  boatBuyActive = false
  
  if (previewedVehicle ~= nil) then
    DeleteVehicle(previewedVehicle)
  end
end)

RegisterNUICallback("setVehiclePreview", function(data, cb)
  if (data) then
    if (data.vehname) then
      for i = 1, #boats do
        if (boats[i].name == data.vehname) then
          if (data.mode == 1) then
            curBuyBoat = i
          elseif (data.mode == 2) then
            curSpawnBoat = i
            print(string.format("curSpawnBoat %s, pl: %s", curSpawnBoat, boats[i].plate))
          end

          break
        end
      end
      
      if (previewedVehicle) then
        DeleteVehicle(previewedVehicle)
      end
      
      if (data.mode == 1) then
        spawnBuyBoatPreview(boats[curBuyBoat].hash)
      elseif (data.mode == 2) then
        spawnDockBoatPreview(boats[curSpawnBoat].model)
      end
    else
      print("data.vehname was nil in setVehiclePreview")
    end
  else
    print("data was nil in setVehiclePreview")
  end
end)

RegisterNUICallback("sellPersonalBoat", function(data, cb)
  if (not blocksell) then
    local veh = boats[curSpawnBoat]
    
    if (veh.model and veh.plate) then
      TriggerServerEvent("bms:boats:sellBoat", veh.plate, veh.model)
    end
  end
end)

RegisterNetEvent("bms:boats:unblocksell")
AddEventHandler("bms:boats:unblocksell", function()
  blocksell = false
end)

RegisterNetEvent("bms:boats:toggleAnchor")
AddEventHandler("bms:boats:toggleAnchor", function()
  if (not togglingAnchor) then
    togglingAnchor = true
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local model = GetEntityModel(veh)
    local speed = GetEntitySpeed(veh)

    if (speed < 10 / 2.236936) then
      local anchorDown = not IsBoatAnchoredAndFrozen(veh)

      if (IsThisModelABoat(model) or IsThisModelAJetski(model)) then
        local anim = {dict = "mp_missheist_ornatebank", anim = "stand_cash_in_bag_loop"}

        TaskLeaveVehicle(ped, veh, 0)
        while (IsPedInAnyVehicle(ped)) do
          Wait(100)
        end
        RequestAnimDict(anim.dict)
            
        while not HasAnimDictLoaded(anim.dict) do
          Wait(10)
        end
        
        TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, -8.0, -1, 1, 1, 0, 0, 0)
        Wait(5000)
        ClearPedTasks(ped)
      elseif (model == GetHashKey("submersible") or model == GetHashKey("submersible2")) then
        FreezeEntityPosition(veh, anchorDown)
        --SetBoatAnchorBuoyancyCoefficient(veh, 0.0)
      end

      SetBoatAnchor(veh, anchorDown)
      SetBoatFrozenWhenAnchored(veh, true)
      togglingAnchor = false

      if (anchorDown) then
        exports.pnotify:SendNotification({text = "Anchor dropped."})
      else
        exports.pnotify:SendNotification({text = "Anchor picked up."})
      end
    else
      togglingAnchor = false
      exports.pnotify:SendNotification({text = "Anchor cannot be dropped when moving."})
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    for _,v in ipairs(buyMarkers) do
      DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.2, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 0.4, 0, 180, 255, 50, 0, 0, 0, 0, 0, 0, 0)

      if (v.dist < 10) then
        local dist = #(pos - v.pos)

        if (dist < 1) then
          if (not showBoatList) then
            drawText("Press ~b~[E]~s~ to access the Marine Emporium.")
          end
          
          if (IsControlJustReleased(1, 38)) then
            lastBuySpot = v.idx
            activateBuySpot()
          end
        end
      end
    end

    for _,v in ipairs(dockMarkers) do
      DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.2, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.4, 120, 255, 70, 50, 0, 0, 0, 0, 0, 0, 0)
      
      if (v.dist < 10) then
        local dist = #(pos - v.pos)

        if (dist < 1) then
          if (not showBoatList) then
            drawText("Press ~b~[E]~s~ to access the docks.")
          end
          
          if (IsControlJustReleased(1, 38)) then
            lastDockSpot = v.idx
            activateDockSpot()
          end
        end
      end
    end

    for _,v in pairs(returnMarkers) do
      DrawMarker(1, v.pos.x, v.pos.y, v.pos.z + 0.4, 0, 0, 0, 0, 0, 0, 10.0, 10.0, 0.15, 240, 70, 70, 50, 0, 0, 0, 1, 0, 0, 0)

      if (v.dist < 25) then
        local dist = #(pos - v.pos)

        if (dist < 9.0) then
          local curveh = GetVehiclePedIsIn(ped)
          local driver = GetPedInVehicleSeat(curveh, -1) == ped
          
          if (driver) then
            local bmodel = GetEntityModel(curveh)
            local isBoat = IsThisModelABoat(bmodel)

            if (isBoat) then
              drawText("Press ~b~[E]~s~ to return your marine vehicle.")

              if (IsControlJustReleased(1, 38)) then
                canReturn = false
                getReturnVehicles()
              end
            end
          end          
        end
      end
    end

    if (IsControlJustReleased(1, 81)) then -- .
      if (IsPedInAnyVehicle(ped, false)) then
        local veh = GetVehiclePedIsIn(ped, false)

        if (veh) then
          local model = GetEntityModel(veh)

          if (model == -488123221) then
            BlockWeaponWheelThisFrame()
          
            local vnetid = VehToNet(veh)
            local toggle = not soundPlayingOnEntity(vnetid)

            blockSiren = true
            timeoutSiren()
            TriggerServerEvent("bms:boats:syncBoatSiren", vnetid, toggle)
          end
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  Wait(5000)

  if (#boatBuyBlips == 0) then
    setupBuyBlips()
  end

  if (#boatReturnBlips == 0) then
    setupReturnBlips()
  end

  if (#boatDockBlips == 0) then
    setupDockBlips()
  end

  while true do
    Wait(1500)

    local pos = GetEntityCoords(PlayerPedId())
    local dMarkers = {}
    local iter = 0

    for i=1,#boatDockSpots do
      local dist = #(pos - boatDockSpots[i].pos)

      if (dist < 65) then
        iter = iter + 1
        dMarkers[iter] = boatDockSpots[i]
        dMarkers[iter].dist = dist
        dMarkers[iter].idx = i

        if (dist < 10) then
          ClearAreaOfVehicles(boatDockSpots[i].pos.x, boatDockSpots[i].pos.y, boatDockSpots[i].pos.z, 10.0, 0, 0, 0, 0, 0)
        end
      end
    end

    dockMarkers = dMarkers
    local bMarkers = {}
    iter = 0

    for i=1,#boatBuySpots do
      local dist = #(pos - boatBuySpots[i].pos)

      if (dist < 65) then
        iter = iter + 1
        bMarkers[iter] = boatBuySpots[i]
        bMarkers[iter].dist = dist
        bMarkers[iter].idx = i
      end
    end

    buyMarkers = bMarkers
    local rMarkers = {}
    iter = 0

    for i=1,#boatReturnSpots do
      local dist = #(pos - boatReturnSpots[i].pos)

      if (dist < 65) then
        iter = iter + 1
        rMarkers[iter] = boatReturnSpots[i]
        rMarkers[iter].dist = dist
      end
    end

    returnMarkers = rMarkers
  end
end)
