local table_insert = table.insert
local table_remove = table.remove
local table_unpack = table.unpack
local DrawMarker = DrawMarker

isonduty = false -- keep global for FD access
local ambblips = {}
local ambspots = {
  {pos = vec3(210.169, -1656.026, 29.803)},
  {pos = vec3(-634.422, -121.646, 39.013)},
  --{pos = vec3(1207.682, -1473.907, 34.859)},
  {pos = vec3(-380.907, 6119.656, 31.479)},
  {pos = vec3(-694.681, 312.630, 83.1028)},
  {pos = vec3(334.102, -561.486, 28.743)},
  {pos = vec3(1819.873, 3681.787, 34.276)},
  {pos = vec3(-264.489, 6329.212, 32.426)},
  {pos = vec3(1207.5666503906, -1474.5153808594, 34.859535217285)},
  {pos = vec3(319.19931030273, -1477.0346679688, 29.886274337769)},
  {pos = vec3(-1473.7164306641, -1016.1090698242, 6.2928419113159)}
}
local ambMarkers = {}
local gearspots = {
  {pos = vec3(215.608, -1649.145, 29.803)},
  {pos = vec3(-634.407, -126.535, 39.014)},
  {pos = vec3(-381.794, 6117.727, 31.631)},
  {pos = vec3(-715.765, 303.155, 85.304)},
  {pos = vec3(331.902, -560.895, 28.743)},
  {pos = vec3(1821.199, 3682.661, 34.276)},
  {pos = vec3(-248.225, 6330.417, 32.426)},
  {pos = vec3(1207.5098876953, -1472.4812011719, 34.859535217285)},
  {pos = vec3(321.02478027344, -1474.4200439453, 29.803953170776)},
  {pos = vec3(301.496, -599.129, 43.284)},
  {pos = vec3(-1491.6893310547, -1025.7176513672, 6.2976603507996)}
}
local gearMarkers = {}
local cargarageprev = {
  {x = 215.997, y = -1639.191, z = 29.566, heading = 321.624},
  {x = -649.723, y = -106.531, z = 37.919, heading = 118.143},
  {x = -356.516, y = 6132.035, z = 31.440, heading = 52.505},
  {x = -701.519, y = 308.661, z = 83.039, heading = 173.919},
  {x = 330.593, y = -555.434, z = 28.743, heading = 305.963},
  {x = 1813.179, y = 3686.306, z = 34.224, heading = 110.954},
  {x = -265.891, y = 6335.351, z = 32.331, heading = 125.032},
  {x = 1204.7125244141, y = -1479.7375488281, z = 34.859535217285, heading = 353.518},
  {x = 334.65548706055, y = -1467.5012207031, z = 29.612033843994, heading = 219.359},
  {x = -1479.7364501953, y = -1007.0393676758, z = 5.9602770805359, heading = 50.289}
}
local cargaragecamcoords = {
  {x = 210.238, y = -1633.262, z = 31.676},
  {x = -642.007, y = -114.281, z = 39.947},
  {x = -362.294, y = 6127.477, z = 32.041},
  {x = -694.402, y = 308.345, z = 83.083},
  {x = 335.522, y = -557.663, z = 28.743},
  {x = 1808.694, y = 3690.217, z = 34.143},
  {x = -262.019, y = 6331.478, z = 32.426},
  {x = 1199.4113769531, y = -1482.7465820313, z = 34.859535217285},
  {x = 331.83480834961, y = -1474.4313964844, z = 29.70652961731},
  {x = -1473.9471435547, y = -1001.1603393555, z = 6.3165588378906}
}
local cargaragespawn = {
  {x = 219.196, y = -1641.748, z = 29.569, heading = 316.501},
  {x = -638.311, y = -112.739, z = 37.993, heading = 93.089},
  {x = -376.041, y = 6126.917, z = 31.447, heading = 38.736},
  {x = -698.259, y = 303.974, z = 82.952, heading = 175.834},
  {x = 341.492, y = -559.673, z = 28.743, heading = 348.417},
  {x = 1804.596, y = 3680.689, z = 34.22, heading = 119.604},
  {x = -271.736, y = 6329.521, z = 32.332, heading = 132.444},
  {x = 1204.08984375, y = -1457.7846679688, z = 34.84383392334, heading = 353.518},
  {x = 327.90692138672, y = -1475.4993896484, z = 29.796501159668, heading = 273.217},
  {x = -1465.1240234375, y = -1003.3364257813, z = 6.2623338699341, heading = 315.342}
}
local helispots = {
  {x = 344.235, y = -585.118, z = 74.165, sx = 351.233, sy = -587.934, sz = 74.165, sh = 336.337, bx = 319.153, by = -558.981, bz = 28.743},
  {x = 1694.0802001953, y = 3597.435546875, z = 35.614135742188, sx = 1694.6701660156, sy = 3591.1455078125, sz = 40.713832855225, sh = 30.01, bx = 1694.0802001953, by = 3597.435546875, bz = 35.614135742188, warpin = true}
} -- spot, spawn, blip
local showhelispawns = false
local heliblips = {}
local emsBlips = {}
local dpBlips = {}
local gearBlips = {}
local distWarn = false
local lastgarage = 0
local garageCam = -1
local curGarageVehicle = 1
local maxGarageVehicles = 1
local previewedVehicle
local blockpreview = false
local blockinput = false
local emsgear = {"WEAPON_FLASHLIGHT", "WEAPON_FIREEXTINGUISHER", "WEAPON_PETROLCAN", "WEAPON_FLARE", "WEAPON_STUNGUN"}
local healspots = {}
local healMarkers = {}
local hospitalBlips = {}
local heallock = false
--[[local xrayspots = {
  {x = 253.752, y = -1368.933, z = 39.534} --/teleport 253 -1368 39
}]]
local inxray = false
local crashcarts = {
  {pos = vec3(318.4743347168, -583.07177734375, 43.284034729004), nped = "s_f_y_scrubs_01", npedstart = {x = 319.92657470703, y = -572.12561035156, z = 43.283981323242}, npedend = {x = 317.96752929688, y = -580.78161621094, z = 43.284038543701}, bedpos = {x = 319.40432739258, y = -581.12377929688, z = 44.184089660645}}
}
local crashMarkers = {}
local nurse = {nped = nil, inc = false, aped = nil, bedanim = {dict = "anim@mp_bedmid@left_var_01", anim = "f_sleep_l_loop_bighouse"}, tendanim = {dict = "amb@medic@standing@timeofdeath@base", anim = "base"}}
local emsboats = {
  prevcoords = {x = -1839.4738769531, y = -932.31939697266, z = -0.41699743270874, heading = 21.828},
  campreview = {x = -1831.9952392578, y = -924.02026367188, z = 0.84876173734665},
  spawn = {x = -1842.8255615234, y = -922.65594482422, z = -0.13263061642647, heading = 67.868}
}
local previewingBoat = false
local emsveh = 0
local roadblockset = false
local roadblocks = {}
local rbradius = 50.0
local lightson = false
local rtimeout = 0
local rbstopdelay = 2000 -- 2 seconds after stopping with lights on, activate roadblock
local pingblips = {}
local wheelchairs = {}
local wheelchair = {
  model = "prop_wheelchair_01_s", 
  hash = GetHashKey("prop_wheelchair_01"), 
  sitAnim = {dict = "missfinale_c2leadinoutfin_c_int", anim = "_leadin_loop2_lester"},
  pushAnim = {dict = "anim@heists@box_carry@", anim = "idle"}
}
local wcInfo = {isSitting = false, isPushing = false, currWc = nil}
local lastinjuries = {}
local lastinjurytype
local showinginjury = false
local injurybones = {
  ["Head"] = {ids = {39317, 31086}},
  ["Left_Shoulder"] = {ids = {64729}},
  ["Right_Shoulder"] = {ids = {10706}},
  ["Chest"] = {ids = {24817, 24818}},
  ["Left_Arm"] = {ids = {45509, 61163}},
  ["Right_Arm"] = {ids = {28252, 40269}},
  ["Left_Hand"] = {ids = {18905}},
  ["Right_Hand"] = {ids = {57005}},
  ["Left_Leg"] = {ids = {58271, 63931}},
  ["Right_Leg"] = {ids = {51826, 36864}},
  ["Left_Foot"] = {ids = {14201}},
  ["Right_Foot"] = {ids = {52301}}
}
local lastPedComps = {}
local lastPedProps = {}
local inTurnoutGear = false
local turnoutAnim = {dict = "anim@mp_yacht@shower@male@", anim = "male_shower_idle_a"}
local revAnim = {dict = "random@peyote@generic", anim = "wakeup"}

function xyDist(pos1, pos2)
  return math.sqrt(math.pow(pos1.x - pos2.x, 2) + math.pow(pos1.y - pos2.y, 2))
end

function getPedInDirection(coordFrom, coordTo, ignore)
  local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 12, ignore, 0)
  local _, _, _, _, ped = GetRaycastResult(rayHandle)
  return ped
end

function setSkin(skin)
  local model = GetHashKey(skin)
  
  if IsModelInCdimage(model) and IsModelValid(model) then
    RequestModel(model)
    
    while not HasModelLoaded(model) do
      Citizen.Wait(25)
    end
    
    SetPlayerModel(PlayerId(), model)
    SetPedRandomComponentVariation(PlayerPedId(), true)
    SetModelAsNoLongerNeeded(model)
  else
    ShowRadarMessage("Skin was not found.")
  end
end

function fillGasTank(veh)
  local fuelprop = "_Fuel_Level"
  TriggerEvent("frfuel:filltankForVeh", veh)
end

function addHospitalBlips()
  local iter = 0

  for _,v in pairs(healspots) do
    if (v.hospital) then
      local blip = AddBlipForCoord(v.pos)
        
      SetBlipSprite(blip, 80)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 0.9)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentSubstringPlayerName("Hospital")
      EndTextCommandSetBlipName(blip)
      
      iter = iter + 1
      hospitalBlips[iter] = blip
    end
  end
end

function getClosestPlayer()
  local players = GetActivePlayers()
  local closestDistance = -1
  local closestPlayer = -1
  local ped = PlayerPedId()
  local ppos = GetEntityCoords(ped)

  for i=1,#players do
    local target = GetPlayerPed(players[i])

    if (target ~= ped) then
      local tpos = GetEntityCoords(target)
      local dist = #(tpos - ppos)
      
      if (closestDistance == -1 or closestDistance > dist) then
        closestPlayer = players[i]
        closestDistance = dist
      end
    end
  end

  return closestPlayer, closestDistance
end

function dpBlipExistsFor(charName)
  for _,v in pairs(dpBlips) do
    if (v.charName == charName) then
      return true
    end
  end

  return false
end

function checkDpBlips()
  Citizen.CreateThread(function()
    while true do
      Wait(1000)
      
      if (isonduty) then
        local remids = {}

        for i,v in ipairs(dpBlips) do
          if (--[[not DoesBlipExist(v.blip) or not ]] not IsPlayerDead(GetPlayerFromServerId(v.sid))) then
            table_insert(remids, i)
            RemoveBlip(v.blip)
          end
        end

        if (#remids > 0) then
          for i = #remids, 1, -1 do
            local r = remids[i]
            
            table_remove(dpBlips, r)
          end
        end
      end
    end
  end)
end

function getDpBlipFor(charName)
  for _,v in pairs(dpBlips) do
    if (v.charName == charName) then
      return v
    end
  end

  return nil
end

function removeDpBlipFor(charName)
  print(charName)
  local remid = 0
  
  for i,v in ipairs(dpBlips) do
    if (v.charName == charName) then
      remid = i
      break
    end
  end

  if (remid > 0) then
    table_remove(dpBlips, remid)
  end
end

function addDpBlipForEntity(ped)
  local blip = AddBlipForEntity(ped)

  SetBlipSprite(blip, 1)
  SetBlipDisplay(blip, 4)
  SetBlipCategory(blip, 2)
  SetBlipScale(blip, 1.1)
  SetBlipAsShortRange(blip, true)
  SetBlipColour(blip, 49)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentSubstringPlayerName(".EMS Required.")
  EndTextCommandSetBlipName(blip)

  return blip
end

function addDpBlip(charName, sid)
  local ped = GetPlayerPed(GetPlayerFromServerId(sid))
  local dpBlip = {charName = charName, sid = sid, blip = addDpBlipForEntity(ped)}
  
  table_insert(dpBlips, dpBlip)
  print("EMS DP blips #: " .. #dpBlips)
end

--[[function clearEmsBlips()
  if (#emsBlips > 0) then
    for _,v in pairs(emsBlips) do
      RemoveBlip(v.blip)
    end

    emsBlips = {}
  end

  for _,v in pairs(gearBlips) do
    RemoveBlip(v)
  end

  gearBlips = {}
end

function emsBlipExistsFor(id)
  for _,v in pairs(emsBlips) do
    if (v.id == id) then
      return true
    end
  end
  
  return false
end

function addEmsBlip(id)
  local players = GetActivePlayers()
  
  for _,v in pairs(players) do
    local sid = GetPlayerServerId(v)
    
    if (sid == id) then
      if (not emsBlipExistsFor(sid)) then
        local rped = GetPlayerPed(v)
        local blip = AddBlipForEntity(rped)
                        
        SetBlipAsFriendly(blip, 1)
        SetBlipColour(blip, 8)
        SetBlipCategory(blip, 1)
        ShowHeadingIndicatorOnBlip(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName("EMS")
        EndTextCommandSetBlipName(blip)
        
        local emsblip = {}
        emsblip.id = id
        emsblip.blip = blip
        
        table_insert(emsBlips, emsblip)
      end
    end
  end
end]]

function setupBlips()
  for _,v in pairs(ambspots) do
    local blip = AddBlipForCoord(v.pos)
    
    SetBlipSprite(blip, 289)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("EMS Vehicle Pool")
    EndTextCommandSetBlipName(blip)
    
    table_insert(ambblips, blip)
  end
end

function addGearBlips()
  for _,v in pairs(gearspots) do
    local blip = AddBlipForCoord(v.pos)
    
    SetBlipSprite(blip, 351)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 18)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("EMS Gear Depot")
    EndTextCommandSetBlipName(blip)
    
    table_insert(gearBlips, blip)
  end
end

-- [[ GARAGE ]]

function drawGarageText(text)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.62, 0.62)
  SetTextColour(125, 125, 255, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.5, 0.795)
end

function drawLoading()
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.55, 0.55)
  SetTextColour(255, 75, 75, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName("Loading Vehicle...")
  EndTextCommandDisplayText(0.5, 0.685)
end

function drawClientText(text)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.32, 0.32)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.475, 0.88)
end

function draw3DText(x, y, z, text, sc)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, sc or 0.55 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    -- SetTextScale(0.0, 0.55)
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

function setupBoatPreviewCamera(enable)
  if (enable) then
    -- switch to ems boat camera
    garageCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", emsboats.campreview.x, emsboats.campreview.y, emsboats.campreview.z, 0, 0, 0, GetGameplayCamFov(), 0, 0)

    SetCamActive(garageCam, true)
    RenderScriptCams(1, 0, 3000, 1, 0)
  else
    -- reset to default ems garage camera
    garageCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cargaragecamcoords[lastgarage].x, cargaragecamcoords[lastgarage].y, cargaragecamcoords[lastgarage].z, 0, 0, 0, GetGameplayCamFov(), 0, 0)
    SetCamActive(garageCam, true)
    RenderScriptCams(1, 0, 3000, 1, 0)
  end
end

function setupGarageCamera(enable)
  if (enable) then
    local ped = PlayerPedId()
    
    Citizen.Trace(tostring(lastgarage))
    
    if (garageCam == -1 or previewingBoat) then
      garageCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cargaragecamcoords[lastgarage].x, cargaragecamcoords[lastgarage].y, cargaragecamcoords[lastgarage].z, 0, 0, 0, GetGameplayCamFov(), 0, 0)
    end

    SetCamActive(garageCam, true)
    RenderScriptCams(1, 0, 3000, 1, 0)
  else
    if (garageCam > -1) then
      if (IsCamActive(garageCam)) then
        RenderScriptCams(0, 0, 3000, 1, 0)
        garageCam = -1
      end
    end
  end
end

function initializeGarage()
  local vehmodel

  curGarageVehicle = 1
  maxGarageVehicles = #fdvehicles
  vehmodel = fdvehicles[1].model  
  spawnVehiclePreview(vehmodel, fdvehicles[1].boat, fdvehicles[1].livery)
end

function spawnVehiclePreview(name, isboat, livery)
  Citizen.CreateThread(function()
    local hash = GetHashKey(name)

    RequestModel(hash)

    while not HasModelLoaded(hash) do
      Wait(0)
      drawLoading()
    end

    local veh
    
    if (isboat) then
      veh = CreateVehicle(hash, emsboats.prevcoords.x, emsboats.prevcoords.y, emsboats.prevcoords.z, emsboats.prevcoords.heading, false, false)
      setupBoatPreviewCamera(true)
      previewingBoat = true
    else
      veh = CreateVehicle(hash, cargarageprev[lastgarage].x, cargarageprev[lastgarage].y, cargarageprev[lastgarage].z, cargarageprev[lastgarage].heading, false, false)
      setupGarageCamera(true)
      previewingBoat = false
    end

    while not DoesEntityExist(veh) do
      Wait(0)
      drawLoading()
    end

    FreezeEntityPosition(veh, true)
    SetEntityInvincible(veh, true)
    SetVehicleDoorsLocked(veh, 4)
    SetVehicleDirtLevel(veh, 0.0)
    previewedVehicle = veh        
    PointCamAtEntity(garageCam, veh, 0, 0, 0, 0)
    SetModelAsNoLongerNeeded(hash)

    if (livery) then
      SetVehicleLivery(veh, livery)
    end

    blockpreview = false
  end)
end

function spawnGarageVehicle()
  local vehmodel
  local power
  local pcolor
  local scolor

  vehmodel = fdvehicles[curGarageVehicle].model
  boat = fdvehicles[curGarageVehicle].boat
  livery = fdvehicles[curGarageVehicle].livery
  pcolor = fdvehicles[curGarageVehicle].pcolor or -1
  scolor = fdvehicles[curGarageVehicle].scolor or -1
  
  Citizen.CreateThread(function()
    local hash = GetHashKey(vehmodel)

    RequestModel(hash)

    while not HasModelLoaded(hash) do
      Wait(25)
    end

    if (boat) then
      emsveh = CreateVehicle(hash, emsboats.spawn.x, emsboats.spawn.y, emsboats.spawn.z, emsboats.spawn.heading, true, false)
    else
      emsveh = CreateVehicle(hash, cargaragespawn[lastgarage].x, cargaragespawn[lastgarage].y, cargaragespawn[lastgarage].z, cargaragespawn[lastgarage].heading, true, false)
    end    
    
    lastgarage = 0

    while not DoesEntityExist(emsveh) do
      drawLoading()
      Wait(0)
    end

    if (emsveh) then
      SetVehicleDirtLevel(emsveh, 0.0)

      if (pcolor > -1 and scolor > -1) then
        SetVehicleColours(emsveh, pcolor, scolor)
      end

      local id = NetworkGetNetworkIdFromEntity(emsveh)
      fillGasTank(emsveh)
      exports.vehicles:registerPulledVehicle(emsveh)
    end

    SetEntityAsMissionEntity(emsveh, true, true)
    SetVehicleHasBeenOwnedByPlayer(emsveh, true)
    SetVehicleNeedsToBeHotwired(emsveh, false)
    SetModelAsNoLongerNeeded(hash)
    ToggleVehicleMod(emsveh, 18, true)
    ToggleVehicleMod(emsveh, 22, true)
    SetVehicleModKit(emsveh, 0)
    SetVehicleMod(emsveh, 13, 2)
    SetVehicleMod(emsveh, 12, 2)
    SetVehicleMod(emsveh, 11, 2)
    SetVehicleMod(emsveh, 16, 4)

    if (not DecorIsRegisteredAsType("lightsOn", 2)) then
      DecorRegister("lightsOn", 2)
    end

    DecorSetBool(emsveh, "lightsOn", false)

    if (livery) then
      SetVehicleLivery(emsveh, livery)
    end

    if (boat) then
      local ped = PlayerPedId()

      TaskWarpPedIntoVehicle(ped, emsveh, -1)
    end
  end)
end

function nextPreview()
  local vehmodel

  if (previewedVehicle) then
    DeleteVehicle(previewedVehicle)
  end

  curGarageVehicle = curGarageVehicle + 1

  if (curGarageVehicle > #fdvehicles) then
    curGarageVehicle = #fdvehicles
  end

  vehmodel = fdvehicles[curGarageVehicle].model
  
  spawnVehiclePreview(vehmodel, fdvehicles[curGarageVehicle].boat, fdvehicles[curGarageVehicle].livery)
end

function prevPreview()
  local vehmodel

  if (previewedVehicle) then
    DeleteVehicle(previewedVehicle)
  end

  curGarageVehicle = curGarageVehicle - 1

  if (curGarageVehicle < 1) then
    curGarageVehicle = 1
  end

  vehmodel = fdvehicles[curGarageVehicle].model
  
  spawnVehiclePreview(vehmodel, fdvehicles[curGarageVehicle].boat, fdvehicles[curGarageVehicle].livery)
end

function getCurCar()
  return curGarageVehicle
end

function getMaxCar()
  return #fdvehicles
end

function fillGasTank(veh)
  local fuelprop = "_Fuel_Level"

  --if (veh) then
  TriggerEvent("frfuel:filltankForVeh", veh)
  --DecorRegister(fuelprop, 1)
  --DecorSetFloat(veh, fuelprop, 65.0)
  --end
end

function giveGearToEms()
  local ped = PlayerPedId()

  for _,v in pairs(emsgear) do
    local hash = GetHashKey(v)
    GiveWeaponToPed(ped, hash, 2000, 0, false)
    TriggerServerEvent("bms:ems:getInventoryLoadout")
  end

  SetPedArmour(ped, 50)
end

function doesVehicleExistAtPoint(x, y, z)
  local player = PlayerPedId()
  local rayHandle = StartShapeTestRay(x, y, z, x + 10.0, y + 10.0, z, 10, player, 0)
  local a, b, c, d, vehicleHandle = GetShapeTestResult(rayHandle)

  if (vehicleHandle ~= nil) and (DoesEntityExist(vehicleHandle)) then
    return true
  end
  
  return false
end

function spawnHelicopter(v, warpin)
  Citizen.CreateThread(function()
    if (not doesVehicleExistAtPoint(v.sx, v.sy, v.sz)) then
      local ped = PlayerPedId()
      local hash = GetHashKey("supervolito")
      
      RequestModel(hash)

      while not HasModelLoaded(hash) do
        Wait(25)
      end

      local spawnedVeh = CreateVehicle(hash, v.sx, v.sy, v.sz, v.sh, true, false)
      
      while not DoesEntityExist(spawnedVeh) do
        Citizen.Wait(200)
      end

      if (spawnedVeh) then
        SetVehicleDirtLevel(spawnedVeh, 0.0)

        local id = NetworkGetNetworkIdFromEntity(spawnedVeh)
        SetVehicleLivery(spawnedVeh, 2)
        fillGasTank(spawnedVeh)
        exports.vehicles:registerPulledVehicle(spawnedVeh)
        
        if (warpin) then
          SetPedIntoVehicle(ped, spawnedVeh, -1)
        end
      else
        Citizen.Trace("veh was nil")
      end

      SetEntityAsMissionEntity(spawnedVeh, true, true)
      SetVehicleHasBeenOwnedByPlayer(spawnedVeh, true)
      SetModelAsNoLongerNeeded(hash)
    else
      exports.pnotify:SendNotification({text = "Clear the landing area first."})
    end
  end)
end

function isPlayerOnDutyEms(cb)
  if (cb) then
    cb(isonduty)
  end
end

function showInjured()
  SendNUIMessage({
    showInjured = true,
    injury = 25
  })
end

function spawnNurse(v, tped)
  local ped = PlayerPedId()
  local hash = GetHashKey(v.nped)
  print(string.format("%s, %s", hash, v.nped))
    
  RequestModel(hash)
  
  while not HasModelLoaded(hash) do
    Wait(25)
  end

  -- since the navmesh is broken inside the hospital, just spawn the nurse in place
  nurse.nped = CreatePed(4, hash, v.npedend.x, v.npedend.y, v.npedend.z, 0, true, 1)
  
  while (not DoesEntityExist(nurse.nped)) do
    Wait(60)
  end

  SetModelAsNoLongerNeeded(hash)
  nurse.aped = GetPlayerPed(tped)
  nurse.inc = true
end

function removePingBlip(blip)
  local remid = 0
  
  for i,v in ipairs(pingblips) do
    if (v.blip == blip) then
      remid = i
      break
    end
  end

  if (remid > 0) then
    table_remove(pingblips, remid)
  end
end

function addPingBlip(ent)
  local blip = AddBlipForEntity(ent)

  SetBlipScale(blip, 1.3)
  SetBlipSprite(blip, 4)
  SetBlipColour(blip, 6)

  local tblip = {}
  tblip.blip = blip
  tblip.timeout = function()
    SetTimeout(60000, function()
      RemoveBlip(tblip.blip)
      removePingBlip(tblip.blip)
    end)
  end
  
  tblip.timeout()
  table_insert(pingblips, tblip)
  exports.pnotify:SendNotification({text = "The location has been marked on your map."})
  
  local pos = GetEntityCoords(ent)

  SetNewWaypoint(pos.x, pos.y)
end

function isLastVehEmsVeh()
  local lastveh = GetVehiclePedIsIn(ped, true)
  
  if (lastveh) then
    local model = GetEntityModel(lastveh)

    for _,v in pairs(fdvehicles) do
      local vmodel = GetHashKey(v.model)

      if (vmodel == model) then
        return true
      end
    end
  end
end

function sitWheelchair(wheelchairObject)
  local ped = PlayerPedId()
  local isPushed = false
  
  RequestAnimDict(wheelchair.sitAnim.dict)
  while (not HasAnimDictLoaded(wheelchair.sitAnim.dict)) do
    Wait(25)
  end

  AttachEntityToEntity(ped, wheelchairObject, 0, 0, 0.0, 0.4, 0.0, 0.0, 180.0, 0.0, false, false, false, true, 2, true)

  local waitTime = 5
  Citizen.CreateThread(function()
    while (IsEntityAttachedToEntity(ped, wheelchairObject)) do
      Wait(waitTime)
      waitTime = 100
      if (not isPushed) then
        NetworkRequestControlOfEntity(wheelchairObject)

        if (not IsEntityPlayingAnim(ped, wheelchair.sitAnim.dict, wheelchair.sitAnim.anim, 3)) then
          TaskPlayAnim(ped, wheelchair.sitAnim.dict, wheelchair.sitAnim.anim, 8.0, 8.0, -1, 1, 1, false, false, false)
        end

        if (IsControlPressed(0, 32)) then -- W
          waitTime = 1
          local wcPos = GetEntityCoords(wheelchairObject)
          local fvec = GetEntityForwardVector(wheelchairObject)
          local ray = StartShapeTestRay(wcPos, wcPos + fvec * -1, -1, wheelchairObject, 1)
          local _, hit, _, _, entHit = GetShapeTestResult(ray)
          if (hit == 0) then
            local x, y, z  = table_unpack(wcPos + fvec * -0.1)

            SetEntityCoords(wheelchairObject, x, y, z)
          end
        end

        if (IsControlPressed(0, 33)) then -- S
          waitTime = 1
          local wcPos = GetEntityCoords(wheelchairObject)
          local fvec = GetEntityForwardVector(wheelchairObject)
          local ray = StartShapeTestRay(wcPos, wcPos + fvec * 1, -1, wheelchairObject, 1)
          local _, hit, _, _, entHit = GetShapeTestResult(ray)
          if (hit == 0) then
            local x, y, z  = table_unpack(GetEntityCoords(wheelchairObject) + GetEntityForwardVector(wheelchairObject) * 0.01)

            SetEntityCoords(wheelchairObject, x, y, z)
          end
        end

        if (IsControlPressed(1, 34)) then -- A
          waitTime = 1
          local heading = GetEntityHeading(wheelchairObject)
          heading = heading + 0.4

          if (heading > 360.0) then
            heading = 0.0
          end

          SetEntityHeading(wheelchairObject, heading)
        end

        if (IsControlPressed(1, 35)) then -- D
          waitTime = 1
          local heading = GetEntityHeading(wheelchairObject)
          heading = heading - 0.4

          if (heading < 0.0) then
            heading = 360.0 - 0.4
          end

          SetEntityHeading(wheelchairObject, heading)
        end

        if (IsPedDeadOrDying(ped)) then
          wcInfo.isSitting = false
          DetachEntity(ped, true, false)
          SetEntityVelocity(wheelchairObject, 0, 0, 0)
          ClearPedTasks(ped)

          for _,v in pairs(wheelchairs) do
            if (v.obj == wheelchairObject) then
              TriggerServerEvent("bms:ems:syncWheelchair", v.nId, false, v.isPushed)
              break
            end
          end
        end
      end

      for _,v in pairs(wheelchairs) do
        if (v.obj == wheelchairObject) then
          isPushed = v.isPushed
          break
        end
      end
    end
  end)
end

function pushWheelchair(wheelchairObject)
  local ped = PlayerPedId()

  NetworkRequestControlOfEntity(wheelchairObject)

  RequestAnimDict(wheelchair.pushAnim.dict)
  while (not HasAnimDictLoaded(wheelchair.pushAnim.dict)) do
    Wait(25)
  end

	AttachEntityToEntity(wheelchairObject, ped, GetPedBoneIndex(ped, 28422), -0.00, -0.3, -0.78, 195.0, 180.0, 180.0, 0.0, false, false, true, true, 2, true)

  Citizen.CreateThread(function()
    while (IsEntityAttachedToEntity(ped, wheelchairObject)) do
      NetworkRequestControlOfEntity(wheelchairObject)
      local heading = GetEntityHeading(wheelchairObject)

      if (not IsEntityPlayingAnim(ped, wheelchair.pushAnim.dict, wheelchair.pushAnim.anim, 3)) then
        TaskPlayAnim(ped, wheelchair.pushAnim.dict, wheelchair.pushAnim.anim, 8.0, 8.0, -1, 50, 1, false, false, false)
      end

      if (IsPedDeadOrDying(ped)) then
        wcInfo.isPushing = false
        DetachEntity(wheelchairObject, true, false)
        SetEntityVelocity(wheelchairObject, 0, 0, 0)

        for _,v in pairs(wheelchairs) do
          if (v.obj == wheelchairObject) then
            TriggerServerEvent("bms:ems:syncWheelchair", v.nId, v.isSeated, false)
            break
          end
        end
      end
      Wait(50)
    end
  end)
end

function getLastBodyPartHit()
  local ped = PlayerPedId()
  local _, lastbone = GetPedLastDamageBone(ped)

  if (lastbone and lastbone ~= 0) then
    --print(string.format("lastbone: %s", lastbone))
    for k,v in pairs(injurybones) do
      for _,j in pairs(v.ids) do
        if (j == lastbone) then
          return k:gsub("_", " ")
        end
      end
    end
  end
end

local function storeLastPedComponents(ped)
  lastPedComps = {}
  lastPedProps = {}

  for i = 0, 11 do
    local did = GetPedDrawableVariation(ped, i)
    local tid = GetPedTextureVariation(ped, i)
    
    table_insert(lastPedComps, {d = did, t = tid})
  end

  for i = 0, 7 do
    local pid = GetPedPropIndex(ped, i)
    local tid = GetPedPropTextureIndex(ped, i)

    table_insert(lastPedProps, {d = did, t = tid})
  end
end

local function loadLastPedComponents(ped)
  Citizen.CreateThread(function()
    while (not HasAnimDictLoaded(turnoutAnim.dict)) do
      RequestAnimDict(turnoutAnim.dict)
      Wait(5)
    end

    TaskPlayAnim(ped, turnoutAnim.dict, turnoutAnim.anim, 2.0, 2.0, -1, 1, 0, 0, 0, 0)
    Wait(2000)
    StopAnimTask(ped, turnoutAnim.dict, turnoutAnim.anim, 2.0)
    RemoveAnimDict(turnoutAnim.dict)    
    ClearAllPedProps(ped)
    
    for i,v in pairs(lastPedComps) do
      SetPedComponentVariation(ped, i - 1, v.d, v.t, 2)
    end

    for i, v in pairs(lastPedProps) do
      SetPedPropIndex(ped, i - 1, v.d, v.t, true)
    end
  end)
end

local function getVehicleInDirection(coordFrom, coordTo, ignore)
  local rayHandle = StartShapeTestRay(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, ignore, 0)
  local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
  local isv = IsEntityAVehicle(vehicle)
  
  if (isv) then
    return vehicle
  else
    return 0
  end
end

local function isNearEmergencyVehicle()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local offset = GetOffsetFromEntityInWorldCoords(ped, 0, 5.0, 0)
  local detVeh = getVehicleInDirection(pos, offset, ped)
  local closestVeh = GetClosestVehicle(pos.x, pos.y, pos.z, 5.0, 0, 127)

  return GetVehicleClass(detVeh) == 18 or GetVehicleClass(closestVeh) == 18
end

local function setFireTurnoutGear(helmetTex)
  Citizen.CreateThread(function()
    local ped = PlayerPedId()
    
    while (not HasAnimDictLoaded(turnoutAnim.dict)) do
      RequestAnimDict(turnoutAnim.dict)
      Wait(5)
    end

    TaskPlayAnim(ped, turnoutAnim.dict, turnoutAnim.anim, 2.0, 2.0, -1, 1, 0, 0, 0, 0)
    Wait(2000)
    StopAnimTask(ped, turnoutAnim.dict, turnoutAnim.anim, 2.0)
    RemoveAnimDict(turnoutAnim.dict)
    
    local genderModel = GetEntityModel(ped)
    local maleParts = {
      {cat = 8, did = 108},   -- undershirt
      {cat = 4, did = 106},   -- pants
      {cat = 7, did = 56},    -- neck
      {cat = 11, did = 274},  -- shirt/jacket
      {cat = 0, prop = true, did = 117}   -- head acc
    }
    local femaleParts = {
      {cat = 8, did = 148},   -- undershirt
      {cat = 4, did = 115},   -- pants
      {cat = 7, did = 46},    -- neck
      {cat = 11, did = 290},  -- shirt/jacket
      {cat = 0, prop = true, did = 116}   -- head acc
    }
    local parts = {}

    if (genderModel == -1667301416) then
      parts = femaleParts
    else
      parts = maleParts
    end

    for _,v in pairs(parts) do
      if (v.prop) then
        SetPedPropIndex(ped, v.cat, v.did, helmetTex, true)
      else
        SetPedComponentVariation(ped, v.cat, v.did, 0, 2)
      end
    end
  end)
end

RegisterNetEvent("bms:ems:toggleInjured")
AddEventHandler("bms:ems:toggleInjured", function(toggle)
  if (toggle) then
    local stage
    
    exports.csrp_gamemode:getHealthStage(function(val)
      stage = val
    end)
    
    if (stage == 1) then
      SendNUIMessage({showInjured = true, injury = 25})
    elseif (stage == 2) then
      SendNUIMessage({showInjured = true, injury = 75})
    elseif (stage == 3) then
      SendNUIMessage({hideInjured = true})
    end
  else
    SendNUIMessage({hideInjured = true})
  end
end)

RegisterNetEvent("bms:ems:showfdv")
AddEventHandler("bms:ems:showfdv", function()
  exports.pnotify:SendNotification({text = #fdvehicles})
end)

RegisterNetEvent("bms:ems:changeSkin")
AddEventHandler("bms:ems:changeSkin", function()
  if (isonduty) then
    local ped = PlayerPedId()
    
    if (IsPedInModel(ped, "s_f_y_scrubs_01")) then
      --setSkin("s_m_m_paramedic_01")
    else
      --setSkin("s_f_y_scrubs_01")
    end
  end
end)

RegisterNetEvent("bms:ems:revive")
AddEventHandler("bms:ems:revive", function()
  local ped = PlayerPedId()
  local clPlayer, clDist = getClosestPlayer()
  local clped = GetPlayerPed(clPlayer)
  local sid = GetPlayerServerId(clPlayer)
  
  --TriggerServerEvent("bms:serverprint", clPlayer .. " " .. clDist)
  
  if (clped and IsPedDeadOrDying(clped) and clDist < 1.5) then
    Citizen.CreateThread(function()
      TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
      Citizen.Wait(8000)
      ClearPedTasks(ped)
      TriggerServerEvent("bms:ems:revivePlayer", sid)
    end)
  end
end)

RegisterNetEvent("bms:ems:drReviveHan")
AddEventHandler("bms:ems:drReviveHan", function()
  local ped = PlayerPedId()
  local clPlayer, clDist = getClosestPlayer()
  local clped = GetPlayerPed(clPlayer)
  local sid = GetPlayerServerId(clPlayer)
  
  if (clped and IsPedDeadOrDying(clped) and clDist < 1.5 and isonduty) then
    RequestAnimDict("amb@medic@standing@tendtodead@idle_a")

    while (not HasAnimDictLoaded("amb@medic@standing@tendtodead@idle_a")) do
      Wait(10)
    end
    
    TaskPlayAnim(ped, "amb@medic@standing@tendtodead@idle_a", "idle_b", 2.0, 2.0, -1, 49, 0, 0, 0, 0)
    Wait(8000)

    TriggerServerEvent("bms:ems:drRevivePlayer", sid)
    ClearPedTasks(ped)
    RemoveAnimDict("amb@medic@standing@tendtodead@idle_a")
  end
end)

RegisterNetEvent("bms:ems:drReviveSelf")
AddEventHandler("bms:ems:drReviveSelf", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local heading = GetEntityHeading(ped)
  
  Citizen.CreateThread(function()
    while (not HasAnimDictLoaded(revAnim.dict)) do
      RequestAnimDict(revAnim.dict)
      Wait(5)
    end

    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, heading, true, true, false)
    TaskPlayAnim(ped, revAnim.dict, revAnim.anim, 2.0, 2.0, -1, 0)
    TriggerEvent("bms:csrp_gamemode:stopRespawnTimer")
    TriggerEvent("bms:csrp_gamemode:setCanRespawn", false)
    exports.csrp_gamemode:setHealthStage(false, 3)
    SendNUIMessage({hideInjured = true})
    exports.inventory:blockInventoryOpen(false)
    RemoveAnimDict(revAnim.dict)
  end)

end)

RegisterNetEvent("bms:management:adminRevive")
AddEventHandler("bms:management:adminRevive", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local heading = GetEntityHeading(ped)
  
  NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, heading, true, true, false)
  TriggerEvent("bms:csrp_gamemode:stopRespawnTimer")
  TriggerEvent("bms:csrp_gamemode:setCanRespawn", false)

  exports.csrp_gamemode:setHealthStage(false, 3)
  exports.inventory:blockInventoryOpen(false)
  exports.vehicles:blockTrunk(false)
  exports.inventory:blockTrade(false)
  exports.inventory:blockInventoryUse(false)
  SetPedCanRagdoll(ped, true)
  SendNUIMessage({hideInjured = true})
  TriggerEvent("bms:csrp_gamemode:adminRevive")
end)

RegisterNetEvent("bms:ems:heal")
AddEventHandler("bms:ems:heal", function()
  local ped = PlayerPedId()
  local clPlayer, clDist = getClosestPlayer()
  local clped = GetPlayerPed(clPlayer)
  local sid = GetPlayerServerId(clPlayer)
  
  --TriggerServerEvent("bms:serverprint", clPlayer .. " " .. clDist)

  if (clped and clDist < 1.5) then
    if (not IsPedDeadOrDying(clped)) then
      Citizen.CreateThread(function()
        --TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
        RequestAnimDict("amb@medic@standing@tendtodead@idle_a")

        while (not HasAnimDictLoaded("amb@medic@standing@tendtodead@idle_a")) do
          Wait(10)
        end
        
        TaskPlayAnim(ped, "amb@medic@standing@tendtodead@idle_a", "idle_c", 2.0, 2.0, -1, 49, 0, 0, 0, 0)
        Citizen.Wait(8000)
        ClearPedTasks(ped)
        RemoveAnimDict("amb@medic@standing@tendtodead@idle_a")
        TriggerServerEvent("bms:ems:healPlayer", sid)
      end)
    else
      exports.pnotify:SendNotification({text = "You can not heal an unrevived player."})
    end
  end
end)

RegisterNetEvent("bms:ems:drHealHan")
AddEventHandler("bms:ems:drHealHan", function()
  local ped = PlayerPedId()
  local clPlayer, clDist = getClosestPlayer()
  local clped = GetPlayerPed(clPlayer)
  local sid = GetPlayerServerId(clPlayer)
  
  --TriggerServerEvent("bms:serverprint", clPlayer .. " " .. clDist)

  if (clped and clDist < 1.5 and isonduty) then
    if (not IsPedDeadOrDying(clped)) then
      Citizen.CreateThread(function()
        --TaskStartScenarioInPlace(ped, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
        RequestAnimDict("amb@medic@standing@tendtodead@idle_a")

        while (not HasAnimDictLoaded("amb@medic@standing@tendtodead@idle_a")) do
          Wait(10)
        end
        
        TaskPlayAnim(ped, "amb@medic@standing@tendtodead@idle_a", "idle_c", 2.0, 2.0, -1, 49, 0, 0, 0, 0)
        Citizen.Wait(8000)
        ClearPedTasks(ped)
        RemoveAnimDict("amb@medic@standing@tendtodead@idle_a")
        TriggerServerEvent("bms:ems:drHealPlayer", sid)
        
      end)
    else
      exports.pnotify:SendNotification({text = "You can not heal an unrevived player."})
    end
  end
end)

RegisterNetEvent("bms:ems:reviveSelf")
AddEventHandler("bms:ems:reviveSelf", function(healinjury)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local heading = GetEntityHeading(ped)
  
  Citizen.CreateThread(function()
    while (not HasAnimDictLoaded(revAnim.dict)) do
      RequestAnimDict(revAnim.dict)
      Wait(5)
    end
    
    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, heading, true, true, false)
    TaskPlayAnim(ped, revAnim.dict, revAnim.anim, 2.0, 2.0, -1, 0)
    TriggerEvent("bms:csrp_gamemode:stopRespawnTimer")
    TriggerEvent("bms:csrp_gamemode:setCanRespawn", false)

    if (healinjury == 1) then
      exports.csrp_gamemode:setHealthStage(false, 3)
      SendNUIMessage({showInjured = false})
    else
      exports.csrp_gamemode:setHealthStage(false, 1)
      SendNUIMessage({showInjured = true, injury = 25})
    end

    exports.inventory:blockInventoryOpen(false)
    exports.vehicles:blockTrunk(false)
    exports.inventory:blockTrade(false)
    exports.inventory:blockInventoryUse(false)
    RemoveAnimDict(revAnim.dict)
  end)
end)

RegisterNetEvent("bms:ems:drHealSelf")
AddEventHandler("bms:ems:drHealSelf", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  exports.csrp_gamemode:setHealthStage(false, 3)
  SetPedArmour(ped, 25)
  SendNUIMessage({
    hideInjured = true
  })
end)

RegisterNetEvent("bms:ems:healSelf")
AddEventHandler("bms:ems:healSelf", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  
  exports.csrp_gamemode:setHealthStage(false, 2)
  SendNUIMessage({
    showInjured = true,
    injury = 75
  })
  exports.pnotify:SendNotification({text = "You have been healed to 75% max health.  Head to a Hospital to get fully healed."})
end)

RegisterNetEvent("bms:ems:setActiveDuty")
AddEventHandler("bms:ems:setActiveDuty", function(onduty)
  --[[local isActiveDuty = false
  
  exports.management:isOnActiveDuty(function(cb)
    isActiveDuty = cb
  end)]]
  
  TriggerEvent("bms:ems:activeDutySwitch", onduty)

  local ped = PlayerPedId()
  
  if (not IsPedDeadOrDying(ped)) then
    isonduty = onduty
    TriggerEvent("bms:ems:activedutyswitch", isonduty)
    
    if (onduty) then
      --setSkin("s_m_m_paramedic_01")
      TriggerServerEvent("bms:char:autoIncomeDepositType", 2)
      TriggerServerEvent("bms:char:setEmsOnDuty", true)
      exports.pnotify:SendNotification({text = "Welcome to EMS. Head to a hospital or vehicle station for a vehicle and your gear."})
      exports.actionmenu:addAction("ems", "emsduty", "none", "Go off EMS Duty", 11, "off")
      exports.actionmenu:addAction("ems", "revive", "ped", "Revive Player", 11, "")
      exports.actionmenu:addAction("ems", "heal", "ped", "Heal Player", 11, "")
      exports.actionmenu:addAction("ems", "cpr", "ped", "Perform CPR", 11, "")
      exports.actionmenu:addAction("charcreator", "removemask", "ped", "Toggle Player Mask", 11)
      exports.actionmenu:addAction("charcreator", "removevest", "ped", "Toggle Player Vest", 11)
      exports.actionmenu:addAction("ems", "glucagon", "ped", "Administer Glucagon Injection", 11, "")
      exports.actionmenu:addAction("ems", "saline", "ped", "Administer Saline IV", 11, "")
      exports.actionmenu:addAction("ems", "inspectwounds", "ped", "Inspect Wounds", 11, "")
      exports.actionmenu:addAction("lawenforcement", "escort", "ped", "Escort Player", 11, "start")
      exports.actionmenu:addAction("lawenforcement", "escort", "ped", "End Escort", 11, "end")
      exports.actionmenu:addAction("lawenforcement", "seat", "vehicle", "Put Player Into Vehicle", 11)
      exports.actionmenu:addAction("lawenforcement", "unseat", "vehicle", "Remove Player from Vehicle", 11)
      exports.actionmenu:addAction("lawenforcement", "marktow", "vehicle", "Mark Vehicle for Tow", 11)
      exports.actionmenu:addAction("lawenforcement", "scuba", "none", "Equip Scuba", 11, "")
      exports.actionmenu:removeAction("EMS Duty", 11)
      exports.management:addActiveDuty("EMS")
    else
      showhelispawns = false

      for _,v in pairs(heliblips) do
        RemoveBlip(v)
      end

      heliblips = {}

      TriggerServerEvent("bms:char:setNormalSkin")
      TriggerServerEvent("bms:char:setEmsOnDuty", false)
      exports.pnotify:SendNotification({text = "You have returned to civilian life."})
      exports.actionmenu:removeAction("Go off EMS Duty", 11)
      exports.actionmenu:removeAction("Revive Player", 11)
      exports.actionmenu:removeAction("Heal Player", 11)
      exports.actionmenu:removeAction("Perform CPR", 11)
      exports.actionmenu:removeAction("Toggle Player Mask", 11)
      exports.actionmenu:removeAction("Toggle Player Vest", 11)
      exports.actionmenu:removeAction("Administer Glucagon Injection", 11)
      exports.actionmenu:removeAction("Administer Saline IV", 11)
      exports.actionmenu:removeAction("Inspect Wounds", 11)
      exports.actionmenu:removeAction("Escort Player", 11)
      exports.actionmenu:removeAction("End Escort", 11)
      exports.actionmenu:removeAction("Put Player Into Vehicle", 11)
      exports.actionmenu:removeAction("Remove Player from Vehicle", 11)
      exports.actionmenu:removeAction("Equip Scuba", 11)
      exports.actionmenu:removeAction("Mark Vehicle for Tow", 11)
      exports.actionmenu:addAction("ems", "emsduty", "none", "EMS Duty", 11, "")
      exports.management:removeActiveDuty("EMS")

      --TriggerEvent("bms:lawenf:clearcopblips")
    end
  end
end)

--[[RegisterNetEvent("bms:ems:setActiveEms")
AddEventHandler("bms:ems:setActiveEms", function(ids)
  local sid = GetPlayerServerId(PlayerId())
  
  for _,v in pairs(ids) do
    if (v ~= sid) then
      addEmsBlip(v)
    end
  end
end)

RegisterNetEvent("bms:ems:removeEmsBlip")
AddEventHandler("bms:ems:removeEmsBlip", function(id)
  if (emsBlipExistsFor(id)) then
    local delidx = 0
        
    for i = 1, #emsBlips do
      if (emsBlips[i].id == id) then
        delidx = i
        RemoveBlip(emsBlips[i].blip)
        break
      end
    end
    
    if (delidx > 0) then
      table_remove(emsBlips, delidx)
    end
  end
end)]]

RegisterNetEvent("bms:ems:setMenuItems")
AddEventHandler("bms:ems:setMenuItems", function()
  exports.actionmenu:addCategory("EMS", 11)
  exports.actionmenu:addAction("ems", "emsduty", "none", "EMS Duty", 11, "")
end)

RegisterNetEvent("bms:ems:addDpBlip")
AddEventHandler("bms:ems:addDpBlip", function(charName, sid)
  --TriggerServerEvent("bms:serverprint", "adding blip" .. charName .. posx)
  --local pos = vector3(posx, posy, posz)
  addDpBlip(charName, sid)
  exports.pnotify:SendNotification({text = "An injured or incapacitated civilian was added to the GPS."})
end)

RegisterNetEvent("bms:ems:activateHeliSpawns")
AddEventHandler("bms:ems:activateHeliSpawns", function()
  showhelispawns = true

  if (#heliblips == 0) then
    for _,v in pairs(helispots) do
      local blip = AddBlipForCoord(v.bx, v.by, v.bz)
      
      SetBlipSprite(blip, 43)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 0.9)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentSubstringPlayerName("EMS Helipad")
      EndTextCommandSetBlipName(blip)
      
      table_insert(heliblips, blip)
    end
  end
end)

RegisterNetEvent("bms:ems:inspectWounds")
AddEventHandler("bms:ems:inspectWounds", function(rid)
  local damagestr = getWeaponDamageString()
  local injstr = ""

  if (lastinjuries and #lastinjuries > 0) then
    for _,v in pairs(lastinjuries) do
      injstr = injstr .. v .. ", "
    end

    injstr = injstr:sub(1, -3)
    injstr = string.format("%s in the %s", lastinjurytype, injstr)
  else
    injstr = string.format("The persons injuries could not be immediately identified, but look like %s", damagestr)
  end

  TriggerServerEvent("bms:ems:woundResults", injstr, rid, lastinjuries)
end)

RegisterNetEvent("bms:ems:showWoundResults")
AddEventHandler("bms:ems:showWoundResults", function(dmgstr, lastinjuries)
  local ped = PlayerPedId()
  local emote = "CODE_HUMAN_MEDIC_KNEEL"
  local anim = {dict = "amb@medic@standing@tendtodead@idle_a", anim = "idle_b"}

  while (not HasAnimDictLoaded(anim.dict)) do
    RequestAnimDict(anim.dict)
    Wait(10)
  end
  
  SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"))
  TaskPlayAnim(ped, anim.dict, anim.anim, 2.0, 2.0, -1, 49)
  RemoveAnimDict(anim.dict)
  SendNUIMessage({showInjurySystem = true, displaymode = true, detdamage = dmgstr, injuries = lastinjuries})
  showinginjury = true -- only set to true for EMS viewing, so we can track key presses
end)

RegisterNetEvent("bms:ems:getPingLocation")
AddEventHandler("bms:ems:getPingLocation", function(civsrc, char)
  if (civsrc) then
    local rped = GetPlayerPed(GetPlayerFromServerId(civsrc))
    local rpos = GetEntityCoords(rped)

    local streetA, streetB = Citizen.InvokeNative(0x2EB41072B4C1E4C0, rpos.x, rpos.y, rpos.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
    local street = {}
    
    if not ((streetA == lastStreetA or streetA == lastStreetB) and (streetB == lastStreetA or streetB == lastStreetB)) then
      lastStreetA = streetA
      lastStreetB = streetB
    end
    
    if (lastStreetA ~= 0) then
      table_insert(street, GetStreetNameFromHashKey(lastStreetA))
    end
    
    if (lastStreetB ~= 0) then
      table_insert(street, GetStreetNameFromHashKey(lastStreetB))
    end

    TriggerEvent("chatMessage", "EMS Dispatch", {255, 0, 0}, string.format("Call from %s [%s] traced to %s.", char.name, char.src, table.concat(street, " & ")))
    addPingBlip(rped)
  end
end)

RegisterNetEvent("bms:ems:setHealSpots")
AddEventHandler("bms:ems:setHealSpots", function(heals)
  healspots = heals
end)

RegisterNetEvent("bms:ems:healPlayerToMaxHealth")
AddEventHandler("bms:ems:healPlayerToMaxHealth", function(data)
  if (data.healcost) then
    local ped = PlayerPedId()

    exports.csrp_gamemode:setHealthStage(false, 3)
    exports.pnotify:SendNotification({text = string.format("You have been fully healed to max health cap for <font color='limegreen'>$%s</font>.", data.healcost)})
    SendNUIMessage({
      hideInjured = true
    })
  elseif (data.msg) then
    exports.pnotify:SendNotification({text = data.msg})
  end

  heallock = false
end)

RegisterNUICallback("bms:ems:sendXrayResults", function(data)
  if (data and #data > 0) then
    TriggerServerEvent("bms:ems:sendXrayResult", data)
  end
  
  SetNuiFocus(false, false)
  inxray = false
end)

RegisterNetEvent("bms:ems:traumabed")
AddEventHandler("bms:ems:traumabed", function(data)
  TriggerEvent("bms:lawenf:notifyDetachEntity", data.detsrc, function()
    local ped = PlayerPedId()
    local bed = data.ccart
    local hkb = nurse.bedanim.dict
    
    RequestAnimDict(hkb)

    while (not HasAnimDictLoaded(hkb)) do
      Wait(20)
    end

    TaskPlayAnimAdvanced(ped, hkb, nurse.bedanim.anim, bed.bedpos.x, bed.bedpos.y, bed.bedpos.z - 0.475, 0, 341.36, 0, 8.0, -1, -1, 1)
    RemoveAnimDict(hkb)
  end)
end)

RegisterNetEvent("bms:ems:injection")
AddEventHandler("bms:ems:injection", function()
  local ped = PlayerPedId()
  RequestModel(GetHashKey("prop_syringe_01"))
  
  while not HasModelLoaded(GetHashKey("prop_syringe_01")) do
    Wait(10)
  end

  RequestAnimDict("missfbi3_syringe")
  while (not HasAnimDictLoaded("missfbi3_syringe")) do
    Wait(10)
  end

  local ppos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
  ccspawned = CreateObject(GetHashKey("prop_syringe_01"), ppos.x, ppos.y, ppos.z, true, false, false)
  SetCurrentPedWeapon(ped, 0xA2719263)
  SetModelAsNoLongerNeeded(GetHashKey("prop_syringe_01"))
  AttachEntityToEntity(ccspawned, ped, GetPedBoneIndex(ped, 28422), 0.062, 0.04, 0.0, -40.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
  Wait(1000)
  TaskPlayAnim(ped, "missfbi3_syringe", "syringe_use_player", 2.0, 2.0, -1, 49, 0, 0, 0, 0)
  Wait(750)
  DetachEntity(ccspawned, 1, 1)
  DeleteEntity(ccspawned)
  Wait(1600)
  ClearPedTasks(ped)
  RemoveAnimDict("missfbi3_syringe")

end)

RegisterNetEvent("bms:ems:setextra")
AddEventHandler("bms:ems:setextra", function(compid, action)
  local veh = GetVehiclePedIsIn(PlayerPedId())
  local cid = tonumber(compid)

  if (not veh) then
    return
  end

  if (action == "allon") then
    for i = 0, 32 do
      SetVehicleExtra(veh, i, 0)
    end
  elseif (action == "alloff") then
    for i = 0, 32 do
      SetVehicleExtra(veh, i, 1)
    end
  elseif (action == "toggle") then
    local toggle = IsVehicleExtraTurnedOn(veh, cid)
    
    SetVehicleExtra(veh, cid, toggle)
  end
end)

AddEventHandler("bms:ems:performCpr", function(dpedid)
  if (dpedid and dpedid > -1) then
    Citizen.CreateThread(function()
      local cpr = {dict = "missheistfbi3b_ig8_2", anim = "cpr_loop_paramedic"}
      local ped = PlayerPedId()
      local dped = GetPlayerPed(GetPlayerFromServerId(dpedid))
      local dpos = GetEntityCoords(dped)
      local dying = IsPedDeadOrDying(dped)

      if (dying) then
        local offs = GetOffsetFromEntityInWorldCoords(dped, -0.25, -0.5, 0.0)

        SetEntityCoords(ped, offs)
        TaskTurnPedToFaceEntity(ped, dped, 0.2)
        Wait(500)

        while (not HasAnimDictLoaded(cpr.dict)) do
          RequestAnimDict(cpr.dict)
          Wait(100)
        end

        TaskPlayAnim(ped, cpr.dict, cpr.anim, 8.0, -8.0, -1, 1, 0, 0, 0, 0)
        RemoveAnimDict(cpr.dict)
      end
    end)
  end
end)

RegisterNetEvent("bms:ems:createWheelchair")
AddEventHandler("bms:ems:createWheelchair", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(PlayerPedId())
  
  RequestModel(wheelchair.hash)
    
  while not HasModelLoaded(wheelchair.hash) do
    Citizen.Wait(25)
  end

  local whlchr = CreateObject(wheelchair.hash, pos.x, pos.y, pos.z - 1.0, true, true, true)
  PlaceObjectOnGroundProperly(whlchr)
  SetModelAsNoLongerNeeded(wheelchair.hash)
  NetworkRegisterEntityAsNetworked(whlchr)

  local nId = NetworkGetNetworkIdFromEntity(whlchr)
  TriggerServerEvent("bms:ems:syncWheelchair", nId, false, false)
end)

RegisterNetEvent("bms:ems:deleteWheelchair")
AddEventHandler("bms:ems:deleteWheelchair", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local minDist = 0
  local nId

  for _,v in pairs(wheelchairs) do
    if (not v.obj) then
      v.obj = NetworkGetEntityFromNetworkId(v.nId)
    end

    local objPos = GetEntityCoords(v.obj)
    local dist = #(pos - objPos)

    if (dist < minDist or minDist == 0) then
      minDist = dist
      nId = v.nId
    end
  end
  
  if (nId) then
    TriggerServerEvent("bms:ems:deleteWheelchair", nId)
  end
end)

RegisterNetEvent("bms:ems:syncWheelchairs")
AddEventHandler("bms:ems:syncWheelchairs", function(wheelchairList)
  if (wheelchairList) then
    wheelchairs = wheelchairList
  end
end)

RegisterNetEvent("bms:ems:showInjury")
AddEventHandler("bms:ems:showInjury", function()
  local damagestr = getWeaponDamageString()

  if (damagestr == "no visible melee or gun shot wounds") then
    damagestr = ""
  end

  SendNUIMessage({showInjurySystem = true, detdamage = damagestr})
  SetNuiFocus(true, true)
end)

AddEventHandler("bms:ems:showInjurySelector", function()
  local damagestr = getWeaponDamageString()
  local selectedbodypart = getLastBodyPartHit()

  if (damagestr == "no visible melee or gun shot wounds") then
    damagestr = ""
  end

  SendNUIMessage({showInjurySystem = true, detdamage = damagestr, selectedpart = selectedbodypart})
  SetNuiFocus(true, true)
end)

--[[RegisterNetEvent("sptest")
AddEventHandler("sptest", function()
  local ped = PlayerPedId()
  local hash = GetHashKey("s_f_y_scrubs_01")
    
  RequestModel(hash)
  
  while not HasModelLoaded(hash) do
    Wait(0)
  end

  SetVehicleAutoRepairDisabled(veh, true)

  if (action == "allon") then
    for i = 0, 32 do
      SetVehicleExtra(veh, i, 0)
    end
  elseif (action == "alloff") then
    for i = 0, 32 do
      SetVehicleExtra(veh, i, 1)
    end
  elseif (action == "toggle") then
    local toggle = IsVehicleExtraTurnedOn(veh, cid)

    SetVehicleExtra(veh, cid, toggle)
  end
end)]]

checkDpBlips()

RegisterNetEvent("bms:ems:setRoadblocks")
AddEventHandler("bms:ems:setRoadblocks", function(rbs)
  if (rbs) then
    for _,v in pairs(roadblocks) do
      if (v.zoneid) then
        RemoveSpeedZone(v.zoneid)
      end
    end

    roadblocks = rbs

    for _,v in pairs(roadblocks) do
      if (v.znpos) then
        v.zoneid = AddSpeedZoneForCoord(v.znpos.x, v.znpos.y, v.znpos.z, rbradius, 2.0, false) -- AddSpeedZoneForCoord (could not find in this manifest?)
      end
    end

    print(json.encode(roadblocks))
  end
end)

RegisterNetEvent("bms:ems:toggleFireTurnoutSuit")
AddEventHandler("bms:ems:toggleFireTurnoutSuit", function(helmetTex)
  local ped = PlayerPedId()

  if (not isNearEmergencyVehicle()) then
    exports.pnotify:SendNotification({text = "You need to be close to an emergency vehicle to use this command."})
    return
  end

  if (not inTurnoutGear) then
    storeLastPedComponents(ped)
    setFireTurnoutGear(helmetTex)
  else
    loadLastPedComponents(ped)
  end

  inTurnoutGear = not inTurnoutGear
end)

RegisterNUICallback("bms:ems:closeWindows", function()
  SetNuiFocus(false, false)
end)

RegisterNUICallback("bms:ems:setInjuries", function(data)
  lastinjuries = data.injuries or {}
  lastinjurytype = data.injurytype
  SetNuiFocus(false, false)
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)
    
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local lastveh = GetVehiclePedIsIn(ped)

    if (isonduty) then      
      for i=1,#ambMarkers do
        DrawMarker(1, ambMarkers[i].pos.x, ambMarkers[i].pos.y, ambMarkers[i].pos.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.15, 240, 70, 70, 50, 0, 0, 2, 0, 0, 0, 0)

        if (ambMarkers[i].dist < 10) then
          local dist = #(pos - ambMarkers[i].pos)
        
          if (dist < 1.0) then
            if (IsControlJustReleased(1, 38) and not blockinput) then -- E
              FreezeEntityPosition(ped, true)
              blockinput = true
              lastgarage = ambMarkers[i].idx
              setupGarageCamera(true)
              initializeGarage()
            end
          end
        end
      end
      
      if (lastgarage > 0) then
        drawGarageText("[Press ENTER to Select]\r[Press BACKSPACE to Exit]\r~g~" .. getCurCar() .. " of " .. getMaxCar())

        if (IsControlJustReleased(1, 18) and blockinput) then -- enter
          spawnGarageVehicle()
          setupGarageCamera(false)
          curGarageVehicle = 1
          maxGarageVehicles = 1

          if (previewedVehicle ~= nil) then
            DeleteVehicle(previewedVehicle)
          end

          PlaySoundFrontend(-1, "YES", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
          blockinput = false
          FreezeEntityPosition(ped, false)
        end

        if (IsControlJustReleased(1, 177) and blockinput) then -- backspace
          setupGarageCamera(false)
          curGarageVehicle = 1
          maxGarageVehicles = 1
          lastgarage = 0

          if (previewedVehicle ~= nil) then
            DeleteVehicle(previewedVehicle)
          end

          PlaySoundFrontend(-1, "NO", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
          blockinput = false
          FreezeEntityPosition(ped, false)
        end

        if (IsControlJustReleased(1, 11) and blockinput) or (IsControlPressed(1, 21) and IsControlJustPressed(1, 315) and blockinput) then -- page down OR shift +
          PlaySoundFrontend(-1, "YES", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

          if (not blockpreview) then
            blockpreview = true
            nextPreview()
          end
        end

        if (IsControlJustReleased(1, 10) and blockinput) or (IsControlPressed(1, 21) and IsControlJustPressed(1, 314) and blockinput) then -- page up OR shift -
          PlaySoundFrontend(-1, "YES", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

          if (not blockpreview) then
            blockpreview = true
            prevPreview()
          end
        end

        DisableControlAction(0, 1, true) -- LookLeftRight
        DisableControlAction(0, 2, true) -- LookUpDown
        DisableControlAction(0, 24, true) -- Attack
        DisablePlayerFiring(ped, true) -- Disable weapon firing
        DisableControlAction(0, 142, true) -- MeleeAttackAlternate
        DisableControlAction(0, 106, true)
        HideHudAndRadarThisFrame()
      end      

      for _,v in pairs(gearMarkers) do
        DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.15, 120, 255, 70, 50, 0, 0, 2, 0, 0, 0, 0)

        if (v.dist < 10) then
          local dist = #(pos - v.pos)
            
          if (dist < 1.0) then
            draw3DText(v.pos.x, v.pos.y, v.pos.z + 0.1, "~s~Press ~b~[E]~s~ to get your gear.", 0.31)

            if (IsControlJustReleased(1, 38)) then -- E
              giveGearToEms()
              exports.pnotify:SendNotification({text = "Your gear has been given to you."})
            end
          end
        end
      end

      if (showhelispawns) then
        for _,v in pairs(helispots) do
          local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)

          if (dist < 20) then
            DrawMarker(1, v.x, v.y, v.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.15, 255, 180, 50, 50, 0, 0, 0, 0, 0, 0, 0)

            if (dist < 1.2) then
              draw3DText(v.x, v.y, v.z + 0.1, "Press ~b~E~w~ to get a Medevac.", 0.31)

              if (IsControlJustReleased(1, 38)) then
                spawnHelicopter(v, v.warpin)
              end
            end
          end
        end
      end

      if (lastveh and lastveh ~= 0) then
        local speed = GetEntitySpeed(lastveh)

        if (speed < 0.2 and not roadblockset) then
          local lights = DecorGetBool(lastveh, "lightsOn")

          if (lights) then
            if (rtimeout == 0) then
              rtimeout = GetGameTimer()
            end

            if (GetGameTimer() > rtimeout + rbstopdelay) then
              roadblockset = true
              
              local vpos = GetEntityCoords(lastveh)

              print("Setting roadblock")

              exports.management:TriggerServerCallback("bms:ems:setRoadblock", function()
                
              end, {x = vpos.x, y = vpos.y, z = vpos.z})
            end
          end
        elseif (roadblockset) then
          local lights = DecorGetBool(lastveh, "lightsOn")

          if (speed > 0.2 or not lights) then
            print("Clearing roadblock")
            roadblockset = false
            rtimeout = 0
            exports.management:TriggerServerCallback("bms:ems:removeRoadblock")
          end
        end
      end
    end
    
    if (isLastVehEmsVeh()) then
      local lastveh = GetVehiclePedIsIn(ped, true)

      if (lastveh ~= 0 and not IsPedInAnyVehicle(ped)) then
        local vpos = GetEntityCoords(lastveh)
        local dist = #(pos - vpos)
              
        if (dist < 40) then
          local offs = GetOffsetFromEntityInWorldCoords(lastveh, 0.0, -3.0, 0.2)
          local dist1 = Vdist(pos.x, pos.y, pos.z, offs.x, offs.y, offs.z)

          if (dist1 < 20) then
            DrawMarker(1, offs.x, offs.y, offs.z, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.15, 250, 20, 20, 50, 0, 0, 0, 0, 0, 0, 0)

            if (dist1 < 1.2) then
              draw3DText(offs.x, offs.y, offs.z + 0.1, "Press ~b~[E]~s~ to get a wheel chair.")

              if (IsControlJustReleased(1, 38)) then
                
              end
            end
          end
        end
      end
    end

    for _,v in pairs(healMarkers) do
      DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.2, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 0.4, 240, 70, 70, 78, 0, 0, 0, 0, 0, 0, 0)
      
      if (v.dist < 10) then
        local dist = #(pos - v.pos)
        
        if (dist < 1) then
          drawClientText("Press ~b~[E]~s~ to heal yourself to max health cap.  This will cost ~g~$3000~s~.")

          if (not heallock) then
            if (IsControlJustReleased(1, 38)) then
              local stage = 1

              exports.csrp_gamemode:getHealthStage(function(val)
                stage = val
              end)

              if (stage < 3) then
                heallock = true
                TriggerServerEvent("bms:ems:healPlayerToMaxHealth")
              else
                exports.pnotify:SendNotification({text = "You are already at your maximum health cap."})
              end
            end
          end
        end
      end
    end

    --[[for _,v in pairs(xrayspots) do
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)

      if (dist < 80.0) then
        DrawMarker(1, v.x, v.y, v.z - 1.000001, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.2, 0, 210, 50, 160, 0, 0, 0, 0, 0, 0, 0)
        
        if (dist < 2.0) then
          if (not inxray) then
            draw3DText(v.x, v.y, v.z + 0.55, "Press ~b~E~w~ to use the X-Ray machine.")
          end

          if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
            SendNUIMessage({showXray = true})
            SetNuiFocus(true, true)
            inxray = true
          end
        end
      end
    end]]

    for _,v in pairs(crashMarkers) do
      DrawMarker(21, v.pos.x, v.pos.y, v.pos.z, 0, 0, 0, 0, 0, 0, 0.6, 0.6, 0.6, 240, 70, 70, 50, 0, 0, 0, 1, 0, 0, 0)

      if (v.dist < 10) then
        local dist = #(pos - v.pos)
        
        if (dist < 1.6) then
          if (not nurse.inc) then
            exports.lawenforcement:isEscorting(function(escorting, escped)
              if (escorting) then
                draw3DText(v.pos.x, v.pos.y, v.pos.z + 0.25, "Press ~b~[E]~s~ to call the trauma nurse.")

                if (IsControlJustReleased(1, 38)) then
                  DetachEntity(GetPlayerPed(escped), true, true)
                  TriggerServerEvent("bms:ems:traumabed", {detped = escped, ccart = v})
                  exports.lawenforcement:setEscorting(false, 0)
                  spawnNurse(v, escped)
                end
              end
            end)
          end
        end
      end
    end

    if (nurse.inc) then
      local hkt = nurse.tendanim.dict

      RequestAnimDict(hkt)
      
      while (not HasAnimDictLoaded(hkt)) do
        Wait(20)
      end

      Wait(1500)
      TaskTurnPedToFaceEntity(nurse.nped, nurse.aped, 1000)
      Wait(1000)
      TaskPlayAnim(nurse.nped, hkt, nurse.tendanim.anim, 8.0, -8, -1, 1, 0, 0, 0, 0)
      Wait(30000)
      ClearPedTasks(nurse.nped)
      DeletePed(nurse.nped)
      nurse.nped = nil
      nurse.aped = nil
      nurse.inc = false
    end

    -- wheelchair handling
    if (not wcInfo.isSitting and not wcInfo.isPushing) then
      for _,v in pairs(wheelchairs) do
        if (not v.obj) then
          NetworkRequestControlOfNetworkId(v.nId)
          v.obj = NetworkGetEntityFromNetworkId(v.nId)
        end

        local wcPos = GetEntityCoords(v.obj)
        local dist = #(pos - wcPos)

        if (dist < 20) then
          local wcVec = GetEntityForwardVector(v.obj)
          local sitPos = (wcPos + wcVec * -0.5)
          local pushPos = (wcPos + wcVec * 0.3)
          local sitDist = xyDist(pos, sitPos)
          local pushDist = xyDist(pos, pushPos)

          if (sitDist < 0.7 and not v.isSeated) then
            exports.jobs:draw3DTextGlobal(sitPos.x, sitPos.y, sitPos.z, "Press ~b~[H]~s~ to sit in the wheelchair", 0.3)

            if (IsControlJustReleased(1, 74)) then -- H
              wcInfo.currWc = v
              sitWheelchair(v.obj)
              wcInfo.isSitting = true
              TriggerServerEvent("bms:ems:syncWheelchair", v.nId, true, v.isPushed)
            end
          end

          if (pushDist < 0.7 and not v.isPushed) then
            exports.jobs:draw3DTextGlobal(pushPos.x, pushPos.y, pushPos.z, "Press ~b~[H]~s~ to push the wheelchair", 0.3)

            if (IsControlJustReleased(1, 74)) then -- H
              wcInfo.currWc = v
              pushWheelchair(v.obj)
              wcInfo.isPushing = true
              TriggerServerEvent("bms:ems:syncWheelchair", v.nId, v.isSeated, true)
            end
          end
        end
      end
    elseif (wcInfo.isSitting and IsControlJustReleased(1, 74)) then -- H
      NetworkRequestControlOfEntity(wcInfo.currWc.obj)
      wcInfo.isSitting = false
      DetachEntity(ped, true, false)
      SetEntityVelocity(wcInfo.currWc.obj, 0, 0, 0)
      ClearPedTasks(ped)

      TriggerServerEvent("bms:ems:syncWheelchair", wcInfo.currWc.nId, false, wcInfo.currWc.isPushed)
    elseif (wcInfo.isPushing and IsControlJustReleased(1, 74)) then -- H
      NetworkRequestControlOfEntity(wcInfo.currWc.obj)
      wcInfo.isPushing = false
      DetachEntity(wcInfo.currWc.obj, true, false)
      SetEntityVelocity(wcInfo.currWc.obj, 0, 0, 0)
      ClearPedTasks(ped)

      TriggerServerEvent("bms:ems:syncWheelchair", wcInfo.currWc.nId, wcInfo.currWc.isSeated, false)
    end

    if (showinginjury and IsControlJustReleased(0, 201)) then
      SendNUIMessage({hideInjurySystem = true})
      showinginjury = false
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1500)

    local pos = GetEntityCoords(PlayerPedId())
    local hMarkers = {}
    local iter = 0

    if (#hospitalBlips == 0 and #healspots > 0) then
      addHospitalBlips()
    end

    for i=1,#healspots do
      local dist = #(pos - healspots[i].pos)

      if (dist < 65) then
        iter = iter + 1
        hMarkers[iter] = healspots[i]
        hMarkers[iter].dist = dist
      end
    end

    healMarkers = hMarkers
    local cMarkers = {}
    iter = 0

    for i=1,#crashcarts do
      local dist = #(pos - crashcarts[i].pos)

      if (dist < 45) then
        iter = iter + 1
        cMarkers[iter] = crashcarts[i]
        cMarkers[iter].dist = dist
      end
    end

    crashMarkers = cMarkers

    if (isonduty) then
      if (#ambblips == 0) then
        setupBlips()
      end

      if (#gearBlips == 0) then
        addGearBlips()
      end

      local aMarkers = {}
      iter = 0
      
      for i = 1, #ambspots do
        local dist = #(pos - ambspots[i].pos)

        if (dist < 65) then
          iter = iter + 1
          aMarkers[iter] = ambspots[i]
          aMarkers[iter].dist = dist
          aMarkers[iter].idx = i
        end
      end

      ambMarkers = aMarkers
      local gMarkers = {}
      iter = 0

      for i=1,#gearspots do
        local dist = #(pos - gearspots[i].pos)

        if (dist < 65) then
          iter = iter + 1
          gMarkers[iter] = gearspots[i]
          gMarkers[iter].dist = dist
        end
      end

      gearMarkers = gMarkers
    else
      if (ambblips and #ambblips > 0) then
        for _,v in pairs(ambblips) do
          RemoveBlip(v)
        end
        
        ambblips = {}
      end

      if (gearBlips and #gearBlips > 0) then
        for _,v in pairs(gearBlips) do
          RemoveBlip(v)
        end
        
        gearBlips = {}
      end
    end
  end
end)
