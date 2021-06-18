local selfieAnim = {dict = "cellphone@self", anim = "selfie", flag = 49}
local selfieMode = false
local selfieCam = -1
local cellprophash = GetHashKey("p_amb_phone_01")
local cellCamSettings = {currentFov = 0, fovMax = 50.0, fovMin = 2.0, zoomSpeed = 2.0}
local startFov = 40.0
local showChatOnMessageVal = false
local overlays = {active = 0, strength = 1.0, hashes = {
    {hash = "ArenaEMP", fname = "E.M.P."}, {hash = "ArenaEMP_Blend", fname = "E.M.P. Blend"}, {hash = "CAMERA_BW", fname = "B&W Camera"}, {hash = "CAMERA_secuirity", fname = "Security Cam"},
    {hash = "CAMERA_secuirity_FUZZ", fname = "Security Cam Fuzzy"}, {hash = "NG_filmic04", fname = "Film Noir 1"}, {hash = "NG_filmic06", fname = "Film Noir 2"}, {hash = "OrbitalCannon", fname = "Orbital Cannon"},
    {hash = "REDMIST", fname = "Red Mist"}, {hash = "RemixDrone", fname = "Drone Remix"}, {hash = "eyeINtheSKY", fname = "Eye in the Sky"}, {hash = "heliGunCam", fname = "Gun Camera"}, hash = "mugShot", fname = "Mug Shot"
  }
}
local zoomData = {active = false, increase = false}

function getIsSelfieMode()
  return selfieMode
end

function cancelSelfieMode()
  if (selfieMode) then
    TriggerEvent("bms:comms:phone:selfie", false)
  end
end

function handlePhoneCamZoom(cam, data)
  if (not cam) then return end

  local ped = PlayerPedId()

  if (zoomData.increase) then
    cellCamSettings.currentFov = math.max(cellCamSettings.currentFov - cellCamSettings.zoomSpeed, cellCamSettings.fovMin)
  else
    cellCamSettings.currentFov = math.min(cellCamSettings.currentFov + cellCamSettings.zoomSpeed, cellCamSettings.fovMax)
  end

  local currentFov = GetCamFov(cam)

  if (math.abs(cellCamSettings.currentFov - currentFov) < 0.1) then
    cellCamSettings.currentFov = currentFov
  end
  
  SetCamFov(cam, currentFov + (cellCamSettings.currentFov - currentFov) * 0.05)
end

function cycleFilter(direction)  
  if (direction == 1) then
    overlays.active = overlays.active - 1

    if (overlays.active < 0) then
      overlays.active = #overlays.hashes
    end
  elseif (direction == 2) then
    overlays.active = overlays.active + 1

    if (overlays.active > #overlays.hashes) then
      overlays.active = 0
    end
  end

  if (overlays.active == 0) then
    ClearTimecycleModifier()
    overlays.nameref = "Default"
  else	
    ClearTimecycleModifier()
    SetTimecycleModifier(overlays.hashes[overlays.active].hash)
    overlays.nameref = overlays.hashes[overlays.active].fname
  end

  SendNUIMessage({setFilterInfo = true, filterName = overlays.nameref, filterStrength = overlays.strength})
end

function cycleFilterStrength(direction)
  if (direction == 1) then
    overlays.strength = overlays.strength - 0.05

    if (overlays.strength < 0) then
      overlays.strength = 0
    end
  elseif (direction == 2) then
    overlays.strength = overlays.strength + 0.05

    if (overlays.strength > 1) then
      overlays.strength = 1
    end
  end

  SetTimecycleModifierStrength(overlays.strength)
  SendNUIMessage({setFilterInfo = true, filterName = overlays.nameref, filterStrength = overlays.strength})
end

RegisterNetEvent("bms:comms:phone:selfie")
AddEventHandler("bms:comms:phone:selfie", function(toggle)
  selfieMode = toggle
  SendNUIMessage({selfieModeToggle = true, val = selfieMode})
  
  if (selfieMode) then -- do selfie shit
    local ped = PlayerPedId()
    local cellprop = getAttachedPhoneProp()

    if (not cellprop or cellprop == 0) then
      exports.pnotify:SendNotification({text = "You do not have your phone out."})
      return
    end
    
    while (not HasAnimDictLoaded(selfieAnim.dict)) do
      RequestAnimDict(selfieAnim.dict)
      Wait(50)
    end

    TaskPlayAnim(ped, selfieAnim.dict, selfieAnim.anim, 8.0, -8, -1, selfieAnim.flag)

    local camPos = GetOffsetFromEntityInWorldCoords(cellprop, 0.0, 0.01, 0.25)

    if (selfieCam == -1) then
      selfieCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camPos.x, camPos.y, camPos.z, 0, 0, 0, GetGameplayCamFov(), 0, 0)
    end

    if (cellCamSettings.currentFov == 0) then
      SetCamFov(selfieCam, startFov)
      cellCamSettings.currentFov = startFov
    end

    SetCamActive(selfieCam, true)
    RenderScriptCams(1, 0, 3000, 1, 0)
    showChatOnMessageVal = exports.chat:showChatOnMessageValue()
    exports.chat:toggleShowChatOnMessage(false)
  else -- stop it
    local ped = PlayerPedId()

    ClearTimecycleModifier()
    exports.chat:toggleShowChatOnMessage(showChatOnMessageVal)
    SendNUIMessage({toggleSelfiePhoneReturn = true, val = false})

    if (IsCamActive(selfieCam)) then
      RenderScriptCams(0, 0, 3000, 1, 0)
      selfieCam = -1
      StopAnimTask(ped, selfieAnim.dict, selfieAnim.anim, 1.0)
    end
  end
end)

RegisterNUICallback("bms:comms:phone:cancelSelfie", function()
  if (selfieMode) then
    TriggerEvent("bms:comms:phone:selfie", false)
  end
end)

RegisterNUICallback("bms:comms:phone:selfieToggle", function(data)
  TriggerEvent("bms:comms:phone:selfie", data.val)
end)

RegisterNUICallback("bms:comms:phone:ucamNextFilter", function()
  cycleFilter(2)
end)

RegisterNUICallback("bms:comms:phone:ucamPrevFilter", function()
  cycleFilter(1)
end)

RegisterNUICallback("bms:comms:phone:ucamIncStrength", function()
  cycleFilterStrength(2)
end)

RegisterNUICallback("bms:comms:phone:ucamDecStrength", function()
  cycleFilterStrength(1)
end)

RegisterNUICallback("bms:comms:phone:ucamToggleZoom", function(data)
  if (data) then
    zoomData.increase = data.increase
    
    if (not data.mouseup) then
      zoomWatcher()
    else
      zoomData.active = false
    end
  end
end)

RegisterNUICallback("bms:comms:phone:ucamTogglePhoneOverlay", function(data)
  SendNUIMessage({toggleSelfiePhoneReturn = true, val = not data.show})
  SendNUIMessage({togglePhoneOverlay = true, val = data.show})
end)

RegisterNUICallback("bms:comms:phone:ucamSnapPhoto", function(data)
  if (data.snaptype == 1) then
    exports.management:TriggerServerCallback("bms:comms:phone:ucamSnapPhoto", function(rdata)
      if (rdata.c) then
        exports.sbc:requestScreenshotUpload("https://api.imgur.com/3/upload", "image", {
          headers = {
            authorization = string.format("Client-ID %s", rdata.c),
            ["content-type"] = "multipart/form-data"
          }
        }, function(sdata)
          if (sdata) then
            sdata = json.decode(sdata)
            TriggerServerEvent("bms:comms:phone:ucamPhotoSnapped", sdata, data.title)
          else
            print("No data received from Imgur.")
          end
        end)
      else
        print("Failed to contact Imgur.")
      end
    end)
  end
end)

function zoomWatcher()
  if (zoomData.active) then return end

  zoomData.active = true
  Citizen.CreateThread(function()
    while (zoomData.active and selfieMode and IsCamActive(selfieCam)) do
      Wait(30)

      handlePhoneCamZoom(selfieCam)
    end
  end)
end

Citizen.CreateThread(function()
  while true do
    Wait(1)
    
    if (selfieMode and IsCamActive(selfieCam)) then
      local ped = PlayerPedId()
      local cellprop = getAttachedPhoneProp()
      local camPos = GetOffsetFromEntityInWorldCoords(cellprop, 0.0, 0.01, 0.25)

      SetCamCoord(selfieCam, camPos.x, camPos.y, camPos.z)
      PointCamAtPedBone(selfieCam, ped, 31086)
      SetIkTarget(ped, 1, cellprop)
      HideHelpTextThisFrame()
      HideHudAndRadarThisFrame()
      HideHudComponentThisFrame(1)
      HideHudComponentThisFrame(2)
      HideHudComponentThisFrame(3)
      HideHudComponentThisFrame(4)
      HideHudComponentThisFrame(6)
      HideHudComponentThisFrame(7)
      HideHudComponentThisFrame(8)
      HideHudComponentThisFrame(9)
      HideHudComponentThisFrame(13)
      HideHudComponentThisFrame(11)
      HideHudComponentThisFrame(12)
      HideHudComponentThisFrame(15)
      HideHudComponentThisFrame(18)
      HideHudComponentThisFrame(19)
      DisablePlayerFiring(PlayerId(), true)
      DisableControlAction(0, 25, true)
      DisableControlAction(0, 44,  true)
      DisableControlAction(0, 37, true)
    end
  end
end)