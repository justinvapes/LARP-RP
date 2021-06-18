local DrawMarker = DrawMarker
local table_insert = table.insert
local table_remove = table.remove

local lastAnimals = {}
local animMarkers = {}
local sellSpots = {
  {pos = vec3(-390.522, 6050.458, 31.500)}, --/teleport -1534 -422 35
  {pos = vec3(-1121.589, 2697.305, 18.554)},
  {pos = vec3(1113.863, -648.747, 57.749)},
  {pos = vec3(1785.084, 4593.738, 37.683)},
  {pos = vec3(4818.693, -4309.256, 5.520)}
}
local sellMarkers = {}
local sellSpotBlips = {}
local lastSellSpot = 0
local blockinput = false
local skinning = {active = false, cur = 0, time = 7000, dict = "amb@medic@standing@tendtodead@idle_a", anim = "idle_a"}
local knifehash = 2578778090
--[[local huntingzones = {}
local showingzones = {active = false, blips = {}}
local animalCullRange = 120]]
local riflehash = "WEAPON_MARKSMANRIFLE"

function round(num, numDecimalPlaces)
  local mult = 10 ^ (numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function vectorNotZero(v)
  return math.floor(v.x) ~= 0 and math.floor(v.y) ~= 0 and math.floor(v.z) ~= 0
end

function setupHuntingBlips()
  for _,v in pairs(sellSpots) do
    local blip = AddBlipForCoord(v.pos)
  
    SetBlipSprite(blip, 141)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 70)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Meat Sales")
    EndTextCommandSetBlipName(blip)
    
    table_insert(sellSpotBlips, blip)
  end
end

function getAnimalMatch(hash)
  for _,v in pairs(animals) do
    if (v.hash == hash) then
      return v
    end
  end
end

function IsPedAnAnimal(ped)
  local model = GetEntityModel(ped)

  for _,v in pairs(animals) do
    if (v.hash == model) then
      return true
    end
  end
end

function removeEntity(entity)
  local delidx = 0
  
  for i = 1, #lastAnimals do
    if (lastAnimals[i].entity == entity) then
      delidx = i
    end
  end
  
  if (delidx > 0) then
    table_remove(lastAnimals, delidx)
  end
  
  animMarkers = {}
end

function lastAnimalExists(entity)
  for _,v in pairs(lastAnimals) do
    if (v.entity == entity) then
      return true
    end
  end
end

function drawMarker(entity, rpos, dist)
  if (dist < 40) then
    DrawMarker(20, rpos.x, rpos.y, rpos.z + 0.5, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 200, 200, 0, 50, 1, 0, 2, 1, 0, 0, 0)
  end
end

function handleDecorator(animal)
  if (DecorExistOn(animal, "lastshot")) then
    DecorSetInt(animal, "lastshot", GetPlayerServerId(PlayerId()))
  else
    DecorRegister("lastshot", 3)
    DecorSetInt(animal, "lastshot", GetPlayerServerId(PlayerId()))
  end
end

function isKillMine(animal)
  if (DecorExistOn(animal, "lastshot")) then
    local aid = DecorGetInt(animal, "lastshot")
    local id = GetPlayerServerId(PlayerId())

    return aid == id
  end
end

function doSkinAnimation(data, entity)
  local ped = PlayerPedId()
  local isSkinning = true

  skinning.cur = 0
  SetCurrentPedWeapon(ped, knifehash, true)

  while (not HasAnimDictLoaded(skinning.dict)) do
    RequestAnimDict(skinning.dict)
    Wait(10)
  end

  TaskPlayAnim(ped, skinning.dict, skinning.anim, 8.0, -8, -1, 1, 0, 0, 0, 0)
  RemoveAnimDict(skinning.dict)

  Citizen.CreateThread(function()
    while (isSkinning) do
      Wait(1000)

      skinning.cur = skinning.cur + 1000

      if (skinning.cur >= skinning.time) then
        ApplyPedDamagePack(entity, "BigHitByVehicle", 100, 100) -- These dont show up very well on animals because the fur obscures it, unfortunately
        -- Damage Packs: https://gist.github.com/alexguirre/f3f47f75ddcf617f416f3c8a55ae2227
        removeEntity(entity)
        exports.management:TriggerServerCallback("bms:hunting:skinningComplete", function(ret)
          exports.pnotify:SendNotification({text = string.format("You have received some %s.", data.item)})
          ClearPedTasks(ped)
          animMarkers = {}
          skinning.active = false
        end, data.item)
        isSkinning = false
      end
    end
  end)
end

--[[function getRandomSpotsForRadius(p, rad, spotcount, cb)  
  Citizen.CreateThread(function()
    local spawns = {}
    local watermats = {435688960, -1136057692, -273490167, 909950165}

    for i = 1, spotcount do
      local notfound = true
      
      while (notfound) do
        local pos = {x = p.x, y = p.y, z = p.z}
      
        local rndx = GetRandomFloatInRange(-rad, rad)
        Wait(1000)
        local rndy = GetRandomFloatInRange(-rad, rad)

        pos.x = pos.x + rndx
        pos.y = pos.y + rndy
        pos.z = pos.z + 1000.0
      
        local gr,posZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z)
        
        if (gr) then
          local rayh = CastRayPointToPoint(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z - 55.0, 1, 0, 0) -- ray shot downward from offset to detect water in front
          local _,_,_,_,matunder,_ = GetShapeTestResultIncludingMaterial(rayh)
          local inwater = false

          for _,v in pairs(watermats) do
            if (matunder == v) then
              inwater = true
              break
            end
          end
                
          if (not inwater) then          
            spawns[i] = {pos = vec3(pos.x, pos.y, posZ), heading = heading}
            print(string.format("animal spawn position found and added >> %s", exports.devtools:dump(spawns[i])))
            notfound = false
          end
        --else
          --print(string.format("ground not found.."))
        end
      end
    end

    if (cb) then
      print(string.format("returning %s", exports.devtools:dump(spawns)))
      cb({spawns = spawns})
    end
  end)
end]]

--[[local huntingZoneTriggerIn = function(data)
  print(string.format("TRIGGER in: %s, %s [%s]", data.pos, data.radius, data.volid))
  
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local zone = huntingzones[data.exdata]
  
  getRandomSpotsForRadius(data.pos, data.radius, zone.maxAnimalsThisZone, function(sdata)
    if (not sdata) then
      print("getRandomSpotForRadius >> Failed to get spawn point/heading.")
      return
    end
    
    exports.management:TriggerServerCallback("bms:hunting:trySpAnimal", function(rdata)
      if (rdata and rdata.animalsSpawned) then
        for _,netid in pairs(rdata.animalsSpawned) do
          local ex = NetworkDoesEntityExistWithNetworkId(netid)

          if (ex) then
            local aped = NetworkGetEntityFromNetworkId(netid)
            local timeout = 0
            local timeoutmax = 3

            Citizen.CreateThread(function()
              while (not DoesEntityExist(aped) and timeout < timeoutmax) do
                Wait(1000)
                timeout = timeout + 1
              end

              if (not DoesEntityExist(aped)) then
                print("hunting_client.lua >> Entity handle timed out.")
              end

              SetEntityAsMissionEntity(aped, true, true)
              TaskWanderStandard(aped, 10.0, 10)
              SetPedKeepTask(aped, true)
              SetPedFleeAttributes(aped, 1, false)
              print(string.format("hunting_client.lua >> spawned entity %s", aped))
            end)
          else
            print(string.format("hunting_client.lua >> Network Entity not found for wander standard [%s].", netid))
          end
        end
      end
    end, {pos = pos, spawns = sdata.spawns})
  end)
end]]

--[[local huntingZoneTriggerOut = function(data)
  print(string.format("TRIGGER out: %s, %s [%s]", data.pos, data.radius, data.volid))
end]]

RegisterNetEvent("bms:jobs:hunting:huntingInit")
AddEventHandler("bms:jobs:hunting:huntingInit", function(data)
  if (data) then
    riflehash = GetHashKey(riflehash)
    --[[huntingzones = data.huntingzones

    for i,v in pairs(huntingzones) do
      exports.baseevents:registerTriggerVolume(v.pos, v.radius, huntingZoneTriggerIn, huntingZoneTriggerOut, i)
    end]]
  end
end)

--[[RegisterNetEvent("bms:hunting:showHuntingZones")
AddEventHandler("bms:hunting:showHuntingZones", function(data)
  if (showingzones.active and #showingzones.blips > 0) then
    for _,v in pairs(showingzones.blips) do
      RemoveBlip(v)
    end

    showingzones.blips = {}
    showingzones.active = false
    return
  end
  
  if (data and data.huntingzones) then
    showingzones.active = true

    for _,v in pairs(data.huntingzones) do
      local bl = AddBlipForRadius(v.pos.x, v.pos.y, v.pos.z, v.radius)

      SetBlipSprite(bl,9)
      SetBlipColour(bl, 6)
      SetBlipAlpha(bl, 150)
      table_insert(showingzones.blips, bl)
    end
  end
end)

RegisterNetEvent("bms:hunting:showHuntingAnimals")
AddEventHandler("bms:hunting:showHuntingAnimals", function(data)
  if (data and data.hz) then
    Citizen.CreateThread(function()
      for _,v in pairs(data.hz) do
        if (v.netanimals) then
          for _,a in pairs(v.netanimals) do
            local ent = NetworkGetEntityFromNetworkId(a.netid)
            local timeout = 0
            local timeoutmax = 3

            while (not DoesEntityExist(ent) and timeout < timeoutmax) do
              Wait(1000)
              timeout = timeout + 1
            end

            if (DoesEntityExist(ent)) then
              AddBlipForEntity(ent)
            end
          end
        end
      end

      exports.pnotify:SendNotification({text = "Hunting animal blips displayed."})
    end)
  end
end)

RegisterNetEvent("bms:hunting:spawnAnimal")
AddEventHandler("bms:hunting:spawnAnimal", function(id)
  if (id) then
    local ped = PlayerPedId()
    local offset = GetOffsetFromEntityInWorldCoords(ped, 0, 5.0, 0)
    local animal = animals[id]
    
    Citizen.CreateThread(function()
      local hash = GetHashKey(animal.model)
    
      RequestModel(hash)
      
      while not HasModelLoaded(hash) do
        Wait(0)
      end
    
      local an = CreatePed(28, hash, offset.x, offset.y, offset.z + 0.0001, 45, true, true)
      SetModelAsNoLongerNeeded(hash)
      --ApplyPedDamagePack(an, "BigHitByVehicle", 100, 100)
    end)
  end
end)

RegisterNetEvent("bms:hunting:deleteAnimalCorpse")
AddEventHandler("bms:hunting:deleteAnimalCorpse", function(netid)
  Citizen.CreateThread(function()
    if (NetworkDoesEntityExistWithNetworkId(netid)) then
      local timeout = 0
      local timeoutmax = 10
      local aped = NetworkGetEntityFromNetworkId(netid)

      while (not DoesEntityExist(aped) and timeout < timeoutmax) do
        Wait(1000)
        timeout = timeout + 1
      end

      if (DoesEntityExist(aped)) then
        timeout = 0
        
        while (not NetworkHasControlOfEntity(aped) and timeout < timeoutmax) do
          NetworkRequestControlOfEntity(aped)
          Wait(1000)
          timeout = timeout + 1
        end

        print(string.format("Deleting hunting animal %s [%s]", aped, netid))
        DeleteEntity(aped)
      end
    end
  end)
end)

RegisterNetEvent("bms:jobs:hunting:updateHuntingAnimals")
AddEventHandler("bms:jobs:hunting:updateHuntingAnimals", function(data)
  if (data and data.huntingzones) then
    huntingzones = data.huntingzones
  end
end)]]

RegisterNUICallback("bms:ginfoClose", function()
  SetNuiFocus(false, false)
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    if (IsAimCamActive()) then
      local _, ent = GetEntityPlayerIsFreeAimingAt(PlayerId(), Citizen.ReturnResultAnyway())
            
      if (ent and not IsEntityDead(ent)) then
        if (IsEntityAPed(ent)) then
          local model = GetEntityModel(ent)
          local animal = getAnimalMatch(model)
          
          if (model and animal) then
            handleDecorator(ent)
            
            if (not lastAnimalExists(ent)) then
              if (#lastAnimals > 10) then
                table_remove(lastAnimals, 1)
              end
              
              local newAnim = {}
              newAnim.entity = ent
              newAnim.data = animal
              table_insert(lastAnimals, newAnim)
            end
          end
        end
      end
    end
    
    for _,v in pairs(animMarkers) do
      local rpos = GetEntityCoords(v.entity)

      DrawMarker(20, rpos.x, rpos.y, rpos.z + 0.5, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 200, 200, 0, 50, 1, 0, 2, 1, 0, 0, 0)

      if (v.dist < 10) then
        local dist = #(pos - rpos)

        if (dist < 1.1) then
          if ((IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) and not skinning.active) then
            skinning.active = true

            local haswep = HasPedGotWeapon(ped, knifehash, false) or GetCurrentPedWeapon(ped, true) == knifehash

            if (haswep) then
              doSkinAnimation(v.data, v.entity)
            else
              exports.pnotify:SendNotification({text = "You need to have a knife in your hand or inventory to skin this animal."})
            end
          end
        end
      end
    end
    
    for _,v in pairs(sellMarkers) do
      DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.15, 255, 180, 50, 50, 0, 0, 2, 0, 0, 0, 0)
        
      if (v.dist < 10) then
        local dist = #(pos - v.pos)

        if (dist < 1.1) then
          draw3DTextGlobal(v.pos.x, v.pos.y, v.pos.z - 0.2, "~w~Press ~b~E~w~ to sell any meat or fish.", 0.3)
          
          if (IsControlJustReleased(0, 38) and not blockinput) then -- E
            blockinput = true
            lastSellSpot = v.idx
            exports.management:TriggerServerCallback("bms:hunting:processHunts", function(ret)
              if (ret and ret.success) then
                SendNUIMessage({showGenericInfo = true, title = "Fish & Meat products sold", data = ret.data})
                SetNuiFocus(true, true)
              else
                exports.pnotify:SendNotification({text = "You do not have any meat products or fish to sell."})
              end
              
              blockinput = false
            end)
          end
        end
      end
    end
        
    if (lastSellSpot > 0) then
      local dist = Vdist(pos, sellSpots[lastSellSpot].x, sellSpots[lastSellSpot].y, sellSpots[lastSellSpot].z)
      
      if (dist > 1.1) then
        lastSellSpot = 0
      end
    end

    local aiming = IsPlayerFreeAiming(PlayerId())
    local _,weapon = GetCurrentPedWeapon(ped, true)

    if (weapon == riflehash) then
      if (aiming) then
        exports.csrp_gamemode:toggleReticule(true)

        local _, aent = GetEntityPlayerIsFreeAimingAt(PlayerId(), Citizen.ReturnResultAnyway())

        if (aent) then
          if (not IsPedAnAnimal(aent) or IsPedAPlayer(aent)) then
            DisableControlAction(0, 24, true)
          end
        end
      else
        exports.csrp_gamemode:toggleReticule(false)
      end
    end
  end
end)

Citizen.CreateThread(function()
  Wait(1000)
  
  if (#sellSpotBlips == 0) then
    setupHuntingBlips()
  end

  while true do
    Wait(1500)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local aMarkers = {}
    local iter = 0

    for i=1,#lastAnimals do
      local rpos = GetEntityCoords(lastAnimals[i].entity)
      local dist = #(pos - rpos)
      
      if (dist < 50 and IsEntityDead(lastAnimals[i].entity) and (lastAnimals[i].myKill or isKillMine(lastAnimals[i].entity))) then
        if (DoesEntityExist(lastAnimals[i].entity)) then
          iter = iter + 1
          aMarkers[iter] = lastAnimals[i]
          aMarkers[iter].dist = dist
        else
          removeEntity(v.entity)
        end
      end
    end

    animMarkers = aMarkers

    local sMarkers = {}
    iter = 0

    for i=1,#sellSpots do
      local dist = #(pos - sellSpots[i].pos)

      if (dist < 65) then
        iter = iter + 1
        sMarkers[iter] = sellSpots[i]
        sMarkers[iter].dist = dist
        sMarkers[iter].idx = i
      end
    end

    sellMarkers = sMarkers

    --[[for _,v in pairs(huntingzones) do
      for _,a in pairs(v.netanimals) do
        local ex = NetworkDoesEntityExistWithNetworkId(a.netid)

        if (ex) then
          local aent = NetworkGetEntityFromNetworkId(a.netid)
          local timeout = 0
          local timeoutmax = 10

          while (not DoesEntityExist(aent) and timeout < timeoutmax) do
            Wait(500)
            timeout = timeout + 1
          end

          if (DoesEntityExist(aent)) then
            local apos = GetEntityCoords(aent)
            local dist = #(pos - apos)
            local vis = IsEntityVisible(aent)

            if (dist < animalCullRange and not vis) then
              SetEntityVisible(aent, true)
              --print(string.format("[%s] Visibility >> true", aent))
            elseif (dist > animalCullRange and vis) then
              SetEntityVisible(aent, false)
              --print(string.format("[%s] Visibility >> false", aent))
            end
          end
        end
      end
    end]]
  end
end)