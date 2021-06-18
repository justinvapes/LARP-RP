local dusterspots = {}
local dustfields = {}
local planeblips = {}
local jobplane = nil
local smokepfx = {}
local spawnblock = false
local curfield = {index = 1, waypoint = nil}
local debugDrawFields = {active = false, blips = {}}
local returnPlane = false
local dustfuel = 100
local dustFuelSpots = {
  {pos = vec3(2107.0180664063, 4770.0200195313, 41.216358184814)}
}
local props = {
  {pos = vec3(2014.906, 4729.592, 40.411), heading = 203.751, model = "prop_gas_tank_01a"},
  {pos = vec3(2010.344, 4730.183, 40.332), heading = 21.406, model = "prop_gas_pump_old3"}
}
local refuelTime = {cur = 0, max = 10000}
local refueling = false
local smokesize = 3.0
local smoketimeout = 10000
local returnSpot = {pos = vec3(2128.3413085938, 4793.498046875, 41.122276306152)}
local airspace = {}
local outOfAirspace = false

function drawPlaneText(text, x, y)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.29, 0.29)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x or 0.475, y or 0.925)
end

function drawPlaneHud()
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.29, 0.29)
  SetTextColour(255, 255, 0, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(0)
  SetTextEntry("STRING")
  AddTextComponentString(string.format("CF Level: %s%%", dustfuel))
  DrawText(0.175, 0.925)
end

function setupPlaneBlips()
  for _,v in pairs(dusterspots) do
    local blip = AddBlipForCoord(v.marker.x, v.marker.y, v.marker.z)
    
    SetBlipSprite(blip, 251)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 15)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Crop Duster")
    EndTextCommandSetBlipName(blip)
    
    table.insert(planeblips, blip)
  end
end

function setupFuelBlips()
  for _,v in pairs(dustFuelSpots) do
    local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
    
    SetBlipSprite(blip, 361)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 60)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Airplane CF Refuel")
    EndTextCommandSetBlipName(blip)
    
    table.insert(fuelblips, blip)
  end
end

function spawnCdProps()
  for _,v in pairs(props) do
    local hash = GetHashKey(v.model)
    
    while (not HasModelLoaded(hash)) do
      RequestModel(hash)
      Wait(50)
    end
    
    local o = CreateObject(hash, v.pos.x, v.pos.y, v.pos.z, false, false)
  
    PlaceObjectOnGroundProperly(o)
    SetEntityCollision(o, true, true)
    SetEntityHeading(o, v.heading)
    SetModelAsNoLongerNeeded(hash)
  end
end

function doPlaneCfRefuel()
  refuelTime.cur = 0

  Citizen.CreateThread(function()
    while (refueling) do
      Wait(1000)

      refuelTime.cur = refuelTime.cur + 1000

      if (refuelTime.cur >= refuelTime.max) then
        refueling = false
        dustfuel = 100
      end
    end
  end)
end

function airspaceTimeout()
  local ooa = 0
  local ooamax = 120000
  
  Citizen.CreateThread(function()
    while (outOfAirspace) do
      Wait(1000)
      ooa = ooa + 1000

      if (ooa > ooamax) then
        outOfAirspace = false
        
        local model = GetEntityModel(jobplane)
        local mname = GetDisplayNameFromVehicleModel(model)

        TriggerServerEvent("bms:aviation:ooaAlert", ooa, mname)
        exports.pnotify:SendNotification({text = "You have ran out of fuel due to a fuel leak."})
        TriggerEvent("bms:fuel:fuelLevel", 0.0)
      end
    end
  end)
end

AddEventHandler("bms:char:charLoggedIn", function()
  spawnCdProps()
end)

RegisterNetEvent("bms:aviation:setDusterSpots")
AddEventHandler("bms:aviation:setDusterSpots", function(data)
  if (data) then
    dusterspots = data.dusterspots
    dustfields = data.dustfields
    airspace = data.airspace
  end
end)

RegisterNetEvent("bms:aviation:startSmoke")
AddEventHandler("bms:aviation:startSmoke", function(netid)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local ent = NetToVeh(netid)

  if (ent ~= 0) then
    local vpos = GetEntityCoords(ent)
    local dist = #(pos - vpos)

    if (dist < 500) then
      Citizen.CreateThread(function()      
        while (not HasNamedPtfxAssetLoaded("core")) do
          RequestNamedPtfxAsset("core")
          Wait(10)
        end

        UseParticleFxAssetNextCall("core")
        local sm1 = StartParticleFxLoopedOnEntity("veh_vent_heli_anh", ent, -3.84, 0.1, -0.55, 0, 0, 0, smokesize, 0, 0, 0)
        SetParticleFxLoopedColour(sm1, 1.0, 1.0, 1.0)
        UseParticleFxAssetNextCall("core")
        local sm2 = StartParticleFxLoopedOnEntity("veh_vent_heli_anh", ent, 3.0, 0.1, -0.55, 0, 0, 0, smokesize, 0, 0, 0)
        SetParticleFxLoopedColour(sm2, 1.0, 1.0, 1.0)
        
        SetTimeout(smoketimeout, function()
          StopParticleFxLooped(sm1)
          StopParticleFxLooped(sm2)
        end)
      end)
    end
  end
end)

--[[RegisterNetEvent("bms:aviation:psmoke")
AddEventHandler("bms:aviation:psmoke", function()
  local nid = NetworkGetNetworkIdFromEntity(jobplane)

  TriggerServerEvent("bms:aviation:startSmoke", nid)
end)]]

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if (#dusterspots > 0) then
      if (#planeblips == 0) then
        setupPlaneBlips()
      end

      for _,v in pairs(dusterspots) do
        local dist = #(pos - v.marker)

        if (dist < 40) then
          DrawMarker(1, v.marker.x, v.marker.y, v.marker.z - 1.000001, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.15, 120, 255, 70, 50, 0, 0, 0, 0, 0, 0, 0)

          if (dist < 0.6) then
            draw3DTextGlobal(v.marker.x, v.marker.y, v.marker.z + 0.2125, "Press ~b~[E]~w~ to get a crop duster aircraft.", 0.37)

            if (isGameControlPressed(1, 38)) then
              if (not spawnblock) then
                if (jobplane) then
                  local jpos = GetEntityCoords(jobplane)

                  exports.pnotify:SendNotification({text = "You already have a job plane.  It has been marked on your GPS."})
                  SetNewWaypoint(jpos.x, jpos.y)
                else
                  spawnblock = true
                  curfield.index = 1

                  if (curfield.waypoint ~= 0) then
                    RemoveBlip(curfield.waypoint)
                  end

                  jobplane = spawnVehicle(v.psp.pos, v.psp.heading, "duster", "bms:aviation:planeSpawned")
                  spawnblock = false
                end
              end
            end
          end
        end
      end
    end

    if (jobplane and jobplane ~= 0) then
      local vbh = GetVehicleBodyHealth(jobplane)
      local veh = GetVehicleEngineHealth(jobplane)
      local inplane = GetPedInVehicleSeat(jobplane, -1) == ped
      
      if (inplane and airspace) then
        if (debugDrawFields.active) then
          DrawMarker(1, airspace.origin.x, airspace.origin.y, airspace.origin.z - 1.000001, 0, 0, 0, 0, 0, 0, airspace.radius, airspace.radius, 50.0, 255, 0, 0, 50, 0, 0, 0, 0, 0, 0, 0)
        end

        local dist = #(pos - airspace.origin)

        if (dist > (airspace.radius / 2)) then
          drawPlaneText("~r~You are out of the AIRSPACE for this job.  Turn around immediately!", 0.475, 0.85)
          
          if (not outOfAirspace) then
            outOfAirspace = true
            airspaceTimeout()
          end
        end

        if (outOfAirspace and dist < (airspace.radius / 2)) then
          outOfAirspace = false
        end
      end

      if (vbh <= 0 and veh == -4000) then
        jobplane = nil
        setJobPlane(nil)
        exports.pnotify:SendNotification({text = "Your aircraft has been completely destroyed.  The FAA and Emergency services have been notified."})
        TriggerServerEvent("bms:aviation:planeDestroyed")
        
        if (curfield.waypoint) then
          RemoveBlip(curfield.waypoint)
        end
      else
        if (returnPlane) then
          if (curfield.waypoint == 0) then
            curfield.waypoint = createWaypoint(returnSpot.pos, 69, true, false)
          end
        end
        
        if (inplane) then
          if (refueling) then
            TaskLeaveVehicle(ped, jobplane, 1)
          else
            drawPlaneHud()
            local field = dustfields[curfield.index]
            local dist = #(pos - field.pos)

            if (not curfield.waypoint or curfield.waypoint == 0) then
              curfield.waypoint = createWaypoint(field.pos, 46, true, false)
            end

            if (dist < 80) then
              DrawMarker(1, field.pos.x, field.pos.y, field.pos.z - 1.000001, 0, 0, 0, 0, 0, 0, field.radius, field.radius, 5.0, 0, 180, 255, 50, 0, 0, 0, 0, 0, 0, 0)

              if (dist <= field.radius / 2) then
                drawPlaneText("Press ~b~[X]~w~ to dust the field below you.")

                if (isGameControlPressed(1, 73)) then
                  if (dustfuel > 10) then
                    -- do dusting and assign next field
                    local nid = NetworkGetNetworkIdFromEntity(jobplane)
                    TriggerServerEvent("bms:aviation:dustComplete", nid)
                    dustfuel = dustfuel - 10

                    RemoveBlip(curfield.waypoint)
                    curfield.index = curfield.index + 1
                    field = dustfields[curfield.index]

                    if (curfield.index > #dustfields) then
                      curfield.index = 1
                      curfield.waypoint = 0
                      returnPlane = true
                    else
                      curfield.waypoint = createWaypoint(field.pos, 46, true, false)
                    end
                  else
                    exports.pnotify:SendNotification({text = "You are out of chemical fuel.  You need to fill up your chemical tanks at an airfield."})
                  end
                end
              end
            end
          end

          local dist = #(pos - returnSpot.pos)

          if (dist < 40) then
            DrawMarker(1, returnSpot.pos.x, returnSpot.pos.y, returnSpot.pos.z - 1.000001, 0, 0, 0, 0, 0, 0, 5.2, 5.2, 0.15, 240, 70, 70, 50, 0, 0, 0, 0, 0, 0, 0)

            if (dist < 2.6) then
              draw3DTextGlobal(returnSpot.pos.x, returnSpot.pos.y, returnSpot.pos.z + 0.2125, "Press ~b~[E]~w~ to return your aircraft.", 0.37)

              if (isGameControlPressed(1, 38)) then
                returnPlane = false

                exports.vehicles:unregisterPulledVehicle(jobplane)
                local plate = GetVehicleNumberPlateText(jobplane)
                TriggerServerEvent("bms:vehicles:unregisterJobVehicle", plate)
                TriggerServerEvent("bms:aviation:returnPlane")
                exports.vehicles:deleteCar(jobplane)

                jobplane = nil
                setJobPlane(nil)
                RemoveBlip(curfield.waypoint)
                curfield.index = 1
              end
            end
          end
        end

        for _,v in pairs(dustFuelSpots) do
          local dist = #(pos - v.pos)
          local ppos = GetEntityCoords(jobplane)
          local pdist = #(pos - ppos)

          if (dist < 40) then
            DrawMarker(27, v.pos.x, v.pos.y, v.pos.z, 0, 0, 0, 0, 0, 0, 6.2, 6.2, 1.1, 255, 180, 50, 50, 0, 0, 0, 1, 0, 0, 0)

            if (dist < 7.6) then
              if (pdist < 10.0) then
                draw3DTextGlobal(v.pos.x, v.pos.y, v.pos.z + 0.2125, "Press ~b~[E]~w~ to fuel your chemical tanks.", 0.37)

                if (not refueling) then
                  if (isGameControlPressed(1, 38)) then
                    refueling = true
                    doPlaneCfRefuel()
                  end
                end
              else
                draw3DTextGlobal(v.pos.x, v.pos.y, v.pos.z + 0.2125, "Your aircraft is too far away from the tanks to fuel it.", 0.37)
              end
            end
          end
        end
      end
    else
      outOfAirspace = false
    end

    if (jobplane and refueling) then
      local ppos = GetEntityCoords(jobplane)

      draw3DTextGlobal(ppos.x, ppos.y, ppos.z, string.format("~b~Refueling: ~w~%s seconds remaining.", math.floor((refuelTime.max - refuelTime.cur) / 1000)), 0.39)
    end

    if (debugDrawFields.active) then
      if (#debugDrawFields.blips == 0) then
        for _,v in pairs(dustfields) do
          local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
    
          SetBlipSprite(blip, 238)
          SetBlipDisplay(blip, 4)
          SetBlipScale(blip, 1.2)
          SetBlipColour(blip, 60)
          SetBlipAsShortRange(blip, true)
          BeginTextCommandSetBlipName("STRING")
          AddTextComponentString("Duster Field")
          EndTextCommandSetBlipName(blip)
          
          table.insert(debugDrawFields.blips, blip)
        end
      end
      
      for _,v in pairs(dustfields) do
        local dist = #(pos - v.pos)

        if (dist < 200) then
          DrawMarker(1, v.pos.x, v.pos.y, v.pos.z, 0, 0, 0, 0, 0, 0, v.radius, v.radius, 2.0, 240, 70, 70, 50, 0, 0, 0, 0, 0, 0, 0)
        end
      end
    end
  end
end)