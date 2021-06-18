local holdingsaw = false
local usingsaw = false
local sawmodel = "prop_tool_consaw"
local anim = {dict = "weapons@heavy@minigun", name = "idle_2_aim_right_med"}
local particles = {dict = "des_fib_floor", name = "ent_ray_fbi5a_ramp_metal_imp"}
local actiontime = 10
local saw_net = nil
local partstarted = false
local partentid = nil
local doors = {
  {bone = "door_pside_f", label = "Front Right Door", index = 1},
  {bone = "door_dside_f", label = "Front Left Door", index = 0},
  {bone = "door_pside_r", label = "Back Right Door", index = 3},
  {bone = "door_dside_r", label = "Back Left Door", index = 2}
}
local trucks = {
  {model = 1239535925, sawmount = {x = -1.25, y = -2.2, z = 0.0}},
  {model = 1073934368, sawmount = {x = -1.25, y = -2.2, z = 0.0}},
  {model = 1475479180, sawmount = {x = -1.25, y = -2.2, z = 0.0}},
  {model = 1882065380, sawmount = {x = -1.25, y = -2.2, z = 0.0}}
}
local lastveh
local debugbones = false
local startedFires = {}
local fireRegions = {}
local hoseActive = false
local hoseNozzleEnt
local hoseRopeId = 0
local waterPfx = {}
local waterActive = false
local waterReactivateTime = 5000
local blockWaterActivate = false
local lastveh = 0
local truckOffsets = {
  ["firetruk"] = {hoseOffset = vec3(0.5, 0.225, 0.1), activateOffset = vec3(1.0, 0.225, -1.0)}
}
local truckHosePinOffsets = {}
--[[ debugs ]]
local debug = {active = true, pfx = 0, ent = 0, offset = vec3(0, 0.15, 0), rot = vec3(0, 0, 0)}

function drawDebugText(text)
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
  EndTextCommandDisplayText(0.475, 0.92)
end

function getVehicleInFront()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.2, 0.0)
  local rayhandle = StartShapeTestCapsule(pos.x, pos.y, pos.z, offset.x, offset.y, offset.z, 0.3, 2, ped, 7) -- 2 mission entites, 10 = vehicles
  local _, _, _, _, veh = GetShapeTestResult(rayhandle)

  return veh
end

function setSawTimer(veh, index)
  Citizen.CreateThread(function()
    -- display wait notify
    local time = actiontime

    TriggerServerEvent("bms:fire:sawstartparticles", saw_net)
    usingsaw = true

    while (time > 0) do
      if (not holdingsaw or getVehicleInFront() ~= veh) then
        usingsaw = false
        TriggerServerEvent("bms:fire:sawstopparticles", saw_net)
        exports.pnotify:SendNotification({text = "Saw action cancelled."})
        SendNUIMessage({hidesawprogress = true})
        return
      end

      Wait(1000)
      time = time - 1
      SendNUIMessage({sawprogress = true, value = time, sawmaxtime = actiontime})
    end

    SetVehicleDoorBroken(veh, doors[index].index, false)
    SetVehicleDoorsLocked(veh, false)
    TriggerServerEvent("bms:fire:sawstopparticles", saw_net)
    exports.pnotify:SendNotification({text = "The vehicle door has been cut off successfully."})
    usingsaw = false
    SendNUIMessage({hidesawprogress = true})
  end)
end

function Draw3DText(x, y, z, text)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, 0.55 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    -- SetTextScale(0.0, 0.55)
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

function getLastFiretruck(vehmodel)
  for _,v in pairs(trucks) do
    if (v.model == vehmodel) then
      return v
    end
  end
end

function clearFireRegions()
  for k,_ in pairs(fireRegions) do
    if (DoesBlipExist(k)) then
      RemoveBlip(k)
    end
  end
end

function addNewFireRegion(spot)
  local rblip = AddBlipForRadius(spot.position.x, spot.position.y, spot.position.z, 85.0)
  local blip = AddBlipForCoord(spot.position.x, spot.position.y, spot.position.z)

  SetBlipColour(rblip, 44)
  SetBlipAlpha(rblip, 120)
  SetBlipSprite(blip, 436)
  SetBlipColour(blip, 47)
  SetBlipAsShortRange(blip, true)
  SetBlipScale(blip, 0.9)
  fireRegions[rblip] = rblip
  fireRegions[blip] = blip
end

function startHoseActivateTimeout()
  SetTimeout(waterReactivateTime, function()
    blockWaterActivate = false
  end)
end

function drawDebugLines()
  local epos = GetEntityCoords(debug.ent)
  local pos = vec3(epos.x - debug.offset.x, epos.y - debug.offset.y, epos.z - debug.offset.z)
  
  DrawLine(pos.x - 0.2, pos.y, pos.z, pos.x + 0.2, pos.y, pos.z, 255, 0, 0, 255)
  DrawLine(pos.x, pos.y - 0.2, pos.z, pos.x, pos.y + 0.2, pos.z, 0, 255, 0, 255)
  DrawLine(pos.x, pos.y, pos.z - 0.2, pos.x, pos.y, pos.z + 0.2, 255, 0, 0, 255)
end

function getTruckData(model)
  for k,v in pairs(truckOffsets) do
    local tmod = GetHashKey(k)

    if (tmod == model) then
      return v
    end
  end
end

AddEventHandler("onClientResourceStop", function(res)
  if (res == GetCurrentResourceName()) then
    clearFireRegions()

    if (hoseRopeId and hoseRopeId ~= 0) then
      DeleteRope(hoseRopeId)
    end
  end
end)

RegisterNetEvent("bms:fire:togglesaw")
AddEventHandler("bms:fire:togglesaw", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  
  if (not holdingsaw) then
    local hash = GetHashKey(sawmodel)
    
    RequestModel(hash)

    while (not HasModelLoaded(hash)) do
      Wait(100)
    end

    RequestAnimDict(anim.dict)

    while (not HasAnimDictLoaded(anim.dict)) do
      Wait(100)
    end

    local bidx = GetPedBoneIndex(ped, 28422)
    local saw = CreateObject(hash, pos.x, pos.y, pos.z, 1, 1, 1)

    Wait(100)

    local netid = ObjToNet(saw)

    SetNetworkIdExistsOnAllMachines(netid, true)
    NetworkSetNetworkIdDynamic(netid, true)
    AttachEntityToEntity(saw, ped, bidx, 0.095, 0.0, 0.0, 270.0, 170.0, 0.0, 1, 1, 0, 1, 0, 1)
    TaskPlayAnim(ped, 1.0, -1, -1, 50, 0, 0, 0, 0)
    TaskPlayAnim(ped, anim.dict, anim.name, 1.0, -1, -1, 50, 0, 0, 0, 0)
    SetModelAsNoLongerNeeded(hash)
    RemoveAnimDict(anim.dict)
    saw_net = netid
    holdingsaw = true
  else
    ClearPedSecondaryTask(ped)
    DetachEntity(NetToObj(saw_net), 1, 1)
    DetachEntity(NetToObj(saw_net))
    DeleteObject(NetToObj(saw_net))
    saw_net = nil
    holdingsaw = false
    usingsaw = false
  end
end)

RegisterNetEvent("bms:fire:sawstartparticles")
AddEventHandler("bms:fire:sawstartparticles", function(sawid)
  local ent = NetToObj(sawid)

  RequestNamedPtfxAsset(particles.dict)

  while (not HasNamedPtfxAssetLoaded(particles.dict)) do
    Wait(100)
  end

  UseParticleFxAssetNextCall(particles.dict)
  StartParticleFxNonLoopedOnEntity(particles.name, ent, -0.715, 0.005, 0.0, 0.0, 25.0, 25.0, 0.75, 0.0, 0.0, 0.0)
end)

RegisterNetEvent("bms:fire:sawstopparticles")
AddEventHandler("bms:fire:sawstopparticles", function(sawid)
  local ent = NetToObj(sawid)

  RemoveParticleFxFromEntity(ent)
end)

Citizen.CreateThread(function()
  while true do
    if (usingsaw) then
      TriggerServerEvent("bms:fire:sawstartparticles", saw_net)
    end

    Wait(100)
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if (isonduty) then
      local lastveh = GetVehiclePedIsIn(ped, true)
      local vehmodel

      if (lastveh ~= 0) then
        vehmodel = GetEntityModel(lastveh)
      end

      if (holdingsaw) then
        local veh = getVehicleInFront()

        if (debugbones) then
          drawClientText(string.format("Vehicle Detect: %s", veh))
        end
        
        if (veh ~= 0) then
          local bonedist = {}

          for a = 1, #doors do
            local doorpos = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, doors[a].bone)) -- /crun GetWorldPositionOfEntityBone(GetVehiclePedIsIn(PlayerPedId()),0)
            
            if (debugbones) then
              DrawMarker(1, doorpos.x, doorpos.y, doorpos.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.15, 0, 180, 255, 50, 0, 0, 0, 0, 0, 0, 1)
            end
            
            local dist = Vdist(pos.x, pos.y, pos.z, doorpos.x, doorpos.y, doorpos.z)

            if (dist < 1.7) then
              --print(string.format("Inserting bone %s, dist %s", doors[a].index, dist))
              table.insert(bonedist, {index = a, dist = dist})
            end
          end

          local low = nil
          local lowdistidx = nil

          if (#bonedist > 0) then
            for b,v in ipairs(bonedist) do
              if (not low) then
                low = v.index
                lowdistidx = b
              else
                if (v.dist < bonedist[lowdistidx].dist) then
                  low = v.index
                end
              end
            end

            if (not IsVehicleDoorDamaged(veh, doors[low].index)) then
              local dcoord = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, doors[low].bone))

              Draw3DText(dcoord.x, dcoord.y, dcoord.z, string.format("Press ~b~E~w~ to cut open the %s", doors[low].label))

              if (IsControlJustPressed(1, 38) and not usingsaw) then
                setSawTimer(veh, low)
              end
            end
          end
        end
      end
      
      if (lastveh ~= 0) then
        if (not IsPedInAnyVehicle(ped)) then
          local lasttruck = getLastFiretruck(vehmodel)
          
          if (lasttruck) then
            local mpos = GetOffsetFromEntityInWorldCoords(lastveh, lasttruck.sawmount.x, lasttruck.sawmount.y, lasttruck.sawmount.z)
            local dist = Vdist(pos.x, pos.y, pos.z, mpos.x, mpos.y, mpos.z)

            DrawMarker(1, mpos.x, mpos.y, mpos.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 0.15, 255, 180, 50, 50, 0, 0, 0, 0, 0, 0, 0)

            if (dist < 1.1) then
              if (holdingsaw) then
                drawClientText("Press ~b~E~w~ to return the jaws of life.")
              else
                drawClientText("Press ~b~E~w~ to deploy the jaws of life.")
              end

              if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
                TriggerEvent("bms:fire:togglesaw")
              end
            end
          end
        end
      end
    end
  end
end)

RegisterNetEvent("bms:firedept:startRandomFire")
AddEventHandler("bms:firedept:startRandomFire", function(spot, startAtPedPos)
  if (spot) then
    local pos = spot.position

    if (startAtPedPos) then
      local ped = PlayerPedId()
      local ppos = GetEntityCoords(ped)

      pos.x = ppos.x
      pos.y = ppos.y
      pos.z = ppos.z - 0.8
    end

    if (not HasNamedPtfxAssetLoaded("core")) then
      RequestNamedPtfxAsset("core")

      while (not HasNamedPtfxAssetLoaded("core")) do
        Wait(1)
      end
    end

    SetPtfxAssetNextCall("core")

    local newfire = {}
    
    newfire.pfx = StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_l_fire", pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    --StartParticleFxLoopedAtCoord(effectName, x, y, z, xRot, yRot, zRot, scale, xAxis, yAxis, zAxis, p11)
    newfire.fire = StartScriptFire(pos.x, pos.y, pos.z, 25, false)
    startedFires[newfire.fire] = newfire.pfx

    print(string.format("started fire at %s, %s, %s", pos.x, pos.y, pos.z))
  else
    print("Position was missing.")
  end
end)

RegisterNetEvent("bms:firedept:addFireRegion")
AddEventHandler("bms:firedept:addFireRegion", function(spot)
  if (spot) then
    exports.pnotify:SendNotification({text = string.format("A fire has been reported in the vicinity of <span style='color: orange'>%s</span>", spot.address)})
  end

  clearFireRegions()
  addNewFireRegion(spot)
end)

RegisterNetEvent("bms:firedept:hoseTest")
AddEventHandler("bms:firedept:hoseTest", function()
  Citizen.CreateThread(function()
    if (hoseRopeId and hoseRopeId ~= 0) then
      DeleteRope(hoseRopeId)
      hoseRopeId = 0
      RopeUnloadTextures()
      TriggerEvent("bms:emotes:clearForcedProp")
      hoseNozzleEnt = nil
      hoseActive = false
      lastveh = nil
      return
    end
    
    if (isonduty) then
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local veh = GetVehiclePedIsIn(ped, true)
      local vpos = GetEntityCoords(veh)
      
      -- todo detect emergency vehicle

      if (veh and veh ~= 0) then
        while (not RopeAreTexturesLoaded()) do
          RopeLoadTextures()
          Wait(10)
        end

        lastveh = veh
        hoseRopeId = AddRope(pos.x, pos.y, pos.z, 0.0, 0.0, 0.0, 20.0, 3, 10.0, 10.0, 0.0, false, false, false, 5.0, true, 0)
        --N_0x36ccb9be67b970fd(hoseRopeId, true)
        --LoadRopeData(hoseRopeId, "ropeFamily3")
        --RopeSetUpdateOrder(hoseRopeId, 2)
        RopeDrawShadowEnabled(true)
        ActivatePhysics(hoseRopeId)
        TriggerEvent("bms:emotes:setForcedProp", "hosenozzle")
        hoseNozzleEnt = exports.emotes:getCurrentForcedProp()
        hoseActive = true
        print(string.format("Rope created [%s]", hoseRopeId))
      else
        exports.pnotify:SendNotification({text = "Enter and EXIT a fire truck first."})
      end
    end
  end)
end)

RegisterNetEvent("bms:firedept:startSyncdWaterPfx")
AddEventHandler("bms:firedept:startSyncdWaterPfx", function(netid)
  if (not netid) then
    return
  end

  local netex = NetworkDoesEntityExistWithNetworkId(netid)

  if (netex) then
    waterPfx[netid] = {localEnt = NetworkGetEntityFromNetworkId(netid), active = false}
  end
end)

RegisterNetEvent("bms:firedept:stopSyncdWaterPfx")
AddEventHandler("bms:firedept:stopSyncdWaterPfx", function(netid)
  print(string.format("stop netid: %s", netid))
  
  if (not netid) then
    return
  end

  if (NetworkDoesEntityExistWithNetworkId(netid)) then
    if (waterPfx[netid]) then
      local data = waterPfx[netid]

      if (data.active) then
        StopParticleFxLooped(data.pfx)
        waterPfx[netid] = nil
      end
    end
  end
end)

RegisterNetEvent("bms:firedept:debugPfxSave")
AddEventHandler("bms:firedept:debugPfxSave", function()
  if (debug.active and debug.pfx) then
    print(string.format("offset: %s, rot: %s", exports.devtools:dump(debug.offset), exports.devtools:dump(debug.rot)))
  end
end)

Citizen.CreateThread(function()
  Wait(2000)

  for k,v in pairs(truckOffsets) do
    truckHosePinOffsets[GetHashKey(k)] = v.hoseOffset
  end
end)

Citizen.CreateThread(function() -- TODO refuce thread count
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if (isonduty) then
      if (lastveh ~= 0) then
        local lastTruck = getLastFiretruck(GetEntityModel(lastveh))
        local vpos = GetEntityCoords(lastveh)
        local truckData = getTruckData(GetEntityModel(lastveh))

        if (truckData) then
          DrawMarker(2, vpos.x + truckData.activateOffset.x, vpos.y + truckData.activateOffset.y, vpos.z + truckData.activateOffset.z, 0, 0, 0, 0, 180.0, 0, 0.155, 0.155, 0.155, 0, 120, 120, 50, 0, 0, 0, true, 0, 0, 0)
        else
          print("truckData was nil")
        end
      end
      
      if (hoseActive and hoseRopeId and hoseRopeId ~= 0 and lastveh ~= 0) then -- ropes are not networked, wonderful.. more layers to add
        local ped = PlayerPedId()
        local vpos = GetEntityCoords(lastveh)
        local epos = GetEntityCoords(hoseNozzleEnt)
        local pinOffset = truckHosePinOffsets[GetEntityModel(lastveh)]

        PinRopeVertex(hoseRopeId, 0, epos.x - 0.1, epos.y, epos.z - 0.08)
        PinRopeVertex(hoseRopeId, GetRopeVertexCount(hoseRopeId) - 1, vpos.x + pinOffset.x, vpos.y + pinOffset.y, vpos.z + pinOffset.z)
        DisableControlAction(0, 24, true)

        if (IsControlPressed(1, 24) or IsDisabledControlPressed(1, 24)) then -- left click
          if (not waterActive and not blockWaterActivate) then
            waterActive = true
            local prent = exports.emotes:getCurrentForcedProp()

            if (prent) then
              local propnet = NetworkGetNetworkIdFromEntity(prent)
              
              TriggerServerEvent("bms:firedept:startSyncdWaterPfx", {propNetId = propnet})
            else
              print("prent was nil >> firedept_cl.lua")
            end
          end
        end
        
        if (IsControlJustReleased(1, 24) or IsDisabledControlJustReleased(1, 24)) then
          if (not debug.active) then
            blockWaterActivate = true
            waterActive = false
            startHoseActivateTimeout()

            if (hoseNozzleEnt) then
              local propnet = NetworkGetNetworkIdFromEntity(hoseNozzleEnt)
              
              TriggerServerEvent("bms:firedept:stopSyncdWaterPfx", {propNetId = propnet}) -- implement
            end
          else
            print("PFX was not stopped, due to debugging flag.")
          end
        end
      end
    end

    for netid,data in pairs(waterPfx) do
      if (data.localEnt) then
        local entpos = GetEntityCoords(data.localEnt)
        local dist = #(pos - entpos)

        if (dist < 20.0 and not data.active) then
          data.active = true
          SetPtfxAssetNextCall("core")

          data.pfx = StartParticleFxLoopedOnEntity("water_cannon_spray", data.localEnt, 0.0, 0.15, 0.0, 0, 0, 90.0, 1.0)
          
          if (debug.active) then
            debug.ent = data.localEnt
            debug.pfx = data.pfx
            debug.offset = vec3(0, 0, 0)
          end
        elseif (data.active and dist > 20.0) then
          StopParticleFxLooped(data.pfx)
          data.active = false
        end
      end
    end

    --[[ debugging ]]
    if (debug.active and debug.pfx ~= 0) then
      local ped = PlayerPedId()

      if (IsControlPressed(1, 172)) then -- up arrow
        if (debug.pfx ~= 0) then
          StopParticleFxLooped(debug.pfx)
        end

        debug.offset = {x = debug.offset.x, y = debug.offset.y + 0.025, z = debug.offset.z}
        SetPtfxAssetNextCall("core")
        debug.pfx = StartParticleFxLoopedOnEntity("water_cannon_spray", debug.ent, debug.offset.x, debug.offset.y, debug.offset.z, debug.rot.x, debug.rot.y, debug.rot.z, 1.0)
      end

      if (IsControlPressed(1, 173)) then -- down arrow
        if (debug.pfx ~= 0) then
          StopParticleFxLooped(debug.pfx)
        end

        debug.offset = {x = debug.offset.x, y = debug.offset.y -0.025, z = debug.offset.z}
        SetPtfxAssetNextCall("core")
        debug.pfx = StartParticleFxLoopedOnEntity("water_cannon_spray", debug.ent, debug.offset.x, debug.offset.y, debug.offset.z, debug.rot.x, debug.rot.y, debug.rot.z, 1.0)
      end

      if (IsControlPressed(1, 174)) then -- left arrow
        if (debug.pfx ~= 0) then
          StopParticleFxLooped(debug.pfx)
        end

        debug.offset = {x = debug.offset.x - 0.025, y = debug.offset.y, z = debug.offset.z}
        SetPtfxAssetNextCall("core")
        debug.pfx = StartParticleFxLoopedOnEntity("water_cannon_spray", debug.ent, debug.offset.x, debug.offset.y, debug.offset.z, debug.rot.x, debug.rot.y, debug.rot.z, 1.0)
      end

      if (IsControlPressed(1, 175)) then -- right arrow
        if (debug.pfx ~= 0) then
          StopParticleFxLooped(debug.pfx)
        end

        debug.offset = {x = debug.offset.x + 0.025, y = debug.offset.y, z = debug.offset.z}
        SetPtfxAssetNextCall("core")
        debug.pfx = StartParticleFxLoopedOnEntity("water_cannon_spray", debug.ent, debug.offset.x, debug.offset.y, debug.offset.z, debug.rot.x, debug.rot.y, debug.rot.z, 1.0)
      end

      if (IsControlPressed(1, 108)) then -- NUM 4
        
      end

      if (IsControlPressed(1, 109)) then -- NUM 6
        
      end

      -- rot
      if (IsControlPressed(1, 314)) then -- NUM +
        if (debug.pfx ~= 0) then
          StopParticleFxLooped(debug.pfx)
        end

        debug.rot = {x = debug.rot.x, y = debug.rot.y, z = debug.rot.z + 0.5}
        SetPtfxAssetNextCall("core")
        debug.pfx = StartParticleFxLoopedOnEntity("water_cannon_spray", debug.ent, debug.offset.x, debug.offset.y, debug.offset.z, debug.rot.x, debug.rot.y, debug.rot.z, 1.0)
      end

      if (IsControlPressed(1, 315)) then -- NUM -
        if (debug.pfx ~= 0) then
          StopParticleFxLooped(debug.pfx)
        end

        debug.rot = {x = debug.rot.x, y = debug.rot.y, z = debug.rot.z - 0.5}        
        SetPtfxAssetNextCall("core")
        debug.pfx = StartParticleFxLoopedOnEntity("water_cannon_spray", debug.ent, debug.offset.x, debug.offset.y, debug.offset.z, debug.rot.x, debug.rot.y, debug.rot.z, 1.0)
      end

      drawDebugLines()
    end
    --[[ end debugging ]]
  end
end)