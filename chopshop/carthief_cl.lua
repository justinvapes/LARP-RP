local table_insert = table.insert
local DrawMarker = DrawMarker
local pedspawns = {}
local curjob = {activect = 0, car = {}, carent = nil}
local stealblip = 0
local timeout = {active = false, stime = 0, max = 20000}
local blockkey = false
local pointblips = {}
local vehSpawnPending = {}

local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function drawText(text, x, y, sx, sy, center)
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

local function draw3DText(x, y, z, text, sc)
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

local function getAddressAtPos(pos)
  local street = table.pack(GetStreetNameAtCoord(pos.x, pos.y, pos.z))
  local address

  address = GetStreetNameFromHashKey(street[1])
  
  if (street[2] ~= nil and street[2] ~= "") then
    local street2 = GetStreetNameFromHashKey(street[2])

    if (street2 ~= "") then
      address = address .. " and " .. street2
    end
  end

  return address or "Unknown"
end

local function clearPointBlips()
  for _,v in pairs(pointblips) do
    RemoveBlip(v)
  end

  pointblips = {}
end

local function addPointBlip(pos, bsprite, bcolor, text, shortrange)
  local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
    
  SetBlipSprite(blip, bsprite)
  SetBlipDisplay(blip, 4)
  SetBlipScale(blip, 0.9)
  SetBlipColour(blip, bcolor)
  SetBlipAsShortRange(blip, shortrange)
  
  if (text) then
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
  end
  
  table_insert(pointblips, blip)
end

function addStealBlip(vent)
  if (stealblip) then
    RemoveBlip(stealblip)
    stealblip = 0
  end

  if (vent) then
    stealblip = AddBlipForEntity(vent)
    SetBlipColour(stealblip, 8)
    SetBlipAsShortRange(stealblip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Target Vehicle")
    EndTextCommandSetBlipName(stealblip)
  end
end

function clearJob()
  curjob = {activect = 0, car = {}, carent = nil}
  addStealBlip()
  vehSpawnPending = {}
end

function doTimeout()
  timeout.active = false
end

RegisterNetEvent("bms:chopshop:carthief:setupSpots")
AddEventHandler("bms:chopshop:carthief:setupSpots", function(data)
  if (data) then
    pedspawns = data.pedspawns
    stealspawns = data.stealspawns
    vehicles = data.vehicles

    for _,v in pairs(pedspawns) do
      local ped = exports.jobs:spawnPedGlobal(v.sp.pos, v.sp.heading, v.model, false)

      SetBlockingOfNonTemporaryEvents(ped, true)
      SetPedFleeAttributes(ped, 0, 0)
      v.entity = ped
    end
  end
end)

--[[debugging]]
local ssblips = {}
local stealspawns = {}
RegisterNetEvent("bms:chopshop:carthief:toct")
AddEventHandler("bms:chopshop:carthief:toct", function(index, spawns)
  if (index == "blips") then
    stealspawns = spawns
    if (#ssblips > 0) then
      for _,v in pairs(ssblips) do
        RemoveBlip(v)
      end
    
      ssblips = {}
    end
    
    for _,v in pairs(pedspawns) do
      local blip = AddBlipForCoord(v.sp.pos.x, v.sp.pos.y, v.sp.pos.z)
  
      SetBlipColour(blip, 46)
      SetBlipAsShortRange(blip, true)
      table_insert(ssblips, blip)
    end
  
    for _,v in pairs(stealspawns) do
      local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
  
      SetBlipColour(blip, 48)
      SetBlipAsShortRange(blip, true)
      table_insert(ssblips, blip)
    end
  else
    local sp = pedspawns[tonumber(index)]

    if (sp) then
      TriggerServerEvent("bms:teleporter:teleportToPoint", PlayerPedId(), sp.sp.pos)
      print(getAddressAtPos(GetEntityCoords(PlayerPedId())))
    end
  end
end)

AddEventHandler("onResourceStop", function(res)
  if (res == GetCurrentResourceName()) then
    for _,v in pairs(pedspawns) do
      if (v.entity) then
        DeleteEntity(v.entity)
        DeletePed(v.entity)
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    for i,v in pairs(pedspawns) do
      if (DoesEntityExist(v.entity)) then
        local pedDead = IsPedDeadOrDying(v.entity)
        local ppos = GetEntityCoords(v.entity)
        local dist = #(pos - ppos)

        if (dist < 0.95 and curjob.activect == 0) then
          if (not pedDead) then
            draw3DText(ppos.x, ppos.y, ppos.z + 0.25, "Press ~b~[E]~w~ to speak with the person.", 0.29)

            if (not IsPedFacingPed(v.entity, ped, 45.0)) then
              TaskTurnPedToFaceEntity(v.entity, ped, 1000)
              Wait(1000)
            end
          else
            draw3DText(ppos.x, ppos.y, ppos.z + 0.15, "Your contact is deceased.")
          end

          if (IsControlJustReleased(1, 38) and not curjob.activect > 0) then
            if (not pedDead) then
              TaskTurnPedToFaceEntity(v.entity, ped, 1250)
              
              if (timeout.active) then
                exports.pnotify:SendNotification({text = string.format("<span style='color: aqua; font-style: bold;'>%s</span><br/><br/><span style='font-style: italic;'>There aren't any cars that I need borrowed right now.</span>", v.name), timeout = 8000, layout = "bottomCenter"})
              elseif (not blockkey) then
                blockkey = true
                exports.management:TriggerServerCallback("bms:chopshop:carthief:getVehicle", function(data)
                  if (data and not data.fail) then
                    local model = data.model
                    local spawn = data.spawn
                    local arnd = data.arnd or 1
                    
                    if (model and spawn) then
                      curjob.activect = i
                      vehSpawnPending = {}
                      vehSpawnPending.model = model
                      vehSpawnPending.arnd = arnd
                      vehSpawnPending.spawn = spawn
                      vehSpawnPending.spawned = false
                      vehSpawnPending.inCarInit = false
                      SetNewWaypoint(spawn.pos.x, spawn.pos.y)
                      addStealBlip(veh)
                      TriggerServerEvent("bms:chopshop:carthief:reserveJob", {model = model, plate = plate, address = getAddressAtPos(spawn.pos), ct = i})
                    end

                    blockkey = false
                  else
                    exports.pnotify:SendNotification({text = data.msg, timeout = 8000, layout = "bottomCenter"})
                    blockkey = false
                  end
                end, {ct = i})
              end
            end
          end
        end
      end
    end

    if (not curjob.carent and vehSpawnPending.spawn and not vehSpawnPending.spawned) then
      local dist = #(pos - vehSpawnPending.spawn.pos)

      if (dist < 40) then
        print("spawning vehicle")
        local spawn = vehSpawnPending.spawn

        vehSpawnPending.spawned = true
        ClearAreaOfVehicles(spawn.pos.x, spawn.pos.y, spawn.pos.z, 5.0)

        local hash = GetHashKey(vehSpawnPending.model)

        while (not HasModelLoaded(hash)) do
          RequestModel(hash)
          Wait(10)
        end

        local veh = CreateVehicle(hash, spawn.pos.x, spawn.pos.y, spawn.pos.z, spawn.heading, true, false)
        local netid = VehToNet(veh)
        local vpos = GetEntityCoords(veh)
        local plate = trim(GetVehicleNumberPlateText(veh):lower())

        SetEntityAsMissionEntity(veh, true, true)
        SetVehicleDoorsLocked(veh, 2)
        SetVehicleAlarm(veh, vehSpawnPending.arnd == 1)
        curjob.carent = veh
        curjob.netid = netid
        SetModelAsNoLongerNeeded(hash)
        print("triggering server event")
        TriggerServerEvent("bms:chopshop:carthief:addJobVehicle", {vnetid = netid, plate = plate})
      end
    end

    if (curjob.carent) then
      local failconds = IsPedDeadOrDying(ped)
      local ex = NetworkDoesEntityExistWithNetworkId(curjob.netid)

      if (not ex) then
        clearJob()
        exports.pnotify:SendNotification({text = "The vehicle has been stolen by someone else."}) -- generic error for despawn
      end

      if (failconds) then
        clearJob()
      else
        if (curjob.outcheck) then
          if (not IsPedInVehicle(ped, curjob.carent)) then
            local vclass = GetVehicleClass(curjob.carent)
            local health = {eng = GetVehicleEngineHealth(curjob.carent), body = GetVehicleBodyHealth(curjob.carent)}
            
            exports.vehicles:deleteCar(curjob.carent)

            clearJob()
            TriggerServerEvent("bms:chopshop:carthief:jobComplete", {class = vclass, health = health})
            doTimeout()
          else
            drawText("Get out of the vehicle.", 0.45, 0.94, 0.28, 0.28, true)
          end
        else
          if (IsPedInVehicle(ped, curjob.carent)) then
            if (stealblip ~= 0) then
              addStealBlip()
              clearPointBlips()

              local ret = pedspawns[curjob.activect].ret

              if (pedspawns[curjob.activect].retext) then
                ret = pedspawns[curjob.activect].retext
              end
              
              addPointBlip(ret, 595, 35, "Vehicle Drop", false)
            end

            if (not vehSpawnPending.inCarInit) then
              vehSpawnPending.inCarInit = true
              TriggerServerEvent("bms:chopshop:carthief:vehicleInit")
            end

            local vpos = GetEntityCoords(curjob.carent)
            local ctspot = pedspawns[curjob.activect].ret
            local dist = Vdist(pos.x, pos.y, pos.z, ctspot.x, ctspot.y, ctspot.z)

            if (dist < 35) then
              DrawMarker(27, ctspot.x, ctspot.y, ctspot.z - 0.850001, 0, 0, 0, 0, 0, 0, 4.5, 4.5, 0.2, 200, 200, 0, 50, 0, 0, 0, 1, 0, 0, 0)
              DrawMarker(22, ctspot.x, ctspot.y, ctspot.z - 0.150001, 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.5, 200, 200, 0, 50, 1, 0, 0, 1, 0, 0, 0)

              if (dist < 1.25) then
                SetVehicleUndriveable(curjob.carent, true)
                SetVehicleEngineOn(curjob.carent, false, true)
                TaskLeaveVehicle(ped, curjob.carent, 256)
                clearPointBlips()
                Wait(2000)
                curjob.outcheck = true
                curjob.activect = 0
              end
            end
          else
            if (stealblip == 0) then
              addStealBlip(curjob.carent)
            end

            if (GetVehicleDoorLockStatus(curjob.carent) == 2) then
              if (not IsVehicleWindowIntact(curjob.carent, 0) or not IsVehicleWindowIntact(curjob.carent, 1)) then
                --SetVehicleDoorsLockedForAllPlayers(curjob.carent, false)
                SetVehicleDoorsLocked(curjob.carent, 1)
              end
            end
          end
        end
      end
    end
  end
end)