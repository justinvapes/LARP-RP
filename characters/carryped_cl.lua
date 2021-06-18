local math_huge = math.huge
local DrawMarker = DrawMarker
local carrySettings = {}
local carryingOrBeingCarried = false
local isCarrier = false
local wasTempRessed = false
local spamBlock = {timeSec = 10, last = 0}

local function draw3DCarryText(x, y, z, text, sc)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, sc or 0.55 * scale)
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

local function getClosestPlayer()
  local players = GetActivePlayers()
  local closestDistance = math_huge
  local closestPlayer = -1
  local ped = PlayerPedId()
  local ppos = GetEntityCoords(ped)

  for i = 1, #players do
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

RegisterNetEvent("bms:characters:carry:init")
AddEventHandler("bms:characters:carry:init", function(data)
  carrySettings = data.carrySettings or {}
end)

RegisterNetEvent("bms:characters:carryPed:doCarry")
AddEventHandler("bms:characters:carryPed:doCarry", function(data)
  local ped = PlayerPedId()
  local handcuffed = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)
  local inVeh = IsPedInAnyVehicle(ped)

  if (handcuffed or inVeh) then
    TriggerServerEvent("bms:characters:carryPed:cancelCarry")
    return
  end

  Citizen.CreateThread(function()
    local serverId = GetPlayerServerId(PlayerId())

    while (not HasAnimDictLoaded(carrySettings.anims.carry.dict)) do
      RequestAnimDict(carrySettings.anims.carry.dict)
      Wait(5)
    end

    while (not HasAnimDictLoaded(carrySettings.anims.beingCarried.dict)) do
      RequestAnimDict(carrySettings.anims.beingCarried.dict)
      Wait(5)
    end

    local ped = PlayerPedId()

    SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"))

    if (data.carrySrc == serverId) then -- carrying someone else
      TaskPlayAnim(ped, carrySettings.anims.carry.dict, carrySettings.anims.carry.anim, 2.0, 2.0, -1, carrySettings.anims.carry.flags)
      exports.emotes:setCanEmote(false)
      exports.emotes:blockHandsUp(true)
      exports.communications:canUsePhone(false)
      carryingOrBeingCarried = true
      isCarrier = true

      local entBag = Entity(ped)

      entBag.state:set("blockEnterTrunk", true)
      exports.csrp_gamemode:blockSprint(true)
      exports.csrp_gamemode:setDefaultMovementRate(0.75)
    elseif (data.carryTarget == serverId) then -- being carried by someone else
      local attachToPed = GetPlayerPed(GetPlayerFromServerId(data.carrySrc))
      
      if (#(GetEntityCoords(ped) - GetEntityCoords(attachToPed)) > 3.0) then
        exports.pnotify:SendNotification({text = "The person wanting to carry you is too far away."})
        TriggerServerEvent("bms:characters:carryPed:cancelCarry")
        return
      end

      local wasDead = false

      if (IsPedDeadOrDying(ped)) then
        wasDead = true
        Wait(60)
      end
      
      local offset = carrySettings.anims.beingCarried.attachOffset
      
      if (wasDead) then
        local pos = GetEntityCoords(ped)
        
        NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, true, true, false)
        wasTempRessed = true
      end

      TaskPlayAnim(ped, carrySettings.anims.beingCarried.dict, carrySettings.anims.beingCarried.anim, 2.0, 2.0, -1, carrySettings.anims.beingCarried.flags)
      AttachEntityToEntity(ped, attachToPed, 0, offset.x, offset.y, offset.z, 0.5, 0.5, 180, false, false, false, false, 2, false)
      exports.emotes:setCanEmote(false)
      exports.emotes:blockHandsUp(true)
      exports.communications:canUsePhone(false)
      carryingOrBeingCarried = true
      isCarrier = false
    end
  end)
end)

RegisterNetEvent("bms:characters:carryPed:cancelCarry")
AddEventHandler("bms:characters:carryPed:cancelCarry", function(wasPlayerDead)
  local ped = PlayerPedId()
  local entBag = Entity(ped)
  
  if (carryingOrBeingCarried) then
    if (IsEntityPlayingAnim(ped, carrySettings.anims.carry.dict, carrySettings.anims.carry.anim, carrySettings.anims.carry.flags)) then
      StopAnimTask(ped, carrySettings.anims.carry.dict, carrySettings.anims.carry.anim, 1.0)
    elseif (IsEntityPlayingAnim(ped, carrySettings.anims.beingCarried.dict, carrySettings.anims.beingCarried.anim, carrySettings.anims.beingCarried.flags)) then
      StopAnimTask(ped, carrySettings.anims.beingCarried.dict, carrySettings.anims.beingCarried.anim, 1.0)
    end

    DetachEntity(ped, true, false)
    exports.emotes:setCanEmote(true)
    exports.emotes:blockHandsUp(false)
    exports.communications:canUsePhone(true)
    SetPedCanSwitchWeapon(ped, true)
    carryingOrBeingCarried = false
    
    if (not isCarrier) then
      RemoveAnimDict(carrySettings.anims.beingCarried.dict)
    else
      RemoveAnimDict(carrySettings.anims.carry.dict)
    end
    
    isCarrier = false
    exports.csrp_gamemode:blockSprint(false)
    exports.csrp_gamemode:setDefaultMovementRate(1.0)

    if (wasPlayerDead) then
      SetEntityHealth(ped, 0)
    end

    entBag.state:set("blockEnterTrunk", nil)
    wasTempRessed = false
  end
end)

AddEventHandler("bms:characters:carryPed:amToggle", function()
  if (not carryingOrBeingCarried) then
    local closestPlayer, closestDist = getClosestPlayer()

    if (closestPlayer > 0 and closestDist < carrySettings.carryDist) then
      if (spamBlock.last == 0 or GetGameTimer() > (spamBlock.last + spamBlock.timeSec * 1000)) then
        local sid = GetPlayerServerId(closestPlayer)

        spamBlock.last = GetGameTimer()
        TriggerServerEvent("bms:management:genericConfirm", GetPlayerServerId(closestPlayer), "bms:characters:carryPed:carryConfirm", "wants to <span style='color: skyblue'>carry</span> you.", 0, "bms:characters:carryPed:carryReject")
      else
        exports.pnotify:SendNotification({text = "You can not do that yet.  Don't try to spam carry people."})
      end
    else
      exports.pnotify:SendNotification({text = "Nobody was found nearby."})
    end
  else
    TriggerServerEvent("bms:characters:carryPed:cancelCarry")
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local health = GetEntityHealth(ped)

    if (carryingOrBeingCarried) then
      BlockWeaponWheelThisFrame()
      SetPedCanSwitchWeapon(ped, false)
      DisableControlAction(0, 44, true) -- cover [Q]
      DisableControlAction(0, 23, true) -- enter veh [F]
      DisableControlAction(0, 22, true) -- jump [space]
      DisableControlAction(0, 24, true) -- attack [left click]
      DisableControlAction(0, 25, true) -- aim [right click]
      DisableControlAction(0, 38, true) -- actions [E]
      DisableControlAction(0, 29, true) -- submission [B] (shift unblocked)

      if (carrySettings and carrySettings.reviveSpots) then
        local pos = GetEntityCoords(ped)

        for reviverIndex, reviveSpot in pairs(carrySettings.reviveSpots) do
          local dist = #(pos - reviveSpot.pos)

          if (dist < 80) then
            DrawMarker(1, reviveSpot.pos.x, reviveSpot.pos.y, reviveSpot.pos.z - 1, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.45, 235, 164, 52, 65)
            
            if (dist < 1.0 and wasTempRessed) then
              if (GlobalState.activeDuty and GlobalState.activeDuty.emsIds) then
                local cost = reviveSpot.cost

                for _, _ in pairs(GlobalState.activeDuty.emsIds) do
                  cost = cost + carrySettings.costIncPerEmsOnline
                end

                draw3DCarryText(reviveSpot.pos.x, reviveSpot.pos.y, reviveSpot.pos.z + 0.25, ("Press [~b~E~w~] to revive here.  It will cost ~g~%s~w~."):format(cost), 0.37)
              else
                draw3DCarryText(reviveSpot.pos.x, reviveSpot.pos.y, reviveSpot.pos.z + 0.25, ("Press [~b~E~w~] to revive here.  It will cost ~g~%s~w~."):format(reviveSpot.cost), 0.37)
              end

              if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then
                TriggerServerEvent("bms:characters:carryPed:doCarriedRevive", reviverIndex)
              end
            end
          end
        end
      end

      if (IsPedDeadOrDying(ped) or IsPedBeingStunned(ped) or IsPedCuffed(ped)) then
        TriggerServerEvent("bms:characters:carryPed:cancelCarry")
      end

      -- Reapply if animation fails.  Animation would stop if carried through a door.
      if (not isCarrier and not IsEntityPlayingAnim(ped, carrySettings.anims.beingCarried.dict, carrySettings.anims.beingCarried.anim, 3)) then
        TaskPlayAnim(ped, carrySettings.anims.beingCarried.dict, carrySettings.anims.beingCarried.anim, 2.0, 2.0, -1, carrySettings.anims.beingCarried.flags)
      elseif (isCarrier and not IsEntityPlayingAnim(ped, carrySettings.anims.carry.dict, carrySettings.anims.carry.anim, 3)) then
        TaskPlayAnim(ped, carrySettings.anims.carry.dict, carrySettings.anims.carry.anim, 2.0, 2.0, -1, carrySettings.anims.carry.flags)
      end
    end
  end
end)

-- Keybinds
RegisterCommand("-carryClosestPlayer", function()
  TriggerEvent("bms:characters:carryPed:amToggle")
end)

RegisterKeyMapping("-carryClosestPlayer", "Carry Closest Player", "keyboard", "")