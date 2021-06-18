local square = math.sqrt
local airportSpots = {}
local planeBlips = {}
local jobplane = nil
local blockspawn = false
local curpickup = 0
local curdropoff = 0
local curcargo = {num = 0, inhand = false, blip = 0}
local loadingCargo = false
local dropOffBlip = 0
local blockdeliver = false
local delivering = false
local returnSpots = {
  {pos = {x = 1743.3154296875, y = 3291.3227539063, z = 41.104335784912}},
  {pos = {x = -942.1025390625, y = -2996.990234375, z = 13.945078849792}}
}

function setupPlaneDeliveryBlips()
  for _,v in pairs(airportSpots) do
    local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
    
    SetBlipSprite(blip, 251)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 15)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Air Delivery")
    EndTextCommandSetBlipName(blip)
    
    table.insert(planeBlips, blip)
  end
end

local getDistance = function(a, b)
  local x, y, z = a.x - b.x, a.y - b.y, a.z - b.z
  
  return square(x * x + y * y + z * z)
end

function getJobNearDropoff(idx)
  local oldpos = airportSpots[idx].cargoDropoff
  local distbias = 75.0

  for i,v in ipairs(airportSpots) do
    if (getDistance(oldpos.pos, v.cargo.pickup) < distbias) then
      return i
    end
  end
end

RegisterNetEvent("bms:aviation:delivery:setDeliverySpots")
AddEventHandler("bms:aviation:delivery:setDeliverySpots", function(data)
  if (data) then
    airportSpots = data.airportSpots
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if (#airportSpots > 0) then
      if (#planeBlips == 0) then
        setupPlaneDeliveryBlips()
      end

      for i,v in ipairs(airportSpots) do
        local dist = Vdist(pos.x, pos.y, pos.z, v.pos.x, v.pos.y, v.pos.z)

        if (dist < 40) then
          if (not jobplane) then
            DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0000001, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.15, 120, 255, 70, 50, 0, 0, 0, 0, 0, 0, 0)
            
            if (dist < 0.6) then
              draw3DTextGlobal(v.pos.x, v.pos.y, v.pos.z + 0.35, "Press ~b~E~w~ to get a delivery aircraft.", 0.38)

              if (isGameControlPressed(1, 38)) then
                blockspawn = true
                curpickup = i
                jobplane = spawnVehicle(v.spos, v.spos.heading, "Mammatus", "bms:aviation:delivery:planeSpawned")
                blockspawn = false
              end
            end
          else -- control the cargo pickup
            if (curcargo.num == 0) then
              loadingCargo = true
              curcargo.num = 1
              curcargo.inhand = false
            end

            if (loadingCargo) then
              local dropcargo = airportSpots[curpickup].cargoDropoff
              local pspot = airportSpots[curpickup]
              local loadcargo = GetOffsetFromEntityInWorldCoords(jobplane, pspot.cargoLoadOffset.x, pspot.cargoLoadOffset.y, pspot.cargoLoadOffset.z)

              drawTextGlobal(string.format("Loading Cargo: %s / %s", curcargo.num, pspot.cargo.numPerTrip), 0.475, 0.865, 0.32)

              if (curcargo.blip == 0) then
                curcargo.blip = createWaypoint(pspot.cargo.pickup, 49, true, false)
              end

              if (not curcargo.inhand) then
                DrawMarker(27, pspot.cargo.pickup.x, pspot.cargo.pickup.y, pspot.cargo.pickup.z - 0.9, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 1.6, 200, 200, 0, 50, 0, 0, 0, 1, 0, 0, 0)
                DrawMarker(20, pspot.cargo.pickup.x, pspot.cargo.pickup.y, pspot.cargo.pickup.z + 0.3, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 200, 200, 0, 50, 1, 0, 0, 1, 0, 0, 0)

                local dist = Vdist(pos.x, pos.y, pos.z, pspot.cargo.pickup.x, pspot.cargo.pickup.y, pspot.cargo.pickup.z)

                if (dist < 0.6) then
                  draw3DTextGlobal(pspot.cargo.pickup.x, pspot.cargo.pickup.y, pspot.cargo.pickup.z, "Press ~b~E~w~ to pick up this cargo.", 0.38)

                  if (isGameControlPressed(1, 38)) then
                    curcargo.inhand = true
                    spawnPropInHand(dropcargo.cargoModel) -- spawn cargo
                  end
                end
              else
                local dist = Vdist(pos.x, pos.y, pos.z, loadcargo.x, loadcargo.y, loadcargo.z + 0.7)

                DrawMarker(27, loadcargo.x, loadcargo.y, loadcargo.z + 0.45, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 1.6, 0, 200, 200, 50, 0, 0, 0, 1, 0, 0, 0)
                DrawMarker(20, loadcargo.x, loadcargo.y, loadcargo.z + 2.0, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 0, 200, 200, 50, 1, 0, 0, 0, 0, 0, 0)

                if (dist < 0.9) then
                  draw3DTextGlobal(loadcargo.x, loadcargo.y, loadcargo.z + 1.5, "Press ~b~E~w~ to put this cargo onto the plane.", 0.38)

                  if (isGameControlPressed(1, 38)) then
                    curcargo.inhand = false
                    spawnPropInHand(dropcargo.cargoModel) -- despawn cargo
                    curcargo.num = curcargo.num + 1

                    if (curcargo.num > pspot.cargo.numPerTrip) then
                      RemoveBlip(curcargo.blip)
                      loadingCargo = false
                      delivering = true
                    end
                  end
                end
              end
            end
          end
        end
      end

      if (jobplane) then
        local vbh = GetVehicleBodyHealth(jobplane)
        local veng = GetVehicleEngineHealth(jobplane)

        if (vbh <= 0 and veng == -4000) then
          jobplane = nil
          curpickup = 0
          curcargo.num = 0
          delivering = false
          curdropoff = 0
          setJobPlane(nil)
          exports.pnotify:SendNotification({text = "Your aircraft has been completely <span style='color: red;'>destroyed</span>.  The FAA and Emergency services have been notified."})
          TriggerServerEvent("bms:aviation:delivery:planeDestroyed")
        end
        
        if (delivering) then
          local dropoff = airportSpots[curpickup].cargoDropoff
          local plpos = GetEntityCoords(jobplane)

          if (dropOffBlip == 0) then
            dropOffBlip = createWaypoint(dropoff.pos, 46, true, false)
            exports.pnotify:SendNotification({text = "Fly to the airport marked in yellow on your GPS to <span style='color: skyblue;'>deliver your cargo</span>."})
          end

          local dist = Vdist(plpos.x, plpos.y, plpos.z, dropoff.pos.x, dropoff.pos.y, dropoff.pos.z)

          if (dist < 40) then
            DrawMarker(1, dropoff.pos.x, dropoff.pos.y, dropoff.pos.z - 1.0000001, 0, 0, 0, 0, 0, 0, 5.0, 5.0, 0.15, 120, 255, 70, 50, 0, 0, 0, 0, 0, 0, 0)

            if (dist < 2.5) then
              if (not blockdeliver) then
                draw3DTextGlobal(dropoff.pos.x, dropoff.pos.y, dropoff.pos.z + 0.25, "Press ~b~E~w~ to deliver the cargo.", 0.38)

                if (isGameControlPressed(1, 38)) then
                  blockdeliver = true
                  exports.management:TriggerServerCallback("bms:aviation:delivery:cargoDelivered", function(data)
                    if (data.success) then
                      exports.pnotify:SendNotification({text = string.format("You have been paid <span style='color: lawngreen;'>$%s</span> for this <span style='color: skyblue;'>cargo delivery</span>.", data.payout)})
                      blockdeliver = false
                      curcargo.num = 0
                      delivering = false
                      curpickup = getJobNearDropoff(curpickup)
                      RemoveBlip(dropOffBlip)
                      dropOffBlip = 0
                    end
                  end, curpickup)
                end
              end
            end
          end
        end

        for _,v in pairs(returnSpots) do
          local plpos = GetEntityCoords(jobplane)
          local dist = Vdist(plpos.x, plpos.y, plpos.z, v.pos.x, v.pos.y, v.pos.z)

          if (dist < 40) then
            DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0000001, 0, 0, 0, 0, 0, 0, 5.0, 5.0, 0.15, 240, 70, 70, 50, 0, 0, 0, 0, 0, 0, 0)
            
            if (dist < 2.5) then
              draw3DTextGlobal(v.pos.x, v.pos.y, v.pos.z + 0.25, "Press ~b~E~w~ to ~b~return your aircraft~w~ to the hangar.", 0.38)
              
              if (isGameControlPressed(1, 38)) then
                exports.vehicles:deleteCar(jobplane)

                curpickup = 0
                curcargo.num = 0
                delivering = false
                setJobPlane(nil)
                jobplane = nil
                curdropoff = 0
                exports.pnotify:SendNotification({text = "Your aircraft has been <span style='color: skyblue;'>returned</span>."})
              end
            end
          end
        end
      else -- fix edge case when plane gets deleted or despawned weird shit happens
        curpickup = 0
        curcargo.num = 0
        delivering = false
        curdropoff = 0
      end
    end
  end
end)