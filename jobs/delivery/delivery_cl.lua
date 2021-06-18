local DrawMarker = DrawMarker

local deliveryjobs = {}
local jobBlips = {}
local showAllBlips = true
local activeJob
local activeDropIdx = 0
local activeJobBlip
local jobCar
local jobTotalDist = 0
local distWarn = false
local payblock = false
local hasparcel = false
local jobtype = 1
local deliveredhere = false
local currjob = nil
local jobMarkers = {}
local deliveryMarker = nil
local returnMarkers = {}

function drawText(text)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.72, 0.72)
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

function spawnJobCar(vehmodel, vehspawn, vehspawnh, col, livery)
  Citizen.CreateThread(function()
    local model = GetHashKey(vehmodel)

    RequestModel(model)

    while not HasModelLoaded(model) do
      Wait(1)
    end

    jobCar = CreateVehicle(model, vehspawn, vehspawnh + 0.0001, true, false)
    
    SetModelAsNoLongerNeeded(model)
    SetVehicleOnGroundProperly(jobCar)
    SetVehicleDoorsLocked(jobCar, 1)
    SetVehicleDoorsLockedForPlayer(jobCar, PlayerId(), false)
    SetEntityAsMissionEntity(jobCar, true, true)
    
    if (col) then
      SetVehicleColours(jobCar, col[1], col[2])
    end

    if (livery) then
      if (livery.isextra) then
        for i = 1, livery.exmax do
          SetVehicleExtra(jobCar, i, true)
        end

        SetVehicleExtra(jobCar, livery.ex)
      else
        SetVehicleModKit(jobCar, 0)
        SetVehicleLivery(jobCar, livery)
      end
    end

    while (not DoesEntityExist(jobCar)) do
      Wait(10)
    end

    SetVehicleDirtLevel(jobCar, 0)
    TriggerEvent("frfuel:filltankForVeh", jobCar)
    exports.vehicles:registerPulledVehicle(jobCar)
    
    local plate = string.lower(GetVehicleNumberPlateText(jobCar))
    TriggerServerEvent("bms:vehicles:registerJobVehicle", plate, vehmodel)
  end)
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function spawnParcelInHands(prop)
  local pr
  
  if (prop) then
    pr = prop
  else
    pr = "prop_cs_package_01"
  end

  TriggerEvent("bms:devtools:addpropinhand", pr, 1, 0.1, 0.02, 0.25, 4.75, 74.75, 124.75, true)
end

function setNewActiveJob(cb)
  exports.management:TriggerServerCallback("bms:jobs:delivery:getNewDelivery", function(newJob)
    activeDropIdx = newJob
    --print(activeDropIdx)
    cb(activeDropIdx)
  end, {jobtype = jobtype})
end

RegisterNetEvent("bms:jobs:delivery:addBlips")
AddEventHandler("bms:jobs:delivery:addBlips", function(deljobs)
  for i = 1, #deliveryjobs do
    if (jobBlips[i] ~= nil) then
      RemoveBlip(jobBlips[i])
      jobBlips[i] = nil
    end
  end

  jobBlips = {}
  showAllBlips = true
  activeJob = nil
  activeDropIdx = 0
  activeJobBlip = nil
  jobCar = nil
  jobTotalDist = 0
  deliveryjobs = deljobs
end)

--[[
local curdp = 0

RegisterNetEvent("bms:jobs:delivery:dp")
AddEventHandler("bms:jobs:delivery:dp", function()
  local ped = PlayerPedId()
  curdp = curdp + 1

  local job = deliveryjobs[2].pointdropoffs
  local count = #job

  if (curdp == count) then
    curdp = 1
    exports.pnotify:SendNotification({text = "End reached."})
  end

  local point = deliveryjobs[1].pointdropoffs[curdp]

  Citizen.CreateThread(function()
    RequestCollisionAtCoord(point.x, point.y, point.z)
    
    while not HasCollisionLoadedAroundEntity(ped) do
      RequestCollisionAtCoord(point.x, point.y, point.z)
      Citizen.Wait(0)
    end
    
    SetEntityCoords(ped, point.x, point.y, point.z)
  end)
end)]]

RegisterNetEvent("bms:jobs:delivery:driverpaid")
AddEventHandler("bms:jobs:delivery:driverpaid", function(income)
  deliveredhere = true
  exports.pnotify:SendNotification({text = string.format("You have received <font color='skyblue'>$%s</font> for completing your delivery.  It has been deposited into your bank account.", income)})
  TriggerServerEvent("bms:management:updateAnalytics", "Deliveries Made", 1)
  RemoveBlip(activeJobBlip)
  activeJobBlip = nil
  setNewActiveJob(function()
    currJob = activeJob.pointdropoffs[activeDropIdx]
    local pos = GetEntityCoords(PlayerPedId())

    jobTotalDist = #(pos - currJob.pos)
    
    if (activeJobBlip == nil) then
      local blip = AddBlipForCoord(currJob.pos)

      SetBlipSprite(blip, activeJob.blipid)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 0.9)
      SetBlipColour(blip, 2)
      SetBlipAsShortRange(blip, false)
      SetBlipFlashes(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(activeJob.blipname)
      EndTextCommandSetBlipName(blip)
      
      activeJobBlip = blip
    end
    
    SetNewWaypoint(currJob.pos.x, currJob.pos.y)
    exports.pnotify:SendNotification({text = "A new job is available and your GPS has been updated."})
    payblock = false
  end)
end)

local debugdelpoints = {}
RegisterNetEvent("bms:jobs:delivery:showDelPoints")
AddEventHandler("bms:jobs:delivery:showDelPoints", function(jobs, idx)
  if (#debugdelpoints > 0) then
    for _,v in pairs(debugdelpoints) do
      RemoveBlip(v)
    end

    debugdelpoints = {}
    return
  end
  
  if (jobs) then
    local points = jobs[idx]

    for i,v in pairs(points.pointdropoffs) do
      local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)

      SetBlipSprite(blip, points.blipid)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 0.9)
      SetBlipColour(blip, points.blipcolor or 2)
      SetBlipAsShortRange(blip, false)
      SetBlipFlashes(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(points.blipname)
      EndTextCommandSetBlipName(blip)

      table.insert(debugdelpoints, blip)
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    if (deliveryjobs) then
      for _,v in pairs(jobMarkers) do
        DrawMarker(1, v.pointpickup.pos.x, v.pointpickup.pos.y, v.pointpickup.pos.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.15, 120, 255, 70, 50, 0, 0, 2, 0, 0, 0, 0)

        if (v.dist < 10) then
          local dist = #(pos - v.pointpickup.pos)

          if (dist < 0.6 and activeJob == nil) then
            draw3DTextGlobal(v.pointpickup.pos.x, v.pointpickup.pos.y, v.pointpickup.pos.z + 0.25, "~w~Press ~b~E~w~ to start this delivery job.", 0.36)

            if (IsControlJustReleased(1, 38)) then -- E
              activeJob = v
              jobtype = v.idx
              setNewActiveJob(function()
                showAllBlips = false

                currJob = activeJob.pointdropoffs[activeDropIdx]
                --print(string.format("currJob: %s", activeDropIdx))
                jobTotalDist = #(v.pointpickup.pos - currJob.pos)
                
                if (activeJobBlip == nil) then
                  local blip = AddBlipForCoord(currJob.pos)

                  SetBlipSprite(blip, activeJob.blipid)
                  SetBlipDisplay(blip, 4)
                  SetBlipScale(blip, 0.9)
                  SetBlipColour(blip, 2)
                  SetBlipAsShortRange(blip, false)
                  SetBlipFlashes(blip, true)
                  BeginTextCommandSetBlipName("STRING")
                  AddTextComponentString(activeJob.blipname)
                  EndTextCommandSetBlipName(blip)
                  activeJobBlip = blip
                end
                
                SetNewWaypoint(currJob.pos.x, currJob.pos.y)
                spawnJobCar(activeJob.vehmodel, activeJob.vehspawnpoint.pos, activeJob.vehspawnheading, activeJob.vehcolors, activeJob.livery)
                exports.pnotify:SendNotification({text = "Your delivery vehicle is now available.", layout = "bottomLeft"})
                TriggerServerEvent("bms:management:updateAnalytics", activeJob.blipname, 1)
              end)
            end
          end
        end
      end
    
      if (deliveryMarker) then
        DrawMarker(27, deliveryMarker.pos.x, deliveryMarker.pos.y, deliveryMarker.pos.z - 0.5501, 0, 0, 0, 0, 0, 0, 1.9, 1.9, 1.9, 178, 236, 93, 100, 0, 0, 2, 1, 0, 0, 0)

        if (not IsPedInAnyVehicle(ped)) then
          if (deliveryMarker.dist < 25) then
            if (not hasparcel) then              
              local toff = GetOffsetFromEntityInWorldCoords(jobCar, activeJob.jobpuoffset.x, activeJob.jobpuoffset.y, -1.000001)
              local odist = #(pos - toff)

              DrawMarker(20, toff.x, toff.y - 0.5, toff.z + 1.0, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 0, 180, 255, 50, 1, 0, 0, 1, 0, 0, 0)
                            
              if (odist > 1.3) then
                drawTextGlobal("Pick up your delivery from the vehicle.", 0.45, 0.94)
              else
                draw3DTextGlobal(toff.x, toff.y, toff.z + 0.25, "~w~Press ~b~H~w~ to pick up your delivery.", 0.36)
                
                if (IsControlJustReleased(1, 74)) then -- H
                  hasparcel = true
                  spawnParcelInHands(activeJob.prop)
                end
              end
            else
              if (deliveryMarker.dist < 10) then
                draw3DTextGlobal(currJob.pos.x, currJob.pos.y, currJob.pos.z + 0.25, "~w~Press ~b~E~w~ to complete your delivery.", 0.36)

                if (not payblock) then
                  if (IsControlJustReleased(1, 38)) then -- E
                    payblock = true
                    deliveryMarker = nil
                    local income = tonumber(round(activeJob.profit * jobTotalDist))

                    spawnParcelInHands()
                    hasparcel = false
                    TriggerServerEvent("bms:jobs:delivery:paydriver", income, activeDropIdx)
                  end
                end
              end
            end
          end
        end
      end
    else
      print("deliveryjobs == nil")
    end
    
    if (jobCar) then
      local vbh = GetVehicleBodyHealth(jobCar) -- 0
      local veh = GetVehicleEngineHealth(jobCar) -- -4000
      local vpos = GetEntityCoords(jobCar)
      
      if (vbh <= 0 and veh == -4000) then
        exports.pnotify:SendNotification({text = "Your job vehicle was completely destroyed.  Your contract has been cancelled."})
        activeJob = nil
        jobTotalDist = 0
        RemoveBlip(activeJobBlip)
        activeJobBlip = nil
        showAllBlips = true

        if (hasparcel) then
          hasparcel = false
          spawnParcelInHands()
        end
      end
      
      local dist = #(pos - vpos)

      if (dist > 50) then
        if (not distWarn) then
          exports.pnotify:SendNotification({text = "If you get too far away from the job vehicle your contract will be cancelled."})
          distWarn = true
        end
        
        if (dist > 65) then
          exports.pnotify:SendNotification({text = "You are too far away from the job vehicle.  Your contract has been cancelled and vehicle towed."})
          
          local pl = GetVehicleNumberPlateText(jobCar)

          if (pl and type(pl) == "string") then
            TriggerServerEvent("bms:vehicles:unregisterJobVehicle", pl)
          end
          
          activeJob = nil
          jobTotalDist = 0
          RemoveBlip(activeJobBlip)
          activeJobBlip = nil
          showAllBlips = true
          DeleteVehicle(jobCar)
          jobCar = nil

          if (hasparcel) then
            hasparcel = false
            spawnParcelInHands()
          end
        end
      else
        distWarn = false
      end

      for _,v in pairs(returnMarkers) do
        DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 0.800001, 0, 0, 0, 0, 0, 0, 3.5, 3.5, 0.15, 240, 70, 70, 50, 1, 0, 0, 1, 0, 0, 0)

        if (v.dist < 10) then
          local dist = #(pos - v.pos)

          if (dist < 1.5) then
            draw3DTextGlobal(v.pos.x, v.pos.y, v.pos.z + 0.25, "~w~Press ~b~E~w~ to return your delivery vehicle.", 0.36)

            if (isGameControlPressed(1, 38)) then -- E
              activeJob = nil
              jobTotalDist = 0
              activeDropIdx = 0
              RemoveBlip(activeJobBlip)
              activeJobBlip = nil
              showAllBlips = true

              if (hasparcel) then
                hasparcel = false
                spawnParcelInHands()
              end

              exports.vehicles:deleteCar(jobCar)
              jobCar = nil
            end
          end
        end
      end
    end
    
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1500)

    local pos = GetEntityCoords(PlayerPedId())
    local iter = 0
    local jMarkers = {}

    if (deliveryjobs) then
      if (showAllBlips) then
        if (#jobBlips == 0) then
          for i = 1,#deliveryjobs do                      
            local blip = AddBlipForCoord(deliveryjobs[i].pointpickup.pos)
            
            SetBlipSprite(blip, deliveryjobs[i].blipid)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.9)
            SetBlipColour(blip, deliveryjobs[i].blipcolor or 3)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(deliveryjobs[i].blipname)
            EndTextCommandSetBlipName(blip)
          
            jobBlips[i] = blip
          end
        end

        if (not activeJob) then
          for i=1,#deliveryjobs do
            local dist = #(pos - deliveryjobs[i].pointpickup.pos)

            if (dist < 65) then
              iter = iter + 1
              jMarkers[iter] = deliveryjobs[i]
              jMarkers[iter].dist = dist
              jMarkers[iter].idx = i
            end
          end
        end
      
      else
        if (#jobBlips ~= 0) then
          for i = 1,#deliveryjobs do
            if (jobBlips[i] ~= nil) then
              RemoveBlip(jobBlips[i])
            end
          end

          jobBlips = {}
        end
      end
    end

    jobMarkers = jMarkers

    if (activeJob and activeDropIdx > 0) then
      local dMarker = nil

      if (currJob == nil) then
        currjob = remainingjobs[tostring(jobtype)][activeDropIdx]
      end

      local dist = #(pos - currJob.pos)

      if (dist < 65) then
        dMarker = currJob
        dMarker.dist = dist
      end

      deliveryMarker = dMarker
    end

    if (jobCar) then
      local rMarkers = {}
      iter = 0
  
      for i=1,#deliveryjobs do
        local dist = #(pos - deliveryjobs[i].dropoff.pos)
  
        if (dist < 65) then
          iter = iter + 1
          rMarkers[iter] = deliveryjobs[i].dropoff
          rMarkers[iter].dist = dist
          rMarkers[iter].idx = i
        end
      end
  
      returnMarkers = rMarkers
    end
  end
end)
