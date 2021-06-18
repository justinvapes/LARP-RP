local table_insert = table.insert
local camaccess = {
  {pos = vec3(444.681, -998.760, 34.970)},
  {pos = vec3(444.681, -998.760, 34.970)},
  {pos = vec3(1854.9899902344, 3697.6259765625, 33.761642456055)},
  {pos = vec3(-435.10958862305, 6000.8046875, 31.216329574585)}
}
local camAccessBlips
local campoints = {
  {access = {x = 259.162, y = 275.021, z = 105.629}, mount = {x = 241.861, y = 215.184, z = 108.911, head = 2.0}, camfx = "SwitchOpenNeutralFIB5"},
  {access = {x = 303.884, y = -277.451, z = 54.167}, mount = {x = 307.302, y = -279.463, z = 56.139, head = 250.1}, camfx = "SwitchOpenNeutralFIB5"},
  {access = {x = 138.817, y = -1056.862, z = 29.192}, mount = {x = 142.991, y = -1040.838, z = 30.992, head = 249.182}, camfx = "SwitchOpenNeutralFIB5"},
  {access = {x = -2947.561, y = 481.253, z = 15.262}, mount = {x = -2960.314, y = 476.548, z = 17.371, head = 1.98}, camfx = "SwitchOpenNeutralFIB5"},
  {access = {x = -119.440, y = 6477.891, z = 31.568}, mount = {x = -103.867, y = 6467.598, z = 33.451, head = 50.631}, camfx = "SwitchOpenNeutralFIB5"},
  {access = {x = 1204.491, y = 2709.771, z = 38.004}, mount = {x = 1181.122, y = 2709.306, z = 39.737, head = 92.475}, camfx = "SwitchOpenNeutralFIB5"},
  {access = {x = -1201.337, y = -338.421, z = 38.085}, mount = {x = -1217.239, y = -336.112, z = 39.381, head = 302.264}, camfx = "SwitchOpenNeutralFIB5"},
}
local camsyscameras = {
  {pos = vec3(149.150, -1035.920, 32.341), rot = vec3(-36.724, -0.000, -88.693), desc = "Vespucci Bank A"},
  {pos = vec3(146.506, -1038.124, 30.838), rot = vec3(-21.102, -0.000, -104.063), desc = "Vespucci Bank B"},
  {pos = vec3(142.741, -1041.714, 31.175), rot = vec3(-28.787, -0.000, -132.472), desc = "Vespucci Bank C"},
  {pos = vec3(-103.756, 6451.717, 34.872), rot = vec3(-18.961, -0.000, 76.409), desc = "Paleto Bank Outside"},
  {pos = vec3(-115.606, 6472.755, 33.118), rot = vec3(-20.787, -0.000, -152.000), desc = "Paleto Bank Inside A"},
  {pos = vec3(-103.682, 6467.042, 33.508), rot = vec3(-31.874, 0.000, 46.362), desc = "Paleto Bank Inside B"},
  {pos = vec3(1175.204, 2702.665, 40.713), rot = vec3(-40.488, -0.000, -178.835), desc = "Route 68 Bank Outside A"},
  {pos = vec3(1179.077, 2705.570, 39.569), rot = vec3(-22.157, 0.000, 92.220), desc = "Route 68 Bank Inside A"},
  {pos = vec3(1181.498, 2710.125, 40.029), rot = vec3(-35.953, -0.000, 58.898), desc = "Route 68 Bank Inside A"},
  {pos = vec3(-2966.692, 485.685, 18.014), rot = vec3(-35.008, -0.000, 152.882), desc = "Great Ocean Bank Outside A"},
  {pos = vec3(-2963.971, 479.055, 17.207), rot = vec3(-21.717, -0.000, -2.646), desc = "Great Ocean Bank Inside A"},
  {pos = vec3(-2959.575, 476.428, 17.648), rot = vec3(-34.693, -0.000, -29.669), desc = "Great Ocean Bank Inside B"},
  {pos = vec3(-1207.227, -323.966, 40.300), rot = vec3(-19.638, -0.000, 92.472), desc = "Blvd Del Perro Bank Outside A"},
  {pos = vec3(-1216.671, -331.372, 39.374), rot = vec3(-20.583, -0.000, -63.811), desc = "Blvd Del Perro Bank Inside A"},
  {pos = vec3(-1216.912, -336.613, 39.712), rot = vec3(-33.433, -0.000, -94.173), desc = "Blvd Del Perro Bank Inside B"},
  {pos = vec3(221.504, 213.473, 113.682), rot = vec3(-40.740, 0.000, -77.039), desc = "Alta Bank Outside A"},
  {pos = vec3(232.690, 221.700, 108.501), rot = vec3(-26.819, -0.000, -154.268), desc = "Alta Bank Inside A"},
  {pos = vec3(242.068, 214.793, 108.688), rot = vec3(-16.488, -0.000, -53.795), desc = "Alta Bank Inside B"},
  {pos = vec3(266.638, 215.913, 108.490), rot = vec3(-23.732, -0.000, 127.622), desc = "Alta Bank Inside C"},
  {pos = vec3(261.112, 220.173, 110.101), rot = vec3(-25.622, 0.000, 47.811), desc = "Alta Bank Inside D"},
  {pos = vec3(261.851, 218.304, 113.910), rot = vec3(-32.898, -0.000, -171.779), desc = "Alta Bank Inside E"},
  {pos = vec3(252.008, 225.493, 104.513), rot = vec3(-45.685, -0.000, -63.433), desc = "Alta Bank Inside F"},
  {pos = vec3(314.637, -268.863, 59.084), rot = vec3(-34.315, 0.000, -174.488), desc = "Hawick Bank Outside A"},
  {pos = vec3(310.815, -276.568, 55.792), rot = vec3(-25.118, -0.000, -110.173), desc = "Hawick Bank Inside A"},
  {pos = vec3(307.072, -280.019, 56.058), rot = vec3(-34.441, -0.000, -134.992), desc = "Hawick Bank Inside B"},
  {pos = vec3(-645.899, -239.878, 45.455), rot = vec3(-30.535, -0.000, -75.717), desc = "Jewelry Store Outside A"},
  {pos = vec3(-627.458, -239.896, 40.492), rot = vec3(-19.764, -0.000, -23.370), desc = "Jewelry Store Inside A"},
  {pos = vec3(-620.324, -224.325, 40.400), rot = vec3(-17.307, 0.000, 161.008), desc = "Jewelry Store Inside B"},
  {pos = vec3(1726.240, 6413.336, 37.755), rot = vec3(-25.618, -1.109, -141.204), desc = "24-7 Senora Outside A"},
  {pos = vec3(1736.103, 6409.621, 37.324), rot = vec3(-21.335, -1.074, 35.830), desc = "24-7 Senora Inside A"},
  {pos = vec3(1736.524, 6417.654, 37.293), rot = vec3(-35.191, -1.224, 30.161), desc = "24-7 Senora Inside B"},
  {pos = vec3(549.268, 2674.206, 44.367), rot = vec3(-26.500, -1.117, 69.990), desc = "24-7 Route 68 Outside A"},
  {pos = vec3(539.159, 2671.381, 44.380), rot = vec3(-22.658, -1.084, -109.079), desc = "24-7 Route 68 Inside A"},
  {pos = vec3(543.098, 2664.565, 44.345), rot = vec3(-33.868, -1.204, -115.632), desc = "24-7 Route 68 Inside B"},
  {pos = vec3(23.239, -1349.964, 32.575), rot = vec3(-24.673, -1.100, -110.696), desc = "24-7 Innocence Blvd Outside A"},
  {pos = vec3(34.333, -1348.604, 31.738), rot = vec3(-22.028, -1.079, 62.084), desc = "24-7 Innocence Blvd Inside A"},
  {pos = vec3(31.159, -1341.290, 31.735), rot = vec3(-35.254, -1.225, 58.695), desc = "24-7 Innocence Blvd Inside B"},
  {pos = vec3(1960.197, 3736.036, 35.108), rot = vec3(-24.925, -1.103, -69.441), desc = "24-7 Alhambra Dr Outside A"},
  {pos = vec3(1969.402, 3743.812, 34.609), rot = vec3(-20.264, -1.066, 93.111), desc = "24-7 Alhambra Dr Inside A"},
  {pos = vec3(1963.015, 3748.582, 34.588), rot = vec3(-31.412, -1.172, 89.468), desc = "24-7 Alhambra Dr Inside B"},
  {pos = vec3(-3036.348, 584.849, 10.870), rot = vec3(-31.034, -1.167, 1.225), desc = "24-7 Ineseno Road Outside A"},
  {pos = vec3(-3040.678, 594.316, 10.161), rot = vec3(-23.288, -1.089, 169.459), desc = "24-7 Ineseno Road Inside A"},
  {pos = vec3(-3046.710, 589.169, 10.137), rot = vec3(-34.939, -1.220, 165.978), desc = "24-7 Ineseno Road Inside B"},
  {pos = vec3(369.076, 324.442, 106.750), rot = vec3(-27.129, -1.124, -125.930), desc = "24-7 Clinton Ave Outside A"},
  {pos = vec3(381.844, 322.697, 105.840), rot = vec3(-22.028, -1.079, 45.832), desc = "24-7 Clinton Ave Inside A"},
  {pos = vec3(380.602, 330.575, 105.823), rot = vec3(-36.009, -1.236, 41.352), desc = "24-7 Clinton Ave Inside B"},
  {pos = vec3(-719.958, -916.959, 21.746), rot = vec3(-25.618, -1.109, -114.936), desc = "24-7 Ginger Street Outside A"},
  {pos = vec3(-705.135, -909.187, 21.341), rot = vec3(-24.988, -1.103, 131.880), desc = "24-7 Ginger Street Inside A"},
  {pos = vec3(-710.385, -903.995, 21.093), rot = vec3(-53.957, -1.700, -132.461), desc = "24-7 Ginger Street Inside B"},
  {pos = vec3(1704.516, 4937.788, 45.634), rot = vec3(-23.477, -1.090, 117.676), desc = "24-7 Grapeseed Outside"},
  {pos = vec3(1701.150, 4919.312, 44.221), rot = vec3(-22.343, -1.081, 9.416), desc = "24-7 Grapeseed Inside A"},
  {pos = vec3(1708.440, 4921.063, 43.798), rot = vec3(-50.304, -1.566, 113.693), desc = "24-7 Grapeseed Inside B"},
  {pos = vec3(-58.348, -1752.355, 31.731), rot = vec3(-24.358, -1.098, -157.807), desc = "24-7 Grove St Outside A"},
  {pos = vec3(-42.994, -1755.205, 31.556), rot = vec3(-25.807, -1.111, 95.327), desc = "24-7 Grove St Inside A"},
  {pos = vec3(-44.018, -1747.785, 31.183), rot = vec3(-54.334, -1.715, -165.047), desc = "24-7 Grove St Inside B"},
  {pos = vec3(2685.503, 3288.296, 57.439), rot = vec3(-19.446, -1.061, -178.054), desc = "24-7 Senora Fwy Outside A"},
  {pos = vec3(2683.975, 3287.270, 57.499), rot = vec3(-22.532, -1.083, 116.058), desc = "24-7 Senora Fwy Inside A"},
  {pos = vec3(2676.208, 3288.288, 57.449), rot = vec3(-33.301, -1.196, 116.571), desc = "24-7 Senora Fwy Inside B"},
  {pos = vec3(1151.232, -328.381, 71.474), rot = vec3(-21.461, -1.075, -106.220), desc = "24-7 Mirror Park Outside A"},
  {pos = vec3(1164.991, -318.014, 71.285), rot = vec3(-21.902, -1.078, 145.551), desc = "24-7 Mirror Park Inside A"},
  {pos = vec3(1158.696, -314.141, 71.008), rot = vec3(-55.971, -1.787, -107.308), desc = "24-7 Mirror Park Inside B"},
  {pos = vec3(172.359, -1035.569, 36.757), rot = vec3(-14.173, 0.000, -24.441), desc = "Legion Square A"},
  {pos = vec3(205.191, -1024.152, 37.309), rot = vec3(-23.760, -1.093, 58.016), desc = "Legion Square B"},
  {pos = vec3(315.355, -1626.315, 36.363), rot = vec3(-44.535, -0.000, 14.992), desc = "Court House Outside A"},
  {pos = vec3(267.705, -421.801, -18.655), rot = vec3(-24.504, 0.000, 127.937), desc = "Court House Inside A"},
  {pos = vec3(247.097, -437.356, -18.714), rot = vec3(-29.858, -0.000, -60.976), desc = "Court House Inside B"},
  {pos = vec3(255.689, -447.062, -20.410), rot = vec3(-20.787, -0.000, 46.740), desc = "Court House Inside C"},
  {pos = vec3(1856.102, 3683.679, 36.496), rot = vec3(-31.496, -0.000, -163.087), desc = "Sandy PD Outside A"},
  {pos = vec3(1853.031, 3692.873, 36.497), rot = vec3(-25.260, -0.000, 172.661), desc = "Sandy PD Inside A"},
  {pos = vec3(1846.589, 3689.283, 36.630), rot = vec3(-24.063, -0.000, -176.567), desc = "Sandy PD Inside B"},
  {pos = vec3(433.655, -978.137, 33.243), rot = vec3(-21.858, -0.000, 110.803), desc = "MRPD Outside A"},
  {pos = vec3(438.294, -999.616, 32.740), rot = vec3(-14.110, -0.000, -164.094), desc = "MRPD Outside B"},
  {pos = vec3(449.477, -988.743, 32.922), rot = vec3(-19.213, -0.000, 51.968), desc = "MRPD Inside A"},
  {pos = vec3(465.784, -1002.798, 26.539), rot = vec3(-18.898, 0.000, 50.772), desc = "MRPD Inside B"},
  {pos = vec3(468.184, -1004.105, 26.567), rot = vec3(-31.055, -0.000, -162.961), desc = "MRPD Inside C"},
  {pos = vec3(476.450, -1003.930, 26.625), rot = vec3(-28.094, -0.000, -157.606), desc = "MRPD Inside D"},
  {pos = vec3(466.915, -978.289, 26.697), rot = vec3(-19.717, -0.000, -177.575), desc = "MRPD Inside E"},
  {pos = vec3(471.652, -985.494, 26.736), rot = vec3(-20.283, -0.000, -97.701), desc = "MRPD Inside F"},
  {pos = vec3(-424.462, 6018.865, 37.471), rot = vec3(-21.606, 0.000, 68.094), desc = "Paleto PD Outside A"},
  {pos = vec3(-447.307, 6006.885, 33.966), rot = vec3(-24.945, -0.000, 4.031), desc = "Paleto PD Inside A"},
  {pos = vec3(-439.326, 5994.111, 33.953), rot = vec3(-22.866, -0.000, -178.961), desc = "Paleto PD Inside B"},
  {pos = vec3(-435.713, 5996.540, 33.918), rot = vec3(-21.606, -0.000, -80.000), desc = "Paleto PD Inside C"}
}
local survcam = -1
local lastcam = {}
local cammode = false
local leoonduty = false
local usingcamsys = false

function drawCameraText(text, x, y)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.32, 0.32)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
end

function draw3DCamText(x, y, z, text, tscale)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
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
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
  end
end

function setupSurvCamera(enable)
  if (enable) then
    if (lastcam) then
      local ped = PlayerPedId()
      
      if (survcam == -1) then
        survcam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", lastcam.mount.x, lastcam.mount.y, lastcam.mount.z, 0, 0, 0, GetGameplayCamFov(), 0, 0)
      end

      SetCamActive(survcam, true)
      RenderScriptCams(1, 0, 3000, 1, 0)

      local rot = GetCamRot(survcam, 2)
      local vrot = {x = rot.x, y = rot.y, z = rot.z}
        
      vrot.z = lastcam.mount.head
      SetCamRot(survcam, vrot.x, vrot.y, vrot.z, 2)
      StartScreenEffect(lastcam.camfx, 0, true)
    else
      print("lastcam was nil in >> camerasystem_cl.lua")
    end
  else
    if (survcam > -1) then
      if (IsCamActive(survcam)) then
        RenderScriptCams(0, 0, 3000, 1, 0)
        StopAllScreenEffects()
        survcam = -1
      end
    end
  end
end

function setupCameraSystemCams(enable, cam)
  if (enable) then
    local ped = PlayerPedId()
    
    if (survcam == -1) then
      survcam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cam.pos.x, cam.pos.y, cam.pos.z, 0, 0, 0, GetGameplayCamFov(), 0, 0)
      SetFocusArea(cam.pos.x, cam.pos.y, cam.pos.z)
    end

    SetCamActive(survcam, true)
    RenderScriptCams(1, 0, 3000, 1, 0)      
    SetCamRot(survcam, cam.rot.x, cam.rot.y, cam.rot.z, 2)
    StartScreenEffect("SwitchOpenNeutralFIB5", 0, true)
  else
    if (survcam > -1) then
      if (IsCamActive(survcam)) then
        RenderScriptCams(0, 0, 3000, 1, 0)
        StopAllScreenEffects()
        survcam = -1
      end

      ClearFocus()
    end
  end
end

function checkInput()
  local ped = PlayerPedId()

  DisableControlAction(0, 1, true) -- LookLeftRight
  DisableControlAction(0, 2, true) -- LookUpDown
  DisableControlAction(0, 24, true) -- Attack
  DisablePlayerFiring(ped, true) -- Disable weapon firing
  DisableControlAction(0, 142, true) -- MeleeAttackAlternate
  DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
  HideHudAndRadarThisFrame()
  DisableFirstPersonCamThisFrame()
  
  if (survcam ~= -1) then
    if (IsControlPressed(1, 174)) then -- left arrow
      local rot = GetCamRot(survcam, 2)
      local vrot = {x = rot.x, y = rot.y, z = rot.z}
        
      vrot.z = rot.z + 0.25
      SetCamRot(survcam, vrot.x, vrot.y, vrot.z, 2)
    elseif (IsControlPressed(1, 175)) then -- right arrow
      local rot = GetCamRot(survcam, 2)
      local vrot = {x = rot.x, y = rot.y, z = rot.z}
        
      vrot.z = rot.z - 0.25
      SetCamRot(survcam, vrot.x, vrot.y, vrot.z, 2)
    end
    
    if (IsControlPressed(1, 27)) then -- up arrow
      local rot = GetCamRot(survcam, 2)
      local vrot = {x = rot.x, y = rot.y, z = rot.z}
        
      vrot.x = rot.x + 0.25
      SetCamRot(survcam, vrot.x, vrot.y, vrot.z, 2)
    elseif (IsControlPressed(1, 173)) then -- down arrow
      local rot = GetCamRot(survcam, 2)
      local vrot = {x = rot.x, y = rot.y, z = rot.z}
        
      vrot.x = rot.x - 0.25
      SetCamRot(survcam, vrot.x, vrot.y, vrot.z, 2)
    end
  end
end

function setupCamAccessBlips()
  camAccessBlips = {}
  
  for i,v in pairs(camaccess) do
    camAccessBlips[i] = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)

    local blip = camAccessBlips[i]

    SetBlipSprite(blip, 135)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("City Cameras")
    EndTextCommandSetBlipName(blip)
  end
end

function removeCamAccessBlips()
  for _,v in pairs(camAccessBlips) do
    if (DoesBlipExist(v)) then
      RemoveBlip(v)
    end
  end

  camAccessBlips = nil
end

AddEventHandler("bms:lawenf:activedutyswitch", function(tog)
  leoonduty = tog
end)

RegisterNUICallback("bms:comms:cameras:activateCamera", function(data)
  if (data and data.cid) then
    local cam = camsyscameras[data.cid]
    
    if (cam) then
      if (survcam == -1) then
        setupCameraSystemCams(true, cam)
      end

      SetCamCoord(survcam, cam.pos.x, cam.pos.y, cam.pos.z)
      SetCamRot(survcam, cam.rot.x, cam.rot.y, cam.rot.z, 2)
      SetFocusArea(cam.pos.x, cam.pos.y, cam.pos.z)
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    if (leoonduty) then
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)

      if (not camAccessBlips) then
        setupCamAccessBlips()
      end
      
      if (not cammode) then
        for _,v in pairs(campoints) do
          local dist = Vdist(pos.x, pos.y, pos.z, v.access.x, v.access.y, v.access.z)
  
          if (dist < 80.1) then
            DrawMarker(1, v.access.x, v.access.y, v.access.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 0.15, 0, 180, 255, 50, 0, 0, 2, 0, 0, 0, 0)
  
            if (dist < 1.2) then
              draw3DCamText(v.access.x, v.access.y, v.access.z + 0.5, "Press ~b~[E]~w~ to access the security footage.")
  
              if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
                lastcam = v
                cammode = true
              end
            end
          end
        end
      end
  
      if (cammode and survcam == -1 and lastcam.mount) then
        setupSurvCamera(true)
      elseif (cammode and survcam > -1 and lastcam.mount) then
        drawCameraText("Press ~b~[E]~w~ to exit the camera.", 0.475, 0.92)
        drawCameraText("Use [Left/Right Arrow] to move the camera lens.", 0.475, 0.95)
        HideHudAndRadarThisFrame()
  
        if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
          cammode = false
          lastcam = {}
          setupSurvCamera(false)
        end

        checkInput()
      end

      if (not usingcamsys) then -- wip
        for _,v in pairs(camaccess) do
          local dist = #(pos - v.pos)

          if (dist < 30) then
            DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 0.9000001, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 0.15, 0, 180, 255, 50, 0, 0, 0, 0, 0, 0, 0)

            if (dist < 0.6) then
              draw3DCamText(v.pos.x, v.pos.y, v.pos.z + 0.5, "Press ~b~[E]~w~ to access the city camera system.", 0.29)

              if (IsControlJustReleased(1, 38)) then
                usingcamsys = true

                local ncams = {}

                for _,v in pairs(camsyscameras) do
                  table_insert(ncams, v.desc)
                end

                SendNUIMessage({showCameraSystem = true, cameras = ncams})
                SetNuiFocusKeepInput(true)
              end
            end
          end
        end
      else
        checkInput()

        if (IsControlJustReleased(1, 38)) then
          setupCameraSystemCams(false)
          SendNUIMessage({hideCameraSystem = true})
          SetNuiFocus(false, false)
          usingcamsys = false
        elseif (IsControlJustReleased(1, 127)) then -- num 8
          SendNUIMessage({camSystemNav = true, dir = 1})
        elseif (IsControlJustReleased(1, 126)) then -- num 5
          SendNUIMessage({camSystemNav = true, dir = 2})
        end
      end
    end
  end
end)