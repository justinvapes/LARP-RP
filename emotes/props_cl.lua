local table_insert = table.insert
local table_sort = table.sort
local debug = {active = false, poffset = {x = 0, y = 0, z = 0}, roffset = {x = 0, y = 0, z = 0}}
--print("RESET DEBUG")
local curprop = {ent = 0, propid = "", dropped = false, animidx = 1}
local forcedprop = {ent = 0, propid = "", animidx = 1}
local pickupanims = {
  {dict = "random@domestic", anim = "pickup_low", flag = 48, pause = 700},
  {dict = "anim@heists@box_carry@", anim = "idle", flag = 49, pause = 700},
  {dict = "anim@cellphone@in_car@ps", anim = "cellphone_text_read_base", flag = 49, pause = 700},
  {dict = "mp_player_inteat@burger", anim = "mp_player_int_eat_burger_enter", flag = 50, pause = 700},
  {dict = "amb@bagels@male@walking@", anim = "static", flag = 50, pause = 700},
  {dict = "weapons@first_person@aim_idle@p_m_zero@light_machine_gun@combat_mg@fidgets@b", anim = "fidget_med_loop", flag = 49, pause = 700},
  {dict = "oddjobs@bailbond_hobotwitchy", anim = "idle_a", flag = 1, pause = 700},
  {dict = "amb@code_human_wander_drinking@beer@male@base", anim = "static", flag = 49, pause = 700},
  {dict = "impexp_int-0", anim = "mp_m_waremech_01_dual-0", flag = 49, pause = 700}
}
local dropkey = 117 -- numpad 7
local unarmedHash = GetHashKey("WEAPON_UNARMED")
local cangetprop = true

local function removeProp()
  if (curprop.ent ~= 0) then
    if (DoesEntityExist(curprop.ent)) then
      TriggerServerEvent("bms:management:unregisterSpawnedProp", NetworkGetNetworkIdFromEntity(curprop.ent))
      DeleteEntity(curprop.ent)
    end

    local ped = PlayerPedId()
    local anim = pickupanims[curprop.animidx]

    if (anim) then
      if (IsEntityPlayingAnim(ped, anim.dict, anim.anim, 3)) then
        StopAnimTask(ped, anim.dict, anim.anim, 2.0)
      end
    end

    curprop.ent = 0
    curprop.dropped = false
    curprop.animidx = 1
    curprop.propid = ""
  end

  TriggerEvent("bms:emotes:props:attachedNewProp", curprop)
end

local function loadAnimDict(dict)
  while (not HasAnimDictLoaded(dict)) do
    RequestAnimDict(dict)
    Wait(10)
  end
end

function playPickupAnim(idx, cb)
  local ped = PlayerPedId()
  local pua = pickupanims[1]
  local sanim

  if (idx and idx > 1) then
    sanim = pickupanims[idx]
  end

  Citizen.CreateThread(function()
    loadAnimDict(pua.dict)
    TaskPlayAnim(ped, pua.dict, pua.anim, 2.0, 2.0, 1.0, pua.flag, 0.0, 0, 0, 0)
    Wait(pua.pause)

    if (sanim) then
      TaskPlayAnim(ped, sanim.dict, sanim.anim, 2.0, 2.0, 1.0, sanim.flag, 0.0, 0, 0, 0)
    end

    RemoveAnimDict(pua.dict)

    cb()
  end)
end

function getProp(prname)
  if (prname) then
    TriggerEvent("bms:emotes:props:getProp", prname)
  end
end

function setCanGetProp(toggle)
  cangetprop = toggle
end

function getCurrentProp()
  if (curprop.ent and curprop.ent ~= 0) then
    return curprop.ent
  end
end

function getCurrentForcedProp()
  if (forcedprop.ent and forcedprop.ent ~= 0) then
    return forcedprop.ent
  end
end

RegisterNetEvent("bms:emotes:initializeEmotes")
AddEventHandler("bms:emotes:initializeEmotes", function()
  exports.actionmenu:addCategory("Props", 8)

  local names = {}
  local strlist = ""

  for k,_ in pairs(attachProps) do
    table_insert(names, k)
  end

  table_sort(names)

  for _,v in pairs(names) do
    if (not v.disablecmd) then
      local name = v:gsub("^%l", string.upper)
      
      exports.actionmenu:addAction("emotes", "prop", "none", name, 8, v)
    end
  end
end)

RegisterNetEvent("bms:emotes:props:getProp")
AddEventHandler("bms:emotes:props:getProp", function(param, forceDebug)
  local ped = PlayerPedId()
  local cuffed = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)

  if (forceDebug) then
    debug.active = true
  end

  exports.lawenforcement:isPlayerOnDutyCop(function(iscop)
    exports.ems:isPlayerOnDutyEms(function(isems)
      isResponderOnDuty = iscop or isems
    end)
  end)

  if (cuffed or not cangetprop) then
    exports.pnotify:SendNotification({text = "You can not use props at this time."})
    return
  end

  if (param) then
    if (param == "?") then
      local keys = {}
      local strlist = ""

      for k,v in pairs(attachProps) do
        if (not v.disablecmd) then
          table_insert(keys, k)
        end
      end

      table_sort(keys)

      for _,v in pairs(keys) do
        strlist = strlist .. string.format("%s, ", v)
      end

      strlist = strlist:sub(1, -3)
      TriggerEvent("chatMessage", "SERVER", {0, 255, 255}, string.format("Props List: %s", strlist))
    else
      if (curprop.ent == 0) then
        local prop = attachProps[param]

        if (prop) then
          if (prop.disablecmd) then
            return
          end

          blockHandsUp(true)
          local model = prop.model
          
          if (type(prop.model) == "string") then
            model = GetHashKey(prop.model)
          end

          if param == "defib" or param == "medkit2" or param == "medkit3" or param == "emsbag" then
            if (not isResponderOnDuty) then
              exports.pnotify:SendNotification({text = string.format("You must be an on duty EMS/LEO to use this prop.")})
              return
            end
          end
          
          local bone = GetPedBoneIndex(ped, prop.bone)
          local anim = pickupanims[prop.canim]
                              
          SetCurrentPedWeapon(ped, 0xA2719263)
          
          while (not HasModelLoaded(model)) do
            RequestModel(model)
            Wait(10)
          end

          curprop.ent = CreateObject(model, 1.0, 1.0, 1.0, true, true, false)
          curprop.propid = param
          curprop.animidx = prop.canim or 1
          
          while (not DoesEntityExist(curprop.ent)) do
            Wait(10)
          end

          curprop.netid = ObjToNet(curprop.ent)
          AttachEntityToEntity(curprop.ent, ped, bone, prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, 1, 1, 0, 0, 2, 1)
          SetEntityCollision(curprop.ent, false, true)
          SetModelAsNoLongerNeeded(model)
          TriggerServerEvent("bms:management:registerSpawnedProp", curprop.netid)
          TriggerEvent("bms:emotes:props:attachedNewProp", curprop)

          if (curprop.animidx > 1) then
            loadAnimDict(anim.dict)
            TaskPlayAnim(ped, anim.dict, anim.anim, 2.0, 2.0, 1.0, anim.flag, 0.0, 0, 0, 0)
          end

          if (debug.active) then
            debug.poffset.x = prop.pos.x
            debug.poffset.y = prop.pos.y
            debug.poffset.z = prop.pos.z
            debug.roffset.x = prop.rot.x
            debug.roffset.y = prop.rot.y
            debug.roffset.z = prop.rot.z
          end
        else
          exports.pnotify:SendNotification({text = string.format("Prop <span style='color: lawngreen'>%s</span> not recognized.  Type <span style='color: skyblue'>'/getprop ?'</span> for a complete list.", param)})
        end
      else -- detach
        removeProp()
      end
    end
  end
end)

--forcedprop
RegisterNetEvent("bms:emotes:setForcedProp")
AddEventHandler("bms:emotes:setForcedProp", function(name, skipForceInventoryUnblock)
  local ped = PlayerPedId()
  local prop = attachProps[name]

  if (not prop) then
    return
  end

  if (forcedprop.ent == 0) then
    blockHandsUp(true)
    local model = GetHashKey(prop.model)
    local bone = GetPedBoneIndex(ped, prop.bone)
    local anim = pickupanims[prop.canim]
                        
    SetCurrentPedWeapon(ped, 0xA2719263)
    
    while (not HasModelLoaded(model)) do
      RequestModel(model)
      Wait(10)
    end

    forcedprop.ent = CreateObject(model, 1.0, 1.0, 1.0, true, true, false)
    forcedprop.propid = name
    forcedprop.animidx = prop.canim or 1
    
    while (not DoesEntityExist(forcedprop.ent)) do
      Wait(10)
    end

    forcedprop.netid = ObjToNet(forcedprop.ent)
    AttachEntityToEntity(forcedprop.ent, ped, bone, prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, 1, 1, 0, 0, 2, 1)
    SetModelAsNoLongerNeeded(model)
    TriggerEvent("bms:emotes:props:attachedNewProp", forcedprop)

    if (forcedprop.animidx > 1) then
      loadAnimDict(anim.dict)
      TaskPlayAnim(ped, anim.dict, anim.anim, 2.0, 2.0, 1.0, anim.flag, 0.0, 0, 0, 0)
    end
    
    if (not skipForceInventoryUnblock) then
      exports.inventory:blockInventoryUse(false) -- This could be causing conflicts.
    end
  else
    TriggerEvent("bms:emotes:clearForcedProp")
  end
end)

RegisterNetEvent("bms:emotes:clearForcedProp")
AddEventHandler("bms:emotes:clearForcedProp", function()  
  if (forcedprop.ent ~= 0) then
    if (DoesEntityExist(forcedprop.ent)) then
      DeleteEntity(forcedprop.ent)
    end

    local ped = PlayerPedId()
    local anim = pickupanims[forcedprop.animidx]

    if (anim) then
      if (IsEntityPlayingAnim(ped, anim.dict, anim.anim, 3)) then
        StopAnimTask(ped, anim.dict, anim.anim, 2.0)
      end
    end

    forcedprop.ent = 0
    forcedprop.animidx = 1
    forcedprop.propid = ""
  end

  blockHandsUp(false)
  exports.inventory:blockInventoryUse(false)
  TriggerEvent("bms:emotes:props:attachedNewProp", forcedprop)
end)

RegisterNetEvent("bms:emotes:props:prsave")
AddEventHandler("bms:emotes:props:prsave", function()
  if (debug.active and curprop) then
    local data = {poffset = debug.poffset, roffset = debug.roffset, prname = curprop.propid}
    
    TriggerServerEvent("bms:emotes:props:prsave", data)
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    if (curprop.ent ~= 0) then
      local ped = PlayerPedId()
      local dead = IsPedDeadOrDying(ped)
      local cuffed = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)
      
      if (not curprop.dropped) then
        if (dead or cuffed) then
          removeProp()
        else
          local prop = attachProps[curprop.propid]

          if (not prop.static) then
            if (IsControlJustReleased(1, dropkey) and (GetSelectedPedWeapon(ped) == unarmedHash)) then
              playPickupAnim(1, function()
                curprop.dropped = true
                DetachEntity(curprop.ent)
                SetEntityCollision(curprop.ent, false, false)

                if (not prop.freefall) then
                  PlaceObjectOnGroundProperly(curprop.ent)
                end

                if (prop.dropRotation) then
                  SetEntityRotation(curprop.ent, prop.dropRotation.x, prop.dropRotation.y, prop.dropRotation.z, 1)
                end
                
                blockHandsUp(false)
              end)
            end
          end
        end
      else
        local pos = GetEntityCoords(ped)
        local epos = GetEntityCoords(curprop.ent)
        local dist = #(pos.xy - epos.xy)
        local prop = attachProps[curprop.propid]

        if (dist > 80.0 or dead) then
          removeProp()
        elseif (dist < 1.15) then
          if (IsControlJustReleased(1, dropkey) and (GetSelectedPedWeapon(ped) == unarmedHash)) then
            playPickupAnim(prop.canim, function()
              local prop = attachProps[curprop.propid]
              local bone = GetPedBoneIndex(ped, prop.bone)

              if (prop) then
                blockHandsUp(true)
                SetCurrentPedWeapon(ped, 0xA2719263)
                curprop.dropped = false
                AttachEntityToEntity(curprop.ent, ped, bone, prop.pos.x, prop.pos.y, prop.pos.z, prop.rot.x, prop.rot.y, prop.rot.z, 1, 1, 0, 0, 2, 1)
                SetEntityCollision(curprop.ent, false, true)
              end
            end)
          end
        end
      end
    end

    --[[if (curprop.ent ~= 0 and not curprop.dropped) then
      local ped = PlayerPedId()
      
      DisableControlAction(0, 24, true) -- Attack
      DisablePlayerFiring(ped, true) -- Disable weapon firing
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
      DisableControlAction(0, 37, true) -- SelectWeapon
      DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
      DisableControlAction(0, 25, true) -- INPUT_AIM
    end]]
    
    if (debug.active and curprop.ent ~= 0) then
      local ped = PlayerPedId()
      local prop = attachProps[curprop.propid]

      if (prop) then
        local bone = GetPedBoneIndex(ped, prop.bone)
        local trpos = GetWorldPositionOfEntityBone(ped, bone)

        if (IsControlPressed(1, 172)) then -- up arrow
          DetachEntity(curprop.ent)
          debug.poffset.z = debug.poffset.z + 0.005
          AttachEntityToEntity(curprop.ent, ped, bone, debug.poffset.x, debug.poffset.y, debug.poffset.z, debug.roffset.x, debug.roffset.y, debug.roffset.z, 1, 1, 0, 0, 2, 1)

          while (not IsEntityAttachedToEntity(curprop.ent, ped)) do
            Wait(10)
          end
        end

        if (IsControlPressed(1, 173)) then -- down arrow
          DetachEntity(curprop.ent)
          debug.poffset.z = debug.poffset.z - 0.005
          AttachEntityToEntity(curprop.ent, ped, bone, debug.poffset.x, debug.poffset.y, debug.poffset.z, debug.roffset.x, debug.roffset.y, debug.roffset.z, 1, 1, 0, 0, 2, 1)

          while (not IsEntityAttachedToEntity(curprop.ent, ped)) do
            Wait(10)
          end
        end

        if (IsControlPressed(1, 174)) then -- left arrow
          DetachEntity(curprop.ent)
          debug.poffset.y = debug.poffset.y + 0.005
          AttachEntityToEntity(curprop.ent, ped, bone, debug.poffset.x, debug.poffset.y, debug.poffset.z, debug.roffset.x, debug.roffset.y, debug.roffset.z, 1, 1, 0, 0, 2, 1)

          while (not IsEntityAttachedToEntity(curprop.ent, ped)) do
            Wait(10)
          end
        end

        if (IsControlPressed(1, 175)) then -- right arrow
          DetachEntity(curprop.ent)
          debug.poffset.y = debug.poffset.y - 0.005
          AttachEntityToEntity(curprop.ent, ped, bone, debug.poffset.x, debug.poffset.y, debug.poffset.z, debug.roffset.x, debug.roffset.y, debug.roffset.z, 1, 1, 0, 0, 2, 1)

          while (not IsEntityAttachedToEntity(curprop.ent, ped)) do
            Wait(10)
          end
        end

        if (IsControlPressed(1, 108)) then -- NUM 4
          DetachEntity(curprop.ent)
          debug.poffset.x = debug.poffset.x - 0.005
          AttachEntityToEntity(curprop.ent, ped, bone, debug.poffset.x, debug.poffset.y, debug.poffset.z, debug.roffset.x, debug.roffset.y, debug.roffset.z, 1, 1, 0, 0, 2, 1)

          while (not IsEntityAttachedToEntity(curprop.ent, ped)) do
            Wait(10)
          end
        end

        if (IsControlPressed(1, 109)) then -- NUM 6
          DetachEntity(curprop.ent)
          debug.poffset.x = debug.poffset.x + 0.005
          AttachEntityToEntity(curprop.ent, ped, bone, debug.poffset.x, debug.poffset.y, debug.poffset.z, debug.roffset.x, debug.roffset.y, debug.roffset.z, 1, 1, 0, 0, 2, 1)

          while (not IsEntityAttachedToEntity(curprop.ent, ped)) do
            Wait(10)
          end
        end

        -- rot
        if (IsControlPressed(1, 314)) then -- NUM +
          DetachEntity(curprop.ent)
          
          if (IsControlPressed(1, 21)) then -- SHIFT + NUM+
            debug.roffset.y = debug.roffset.y + 0.5
          elseif (IsControlPressed(1, 137)) then -- CAPSLOCK + NUM+
            debug.roffset.z = debug.roffset.z + 0.5
          else
            debug.roffset.x = debug.roffset.x + 0.5
          end
          
          AttachEntityToEntity(curprop.ent, ped, bone, debug.poffset.x, debug.poffset.y, debug.poffset.z, debug.roffset.x, debug.roffset.y, debug.roffset.z, 1, 1, 0, 0, 2, 1)

          while (not IsEntityAttachedToEntity(curprop.ent, ped)) do
            Wait(10)
          end
        end

        if (IsControlPressed(1, 315)) then -- NUM -
          DetachEntity(curprop.ent)
          
          if (IsControlPressed(1, 21)) then -- SHIFT + NUM+
            debug.roffset.y = debug.roffset.y - 0.5
          elseif (IsControlPressed(1, 137)) then -- CAPSLOCK + NUM+
            debug.roffset.z = debug.roffset.z - 0.5
          else
            debug.roffset.x = debug.roffset.x - 0.5
          end

          AttachEntityToEntity(curprop.ent, ped, bone, debug.poffset.x, debug.poffset.y, debug.poffset.z, debug.roffset.x, debug.roffset.y, debug.roffset.z, 1, 1, 0, 0, 2, 1)

          while (not IsEntityAttachedToEntity(curprop.ent, ped)) do
            Wait(10)
          end
        end
      end
    end
  end
end)