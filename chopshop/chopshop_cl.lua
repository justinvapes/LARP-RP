local DrawMarker = DrawMarker
local chopSpots = {} -- To be initialized on start
local parts = { 
  door1 = {
    prop = "prop_car_door_01", hash = GetHashKey("prop_car_door_01"), bone = "door_dside_f", index = 0,
    carryanim = {dict = "anim@heists@narcotics@trash", anim = "walk"}, pedbone = 57005, chopped = false,
    chopanim = "WORLD_HUMAN_WELDING", name = "Door", boneIdx = -1
  },
  door2 = {
    prop = "prop_car_door_02", hash = GetHashKey("prop_car_door_02"), bone = "door_pside_f", index = 1,
    carryanim = {dict = "anim@heists@narcotics@trash", anim = "walk"}, pedbone = 57005, chopped = false,
    chopanim = "WORLD_HUMAN_WELDING", name = "Door", boneIdx = -1
  },
  door3 = {
    prop = "prop_car_door_03", hash = GetHashKey("prop_car_door_03"), bone = "door_dside_r", index = 2,
    carryanim = {dict = "anim@heists@narcotics@trash", anim = "walk"}, pedbone = 57005, chopped = false,
    chopanim = "WORLD_HUMAN_WELDING", name = "Door", boneIdx = -1
  },
  door4 = {
    prop = "prop_car_door_04", hash = GetHashKey("prop_car_door_04"), bone = "door_pside_r", index = 3,
    carryanim = {dict = "anim@heists@narcotics@trash", anim = "walk"}, pedbone = 57005, chopped = false,
    chopanim = "WORLD_HUMAN_WELDING", name = "Door", boneIdx = -1
  },
  hood = {
    prop = "prop_car_bonnet_01", hash = GetHashKey("prop_car_bonnet_01"), bone = "bonnet", index = 4,
    carryanim = {dict = "anim@heists@narcotics@trash", anim = "walk"}, pedbone = 57005, chopped = false,
    chopanim = "PROP_HUMAN_BUM_BIN", name = "Hood", boneIdx = -1
  },
  trunk = {
    prop = "prop_cs_cardbox_01", hash = GetHashKey("prop_cs_cardbox_01"), bone = "boot", index = 5,
    carryanim = {dict = "anim@heists@box_carry@", anim = "idle"}, pedbone = 28422, chopped = false,
    chopanim = "PROP_HUMAN_BUM_BIN", name = "Trunk", boneIdx = -1
  },
  radio = {
    prop = "prop_cs_cardbox_01", hash = GetHashKey("prop_cs_cardbox_01"), bone = "dials", index = 6,
    carryanim = {dict = "anim@heists@box_carry@", anim = "idle"}, pedbone = 28422, chopped = false,
    chopanim = "PROP_HUMAN_BUM_BIN", name = "Radio", boneIdx = -1
  }
}
local lastVeh
local isChopping = false
local carryingPart = false
local chopSpot = -1
local blockChop = false
local partEntity = nil
local currPart = -1
local wep_unarmed = GetHashKey("WEAPON_UNARMED")
local chopMarkers = {}
local openDoor = {pos = vec3(927.666, -2328.594, 29.784), openPos = vec3(927.666, -2328.594, 34.118), hash = 515793184}

local function drawText(text)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.3, 0.3)
  SetTextColour(125, 125, 255, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.5, 0.9)
end

function startChop(spot, veh, vehclass)
  local ped = PlayerPedId()

  TriggerServerEvent("bms:chopshop:startChop", spot, veh, vehclass)

  SetVehicleDoorOpen(veh, 0, false, false)
  SetVehicleDoorOpen(veh, 1, false, false)
  SetVehicleDoorOpen(veh, 2, false, false)
  SetVehicleDoorOpen(veh, 3, false, false)
  SetVehicleDoorOpen(veh, 4, false, false)
  SetVehicleDoorOpen(veh, 5, false, false)
  SetVehicleDoorsLockedForAllPlayers(veh, 2)
  SetVehicleUndriveable(veh, true)
  TaskLeaveVehicle(ped, veh, 256)
  SetEntityAsMissionEntity(veh, true, true)
  SetVehicleDoorsLockedForAllPlayers(veh, 2)
end

function updateChop(index) 
  for _,v in pairs(parts) do
    if (v.index == index) then
      v.chopped = true
      break
    end
  end
end

function carryPart(part)
  local ped = PlayerPedId()
  carryingPart = true
  
  partEntity = CreateObject(part.hash, part.pos.x, part.pos.y, part.pos.z, true, true, true)
  
  while (not DoesEntityExist(partEntity)) do
    Wait(50)
  end
  SetEntityCollision(partEntity, false, false)
  PlaceObjectOnGroundProperly(partEntity)
  
  if (part.index >= 5) then
    AttachEntityToEntity(partEntity, ped, GetPedBoneIndex(ped, part.pedbone), 0.0, -0.03, 0.0, 5.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
  else
    AttachEntityToEntity(partEntity, ped, GetPedBoneIndex(ped, part.pedbone), 0.4, 0, 0, 0, 270.0, 60.0, 1, 1, 0, 1, 1, 1)
  end

  ClearPedTasks(ped)

  Citizen.CreateThread(function() -- thread to keep the anim playing

    while (not HasAnimDictLoaded(part.carryanim.dict)) do
      RequestAnimDict(part.carryanim.dict)
      Wait(5)
    end

    while (carryingPart) do
      Wait(50)
  
      if (not IsPlayerDead(PlayerId())) then
        if (not IsEntityPlayingAnim(ped, part.carryanim.dict, part.carryanim.anim, 3)) then
          TaskPlayAnim(ped, part.carryanim.dict, part.carryanim.anim, 8.0, 8.0, -1, 50, 0, false, false, false)
        end
        SetCurrentPedWeapon(ped, wep_unarmed, true)
      else
        DetachEntity(ped, true, false)
        ClearPedTasks(ped)
        endChop("You <font color='#CF3732'>died</font> and the car/part was removed.")
      end
    end

    RemoveAnimDict(part.carryanim.dict)
    ClearPedTasks(ped)
  end)
end

function turnInPart()
  updateChop(currPart)
  --print(exports.devtools:dump(parts))
  local chopDone = true
  local doors = 0
  local radio = 0

  --print(exports.devtools:dump(parts))
  for _,v in pairs(parts) do
    if (v.boneIdx ~= -1) then
      if (not v.chopped) then
        chopDone = false
        break
      else
        if (v.index <= 5) then
          doors = doors + 1
        end

        if (v.index == 6) then
          radio = radio + 1
        end
      end
    end
  end

  if (chopDone) then
    local occupied = false

    for i=-1, GetVehicleMaxNumberOfPassengers(lastVeh) - 1 do
      if (not IsVehicleSeatFree(lastVeh, i)) then
        occupied = true
      end
    end

    if (not occupied) then
      TriggerServerEvent("bms:chopshop:chopDone", chopSpot, doors, radio, GetDisplayNameFromVehicleModel(GetEntityModel(lastVeh)), GetVehicleNumberPlateText(lastVeh):lower())
    else
      endChop("You can't chop cars with others in it.")
    end
    resetParts()
  end
end

function endChop(text)
  local ped = PlayerPedId()
  exports.pnotify:SendNotification({text = text})

  TriggerServerEvent("bms:chopshop:endChop", chopSpot)
  isChopping = false
  carryingPart = false
  chopSpot = -1
  blockChop = false

  if (lastVeh ~= nil) then
    exports.vehicles:deleteCar(lastVeh)
    lastVeh = nil
  end
  if (partEntity ~= nil) then
    DeleteEntity(partEntity)
    if (not IsPedInAnyVehicle(ped, false)) then
      ClearPedTasksImmediately(ped)
    end
  end

  resetParts()
end

function resetParts()
  parts = { 
    door1 = {
      prop = "prop_car_door_01", hash = GetHashKey("prop_car_door_01"), bone = "door_dside_f", index = 0,
      carryanim = {dict = "anim@heists@narcotics@trash", anim = "walk"}, pedbone = 57005, chopped = false,
      chopanim = "WORLD_HUMAN_WELDING", name = "Door", boneIdx = -1
    },
    door2 = {
      prop = "prop_car_door_02", hash = GetHashKey("prop_car_door_02"), bone = "door_pside_f", index = 1,
      carryanim = {dict = "anim@heists@narcotics@trash", anim = "walk"}, pedbone = 57005, chopped = false,
      chopanim = "WORLD_HUMAN_WELDING", name = "Door", boneIdx = -1
    },
    door3 = {
      prop = "prop_car_door_03", hash = GetHashKey("prop_car_door_03"), bone = "door_dside_r", index = 2,
      carryanim = {dict = "anim@heists@narcotics@trash", anim = "walk"}, pedbone = 57005, chopped = false,
      chopanim = "WORLD_HUMAN_WELDING", name = "Door", boneIdx = -1
    },
    door4 = {
      prop = "prop_car_door_04", hash = GetHashKey("prop_car_door_04"), bone = "door_pside_r", index = 3,
      carryanim = {dict = "anim@heists@narcotics@trash", anim = "walk"}, pedbone = 57005, chopped = false,
      chopanim = "WORLD_HUMAN_WELDING", name = "Door", boneIdx = -1
    },
    hood = {
      prop = "prop_car_bonnet_01", hash = GetHashKey("prop_car_bonnet_01"), bone = "bonnet", index = 4,
      carryanim = {dict = "anim@heists@narcotics@trash", anim = "walk"}, pedbone = 57005, chopped = false,
      chopanim = "PROP_HUMAN_BUM_BIN", name = "Hood", boneIdx = -1
    },
    trunk = {
      prop = "prop_cs_cardbox_01", hash = GetHashKey("prop_cs_cardbox_01"), bone = "boot", index = 5,
      carryanim = {dict = "anim@heists@box_carry@", anim = "idle"}, pedbone = 28422, chopped = false,
      chopanim = "PROP_HUMAN_BUM_BIN", name = "Trunk", boneIdx = -1
    },
    radio = {
      prop = "prop_cs_cardbox_01", hash = GetHashKey("prop_cs_cardbox_01"), bone = "interiorlight", index = 6,
      carryanim = {dict = "anim@heists@box_carry@", anim = "idle"}, pedbone = 28422, chopped = false,
      chopanim = "PROP_HUMAN_BUM_BIN", name = "Radio", boneIdx = -1
    }
  }
end

AddEventHandler("bms:chopshop:chopPart", function(part)
  local ped = PlayerPedId()
  local chopTime = 12000 --- 12000
  currPart = part.index

  Citizen.CreateThread(function()
    while (blockChop) do
      if (chopTime < 0) then
        SetVehicleDoorBroken(lastVeh, part.index, true)
        ClearPedTasksImmediately(ped)
        exports.jobs:hideProgressBar()
        blockChop = false
        carryPart(part)
      else   
        if (not IsPlayerDead(PlayerId())) then
          if (not IsPedActiveInScenario(ped)) then
            TaskStartScenarioInPlace(ped, part.chopanim, 0, true)
          end
        else
          ClearPedTasks(ped)
          endChop("You <font color='#CF3732'>died</font> and the car/part was removed.")
        end

        exports.jobs:showProgressBar("Cutting off the " .. part.name, 12, chopTime / 1000)
        chopTime = chopTime - 1000
      end
      Wait(1000)
    end
  end)
end)

RegisterNetEvent("bms:chopshop:carTurnedIn")
AddEventHandler("bms:chopshop:carTurnedIn", function(data)
	if (data.text) then
		exports.pnotify:SendNotification({text = data.text})

		if (data.allow) then
      isChopping = false
      carryingPart = false
      chopSpot = -1
      blockChop = false
    
      if (lastVeh ~= nil) then
        exports.vehicles:deleteCar(lastVeh)
        lastVeh = nil
      end
      if (partEntity ~= nil) then
        DeleteEntity(partEntity)
        ClearPedTasksImmediately(ped)
      end
		end
	end
end)

RegisterNetEvent("bms:chopshop:syncSpots")
AddEventHandler("bms:chopshop:syncSpots", function(chopspots)
  chopSpots = chopspots
end)

Citizen.CreateThread(function()
	while true do
    Wait(1)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    --print(json.encode(chopSpots))

    -- Debug for drawing markers
    --[[for _,v in pairs(chopSpots) do
      DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.2, 0, 0, 0, 0, 0, 0, 3.5, 3.5, 0.45, 200, 0, 0, 155, 0, 0, 0, 0, 0, 0, 0)
      DrawMarker(1, v.returnpos.x, v.returnpos.y, v.returnpos.z - 1.2, 0, 0, 0, 0, 0, 0, 0.95, 0.95, 0.4, 0, 200, 0, 155, 0, 0, 0, 0, 0, 0, 0)
    end]]

    for _,v in pairs(chopMarkers) do
      if (v.inUse == -1 and not blockChop and not isChopping) then
        DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.2, 0, 0, 0, 0, 0, 0, 3.5, 3.5, 0.45, 200, 0, 0, 120, 0, 0, 0, 0, 0, 0, 0)
        
        if (v.dist < 15) then
          local dist = #(pos - v.pos)

          if (dist < 3.35) then
            local veh = GetVehiclePedIsIn(ped, false)
            
            if (veh and (GetPedInVehicleSeat(veh, -1) == ped)) then
              drawText("~w~Press ~b~E~w~ to start chopping this car~w~.")
              if (IsControlJustReleased(1, 38) and not isChopping) then -- E pressed
                local vclass = GetVehicleClass(veh)

                if (not (vclass == 8 or vclass == 13 or vclass == 14 or vclass == 15 or vclass == 16 or vclass == 18)) then
                  local occupied = false

                  for i=0, GetVehicleMaxNumberOfPassengers(veh) - 1 do
                    if (not IsVehicleSeatFree(veh, i)) then
                      occupied = true
                    end
                  end

                  if (not occupied) then
                    local plate = GetVehicleNumberPlateText(veh):lower()

                    exports.management:TriggerServerCallback("bms:chopshop:checkChop", function(data)
                      if (data.ret) then
                        startChop(v.idx, veh, vclass)
                        Wait(1000)
                        lastVeh = veh
                        isChopping = true
                        chopSpot = v.idx
                      else
                        if (data.msg) then
                          exports.pnotify:SendNotification({text = data.msg})
                        else
                          exports.pnotify:SendNotification({text = "The chop shop is still breaking down the rest of the other car."})
                        end
                      end
                    end, {plate = plate})
                  else
                    exports.pnotify:SendNotification({text = "You can't chop a car while someone is sitting in it."})
                  end
                else
                  exports.pnotify:SendNotification({text = "The chop shop doesn't want this car."})
                end
              end
            end
          end
        end
      elseif (v.inUse ~= -1 and chopSpot == v.idx) then
        local dist = #(pos - v.returnpos)
        if (dist < 20) then
          DrawMarker(1, v.returnpos.x, v.returnpos.y, v.returnpos.z - 1.2, 0, 0, 0, 0, 0, 0, 0.95, 0.95, 0.4, 0, 200, 0, 120, 0, 0, 0, 0, 0, 0, 0)

          if (dist < 0.85 and carryingPart) then
            exports.jobs:draw3DTextGlobal(v.returnpos.x, v.returnpos.y, v.returnpos.z, "Press ~b~E~w~ to deliver the part", 0.3)
    
            if (IsControlJustReleased(1, 38)) then -- E pressed
              DeleteEntity(partEntity)
              ClearPedTasksImmediately(ped)
              carryingPart = false
    
              turnInPart()
            end
          end
        elseif (dist > 50) then
          endChop("You moved <font color='#CF3732'>too far</font> from the chop spot and the car/part was removed.")
        end

        if (IsPlayerDead(PlayerId())) then
          endChop("You <font color='#CF3732'>died</font> and the car/part was removed.")
        end
      end
    end

    if (chopSpot ~= -1 and isChopping and not blockChop and not carryingPart) then
      local bonedist = {}
      local part = nil
      local minDist = 0

      for _,v in pairs(parts) do
        if (not v.chopped) then
          local boneIdx = GetEntityBoneIndexByName(lastVeh, v.bone)
          if (boneIdx ~= -1 or boneIdx ~= nil) then
            v.boneIdx = boneIdx
            local partPos = GetWorldPositionOfEntityBone(lastVeh, boneIdx)
            if (partPos) then
              local dist = #(pos - partPos)

              if (dist < 5.0 and (dist < minDist or minDist == 0)) then
                minDist = dist
                part = v
                part.pos = partPos
              end
            end
          end
        end
      end

      if (part ~= nil) then
        if (#(pos.xy - part.pos.xy) < 1.75) then
          exports.jobs:draw3DTextGlobal(part.pos.x, part.pos.y, part.pos.z, string.format("Press ~b~E~w~ to cut off the %s", part.name), 0.3)
          if (IsControlJustReleased(1, 38)) then -- E pressed
            blockChop = true
            TriggerEvent("bms:chopshop:chopPart", part)
          end
        end
      end
    end
	end
end)

Citizen.CreateThread(function()
  while true do
    Wait(2500)

    local pos = GetEntityCoords(PlayerPedId())
    local cMarker = {}
    local iter = 0

    for i=1,#chopSpots do
      local dist = #(pos - chopSpots[i].pos)

      if (dist < 65) then
        iter = iter + 1
        cMarker[iter] = chopSpots[i]
        cMarker[iter].idx = i
        cMarker[iter].dist = dist
      end
    end

    chopMarkers = cMarker

    --[[local doorDist = #(pos - openDoor.pos)

    if (doorDist < 30) then
      local doorObj = GetClosestObjectOfType(openDoor.pos.x, openDoor.pos.y, openDoor.pos.z, 2.0, openDoor.hash, false, 0, 0)
      SetEntityCoords(doorObj, openDoor.openPos)
      FreezeEntityPosition(doorObj, true)
    end]]
  end
end)
