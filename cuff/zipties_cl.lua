local table_insert = table.insert
local table_remove = table.remove
local math_huge = math.huge
local ziptie = {active = false, applytime = 0, ztimeout = 15}
local trunkanims = {
  {dict = "timetable@floyd@cryingonbed@base", anim = "base"}
}
local inTrunk = false
local trcam = -1
local trVeh = 0
local escortingPed = {sid = 0, ped = 0}
local escortedBy = 0
local anims = { -- escorting
  {dict = "rcmnigel1d", anim = "base_club_shoulder"},
  {dict = "move_characters@dave_n@core@", anim = "walk"},
  {dict = "mp_arresting", anim = "walk"},
  {dict = "mp_arresting", anim = "idle"}
}
local debug = {active = false, trpos = {x = 0, y = 0, z = 0.35}}
local vexitoffset = 1.5

local function getVehicleInDirection(coordFrom, coordTo, ignore)
  local rayHandle = StartShapeTestRay(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, ignore, 0)
  local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)

  if (vehicle and vehicle ~= 0 and IsEntityAVehicle(vehicle)) then
    return vehicle
  end
end

local function getPedInDirection(coordFrom, coordTo, ignore)
  local rayHandle = StartShapeTestRay(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 12, ignore, 0)
  local _, _, _, _, ped = GetShapeTestResult(rayHandle)
  return ped
end

function drawDebugText(text, scale, x, y)
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

local function getClosestPlayer()
  local players = GetActivePlayers()
  local closestDistance = math_huge
  local closestPlayer = -1
  local ped = PlayerPedId()
  local ppos = GetEntityCoords(ped)

  for i=1,#players do
    local target = GetPlayerPed(players[i])

    if (target ~= ped) then
      local tpos = GetEntityCoords(target)
      local dist = #(tpos - ppos)
      
      if (closestDistance > dist) then
        closestPlayer = players[i]
        closestDistance = dist
      end
    end
  end

  if (closestDistance == math_huge) then
    closestDistance = -1
  end

  return closestPlayer, closestDistance
end

local function playAnim(ped, blendSpeed, dict, anim, flag)
  if (not IsEntityPlayingAnim(ped, dict, anim, 3)) then
    while (not HasAnimDictLoaded(dict)) do
      RequestAnimDict(dict)
      Wait(10)
    end

    TaskPlayAnim(ped, dict, anim, blendSpeed, blendSpeed, -1, flag, 0, 0, 0, 0)
    RemoveAnimDict(dict)
  end
end

local function disableInput()
  local ped = PlayerPedId()

  DisableControlAction(0, 32, true)  -- Movement
  DisableControlAction(0, 33, true)  --
  DisableControlAction(0, 34, true)  --
  DisableControlAction(0, 35, true)  --
  DisableControlAction(0, 24, true)  -- Attack
  DisablePlayerFiring(ped, true)     -- Disable weapon firing
  DisableControlAction(0, 142, true) -- MeleeAttackAlternate
  DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
  DisableControlAction(0, 37, true)  -- SelectWeapon
  DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
  DisableControlAction(0, 25, true)  -- INPUT_AIM
end

local function endEscort() -- escorting someone
  local ped = PlayerPedId()
  
  if (escortingPed.ped ~= 0) then
    --[[if (not skipevent) then
      TriggerServerEvent("bms:zipties:stopEscortCiv", escortingPed.sid)
    end]]

    escortingPed.ped = 0
    escortingPed.sid = 0
    StopAnimTask(ped, anims[1].dict, anims[1].anim, 2.0)
  end
end

local function invalidVehicleType(veh)
  local class = GetVehicleClass(veh)
  local model = GetEntityModel(veh)

  return trunkDisallows[model] or IsThisModelABike(veh) or IsThisModelABoat(veh) or IsThisModelAHeli(veh) or IsThisModelAJetski(veh) or IsThisModelAPlane(veh) or IsThisModelAQuadbike(veh) or IsThisModelATrain(veh) or
    class == 8 --[[Motorcycles]] or class == 9 --[[ Off-road ]] or class == 12 --[[ Vans (for Pickups) ]] or class == 13 --[[Cycles]] or class == 18 --[[Emergency]]
end

local function vehicleCanStuff(veh)
  local locked = GetVehicleDoorLockStatus(veh) == 2
  local model = GetEntityModel(veh)

  if (locked) then
    exports.pnotify:SendNotification({text = "This vehicle is locked."})
    return false
  end

  if (invalidVehicleType(veh)) then
    if (not trunkExceptions[model]) then
      exports.pnotify:SendNotification({text = "You can not get into this vehicles trunk."})
      return false
    end
  end

  return true
end

local function findVehExit(veh)
  local model = GetEntityModel(veh)
  local dim1 = vector3(0.0, 0.0, 0.0)
  local dim2 = vector3(5.0, 5.0, 5.0)
  local dim = GetModelDimensions(model, dim1, dim2)

  return {x = 0.0, y = dim.y - vexitoffset, z = dim.z + 1.0}
end

local function setTieDecor(apply)
  local ped = PlayerPedId()
  
  if (apply) then
    if (not DecorIsRegisteredAsType("ziptied", 2)) then
      DecorRegister("ziptied", 2)
    end

    DecorSetBool(ped, "ziptied", true)
  else
    DecorSetBool(ped, "ziptied", false)
  end
end

RegisterNetEvent("bms:zipties:useZiptie")
AddEventHandler("bms:zipties:useZiptie", function(data)
  local ped = PlayerPedId()
  local clplayer, cldist = getClosestPlayer()
  
  if (clplayer and cldist < 1.5) then
    local sid = GetPlayerServerId(clplayer)

    if (sid > 0) then
      local tped = GetPlayerPed(clplayer)
      local dead = IsPedDeadOrDying(tped)
      local cuffed = IsEntityPlayingAnim(tped, "mp_arresting", "idle", 3)
      local inveh = IsPedInAnyVehicle(tped, false)
      local handsup = IsEntityPlayingAnim(tped, "random@mugging3", "handsup_standing_base", 3) or IsEntityPlayingAnim(tped, "random@arrests", "kneeling_arrest_idle", 3) or IsEntityPlayingAnim(tped, "random@arrests@busted", "idle_c", 3)
      local proceed = handsup and not dead and not cuffed and not inveh -- any fail conditions here

      if (proceed) then
        data.sid = sid
        exports.management:TriggerServerCallback("bms:zipties:useZiptie", function()
          Citizen.CreateThread(function()
            while (not HasAnimDictLoaded("mp_arresting")) do
              RequestAnimDict("mp_arresting")
              Wait(10)
            end
            
            TaskTurnPedToFaceEntity(ped, tped, 500)
            TaskPlayAnim(ped, "mp_arresting", "a_uncuff", 8.0, 8.0, 0.75, 0, 0, 0, 0, 0)
            RemoveAnimDict("mp_arresting")
            exports.pnotify:SendNotification({text = "The <span style='color: skyblue'>ziptie</span> has been applied successfully."})
          end)
        end, data)
      else
        if (not handsup) then
          exports.pnotify:SendNotification({text = "You can not ziptie someone who has not submitted in some way."})
        else
          exports.pnotify:SendNotification({text = "You can not ziptie this person at this time."})
        end

        exports.inventory:blockInventoryUse(false)
      end
    else
      print("bms:zipties:useZiptie >> sid < 0")
    end
  else
    exports.inventory:blockInventoryUse(false)
  end
end)

RegisterNetEvent("bms:zipties:applyZiptie")
AddEventHandler("bms:zipties:applyZiptie", function(data)
  TriggerEvent("bms:cuff:softHandcuff", true)
  ziptie.ztimeout = data and data.ztimeout or 15
  ziptie.applytime = GetGameTimer() + (ziptie.ztimeout * 60000)
  ziptie.active = true
  setTieDecor(true)
  exports.pnotify:SendNotification({text = "You have been <span style='color: skyblue'>ziptied</span>."})
end)

RegisterNetEvent("bms:zipties:getInTrunk")
AddEventHandler("bms:zipties:getInTrunk", function(override, deadOnExit)
  local ped = PlayerPedId()
  local playerBag = Player(GetPlayerServerId(PlayerId()))

  if (playerBag.state.blockEnterTrunk and not override) then
    exports.pnotify:SendNotification({text = "You can not get in a trunk at this time."})
    if (deadOnExit) then
      SetEntityHealth(ped, 1)
    end
    return
  end

  if (not inTrunk) then
    local pos = GetEntityCoords(ped)

    if (GetVehiclePedIsIn(ped, false) ~= 0) then
      exports.pnotify:SendNotification({text = "You can not reach the trunk from here.  Maybe get out?"})
      if (deadOnExit) then
        SetEntityHealth(ped, 1)
      end
      return
    end

    local offset
    local beingCarried = IsEntityPlayingAnim(ped, "nm", "firemans_carry", 3)

    if (beingCarried) then
      offset = GetOffsetFromEntityGivenWorldCoords(ped, -0.2, 5.0, -0.35)
    else
      offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
      playerBag.state.wasDeadBeforeTrunk = GetEntityHealth(ped) <= 1
    end

    local veh = getVehicleInDirection(pos, offset, ped)

    if (not veh) then
      for _,v in pairs(GetGamePool("CVehicle")) do
        local dist = #(pos - GetEntityCoords(v))
        local trunkDist = 4.0
        local model = GetEntityModel(v)

        if (trunkData and trunkData[model]) then
          trunkDist = trunkData[model].dist or 4.0
        end

        if (dist < trunkDist) then
          veh = v
          break
        end
      end
    end

    if (veh and veh ~= 0 and vehicleCanStuff(veh)) then
      local trunkTracker = GlobalState.trunkTracker
      local vehNetId = NetworkGetNetworkIdFromEntity(veh)
      local hasPlayerInTrunk = trunkTracker[vehNetId] ~= nil

      if (hasPlayerInTrunk) then
        exports.pnotify:SendNotification({text = "There is already someone inside this trunk."})
        if (deadOnExit) then
          SetEntityHealth(ped, 1)
        end
        return
      end

      local trunkbone = GetEntityBoneIndexByName(veh, "boot")
      local trpos = GetWorldPositionOfEntityBone(veh, trunkbone)
      local vpos = GetEntityCoords(veh)
      local distToTrunkBone = #(pos - trpos)
      
      if (distToTrunkBone > 1.5) then
        if (deadOnExit) then
          SetEntityHealth(ped, 1)
        end
        exports.pnotify:SendNotification({text = "You are too far from the trunk.  Move closer to it."})
        return
      end

      exports.management:TriggerServerCallback("bms:zipties:trunkReg", function(rdata)
        if (rdata.success == false and rdata.msg) then
          exports.pnotify:SendNotification({text = rdata.msg})
          return
        end

        inTrunk = true
        SetVehicleDoorOpen(veh, 5, false, false)

        local trunkanim = trunkanims[1]

        Citizen.CreateThread(function()
          while (not HasAnimDictLoaded(trunkanim.dict)) do
            RequestAnimDict(trunkanim.dict)
            Wait(10)
          end

          ClearPedTasks(ped)
          TaskPlayAnim(ped, trunkanim.dict, trunkanim.anim, 2.0, 2.0, -1, 2)
          AttachEntityToEntity(ped, veh, trunkbone, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 1, 1, 1)
          Wait(1200)
          SetEntityVisible(ped, false, false)
          SetEntityCollision(ped, false, false)
          RemoveAnimDict(trunkanim.dict)

          trcam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

          SetCamActive(trcam, true)
          RenderScriptCams(true,  false, 0, true, true)
          AttachCamToVehicleBone(trcam, veh, trunkbone, true, 0, 0, 0, 0.0, -6.0, 3.0, true)
          PointCamAtEntity(trcam, veh)
          SetVehicleDoorShut(veh, 5, false)
          trVeh = veh
        end)
      end, {isRegistering = true, netId = vehNetId})
    else
      if (not deadOnExit and not playerBag.state.wasDeadBeforeTrunk) then
        exports.pnotify:SendNotification({text = "A vehicle was not found nearby.  Try moving closer to the center of it."})
      else
        SetEntityHealth(ped, 1)
      end
    end
  else
    if (not ziptie.active or override) then
      Citizen.CreateThread(function()
        local trunkanim = trunkanims[1]

        SetVehicleDoorOpen(trVeh, 5, false, false)
        Wait(500)
        DetachCam(trcam)
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(trcam, false)
        DetachEntity(ped)
        StopAnimTask(ped, trunkanim.dict, trunkanim.anim, 2.0)
        inTrunk = false

        if (ziptie.active) then
          TriggerEvent("bms:cuff:softHandcuff", true)
        end

        local exit = findVehExit(trVeh)
        local off = GetOffsetFromEntityInWorldCoords(trVeh, exit.x, exit.y, exit.z)

        SetEntityCollision(ped, true, true)
        SetEntityVisible(ped, true, true)
        SetEntityCoords(ped, off)
        Wait(500)
        SetVehicleDoorShut(trVeh, 5, false)

        if (deadOnExit or playerBag.state.wasDeadBeforeTrunk == true) then
          SetEntityHealth(ped, 1)
        end

        exports.management:TriggerServerCallback("bms:zipties:trunkReg", function()
          trVeh = 0
        end, {isRegistering = false, netId = NetworkGetNetworkIdFromEntity(trVeh)})
      end)
    else
      exports.pnotify:SendNotification({text = "You can not do this while ziptied."})
    end
  end
end)

RegisterNetEvent("bms:zipties:trsave")
AddEventHandler("bms:zipties:trsave", function()
  local out = string.format("Vehicle InTrunk Position >> Vehicle: %s, Offset: {x = %s, y = %s, z = %s}", GetEntityModel(trVeh), debug.trpos.x, debug.trpos.y, debug.trpos.z)

  TriggerServerEvent("bms:zipties:trsave", out)
end)

RegisterNetEvent("bms:zipties:escortCiv")
AddEventHandler("bms:zipties:escortCiv", function()
  if (escortingPed.ped ~= 0) then
    TriggerServerEvent("bms:zipties:sendEndEscort", escortingPed.sid)
    endEscort()
  else
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.2, 0.0)
    local rped = getPedInDirection(pos, offset, ped)

    if (rped and rped ~= 0) then
      local cuffed = IsEntityPlayingAnim(rped, "mp_arresting", "idle", 3)
      local dead = IsPedDeadOrDying(rped)

      if (cuffed and not dead) then
        if (IsPedAPlayer(rped)) then        
          for _,id in ipairs(GetActivePlayers()) do
            if (GetPlayerPed(id) == rped) then
              local sid = GetPlayerServerId(id)

              if (sid and sid > 0) then
                exports.management:TriggerServerCallback("bms:zipties:escortCiv", function()
                  escortingPed.sid = sid
                  escortingPed.ped = rped
                end, {sid = sid})
                break
              end
            end
          end
        else
          print("ped not a player")
        end
      else
        print("bms:zipties:escortCiv >> ped was not cuffed or dead")
      end
    else
      print("bms:zipties:escortCiv >> reped was nil")
    end
  end
end)

RegisterNetEvent("bms:zipties:doEscortCiv") -- called from server when someone starts escorting me
AddEventHandler("bms:zipties:doEscortCiv", function(data)
  if (data and data.escped) then
    local ped = PlayerPedId()

    escortedBy = GetPlayerPed(GetPlayerFromServerId(data.escped))
    AttachEntityToEntity(ped, escortedBy, 57005, 0.3, 0.3, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
  end
end)

RegisterNetEvent("bms:zipties:endEscortCiv") -- called to end someone escorting me
AddEventHandler("bms:zipties:endEscortCiv", function()
  if (escortedBy and escortedBy ~= 0) then
    local ped = PlayerPedId()
    
    DetachEntity(ped)
    escortedBy = 0
    SetEntityCollision(ped, true)
    EnableAllControlActions(0)
  end
end)

RegisterNetEvent("bms:zipties:putInTrunk")
AddEventHandler("bms:zipties:putInTrunk", function()  
  if (escortingPed.ped ~= 0 and escortingPed.sid ~= 0) then
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.0, 0.0)
    local veh = getVehicleInDirection(pos, offset, ped)

    if (veh and veh ~= 0) then
      if (vehicleCanStuff(veh)) then
        local netId = NetworkGetNetworkIdFromEntity(veh)
        local trunkTracker = GlobalState.trunkTracker
        local hasPlayerInTrunk = trunkTracker[netId] ~= nil

        if (not hasPlayerInTrunk) then
          exports.management:TriggerServerCallback("bms:zipties:putInTrunk", function()
            endEscort()
          end, {sid = escortingPed.sid})
        else
          exports.pnotify:SendNotification({text = "There is already someone inside this trunk."})
        end
      else
        print("bms:zipties:putInTrunk >> invalid vehicle")
      end
    else
      print("bms:zipties:putInTrunk >> vehicle not found in range.")
    end
  else   
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 4.0, 0.0)
    local veh = getVehicleInDirection(pos, offset, ped)

    if (veh and veh ~= 0) then
      exports.management:TriggerServerCallback("bms:zipties:putInTrunk")
    else
      print("Could not find vehicle in direction.", veh)
    end
  end
end)

RegisterNetEvent("bms:zipties:takeFromTrunk")
AddEventHandler("bms:zipties:takeFromTrunk", function()
  local clplayer, cldist = getClosestPlayer()
  
  if (clplayer and cldist < 1.9) then
    local sid = GetPlayerServerId(clplayer)

    if (sid > 0) then
      TriggerServerEvent("bms:zipties:takeFromTrunk", {sid = sid})
    end
  end
end)

RegisterNetEvent("bms:zipties:putInTrunkFromEscort")
AddEventHandler("bms:zipties:putInTrunkFromEscort", function(override, deadOnExit)
  if (escortedBy ~= 0) then
    local ped = PlayerPedId()
    
    SetEntityCollision(ped, true)
    EnableAllControlActions(0)
    
    Citizen.CreateThread(function()
      DetachEntity(ped)
    
      while (IsEntityAttachedToEntity(ped, escortedBy)) do
        Wait(10)
      end
      
      escortedBy = 0 -- this may cause a race condition if the loop check happens before this one completes
      TriggerEvent("bms:zipties:getInTrunk")
    end)
  else
    --DetachEntity(ped)
    TriggerEvent("bms:zipties:getInTrunk", override, deadOnExit)
  end
end)

RegisterNetEvent("bms:zipties:useScissors")
AddEventHandler("bms:zipties:useScissors", function()
  local clplayer, cldist = getClosestPlayer()
  local ped = PlayerPedId()
  
  if (clplayer ~= -1 and cldist < 1.9) then
    local sid = GetPlayerServerId(clplayer)

    if (sid > 0) then
      local rped = GetPlayerPed(clplayer)

      Citizen.CreateThread(function()
        while (not HasAnimDictLoaded("mp_arresting")) do
          RequestAnimDict("mp_arresting")
          Wait(10)
        end
        
        TaskTurnPedToFaceEntity(ped, rped, 500)
        TaskPlayAnim(ped, "mp_arresting", "a_uncuff", 8.0, 8.0, 0.75, 0, 0, 0, 0, 0)
        RemoveAnimDict("mp_arresting")
        TriggerServerEvent("bms:zipties:useScissors", sid)
      end)
    end
  end
end)

RegisterNetEvent("bms:zipties:checkUseScissors")
AddEventHandler("bms:zipties:checkUseScissors", function()
  if (ziptie.active) then
    ziptie.active = false
    ziptie.applytime = 0
    setTieDecor(false)

    getCuffStatus(function(cuffed)
      if (cuffed == 0 or cuffed == 3) then
        TriggerEvent("bms:Uncuff")
      end
    end)
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1000)

    if (ziptie.active) then
      local ped = PlayerPedId()
      local time = GetGameTimer()
      local exp = time > ziptie.applytime
      local dead = IsPedDeadOrDying(ped)

      if (exp or dead) then
        ziptie.active = false
        ziptie.applytime = 0
        setTieDecor(false)

        getCuffStatus(function(cuffed)
          if (dead and (cuffed == 0 or cuffed == 3)) then -- LEO cuff check:  Scenario-- We get ziptied, an officer comes and handcuffs us for some reason, the zip ties expire and auto uncuff us.
            TriggerEvent("bms:Uncuff")
          end
        end)
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(50)

    local ped = PlayerPedId()
    local zipped = DecorGetBool(ped, "ziptied")
    local isplaying = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)-- and GetEntityAnimCurrentTime(ped, "mp_arresting", "idle") == 2000.0

    if (zipped and not isplaying and not inTrunk) then
      Wait(3000)

      while (not HasAnimDictLoaded("mp_arresting")) do
        RequestAnimDict("mp_arresting")
        Wait(100)
      end

      TaskPlayAnim(ped, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0) -- 49 = add player control
      RemoveAnimDict("mp_arresting")
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()

    if (inTrunk) then
      local vehInTrunk = GetEntityAttachedTo(ped)

      if (GetVehicleDoorAngleRatio(vehInTrunk, 5) < 0.9) then
        if (IsEntityVisible(ped)) then
          SetEntityVisible(ped, false, false)
        end
      else
        if (not IsEntityPlayingAnim(ped, trunkanims.dict, trunkanims.anim, 3)) then
          while (not HasAnimDictLoaded(trunkanims.dict)) do
            RequestAnimDict(trunkanims.dict)
            Wait(5)
          end
          
          TaskPlayAnim(ped, trunkanims.dict, trunkanims.anim, 2.0, 2.0, -1, 2)
          RemoveAnimDict(trunkanims.dict)
          SetEntityVisible(ped, true, false)
        end
      end

      if (IsPedBeingStunned(ped) or IsPedDeadOrDying(ped) or IsPedFatallyInjured(ped)) then
        TriggerEvent("bms:zipties:getInTrunk")
      end
    end

    if (escortingPed and escortingPed.ped ~= 0) then -- escorting someone
      DisableControlAction(0, 21, true)
      playAnim(ped, 9.0, anims[1].dict, anims[1].anim, 50)
    elseif (escortedBy and escortedBy ~= 0) then -- being escorted
      disableInput()
      local epos = GetEntityCoords(escortedBy)
      local ehead = GetEntityHeading(escortedBy)
      local frontoffset = GetOffsetFromEntityInWorldCoords(escortedBy, 0.15, 2.0, 0.0)
      local walking = IsPedWalking(escortedBy)

      SetEntityHeading(ped, ehead)
      SetEntityCollision(ped, false)
      
      if (IsPedStill(escortedBy)) then
        local pos = GetEntityCoords(ped)
        
        TaskGoStraightToCoord(ped, pos.x, pos.y, pos.z, 5.0, -1, ehead, 1.0)
      elseif (walking) then
        TaskGoStraightToCoord(ped, frontoffset.x, frontoffset.y, frontoffset.z, 5.0, -1, ehead, 1.0) -- this looks much more natural, but animations do not sync on the escorter client, who the fuck knows why.
      end
    end
  end
end)

function init() -- to support restart debugging we remove the decor since it persists
  local ped = PlayerPedId()

  DecorSetBool(ped, "ziptied", false)
end

init()

--[[ Raycast tester - Trying to use a raycast to detect a closed trunk above (to deny open roofed vehicle trunks), but I think it's too sensative ]]
--[[local rcBoneIndex
local upVector = vec3(0.0, 0.0, 1.0)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if (not rcBoneIndex) then rcBoneIndex = GetPedBoneIndex(ped, "SKEL_Pelvis") end

    local wBonePos = GetWorldPositionOfEntityBone(ped, rcboneIndex)
    local rayHandle = StartShapeTestRay(wBonePos, wBonePos + upVector, 10, ped, 0)
    local _, hit, _, _, hitEnt = GetShapeTestResult(rayHandle)

    if (hit == 0) then
      DrawLine(wBonePos, wBonePos + upVector, 255, 0, 0, 255)
    else
      print(("hit: %s"):format(hit))
      DrawLine(wBonePos, wBonePos + upVector, 0, 255, 0, 255)
    end
  end
end)]]