local table_insert = table.insert
local DrawMarker = DrawMarker
local prisonCoords = vec3(1707.934, 2530.336, 45.564)
local releaseCoords = vec3(1852.0, 2585.0, 45.0)
local inPrison = false
local prisonSentenceTime = 0
local prisonElapsedTime = 0
local timerem
local charName
local prisonRadius = 200 -- determines how far from prisonCoords the player can get before being teleported back
local prisonReleaseSpot = vec(1775.281, 2551.932, 45.565)
local prisonReleaseBlip
local releasePending = false
local breakspots = {
  {pos = {x = 1826.806, y = 2573.722, z = 45.672}, reqtool = "High Grade C4 (Prison Break Tool)"}
}
local breakrole = 0 -- 1 for person breaking in, 2 for the person 1 is breaking out
local breakstage = 0
local role1spots = {
  {pos = {x = 1773.478, y = 2420.635, z = 45.456}}
}
local role2spots = {
  {pos = {x = 1617.722, y = 2524.312, z = 45.564}},
  {pos = {x = 1557.130, y = 2473.955, z = 45.400}},
  {pos = {x = 1651.458, y = 2405.256, z = 45.402}},
  {pos = {x = 1770.245, y = 2422.401, z = 45.064}}
}
local prisonBreakOutside = {
  {pos = {x = 1773.478, y = 2420.635, z = 45.456}}
}
local lastbreakspot = 0
local currolespot = 1
local alarmsoundid = 0
local role2wait = false
local role2waittime = 30000
local role2curmarker = 1
local opprolecomplete = false
local cancelwarned = false
local hardcuff = false
local softcuff = false
local waitcuffpress = false
local doublecuffpress = false
local prosters = {
  {pos = vec(1840.573, 2581.083, 47.016)},
  {pos = vec(1667.624, 2568.933, 51.242)}
}
local rosterwait = false
local isleo = false
local towers = {}
local guardloadout = {
  "WEAPON_HEAVYSNIPER"
}
local hastowerkit = false
local kitremrange = 125
local lsspots = {
  {pos = {x = 1671.7969970703, y = 2571.7270507813, z = 50.254734039307}},
  {pos = {x = 1712.0076904297, y = 2571.8022460938, z = 50.475933074951}}
}
local lsvc = 9999 -- loudspeaker voice channel, use exports.playerhousing:getVchan and exports.communications:getVchan to get last known vc
local usingls = false
local lkvc = 0
local cameras = {
  {x = 1834.3273925781, y = 2604.5627441406, z = 46.298450469971, offrot = {x = 0, y = 0, z = -70.749}, desc = "Front Gate"},
  {x = 1835.8975830078, y = 2602.8330078125, z = 50.171653747559, offrot = {x = -7.499, y = -1.722, z = 58.249}, desc = "Front Gate 2"},
  {x = 1836.115, y = 2579.956, z = 48.262, offrot = {x = -16.882, y = -0.000, z = -48.819}, desc = "Main Lobby Entrance"},
  {x = 1786.757, y = 2598.417, z = 49.027, offrot = {x = -22.551, y = 0.000, z = -156.031}, desc = "Visitors Center Entrance"},
  {x = 1779.167, y = 2596.590, z = 48.118, offrot = {x = -22.299, y = -0.000, z = -132.031}, desc = "Visitors Center Sitting Area"},
  {x = 1779.956, y = 2577.121, z = 48.861, offrot = {x = -30.126, y = -0.000, z = -41.764}, desc = "Medical A"},
  {x = 1783.727, y = 2569.011, z = 49.079, offrot = {x = -31.512, y = 0.000, z = 42.394}, desc = "Visitors Security A"},
  {x = 1686.4989013672, y = 2529.1337890625, z = 58.652381896973, offrot = {x = -26.499, y = -5.724, z = 73.998}, desc = "Guard Tower A"},
  {x = 1690.6702880859, y = 2498.83203125, z = 50.126861572266, offrot = {x = -21.249, y = -9.161, z = 22.999}, desc = "Guard Tower B"},
  {x = 1771.991, y = 2577.362, z = 49.077, offrot = {x = -20.677, y = -0.000, z = 140.409}, desc = "Workout A, To Yard"},
  {x = 1691.7930908203, y = 2498.892578125, z = 50.126861572266, offrot = {x = -24.499, y = 2.345, z = -7.249}, desc = "Inmate Yard"},
  {x = 1628.895, y = 2539.548, z = 60.057, offrot = {x = -34.598, y = -0.000, z = -42.331}, desc = "Inmate Yard Overwatch"},
  {x = 1771.896, y = 2582.848, z = 49.091, offrot = {x = -34.472, y = -0.000, z = 114.457}, desc = "Laundry"},
  {x = 1772.685, y = 2588.338, z = 49.168, offrot = {x = -33.087, y = -0.000, z = 64.819}, desc = "Workshops A"},
  {x = 1621.523, y = 2635.107, z = 49.152, offrot = {x = -14.945, y = -0.000, z = -33.827}, desc = "Workshops B"}
}
local cameraspots = {
  {pos = {x = 1664.2891845703, y = 2571.4484863281, z = 50.854820251465}}, 
  {pos = {x = 1717.0932617188, y = 2571.5024414063, z = 51.101062774658}}
}
local cammode = {active = false, lastcamspot = 0, activecam = 1, cam = -1}
local dbcount = 0
local oldneckcomp = {cat = 0, part = 0, pmodel = 0}
local cbreakanims = {
  {dict = "mp_arresting", anim = "a_uncuff"}, -- master
  {hash = "WORLD_HUMAN_LEANING"} -- slave (scenerio)
}
local cuffbreakspots = {
  {pos1 = {x = 1749.3541259766, y = 3691.8427734375, z = 34.442768096924}, pos2 = {x = 1747.6572265625, y = 3690.9165039063, z = 34.405155181885}, posttf = {x = 1750.5250244141, y = 3692.3388671875, z = 34.46475982666}}, -- /teleport 1749, 3691, 34
  {pos1 = {x = 1556.3055419922, y = -2174.4953613281, z = 77.398765563965}, pos2 = {x = 1556.6130371094, y = -2172.7021484375, z = 77.450981140137}, posttf = {x = 1556.7767333984, y = -2171.8044433594, z = 77.473419189453}}, --/teleport 1556, -2172, 77
  {pos1 = {x = -2948.2561035156, y = 448.21942138672, z = 15.297803878784}, pos2 = {x = -2948.1577148438, y = 450.07727050781, z = 15.301735877991}, posttf = {x = -2948.052734375, y = 451.88919067383, z = 15.305558204651}}
}
local cuffbreaks = {
  ["1"] = {p1src = 0, p2src = 0},
  ["2"] = {p1src = 0, p2src = 0},
  ["3"] = {p1src = 0, p2src = 0}
}
local cbspotcheck = true
local blockcuffbreak = false
local curcuffbreak = {cur = 0, max = 300000} -- todo, change to 5 minutes
local mgenders = {male = 1885233650, female = -1667301416}
local breakanims = {
  ["1"] = {dict = "", anim = ""},
  ["2"] = {dict = "", anim = ""}
}
local cbreakpwait = false
local lastcbchecked = {cb = 0, spot = 0}
local welding = {active = false, bpos = {}}
local isCopOnDuty = false
local isDocOnDuty = false
local prisonBounds = {
  pos1 = vec3(1800.794, 2467.393, 35.0),
  pos2 = vec3(1596.978, 2697.254, 65.0)
}
local ziptied = false
local blockMovement = false
local playerInfo = {}
local isEscorted = false

function getPrisonCoords()
  return prisonCoords
end

function drawCuffText(text, scale, x, y)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(scale or 0.32, scale or 0.32)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x or 0.475, y or 0.88)
end

local function draw3DCuffText(x, y, z, text, pscale)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, (pscale or 0.55) * scale)
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

function getPedInDirection(coordFrom, coordTo)
  local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 4, PlayerPedId(), 0)
  local a, b, c, d, ped = GetRaycastResult(rayHandle)
  return ped
end

function setSkin(skin)
  local model = GetHashKey(skin)
  
  if (IsModelInCdimage(model) and IsModelValid(model)) then
    while not HasModelLoaded(model) do
      RequestModel(model)
      Wait(0)
    end
    
    SetPlayerModel(PlayerId(), model)
    SetPedRandomComponentVariation(PlayerPedId(), true)
    SetModelAsNoLongerNeeded(model)
  else
    --ShowRadarMessage("Skin was not found.")
    print("skin was not found.")
  end
end

function toggleCuffedBlockers(toggle)
  exports.inventory:blockInventoryOpen(toggle)
  exports.emotes:setCanEmote(not toggle)
  exports.emotes:blockHandsUp(toggle)
  exports.csrp_gamemode:blockPointing(toggle)
  exports.csrp_gamemode:blockJumping(toggle)
end

function uncuff()
  local ped = PlayerPedId()
  
  if (DecorExistOn(ped, "softcuffed")) then
    DecorSetBool(ped, "softcuffed", false)
  end

  if (DecorExistOn(ped, "hardcuffed")) then
    DecorSetBool(ped, "hardcuffed", false)
  end

  SetPedComponentVariation(ped, oldneckcomp.cat, oldneckcomp.part, 0, 2)
  SetEnableHandcuffs(ped, false)
  toggleCuffedBlockers(false)
  EnableAllControlActions(0)
  
  if (not IsPedFatallyInjured(ped)) then
    ClearPedTasksImmediately(ped)
  end

  while (not HasAnimDictLoaded("mp_uncuff_paired")) do
    RequestAnimDict("mp_uncuff_paired")
    Wait(100)
  end

  TaskPlayAnim(ped, "mp_uncuff_paired", "crook_02_p3_fwd", 8.0, -8.0, 1000, 48, 0, false, false, false)
  Wait(1000)
  RemoveAnimDict("mp_uncuff_paired")
  RemoveAnimDict("mp_arresting")
  StopAnimTask(ped, "mp_arresting", "idle", 1.2)
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

function playAnim(dict, anim, flag)
  local ped = PlayerPedId()

  while (not HasAnimDictLoaded(dict)) do
    RequestAnimDict(dict)
    Wait(10)
  end

  if (not IsEntityPlayingAnim(ped, dict, anim, 3)) then
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, flag, 0, 0, 0, 0)
  end

  RemoveAnimDict(dict)
end

function setPrisonClothes()
  local ped = PlayerPedId()
  local model = GetEntityModel(ped)

  --[[
  0: Face
  1: Mask
  2: Hair
  3: Torso
  4: Leg
  5: Parachute / bag
  6: Shoes
  7: Accessory
  8: Undershirt
  9: Kevlar
  10: Badge
  11: Torso 2
  ]]

  if (model == 1885233650) then -- male
    SetPedComponentVariation(ped, 0, -1, 0, 2)
    SetPedComponentVariation(ped, 1, -1, 0, 2)
    --SetPedComponentVariation(ped, 2, 0, 0, 2) -- hair stays normal
    SetPedComponentVariation(ped, 3, 11, 0, 2)
    SetPedComponentVariation(ped, 4, 95, 3, 2)
    SetPedComponentVariation(ped, 5, -1, 0, 2)
    SetPedComponentVariation(ped, 6, 1, 0, 2)
    SetPedComponentVariation(ped, 7, -1, 0, 2)
    SetPedComponentVariation(ped, 8, 15, 0, 2)
    SetPedComponentVariation(ped, 9, -1, 0, 2)
    SetPedComponentVariation(ped, 10, -1, 0, 2)
    SetPedComponentVariation(ped, 11, 272, 0, 2)
    
    ClearPedProp(ped, 0)
    ClearPedProp(ped, 1)
    ClearPedProp(ped, 2)
  elseif (model == -1667301416) then -- female
    -- shirt 11-4-12
    -- pants 4-4-5
    -- arms/torso 3-4-0
    SetPedComponentVariation(ped, 0, -1, 0, 2)
    SetPedComponentVariation(ped, 1, -1, 0, 2)
    --SetPedComponentVariation(ped, 2, 0, 0, 2) -- hair stays normal
    SetPedComponentVariation(ped, 3, 14, 0, 2)
    SetPedComponentVariation(ped, 4, 98, 3, 2)
    SetPedComponentVariation(ped, 5, -1, 0, 2)
    SetPedComponentVariation(ped, 6, 1, 0, 2)
    SetPedComponentVariation(ped, 7, -1, 0, 2)
    SetPedComponentVariation(ped, 8, 14, 0, 2)
    SetPedComponentVariation(ped, 9, -1, 0, 2)
    SetPedComponentVariation(ped, 10, -1, 0, 2)
    SetPedComponentVariation(ped, 11, 254, 3, 2)
    
    ClearPedProp(ped, 0)
    ClearPedProp(ped, 1)
    ClearPedProp(ped, 2)
  end
end

function isInPrisonArea(coords, checkZ)
  local inArea = false

  if (coords.x < prisonBounds.pos1.x and coords.x > prisonBounds.pos2.x) then
    if (coords.y > prisonBounds.pos1.y and coords.y < prisonBounds.pos2.y) then
      if (checkZ) then
        if (coords.z > prisonBounds.pos1.z and coords.z < prisonBounds.pos2.z) then
          inArea = true
        end
      else
        inArea = true
      end
    end
  end

  return inArea
end

function role2waitTimeout()
  local waitTime = 0
  
  Citizen.CreateThread(function()
    while role2wait do
      Wait(1000)
      waitTime = waitTime + 1000

      if (waitTime >= role2waittime) then
        role2wait = false
        TriggerServerEvent("bms:cuff:role2Status", {success = false})
      end
    end
  end)
end

function isInPrison()
  dbcount = 0
  TriggerEvent("bms:cuff:onPrisonStatusChange", inPrison)

  Citizen.CreateThread(function()
    while inPrison do
      Wait(1000)
      dbcount = dbcount + 1
      prisonElapsedTime = prisonElapsedTime + 1000
      
      local timeLeft = prisonSentenceTime - prisonElapsedTime
      
      if (prisonElapsedTime < prisonSentenceTime) then
        --exports.pnotify:SendNotification({text = string.format("You have %s minutes remaining on your sentence.", timeLeft)})
        timerem = timeLeft

        if (dbcount >= 60) then
          TriggerServerEvent("bms:char:updatePrisonTime", prisonElapsedTime / 60000, prisonSentenceTime / 60000)
          dbcount = 0
        end
      end
            
      if (prisonElapsedTime == prisonSentenceTime) then
        inPrison = false
        prisonSentenceTime = 0
        prisonElapsedTime = 0
        
        TriggerServerEvent("bms:lawenf:releasedFromPrison", charName)
        TriggerEvent("bms:releaseFromPrison")
        TriggerEvent("bms:cuff:onPrisonStatusChange", inPrison)
      end
    end
  end)
end

function teleportToOutside()
  local ped = PlayerPedId()

  TriggerServerEvent("bms:teleporter:teleportToPoint", ped, prisonBreakOutside.pos)
end

function isCuffed(cb)
  if (cb) then
    cb(hardcuff or softcuff)
  end

  return hardcuff or softcuff
end

function getCuffStatus(cb)
  local cuffStatus = isCuffed()
  local cuffState = 0

  if (cuffed) then
    if (ziptied) then
      cb(3)
      cuffState = 3
    elseif (softcuff) then
      cb(1)
      cuffState = 1
    elseif (hardcuff) then
      cb(2)
      cuffState = 2
    end
  else
    cb(0)
    cuffState = 0
  end

  return cuffState
end

function getCuffState(cb)
  local ped = PlayerPedId()

  if (IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)) then
    if (softcuff) then
      if (cb) then
        cb(1)
      end

      return 1
    else
      if (cb) then
        cb(2)
      end

      return 2
    end
  else
    if (cb) then
      cb(0)
    end

    return 0
  end
end

function enableSurvCam(camidx) -- pass 0 to deactivate
  if (cammode.cam > -1) then
    if (IsCamActive(cammode.cam)) then
      RenderScriptCams(0, 0, 3000, 1, 0)
      StopAllScreenEffects()
      cammode.cam = -1
    end
  end
  
  if (camidx > 0) then
    local cam = cameras[camidx]

    cammode.cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", cam.x, cam.y, cam.z, 0, 0, 0, GetGameplayCamFov(), 0, 0)
    SetCamActive(cammode.cam, true)
    RenderScriptCams(1, 0, 3000, 1, 0)
    SetCamRot(cammode.cam, cam.offrot.x, cam.offrot.y, cam.offrot.z, 2)
  end
end

function isPlayerInPrison(cb)
  if (cb) then
    cb(inPrison)
  end
end

function startBreakTimer(index, type)
  local ped = PlayerPedId()
  
  Citizen.CreateThread(function()
    while (breakingcuffs) do
      Wait(1000)

      curcuffbreak.cur = curcuffbreak.cur + 1000

      if (curcuffbreak.cur >= curcuffbreak.max) then
        breakingcuffs = false
        
        if (type == 1) then
          -- break player handcuffs here
          TriggerEvent("bms:Handcuff")
          Wait(1000)
          TriggerEvent("bms:Uncuff")
          EnableAllControlActions(0)
          TriggerServerEvent("bms:cuff:cuffBreakComplete", index)
        end

        curcuffbreak.cur = 0
        blockcuffbreak = false
        
        if (welding.active) then
          welding.active = false
          welding.bpos = {}
        end
        
        ClearPedTasks(ped)
      end
    end
  end)
end

function startCuffBreak(index, type)
  breakingcuffs = true
  startBreakTimer(index, type)
  
  print(string.format("cuffbreaks: %s", json.encode(cuffbreaks)))

  local spot = cuffbreakspots[index]
  local pspot = cuffbreaks[tostring(index)]
  local pos
  local ped = PlayerPedId()
  
  TaskTurnPedToFaceCoord(ped, spot.posttf.x, spot.posttf.y, spot.posttf.z, 1500)
  Wait(1500)

  if (type == 1) then
    pos = spot.pos1
  else
    pos = spot.pos2
    local rped = GetPlayerPed(GetPlayerFromServerId(pspot.p1src))

    if (rped) then
      local mpos = GetOffsetFromEntityInWorldCoords(rped, 0.0, -0.5, 0.0)

      TaskGoToCoordAnyMeans(ped, mpos.x, mpos.y, mpos.z, 1.0, 0, 0, 786603.0, 0)
      Wait(1250)
      TaskTurnPedToFaceEntity(ped, rped, 500)
      Wait(500)
      TaskStartScenarioInPlace(ped, "WORLD_HUMAN_WELDING", 0, true) -- change to normal duck with spawned prop? prop has no sfx or pfx
      SetPedCanArmIk(ped, true)
      --playAnim("amb@medic@standing@kneel@base", "base", 50)
      --Wait(1000)

      local bindex = GetPedBoneIndex(rped, 0xDEAD)
      local bpos = GetWorldPositionOfEntityBone(rped, bindex) -- right hand
      print(string.format("hand bone pos: %s, %s, %s", bpos.x, bpos.y, bpos.z))

      welding.active = true
      welding.bpos = bpos
      --[[if (bpos) then
        SetIkTarget(ped, 4, 0, 0, bpos.x, bpos.y, bpos.z, 0, 8.0, 8.0)
      end]]
    end
  end

  Citizen.CreateThread(function()
    while (breakingcuffs) do
      Wait(1)

      local ped = PlayerPedId()
      local isdead = IsPedDeadOrDying(ped)

      if (isdead) then
        ClearPedTasks(ped)
        
        if (welding.active) then
          welding.active = false
          welding.bpos = {}
        end

        breakingcuffs = false
        curcuffbreak.cur = 0
        exports.pnotify:SendNotification({text = "Breaking the cuffs has failed because you entered combat."})
        exports.management:TriggerServerCallback("bms:cuff:cancelCuffBreak", function()
          blockcuffbreak = false
          cbreakpwait = false
        end, {index = index, type = type})
      else
        draw3DCuffText(pos.x, pos.y, pos.z + 0.2, string.format("Breaking hand cuffs.. %s seconds remaining.", math.floor((curcuffbreak.max - curcuffbreak.cur) / 1000)), 0.3)
      end
    end
  end)
end

function doCuffSpotChecks(spot, type, index)
  if (breakingcuffs) then
    return
  end

  local spotsrc = 0
  local spotpos

  if (type == 1) then
    spotsrc = spot.p1src
    spotpos = cuffbreakspots[index].pos1
  elseif (type == 2) then
    spotsrc = spot.p2src
    spotpos = cuffbreakspots[index].pos2
  end

  --print(string.format("%s, %s", spotsrc, json.encode(spotpos)))

  if (spotsrc > 0) then
    local msrc = GetPlayerServerId(PlayerId())

    if (spotsrc == msrc) then
      draw3DCuffText(spotpos.x, spotpos.y, spotpos.z + 0.15, "Waiting for other party.  Press ~b~E~w~ to cancel.", 0.3)

      if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
        exports.management:TriggerServerCallback("bms:cuff:cancelCuffBreak", function()
          blockcuffbreak = false
          cbreakpwait = false
        end, {index = index, type = type})
      end
      return
    else
      draw3DCuffText(spotpos.x, spotpos.y, spotpos.z + 0.15, "This is in use by someone else.", 0.3)
    end
  else
    if (cbreakpwait) then
      draw3DCuffText(spotpos.x, spotpos.y, spotpos.z + 0.15, "Waiting for other party.  Press ~b~E~w~ to cancel.", 0.3)

      if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
        exports.management:TriggerServerCallback("bms:cuff:cancelCuffBreak", function()
          blockcuffbreak = false
          cbreakpwait = false
        end, {index = index, type = type})
      end
      return
    end
    
    if (type == 1) then
      draw3DCuffText(spotpos.x, spotpos.y, spotpos.z + 0.15, "Press ~b~E~w~ to remove your hand cuffs.", 0.3)
    else
      draw3DCuffText(spotpos.x, spotpos.y, spotpos.z + 0.15, "Press ~b~E~w~ to use this tool to remove someones hand cuffs.", 0.3)
    end

    if (not blockcuffbreak) then
      if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
        blockcuffbreak = true
        exports.management:TriggerServerCallback("bms:cuff:updateCuffBreak", function(data)
          print(json.encode(data))
          local start = data.start
          local wait = data.wait
          local breakwait = data.breakwait
          local breaks = data.cuffbreaks

          if (breaks) then
            cuffbreaks = breaks
          else
            print("cuffbreaks was nil >> doCuffSpotChecks")
          end

          if (breakwait) then
            cbreakpwait = false
          end
          
          if (start) then
            local idx = data.index
            local type = data.type

            startCuffBreak(index, type)
          elseif (wait) then
            cbreakpwait = true
          else
            if (type == 1) then
              startCuffBreak(index, type)
            end
          end
        end, {index = index, type = type})
      end
    end
  end
end

function setIsOnDutyCop(val)
  isCopOnDuty = val
end

function setIsDocOnDuty(val)
  isDocOnDuty = val
end

local function disableInput()
  local ped = PlayerPedId()

  DisableControlAction(0, 32, true)  -- Movement
  DisableControlAction(0, 31, true)  --
  DisableControlAction(0, 34, true)  --
  DisableControlAction(0, 30, true)  --
  DisableControlAction(0, 24, true)  -- Attack
  DisablePlayerFiring(ped, true)     -- Disable weapon firing
  DisableControlAction(0, 142, true) -- MeleeAttackAlternate
  DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
  DisableControlAction(0, 37, true)  -- SelectWeapon
  DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
  DisableControlAction(0, 25, true)  -- INPUT_AIM
end

AddEventHandler("bms:lawenf:activedutyswitch", function(toggle)
  isCopOnDuty = toggle
  --isleo = toggle -- The fuck is this?

  if (toggle) then
    exports.management:TriggerServerCallback("bms:cuff:getTowers", function(ptowers)
      towers = ptowers
    end)
  else
    towers = {}
  end
end)

AddEventHandler("bms:cc:componentsChanged", function(comps, props, overlays, tattoos, mpskin)
  if (comps) then
    --print(string.format("bmc:cc:componentsChanged comps >> %s", json.encode(comps)))
    oldneckcomp.cat = 7

    for _,v in pairs(comps) do
      if (v.cid == 7) then
        local ped = PlayerPedId()
        local pmodel = GetEntityModel(ped)
        
        oldneckcomp.part = v.draw or 0
        oldneckcomp.model = pmodel
        break
      end
    end
  else
    print("comps was nil in cl_cuff.lua >> bms:cc:componentsChanged")
  end
end)

RegisterNetEvent("bms:Handcuff")
AddEventHandler("bms:Handcuff", function()
  local ped = PlayerPedId()

  Citizen.CreateThread(function()
    if (oldneckcomp.model == mgenders.male) then
      SetPedComponentVariation(ped, 7, 41, 0, 2)
    else
      SetPedComponentVariation(ped, 7, 25, 0, 2)
    end

    if (not override) then
      if (not DecorIsRegisteredAsType("hardcuffed", 2)) then
        DecorRegister("hardcuffed", 2)
      end
  
      DecorSetBool(ped, "hardcuffed", true)
    end

    while (not HasAnimDictLoaded("mp_arresting")) do
      RequestAnimDict("mp_arresting")
      Wait(50)
    end
    
    while (not HasAnimDictLoaded("mp_arrest_paired")) do
      RequestAnimDict("mp_arrest_paired")
      Wait(50)
    end
    --TaskPlayAnim(ped, "mp_arrest_paired", "crook_p2_back_left", 8.0, -8.0, 5500, 33, 0, false, false, false)
    --Wait(4800)
    TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 15, 0, 0, 0, 0)
    SetEnableHandcuffs(ped, true)
    toggleCuffedBlockers(true)
    hardcuff = true
    RemoveAnimDict("mp_arresting")
    RemoveAnimDict("mp_arrest_paired")
  end)
end)

RegisterNetEvent("bms:Uncuff")
AddEventHandler("bms:Uncuff", function()
  uncuff()
  softcuff = false
  hardcuff = false
  ziptied = false
  toggleCuffedBlockers(false)
end)

RegisterNetEvent("bms:cuff:softHandcuff")
AddEventHandler("bms:cuff:softHandcuff", function(isZiptie, playintro)
  local ped = PlayerPedId()
  --print(string.format("isZiptie: %s", isZiptie))

  Citizen.CreateThread(function()
    if (not isZiptie) then
      if (not DecorIsRegisteredAsType("softcuffed", 2)) then
        DecorRegister("softcuffed", 2)
      end
  
      DecorSetBool(ped, "softcuffed", true)
    end
    
    while (not HasAnimDictLoaded("mp_arresting")) do
      RequestAnimDict("mp_arresting")
      Wait(50)
    end
    
    if (oldneckcomp.model == mgenders.male) then
      SetPedComponentVariation(ped, 7, 41, 0, 2)
    else
      SetPedComponentVariation(ped, 7, 25, 0, 2)
    end

    if playintro then
      while (not HasAnimDictLoaded("mp_arrest_paired")) do
        RequestAnimDict("mp_arrest_paired")
        Wait(50)
      end
      TaskPlayAnim(ped, "mp_arrest_paired", "crook_p2_back_left", 8.0, -8.0, 5500, 33, 0, false, false, false)
    end

    blockMovement = true
    FreezeEntityPosition(ped, true)
    Wait(4800)
    TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
    SetEnableHandcuffs(ped, true)
    Wait(1600)
    blockMovement = false
    FreezeEntityPosition(ped, false)

    if (isZiptie) then
      ziptied = true
    end

    hardcuff = false
    softcuff = true
    toggleCuffedBlockers(true)
    RemoveAnimDict("mp_arresting")
    RemoveAnimDict("mp_arrest_paired")
  end)
end)

RegisterNetEvent("bms:Prison")
AddEventHandler("bms:Prison", function(id, time, reason, chrName)
  -- sentence and send to prison
  local ped = PlayerPedId()
  charName = chrName
  
  Citizen.CreateThread(function()
    Wait(500)

    ClearPedSecondaryTask(ped)
    SetEnableHandcuffs(ped, false)
    FreezeEntityPosition(ped, false)
  end)
  
  TriggerServerEvent("bms:teleporter:teleportToPoint", ped, prisonCoords)

  inPrison = true
  softcuff = false
  hardcuff = false
  ziptied = false
  toggleCuffedBlockers(false)
  prisonSentenceTime = tonumber(time * 60000)
  prisonElapsedTime = 0
  setPrisonClothes()
  isInPrison()
end)

RegisterNetEvent("bms:checkPrisonSentence")
AddEventHandler("bms:checkPrisonSentence", function(prisonNewTime, prisonMaxTime, charname)
  if (prisonElapsedTime < prisonMaxTime) then
    local ped = PlayerPedId()

    charName = charname        
    Citizen.CreateThread(function()
      TriggerServerEvent("bms:teleporter:teleportToPoint", ped, prisonCoords)
      inPrison = true
      prisonSentenceTime = prisonMaxTime * 60000
      prisonElapsedTime = prisonNewTime * 60000
      isInPrison()
      Wait(5000) -- hackish way, but works
      setPrisonClothes()
    end)
  end
end)

RegisterNetEvent("bms:releaseFromPrison")
AddEventHandler("bms:releaseFromPrison", function()
  local ped = PlayerPedId()
  
  if (IsPlayerDead(ped)) then
    local pos = GetEntityCoords(ped)

    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, 0, true, true, false)
    ClearPedTasksImmediately(ped)
    ClearPlayerWantedLevel(PlayerId())
    SetPoliceIgnorePlayer(ped, true)
    SetDispatchCopsForPlayer(ped, false)
    exports.inventory:blockInventoryOpen(false)
    TriggerServerEvent("bms:csrp_gamemode:setCanRespawn", false)
  end
  
  exports.pnotify:SendNotification({text = "Walk to the prison exit to receive your clothing and be released.  It is marked on your map."})
  
  if (not prisonReleaseBlip) then
    prisonReleaseBlip = AddBlipForCoord(prisonReleaseSpot.x, prisonReleaseSpot.y, prisonReleaseSpot.z)

    SetBlipSprite(prisonReleaseBlip, 162)
    SetBlipDisplay(prisonReleaseBlip, 4)
    SetBlipScale(prisonReleaseBlip, 0.9)
    SetBlipColour(prisonReleaseBlip, 3)
    SetBlipAsShortRange(prisonReleaseBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Prison Release")
    EndTextCommandSetBlipName(prisonReleaseBlip)
  end

  releasePending = true
  --[[local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  
  if (IsPlayerDead(ped)) then
    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, 0, true, true, false)
    ClearPedTasksImmediately(player)
    RemoveAllPedWeapons(player, true)
    ClearPlayerWantedLevel(PlayerId())
    SetPoliceIgnorePlayer(player, true)
    SetDispatchCopsForPlayer(player, false)
    exports.inventory:blockInventoryOpen(false)

    TriggerServerEvent("bms:csrp_gamemode:setCanRespawn", false)
  end

  TriggerServerEvent("bms:char:setNormalSkin")
  Wait(500)

  ClearPedSecondaryTask(ped)
  SetEnableHandcuffs(ped, false)
  FreezeEntityPosition(ped, false)
  
  TriggerServerEvent("bms:teleporter:teleportToPoint", 0, releaseCoords)

  softcuff = false
  hardcuff = false
  ziptied = false

  if (lkvc ~= 0) then
    NetworkSetVoiceChannel(lkvc)
  else
    NetworkClearVoiceChannel()
  end]]
end)

RegisterNetEvent("bms:cuff:doPrisonBreak")
AddEventHandler("bms:cuff:doPrisonBreak", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)

  for i,v in ipairs(breakspots) do
    local dist = Vdist(pos.x, pos.y, pos.z, v.pos.x, v.pos.y, v.pos.z)

    if (dist < 1.1) then
      lastbreakspot = i
      SetNuiFocus(true, true)
      
      SendNUIMessage({
        getBreakoutName = true
      })
      break
    end
  end
end)

RegisterNetEvent("bms:cuff:prisonBreakProceed")
AddEventHandler("bms:cuff:prisonBreakProceed", function(spot, spotidx)
  breakstage = 1
  breakrole = 1

  SendNUIMessage({
    doPrisonBreakTimer = true,
    breakspot = spotidx
  })
end)

RegisterNetEvent("bms:cuff:activatePrisonAlarm")
AddEventHandler("bms:cuff:activatePrisonAlarm", function()
  if (alarmsoundid > 0) then
    StopSound(alarmsoundid)
    ReleaseSoundId(alarmsoundid)
    alarmsoundid = 0
  end

  alarmsoundid = GetSoundId()
  PlaySoundFromCoord(alarmsoundid, "VEHICLES_HORNS_AMBULANCE_WARNING", alarmcoord.x, alarmcoord.y, alarmcoord.z, 0, 0, 100.0, 0)
end)

RegisterNetEvent("bms:cuff:prisonAlarmDisable")
AddEventHandler("bms:cuff:prisonAlarmDisable", function()
  if (alarmsoundid > 0) then
    StopSound(alarmsoundid)
    ReleaseSoundId(alarmsoundid)
    alarmsoundid = 0
  end
end)

RegisterNetEvent("bms:cuff:breakoutMatchStatus")
AddEventHandler("bms:cuff:breakoutMatchStatus", function(data)
  local success = data.success
  local msg = data.msg

  SetNuiFocus(false, false)

  if (success) then
    breakstage = 0
    breakrole = 0
    TriggerServerEvent("bms:cuff:doPrisonBreak", breakspots[lastbreakspot], lastbreakspot)
  else
    exports.pnotify:SendNotification({text = msg})
  end
end)

RegisterNetEvent("bms:cuff:doPrisonBreakRole2")
AddEventHandler("bms:cuff:doPrisonBreakRole2", function(charname)
  exports.pnotify:SendNotification({text = string.format("%s is breaking you out of prison.  Press <font color='limegreen'>F3</font> to break out, or press <font color='red'>F5</font> to reject.", charname), timeout = 12000})
  role2wait = true
  role2waitTimeout()
end)

RegisterNetEvent("bms:cuff:cancelPrisonBreak")
AddEventHandler("bms:cuff:cancelPrisonBreak", function(charname)
  exports.pnotify:SendNotification({text = string.format("%s declined to break out of prison or the request timed out.", charname)})
  breakstage = 0
  breakrole = 0
  lastbreakspot = 0
end)

RegisterNetEvent("bms:cuff:prisonbreakRole1Complete")
AddEventHandler("bms:cuff:prisonbreakRole1Complete", function()
  opprolecomplete = true
end)

RegisterNetEvent("bms:cuff:activateLsSystem")
AddEventHandler("bms:cuff:activateLsSystem", function(cancel)  
  if (cancel) then
    if (lkvc and lkvc > 0) then
      NetworkSetVoiceChannel(lkvc)
    else
      NetworkClearVoiceChannel()
    end

    return
  end
  
  exports.playerhousing:getVchan(function(hvc)
    exports.communications:getVchan(function(cvc)
      local vc = 0
      
      if (hvc ~= 0) then
        vc = hvc
      end

      if (cvc ~= 0) then
        vc = cvc
      end

      lkvc = vc
      NetworkSetVoiceChannel(lsvc)
    end)
  end)
end)

RegisterNetEvent("bms:cuff:updateCuffBreaks")
AddEventHandler("bms:cuff:updateCuffBreaks", function(breaks)
  if (breaks) then
    cuffbreaks = breaks
  else
    print("cuffbreaks was nil >> bms:cuff:updateCuffBreaks")
  end
end)

RegisterNetEvent("bms:cuff:cancelCuffBreak")
AddEventHandler("bms:cuff:cancelCuffBreak", function()
  cbreakpwait = false
  blockcuffbreak = false
end)

RegisterNetEvent("bms:cuff:breakwaitContinue")
AddEventHandler("bms:cuff:breakwaitContinue", function(data)
  if (data) then
    local src = source
    local breaks = data.cuffbreaks

    if (breaks) then
      cuffbreaks = breaks
    else
      print("cuffbreaks was nil >> bms:cuff:breakwaitContinue")
    end
  
    cbreakpwait = false
    startCuffBreak(data.index, data.type)
  end
end)

RegisterNetEvent("bms:csrp_gamemode:respawnPlayer")
AddEventHandler("bms:csrp_gamemode:respawnPlayer", function()
  releasePending = false
end)

--[[Test functions]]
local breakout = false

local function animationComplete(ped, dict, anim, time, cycles)
	local animation = true
  local count = 0
  
	repeat 
		if (GetEntityAnimCurrentTime(ped, dict, anim) < time) then
			Wait(0)
    end
    
		count = count + 1
		animation = IsEntityPlayingAnim(ped, dict, anim, 3)
	until (not animation or count == cycles)

	return true
end

RegisterNUICallback("closemenu", function(data, cb)
  SetNuiFocus(false, false)
end)

RegisterNUICallback("findUser", function(data, cb)
  SetNuiFocus(false, false)

  local charname = data.charname

  if (charname) then
    TriggerServerEvent("bms:cuff:findCharacterByName", charname)
  end
end)

RegisterNUICallback("pbTimerComplete", function(data, cb)
  local bidx = data.bspot
  local breakspot = breakspots[bidx]
  
  if (breakspot and (breakstage == 1)) then
    -- explode and start chain
    AddExplosion(breakspot.pos.x, breakspot.pos.y, breakspot.pos.z, 8, 25.0, 1, 0, 1)
    breakstage = 2
  elseif (breakstage == 3) then
    AddExplosion(role1spots[#role1spots].pos.x, role1spots[#role1spots].pos.y, role1spots[#role1spots].pos.z, 8, 25.0, 1, 0, 1)
    breakstage = 0
    currolespot = 0
    breakrole = 0
    TriggerServerEvent("bms:cuff:prisonBreakRole1Completed")
  end
end)

--[[local doik = false

RegisterNetEvent("bms:cuff:testik")
AddEventHandler("bms:cuff:testik", function()
  doik = not doik

  if (doik) then
    local ped = PlayerPedId()
    local offs = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.5, 0.0)

    --SetPedCanArmIk(ped, true)
    SetIkTarget(ped, 4, 0, 0, offs.x, offs.y, offs.z, 0, 0, 0)
  end
end)]]

Citizen.CreateThread(function()
  local waitTime = 50
  local ped = 0
  local softCuffed = false
  local hardCuffed = false
  local isCuffAnim = false

  while true do
    Wait(waitTime) -- 50

    ped = playerInfo.ped
    softCuffed = DecorGetBool(ped, "softcuffed")
    hardCuffed = DecorGetBool(ped, "hardcuffed")
    isCuffAnim = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)
    isEscorted = IsEntityAttachedToAnyPed(ped)

    if ((hardCuffed or softCuffed) and not isCuffAnim) then
      Wait(3000)

      while (not HasAnimDictLoaded("mp_arresting")) do
        RequestAnimDict("mp_arresting")
        Wait(100)
      end

      if (softCuffed) then
        TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
      elseif (hardCuffed) then
        TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 15, 0, 0, 0, 0)
      end

      RemoveAnimDict("mp_arresting")
    end
  end
end)

Citizen.CreateThread(function()
  local waitTime = 1
  local ped = 0
  local pos = vec3(0, 0, 0)

  while true do
    Wait(waitTime) -- 1
    
    ped = PlayerPedId()
    pos = GetEntityCoords(ped)
    playerInfo.ped = ped

    if (isEscorted) then
      DisableControlAction(1, 75) -- INPUT_VEH_EXIT / F
      DisableControlAction(1, 23) -- INPUT_ENTER / F
    end

     --if (not IsControlPressed(1, 21)) then -- check for modifier press, since spikes now use the modifier with F3
    --if (IsControlJustReleased(1, 170) or IsDisabledControlJustReleased(1, 170)) then -- F3
    if (IsControlPressed(1, 21) and IsControlJustReleased(1, 170)) then -- Shift-F3 to aggressive cuff
      local iskb = GetLastInputMethod(2)
      if (iskb) then
        if (isCopOnDuty or isDocOnDuty) then
          --[[if (waitcuffpress) then
            doublecuffpress = true
          end
          
          if (not waitcuffpress) then
            waitcuffpress = true
            SetTimeout(1500, function()
              waitcuffpress = false
              doublecuffpress = false
            end)
          end]]
          
          --if (doublecuffpress) then
          local clplayer, cldist = getClosestPlayer()
          local sid = GetPlayerServerId(clplayer)
          local nped = GetPlayerPed(sid)
          if (clplayer and cldist < 1.5) then

            if (sid > 0) then
              TriggerServerEvent("bms:cuff:setSoftHandcuffsOnPed", sid, true, false)
              TaskTurnPedToFaceEntity(ped, nped, 500)
              TriggerServerEvent("bms:lawenf:notifyAttachEntity", sid)
              escorting = false
              escentity = nil                  
              Wait(200)

              while (not HasAnimDictLoaded("mp_arrest_paired")) do 
                RequestAnimDict("mp_arrest_paired")
                Wait(50)
              end

              TaskPlayAnim(ped, "mp_arrest_paired", "cop_p2_back_left", 2.0, 3.0, 2500, 33, 0, false, false, false)
              TriggerServerEvent("bms:lawenf:notifyDetachEntity", sid)
              escorting = true
              escentity = nped
              RemoveAnimDict("mp_arrest_paired")
            end                  
          end
        end
      end
    end   
     --Need to disable movement on person thats getting cuffed.
    if (IsControlJustReleased(1, 170) or IsDisabledControlJustReleased(1, 170)) then -- F3
      local iskb = GetLastInputMethod(2)
      if (iskb) then
        
        if (isCopOnDuty or isDocOnDuty) then                     
        local clplayer, cldist = getClosestPlayer()                          
          
          if (clplayer > -1 and cldist > -1 and cldist < 1.5) then
            local sid = GetPlayerServerId(clplayer)
            local nped = GetPlayerPed(sid)
            
            if (sid > 0) then
              TriggerServerEvent("bms:cuff:setSoftHandcuffsOnPed", sid, true, true)
              while (not HasAnimDictLoaded("mp_arresting")) do
                RequestAnimDict("mp_arresting")
                Wait(60)
              end
              TaskPlayAnim(ped, "mp_arresting", "a_uncuff", 8.0, 8.0, 0.75, 0, 0, 0, 0, 0)
              Wait(6000)
              RemoveAnimDict("mp_arresting")
            end
          else
            local offs = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
            local nped = getPedInDirection(pos, offs, ped)
            if (nped and nped > 0) then

              while (not HasAnimDictLoaded("mp_arresting")) do
                RequestAnimDict("mp_arresting")
                Wait(60)
              end

              TaskTurnPedToFaceEntity(ped, nped, 1000)
              Wait(200)
              ClearPedTasks(nped)
              TaskPlayAnim(ped, "mp_arresting", "a_uncuff", 8.0, 8.0, 0.75, 0, 0, 0, 0, 0)
              SetBlockingOfNonTemporaryEvents(nped, true)
              TaskPlayAnim(nped, "mp_arresting", "idle", 8.0, -8, -1, 1, 0, 0, 0, 0)
              SetEnableHandcuffs(nped, true)
              RemoveAnimDict("mp_arresting")
            end
          end
        end
      end
    end
    
    if (not IsControlPressed(1, 21)) then -- check for modifier press, since spikes now use the modifier with F5
      if (IsControlJustReleased(1, 166) or IsDisabledControlJustReleased(1, 166)) then -- F5
        local iskb = GetLastInputMethod(2)
    
        if (iskb) then
          if (isCopOnDuty or isDocOnDuty) then
            local clplayer, cldist = getClosestPlayer()
            local sid = GetPlayerServerId(clplayer)
            local nped = GetPlayerPed(sid)
        
            if (cldist < 1.5) then
              
              while (not HasAnimDictLoaded("mp_arresting")) do
                RequestAnimDict("mp_arresting")
                Wait(60)
              end

              TaskTurnPedToFaceEntity(ped, nped, 500)
              Wait(500)
              TaskPlayAnim(ped, "mp_arresting", "a_uncuff", 8.0, 8.0, 0.75, 0, 0, 0, 0, 0)
              Wait(3000)
              TriggerServerEvent("bms:cuff:setHandcuffsOnPed", sid, false)
              RemoveAnimDict("mp_arresting")
              --TriggerServerEvent("localChatAction", sid, -1, {0, 255, 0}, "has been uncuffed.")
            end
          end         
        end
      end
    end
    
    if (inPrison) then      
      if (not isInPrisonArea(pos, true)) then
        TriggerServerEvent("bms:teleporter:teleportToPoint", ped, prisonCoords)
      end

      if (timerem) then
        drawCuffText(string.format("%s minutes remaining on your sentence.", math.ceil(timerem / 60000)), 0.34, 0.481, 0.93)
      end
    end

    if (breakstage == 0) then
      for _,v in pairs(breakspots) do
        local dist = Vdist(pos.x, pos.y, pos.z, v.pos.x, v.pos.y, v.pos.z)

        if (dist < 80) then
          DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 1.2, 255, 0, 0, 160, 0, 0, 0, 0, 0, 0, 0)
        end
      end
    elseif (breakstage == 2 and breakrole == 1) then
      local dist = Vdist(pos.x, pos.y, pos.z, role1spots[1].pos.x, role1spots[1].pos.y, role1spots[1].pos.z)

      if (dist < 1.1) then
        drawCuffText("Press ~b~E~w~ to set the final C4 charge.")
        DrawMarker(1, role1spots[1].pos.x, role1spots[1].pos.y, role1spots[1].pos.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.1, 1,1, 1.6, 255, 255, 0, 160, 0, 0, 0, 0, 0, 0, 0)

        if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
          breakstage = 3
          SendNUIMessage({
            doPrisonBreakTimer = true,
            breakspot = lastbreakspot
          })
        end
      else
        --local size = (pos.x - role1spots[1].pos.x) / 2
        drawCuffText("Head towards the center of the red marker to set the final C4 charge.")
        DrawMarker(1, role1spots[1].pos.x, role1spots[1].pos.y, role1spots[1].pos.z - 1.0001, 0, 0, 0, 0, 0, 0, dist * 1.8, dist * 1.8, 2.2, 255, 0, 0, 160, 0, 0, 0, 0, 0, 0, 0)
      end
    elseif (breakstage == 1 and breakrole == 2) then
      if (inPrison) then
        inPrison = false

        local pos = GetEntityCoords(ped)
        local fdist = Vdist(pos.x, pos.y, pos.z, role2spots[#role2spots].pos.x, role2spots[#role2spots].pos.y, role2spots[#role2spots].pos.z)

        if (fdist < 1.1) then
          drawCuffText("Press ~b~E~w~ to break out of the prison.")
          DrawMarker(1, role2spots[#role2spots].pos.x, role2spots[#role2spots].pos.y, role2spots[#role2spots].pos.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.1, 1,1, 1.6, 255, 0, 0, 160, 1, 0, 0, 0, 0, 0, 0)

          if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
            if (opprolecomplete) then
              role2curmarker = 1
              breakstage = 0
              breakrole = 0
              teleportToOutside()
              TriggerServerEvent("bms:cuff:zeroPrisonTime")
              opprolecomplete = false
            else
              exports.pnotify:SendNotification({text = "Still waiting for the other participant to detonate the fence C4 charge.. You can cancel the breakout by running away and return to prison."})
              cancelwarned = true
            end
          end
        else
          if (cancelwarned and fdist > 20) then
            exports.pnotify:SendNotification({text = "You have been detected and returned to prison."})
            role2curmarker = 1
            breakstage = 0
            breakrole = 0
            cancelwarned = false
            
            local ped = PlayerPedId()

            TriggerServerEvent("bms:teleporter:teleportToPoint", ped, prisonCoords)
            inPrison = true
            isInPrison()
          else
            local mdist = Vdist(pos.x, pos.y, pos.z, role2spots[role2curmarker].pos.x, role2spots[role2curmarker].pos.y, role2spots[role2curmarker].pos.z)
            
            drawCuffText("Head towards the center of the red circle to continue!")
            
            if (mdist < 1.1) then
              role2curmarker = role2curmarker + 1
            end
          end
        end
      end
    end

    if (role2wait) then
      if (IsControlJustReleased(1, 170) or IsDisabledControlJustReleased(1, 170)) then
        role2wait = false
        TriggerServerEvent("bms:cuff:role2Status", {success = true})
        breakrole = 2
        breakstage = 1
      end

      if (IsControlJustReleased(1, 166) or IsDisabledControlJustReleased(1, 166)) then
        role2wait = false
        TriggerServerEvent("bms:cuff:role2Status", {success = false})
      end
    end

    if (softcuff) then
      DisableControlAction(0, 24, true) -- Attack
      DisablePlayerFiring(ped, true) -- Disable weapon firing
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
      DisableControlAction(0, 37, true) -- SelectWeapon
      DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
      DisableControlAction(0, 25, true) -- INPUT_AIM
    end

    if (blockMovement) then
      disableInput()
    end

    if (isCopOnDuty or isDocOnDuty) then      
      for _,v in pairs(prosters) do
        local dist = #(pos - v.pos)

        if (dist < 20.0) then
          DrawMarker(20, v.pos.x, v.pos.y, v.pos.z - 1.000001, 0, 0, 0, 180.0, 0, 0, 0.48, 0.48, 0.4, 0, 180, 255, 50, 0, 0, 0, 1, 0, 0, 0)

          if (not rosterwait) then
            if (dist < 1.5) then
              draw3DCuffText(v.pos.x, v.pos.y, v.pos.z - 1.000001, "Press ~b~E~w~ to use the prison computer.", 0.25)

              if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
                rosterwait = true

                exports.management:TriggerServerCallback("bms:cuff:getRoster", function(roster)
                  rosterwait = false
                  SendNUIMessage({updatePrisonRoster = true, roster = roster})
                  SetNuiFocus(true, true)
                end)
              end
            end
          end
        end
      end

      for _,v in pairs(towers) do
        local entdist = Vdist(pos.x, pos.y, pos.z, v.entry.x, v.entry.y, v.entry.z)
        
        if (entdist < 20) then
          DrawMarker(1, v.entry.x, v.entry.y, v.entry.z - 0.900001, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.15, 0, 180, 255, 150, 0, 0, 0, 0, 0, 0, 0)

          if (entdist < 1.2) then
            draw3DCuffText(v.entry.x, v.entry.y, v.entry.z + 0.25, "Press ~b~E~w~ to get your guard loadout.")
            
            if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then              
              for _,v in pairs(guardloadout) do
                GiveWeaponToPed(ped, GetHashKey(v), 1000, false, false)
              end

              if (not hastowerkit) then
                exports.pnotify:SendNotification({text = "You have been given a tower guard loadout.  These items will be removed once a specific distance from the prison is reached."})
              end

              hastowerkit = true
            end
          end
        end
      end

      for _,v in pairs(lsspots) do
        local dist = Vdist(pos.x, pos.y, pos.z, v.pos.x, v.pos.y, v.pos.z)

        if (dist < 20) then
          DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.000001, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.15, 0, 180, 255, 50, 0, 0, 0, 0, 0, 0, 0)

          if (dist < 0.6) then
            if (not usingls) then
              draw3DCuffText(v.pos.x, v.pos.y, v.pos.z + 0.25, "Press ~b~E~w~ to use the prison loud speakers.", 0.28)

              if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
                usingls = true
                
                exports.management:TriggerServerCallback("bms:cuff:activateLsSystem", function()
                  NetworkSetVoiceChannel(lsvc)
                end)
              end
            else
              draw3DCuffText(v.pos.x, v.pos.y, v.pos.z + 0.25, "Press ~b~E~w~ to ~r~stop~w~ using the loud speakers.", 0.28)

              if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
                exports.management:TriggerServerCallback("bms:cuff:activateLsSystem", function()
                  NetworkClearVoiceChannel()
                  usingls = false
                end, true)
              end
            end
          end
        end
      end

      for i,v in ipairs(cameraspots) do
        local dist = Vdist(pos.x, pos.y, pos.z, v.pos.x, v.pos.y, v.pos.z)

        if (dist < 20) then
          if (not cammode.active) then
            DrawMarker(20, v.pos.x, v.pos.y, v.pos.z - 0.5, 0, 0, 0, 180.0, 0, 0, 0.48, 0.48, 0.4, 0, 180, 255, 50, 0, 0, 0, 1, 0, 0, 0)

            if (dist < 1.8) then
              draw3DCuffText(v.pos.x, v.pos.y, v.pos.z - 1.000001, "Press ~b~F~w~ to use surveillance system.", 0.25)

              if (IsControlJustReleased(1, 23) or IsDisabledControlJustReleased(1, 23)) then
                cammode = {active = true, lastcamspot = i, activecam = 1, cam = -1}
                StartScreenEffect("SwitchOpenNeutralFIB5", 0, true)
                enableSurvCam(1)
              end
            end
          end
        end
      end

      if (hastowerkit) then
        local aiming = IsPlayerFreeAiming(PlayerId())
        local _,weapon = GetCurrentPedWeapon(ped, true)

        if (aiming and weapon == 100416529) then
          exports.csrp_gamemode:toggleReticule(true)
        end

        local dist = Vdist(pos.x, pos.y, pos.z, prisonCoords.x, prisonCoords.y, prisonCoords.z)

        if (dist > kitremrange) then
          for _,v in pairs(guardloadout) do
            RemoveWeaponFromPed(ped, GetHashKey(v))
          end

          exports.csrp_gamemode:toggleReticule(false)
          exports.pnotify:SendNotification({text = "Your guard tower kit has been removed.  Maximum Range reached."})
          hastowerkit = false
        end
      end

      if (usingls) then
        drawCuffText("~r~[ Intercom mode is active ]", 0.3, 0.3)
      end

      if (cammode.active) then
        HideHudAndRadarThisFrame()
        drawCuffText(string.format("Viewing Camera %s of %s (%s).", cammode.activecam, #cameras, cameras[cammode.activecam].desc), 0.31)
        drawCuffText("~w~Pageup/Down: Cycle Cams, UDLR Arrows: Navigate View.", 0.31, 0.475, 0.9)
        drawCuffText("~w~Press [Backspace] to exit surveillance system.", 0.31, 0.475, 0.925)
        
        local rot = GetCamRot(cammode.cam, 2)
        
        --drawCuffText(string.format("debug headings: x: %s, y: %s, z: %s", rot.x, rot.y, rot.z), 0.31, 0.475, 0.945)

        if (IsControlJustReleased(1, 11) or IsDisabledControlJustReleased(1, 11)) then -- pagedown
          cammode.activecam = cammode.activecam + 1

          if (cammode.activecam > #cameras) then
            cammode.activecam = 1
          end

          enableSurvCam(cammode.activecam)
        elseif (IsControlJustReleased(1, 10) or IsDisabledControlJustReleased(1, 10)) then -- pageup
          cammode.activecam = cammode.activecam - 1

          if (cammode.activecam < 1) then
            cammode.activecam = #cameras
          end

          enableSurvCam(cammode.activecam)
        elseif (IsControlJustReleased(1, 177) or IsDisabledControlJustReleased(1, 177)) then -- backspace
          cammode.active = false
          enableSurvCam(0)
        elseif (IsControlPressed(1, 174)) then -- left arrow
          local vrot = {x = rot.x, y = rot.y, z = rot.z}
            
          vrot.z = rot.z + 0.25
          SetCamRot(cammode.cam, vrot.x, vrot.y, vrot.z, 2)
        elseif (IsControlPressed(1, 175)) then -- right arrow
          local vrot = {x = rot.x, y = rot.y, z = rot.z}
            
          vrot.z = rot.z - 0.25
          SetCamRot(cammode.cam, vrot.x, vrot.y, vrot.z, 2)
        end
        
        if (IsControlPressed(1, 27)) then -- up arrow
          local vrot = {x = rot.x, y = rot.y, z = rot.z}
            
          vrot.x = rot.x + 0.25
          SetCamRot(cammode.cam, vrot.x, vrot.y, vrot.z, 2)
        elseif (IsControlPressed(1, 173)) then -- down arrow
          local vrot = {x = rot.x, y = rot.y, z = rot.z}
            
          vrot.x = rot.x - 0.25
          SetCamRot(cammode.cam, vrot.x, vrot.y, vrot.z, 2)
        end
      end
    end

    for i,v in ipairs(cuffbreakspots) do
      local dist1 = Vdist(pos.x, pos.y, pos.z, v.pos1.x, v.pos1.y, v.pos1.z)
      local dist2 = Vdist(pos.x, pos.y, pos.z, v.pos2.x, v.pos2.y, v.pos2.z)

      if (dist1 < 40 or dist2 < 40) then
        DrawMarker(1, v.pos1.x, v.pos1.y, v.pos1.z - 1.0000001, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.15, 200, 60, 60, 50, 0, 0, 0, 0, 0, 0, 0)
        DrawMarker(1, v.pos2.x, v.pos2.y, v.pos2.z - 1.0000001, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.15, 150, 150, 0, 50, 0, 0, 0, 0, 0, 0, 0)
        
        if (dist1 < 0.6) then
          if (cbspotcheck) then
            cbspotcheck = false
            lastcbchecked = {cb = i, spot = 1}
            exports.management:TriggerServerCallback("bms:cuff:getCuffBreaks", function(cbreaks)
              cuffbreaks = cbreaks
            end)
          else
            doCuffSpotChecks(cuffbreaks[tostring(i)], 1, i)
          end
        elseif (dist2 < 0.6) then
          if (cbspotcheck) then
            cbspotcheck = false
            lastcbchecked = {cb = i, spot = 2}
            exports.management:TriggerServerCallback("bms:cuff:getCuffBreaks", function(cbreaks)
              cuffbreaks = cbreaks
              print(json.encode(cuffbreaks))
            end)
          else
            doCuffSpotChecks(cuffbreaks[tostring(i)], 2, i)
          end
        elseif (lastcbchecked.cb > 0) then
          local cbc = cuffbreaks[tostring(lastcbchecked.cb)]
          local cbpos
          
          if (cbc) then
            if (lastcbchecked.spot == 1) then
              cbpos = cuffbreakspots[tonumber(lastcbchecked.cb)].pos1
            else
              cbpos = cuffbreakspots[tonumber(lastcbchecked.cb)].pos2
            end

            local scdist = Vdist(pos.x, pos.y, pos.z, cbpos.x, cbpos.y, cbpos.z)

            if (scdist > 0.7) then
              lastcbchecked = {cb = 0, spot = 0}
              cbspotcheck = true
            end
          end
        end
      end
    end

    if (breakingcuffs) then
      DisableControlAction(0, 32, true)
      DisableControlAction(0, 33, true)
      DisableControlAction(0, 34, true)
      DisableControlAction(0, 35, true)
    end

    if (welding.active) then
      SetIkTarget(ped, 4, 0, 0, welding.bpos.x, welding.bpos.y - 0.5, welding.bpos.z - 0.5, 0, 0, 0)
    end

    if (releasePending) then
      local dist = #(pos - prisonReleaseSpot)

      if (dist < 40) then
        DrawMarker(1, prisonReleaseSpot.x, prisonReleaseSpot.y, prisonReleaseSpot.z - 1.0, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.2, 240, 70, 70, 50, 0, 0, 0, 0, 0, 0, 0)
        DrawMarker(20, prisonReleaseSpot.x, prisonReleaseSpot.y, prisonReleaseSpot.z + 0.3, 0, 0, 0, 0, 0, 0, 0.4, 0.4, 0.4, 240, 70, 70, 50, 1, 0, 0, 1, 0, 0, 0)

        if (dist < 0.6) then
          draw3DCuffText(prisonReleaseSpot.x, prisonReleaseSpot.y, prisonReleaseSpot.z + 0.2, "Press ~b~[E]~w~ to exit the prison.", 0.25)

          if (IsControlJustReleased(1, 38)) then
            releasePending = false

            if (prisonReleaseBlip) then
              RemoveBlip(prisonReleaseBlip)
              prisonReleaseBlip = nil
            end

            TriggerServerEvent("bms:char:setNormalSkin")
            Wait(500)
            ClearPedSecondaryTask(ped)
            SetEnableHandcuffs(ped, false)
            FreezeEntityPosition(ped, false)            
            TriggerServerEvent("bms:teleporter:teleportToPoint", 0, releaseCoords)
            softcuff = false
            hardcuff = false
            ziptied = false

            if (lkvc ~= 0) then
              NetworkSetVoiceChannel(lkvc)
            else
              NetworkClearVoiceChannel()
            end
          end
        end
      end
    end
  end
end)
