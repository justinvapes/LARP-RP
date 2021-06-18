local DrawMarker = DrawMarker

local paraspots = {
  {
    marker = vec3(-1551.015, -2611.079, 13.944), 
    pos = {x = -1558.047, y = -2603.271, z = 13.944, heading = 331.031}, 
    ppos = {x = -1548.529, y = -2605.489, z = 13.944}, 
    taxipos = {x = -1400.899, y = -2322.647, z = 13.944},
    dist = 100
  }
}
local destspots = {
  {
    rstart = {x = 1183.027, y = 3110.222, z = 40.416}, 
    rend = {x = 1657.316, y = 3237.831, z = 40.568}, 
    flyto = {x = 348.669, y = 2720.305, z = 55.848},
    endtaxi = {
      {x = 1726.648, y = 3256.767, z = 41.204},
      {x = 1736.591, y = 3288.222, z = 41.138},
      {x = 1731.472, y = 3309.754, z = 41.223} -- /teleport 1731 3309 41
    }
  }
}
local parablips = {}
local tripblock = false
local lastspot = 0
local myplane
local mypilot
local mydestspot = 1
local taxiing = false
local flying = false
local landing = false
local endtaxi = false
local curtimeout = 0
local maxtimeout = 900000 -- 15 mins
local intimeout = false
local planeidx = 1
local planehashes = {
  {hash = -644710429, model = "cuban800"}
}

function round(num, numDecimalPlaces) -- returns string
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function doesVehicleExistAtPoint(x, y, z)
  local player = PlayerPedId()
  local rayHandle = StartShapeTestRay(x, y, z, x + 10.0, y + 10.0, z, 10, player, 0)
  local a, b, c, d, vehicleHandle = GetShapeTestResult(rayHandle)

  if (vehicleHandle ~= nil) and (DoesEntityExist(vehicleHandle)) then
    return true
  end
  
  return false
end

function drawScreenText(text)
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

function drawParaBlips()
  if (#parablips == 0) then
    for _,v in pairs(paraspots) do
      local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
      
      SetBlipSprite(blip, 94)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 0.85)
      SetBlipColour(blip, 3)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Skydiving / Skytaxi")
      EndTextCommandSetBlipName(blip)
      
      table.insert(parablips, blip)
    end
  end
end

function spawnPlaneAndPilot()
  local spot = paraspots[lastspot]
  local hash = GetHashKey(planehashes[planeidx].model)
  local ped = PlayerPedId()

  Citizen.CreateThread(function()
    RequestModel(hash)

    while (not HasModelLoaded(hash)) do
      Wait(100)
    end

    myplane = CreateVehicle(hash, spot.pos.x, spot.pos.y, spot.pos.z, spot.heading, true, false)

    while (not DoesEntityExist(myplane)) do
      Wait(100)
    end

    SetVehicleOnGroundProperly(myplane)
    SetModelAsNoLongerNeeded(hash)

    local phash = GetHashKey("s_m_m_pilot_01")

    RequestModel(phash)

    while (not HasModelLoaded(phash)) do
      Wait(100)
    end

    mypilot = CreatePed(4, phash, spot.ppos.x, spot.ppos.y, spot.ppos.z, 250.0, true, 1)
  
    while (not DoesEntityExist(mypilot)) do
      Wait(200)
    end

    SetModelAsNoLongerNeeded(phash)
    SetPedIntoVehicle(mypilot, myplane, -1)
    SetPedCanBeDraggedOut(mypilot, false)
    SetPedCanBeTargetted(mypilot, false)
    NetworkRegisterEntityAsNetworked(mypilot)
    NetworkRegisterEntityAsNetworked(myplane)
    SetBlockingOfNonTemporaryEvents(mypilot, true)

    math.randomseed(GetGameTimer())
    mydestspot = math.random(1, #destspots)
    SetVehicleEngineOn(mypilot, true, false, false)

    Wait(100)
    
    local tspot = paraspots[lastspot].taxipos
    
    TaskVehicleDriveToCoord(mypilot, myplane, tspot.x, tspot.y, tspot.z, 45.0, 0, GetHashKey(), 262144, 1.0, true)
    GiveWeaponToPed(ped, GetHashKey("GADGET_PARACHUTE"), 1, 0, false)
    SetPedIntoVehicle(ped, myplane, -2)
    exports.pnotify:SendNotification({text = "You have been given a parachute.  Use <font color='skyblue'>Primary-Attack</font> to deploy it after exiting the aircraft.", timeout = 7000})
    flying = true
    taxiing = true

    while taxiing do
      Wait(1)

      local ppos = GetEntityCoords(myplane)
      local dist = Vdist(ppos.x, ppos.y, ppos.z, tspot.x, tspot.y, tspot.z)

      if (dist < 1) then
        TaskPlaneMission(mypilot, myplane, 0, 0, destspots[mydestspot].flyto.x, destspots[mydestspot].flyto.y, destspots[mydestspot].flyto.z, 4, 160.0, 180.0, 0.0, 2700.0, 2500.0)
        SetPedKeepTask(mypilot, true)
        taxiing = false

        Wait(5000)

        ControlLandingGear(myplane, 1)
      end
    end
  end)
end

function tripTimeout()
  intimeout = true

  Citizen.CreateThread(function()
    while intimeout do
      Wait(1000)

      if (curtimeout < maxtimeout) then
        curtimeout = curtimeout + 1000
      else
        intimeout = false
      end
    end
  end)
end

function doEndTaxi()
  endtaxi = true
  local curtaxispot = 1
  local ppos = GetEntityCoords(myplane)

  --TaskVehicleDriveToCoord(mypilot, myplane, destspots[mydestspot].endtaxi[1].x, destspots[mydestspot].endtaxi[1].y, destspots[mydestspot].endtaxi[1].z, 25.0, 0, GetHashKey(), 262144, 3.0, true)
  TaskVehiclePark(mypilot, myplane, destspots[mydestspot].endtaxi[1].x, destspots[mydestspot].endtaxi[1].y, destspots[mydestspot].endtaxi[1].z, 0, 0, 20.0, 1)
  SetPedKeepTask(mypilot, true)
  
  Citizen.CreateThread(function()
    while (curtaxispot <= #destspots[mydestspot].endtaxi) do
      Wait(1)
      
      ppos = GetEntityCoords(myplane)
      local dist = Vdist(ppos.x, ppos.y, ppos.z, destspots[mydestspot].endtaxi[curtaxispot].x, destspots[mydestspot].endtaxi[curtaxispot].y, destspots[mydestspot].endtaxi[curtaxispot].z)

      if (dist < 3.1) then
        if (curtaxispot == 1) then
          --SetVehicleForwardSpeed(myplane, 0.0)
          Wait(1000)

          local seats = GetVehicleModelNumberOfSeats(GetHashKey(planehashes[planeidx].model))

          for i = 0, seats do
            local sped = GetPedInVehicleSeat(myplane, i)
            TaskLeaveVehicle(sped, myplane, 0)
          end

          Wait(5000)
          curtaxispot = curtaxispot + 1
          TaskVehicleDriveToCoord(mypilot, myplane, destspots[mydestspot].endtaxi[curtaxispot].x, destspots[mydestspot].endtaxi[curtaxispot].y, destspots[mydestspot].endtaxi[curtaxispot].z, 5.0, 0, GetHashKey(), 262144, 3.0, true)
        elseif (curtaxispot == #destspots[mydestspot].endtaxi - 1) then
          curtaxispot = curtaxispot + 1
          --print(string.format("parking at %s", curtaxispot))
          TaskVehiclePark(mypilot, myplane, destspots[mydestspot].endtaxi[curtaxispot].x, destspots[mydestspot].endtaxi[curtaxispot].y, destspots[mydestspot].endtaxi[curtaxispot].z, 0, 0, 20.0, 1)
        elseif (curtaxispot == #destspots[mydestspot].endtaxi) then
          SetVehicleEngineOn(myplane, false, false, false)
          Wait(8000)
          curtaxispot = curtaxispot + 1 -- force out of loop to delete
        else
          --print(string.format("driving to %s", curtaxispot))
          curtaxispot = curtaxispot + 1
          TaskVehicleDriveToCoord(mypilot, myplane, destspots[mydestspot].endtaxi[curtaxispot].x, destspots[mydestspot].endtaxi[curtaxispot].y, destspots[mydestspot].endtaxi[curtaxispot].z, 5.0, 0, GetHashKey(), 262144, 3.0, true)
        end
      end
    end

    --ClearPedTasks(mypilot)
    DeleteEntity(mypilot)
    DeleteVehicle(myplane)
    mypilot = nil
    myplane = nil
    flying = false
    taxiing = false
    landing = false
    endtaxi = false
    lastspot = 0
    print("plane and pilot deleted")
  end)
end

RegisterNetEvent("bms:events:parachuting:reqparachutetrip")
AddEventHandler("bms:events:parachuting:reqparachutetrip", function(data)
  if (data) then
    local success = data.success

    if (success) then
      math.randomseed(GetGameTimer())
      local prand = math.random(1, #planehashes)

      planeidx = prand
      spawnPlaneAndPilot()
      tripTimeout() -- wait 15 minutes on the client session before allowing a new plane
    else
      exports.pnotify:SendNotification({text = data.msg})
      lastspot = 0
      tripblock = false
    end
  end
end)

--[[Citizen.CreateThread(function()
  while true do
    Wait(1)

    -- reissue landing command if the task is lost
    if (mypilot and myplane) then
      while landing do
        Wait(200)

        if (not GetIsTaskActive(mypilot, 482)) then
          TaskPlaneLand(mypilot, myplane, destspots[mydestspot].rstart.x, destspots[mydestspot].rstart.y, destspots[mydestspot].rstart.z, destspots[mydestspot].rend.x, destspots[mydestspot].rend.y, destspots[mydestspot].rend.z)
        end
      end
    end
  end
end)]]

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = playerInfo.playerPedId
    local pos = playerInfo.pos

    --[[ failsafe to prevent piloting the plane ]]
    local curveh = playerInfo.curVeh

    if (curveh and GetEntityModel(curveh) == -644710429) then
      if (GetPedInVehicleSeat(curveh, -1) == ped) then
        TaskLeaveVehicle(ped, curveh, 0)
      end
    end
    --

    for i,v in ipairs(paraspots) do
      if (v.dist < 80) then
        DrawMarker(1, v.marker.x, v.marker.y, v.marker.z - 1.2, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.4, 0, 255, 0, 90, 0, 0, 0, 0, 0, 0, 0)

        if (v.dist < 10) then
          local dist = #(pos - v.marker)
        
          if (dist < 0.6) then
            if (not tripblock) then
              drawScreenText("Press ~b~E~w~ to rent a plane and parachute.  It will cost ~g~$3500~w~ for this trip.")
            
              if (IsControlJustReleased(1, 38)) then
                if (doesVehicleExistAtPoint(v.marker.x, v.marker.y, v.marker.z)) then
                  exports.pnotify:SendNotification({text = "Wait a moment.  There is a vehicle blocking the runway."})
                else
                  tripblock = true
                  lastspot = i
                  TriggerServerEvent("bms:events:parachuting:reqparachutetrip")
                end
              end
            else
              drawScreenText(string.format("You can not rent another plane for another %s minutes.", round(math.ceil(maxtimeout - curtimeout) / 60000)))
            end
          end
        end
      end
    end

    if (flying) then
      local ppos = GetEntityCoords(mypilot)
      local ftdist = Vdist(ppos.x, ppos.y, ppos.z, destspots[mydestspot].flyto.x, destspots[mydestspot].flyto.y, destspots[mydestspot].flyto.z)
      local rdist = Vdist(ppos.x, ppos.y, ppos.z, destspots[mydestspot].rend.x, destspots[mydestspot].rend.y, destspots[mydestspot].rend.z)

      --[[if (not landing and not endtaxi and not taxiing) then
        if (not GetIsTaskActive(mypilot, 454)) then
          --print("resetting Plane Mission task")
          TaskPlaneMission(mypilot, myplane, 0, 0, destspots[mydestspot].flyto.x, destspots[mydestspot].flyto.y, destspots[mydestspot].flyto.z, 4, 160.0, 180.0, 0.0, 2700.0, 2500.0)
        end
      end]]
      
      if (ftdist < 10.0) then
        if (GetLandingGearState(myplane) == 3) then
          ControlLandingGear(myplane, 1)
        end

        landing = true
        TaskPlaneLand(mypilot, myplane, destspots[mydestspot].rstart.x, destspots[mydestspot].rstart.y, destspots[mydestspot].rstart.z, destspots[mydestspot].rend.x, destspots[mydestspot].rend.y, destspots[mydestspot].rend.z)
      end

      if (rdist < 10) then
        landing = false
        doEndTaxi()
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(2500)

    local pos = playerInfo.pos

    if (#parablips == 0) then
      drawParaBlips()
    end

    for i=1,#paraspots do
      paraspots[i].dist = #(pos - paraspots[i].marker)
    end
  end
end)
