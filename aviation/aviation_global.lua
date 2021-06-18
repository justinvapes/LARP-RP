local table_insert = table.insert
local string_format = string.format
local math_floor = math.floor
local fuelSpots = {
  vec3(2012.007, 4734.948, 40.696),
  vec3(-700.682, -1447.375, 4.15),
  vec3(-1540.003, -3189.767, 13.284),
  vec3(4473.719, -4463.500, 3.524)
}
local fuelBlips = {}
local refuelTime = {max = 10000}
local refueling = false
local jobplane = nil

function draw3DTextGlobal(x, y, z, text, sc)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
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

function drawTextGlobal(text, x, y, sx, sy, center)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(sx or 0.32, sy or 0.32)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(center or 1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
end

function isGameControlPressed(cgroup, ckey) -- This is useless
  return IsControlJustReleased(cgroup, ckey)
end

function setJobPlane(plane)
  jobplane = plane
end

function drawFuelingBlips()
  for _,v in pairs(fuelSpots) do
    local blip = AddBlipForCoord(v.x, v.y, v.z)
    
    SetBlipSprite(blip, 361)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 13)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Airplane Refuel")
    EndTextCommandSetBlipName(blip)    
    table_insert(fuelBlips, blip)
  end
end

function spawnVehicle(pos, heading, model, spawnEvent)
  local ped = PlayerPedId()
  local hash = GetHashKey(model)

  while (not HasModelLoaded(hash)) do
    RequestModel(hash)
    Wait(100)
  end

  local plane = CreateVehicle(hash, pos.x, pos.y, pos.z, heading, true, false)

  SetEntityAsMissionEntity(plane, true, true)
  SetModelAsNoLongerNeeded(hash)
  SetVehicleNeedsToBeHotwired(plane, false)
  SetVehicleDoorsLockedForAllPlayers(plane, false)
  exports.vehicles:registerPulledVehicle(plane)
    
  local plate = string.lower(GetVehicleNumberPlateText(plane))

  TriggerServerEvent("bms:vehicles:registerJobVehicle", plate, model)
  TriggerEvent("frfuel:filltankForVeh", plane)
  
  if (spawnEvent) then
    TriggerServerEvent(spawnEvent)
  end
  
  jobplane = plane

  return plane
end

function createWaypoint(pos, color, drawRoute, shortRange) -- colored "waypoints"
  local blip = AddBlipForCoord(pos.x, pos.y, pos.z)

  SetBlipSprite(blip, 8)
  SetBlipDisplay(blip, 4)
  SetBlipScale(blip, 0.95)
  SetBlipColour(blip, color)
  SetBlipAsShortRange(blip, shortRange)

  if (drawRoute) then
    SetBlipRoute(blip, true)
  end

  return blip
end

function spawnPropInHand(model)
  TriggerEvent("bms:devtools:addpropinhand", model, 1, 0.1, 0.02, 0.25, 4.75, 74.75, 124.75, true)
end

function doPlaneRefuel()
  local veh = GetVehiclePedIsIn(PlayerPedId())
  local timeout = GetGameTimer() + refuelTime.max

  refuelTime.start = timeout
  Citizen.CreateThread(function()
    while (refueling) do
      DisableControlAction(0, 75, true)
      Wait(1)

      if (IsDisabledControlJustReleased(1, 75)) then
        exports.pnotify:SendNotification({text = "You can not exit your aircraft while fueling."})
      end

      if (GetGameTimer() >= timeout) then
        refueling = false
        TriggerEvent("frfuel:filltankForVeh", veh)
        exports.pnotify:SendNotification({text = "Your aircraft has been refueled."})
      end
    end
  end)
end

local function isPlayerInAircraft(ped)
  local veh = GetVehiclePedIsIn(ped)

  if (veh ~= 0) then
    local model = GetEntityModel(veh)
    local driver = GetPedInVehicleSeat(veh, -1) == ped
    local isPlaneModel = IsThisModelAHeli(model) or IsThisModelAPlane(model)

    return driver and isPlaneModel
  end
end

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()

    --if (jobplane) then
    if (isPlayerInAircraft(ped)) then
      local pos = GetEntityCoords(ped)
      
      if (refueling) then
        local veh = GetVehiclePedIsIn(ped, true)
        local ppos = GetEntityCoords(veh)

        draw3DTextGlobal(ppos.x, ppos.y, ppos.z, string_format("~b~Refueling: ~w~%s seconds remaining.", math_floor((refuelTime.start - GetGameTimer()) / 1000)), 0.39)
      end
      
      for _, fuelSpot in pairs(fuelSpots) do
        if (#fuelBlips == 0) then
          drawFuelingBlips()
        end

        local dist = #(pos - fuelSpot)
        local veh = GetVehiclePedIsIn(ped)
        local ppos = GetEntityCoords(veh)
        local pdist = #(fuelSpot - ppos)

        if (dist < 40) then
          DrawMarker(27, fuelSpot.x, fuelSpot.y, fuelSpot.z, 0, 0, 0, 0, 0, 0, 8.2, 8.2, 0, 200, 200, 0, 50, 0, 0, 0, 1, 0, 0, 0)

          if (dist < 10.0) then
            if (pdist < 10.0) then
              draw3DTextGlobal(fuelSpot.x, fuelSpot.y, fuelSpot.z + 0.2125, "Press [~b~E~w~] to fuel your aircraft.", 0.37)

              if (not refueling) then
                if (IsControlJustReleased(1, 38)) then
                  if (GetIsVehicleEngineRunning(veh) or IsVehicleEngineStarting(veh)) then
                    exports.pnotify:SendNotification({text = "You must turn your aircraft engine off before refueling."})
                  else
                    refueling = true
                    doPlaneRefuel()
                  end
                end
              end
            else
              draw3DTextGlobal(fuelSpot.x, fuelSpot.y, fuelSpot.z + 0.2125, "Your aircraft is too far away from the pump to fuel it.", 0.37)
            end
          end
        end
      end
    end
  end
end)