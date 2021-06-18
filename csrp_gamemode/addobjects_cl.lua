local objects = {
  -- Route 68 / Great Ocean repair spot
  {pos = vec3(-2214.267, 2309.590, 31.770), prop = "prop_rub_carwreck_14", heading = 200.0},
  {pos = vec3(-2211.893, 2315.215, 31.639), prop = "imp_prop_covered_vehicle_07a", heading = 270.0},
  {pos = vec3(-2211.602, 2311.877, 31.947), prop = "imp_prop_engine_hoist_02a", heading = 234.0},
  {pos = vec3(-2215.743, 2315.085, 31.622), prop = "imp_prop_impexp_parts_rack_03a", heading = 192.0},
  {pos = vec3(-2219.901, 2311.814, 31.582), prop = "prop_rub_carwreck_17", heading = 334.0},
  {pos = vec3(-2218.673, 2308.206, 31.584), prop = "imp_prop_impexp_boxpile_01", heading = 240.0},
  {pos = vec3(-2206.289, 2313.582, 32.098), prop = "prop_rub_carwreck_9", heading = 240.0},
  -- Legion ladders
  {pos = vec3(129.138, -1044.820, 36.313), prop = "v_serv_metro_stationfence", rot = vec3(90.0, 0.0, 250.0)},
  {pos = vec3(163.565, -1061.174, 45.050), prop = "v_serv_metro_stationfence", rot = vec3(90.0, 0.0, 340.0)},
  -- Route 68 Chop
  {pos = vec3(259.764, 2584.919, 43.954), prop = "imp_prop_impexp_parts_rack_01a", heading = 100.0},
  -- Paleto Boat Docks
  {pos = vec3(-654.900, 6224.781, 2.125), prop = "prop_byard_rampold", rot = vec3(0.0, 18.0, 0.0)},
  {pos = vec3(-659.850, 6224.781, 2.125), prop = "prop_byard_rampold", rot = vec3(0.0, 18.0, 0.0)},
  {pos = vec3(-664.800, 6224.781, 2.125), prop = "prop_byard_rampold", rot = vec3(0.0, 18.0, 0.0)},
  {pos = vec3(-669.750, 6224.781, 2.125), prop = "prop_byard_rampold", rot = vec3(0.0, 18.0, 0.0)},
  {pos = vec3(-674.700, 6224.781, 2.125), prop = "prop_byard_rampold", rot = vec3(0.0, 18.0, 0.0)},

  {pos = vec3(-659.850, 6223.273, -5.0), prop = "prop_dock_woodpole4", heading = 0.0},
  {pos = vec3(-659.850, 6226.273, -5.0), prop = "prop_dock_woodpole4", heading = 0.0},
  {pos = vec3(-664.800, 6223.273, -5.0), prop = "prop_dock_woodpole4", heading = 0.0},
  {pos = vec3(-664.800, 6226.273, -5.0), prop = "prop_dock_woodpole4", heading = 0.0},
  {pos = vec3(-669.750, 6223.273, -5.0), prop = "prop_dock_woodpole4", heading = 0.0},
  {pos = vec3(-669.750, 6226.273, -5.0), prop = "prop_dock_woodpole4", heading = 0.0},
  {pos = vec3(-674.700, 6223.273, -5.0), prop = "prop_dock_woodpole4", heading = 0.0},
  {pos = vec3(-674.700, 6226.273, -5.0), prop = "prop_dock_woodpole4", heading = 0.0},
}

Citizen.CreateThread(function()
  while true do
    Wait(1500)

    local pos = GetEntityCoords(PlayerPedId())

    for i=1,#objects do
      local dist = #(pos - objects[i].pos)

      if (dist < 100) then
        if (not objects[i].spawnedProp) then
          local hash = GetHashKey(objects[i].prop)
          RequestModel(hash)
          while (not HasModelLoaded(hash)) do
            Wait(10)
          end
          
          local obj = CreateObject(hash, objects[i].pos, false, true, false)
          while (not DoesEntityExist(obj)) do
            Wait(10)
          end
          FreezeEntityPosition(obj, true)

          if (objects[i].heading) then
            SetEntityHeading(obj, objects[i].heading)
          elseif (objects[i].rot) then
            SetEntityRotation(obj, objects[i].rot, 1, true)
          end
          SetModelAsNoLongerNeeded(hash)
    
          objects[i].spawnedProp = obj
        end
      elseif (objects[i].spawnedProp) then
        DeleteObject(objects[i].spawnedProp)
        objects[i].spawnedProp = nil
      end
    end
  end
end)

AddEventHandler("onResourceStop", function(res)
  if (res == GetCurrentResourceName()) then
    for _,v in pairs(objects) do
      if (v.spawnedProp) then
        DeleteEntity(v.spawnedProp)
      end
    end
  end
end)
