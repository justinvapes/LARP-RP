local table_insert = table.insert
local table_remove = table.remove
local DrawMarker = DrawMarker
local aqspots = {
  {
    pos = {x = 16.666681289673, y = 3674.5107421875, z = 39.756481170654}, --/teleport 16.666, 3674.510, 39.756
    spawns = {
      {x = 17.03444480896, y = 3671.7094726563, z = 39.374130249023, heading = 152.71617126465, model = "rebel"},
      {model = "imp_prop_impexp_boxcoke_01", voffset = {x = 0.0, y = 0.0, z = 0.0, heading = 0}},
      {hash = 1728056212, pos = {x = 15.792679786682, y = 3673.48046875, z = 39.762283325195}, heading = 315.314}
    }
  }
}
local anim = {dict = "amb@code_human_wander_idles@male@idle_a", anim = "idle_b_rubnose"}
local cd = false
local blockbuy = false
local mapblips = {}
local exspots = {}
local bdealerenroute = false
local bdealerent = {boat = 0, driver = 0, dest = {}}
local boatprops = {
  {offset = {x = 0.0, y = -9.0, z = 0.9}, model = "ba_prop_battle_rsply_crate_02a"}
}
local cdata = {drnetid = 0, boatnetid = 0, price = 0}
local brickprice = 40000 -- server controlled

local function spawnVehicle(pos, model)
  local hash = GetHashKey(model)
  
  while (not HasModelLoaded(hash)) do
    RequestModel(hash)
    Wait(10)
  end

  local v = CreateVehicle(hash, pos.x, pos.y, pos.z, pos.heading, false, false)
  SetModelAsNoLongerNeeded(hash)

  return v
end

local function spawnObject(pos, model)
  local hash = GetHashKey(model)
  
  while (not HasModelLoaded(hash)) do
    RequestModel(hash)
    Wait(10)
  end

  local o = CreateObject(hash, pos.x, pos.y, pos.z, false, false)
  SetModelAsNoLongerNeeded(hash)

  return o
end

local function spawnDealerPed(pos, heading, hash, net)
  while (not HasModelLoaded(hash)) do
    RequestModel(hash)
    Wait(10)
  end

  local p = CreatePed(4, hash, pos.x, pos.y, pos.z, heading, net)
  
  SetModelAsNoLongerNeeded(hash)

  return p
end

local function loadProps()
  if (#mapblips == 0) then
    for _,v in pairs(aqspots) do
      local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
    
      SetBlipSprite(blip, 501)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 0.9)
      SetBlipColour(blip, 4)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Cocaine Dealer")
      EndTextCommandSetBlipName(blip)
      
      table_insert(mapblips, blip)
    end
  end
  
  Citizen.CreateThread(function()
    local csp = aqspots[1].spawns[1]
    local veh = spawnVehicle(csp, csp.model)
    
    while (not DoesEntityExist(veh)) do
      Wait(10)
    end

    SetVehicleUndriveable(veh, true) -- since it's not networked, lock it up tight
    SetVehicleDoorsLocked(veh, true)
    SetVehicleDoorsLockedForAllPlayers(veh, true)

    csp = aqspots[1].spawns[2]
    local offset = GetOffsetFromEntityInWorldCoords(veh, csp.voffset.x, csp.voffset.y, csp.voffset.z) -- initial offset, brick offset from bone is controlled in AttachEntity below
    local coke = spawnObject(offset, csp.model)
    local trunkbone = GetEntityBoneIndexByName(veh, "boot")
    
    while (not DoesEntityExist(coke)) do
      Wait(10)
    end
    
    AttachEntityToEntity(coke, veh, trunkbone, 0.0, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

    csp = aqspots[1].spawns[3]
    local ped = spawnDealerPed(csp.pos, csp.heading, csp.hash)

    while (not DoesEntityExist(ped)) do
      Wait(10)
    end

    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, 0)
  end)
end

local function getClosestDealer(pos)
  local cldist = 0
  local clped = 0

  for _,v in pairs(dealerpeds) do
    local dpos = GetEntityCoords(v)
    local dist = Vdist(pos.x, pos.y, pos.z, dpos.x, dpos.y, dpos.z)

    if (dist < cldist or cldist == 0) then
      cldist = dist
      clped = v
    end
  end

  return cldist, clped
end

local function spawnDealers()
  for _,v in pairs(cspots) do
    if (v.psp) then
      local ped = spawnDealerPed({x = v.psp.x, y = v.psp.y, z = v.psp.z}, v.psp.heading, -2039072303)
      
      table_insert(dealerpeds, ped)
      SetBlockingOfNonTemporaryEvents(ped, true)
      SetPedFleeAttributes(ped, 0, 0)
    end
  end
end

local function addCocaProp(ped, prop, offx, offy, offz, rotx, roty, rotz)
  if (prop) then
    if (loadedprop) then
      DeleteEntity(loadedprop)
      loadedprop = nil
      ClearPedTasks(ped)
    else
      local mhash = GetHashKey(prop)
  
      while (not HasModelLoaded(mhash)) do
        RequestModel(mhash)
        Wait(10)
      end
      
      local boneidx = GetPedBoneIndex(ped, 57005)
      
      loadedprop = CreateObject(prop, 1729.73, 6403.90, 34.56, true, true, 0)
      AttachEntityToEntity(loadedprop, ped, boneidx, tonumber(offx), tonumber(offy), tonumber(offz), tonumber(rotx), tonumber(roty), tonumber(rotz), false, false, false, false, 2, true)
      SetModelAsNoLongerNeeded(mhash)
    end
  end
end

local function playSyncedAnimation(ped1, ped2, anim, clip, flags, prop)
  Citizen.CreateThread(function()
    while (not HasAnimDictLoaded(anim)) do
      RequestAnimDict(anim)
      Wait(10)
    end

    addCocaProp(ped2, prop, 0.19, 0.0, 0.0, 180.0, 270.0, 0.0)
    
    if (IsEntityPlayingAnim(ped2, anim, clip, 3)) then
      ClearPedSecondaryTask(ped2)
    else
      TaskPlayAnim(ped2, anim, clip, 8.0, -8, -1, flags, 0.0, 0, 0, 0)
    end
    
    if (IsEntityPlayingAnim(ped1, anim, clip, 3)) then
      ClearPedSecondaryTask(ped1)
    else
      TaskPlayAnim(ped1, anim, clip, 8.0, -8, 0.05, flags, 0.0, 0, 0, 0)
    end

    Wait(1500)
    ClearPedSecondaryTask(ped1)
    ClearPedSecondaryTask(ped2)
    RemoveAnimDict(anim)
    addCocaProp(ped2, prop)
  end)
end

local function spawnDealerBoat(data)
  if (data) then
    while (not HasModelLoaded(data.vhash)) do
      RequestModel(data.vhash)
      Wait(10)
    end

    for _,v in pairs(boatprops) do
      local hash = GetHashKey(v.model)
      
      while (not HasModelLoaded(hash)) do
        RequestModel(hash)
        Wait(10)
      end

      local pr = CreateObject(hash, 1000.0, 1000.0, 1000.0, true, false)

      AttachEntityToEntity(pr, boat, 0, v.offset.x, v.offset.y, v.offset.z, v.offset.rx or 0.0, v.offset.ry or 0.0, v.offset.rz or 0.0, 1, 1, 0, 0, 2, 1)
    end

    local boat = CreateVehicle(data.vhash, data.pos.x, data.pos.y, data.pos.z, 1.0, true, false)
    local nid = NetworkGetNetworkIdFromEntity(boat)
    
    SetEntityAsMissionEntity(boat, true, true)
    for i,v in pairs(data.occpeds) do
      local p = spawnDealerPed({x = 1000.0, y = 1000.0, z = 1000.0}, 1.0, v, true)

      TaskWarpPedIntoVehicle(p, boat, i - 2)
    end

    local dr = GetPedInVehicleSeat(boat, -1)
    local ms = GetVehicleModelMaxSpeed(GetEntityModel(boat))

    TaskBoatMission(dr, boat, 0, 0, data.dest.x, data.dest.y, data.dest.z, 4, ms, 786469, -1.0, 7)
    SetBlockingOfNonTemporaryEvents(dr, true)
    bdealerent.boat = boat
    bdealerent.driver = dr
    bdealerent.dest = data.dest
    bdealerent.arriving = true

    return dr, boat
  end
end

local function doBoatHorns()
  Citizen.CreateThread(function()
    local h = GetHashKey("NORMAL")

    --StartVehicleHorn(bdealerent.boat, 1500, h) -- the horn sometimes gets stuck and is incredibly annoying
  end)
end

local function doReturnRoute(dr, boat, route)
  local routeidx = 1
  local sentcmd = false
  
  Citizen.CreateThread(function()
    while (bdealerent.returning and bdealerent.boat ~= 0 and bdealerent.driver ~= 0) do
      Wait(1)

      local bpos = GetEntityCoords(boat)
      local dest = route[routeidx]
      local dist = Vdist(bpos.x, bpos.y, bpos.z, dest.x, dest.y, dest.z)

      --print(dist)

      if (not sentcmd) then
        print(string.format("sending mission: %s, %s, %s, dr: %s, boat: %s", dest.x, dest.y, dest.z, dr, boat))
        
        local ms = GetVehicleModelMaxSpeed(GetEntityModel(boat))
        
        if (routeidx == #route) then
          bdealerent.dest = dest -- flag for cleanup
        end

        TaskBoatMission(dr, boat, 0, 0, dest.x, dest.y, dest.z, 4, ms, 786469, -1.0, 7)
        SetBlockingOfNonTemporaryEvents(dr, true)
        sentcmd = true
      end

      if (dist < 30.0) then
        routeidx = routeidx + 1

        if (routeidx <= #route) then
          sentcmd = false
        end
      end
    end
  end)
end

local function reinitialize()
  if (bdealerent.boat ~= 0 or bdealerent.driver ~= 0) then
    bdealerent.returning = false
    bdealerent.arriving = false
    SetEntityAsMissionEntity(bdealerent.driver, false, false)
    SetEntityAsMissionEntity(bdealerent.boat, false, false)
    Wait(500)
    DeleteEntity(bdealerent.driver)
    DeleteEntity(bdealerent.boat)
    bdealerent.driver = 0
    bdealerent.boat = 0
    bdealerent.dest = {}
    TriggerServerEvent("bms:jobs:cocaine:dealerFinished")
  end
end

local function decayTimeout()
  local dectime = GetGameTimer() + (60000 * 6)
  local act = true
  
  Citizen.CreateThread(function()
    while (act) do
      Wait(1000)

      if (time >= dectime) then
        act = false
        reinitialize()
      end
    end
  end)
end

RegisterNetEvent("bms:jobs:drugdealer:cocaine:actCocaine")
AddEventHandler("bms:jobs:drugdealer:cocaine:actCocaine", function(bp)
  loadProps()
  cd = true

  if (bp) then
    brickprice = bp
  end
end)

RegisterNetEvent("bms:jobs:drugdealer:cocaine:actCEffects")
AddEventHandler("bms:jobs:drugdealer:cocaine:actCEffects", function()
  Citizen.CreateThread(function()
    local ped = PlayerPedId()

    while (not HasAnimDictLoaded(anim.dict)) do
      RequestAnimDict(anim.dict)
      Wait(10)
    end

    TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, -8, -1, 16, 0, 0, 0, 0)
    Wait(4000)
    StopAnimTask(ped, anim.dict, anim.anim, 2.0)
    RemoveAnimDict(anim.dict)
  end)
end)

RegisterNetEvent("bms:jobs:cocaine:spawnDealerBoat")
AddEventHandler("bms:jobs:cocaine:spawnDealerBoat", function(spots)
  if (spots) then
    exspots = spots
  end
  
  math.randomseed(GetGameTimer())
  
  local rnd = math.random(1, #exspots)
  local driver, boat = spawnDealerBoat(exspots[rnd])
  local dnid = NetworkGetNetworkIdFromEntity(driver)
  local bnid = NetworkGetNetworkIdFromEntity(boat)

  print(string.format("NetIDs >> driver: %s, boat: %s", dnid, bnid))
  TriggerServerEvent("bms:jobs:cocaine:dealersSpawned", {drnetid = dnid, boatnetid = bnid, spotidx = rnd})
end)

RegisterNetEvent("bms:jobs:cocaine:endDealerBoat")
AddEventHandler("bms:jobs:cocaine:endDealerBoat", function(data)
  if (data) then
    exspots = data.spots

    local spot = exspots[data.statedata.spotidx]
    local dr = NetToPed(data.statedata.drnetid)
    local boat = NetToVeh(data.statedata.boatnetid)

    print(string.format("LocalIDs >> boat: %s, driver: %s, data: %s", boat, dr, json.encode(data.statedata)))

    if (dr and dr ~= 0 and boat and boat ~= 0) then
      bdealerent.driver = dr
      bdealerent.boat = boat

      if (not NetworkHasControlOfEntity(driver)) then
        NetworkRequestControlOfEntity(driver)
      end

      if (not NetworkHasControlOfEntity(boat)) then
        NetworkRequestControlOfEntity(boat)
      end

      Wait(500)
      
      local ms = GetVehicleModelMaxSpeed(GetEntityModel(boat))
      local dest = spot.pos
      
      bdealerent.dest = dest
      bdealerent.returning = true
      doBoatHorns()
      SetBoatAnchor(boat, false)

      if (not spot.returnroute and not spot.returnroute.x) then
        TaskBoatMission(dr, boat, 0, 0, dest.x, dest.y, dest.z, 4, ms, 786469, -1.0, 7)
        SetBlockingOfNonTemporaryEvents(dr, true)
      else
        local route = spot.returnroute

        table_insert(route, spot.pos)
        doReturnRoute(dr, boat, route)
      end

      decayTimeout()
    else
      print("Error >> bms:jobs:cocaine:endDealerBoat >> Could not find driver/boat entities from NetIDs!")
    end
  end
end)

RegisterNetEvent("bms:jobs:cocaine:takeDealerControl") -- Should resume the action if the host d/cs in the middle of an arrival or return
AddEventHandler("bms:jobs:cocaine:takeDealerControl", function(data)
  print("bms:jobs:cocaine:takeDealerControl")
  
  if (data) then
    local spot = exspots[data.statedata.spotidx]
    local dr = NetToPed(data.statedata.drnetid)
    local boat = NetToVeh(data.statedata.boatnetid)

    if (driver and driver ~= 0 and boat and boat ~= 0) then
      bdealerent.driver = dr
      bdealerent.boat = boat

      if (not NetworkHasControlOfEntity(driver)) then
        NetworkRequestControlOfEntity(driver)
      end

      if (not NetworkHasControlOfEntity(boat)) then
        NetworkRequestControlOfEntity(boat)
      end

      local dest = spot.pos
      local ms = GetVehicleModelMaxSpeed(GetEntityModel(boat))

      bdealerent.driver = dr
      bdealerent.boat = boat
      bdealerent.dest = {}
      bdealerent.dest = dest
      bdealerent.arriving = data.statedata.arriving
      bdealerent.returning = dats.statedata.returning
      TaskBoatMission(dr, boat, 0, 0, dest.x, dest.y, dest.z, 4, ms, 786469, -1.0, 7)
      SetBlockingOfNonTemporaryEvents(dr, true)
    else
      print("Error >> bms:jobs:cocaine:takeDealerControl >> Could not find driver/boat entities from NetIDs!")
    end
  end
end)

RegisterNetEvent("bms:jobs:cocaine:notifyBoatSpawned")
AddEventHandler("bms:jobs:cocaine:notifyBoatSpawned", function(data)
  if (data) then
    --data.drnetid
    --= data.boatnetid
    cdata.drnetid = data.drnetid
    cdata.boatnetid = data.boatnetid
    cdata.drent = NetToPed(data.drnetid)
    cdata.boatent = NetToVeh(data.boatnetid)
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if (cd) then
      local pos = GetEntityCoords(ped)
      
      for _,v in pairs(aqspots) do
        local dist = Vdist(pos.x, pos.y, pos.z, v.pos.x, v.pos.y, v.pos.z)
        if (dist < 50) then
          DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0000001, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 0.15, 200, 60, 60, 105, 0, 0, 0, 0, 0, 0, 0)
          if (dist < 0.55 and not blockbuy) then
            draw3DTextGlobal(v.pos.x, v.pos.y, v.pos.z + 0.25, string.format("Press [~b~E~w~] to purchase a brick of cocaine for $%s.", brickprice), 0.32)
            if (isGameControlPressed(1, 38)) then
              blockbuy = true
              exports.management:TriggerServerCallback("bms:jobs:drugdealer:cocaine:buyCocaine", function(data)
                if (not data.fail) then
                  exports.pnotify:SendNotification({text = "You have purchased a <span style='color: skyblue'>brick of cocaine</span>."})
                else
                  if (data.msg) then
                    exports.pnotify:SendNotification({text = data.msg})
                  end
                end
                blockbuy = false
              end)
            end
          end
        end
      end
    end

    if (bdealerent.boat ~= 0) then
      local bpos = GetEntityCoords(bdealerent.boat)
      local dest = bdealerent.dest
      local dist = Vdist(bpos.x, bpos.y, bpos.z, dest.x, dest.y, dest.z)

      if (dist < 15.0 and bdealerent.arriving) then
        bdealerent.arriving = false
        SetBoatAnchor(bdealerent.boat, true)
        doBoatHorns()
        TriggerServerEvent("bms:jobs:cocaine:dealerArrived")
      elseif (dist < 30.0 and bdealerent.returning) then -- cleanup
        bdealerent.returning = false
        reinitialize()
      end

      local bpos = GetOffsetFromEntityInWorldCoords(bdealerent.boat, 0.0, -9.0, 0.9)

      DrawMarker(1, bpos.x, bpos.y, bpos.z, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 0.15, 200, 60, 60, 100, 0, 0, 0, 0, 0, 0, 0)
    end

    if (cdata and cdata.boatent and cdata.boatent ~= 0) then
      local offset = GetOffsetFromEntityInWorldCoords(cdata.boatent, boatprops[1].offset.x, boatprops[1].offset.y, boatprops[1].offset.z)
      local dist = Vdist(pos.x, pos.y, pos.z, offset.x, offset.y, offset.z)

      if (dist < 2.0) then
        draw3DTextGlobal(offset.x, offset.y, offset.z + 0.25, string.format("~w~Press [~b~E~w~] to purchase some cocaine for %s", cdata.price), 0.26)

        if (isGameControlPressed(1, 38)) then
          exports.management:TriggerServerCallback("bms:jobs:cocaine:purchaseCokeFromBoat", function(data)
            if (data.fail) then
              exports.pnotify:SendNotification({text = data.msg})
            else
              exports.pnotify:SendNotification({text = string.format("You have made a deal for a brick of cocaine.  You paid $%s for it.", cdata.price)})
            end
          end)
        end
      end
    end
  end
end)