local aCamActive = false
local cameraSettings = {precision = 5.0, maxPrecision = 10.0, minPrecision = 1.0, origPos = vec3(0, 0, 0)}
local disabledControls = {
  15,     -- Mouse Wheel Up
  14,     -- Mouse Wheel Down
  30,     -- A and D (Character Movement)
  31,     -- W and S (Character Movement)
  21,     -- LEFT SHIFT
  36,     -- LEFT CTRL
  44,     -- Q
  38,     -- E
  71,     -- W (Vehicle Movement)
  72,     -- S (Vehicle Movement)
  59,     -- A and D (Vehicle Movement)
  60,     -- LEFT SHIFT and LEFT CTRL (Vehicle Movement)
  85,     -- Q (Radio Wheel)
  86,     -- E (Vehicle Horn)
}
local offsetRotX = 0.0
local offsetRotY = 0.0
local offsetRotZ = 0.0

RegisterNetEvent("4DIRnNM3YvP22myrQnW0")
AddEventHandler("4DIRnNM3YvP22myrQnW0", function()
  aCamActive = not aCamActive
  local ped = PlayerPedId()

  if (aCamActive) then
    local pos = GetEntityCoords(ped)
    local fov = GetGameplayCamFov()

    cameraSettings.origPos = pos
    cameraSettings.cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos, 0, 0, 0, fov * 1.0)
    SetCamActive(cameraSettings.cam, true)
    RenderScriptCams(true, false, 0, true, false)
    SetEntityCollision(ped, true, true)
    SetEntityVisible(ped, false, false)
  else
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cameraSettings.cam)
    cameraSettings.cam = nil
    exports.teleporter:teleportToPoint(ped, cameraSettings.origPos)
    Wait(500)
    ClearFocus()
    SetEntityVisible(ped, true, true)
    SetEntityCollision(ped, false, false)
  end
end)

function processCameraInput()
  DisableFirstPersonCamThisFrame()
  BlockWeaponWheelThisFrame()

  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local playerRot = GetEntityRotation(ped, 2)
  local rotX = playerRot.x
  local rotY = playerRot.y
  local rotZ = playerRot.z

  for _, control in pairs(disabledControls) do
    DisableControlAction(0, control, true)
  end

  offsetRotX = offsetRotX - (GetDisabledControlNormal(1, 2) * 8.0)
  offsetRotZ = offsetRotZ - (GetDisabledControlNormal(1, 1) * 8.0)

  if (offsetRotX > 90.0) then
    offsetRotX = 90.0
  elseif (offsetRotX < -90.0) then
    offsetRotX = -90.0
  end

  if (offsetRotY > 90.0) then
    offsetRotY = 90.0
  elseif (offsetRotY < -90.0) then
    offsetRotY = -90.0
  end
  
  if (offsetRotZ > 360.0) then
    offsetRotZ = offsetRotZ - 360.0
  elseif (offsetRotZ < -360.0) then
    offsetRotZ = offsetRotZ + 360.0
  end

  local camPos = GetCamCoord(cameraSettings.cam)
  local cX = camPos.x
  local cY = camPos.y
  local cZ = camPos.z

  if (IsDisabledControlPressed(1, 32)) then -- W
    local multCoordY = 0.0
    local multCoordX = 0.0
    
    if ((offsetRotZ >= 0.0 and offsetRotZ <= 90.0) or (offsetRotZ <= 0.0 and offsetRotZ >= -90.0)) then
      multCoordX = offsetRotZ / 90
      multCoordY = 1.0 - (math.abs(offsetRotZ) / 90)
    elseif ((offsetRotZ >= 90.0 and offsetRotZ <= 180.0) or (offsetRotZ <= -90.0 and offsetRotZ >= -180.0)) then
      if (offsetRotZ >= 90.0) then
        multCoordX = 1.0 - (offsetRotZ - 90.0) / 90
      else
        multCoordX = - (1.0 + (offsetRotZ + 90.0) / 90)
      end

      multCoordY = - (math.abs(offsetRotZ) - 90.0) / 90
    elseif ((offsetRotZ >= 180.0 and offsetRotZ <= 270.0) or (offsetRotZ <= -180.0 and offsetRotZ >= -270.0)) then
      if (offsetRotZ >= 180.0) then
        multCoordX = - ((offsetRotZ - 180.0) / 90)
      else
        multCoordX = - (offsetRotZ + 180.0) / 90
      end

      multCoordY = - 1.0 + (math.abs(offsetRotZ) - 180.0) / 90
    elseif ((offsetRotZ >= 270.0 and offsetRotZ <= 360.0) or (offsetRotZ <= -270.0 and offsetRotZ >= -360.0)) then
      if (offsetRotZ >= 270.0) then
        multCoordX = - (1.0 - ((offsetRotZ - 270.0) / 90))
      else
        multCoordX = 1.0 + (offsetRotZ + 270.0) / 90
      end

      multCoordY = (math.abs(offsetRotZ) - 270.0) / 90
    end

    cX = cX - (0.1 * cameraSettings.precision * multCoordX)
    cY = cY + (0.1 * cameraSettings.precision * multCoordY)
  end

  if (IsDisabledControlPressed(1, 33)) then -- S
    local multCoordY = 0.0
    local multCoordX = 0.0
    
    if ((offsetRotZ >= 0.0 and offsetRotZ <= 90.0) or (offsetRotZ <= 0.0 and offsetRotZ >= -90.0)) then
      multCoordX = offsetRotZ / 90
      multCoordY = 1.0 - (math.abs(offsetRotZ) / 90)
    elseif ((offsetRotZ >= 90.0 and offsetRotZ <= 180.0) or (offsetRotZ <= -90.0 and offsetRotZ >= -180.0)) then
      if (offsetRotZ >= 90.0) then
        multCoordX = 1.0 - (offsetRotZ - 90.0) / 90
      else
        multCoordX = - (1.0 + (offsetRotZ + 90.0) / 90)
      end
      
      multCoordY = - (math.abs(offsetRotZ) - 90.0) / 90
    elseif ((offsetRotZ >= 180.0 and offsetRotZ <= 270.0) or (offsetRotZ <= -180.0 and offsetRotZ >= -270.0)) then
      if (offsetRotZ >= 180.0) then
        multCoordX = - ((offsetRotZ - 180.0) / 90)
      else
        multCoordX = - (offsetRotZ + 180.0) / 90
      end

      multCoordY = - 1.0 + (math.abs(offsetRotZ) - 180.0) / 90
    elseif ((offsetRotZ >= 270.0 and offsetRotZ <= 360.0) or (offsetRotZ <= -270.0 and offsetRotZ >= -360.0)) then
      if (offsetRotZ >= 270.0) then
        multCoordX = - (1.0 - ((offsetRotZ - 270.0) / 90))
      else
        multCoordX = 1.0 + (offsetRotZ + 270.0) / 90
      end

      multCoordY = (math.abs(offsetRotZ) - 270.0) / 90
    end

    cX = cX + (0.1 * cameraSettings.precision * multCoordX)
    cY = cY - (0.1 * cameraSettings.precision * multCoordY)
  end

  if (IsDisabledControlPressed(1, 34)) then -- A
    local multCoordY = 0.0
    local multCoordX = 0.0

    if ((offsetRotZ >= 0.0 and offsetRotZ <= 90.0) or (offsetRotZ <= 0.0 and offsetRotZ >= -90.0)) then
      multCoordX = 1.0 - (math.abs(offsetRotZ) / 90)
      multCoordY = - (offsetRotZ / 90)
    elseif ((offsetRotZ >= 90.0 and offsetRotZ <= 180.0) or (offsetRotZ <= -90.0 and offsetRotZ >= -180.0)) then
      if (offsetRotZ >= 90.0) then
        multCoordX = - (offsetRotZ - 90.0) / 90
        multCoordY = - (1.0 - (math.abs(offsetRotZ) - 90.0) / 90)
      else
        multCoordX = (offsetRotZ + 90.0) / 90
        multCoordY = 1.0 - ((math.abs(offsetRotZ) - 90.0) / 90)
      end
    elseif ((offsetRotZ >= 180.0 and offsetRotZ <= 270.0) or (offsetRotZ <= -180.0 and offsetRotZ >= -270.0)) then
      if (offsetRotZ >= 180.0) then
        multCoordX = - (1.0 - ((offsetRotZ - 180.0) / 90))
        multCoordY = (math.abs(offsetRotZ) - 180.0) / 90
      else
        multCoordX = - (1.0 + (offsetRotZ + 180.0) / 90)
        multCoordY = - (math.abs(offsetRotZ) - 180.0) / 90
      end
    elseif ((offsetRotZ >= 270.0 and offsetRotZ <= 360.0) or (offsetRotZ <= -270.0 and offsetRotZ >= -360.0)) then
      if (offsetRotZ >= 270.0) then
        multCoordX = (offsetRotZ - 270.0) / 90
        multCoordY = 1.0 - (math.abs(offsetRotZ) - 270.0) / 90
      else
        multCoordX = - (offsetRotZ + 270.0) / 90
        multCoordY = - (1.0 - ((math.abs(offsetRotZ) - 270.0) / 90))
      end
    end

    cX = cX - (0.1 * cameraSettings.precision * multCoordX)
    cY = cY + (0.1 * cameraSettings.precision * multCoordY)
  end

  if (IsDisabledControlPressed(1, 35)) then -- D
    local multCoordY = 0.0
    local multCoordX = 0.0
    
    if ((offsetRotZ >= 0.0 and offsetRotZ <= 90.0) or (offsetRotZ <= 0.0 and offsetRotZ >= -90.0)) then
      multCoordX = 1.0 - (math.abs(offsetRotZ) / 90)
      multCoordY = - (offsetRotZ / 90)
    elseif ((offsetRotZ >= 90.0 and offsetRotZ <= 180.0) or (offsetRotZ <= -90.0 and offsetRotZ >= -180.0)) then
      if (offsetRotZ >= 90.0) then
        multCoordX = - (offsetRotZ - 90.0) / 90
        multCoordY = - (1.0 - (math.abs(offsetRotZ) - 90.0) / 90)
      else
        multCoordX = (offsetRotZ + 90.0) / 90
        multCoordY = 1.0 - ((math.abs(offsetRotZ) - 90.0) / 90)
      end
    elseif ((offsetRotZ >= 180.0 and offsetRotZ <= 270.0) or (offsetRotZ <= -180.0 and offsetRotZ >= -270.0)) then
      if (offsetRotZ >= 180.0) then
        multCoordX = - (1.0 - ((offsetRotZ - 180.0) / 90))
        multCoordY = (math.abs(offsetRotZ) - 180.0) / 90
      else
        multCoordX = - (1.0 + (offsetRotZ + 180.0) / 90)
        multCoordY = - (math.abs(offsetRotZ) - 180.0) / 90
      end
    elseif ((offsetRotZ >= 270.0 and offsetRotZ <= 360.0) or (offsetRotZ <= -270.0 and offsetRotZ >= -360.0)) then
      if (offsetRotZ >= 270.0) then
        multCoordX = (offsetRotZ - 270.0) / 90
        multCoordY = 1.0 - (math.abs(offsetRotZ) - 270.0) / 90
      else
        multCoordX = - (offsetRotZ + 270.0) / 90
        multCoordY = - (1.0 - ((math.abs(offsetRotZ) - 270.0) / 90))
      end
    end

    cX = cX + (0.1 * cameraSettings.precision * multCoordX)
    cY = cY - (0.1 * cameraSettings.precision * multCoordY)
  end

  if (IsDisabledControlPressed(1, 21)) then -- SHIFT
    cZ = cZ + (0.1 * cameraSettings.precision)
  end

  if (IsDisabledControlPressed(1, 36)) then -- LEFT CTRL
    cZ = cZ - (0.1 * cameraSettings.precision)
  end

  if (IsDisabledControlPressed(1, 44)) then -- Q
    offsetRotY = offsetRotY - (1.0 * cameraSettings.precision)
  end

  if (IsDisabledControlPressed(1, 38)) then -- E
    offsetRotY = offsetRotY + (1.0 * cameraSettings.precision)
  end

  if (IsDisabledControlJustPressed(1, 241)) then -- mouse wheel up
    cameraSettings.precision = cameraSettings.precision + 1
    
    if (cameraSettings.precision > cameraSettings.maxPrecision) then
      cameraSettings.precision = cameraSettings.maxPrecision
    end

    TriggerEvent("chatMessage", "", {255, 255, 255}, ("Camera Precision: %s"):format(cameraSettings.precision))
  elseif (IsDisabledControlJustPressed(1, 242)) then -- mouse wheel down
    cameraSettings.precision = cameraSettings.precision - 1

    if (cameraSettings.precision < cameraSettings.minPrecision) then
      cameraSettings.precision = cameraSettings.minPrecision
    end

    TriggerEvent("chatMessage", "", {255, 255, 255}, ("Camera Precision: %s"):format(cameraSettings.precision))
  end

  SetFocusArea(cX, cY, cZ, 0.0, 0.0, 0.0)
  SetCamCoord(cameraSettings.cam, cX, cY, cZ)
  SetCamRot(cameraSettings.cam, offsetRotX, offsetRotY, offsetRotZ)
  SetEntityCoords(ped, cX - 1.0, cY - 1.0, cZ)
end

Citizen.CreateThread(function()
  while true do
    Wait(1)

    if (aCamActive and cameraSettings.cam) then
      processCameraInput()
    end
  end
end)