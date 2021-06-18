--[[ bison, sadler, bobcatxl ]]
local pickups = {
  {
    pos = {x = 804.50677490234, y = -819.63800048828, z = 26.181083679199},
    tspawn = {x = 812.5107421875, y = -822.73742675781, z = 26.088619232178, heading = 19.058},
    dropoff = {x = 802.02838134766, y = -810.46990966797, z = 26.184997558594}
  }    
}
local pickupblips = {}
local moweroffs = {y = -1.2, z = 0.1}
local trailerhash = "trailersmall"
local mowerhash = "mower"
local jobtrailer = 0
local jobmower = 0
local mattached = false
local mowmats = {
  1333033863, -- green grass 1
  -1286696947, -- green grass 2
  -461750719, -- golf grass 1
  -1286696947, -- golf grass 2
}
local mowing = false
local mowingtime = 0
local blockinput = false
local mpfx = {dict = "core", pfx = "ent_anim_leaf_blower", inst = 0}
local pmod = 0 -- used for display
local spawnedtrailer = false

function spawnJobVehicle(vehmodel, vspx, vspy, vspz, vehspawnh, istrailer)
  local model = GetHashKey(vehmodel)

  RequestModel(model)

  while not HasModelLoaded(model) do
    Wait(1)
  end

  local veh = CreateVehicle(model, vspx, vspy, vspz, vehspawnh + 0.0001, true, false)
  
  SetModelAsNoLongerNeeded(model)
  SetVehicleOnGroundProperly(veh)
  
  if (not istrailer) then
    SetVehicleDoorsLocked(veh, 1)
    SetVehicleDoorsLockedForPlayer(veh, PlayerId(), false)
  end

  SetEntityAsMissionEntity(veh, true, true)
  SetVehicleDirtLevel(veh, 0)
  
  if (not istrailer) then
    TriggerEvent("frfuel:filltankForVeh", veh)
  end
  
  exports.vehicles:registerPulledVehicle(veh)
  local plate = string.lower(GetVehicleNumberPlateText(veh))
  TriggerServerEvent("bms:vehicles:registerJobVehicle", plate, vehmodel)

  return veh
end

function drawMowerPickupBlips()
  for _,v in pairs(pickups) do
    local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)

    SetBlipSprite(blip, 381)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 24)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Lawn Care")
    EndTextCommandSetBlipName(blip)

    table.insert(pickupblips, blip)
  end
end

function startPfx()
  Citizen.CreateThread(function()
    if (mpfx.inst ~= 0) then
      return
    end

    while (not HasNamedPtfxAssetLoaded(mpfx.dict)) do
      RequestNamedPtfxAsset(mpfx.dict)
      Wait(10)
    end

    UseParticleFxAssetNextCall(mpfx.dict)
    mpfx.inst = StartParticleFxLoopedOnEntity(mpfx.pfx, jobmower, 0.0, 0.15, -0.225, 0, 0, 0, 1.5, 0, 0, 0)
    SetParticleFxLoopedColour(mpfx.inst, 1.0, 1.0, 1.0)
    UseParticleFxAssetNextCall(mpfx.dict)
  end)
end

function stopPfx()
  if (mpfx.inst ~= 0) then
    StopParticleFxLooped(mpfx.inst)
    mpfx.inst = 0
  end
end

RegisterNetEvent("bms:lawncare:testmaterial")
AddEventHandler("bms:lawncare:testmaterial", function()
  local ped = PlayerPedId()
  local mpos = GetEntityCoords(ped)

  local rayh = CastRayPointToPoint(mpos.x, mpos.y, mpos.z, mpos.x, mpos.y, mpos.z - 2.0, 1, ped, 0)
  local _,_,_,_,matunder,_ = GetShapeTestResultEx(rayh)

  if (matunder ~= 0) then
    TriggerEvent("chatMessage", "DEVTOOLS", {0, 0, 255}, string.format("Material Test: %s.  Sent to Discord.", matunder))
    TriggerServerEvent("bms:lawncare:testmatresult", matunder)
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1000)

    if (mowing) then
      mowingtime = mowingtime + 1000
      --print(string.format("Mow time: %s", mowingtime))
      local amt = math.ceil((mowingtime / 1000) * pmod)
      SendNUIMessage({setLawnAmount = true, amount = amt})
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    local inveh = veh ~= 0
    local hastrailer, curtrailer = GetVehicleTrailerVehicle(veh, 1)
    
    if (not hastrailer and not spawnedtrailer) then
      for _,v in pairs(pickups) do
        if (#pickupblips == 0) then
          drawMowerPickupBlips()
        end

        local pos = GetEntityCoords(ped)
        local dist = Vdist(pos.x, pos.y, pos.z, v.pos.x, v.pos.y, v.pos.z)

        if (dist < 40) then
          DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0000001, 0, 0, 0, 0, 0, 0, 3.0, 3.0, 0.15, 120, 255, 70, 50, 0, 0, 0, 0, 0, 0, 0)

          if (dist < 1.5 and inveh) then
            draw3DTextGlobal(v.pos.x, v.pos.y, v.pos.z + 0.25, "Press ~b~E~w~ to get your lawn care equipment.", 0.37)

            if (isGameControlPressed(1, 38)) then
              spawnedtrailer = true
              jobtrailer = spawnJobVehicle(trailerhash, v.tspawn.x, v.tspawn.y, v.tspawn.z, v.tspawn.heading, true)

              while (not DoesEntityExist(jobtrailer)) do
                Wait(10)
              end
              
              AttachVehicleToTrailer(veh, jobtrailer, 7.0)
              Wait(250)
              local msp = GetOffsetFromEntityInWorldCoords(jobtrailer, 2.0, 0.0, 0.0)
              jobmower = spawnJobVehicle(mowerhash, msp.x, msp.y, msp.z, 0.0, false)

              while (not DoesEntityExist(jobmower)) do
                Wait(10)
              end
              
              AttachEntityToEntity(jobmower, jobtrailer, 20, 0.0, moweroffs.y, moweroffs.z, 0, 0, 0, false, false, false, false, 20, true)
              mattached = true
              exports.management:TriggerServerCallback("bms:jobs:lawncare:getPMod", function(mod)
                pmod = mod
              end)
            end
          end
        end
      end
    --else
    end
      
    if (jobtrailer ~= 0 and jobmower ~= 0) then
      if (mattached) then
        local toff = GetOffsetFromEntityInWorldCoords(jobtrailer, -1.6, -0.2, 0.0)
        local pos = GetEntityCoords(ped)
        local tdist = Vdist(pos.x, pos.y, pos.z, toff.x, toff.y, toff.z)
        local onfoot = not IsPedInAnyVehicle(ped)

        if (tdist < 40 and onfoot) then
          DrawMarker(20, toff.x, toff.y, toff.z + 0.5, 0, 0, 0, 0, 0, 0, 0.6, 0.6, 0.6, 80, 200, 0, 50, 1, 0, 0, 1, 0, 0, 0)

          if (tdist < 0.65) then
            draw3DTextGlobal(toff.x, toff.y, toff.z + 0.25, "Press ~b~H~w~ to ~b~un~w~hitch your lawn mower.", 0.37)

            if (isGameControlPressed(1, 74)) then
              DetachEntity(jobmower)
              mattached = false
            end
          end
        end
      else
        local speed = GetEntitySpeed(jobmower)
        local mpos = GetEntityCoords(jobmower)
        local engon = GetIsVehicleEngineRunning(jobmower)
        local toff = GetOffsetFromEntityInWorldCoords(jobtrailer, 0.0, moweroffs.y, moweroffs.z)
        local disttrail = Vdist(mpos.x, mpos.y, mpos.z, toff.x, toff.y, toff.z)
        local onwheels = IsVehicleOnAllWheels(jobmower)

        if (veh == jobmower and speed > 1.0 and engon and onwheels) then
          local rayh = CastRayPointToPoint(mpos.x, mpos.y, mpos.z, mpos.x, mpos.y, mpos.z - 2.0, 1, jobmower, 0)
          local _,_,_,_,matunder,_ = GetShapeTestResultEx(rayh)

          for _,v in pairs(mowmats) do
            if (v == matunder) then
              mowing = true
              SendNUIMessage({toggleLawnIcon = true, toggle = true})
              startPfx()
              break
            end
          end
        elseif (speed <= 0.1 and veh == jobmower and not blockinput) then
          if (disttrail < 1.3) then
            draw3DTextGlobal(toff.x, toff.y, toff.z + 0.25, "Press ~b~H~w~ to ~b~hitch~w~ your lawn mower.", 0.37)

            if (isGameControlPressed(1, 74)) then
              blockinput = true
              TaskLeaveVehicle(ped, jobmower)
              Wait(500)
              AttachEntityToEntity(jobmower, jobtrailer, 20, 0.0, moweroffs.y, moweroffs.z, 0, 0, 0, false, false, false, false, 20, true)
              mattached = true
              exports.management:TriggerServerCallback("bms:jobs:lawncare:pmt", function(data)
                mowingtime = 0
                blockinput = false
              end, mowingtime)
            end
          end

          mowing = false
          SendNUIMessage({toggleLawnIcon = true, toggle = false})
          stopPfx()
        end
      end
    end

    if (jobtrailer ~= 0 or jobmower ~= 0) then
      for _,v in pairs(pickups) do
        local ddist = Vdist(pos.x, pos.y, pos.z, v.dropoff.x, v.dropoff.y, v.dropoff.z)

        if (ddist < 40) then
          DrawMarker(27, v.dropoff.x, v.dropoff.y, v.dropoff.z - 0.900001, 0, 0, 0, 0, 0, 0, 3.0, 3.0, 0.1, 160, 0, 0, 50, 0, 0, 0, 1, 0, 0, 0)
          
          if (ddist < 1.5) then
            draw3DTextGlobal(v.dropoff.x, v.dropoff.y, v.dropoff.z + 0.25, "Press ~b~E~w~ to <span style='color: red;'>return</span> your lawn care equipment.", 0.37)
            
            if (isGameControlPressed(1, 38)) then
              exports.vehicles:deleteCar(jobmower)
              jobmower = 0
              exports.vehicles:deleteCar(jobtrailer)
              jobtrailer = 0
              spawnedtrailer = false
            end
          end
        end
      end
    end
  end
end)