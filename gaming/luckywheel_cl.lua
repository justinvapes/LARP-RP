local DrawMarker = DrawMarker
local gameSettings = {}
local localSettings = {}
local inCasino = false
local wheelSpinning = false
local blockInput = false
local debugging = false

local function draw3DWheelText(x, y, z, text, tscale)
  local onScreen, _x ,_y = GetScreenCoordFromWorldCoord(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, tscale or 0.55 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    SetTextCentre(1)
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(_x, _y)
  end
end

local function doWheelSpin(targetSpinRot, controller)
  local function inRangeOf(val, target, range)
    if (val >= target and val < (target + range)) then
      return true
    elseif (val <= target and val > (target - range)) then
      return true
    end
  end

  Citizen.CreateThread(function()
    local speedIncDec = 0.001
    local speedMax = 2.4
    local speed = 1.8
    local speedInc = true
    local speedDec = false
    local speedWait = {active = false, waitTime = 500, waitStart = 0}
    local targetRotHit = false
    local rotVec = vec3(0, 0, 0)

    wheelSpinning = true
    while (wheelSpinning) do
      if (speedInc and speed < speedMax) then
        speed = speed + speedIncDec

        if (speed > speedMax) then
          speed = speedMax
          speedInc = false
        end
      elseif (speedDec and speed > 0) then
        speed = speed - speedIncDec

        if (speed < 0.2 and not targetRotHit) then -- If we have reports of the wheel spinning past its intended target, this number might need lowered for slower CPUs
          if (not inRangeOf(rotVec.y, targetSpinRot, 0.2)) then
            --print(rotVec.y, targetSpinRot)
            speed = 0.2
          else
            speedIncDec = 0.01
            targetRotHit = true
          end
        end

        if (speed < 0) then
          speed = 0
        end
      elseif (speedDec and speed <= 0) then
        speedDec = false
        speed = 0
        wheelSpinning = false
        if (controller) then
          exports.management:TriggerServerCallback("bms:gaming:luckyWheel:wheelSpinComplete", function(rdata)
            if (rdata.msg) then
              exports.pnotify:SendNotification({text = rdata.msg})
            end
            
            blockInput = false
          end)
          print("Wheel Spin Complete")
        end
      end

      if (not speedInc and not speedDec and not speedWait.active) then
        speedWait.active = true
        speedWait.waitStart = GetGameTimer() + speedWait.waitTime
      end

      if (speedWait.active and GetGameTimer() > speedWait.waitStart) then
        speedWait.active = false
        speedDec = true
      end

      if (speed > 0) then
        rotVec = vec3(0, rotVec.y - speed, 0)

        if (rotVec.y <= 0) then
          rotVec = vec3(0, 359.99, 0)
        end
        
        SetEntityRotation(localSettings.wheelObject, 0.0, rotVec.y, 0.0, 1, true)
      end
      
      Wait(1)
    end
  end)
end

local function finishWheelSpin()
  wheelSpinning = false
end

local function doSpinAnimation()
  local ped = PlayerPedId()
  
  if (not wheelSpinning) then
    wheelSpinning = true

    local animDict = gameSettings.wheelSpinAnimDict.female

    if (IsPedMale(ped)) then
      animDict = gameSettings.wheelSpinAnimDict.male
    end

    local anim = {dict = animDict, anim = "enter_right_to_baseidle"}

    Citizen.CreateThread(function()
      while (not HasAnimDictLoaded(anim.dict)) do
        RequestAnimDict(anim.dict)
        Wait(5)
      end

      local movedToStart = false

      TaskGoStraightToCoord(ped, gameSettings.wheelPedMovePos.x, gameSettings.wheelPedMovePos.y, gameSettings.wheelPedMovePos.z, 1.0, -1, 312.2, 0.0)

      while (not movedToStart) do
        local pos = GetEntityCoords(ped)
        local movePos = gameSettings.wheelPedMovePos

        if (pos.x >= (movePos.x - 0.01) and pos.x <= (movePos.x + 0.01) and pos.y >= (movePos.y - 0.01) and pos.y <= (movePos.y + 0.01)) then -- TODO add a timeout to prevent lock
          movedToStart = true
        end

        Wait(1)
      end

      TaskPlayAnim(ped, anim.dict, anim.anim, 2.0, -2.0, -1, 0, 0)

      while (IsEntityPlayingAnim(ped, anim.dict, anim.anim, 3)) do
        Wait(1)
        DisableAllControlActions(0)
      end

      TaskPlayAnim(ped, anim.dict, "enter_to_armraisedidle", 2.0, -2.0, -1, 0, 0)

      while (IsEntityPlayingAnim(ped, anim.dict, "enter_to_armraisedidle", 3)) do
        Wait(1)
        DisableAllControlActions(0)
      end

      exports.management:TriggerServerCallback("bms:gaming:luckyWheel:doWheelSpin", function(rdata)
        if (rdata.success) then
          TaskPlayAnim(ped, anim.dict, "armraisedidle_to_spinningidle_high", 2.0, -2.0, -1, 0, 0)
          doWheelSpin(rdata.targetRotation, true)
        else
          if (rdata.msg) then
            exports.pnotify:SendNotification({text = rdata.msg})
            wheelSpinning = false
          end
        end
      end)
    end)
  end
end

function loadFloorRotator()
  Citizen.CreateThread(function()
    Wait(1000) -- Wait to fully load rotator platform

    if (gameSettings.vehiclePrize == "" and localSettings.vehicleFloorObject and localSettings.vehicleFloorObject ~= 0) then
      DeleteVehicle(localSettings.vehicleFloorObject)
      return
    end
    
    if (type(gameSettings.vehiclePrize) == "string") then
      gameSettings.vehiclePrize = GetHashKey(gameSettings.vehiclePrize)
    end

    if (localSettings.vehicleFloorObject and localSettings.vehicleFloorObject ~= 0) then
      DeleteVehicle(localSettings.vehicleFloorObject)
    end

    while (not HasModelLoaded(gameSettings.vehiclePrize)) do
      RequestModel(gameSettings.vehiclePrize)
      Wait(5)
    end

    localSettings.vehicleFloorObject = CreateVehicle(gameSettings.vehiclePrize, gameSettings.floorVehPos.x, gameSettings.floorVehPos.y, gameSettings.floorVehPos.z, 0.0)
    
    if (not localSettings.floorPodiumRotator or localSettings.floorPodiumRotator == 0) then
      local flPos = gameSettings.floorPodiumRotator.pos
      local floorRotator = GetClosestObjectOfType(flPos.x, flPos.y, flPos.z, 5.0, GetHashKey(gameSettings.floorPodiumRotator.model), false, false, false)

      if (floorRotator) then
        localSettings.floorPodiumRotator = floorRotator
      end
    end
    
    PlaceObjectOnGroundProperly(localSettings.vehicleFloorObject)
    FreezeEntityPosition(localSettings.vehicleFloorObject, true)
    SetModelAsNoLongerNeeded(gameSettings.vehiclePrize)
    SetVehicleDoorsLocked(localSettings.vehicleFloorObject, 4)
    SetVehicleDirtLevel(localSettings.vehicleFloorObject, 0.0)
    startFloorRotator()
  end)
end

RegisterNetEvent("bms:gaming:luckyWheel:init")
AddEventHandler("bms:gaming:luckyWheel:init", function(data)
  gameSettings = data.gameSettings or {}

  Citizen.CreateThread(function()
    gameSettings.baseWheelModel = GetHashKey(gameSettings.baseWheelModel)
    gameSettings.wheelModel = GetHashKey(gameSettings.wheelModel)

    while (not HasModelLoaded(gameSettings.baseWheelModel)) do
      RequestModel(gameSettings.baseWheelModel)
      Wait(5)
    end

    while (not HasModelLoaded(gameSettings.wheelModel)) do
      RequestModel(gameSettings.wheelModel)
      Wait(5)
    end
    
    localSettings.baseWheelObject = CreateObject(gameSettings.baseWheelModel, gameSettings.baseWheelPos.x, gameSettings.baseWheelPos.y, gameSettings.baseWheelPos.z, false, false, true)
    SetEntityHeading(localSettings.baseWheelObject, 0.0)
    localSettings.wheelObject = CreateObject(gameSettings.wheelModel, gameSettings.wheelPos.x, gameSettings.wheelPos.y, gameSettings.wheelPos.z, false, false, true)
    SetEntityHeading(localSettings.wheelObject, 0.0)

    SetModelAsNoLongerNeeded(gameSettings.baseWheelModel)
    SetModelAsNoLongerNeeded(gameSettings.wheelModel)
  end)
end)

RegisterNetEvent("bms:gaming:inCasino")
AddEventHandler("bms:gaming:inCasino", function(inCas)
  inCasino = inCas
  
  if (inCasino) then
    checkWheelDistances()
    loadFloorRotator()
    
    localSettings.prizeCounterBlip = AddBlipForCoord(gameSettings.prizeCounter.x, gameSettings.prizeCounter.y, gameSettings.prizeCounter.z)

    SetBlipSprite(localSettings.prizeCounterBlip, 276)
    SetBlipColour(localSettings.prizeCounterBlip, 26)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Prize Desk")
    EndTextCommandSetBlipName(localSettings.prizeCounterBlip)
  else
    if (localSettings.vehicleFloorObject and DoesEntityExist(localSettings.vehicleFloorObject)) then
      DeleteVehicle(localSettings.vehicleFloorObject)
      localSettings.vehicleFloorObject = nil
      localSettings.floorPodiumRotator = 0
    end

    if (DoesBlipExist(localSettings.prizeCounterBlip)) then
      RemoveBlip(localSettings.prizeCounterBlip)
    end
  end
end)

RegisterNetEvent("bms:gaming:luckyWheel:refreshVehiclePrize")
AddEventHandler("bms:gaming:luckyWheel:refreshVehiclePrize", function(vehiclePrize)
  if (gameSettings) then
    gameSettings.vehiclePrize = vehiclePrize
  end

  loadFloorRotator()
end)

RegisterNetEvent("bms:gaming:luckyWheel:finishSpin")
AddEventHandler("bms:gaming:luckyWheel:finishSpin", function()
  finishWheelSpin()
end)

RegisterNetEvent("bms:gaming:luckyWheel:debugWheel")
AddEventHandler("bms:gaming:luckyWheel:debugWheel", function()
  debugging = true
  debugWheel()
end)

RegisterNetEvent("bms:gaming:luckyWheel:doClientWheelSpin")
AddEventHandler("bms:gaming:luckyWheel:doClientWheelSpin", function(spinRot)
  if (inCasino and not wheelSpinning) then
    doWheelSpin(spinRot, false)
  end
end)

AddEventHandler("onResourceStop", function(res)
  if (res == GetCurrentResourceName()) then
    if (not localSettings) then return end

    DeleteVehicle(localSettings.vehicleFloorObject)
    DeleteObject(localSettings.wheelObject)
    DeleteObject(localSettings.baseWheelObject)
  end
end)

function startFloorRotator()
  Citizen.CreateThread(function() 
    while (localSettings.vehicleFloorObject) do
      local head = GetEntityHeading(localSettings.vehicleFloorObject)
      
      SetEntityHeading(localSettings.vehicleFloorObject, head - 0.1)

      if (localSettings.floorPodiumRotator and DoesEntityExist(localSettings.floorPodiumRotator)) then
        SetEntityHeading(localSettings.floorPodiumRotator, head - 0.1)
      end

      Wait(5)
    end
  end)
end

function checkWheelDistances()
  Citizen.CreateThread(function()
    while (inCasino) do
      Wait(1)

      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local wheelPos = gameSettings.wheelRegistration
      local distToWheel = #(pos - wheelPos)
      local distToPrizeCounter = #(pos - gameSettings.prizeCounter)

      if (distToWheel < 60) then
        DrawMarker(1, wheelPos.x, wheelPos.y, wheelPos.z - 1, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.34, 0, 150, 25, 35)
        
        if (distToWheel < 0.6) then
          draw3DWheelText(wheelPos.x, wheelPos.y, wheelPos.z + 0.25, ("Pay ~g~$%s~w~ [~b~E~w~] to spin the wheel!"):format(gameSettings.costPerSpin), 0.32)

          if (IsControlJustReleased(1, 38) and not blockInput) then
            blockInput = true
            exports.management:TriggerServerCallback("bms:gaming:checkCanDoSpin", function(rdata)
              if (rdata) then
                if (rdata.success) then
                  doSpinAnimation()
                else
                  exports.pnotify:SendNotification({text = rdata.msg})
                  blockInput = false
                end
              end
            end)
          end
        end
      end

      if (distToPrizeCounter < 60) then
        DrawMarker(1, gameSettings.prizeCounter.x, gameSettings.prizeCounter.y, gameSettings.prizeCounter.z - 1, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.34, 0, 150, 25, 35)

        if (distToPrizeCounter < 0.6) then
          draw3DWheelText(gameSettings.prizeCounter.x, gameSettings.prizeCounter.y, gameSettings.prizeCounter.z + 0.25, "Press [~b~E~w~] to check for prize pickups.", 0.32)

          if (IsControlJustReleased(1, 38) and not blockInput) then
            blockInput = true
            exports.management:TriggerServerCallback("bms:gaming:luckyWheel:prizePickup", function(rdata)
              if (rdata.msg) then
                exports.pnotify:SendNotification({text = rdata.msg})
              end

              blockInput = false
            end)
          end
        end
      end
    end
  end)
end

--[[local debugData = {yRot = 0} -- Used to get wheel radians for prizes
function debugWheel()
  Citizen.CreateThread(function()
    while (debugging) do
      Wait(1)

      if (IsControlPressed(1, 27)) then -- up arrow
        debugData.yRot = debugData.yRot + 0.5
        SetEntityRotation(localSettings.wheelObject, 0.0, debugData.yRot, 0.0, 1, true)
      elseif (IsControlPressed(1, 173)) then -- down arrow
        debugData.yRot = debugData.yRot - 0.5
        SetEntityRotation(localSettings.wheelObject, 0.0, debugData.yRot, 0.0, 1, true)
      end

      if (IsControlJustReleased(1, 38)) then
        local msg = ("Wheel Y Rotation: %s"):format(debugData.yRot)

        print(msg)
        TriggerEvent("chatMessage", "DEBUG", {0, 120, 120}, msg)
      end

      if (IsControlJustReleased(1, 23)) then
        testWheelSpin()
      end
    end
  end)
end]]