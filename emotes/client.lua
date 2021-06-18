local emotes = {}
local stances = {}
local groupanimations = {}
local expressions = {}
local canEmote = true
local subemote = {
  {dict = "random@arrests", anim = "idle_2_hands_up"},
  {dict = "random@arrests", anim = "kneeling_arrest_idle"},
  {dict = "random@arrests", anim = "kneeling_arrest_get_up"}
}
local fingeremote = {
  {dict = "mp_player_int_upperfinger", anim = "mp_player_int_finger_02_enter"},
  {dict = "mp_player_int_upperfinger", anim = "mp_player_int_finger_02"},
  {dict = "mp_player_int_upperfinger", anim = "mp_player_int_finger_02_exit"}
}
local submitting = false
local flicking = false
local notifyonce = false
local cscenario = nil
local chairtext = {draw = false, pos = {}, text = ""}
local chairobj = {}
local dshownames = false -- debug to show model name for chair in sit string
local scannerActive = true
local lastshadowspot = {spot = nil, pos = nil}
local chairsEnabled = true
local chairHashes = {}
local closestChairs = {}
local isCuffed = false
local stanceState = false
--local debugs = {}

function objectScannerToggle(val)
  scannerActive = val
end

function vectorNotZero(v)
  return math.floor(v.x) ~= 0 and math.floor(v.y) ~= 0 and math.floor(v.z) ~= 0
end

local function draw3DText(x, y, z, text)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, 0.30 * scale)
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

function doEmoteById(id) -- data is nil for new emotes
  local ped = PlayerPedId()

  if (not canEmote) then
    exports.pnotify:SendNotification({text = "You can not emote at this time."})
    return
  end

  if (not isCuffed) then
  
    if (id == -1) then
      ClearPedTasks(ped)
    else
      local emote = emotes[id]
      
      if (emote) then
        local inVeh = IsPedInAnyVehicle(ped, true)
              
        if (not inVeh) then
          ClearPedTasks(ped)
          
          if (emote.anim) then -- old anims
            Citizen.CreateThread(function()
              RequestAnimDict(emote.entry)
              
              while not HasAnimDictLoaded(emote.entry) do
                Wait(100)
              end
          
              if (IsEntityPlayingAnim(ped, emote.entry, emote.anim, 3)) then
                ClearPedSecondaryTask(ped)
              else
                TaskPlayAnim(ped, emote.entry, emote.anim, 2.0, 2.0, -1, emote.flags, 0, 0, 0, 0)
                SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
              end
              RemoveAnimDict(emote.entry)
            end)
          else -- new scenerios
            TaskStartScenarioInPlace(ped, emote.hash, emote.delay, emote.playEntry)
            TriggerServerEvent("bms:emotes:logemote", emote)
          end
        else
          exports.pnotify:SendNotification({text = "You can not emote while inside of a vehicle or when handcuffed."})
        end
      end
    end
  else
    exports.pnotify:SendNotification({text = "You can not emote while inside of a vehicle or when handcuffed."})
  end
end

function doStanceById(id)
  local ped = PlayerPedId()

  if (not isCuffed) then
    if (id == -1) then
      ResetPedMovementClipset(ped, 0)
    else
      local stance = stances[id]
      if (stance) then
        if (not HasAnimSetLoaded(stance.hash)) then
          RequestAnimSet(stance.hash)
        
          while (not HasAnimSetLoaded(stance.hash)) do
            Wait(0)
          end
        end

        SetPedMovementClipset(ped, stance.hash, 1.0)
        RemoveAnimSet(stance.hash)
      end
    end
  else
    exports.pnotify:SendNotification({text = "You can not emote while inside of a vehicle or when handcuffed."})
  end
end

function doExpressionById(id)
  local ped = PlayerPedId()
  if (not isCuffed) then
    if (id == -1) then
      SetFacialIdleAnimOverride(ped, "mood_normal_1", 0)
    else
      local expressions = expressions[id]
      if (expressions) then
        SetFacialIdleAnimOverride(ped, expressions.hash, 0)
      end
    end
  else
    exports.pnotify:SendNotification({text = "You can not do that right now."})
  end
end

function doAnim(data) -- old style emotes
  local entry = data.entry
  local anim = data.anim
  local flags = data.flags

  local ped = PlayerPedId()

  if (not isCuffed) then
    Citizen.CreateThread(function()
      RequestAnimDict(entry)
      
      while not HasAnimDictLoaded(entry) do
        Citizen.Wait(100)
      end

      if (IsEntityPlayingAnim(ped, entry, anim, 3)) then
        ClearPedSecondaryTask(ped)
      else
        TaskPlayAnim(ped, entry, anim, 2.0, 2.0, -1, flags, 0, 0, 0, 0)
        SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
      end

      RemoveAnimDict(entry)
    end)
  else
    exports.pnotify:SendNotification({text = "You can not emote while inside of a vehicle or when handcuffed."})
  end
end

function setCanEmote(toggle)
  canEmote = toggle
  setCanGetProp(toggle)
end

function getEmoteByCommand(command)
  for _,v in pairs(emotes) do
    if (v.command == command) then
      return v
    end
  end
end

function getClosestObjectOfTypes(objects)
  if (not objects) then
    return nil
  end
  
  local cl = {dist = -1, obj = -1}
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)

  for _,o in pairs(GetGamePool("CObject")) do
    local opos = GetEntityCoords(o)
    local dist = Vdist(pos.x, pos.y, pos.z, opos.x, opos.y, opos.z)

    if (dist < 10.0) then
      local omodel = GetEntityModel(o)
      
      for _,v in pairs(objects) do
        local cmodel
        
        if (type(v) == "string") then
          cmodel = GetHashKey(v)
        else
          cmodel = v
        end

        if (cmodel == omodel) then
          FreezeEntityPosition(o, true) -- seems to work for most benches/chairs to help stop desync, but not all (for whatever stupid reason)
          SetEntityDynamic(o, false)

          if (cl.dist == -1 or cl.dist > dist) then
            cl.name = v
            cl.obj = o
            cl.dist = dist
          end
        end
      end
    end
  end

  return cl
end

--local debugs = {}

function sitInChair(obj, model, data)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local opos = GetEntityCoords(obj)

  if (not vectorNotZero(opos)) then
    return
  end
  
  --FreezeEntityPosition(obj, true) -- set on collection to avoid desyncing position/orientation
  --SetEntityDynamic(obj, false)
  cscenario = data.scenario

  if (data.offsetLr) then
    local offs = {left = GetOffsetFromEntityInWorldCoords(obj, data.offsetLr, 0.0, 0.0), right = GetOffsetFromEntityInWorldCoords(obj, -data.offsetLr, 0.0, 0.0)}
    local distL = Vdist(pos.x, pos.y, pos.z, offs.left.x, opos.y, opos.z)
    local distR = Vdist(pos.x, pos.y, pos.z, offs.right.x, opos.y, opos.z)

    --[[debugs = {}
    table.insert(debugs, {pos = {x = offs.left.x, y = offs.left.y, z = offs.left.z}})
    table.insert(debugs, {pos = {x = offs.right.x, y = offs.right.y, z = offs.right.z}})]]

    if (distL < distR) then
      TaskStartScenarioAtPosition(ped, cscenario, offs.left.x, offs.left.y, offs.left.z - data.verticalOffset, GetEntityHeading(obj) + 180.0, 0, true, true)
    else
      TaskStartScenarioAtPosition(ped, cscenario, offs.right.x, offs.right.y, offs.right.z - data.verticalOffset, GetEntityHeading(obj) + 180.0, 0, true, true)
    end
  else
    if (data.other) then
      TaskStartScenarioAtPosition(ped, cscenario, opos.x, opos.y, opos.z - data.verticalOffset, GetEntityHeading(obj) + data.rot, 0, false, true)
    else
      TaskStartScenarioAtPosition(ped, cscenario, opos.x, opos.y, opos.z - data.verticalOffset, GetEntityHeading(obj) + 180.0, 0, true, true)
    end
  end

  sitting = true
  TriggerEvent("bms:emotes:sitStateChanged", true)
end

RegisterNetEvent("bms:emotes:initializeEmotes")
AddEventHandler("bms:emotes:initializeEmotes", function()
  exports.actionmenu:addCategory("Emotes", 2)
  exports.actionmenu:addCategory("Stances", 6)
  exports.actionmenu:addCategory("Group Emotes", 10)
  exports.actionmenu:addCategory("Expressions", 14)
  exports.actionmenu:addAction("emotes", "emote", "none", "End Emote", 2, -1)
  exports.actionmenu:addAction("emotes", "stance", "none", "Default Stance", 6, -1)
  exports.actionmenu:addAction("emotes", "expressions", "none", "Default Expression", 14, -1)

  TriggerServerEvent("bms:emotes:getEmotes")
end)

RegisterNetEvent("bms:emotes:setEmotes")
AddEventHandler("bms:emotes:setEmotes", function(data)
  if (data) then
    emotes = data.emotes
    stances = data.stances
    groupanimations = data.groupanimations
    expressions = data.expressions
    
    for i,v in ipairs(groupanimations) do
      exports.actionmenu:addAction("emotes", "groupanim", "ped", v.desc, 10, i)
    end

    for i,v in ipairs(emotes) do
      exports.actionmenu:addAction("emotes", "emote", "none", v.desc, 2, i, v.cat)
    end

    for i,v in ipairs(stances) do
      exports.actionmenu:addAction("emotes", "stance", "none", v.desc, 6, i)
    end

    for i,v in ipairs(expressions) do
      exports.actionmenu:addAction("emotes", "expressions", "none", v.desc, 14, i)
    end
  end
end)

RegisterNetEvent("bms:actionmenu:resourceRestarted")
AddEventHandler("bms:actionmenu:resourceRestarted", function()
  TriggerEvent("bms:emotes:initializeEmotes")
end)

RegisterNetEvent("bms:emotes:doEmote")
AddEventHandler("bms:emotes:doEmote", function(emname)
  if (canEmote) then
    if (emname) then
      local exists = false
      local oldem = false
      local data = {}
      local emnum = 0
      
      --Citizen.Trace(string.format("%s", emname))

      for i,v in ipairs(emotes) do
        if (v.command == emname) then
          exists = true
          emnum = i

          if (v.hash == "") then
            oldem = true
            data = {entry = v.entry, anim = v.anim, flags = v.flags}
          end

          break
        end
      end
      
      if (exists) then
        if (oldem) then
          doAnim(data)
        else
          doEmoteById(emnum)
        end
      else
        doEmoteById(-1)
      end
    end
  else
    exports.pnotify:SendNotification({text = "You can not emote at this time."})
  end
end)

RegisterNetEvent("bms:emotes:setStance")
AddEventHandler("bms:emotes:setStance", function(stname)
  local ped = PlayerPedId()
  exists = false

  if (stname == "0") then
    ResetPedMovementClipset(ped, 0)
    stanceStatus = false
  else
    
    for i,v in ipairs(stances) do
      if (v.command == stname) then
        exists = true
        stname = i
        stplay = v.hash
      end
    end
    
    if not exists then
      ResetPedMovementClipset(ped, 0)
      stanceStatus = false
      return
    end

    if (not HasAnimSetLoaded(stplay)) then
      RequestAnimSet(stplay)
    
      while (not HasAnimSetLoaded(stplay)) do
        Wait(0)
      end

      SetPedMovementClipset(ped, stplay, 1.0)
      RemoveAnimSet(stplay)
      stanceStatus = true
    end
  end
end)

RegisterNetEvent("bms:emotes:setExpress")
AddEventHandler("bms:emotes:setExpress", function(exname)
  local ped = PlayerPedId()
  exists = false

  if (exname == "0") then
    SetFacialIdleAnimOverride(ped, "mood_normal_1", 0)
  else
    
    for i,v in ipairs(expressions) do
      if (v.command == exname) then
        exists = true
        exname = i
        explay = v.hash
      end
    end
    
    if not exists then
      SetFacialIdleAnimOverride(ped, "mood_normal_1", 0)
      return
    end

    SetFacialIdleAnimOverride(ped, explay, 0)
  end
end)

RegisterNetEvent("bms:emotes:tstance")
AddEventHandler("bms:emotes:tstance", function(stance)
  if (stance) then
    local ped = PlayerPedId()

    ResetPedMovementClipset(ped)

    while (not HasAnimSetLoaded(stance)) do
      RequestAnimSet(stance)
      Wait(10)
    end

    SetPedMovementClipset(ped, stance, 1.0)
    RemoveAnimSet(stance)
  end
end)

RegisterNetEvent("bms:emotes:toggleSitScript")
AddEventHandler("bms:emotes:toggleSitScript", function()
  chairsEnabled = not chairsEnabled
  TriggerEvent("chatMessage", "SERVER", {255, 0, 0}, string.format("Emote Chair Sit script has been toggle to %s", chairsEnabled))
end)

RegisterNetEvent("bms:emotes:doGroupEmote")
AddEventHandler("bms:emotes:doGroupEmote", function(data)
  if (data) then
    local gaindex = data.gaindex
    local gemote = groupanimations[gaindex]

    if (gemote) then
      local person = gemote[data.person]

      if (person) then
        local rped = GetPlayerPed(GetPlayerFromServerId(data.othersrc))
        local ped = PlayerPedId()

        Citizen.CreateThread(function()
          while (not HasAnimDictLoaded(person.anim.dict)) do
            RequestAnimDict(person.anim.dict)
            Wait(10)
          end

          if (gemote.turnface) then
            TaskTurnPedToFaceEntity(ped, rped, 1125)
            Wait(1125)
          end

          TaskPlayAnim(ped, person.anim.dict, person.anim.anim, 2.0, 2.0, -1, 2, 0, 0, 0, 0)
          RemoveAnimDict(person.anim.dict)

          while (not HasEntityAnimFinished(ped, person.anim.dict, person.anim.anim, 3)) do
            Wait(10)
          end

          ClearPedTasks(ped)
        end)
      else
        print("emotes >> person was nil")
      end
    else
      print("emotes >> gemote was nil")
    end
  end
end)

AddEventHandler("bms:emotes:actionDoGroupEmote", function(dped, gaindex)
  if (dped and dped > 0) then
    local cuffed = exports.cuff:isCuffed()

    if (cuffed or not canEmote) then
      exports.pnotify:SendNotification({text = "You can not emote at this time."})
    else
      TriggerServerEvent("bms:management:genericConfirm", dped, "bms:emotes:confirmGroupEmote", string.format("wants to do a <span style='color: skyblue'>%s</span>", groupanimations[gaindex].desc), gaindex)
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(500)

    exports.cuff:isCuffed(function(cuffed)
      isCuffed = cuffed

      if (cuffed and submitting) then
        submitting = false
      end
      
      if (cuffed and flicking) then
        flicking = false
      end
    end)
  end
end)

--[[ This thread is necessary because when there are large groups of objects, such as is normal with map additions, the script comes to a hault with a small thread time ]]
--[[Citizen.CreateThread(function()
  while true do
    Wait(100)

    if (scannerActive and chairsEnabled) then
      local clobj = getClosestObjectOfTypes(chairs)

      if (clobj and clobj.obj and clobj.dist < 1.5) then
        local opos = GetEntityCoords(clobj.obj)

        if (vectorNotZero(opos)) then
          chairtext.draw = true
          chairtext.pos = {x = opos.x, y = opos.y, z = opos.z}

          local data = nil
          local chair = chairs.config[tostring(clobj.name)]

          if (chair) then
            chairtext.text = string.format("Press ~b~H~w~ to %s here.", chair.desc or "sit")

            if (dshownames) then
              chairtext.text = string.format("Press ~b~H~w~ to %s here (%s).", chair.desc or "sit", k)
            end

            data = chair
          end
          
          if (data) then
            chairobj.obj = clobj.obj
            chairobj.data = data
          end
        end
      else
        chairtext.draw = false
        chairobj = {}
        local ssclose = 0.2

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        for _,v in pairs(chairs.shadowspots) do
          local d1, d2
          local dist = Vdist(pos.x, pos.y, pos.z, v.pos.x, v.pos.y, v.pos.z)
          local lpos = {x = v.pos.x, y = v.pos.y, z = v.pos.z}

          if (v.spread) then
            d1 = Vdist(pos.x, pos.y, pos.z, v.pos.x - v.spreadbias, v.pos.y, v.pos.z)
            d2 = Vdist(pos.x, pos.y, pos.z, v.pos.x + v.spreadbias, v.pos.y, v.pos.z)

            if (d1 < ssclose) then
              lastshadowspot.pos = {x = v.pos.x - v.spreadbias, y = v.pos.y, z = v.pos.z}
            elseif (d2 < ssclose) then
              lastshadowspot.pos = {x = v.pos.x + v.spreadbias, y = v.pos.y, z = v.pos.z}
            elseif (dist < ssclose) then
              lastshadowspot.pos = lpos
            end
          else
            if (dist < ssclose) then
              lastshadowspot.pos = lpos
            end
          end
        end

        if (lastshadowspot and lastshadowspot.spot) then
          local dist = Vdist(pos.x, pos.y, pos.z, lastshadowspot.pos.x, lastshadowspot.pos.y, lastshadowspot.pos.z)

          if (dist > ssclose) then
            lastshadowspot = {spot = nil, pos = nil}
          end
        end
      end
    end
  end
end)]]

Citizen.CreateThread(function()
  while true do
    Wait(100)

    if (scannerActive and chairsEnabled) then
      local pos = GetEntityCoords(PlayerPedId())
      local foundCloseChair = false

      for i=1,#closestChairs do
        local opos = closestChairs[i].pos
        local dist = #(pos - opos)

        if (dist < 1.5) then
          chairtext.draw = true
          chairtext.pos = {x = opos.x, y = opos.y, z = opos.z}

          local data = nil
          local chair = chairs.config[closestChairs[i].name]

          if (chair) then
            chairtext.text = string.format("Press ~b~H~w~ to %s here.", chair.desc or "sit")

            if (dshownames) then
              chairtext.text = string.format("Press ~b~H~w~ to %s here (%s).", chair.desc or "sit", k)
            end

            data = chair
          end
          
          if (data) then
            chairobj.obj = closestChairs[i].obj
            chairobj.data = data
          end

          foundCloseChair = true
          break
        end
      end

      if (not foundCloseChair) then
        chairtext.draw = false
        chairobj = {}
      end
    end
  end
end)

--[[ Keybound emotes ]]
Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()

    if (stanceStatus == true) then
      SetPedCanPlayAmbientAnims(ped, false)
      SetPedCanPlayAmbientIdles(ped, false, false)
    end

    --[[ Shift (21) + B (29) ]]
    if (IsControlPressed(1, 21)) then
      if (IsControlJustReleased(1, 29)) then
        if (isCuffed) then return end

        local inveh = IsPedInAnyVehicle(ped)

        if (inveh) then
          return
        end

        if (not IsEntityPlayingAnim(ped, subemote[1].dict, subemote[1].anim, 3) and not IsEntityPlayingAnim(ped, subemote[2].dict, subemote[2].anim, 3)) then
          SetCurrentPedWeapon(ped, 2725352035, true)
          exports.cuff:toggleCuffedBlockers(true)

          RequestAnimDict(subemote[1].dict)

          while (not HasAnimDictLoaded(subemote[1].dict)) do
            Wait(1)
          end

          TaskPlayAnim(ped, subemote[1].dict, subemote[1].anim, 2.0, 2.0, -1, 1, 0, 0, 0, 0)
          Wait(3000)
          TaskPlayAnim(ped, subemote[2].dict, subemote[2].anim, 2.0, 2.0, -1, 1, 0, 0, 0, 0)
          RemoveAnimDict(subemote[1].dict)
        else
          if (IsEntityPlayingAnim(ped, subemote[2].dict, subemote[2].anim, 3)) then
            TaskPlayAnim(ped, subemote[3].dict, subemote[3].anim, 2.0, 2.0, -1, 1, 0, 0, 0, 0)
            Wait(3000)
            ClearPedTasks(ped)
            
            if (isCuffed) then
              TriggerEvent("bms:Handcuff")
            else
              exports.cuff:toggleCuffedBlockers(false)
            end
          end
        end
        --[[ Shift (21) + Z (20) ]]
      elseif (IsControlPressed(1, 20)) then
        if (isCuffed) then return end

        local inveh = IsPedInAnyVehicle(ped)

        if (inveh) then
          if (not notifyonce) then
            notifyonce = true
            exports.pnotify:SendNotification({text = "You can not show someone love while in a vehicle."})
          end
          return
        end

        if (not IsEntityPlayingAnim(ped, fingeremote[1].dict, fingeremote[1].anim, 3) and not IsEntityPlayingAnim(ped, fingeremote[2].dict, fingeremote[2].anim, 3)) then
          RequestAnimDict(fingeremote[1].dict)

          while (not HasAnimDictLoaded(fingeremote[1].dict)) do
            Wait(1)
          end

          TaskPlayAnim(ped, fingeremote[1].dict, fingeremote[1].anim, 2.0, 2.0, -1, 1, 0, 0, 0, 0)
          Wait(750)
          TaskPlayAnim(ped, fingeremote[2].dict, fingeremote[2].anim, 2.0, 2.0, -1, 11, 0, 0, 0, 0)
          RemoveAnimDict(fingeremote[1].dict)
        end
      else
        notifyonce = false
        if (isCuffed) then return end

        if (IsEntityPlayingAnim(ped, fingeremote[2].dict, fingeremote[2].anim, 3)) then
          TaskPlayAnim(ped, fingeremote[3].dict, fingeremote[3].anim, 2.0, 2.0, -1, 49, 0, 0, 0, 0)
          Wait(750)
          ClearPedTasks(ped)
        end
      end
    end

    if (not sitting) then
      if (chairtext.draw and chairtext.text ~= "") then
        draw3DText(chairtext.pos.x, chairtext.pos.y, chairtext.pos.z + 0.25, chairtext.text)

        if (chairobj.obj) then
          if (not isCuffed) then
            if (GetLastInputMethod(2) and IsControlJustReleased(1, 104) and not IsPedInAnyVehicle(ped, true)) then
              sitInChair(chairobj.obj, GetEntityModel(chairobj.obj), chairobj.data)
            end
          end
        end
      end
    else
      if (GetLastInputMethod(2) and IsControlJustReleased(1, 104)) then
        ClearPedTasks(ped)
        sitting = false
        cscenario = nil
        TriggerEvent("bms:emotes:sitStateChanged", false)
      end
    end
    --[[for _,v in pairs(debugs) do
      DrawMarker(1, v.pos.x, v.pos.y, v.pos.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.1, 0, 255, 0, 110, 0, 0, 0, 0, 0, 0, 0)
    end]]
  end
end)

Citizen.CreateThread(function()
  Wait(10000)

  -- preprocessor for the chair hashes
  for _,v in pairs(chairs) do
    if (type(v) == "string") then
      chairHashes[GetHashKey(v)] = v
    else
      chairHashes[v] = tostring(v)
    end
  end

  while true do
    Wait(2500)

    if (scannerActive and chairsEnabled) then
      local ped = PlayerPedId()
      local speed = GetEntitySpeed(ped)
      local pos = GetEntityCoords(ped)
      local cChairs = {}
      local iter = 0

      if (speed < 8.73) then -- ~20 mph -- Done to hopefully prevent the object detecter from running while in a car
        local objects = GetGamePool("CObject")
        for i=1,#objects do
          local opos = GetEntityCoords(objects[i])

          if (vectorNotZero(opos)) then
            local dist = #(pos - opos)
        
            if (dist < 30.0) then
              local omodel = GetEntityModel(objects[i])
              
              if (chairHashes[omodel] ~= nil) then  
                FreezeEntityPosition(objects[i], true) -- seems to work for most benches/chairs to help stop desync, but not all (for whatever stupid reason)
                SetEntityDynamic(objects[i], false)
                iter = iter + 1
                cChairs[iter] = {obj = objects[i], name = chairHashes[omodel], dist = dist, pos = opos} -- May need to recheck pos instead of passing it
              end
            end
          end
        end
      end

      closestChairs = cChairs
    end
  end
end)
