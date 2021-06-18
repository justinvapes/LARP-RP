local math_random = math.random
local vipSpots = {}
local vipSpawns = {}
local vipBlip = 0
local vipLocBlip = 0
local vstage = 1 -- Stage 1 = Vehicle pickup to VIP Pickup, 2 = VIP Pickup to Plane Pickup, 3 = Plane Pickup to VIP Dropoff
local hasPickedUpVip = false
local jobVehicle = nil
local jobPlane = nil
local curvip = 1
local vipEntity = nil
local vipSkins = {
  "cs_solomon", "cs_bankman"
}
local waitVipSpawn = false
local vipSpawnRange = 80
local stageBlipsDrawn = false
local entertasked = false
local endblock = false
local planeSpawnRequested = false
local planeSpawn = {spawned = false}
local jobEnding = false

function drawVipBlips(clear, shortrange)
  if (stageBlipsDrawn) then
    return
  end

  if (clear) then
    RemoveBlip(vipBlip)
    vipBlip = 0
  end

  local v = vipSpots[1] -- temporary for one spot
  local blip
  local blinfo = {id = 0, color = 0}
  local setloc = false
  
  if (vstage == 1 and not hasPickedUpVip) then
    if (not jobVehicle) then
      blip = AddBlipForCoord(v.start.x, v.start.y, v.start.z)
      blinfo.id = 351
      blinfo.color = 44
    else
      local ec = vipSpawns[curvip]

      SetNewWaypoint(ec.pos.x, ec.pos.y)
      blip = AddBlipForCoord(ec.pos.x, ec.pos.y, ec.pos.z)
      setloc = true
      blinfo.id = 280
      blinfo.color = 44
      exports.pnotify:SendNotification({text = "Your <span style='color: skyblue'>transport contract</span> is waiting for pickup."})
    end
  elseif (vstage == 2) then
    if (planeSpawn and planeSpawn.pos) then
      SetNewWaypoint(planeSpawn.pos.x, planeSpawn.pos.y)
      blip = AddBlipForCoord(planeSpawn.pos.x, planeSpawn.pos.y, planeSpawn.pos.z)
      blinfo.id = 304
      blinfo.color = 44
      exports.pnotify:SendNotification({text = "Your air craft is waiting at the <span style='color: skyblue'>LAX Terminal</span>."})
    end
  elseif (vstage == 3) then
    SetNewWaypoint(v.plane.destination.x, v.plane.destination.y)
    blip = AddBlipForCoord(v.plane.destination.x, v.plane.destination.y, v.plane.destination.z)
    blinfo.id = 304
    blinfo.color = 43
    exports.pnotify:SendNotification({text = "A waypoint has been created to your <span style='color: skyblue'>destination</span>."})
  end
  
  SetBlipSprite(blip, blinfo.id)
  SetBlipColour(blip, blinfo.color)
  SetBlipDisplay(blip, 4)
  SetBlipScale(blip, 0.9)
  SetBlipAsShortRange(blip, shortrange)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("VIP Transport")
  EndTextCommandSetBlipName(blip)

  if (setloc) then
    SetBlipSprite(vipLocBlip, blinfo.id)
    SetBlipColour(vipLocBlip, blinfo.color)
    SetBlipDisplay(vipLocBlip, 4)
    SetBlipScale(vipLocBlip, 0.9)
    SetBlipAsShortRange(vipLocBlip, shortrange)
  end

  vipBlip = blip
  stageBlipsDrawn = true
end

function atDistanceAndKey(pos, spos, range, key, text)
  local dist = #(pos - spos)

  if (dist < range) then
    draw3DTextGlobal(spos.x, spos.y, spos.z + 0.25, text, 0.38)

    if (isGameControlPressed(1, key)) then
      return true
    end
  end

  return false
end

function getRandomVip()
  local rndskin = vipSkins[math_random(1, #vipSkins)]
  local rndspot = vipSpawns[curvip]
  local rndhead = math_random(1, 359)
  local phash = GetHashKey(rndskin)

  while (not HasModelLoaded(phash)) do
    RequestModel(phash)
    Wait(50)
  end  

  local ent = CreatePed(4, phash, rndspot.pos.x, rndspot.pos.y, rndspot.pos.z, rndhead, true, true)
  
  while (not DoesEntityExist(ent)) do
    Wait(10)
  end

  SetBlockingOfNonTemporaryEvents(ent, true)
  SetModelAsNoLongerNeeded(phash)
  vipLocBlip = AddBlipForEntity(ent)

  return ent
end

function resetJob()
  hasPickedUpVip = false
  entertasked = false
  jobPlane = nil
  jobVehicle = nil
  vstage = 1
  setJobPlane(nil)
  planeSpawnRequested = false
  RemoveBlip(vipBlip)
  vipBlip = 0
  jobEnding = false

  if (vipLocBlip ~= 0) then
    RemoveBlip(vipLocBlip)
    vipLocBlip = 0
  end
end

RegisterNetEvent("bms:aviation:vip:setVipSpots")
AddEventHandler("bms:aviation:vip:setVipSpots", function(data)
  if (data) then
    vipSpots = data.vipSpots
    vipSpawns = data.vipSpawns
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if (#vipSpots > 0) then
      if (jobPlane and vstage == 3) then
        local pvbh = GetVehicleBodyHealth(jobPlane)
        local pveng = GetVehicleEngineHealth(jobPlane)

        if (pvbh <= 0 and pveng == -4000) then
          resetJob()
          exports.pnotify:SendNotification({text = "Your aircraft has been completely <span style='color: red;'>destroyed</span>.  The FAA and Emergency services have been notified."})
          TriggerServerEvent("bms:aviation:vip:vehicleDestroyed", 1)
        end
      end

      if (jobVehicle and vstage == 1 or vstage == 2) then
        local pvbh = GetVehicleBodyHealth(jobVehicle)
        local pveng = GetVehicleEngineHealth(jobVehicle)

        if (pvbh <= 0 and pveng == -4000) then
          resetJob()
          exports.pnotify:SendNotification({text = "Your limo has been completely <span style='color: red;'>destroyed</span>."})
          TriggerServerEvent("bms:aviation:vip:vehicleDestroyed", 2)
        end
      end

      if (vipEntity and vstage == 2 or vstage == 3 and not jobEnding) then
        local vipdead = IsPedDeadOrDying(vipEntity)

        if (vipdead) then
          resetJob()
          exports.pnotify:SendNotification({text = "Your transport contract has been <span style='color: red;'>killed</span>."})
          TriggerServerEvent("bms:aviation:vip:vehicleDestroyed", 3)
        end
      end

      if (vipBlip == 0) then
        drawVipBlips(false, true)
      end

      for _,v in pairs(vipSpots) do
        if (vstage == 1) then
          if (not hasPickedUpVip) then
            if (not stageBlipsDrawn) then
              drawVipBlips(true, false)
            end

            if (not jobVehicle) then
              DrawMarker(7, v.start.x, v.start.y, v.start.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 120, 255, 70, 50, 0, 0, 0, 1, 0, 0, 0)
            
              if (atDistanceAndKey(pos, v.start, 0.7, 38, "Press ~b~E~w~ to rent a limousine.")) then
                jobVehicle = spawnVehicle(v.limo.spos, v.limo.heading, v.limoModel, nil)
                stageBlipsDrawn = false
                
                if (not vipEntity and not waitVipSpawn) then
                  curvip = math_random(1, #vipSpawns)
                  waitVipSpawn = true
                end
                
                drawVipBlips(true, false)
              end
            else
              local vpos = GetEntityCoords(vipEntity)
              local jvpos = GetEntityCoords(jobVehicle)
              local dist = #(vpos - jvpos)
              local vipSpawn = vipSpawns[curvip]
              local vrange = vipSpawn and vipSpawn.range or 15.0

              if (dist < vrange) then
                if (not IsPedInVehicle(vipEntity, jobVehicle)) then
                  if (not entertasked) then
                    TaskEnterVehicle(vipEntity, jobVehicle, 20000, 2, 1.0, 1, 0)
                    entertasked = true
                  end
                else
                  entertasked = false
                  vstage = 2
                end
              else
                entertasked = false
              end
            end
          end
        elseif (vstage == 2) then
          if (not jobPlane and not planeSpawnRequested) then
            planeSpawnRequested = true
            exports.management:TriggerServerCallback("bms:aviation:vip:getPlaneSpawn", function(data)
              planeSpawn = {spawned = false, pos = data.pos, heading = data.heading, model = v.planeModel}
              stageBlipsDrawn = false
              drawVipBlips(true, false)
            end)            
          elseif (not jobPlane and not planeSpawn.spawned) then
            if (planeSpawn and planeSpawn.pos) then
              if (#(pos - planeSpawn.pos) < vipSpawnRange) then
                planeSpawn.spawned = true
                jobPlane = spawnVehicle(planeSpawn.pos, planeSpawn.heading, planeSpawn.model, nil)
              end
            end
          elseif (jobPlane and planeSpawn.spawned) then
            local ppos = GetEntityCoords(jobPlane)
            local dist = #(pos - ppos)

            if (dist < 40) then
              local stopped = IsVehicleStopped(jobVehicle)

              if (stopped) then
                if (not entertasked) then
                  TaskEnterVehicle(vipEntity, jobPlane, 20000, 1, 1.0, 1, 0)
                  entertasked = true
                end

                if (IsPedInVehicle(vipEntity, jobPlane)) then
                  ClearPedTasks(vipEntity)
                  SetBlockingOfNonTemporaryEvents(vipEntity, true)
                  SetPedFleeAttributes(vipEntity, 0, 0)
                  vstage = 3
                  stageBlipsDrawn = false
                  drawVipBlips(true, false)
                end
              else
                entertasked = false
              end
            end
          end
        elseif (vstage == 3) then -- fly plane to destination
          if (jobVehicle) then
            local jcpos = GetEntityCoords(jobVehicle)
            local distFromCar = #(pos - jcpos)       

            if (distFromCar > 75) then
              exports.vehicles:deleteCar(jobVehicle)

              jobVehicle = nil
            end
          end
          
          local dest = v.plane.destination
          local jpos = GetEntityCoords(jobPlane)
          local dist = #(jpos - dest)

          if (dist < 40) then
            DrawMarker(1, dest.x, dest.y, dest.z - 1.000001, 0, 0, 0, 0, 0, 0, 15.0, 15.0, 0.15, 120, 255, 70, 50, 0, 0, 0, 0, 0, 0, 0)

            if (dist < 10.0) then
              local stopped = IsVehicleStopped(jobPlane)
              local engon = GetIsVehicleEngineRunning(jobPlane)
              local vpos = GetEntityCoords(vipEntity)

              if (engon) then
                drawTextGlobal("Turn the engine off and wait for the VIP to disembark.", 0.5, 0.93, 0.45, 0.37)
              end

              if (stopped and not engon and not jobEnding) then
                jobEnding = true
                TaskLeaveVehicle(vipEntity, jobPlane, 0)
                Wait(2000)
                TaskGoToCoordAnyMeans(vipEntity, v.plane.vipDest.x, v.plane.vipDest.y, v.plane.vipDest.z, 1.0, 0, 0, 786603, 0)
              end

              if (jobEnding) then
                local vdist = #(vpos - v.plane.vipDest)

                if (vdist < 3.0) then
                  DeletePed(vipEntity)
                  vipEntity = nil
                end
              end

              if (not vipEntity) then
                drawTextGlobal("Press ~b~E~w~ to return your aircraft to the hangar.", 0.5, 0.93, 0.45, 0.37)

                if (not endblock) then
                  if (isGameControlPressed(1, 38)) then
                    endblock = true

                    exports.management:TriggerServerCallback("bms:aviation:vip:vipcomplete", function(amount)
                      RemoveBlip(vipBlip)
                      vipBlip = 0
                      RemoveBlip(vipLocBlip)
                      vipLocBlip = 0

                      exports.vehicles:deleteCar(jobPlane)

                      hasPickedUpVip = false
                      entertasked = false
                      jobPlane = nil
                      vstage = 1
                      jobEnding = false
                      planeSpawnRequested = false
                      exports.pnotify:SendNotification({text = string.format("You have been paid <span style='color: lawngreen;'>$%s</span> for transporting the <span style='color: skyblue'>VIP</span> to their destination.", amount)})
                      endblock = false
                    end)
                  end
                end
              end
            end
          end
        end
      end
    end

    if (waitVipSpawn and not vipEntity) then
      local vipSpawn = vipSpawns[curvip]

      if (#(pos - vipSpawn.pos) < vipSpawnRange) then
        waitVipSpawn = false
        vipEntity = getRandomVip()

        if (vipBlip and DoesBlipExist(vipBlip)) then
          RemoveBlip(vipBlip)
          vipBlip = 0
        end
      end
    end
  end
end)