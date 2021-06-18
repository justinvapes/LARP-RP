local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort
local json_decode = json.decode
local math_fmod = math.fmod
local math_floor = math.floor
local math_randomseed = math.randomseed
local math_random = math.random
local isk9 = false
local placemode = false
local placemodebox = false
local pmodeblip
local pradius = 10.0
local pbpos
local pbradius = 30.0
local pbradiusx = 0.0
local pbheight = 10.0
local objectdetect = false
local markertest = false
local curmarker = 0
local deltool = false
local markedItems = {}
local enttarget = false
local pblips = {}
local spmmode = false
local asemode = false
local aserange = 40.0
local hudToggle = false
local loadedprop
local lastprop = {}
local propanims = {
  {dict = "anim@heists@box_carry@", anim = "idle", flag = 49}
}
local propposrot = {
  pos = {x = 0, y = 0, z = 0},
  rot = {x = 0, y = 0, z = 0}
}
local presetprops = {
  {prop = "prop_pizza_box_01", pos = {x = 0, y = 0, z = 0}, rot = {x = 274.75, y = 74.75, z = 84.75}}
}
local hidepropdebug = false
--local speccam = {cam = -1, ped = nil, zoom = 5.0, lastpos = nil}
local k9Anims = {
  {name = "sit", dict = "creatures@rottweiler@amb@world_dog_sitting@idle_a", anim = "idle_b", flag = 1},
  {name = "sit2", dict = "creatures@rottweiler@amb@world_dog_sitting@idle_a", anim = "idle_c", flag = 1},
  {name = "lay", dict = "creatures@rottweiler@amb@sleep_in_kennel@", anim = "sleep_in_kennel", flag = 1},
  {name = "lay2", dict = "creatures@rottweiler@move", anim = "dead_left", flag = 1},
  {name = "search", dict = "creatures@rottweiler@indication@", anim = "indicate_high", flag = 0},
  {name = "search2", dict = "creatures@rottweiler@indication@", anim = "indicate_low", flag = 0},
  {name = "search3", dict = "creatures@rottweiler@indication@", anim = "indicate_ahead", flag = 0},
  {name = "bark", dict = "creatures@rottweiler@amb@world_dog_barking@idle_a", anim = "idle_a", flag = 0},
  {name = "beg", dict = "creatures@rottweiler@tricks@", anim = "beg_loop", flag = 0},
  {name = "beg2", dict = "creatures@retriever@amb@world_dog_barking@idle_a", anim = "idle_b", flag = 0},
  {name = "shake", dict = "creatures@rottweiler@tricks@", anim = "paw_right_loop", flag = 1},
  {name = "pet", dict = "creatures@rottweiler@tricks@", anim = "petting_chop", flag = 1},
  {name = "play", dict = "creatures@retriever@amb@world_dog_barking@idle_a", anim = "idle_c", flag = 0},
  {name = "poop", dict = "creatures@rottweiler@move", anim = "dump_loop", flag = 1},
  {name = "pee", dict = "creatures@rottweiler@move", anim = "pee_left_idle", flag = 1}
}
local spec = {active = false, ped = 0}
local lastodetect = {pos = {x = 0, y = 0, z = 0, heading = 0}, ent = 0, model = 0}
local objectScanner = {objects = {}, active = false}
local playerList = {}
local isMadCow = -1
local snowballs = {isGatheringSnow = false, hash = GetHashKey("WEAPON_SNOWBALL")}
local camdisablecontrols = {
  30,     -- A and D (Character Movement)
  31,     -- W and S (Character Movement)
  21,     -- LEFT SHIFT
  36,     -- LEFT CTRL
  22,     -- SPACE
  44,     -- Q
  38,     -- E
  71,     -- W (Vehicle Movement)
  72,     -- S (Vehicle Movement)
  59,     -- A and D (Vehicle Movement)
  60,     -- LEFT SHIFT and LEFT CTRL (Vehicle Movement)
  85,     -- Q (Radio Wheel)
  86,     -- E (Vehicle Horn)
  15,     -- Mouse wheel up
  14,     -- Mouse wheel down
  37,     -- Controller R1 (PS) / RT (XBOX)
  80,     -- Controller O (PS) / B (XBOX)
  228,    -- 
  229,    -- 
  172,    -- 
  173,    -- 
  37,     -- 
  44,     -- 
  178,    -- 
  244,    -- 
}
local spmblips = {}
local offsetf = vec3(0, 0, 0)
local offsetb = vec3(0, 0, 0)
local timecyclerSettings = {active = false, cur = 1, strength = 1.0}

function dump(o)
  if type(o) == 'table' then
    local s = "{"
    local notEmpty = false
    
    for k,v in pairs(o) do
      notEmpty = true
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. "["..k.."]=" .. dump(v) .. ", "
    end
    if (notEmpty) then
      s = s:sub(1, -3)
    end

    return s .. "}"
  else
    return tostring(o)
  end
end

function tableRemove(t, elementsToDel)
  local j, n = 1, #t;

  for i=1,n do
    local del = false
    for _,v in pairs(elementsToDel) do
      if (v == t[i]) then
        del = true
      end
    end
    if (not del) then
      if (i ~= j) then -- Move i's kept value to j's position, if it's not already there
        t[j] = t[i];
        t[i] = nil;
      end
      j = j + 1; -- Increment position of where we'll place the next kept value
    else
      t[i] = nil;
    end
  end

  return t;
end

function drawPmodeText(text)
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
  DrawText(0.475, 0.92)
end

function drawAimingEntity(text)
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
  DrawText(0.475, 0.92)
end

function drawText3Ds(x, y, z, text)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  
  SetTextScale(0.35, 0.35)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 215)
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(_x, _y)
  
  local factor = (string.len(text)) / 370
  
  DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

function drawAseTxt(x, y, width, height, scale, text, r, g, b, a)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.25, 0.25)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x - width / 2, y - height / 2 + 0.005)
end

function addTextEntries()
  AddTextEntry("police_vest_overlay_01", "Police Overlay Text")
end

function isPlayerK9(cb)
  if (cb) then
    cb(isk9)
  end
end

function markedItemExists(obj)
  local exists = false

  for _,v in pairs(markedItems) do
    if (v.entity == obj) then
      exists = true
      break
    end
  end

  return exists
end

function removeMarkedItem(obj)
  local delidx = 0
  
  for i,v in ipairs(markedItems) do
    if (v.entity == obj) then
      delidx = i
      break
    end
  end

  if (delidx > 0) then
    table_remove(markedItems, delidx)
  end
end

function addMarkedItem(obj)
  local item = {}

  item.entity = obj
  item.remain = 500
  item.timeout = function()
    Citizen.CreateThread(function()
      while (item.remain > 0) do
        Wait(10)
        
        local pos = GetEntityCoords(item.entity)
        item.remain = item.remain - 1

        DrawMarker(1, pos.x, pos.y, pos.z, 0, 0, 0, 0, 0, 0, 0.9, 0.9, 1.1, 255, 0, 0, 145, 1, 0, 0, 0, 0, 0, 0)

        if (item.remain <= 0) then
          removeMarkedItem(item.obj)
        end
      end
    end)
  end

  item.timeout()
  table_insert(markedItems, item)
end

function drawPosRotPropText()
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.25, 0.25)
  SetTextColour(120, 120, 120, 255)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextEntry("STRING")
  AddTextComponentString(string_format("%s, %s, %s, %s, %s, %s", propposrot.pos.x, propposrot.pos.y, propposrot.pos.z, propposrot.rot.x, propposrot.rot.y, propposrot.rot.z))
  DrawText(0.475, 0.975)
end

function getObjectDetected(cb)
  local _, ent = GetEntityPlayerIsFreeAimingAt(PlayerId(), Citizen.ReturnResultAnyway())

  if (ent) then
    local head = GetEntityHeading(ent)

    if (cb) then
      cb(ent, GetEntityModel(ent), head)
    end

    return ent, GetEntityModel(ent), head
  end
end

local debugcam = -1
function setupDebugCamera(enable)
  if (enable) then
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local head = GetEntityHeading(ped)
    
    if (debugcam == -1) then
      debugcam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z + 1.00001, 0, 0, 0, GetGameplayCamFov(), 0, 0)
    end

    SetCamActive(debugcam, true)
    RenderScriptCams(1, 0, 3000, 1, 0)

    local rot = GetCamRot(debugcam, 2)
    local vrot = {x = rot.x, y = rot.y, z = rot.z}
      
    vrot.z = head
    SetCamRot(debugcam, vrot.x, vrot.y, vrot.z, 2)
    --StartScreenEffect(lastcam.camfx, 0, true)
  else
    if (debugcam > -1) then
      if (IsCamActive(debugcam)) then
        RenderScriptCams(0, 0, 3000, 1, 0)
        --StopAllScreenEffects()
        debugcam = -1
      end
    end
  end
end

function setBlipOptions(blip, charname)
  SetBlipAsFriendly(blip, 1)
  SetBlipColour(blip, 44)
  SetBlipCategory(blip, 1)
  ShowHeadingIndicatorOnBlip(blip, true)
  BeginTextCommandSetBlipName("STRING")
  
  if (charname) then
    AddTextComponentSubstringPlayerName(charname)
  end
  
  EndTextCommandSetBlipName(blip)
end

local offsetRotX = 0.0
local offsetRotY = 0.0
local offsetRotZ = 0.0
local offsetCoords = {x = 0, y = 0, z = 0}
local dcspeed = 0.1
local dcprecision = 1.0

function processCameraPosition(x, y, z)
  local _x = x
  local _y = y
  local _z = z

  if (IsControlPressed(0, 32)) then -- W
    local mx = Sin(offsetRotZ)
    local my = Cos(offsetRotZ)
    local mz = Sin(offsetRotX)

    _x = _x - (0.1 * dcspeed * mx)
    _y = _y + (0.1 * dcspeed * my)
    _z = _z + (0.1 * dcspeed * mz)
  end

  if (IsControlPressed(0, 33)) then -- S
    local mx = Sin(offsetRotZ)
    local my = Cos(offsetRotZ)
    local mz = Sin(offsetRotX)

    _x = _x + (0.1 * dcspeed * mx)
    _y = _y - (0.1 * dcspeed * my)
    _z = _z - (0.1 * dcspeed * mz)
  end

  if (IsControlPressed(0, 34)) then -- A
    local mx = Sin(offsetRotZ + 90.0)
    local my = Cos(offsetRotZ + 90.0)
    local mz = Sin(offsetRotY)

    _x = _x - (0.1 * dcspeed * mx)
    _y = _y + (0.1 * dcspeed * my)
    _z = _z + (0.1 * dcspeed * mz)
  end

  if (IsControlPressed(0, 35)) then -- D
    local mx = Sin(offsetRotZ + 90.0)
    local my = Cos(offsetRotZ + 90.0)
    local mz = Sin(offsetRotY)

    _x = _x + (0.1 * dcspeed * mx)
    _y = _y - (0.1 * dcspeed * my)
    _z = _z - (0.1 * dcspeed * mz)
  end

  if (IsDisabledControlPressed(0, 38)) then -- E
    _z = _z + (0.1 * dcspeed)
  end

  if (IsDisabledControlPressed(0, 44)) then -- Q
    _z = _z - (0.1 * dcspeed)
  end

  offsetRotX = offsetRotX - (GetDisabledControlNormal(1, 2) * dcprecision * 8.0)
  offsetRotZ = offsetRotZ - (GetDisabledControlNormal(1, 1) * dcprecision * 8.0)

  if (IsDisabledControlPressed(1, 123)) then -- num 6 roll left
    offsetRotY = offsetRotY - dcprecision
  end

  if (IsDisabledControlPressed(1, 124)) then --  num 4 roll right
    offsetRotY = offsetRotY + dcprecision
  end

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

  return {x = _x, y = _y, z = _z}
end

RegisterNetEvent("Z6JOJ4A7NU4W0QMCO4KT")
AddEventHandler("Z6JOJ4A7NU4W0QMCO4KT", function(name, freeze)
  Citizen.CreateThread(function()
    local ped = PlayerPedId()
    local objpos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.2, -1.0)
    local pedh = GetEntityHeading(ped)
    local timeout = 0
    local timeoutmax = 3000

    --[[if (not IsModelInCdimage(name)) then
      TriggerEvent("chatMessage", "DEVTOOLS", {255, 0, 0}, "Model not found in Cdimage.")
      return
    end]]
    
    local meh = CreateObject(GetHashKey(name), objpos.x, objpos.y, objpos.z, true, false)

    while (not DoesEntityExist(meh) and timeout < timeoutmax) do
      print("Waiting for entity..")
      Wait(500)
      timeout = timeout + 500
    end
    
    if (DoesEntityExist(meh)) then
      PlaceObjectOnGroundProperly(meh)
      SetEntityCollision(meh, true, true)    
      SetEntityHeading(meh, pedh)
      
      if (freeze) then
        Wait(500)
        FreezeEntityPosition(meh, true)
      end
      
      local opos = GetEntityCoords(meh)
      local ohead = GetEntityHeading(meh)
      
      TriggerEvent("chatMessage", "DEVTOOLS", {255, 0, 0}, string_format("Entity: %s, Pos: x = %s, y = %s, z = %s, heading = %s", meh, opos.x, opos.y, opos.z, ohead))
    else
      TriggerEvent("chatMessage", "DEVTOOLS", {255, 0, 0}, "Could not create entity.")
    end
  end)
end)

RegisterNetEvent("YZLOFN79XZ19KCQMRISH")
AddEventHandler("YZLOFN79XZ19KCQMRISH", function(id)
  local ped = PlayerPedId()
  local objpos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, -1.0)
  local pedh = GetEntityHeading(ped)
  
  local meh = CreateObject(id, objpos.x, objpos.y, objpos.z, true, false)
  PlaceObjectOnGroundProperly(meh)
  SetEntityCollision(meh, true, true)
  
  SetEntityHeading(meh, pedh)
  
  local opos = GetEntityCoords(meh)
  local ohead = GetEntityHeading(meh)
  
  TriggerEvent("chatMessage", "DEVTOOLS", {255, 0, 0}, string_format("Pos: x = %s, y = %s, z = %s, heading = %s", opos.x, opos.y, opos.z, ohead))
  
  if (meh == nil) then
    Citizen.Trace("nil")
  end
end)

RegisterNetEvent("bms:devtools:voicechannel")
AddEventHandler("bms:devtools:voicechannel", function(channel)
  if (channel == 0) then
    --NetworkClearVoiceChannel()
    Citizen.InvokeNative(0xE036A705F989E049)
    TriggerEvent("chatMessage", "DEVTOOLS", {255, 0, 0}, "Voice channel set to default")
  else
    --NetworkSetVoiceChannel(channel)
    Citizen.Invoke(0xEF6212C2EFEF1A23, Citizen.PointerValueIntInitialized(channel))
    TriggerEvent("chatMessage", "DEVTOOLS", {255, 0, 0}, "Voice channel set to " .. tostring(channel))
  end
end)

function getVehicleInDirection(coordFrom, coordTo, ignore)
  local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, ignore, 0)
  local _, _, _, _, vehicle = GetRaycastResult(rayHandle)
  return vehicle
end

RegisterNetEvent("bms:devtools:unlockVehicle")
AddEventHandler("bms:devtools:unlockVehicle", function(channel)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local poffset = GetOffsetFromEntityInWorldCoords(ped, 0, 3.0, 0)
  local veh = getVehicleInDirection(pos, poffset, ped)
  
  if (veh and veh ~= 0 and DoesEntityExist(veh)) then
    SetEntityAsMissionEntity(veh, true)
    SetVehicleDoorsLocked(veh, 0)
    SetVehicleDoorsLockedForAllPlayers(veh, 0)
    exports.pnotify:SendNotification({text = "Vehicle Unlocked."})
  else
    local found = false

    for _,v in pairs(GetGamePool("CVehicle")) do
      local vpos = GetEntityCoords(v)
      local dist = #(pos - vpos)

      if (dist < 3.0) then
        SetEntityAsMissionEntity(veh, true)
        SetVehicleDoorsLocked(veh, 0)
        SetVehicleDoorsLockedForAllPlayers(veh, 0)
        exports.pnotify:SendNotification({text = "Vehicle Unlocked."})
        found = true
        break
      end
    end

    if (not found) then
      exports.pnotify:SendNotification({text = "No vehicle found."})
    end
  end
end)

RegisterNetEvent("bms:cSetCoord")
AddEventHandler("bms:cSetCoord", function(ctype, chnum, price)
  local ped = PlayerPedId()  
  local coords = GetEntityCoords(ped)  
  local lastStreet = GetStreetNameAtCoord(coords.x, coords.y, coords.z)  
  local lastStreetName = GetStreetNameFromHashKey(lastStreet)
  
  local ct = {}
  ct.x = coords.x
  ct.y = coords.y
  ct.z = coords.z
  
  lastStreetName = chnum .. " " .. lastStreetName
  
  TriggerServerEvent("bms:sSetCoord", ct, ctype, lastStreetName, price)
end)

RegisterNetEvent("bms:devtools:loadIpl")
AddEventHandler("bms:devtools:loadIpl", function(ipl)
  if (ipl) then
    RequestIpl(ipl)
    exports.pnotify:SendNotification({text = "IPL " .. ipl .. " has been loaded."})
  end
end)

function getPlayersInInstance()
  return #GetActivePlayers()
end

RegisterNetEvent("bms:devtools:getClientCount")
AddEventHandler("bms:devtools:getClientCount", function()
  TriggerServerEvent("bms:serverprint", string_format("ID: %s (%s), Local Count: %s", tostring(GetPlayerServerId(PlayerId())), GetPlayerName(PlayerId()), tostring(getPlayersInInstance())))
end)

function setSkin(skin)
  Citizen.CreateThread(function()
    local hash = GetHashKey(skin)
    
    RequestModel(hash)
    
    while not HasModelLoaded(hash) do
      Wait(5)
    end
    
    SetPlayerModel(PlayerId(), hash)
    SetPedDefaultComponentVariation(PlayerPedId())
    SetPedRandomComponentVariation(PlayerPedId(), true)
    SetModelAsNoLongerNeeded(hash)
  end)
end

RegisterNetEvent("bms:devtools:makemek9")
AddEventHandler("bms:devtools:makemek9", function(dogType)
  if (dogType == "off") then
    isk9 = false
    TriggerEvent("bms:devtools:k9changed", false)
    return
  end

  local dog = tonumber(dogType)
  if (dog >= 0) then
    if (dog == 0) then
      setSkin("a_c_rottweiler")
    elseif (dog == 1) then
      setSkin("a_c_shepherd")
    elseif (dog == 2) then
      setSkin("a_c_retriever")
    elseif (dog == 3) then
      setSkin("a_c_husky")
    elseif (dog == 4) then
      setSkin("a_c_pug")
    elseif (dog == 5) then
      setSkin("a_c_poodle")
    elseif (dog == 6) then
      setSkin("a_c_westy")
    end
  else
    setSkin("a_c_rottweiler")
  end
  
  isk9 = true
  TriggerEvent("bms:devtools:k9changed", true)
end)

RegisterNetEvent("bms:devtools:playK9Anim")
AddEventHandler("bms:devtools:playK9Anim", function(emote)
  local dict
  local anim
  local flag
  local emoteFound = false
  local ped = PlayerPedId()
  
  if (isk9) then
    if (emote) then
      for _,v in pairs(k9Anims) do
        if (emote == v.name) then
          dict = v.dict
          anim = v.anim
          flag = v.flag
          emoteFound = true
          break
        end
      end

      if (emoteFound) then
        RequestAnimDict(dict)
        while (not HasAnimDictLoaded(dict)) do
          Wait(5)
        end

        TaskPlayAnim(ped, dict, anim, 8.0, -8, -1, flag, 0, 0, 0, 0)
        RemoveAnimDict(dict)
      else
        local eNames = ""
        for _,v in pairs(k9Anims) do
          eNames = eNames .. v.name .. ", "
        end
        TriggerEvent("chatMessage", "SERVER", {0, 255, 0}, "Valid emotes: " .. eNames)
      end
    else
      local eNames = ""
      for _,v in pairs(k9Anims) do
        eNames = eNames .. ", " .. v.name
      end
      TriggerEvent("chatMessage", "SERVER", {0, 255, 0}, "Valid emotes: " .. eNames)
    end
  end
end)

--[[RegisterNetEvent("bms:devtools:sol")
AddEventHandler("bms:devtools:sol", function(oid, idx, opc)
  local ped = PlayerPedId()
  Citizen.Trace(string_format("setting %s, %s, %s", oid, idx, opc))
  SetPedHeadOverlay(ped, oid, idx, opc)
end)

RegisterNetEvent("bms:devtools:gsol")
AddEventHandler("bms:devtools:gsol", function(oid)
  TriggerEvent("chatMessage", "SERVER", {0, 255, 0}, string_format("Overlays for head: %s", GetNumHeadOverlayValues(oid)))
end)]]

--TriggerClientEvent("bms:devtools:setbeard", headid, hairid, opac, haircol1, haircol2)
RegisterNetEvent("bms:devtools:setbeard")
AddEventHandler("bms:devtools:setbeard", function(hid, hairid, opac, hcol1, hcol2) --/beard 44 5 38 33
  local ped = PlayerPedId()

  SetPedHeadBlendData(ped, hid, hid, 0, hid, hid, 0, 0, 0, 0, 0)
  SetPedHeadOverlay(ped, 1, hairid, opac or 1.0)
  SetPedHeadOverlayColor(ped, 1, 1, hcol1, hcol2)
  SetPedHairColor(ped, hcol1, hcol2)
end)

RegisterNetEvent("bms:devtools:nuifix")
AddEventHandler("bms:devtools:nuifix", function()
  Citizen.Trace("repairing nui")
  SetNuiFocus(false, false)
end)

RegisterNetEvent("bms:devtools:setskin")
AddEventHandler("bms:devtools:setskin", function(skin)
  local model = GetHashKey(skin)

  if IsModelInCdimage(model) and IsModelValid(model) then
    RequestModel(model)

    while not HasModelLoaded(model) do
      Citizen.Wait(0)
    end

    SetPlayerModel(PlayerId(), model)
    SetPedRandomComponentVariation(PlayerPedId(), true)

    SetModelAsNoLongerNeeded(model)
  else
    exports.pnotify:SendNotification({text = "Skin was not found."})
  end
end)

RegisterNetEvent("mtbItufMfmiPVC0")
AddEventHandler("mtbItufMfmiPVC0", function(id, currPos, targPos)
  if (not spec.active) then
    local ped = PlayerPedId()
    
    SetEntityInvincible(ped, true)
    SetPedDiesInWater(ped, false)
    SetEntityCoords(ped, targPos.x, targPos.y, -180.0)
    local timeout = 0

    while (timeout < 10) do -- Make sure you're put into their instance of players
      SetEntityCoords(ped, targPos.x, targPos.y, -180.0)
      Wait(100)
      timeout = timeout + 1
    end

    local pl = GetPlayerFromServerId(id)
    local rped = GetPlayerPed(pl)

    spec.ped = rped
    spec.pl = pl
    spec.oldPos = currPos
    NetworkSetInSpectatorMode(true, rped)
    NetworkOverrideReceiveRestrictions(pl, true)
    spec.active = true
    exports.csrp_gamemode:toggleSpectate(true)
  else
    spec.active = false

    local ped = PlayerPedId()
    SetEntityInvincible(ped, false)
    SetPedDiesInWater(ped, true)
    exports.teleporter:teleportToPoint(ped, spec.oldPos)
    exports.csrp_gamemode:toggleSpectate(false)

    if (spec.ped ~= 0) then
      NetworkSetInSpectatorMode(false, spec.ped)
      NetworkOverrideReceiveRestrictions(spec.pl, false)
      spec.ped = 0
      spec.oldPos = nil
    end
  end
end)

--[[ placement tools ]]

RegisterNetEvent("bms:devtools:placementtool")
AddEventHandler("bms:devtools:placementtool", function()
  placemode = not placemode
end)

RegisterNetEvent("bms:devtools:placementToolBox")
AddEventHandler("bms:devtools:placementToolBox", function()
  placemodebox = not placemodebox
end)

-- end placement

RegisterNetEvent("bms:devtools:getvehiclehash")
AddEventHandler("bms:devtools:getvehiclehash", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped)
  local hash = GetEntityModel(veh)
  local name = GetDisplayNameFromVehicleModel(hash)

  TriggerEvent("chatMessage", "DEVTOOL", {255, 0, 0}, string_format("Vehicle Hash: %s, Vehicle Model: %s", hash, name))
end)

RegisterNetEvent("bms:devtools:anarchytest")
AddEventHandler("bms:devtools:anarchytest", function(id)
  if (id) then
    local ped = GetPlayerPed(GetPlayerFromServerId(id))
    local veh = GetVehiclePedIsIn(ped, false)
    local nid = NetworkGetNetworkIdFromEntity(veh)
    
    if (veh) then
      TriggerEvent("chatMessage", "SERVER", {255, 0, 0}, string_format("Veh Network ID: %s", nid))
    end
  end
end)

function fnAddTextEntry(key, value)
	Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), key, value)
end

Citizen.CreateThread(function()
  fnAddTextEntry("police_vest_overlay_01", "Police Overlay Text")
end)

RegisterNetEvent("bms:devtools:addoverlay")
AddEventHandler("bms:devtools:addoverlay", function()
  local ped = PlayerPedId()
  --addTextEntries()
  SetPedDecoration(ped, GetHashKey("new_overlays"), GetHashKey("police_vest_overlay_01_M"))
  --SetPedDecoration(ped, GetHashKey("mpBiker_overlays"), GetHashKey("MP_Biker_Rank_002_M"))
end)

RegisterNetEvent("bms:devtools:showobjectsinrange")
AddEventHandler("bms:devtools:showobjectsinrange", function(range)
  if (range) then
    local ds = range + 0.000001
    local objects = {}

    for _,obj in pairs(GetGamePool("CObject")) do
      local opos = GetEntityCoords(obj)
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local dist = Vdist(pos.x, pos.y, pos.z, opos.x, opos.y, opos.z)

      if (dist < ds) then
        table_insert(objects, {name = GetEntityModel(obj), heading = GetEntityHeading(obj)})
        
        if (not markedItemExists(obj)) then
          addMarkedItem(obj)
        end
      end
    end

    if (#objects > 0) then
      for _,v in pairs(objects) do
        TriggerEvent("chatMessage", "", {255, 255, 255}, string_format("%s, H: %s", v.name, v.heading))
      end
    else
      TriggerEvent("chatMessage", "", {255, 255, 255}, "No objects found nearby.")
    end
  else
    print("Range not defined.")
  end
end)

RegisterNetEvent("bms:devtools:showentitytargetted")
AddEventHandler("bms:devtools:showentitytargetted", function()
  enttarget = not enttarget

  if (enttarget) then
    TriggerEvent("chatMessage", "SERVER", {255, 255, 255}, "Entity identifier activated.")
  else
    TriggerEvent("chatMessage", "SERVER", {255, 255, 255}, "Entity identifier deactivated.")
  end
end)

RegisterNetEvent("bms:devtools:objectdetect")
AddEventHandler("bms:devtools:objectdetect", function()
  objectdetect = not objectdetect
end)

RegisterNetEvent("bms:devtools:objectScanner")
AddEventHandler("bms:devtools:objectScanner", function(range)
  objectScanner.active = not objectScanner.active

  if (objectScanner.active) then
    objectScanner.range = range or 20.0
    objectScanner.selectedEntityIndex = 1
    SendNUIMessage({toggleGenericInfoPopup = true, toggle = true, text = "Press <span class='genericInfoPopupHighlight'>H</span> for Control Help"})
  else
    SendNUIMessage({toggleGenericInfoPopup = true, toggle = false})
  end

  if (not objectScanner.active and objectScanner.objects) then
    for entity, entData in pairs(objectScanner.objects) do
      SetEntityDrawOutline(entity, false)
    end

    objectScanner.objects = {}
  end
end)

RegisterNetEvent("bms:devtools:markertest")
AddEventHandler("bms:devtools:markertest", function()
  markertest = not markertest
end)

RegisterNetEvent("bms:devtools:deltool")
AddEventHandler("bms:devtools:deltool", function()
  deltool = not deltool

  local ped = PlayerPedId()
  local hashStun = GetHashKey("WEAPON_STUNGUN")
  local hashExtin = GetHashKey("WEAPON_FIREEXTINGUISHER")

  if (deltool) then
    TriggerEvent("chatMessage", "ADMIN", {255, 0, 0}, "Delete tool has been activated. Taser and Extinguisher issued.")
    GiveWeaponToPed(ped, hashStun, 500, true)
    GiveWeaponToPed(ped, hashExtin, 2000, true)
  else
    TriggerEvent("chatMessage", "ADMIN", {255, 0, 0}, "Delete tool has been deactivated.")
    
    -- check if leo on duty
    exports.lawenforcement:isPlayerOnDutyCop(function(onduty)
      if (not onduty) then
        RemoveWeaponFromPed(ped, hashStun)
        RemoveWeaponFromPed(ped, hashExtin)
      end
    end)
  end
end)

RegisterNetEvent("pxuucjrHSlaT3qD")
AddEventHandler("pxuucjrHSlaT3qD", function()
  if (not spmmode) then
    spmmode = true
    TriggerServerEvent("bms:comms:qI63Aot8rnE8EbDd")
  else
    spmmode = false
    TriggerServerEvent("bms:comms:qI63Aot8rnE8EbDd")
    TriggerEvent("bms:comms:blipmanager:updateSpmBlips", {clear = true})
  end
end)

RegisterNetEvent("bms:comms:blipmanager:updateSpmBlips")
AddEventHandler("bms:comms:blipmanager:updateSpmBlips", function(data)
  --print(string_format("client blips: %s", exports.devtools:dump(data)))
  local sblips = data.blips
  local blipremovals = data.blipremovals
  local clear = data.clear
  local plnid = PedToNet(PlayerPedId())
  
  if (clear) then
    for _, v in pairs(spmblips) do
      if (DoesBlipExist(v.blip)) then
        RemoveBlip(v.blip)
      end
    end

    spmblips = {}
    return
  end
  
  if (not sblips) then return end

  --print(string_format("sblips: %s", exports.devtools:dump(sblips)))

  if (blipremovals) then
    for k,_ in pairs(blipremovals) do
      if (spmblips[k] and spmblips[k].blip and DoesBlipExist(spmblips[k].blip)) then
        RemoveBlip(spmblips[k].blip)
        spmblips[k] = nil
      end
    end
  end

  for pl,v in pairs(sblips) do
    if (v.pedNetId ~= plnid) then
      if (not spmblips[pl]) then
        local myInstance = (NetworkDoesEntityExistWithNetworkId(v.pedNetId) and NetworkGetEntityFromNetworkId(v.pedNetId)) or nil
        local blip
        local ent = false
        
        if (myInstance) then
          blip = AddBlipForEntity(NetworkGetEntityFromNetworkId(v.pedNetId))
          ent = true
        else
          blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
        end

        setBlipOptions(blip, v.charname)
        spmblips[pl] = {blip = blip, ent = ent}
      else -- update it
        local myInstance = (NetworkDoesEntityExistWithNetworkId(v.pedNetId) and NetworkGetEntityFromNetworkId(v.pedNetId)) or nil

        --print(string_format("%s >> myInstance: %s", v.pedNetId, myInstance ~= nil))

        if (myInstance) then
          if (not spmblips[pl].ent) then
            if (DoesBlipExist(spmblips[pl].blip)) then
              RemoveBlip(spmblips[pl].blip)
            end
            
            if (NetworkDoesEntityExistWithNetworkId(v.pedNetId)) then
              spmblips[pl] = {blip = AddBlipForEntity(NetworkGetEntityFromNetworkId(v.pedNetId)), ent = true}
              setBlipOptions(spmblips[pl].blip, v.charname)
            --else
              --print(string_format("Entity does not exist with Network ID %s", v.pedNetId))
            end
          end
        else
          if (spmblips[pl].ent) then
            if (DoesBlipExist(spmblips[pl].blip)) then
              RemoveBlip(spmblips[pl].blip)
            end

            --print(string_format("updating blip to coord: %s", v.pedNetId))
            spmblips[pl] = {blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z), ent = false}
            setBlipOptions(spmblips[pl].blip, v.charname)
          end

          SetBlipCoords(spmblips[pl].blip, v.pos.x, v.pos.y, v.pos.z)
          SetBlipRotation(spmblips[pl].blip, v.heading)
        end
      end
    end
  end
end)

RegisterNetEvent("bhsM3vtwZoWsnuo") -- ase
AddEventHandler("bhsM3vtwZoWsnuo", function(range, plist)
  if (range == 0) then
    aserange = 40.0
  else
    aserange = range + 0.00001
  end

  playerList = plist
  asemode = not asemode
end)

RegisterNetEvent("bms:devtools:shweps")
AddEventHandler("bms:devtools:shweps", function(retsrc)
  local ped = PlayerPedId()
  local wepstr = ""

  for _,v in pairs(weaponhashes) do
    if (HasPedGotWeapon(ped, v.hash, false)) then
      wepstr = wepstr .. string_format("%s, ", v.name)
    end
  end

  TriggerServerEvent("bms:devtools:sendweapons", wepstr, retsrc)
end)

RegisterNetEvent("bms:eP3HwUOcDU")
AddEventHandler("bms:eP3HwUOcDU", function(type, arg)
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, true)

  if (type == 1) then
    if (veh) then
      if (arg == -1) then
        SetVehicleTyreBurst(veh, 0, 1, 1000.0)
        SetVehicleTyreBurst(veh, 1, 1, 1000.0)
        SetVehicleTyreBurst(veh, 4, 1, 1000.0)
        SetVehicleTyreBurst(veh, 5, 1, 1000.0)
      else
        SetVehicleTyreBurst(veh, arg, 1, 1000.0)
      end
    end
  elseif (type == 2) then -- detach trunk
    SetVehicleDoorBroken(veh, 5, false)
    SetVehicleDoorsLocked(veh, false)
  end
end)

RegisterNetEvent("bms:devtools:registerVehicle")
AddEventHandler("bms:devtools:registerVehicle", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  if (veh ~= 0) then
    exports.vehicles:registerPulledVehicle(veh, false)
    TriggerEvent("chatMessage", "CDoT", {0, 255, 0}, string_format("The vehicle with plate ^3%s^0 has been registered to you by the state.", string.upper(GetVehicleNumberPlateText(veh))))
  end
end)

RegisterNetEvent("bms:devtools:overlaytest")
AddEventHandler("bms:devtools:overlaytest", function(stop)
  if (stop) then
    StopAllScreenEffects()
    curoverlay = 0
    return
  end

  if (curoverlay > 0) then
    StopAllScreenEffects()
  end

  curoverlay = curoverlay + 1

  if (curoverlay > #overlays) then
    curoverlay = 1
  end

  TriggerEvent("chatMessage", "SERVER", {255, 0, 0}, string_format("Playing overlay %s", curoverlay))
  StartScreenEffect(overlays[curoverlay], 0, true)
end)

RegisterNetEvent("bms:devtools:timecycler")
AddEventHandler("bms:devtools:timecycler", function()
  timecyclerSettings.active = not timecyclerSettings.active
  timecyclerSettings.cur = 1
  timecyclerSettings.strength = 1.0

  if (not timecyclerSettings.active) then
    ClearTimecycleModifier()
  end
end)

RegisterNetEvent("bms:devtools:timecyclerSave")
AddEventHandler("bms:devtools:timecyclerSave", function(desc)
  if (timecyclerSettings.active) then
    timecyclerSettings.desc = desc
    TriggerServerEvent("bms:devtools:timecyclerSave", timecyclerSettings)
  end
end)

local drawmmarker = false
local markerpos

local function RgbToHex(rgb)
	local hexadecimal = ""

	for key, value in pairs(rgb) do
		local hex = ""

		while(value > 0)do
			local index = math_fmod(value, 16) + 1
			value = math_floor(value / 16)
			hex = string.sub("0123456789ABCDEF", index, index) .. hex			
		end

		if(string.len(hex) == 0)then
			hex = "00"

		elseif(string.len(hex) == 1)then
			hex = "0" .. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	return hexadecimal
end

function DrawMissionMarker(types, title, subTitle, posX, posY, posZ, colorId)
	if type(colorId) == "number" then
		if 0 <= colorId and colorId <= 255 then
			colorR, colorG, colorB, colorA = GetHudColour(colorId)
		else
			colorR, colorG, colorB, colorA = GetHudColour(9)
		end
	elseif type(colorId) == "table" then
		if 0 <= colorId[1] and colorId[1] <= 255
		and 0 <= colorId[2] and colorId[2] <= 255
		and 0 <= colorId[3] and colorId[3] <= 255 then
			colorR, colorG, colorB, colorA = colorId[1], colorId[2], colorId[3], 255
		else
			colorR, colorG, colorB, colorA = GetHudColour(9)
		end
	elseif colorId == nil then
		colorR, colorG, colorB, colorA = GetHudColour(9)
	end

	local playerPos = GetEntityCoords(PlayerPedId())
	local markerPos = vector3(posX, posY, posZ)
	if Vdist(playerPos, markerPos) < 30.0 then
		if types == 1 then
			scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(0)
			end
			PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
			PushScaleformMovieFunctionParameterString(("<font color=\"#%s\">%s"):format(RgbToHex({colorR, colorG, colorB}), title))
			PushScaleformMovieFunctionParameterString(subTitle)
			PopScaleformMovieFunctionVoid()
			scaleX = 7.25
			scaleY = 4.25
			scaleZ = 0.00
			offsetZ = 0.5
		else
			scaleform = RequestScaleformMovie("MP_MISSION_NAME_FREEMODE")
			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(0)
			end
			PushScaleformMovieFunction(scaleform, "SET_MISSION_INFO")
			PushScaleformMovieFunctionParameterString(subTitle)
			PushScaleformMovieFunctionParameterString(("<font color=\"#%s\">%s"):format(RgbToHex({colorR, colorG, colorB}), title))
			PushScaleformMovieFunctionParameterString("playerInfo")
			PushScaleformMovieFunctionParameterString("")
			--[[PushScaleformMovieFunctionParameterInt(50)
			PushScaleformMovieFunctionParameterBool(false)
			PushScaleformMovieFunctionParameterString("1")
			PushScaleformMovieFunctionParameterInt(0)
			PushScaleformMovieFunctionParameterInt(0)
			PushScaleformMovieFunctionParameterString("00:06:23.59")]]
			PopScaleformMovieFunctionVoid()
			scaleX = 3.25
			scaleY = 3.00
			scaleZ = 0.00
			offsetZ = -0.4
		end
		DrawScaleformMovie_3dNonAdditive(scaleform, posX, posY, posZ + offsetZ, 0.0, 0.0, 360 - GetGameplayCamRot(false).z, 1.0, 1.0, 1.0, scaleX, scaleY, scaleZ, true)
		DrawMarker(1, posX, posY, posZ - 1.25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 7.5, 7.5, 2.0, colorR, colorG, colorB, 100, false, false, 2, true, false, false, false)
		DrawLightWithRange(posX, posY, posZ, colorR, colorG, colorB, 5.0, 1.0)
	end
end

RegisterNetEvent("bms:devtools:testmmarker")
AddEventHandler("bms:devtools:testmmarker", function()
  drawmmarker = not drawmmarker
  markerpos = {x = -1129.365, y = -840.857, z = 19.316}
end)

--[[RegisterNetEvent("bms:devtools:setPlayerMaxHealth")
AddEventHandler("bms:devtools:setPlayerMaxHealth", function(health)
  local ped = PlayerPedId()
  
  SetEntityMaxHealth(ped, health)
  Wait(50)
  SetEntityHealth(ped, health - 1)
end)]]

RegisterNetEvent("bms:devtools:vehiclecleanup")
AddEventHandler("bms:devtools:vehiclecleanup", function(notify)
  local cli = 0

  for _,v in pairs(GetGamePool("CVehicle")) do
    if (DoesEntityExist(v)) then
      local owned = IsVehiclePreviouslyOwnedByPlayer(v)

      if (not owned) then
        cli = cli + 1
        exports.vehicles:deleteCar(v)
      end
    end
  end

  if (notify) then
    TriggerEvent("chatMessage", "ADMIN", {255, 0, 0}, string_format("Vehicle cleanup finished.  %s vehicles deleted.", cli))
  end
end)

RegisterNetEvent("bms:devtools:setped")
AddEventHandler("bms:devtools:setped", function(skin)
  local hash = GetHashKey(skin)
  local ped = PlayerPedId()
  local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    
  Citizen.CreateThread(function()
    RequestModel(hash)

    while (not HasModelLoaded(hash)) do
      Wait(500)
    end

    local cped = CreatePed(4, hash, offset.x, offset.y, offset.z, 0, 1, 0)
    
    SetPedRandomComponentVariation(cped)
    TriggerEvent("chatMessage", "DEVTOOLS", {255, 0, 0}, "Skin set on created ped.")
    SetModelAsNoLongerNeeded(hash)
  end)
end)

function AttachEntityToPed(prop, boneidx, x, y, z, rx, ry, rz)
  local ped = PlayerPedId()
  boneidx = GetPedBoneIndex(ped, boneidx)
  local obj = CreateObject(prop, 1729.73, 6403.90, 34.56, true, 0, 0)
      
  AttachEntityToEntity(obj, ped, boneidx, x, y, z, rx, ry, rz, false, false, false, false, 2, true)

  return obj
end

function reloadProp()
  TriggerEvent("bms:devtools:addpropinhand", lastprop.prop, lastprop.animid, propposrot.pos.x, propposrot.pos.y, propposrot.pos.z, propposrot.rot.x, propposrot.rot.y, propposrot.rot.z, true)
end

RegisterNetEvent("bms:devtools:addpropinhand")
AddEventHandler("bms:devtools:addpropinhand", function(prop, animid, offx, offy, offz, xrot, yrot, zrot, hidedebug, boneid)
  --/addpropinhand prop_pizza_box_01 1 0 0 0 274.75 74.75 84.75
  hidepropdebug = hidedebug or false
  
  local ped = PlayerPedId()
  animid = tonumber(animid)
  
  if (animid > 100) then
    animid = animid - 100
  end

  if (prop or preset) then
    if (loadedprop and not mod) then
      DeleteEntity(loadedprop)
      loadedprop = nil
      ClearPedTasks(ped)
    else
      if (mod) then
        DeleteEntity(loadedprop)
        loadedprop = nil
      end
      
      lastprop = {prop = prop, animid = animid}
      local ped = PlayerPedId()
      local mhash = prop
  
      if (type(prop) == "string") then
        mhash = GetHashKey(prop)
      end
      
      RequestModel(mhash)
  
      while not HasModelLoaded(mhash) do
        Wait(100)
      end
      
      --print(string_format("rot: %s, %s, %s", xrot, yrot, zrot))
      
      if (preset) then
        loadedprop = AttachEntityToPed(mhash, boneid or 60309, presetprops[preset].pos.x, presetprops[preset].pos.y, presetprops[preset].pos.z, presetprops[preset].rot.x, presetprops[preset].rot.y, presetprops[preset].rot.z)
      else
        loadedprop = AttachEntityToPed(mhash, boneid or 60309, tonumber(offx), tonumber(offy), tonumber(offz), tonumber(xrot), tonumber(yrot), tonumber(zrot))
      end
    
      if (animid and animid > 0) then
        Citizen.CreateThread(function()
          RequestAnimDict(propanims[animid].dict)
            
          while (not HasAnimDictLoaded(propanims[animid].dict)) do
            Citizen.Wait(10)
          end

          --print(string_format("%s, %s, %s", propanims[animid].dict, propanims[animid].anim, propanims[animid].flag))
          
          TaskPlayAnim(ped, propanims[animid].dict, propanims[animid].anim, 4.0, -8, 0.01, propanims[animid].flag, 0, 0, 0, 0)
          RemoveAnimDict(propanims[animid].dict)
        end)
      end

      SetModelAsNoLongerNeeded(mhash)
    end
  end
end)

RegisterNetEvent("bms:devtools:getposn")
AddEventHandler("bms:devtools:getposn", function(desc)
  if (desc) then
    if (placemode) then
      local ped = PlayerPedId()
      local ppos = GetEntityCoords(ped)
      local height = GetEntityHeightAboveGround(ped)
      local zcoord = (ppos.z - height)
      
      TriggerServerEvent("bms:devtools:getposn2", {pos = {x = ppos.x, y = ppos.y, z = zcoord}, radius = pradius, desc = desc})
    elseif (placemodebox) then
      TriggerServerEvent("bms:devtools:getposn4", {pos1 = offsetf, pos2 = offsetb, desc = desc})
    elseif (objectdetect) then
      if (lastodetect.ent ~= 0) then
        TriggerServerEvent("bms:devtools:getposn3", {pos = {x = lastodetect.pos.x, y = lastodetect.pos.y, z = lastodetect.pos.z, heading = lastodetect.heading}, entity = lastodetect.ent, model = lastodetect.model, desc = desc})
      end
    else
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local tpos = {x = pos.x, y = pos.y, z = pos.z}

      TriggerServerEvent("bms:devtools:getposn", {pos = tpos, desc = desc})
    end
  end
end)

RegisterNetEvent("bms:devtools:getposnc")
AddEventHandler("bms:devtools:getposnc", function(desc)
  if (desc) then
    local cpos = GetCamCoord(debugcam)
    local crot = GetCamRot(debugcam, 2)

    TriggerServerEvent("bms:devtools:getposnc", {pos = {x = cpos.x, y = cpos.y, z = cpos.z}, rot = {x = crot.x, y = crot.y, z = crot.z}, desc = desc})
  end
end)

RegisterNetEvent("bms:devtools:getPosShort")
AddEventHandler("bms:devtools:getPosShort", function(desc)
  if (desc) then
    if (objectdetect and lastodetect.ent ~= 0) then
      TriggerServerEvent("bms:devtools:getPosShort", {pos = {x = lastodetect.pos.x, y = lastodetect.pos.y, z = lastodetect.pos.z, heading = lastodetect.heading}, entity = lastodetect.ent, model = lastodetect.model, desc = desc})
    else
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local heading = GetEntityHeading(ped)
      local tpos = {x = pos.x, y = pos.y, z = pos.z, heading = heading}

      TriggerServerEvent("bms:devtools:getPosShort", {pos = tpos, desc = desc})
    end
  end
end)

RegisterNetEvent("bms:devtools:getposnv")
AddEventHandler("bms:devtools:getposnv", function(desc)
  if (desc) then
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    
    if (veh ~= 0) then
      local vpos = GetEntityCoords(veh)
      local heading = GetEntityHeading(veh)
      local tpos = {x = vpos.x, y = vpos.y, z = vpos.z}

      TriggerServerEvent("bms:devtools:getposnv", {pos = tpos, desc = desc, heading = heading})
    end
  end
end)

RegisterNetEvent("bms:devtools:getPosVehShort")
AddEventHandler("bms:devtools:getPosVehShort", function(desc)
  if (desc) then
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    
    if (veh ~= 0) then
      local vpos = GetEntityCoords(veh)
      local heading = GetEntityHeading(veh)
      local tpos = {x = vpos.x, y = vpos.y, z = vpos.z}

      if (desc == "hgarage") then
        desc = exports.playerhousing:getNearestHouse()
      end

      TriggerServerEvent("bms:devtools:getPosVehShort", {pos = tpos, desc = desc, heading = heading})
    end
  end
end)

RegisterNetEvent("bms:devtools:showtrunk")
AddEventHandler("bms:devtools:showtrunk", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, true)

  if (veh) then
    TriggerServerEvent("bms:devtools:showtrunk", {plate = string.lower(GetVehicleNumberPlateText(veh))})
  else
    exports.pnotify:SendNotification({text = "No vehicle trunk found."})
  end
end)

-- testing vehicle cleanup for modders
--[[RegisterNetEvent("bms:devtools:owntest")
AddEventHandler("bms:devtools:owntest", function()
  for _,veh in pairs(GetGamePool("CVehicle")) do
    local vpos = GetEntityCoords(veh)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local dist = Vdist(pos.x, pos.y, pos.z, vpos.x, vpos.y, vpos.z)

    if (dist < 4.0) then
      exports.pnotify:SendNotification({text = string_format("Vehicle %s Owned: %s", string.upper(GetVehicleNumberPlateText(veh)), IsVehiclePreviouslyOwnedByPlayer(veh))})
    end
  end
end)]]

RegisterNetEvent("bms:devtools:sendDebug")
AddEventHandler("bms:devtools:sendDebug", function(msg)
  Citizen.Trace(string_format("[Time:%s] %s", GetGameTimer(), msg))
end)

RegisterNetEvent("bms:devtools:hideHud")
AddEventHandler("bms:devtools:hideHud", function()
  local isLeo = false
  local isEms = false
  exports.lawenforcement:isPlayerOnDutyCop(function(val)
    isLeo = val
  end)
  exports.ems:isPlayerOnDutyEms(function(val)
    isEms = val
  end)
  exports.hud:toggleVitals(hudToggle)
  TriggerEvent("bms:csrp_gamemode:hideVoiceHud", not hudToggle)
  TriggerEvent("bms:ems:toggleInjured", hudToggle)
  TriggerEvent("bms:hud:hideCarHud", not hudToggle)
  TriggerEvent("bms:fuel:hideHud", not hudToggle)
  if (isLeo) then
    TriggerEvent("bms:comms:leoToggleDispatchHud", hudToggle)
  end
  if (isEms) then
    TriggerEvent("bms:comms:emsToggleDispatchHud", hudToggle)
  end
  if (hudToggle) then
    TriggerEvent("bms:setCharMoneyDisplay", 255)
    TriggerEvent("bms:setCharDirtyMoneyDisplay", 255)
  else
    TriggerEvent("bms:setCharMoneyDisplay", 0)
    TriggerEvent("bms:setCharDirtyMoneyDisplay", 0)
  end
  DisplayRadar(hudToggle)
  hudToggle = not hudToggle
end)

RegisterNetEvent("bms:devtools:scenario")
AddEventHandler("bms:devtools:scenario", function(id)
  local scen = scenarios[id]

  print("playing scenario " .. scen)

  if (scen) then
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    TaskStartScenarioAtPosition(ped, scen, pos.x, pos.y, pos.z, heading, -1, false, true)
  end
end)

RegisterNetEvent("bms:devtools:madCowDisease") -- :D
AddEventHandler("bms:devtools:madCowDisease", function(diseaseType)
  local type = tonumber(diseaseType)

  if (type == -1) then -- stop the disease
    isMadCow = -1

  elseif (type == 0) then
    local cowHash = GetHashKey("a_c_cow")
    local spawnedCow = nil
    isMadCow = 0
    RequestModel(cowHash)
    while (not HasModelLoaded(cowHash)) do
      Wait(5)
    end

    Citizen.CreateThread(function()
      while isMadCow == 0 do
        Wait(10)
        local ped = PlayerPedId()

        if (spawnedCow == nil) then
          if (IsPedInAnyVehicle(ped, false)) then
            local veh = GetVehiclePedIsIn(ped, false)
            local seat
            
            for i=-1,2 do
              if (IsVehicleSeatFree(veh, i)) then
                seat = i
                break
              end
            end

            spawnedCow = CreatePedInsideVehicle(veh, 28, cowHash, seat, false, true)
            SetModelAsNoLongerNeeded(cowHash)
          end
        else
          if (not IsPedInAnyVehicle(spawnedCow, false) or not IsPedInAnyVehicle(ped, false)) then
            DeletePed(spawnedCow)
            spawnedCow = nil
          end
        end
      end
    end)

  elseif (type == 1) then
    local ped = PlayerPedId()
    local cows = {}
    local cowHash = GetHashKey("a_c_cow")
    isMadCow = 1
    RequestModel(cowHash)
    while (not HasModelLoaded(cowHash)) do
      Wait(5)
    end
    

    Citizen.CreateThread(function()
      while isMadCow == 1 do
        Wait(60000) -- 60000
        math_randomseed(GetGameTimer())

        local pos = GetEntityCoords(ped)
        local numCows = math_random(1, 5)

        for i=0,numCows do
          local xCowPosOffset = math_random()*20.0 - 10.0 -- random number between (-10 and 10)
          local yCowPosOffset = math_random()*20.0 - 10.0
          local cow = CreatePed(28, cowHash, pos.x + xCowPosOffset, pos.y + yCowPosOffset, pos.z, 0, false, true)
          SetPedRandomComponentVariation(cow, true)
          table_insert(cows, cow)
        end
        
        Wait(2500)

        for _,v in pairs(cows) do
          DeletePed(v)
        end
        cows = {}
        SetModelAsNoLongerNeeded(cowHash)
      end
    end)
  end
end)

RegisterNetEvent("bms:devtools:xmas")
AddEventHandler("bms:devtools:xmas", function()
  Citizen.CreateThread(function()
    while true do
      Wait(1)

      if (GetSelectedPedWeapon(ped) == snowballs.hash) then
        SetPlayerWeaponDamageModifier(PlayerId(), 0.0)
      else
        SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
      end
    end
  end)

  RegisterNetEvent("bms:devtools:gatherSnow")
  AddEventHandler("bms:devtools:gatherSnow", function()
    Citizen.CreateThread(function()
      local ped = PlayerPedId()
      
      if (not IsPedInAnyVehicle(ped, true) and not snowballs.isGatheringSnow) then
        snowballs.isGatheringSnow = true

        RequestAnimDict("anim@mp_snowball")

        while (not HasAnimDictLoaded("anim@mp_snowball")) do
          Wait(10)
        end

        TaskPlayAnim(ped, "anim@mp_snowball", "pickup_snowball", 8.0, 8.0, 8.0, 0, 1, 0, 0, 0)
        RemoveAnimDict("anim@mp_snowball")
        Wait(1950)
        GiveWeaponToPed(ped, snowballs.hash, 2, false, true)
        snowballs.isGatheringSnow = false
      else
        exports.pnotify:SendNotification({text = "You cannot gather snow right now, silly reindeer!"})
      end
    end)
  end)
end)

RegisterNetEvent("bms:devtools:deleteVeh")
AddEventHandler("bms:devtools:deleteVeh", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  exports.vehicles:deleteCar(veh)
end)

RegisterNetEvent("bms:devtools:printHash")
AddEventHandler("bms:devtools:printHash", function(hashStr)
  TriggerEvent("chatMessage", "DEVTOOLS", {68, 137, 235}, string_format("String: %s, Hash: %s", hashStr, GetHashKey(hashStr)))
end)

RegisterNetEvent("bms:devtools:cameradebugger")
AddEventHandler("bms:devtools:cameradebugger", function()
  camsetupmode = not camsetupmode

  if (camsetupmode) then
    if (debugcam == -1) then
      setupDebugCamera(true)
    end
  else
    ClearFocus()
    setupDebugCamera(false)
  end
end)

RegisterNetEvent("bms:devtools:areaDrawDebug")
AddEventHandler("bms:devtools:areaDrawDebug", function(pos1, pos2)
  Citizen.CreateThread(function()
    while true do
      Wait(1)

      DrawLine(pos1.x, pos1.y, (pos2.z + pos1.z) / 2, pos1.x, pos2.y, (pos2.z + pos1.z) / 2, 0, 0, 255, 255)
      DrawLine(pos1.x, pos2.y, (pos2.z + pos1.z) / 2, pos2.x, pos2.y, (pos2.z + pos1.z) / 2, 0, 0, 255, 255)
      DrawLine(pos2.x, pos1.y, (pos2.z + pos1.z) / 2, pos2.x, pos2.y, (pos2.z + pos1.z) / 2, 0, 0, 255, 255)
      DrawLine(pos1.x, pos1.y, (pos2.z + pos1.z) / 2, pos2.x, pos1.y, (pos2.z + pos1.z) / 2, 0, 0, 255, 255)
      DrawLine(pos1.x, pos1.y, (pos2.z + pos1.z) / 2, pos2.x, pos2.y, (pos2.z + pos1.z) / 2, 0, 255, 0, 255)
    end
  end)
end)

RegisterNetEvent("bms:devtools:setpedmaxspeed")
AddEventHandler("bms:devtools:setpedmaxspeed", function(speed)
  local ped = PlayerPedId()
  TriggerEvent("chatMessage", "DEVTOOLS", {68, 137, 235}, string_format("Setting entity max speed to %s", speed))
  SetEntityMaxSpeed(PlayerPedId(), speed)
end)

RegisterNetEvent("wJ7GXixtRTuehFewmXJC")
AddEventHandler("wJ7GXixtRTuehFewmXJC", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local weapon = GetCurrentPedWeaponEntityIndex(ped)
  
  for _,obj in pairs(GetGamePool("CObject")) do
    local opos = GetEntityCoords(obj)
    local dist = #(pos - opos)

    if (dist < 2.0 and obj ~= weapon) then
      if (IsEntityAttachedToEntity(ped, obj)) then
        NetworkRequestControlOfEntity(obj)
        DetachEntity(obj)
        SetEntityCoords(obj, 0.0, 0.0, -100.0)
        NetworkFadeOutEntity(obj, 0, 0)
        SetEntityAsMissionEntity(obj, false, false)
        DeleteEntity(obj)
      end
    end
  end
end)

RegisterNetEvent("bms:devtools:setextra")
AddEventHandler("bms:devtools:setextra", function(extraId, toggle)
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  if (veh ~= 0) then
    if (extraId == "allon") then
      for i = 0, 32 do
        SetVehicleExtra(veh, i, 0)
      end
    elseif (extraId == "alloff") then
      for i = 0, 32 do
        SetVehicleExtra(veh, i, 1)
      end
    else
      local eId = tonumber(extraId)

      if (IsVehicleExtraTurnedOn(veh, eId)) then
        SetVehicleExtra(veh, eId, 1)
      else
        SetVehicleExtra(veh, eId, 0)
      end
    end
  end
end)

RegisterNetEvent("bms:devtools:getVehExtras")
AddEventHandler("bms:devtools:getVehExtras", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  local retStr = "Extras: "

  for i = 0, 32 do
    print(i, IsVehicleExtraTurnedOn(veh, i))
    if (DoesExtraExist(veh, i)) then
      retStr = retStr .. tostring(i) .. ", "
    end
  end

  if (retStr == "Extras: ") then
    retStr = retStr .. "None"
  else
    retStr = retStr:sub(1, -3)
  end

  TriggerEvent("chatMessage", "SERVER", {0, 255, 0}, retStr)
end)

RegisterNetEvent("bms:devtools:getVehLiveries")
AddEventHandler("bms:devtools:getVehLiveries", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  if (veh ~= 0) then
    SetVehicleModKit(veh, 0)
    local count = GetVehicleLiveryCount(veh)
    local retStr = "Liveries: "

    if (count > 0) then
      for i=0,count - 1 do
        local livery = GetLiveryName(veh, i)
        local livery2 = GetLabelText(livery)

        retStr = retStr .. string_format("[%s]: %s | %s\n", i, livery, livery2)
      end
    else
      retStr = retStr .. "None"
    end

    retStr = retStr .. "\nRoof Liveries: "

    local roofCount = GetVehicleRoofLiveryCount(veh)

    if (roofCount > 0) then
      for i=0,roofCount - 1 do
        local livery = GetLiveryName(veh, i)
        local livery2 = GetLabelText(livery)

        retStr = retStr .. string_format("[%s]: %s | %s\n", i, livery, livery2)
      end
    else
      retStr = retStr .. "None"
    end

    TriggerEvent("chatMessage", "SERVER", {0, 255, 0}, retStr)
  end
end)

RegisterNetEvent("bms:devtools:getNearbyObjects")
AddEventHandler("bms:devtools:getNearbyObjects", function(rad)
  local radius = 40.0

  if (rad and type(rad) == "number") then
    radius = rad
  end

  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)

  print(radius)

  for _,obj in pairs(GetGamePool("CObject")) do
    local opos = GetEntityCoords(obj)
    local dist = #(pos - opos)

    if (dist < radius) then
      print(string_format("Entity: %s, Model: %s, Pos: %s", obj, GetEntityModel(obj), opos))
      TriggerEvent("chatMessage", "SERVER", {0, 255, 0}, string_format("Entity: %s, Model: %s, Pos: %s", obj, GetEntityModel(obj), opos))
    end
  end
end)

RegisterNetEvent("sbc:sendssDirect")
AddEventHandler("sbc:sendssDirect", function(data)
  local d = data.ssd

  exports.sbc:requestScreenshotUpload(d, "files", function(sdata)
    local resp = json_decode(sdata)
    local error = sdata.error

    if (resp.message) then
      TriggerServerEvent("sbc:sendssDirect", {error = error, msg = resp.message})
    end
  end)
end)

RegisterNetEvent("bms:devtools:damageMe")
AddEventHandler("bms:devtools:damageMe", function()
  Citizen.CreateThread(function()
    local ped = PlayerPedId()
    local offset = GetOffsetFromEntityInWorldCoords(ped, 0.0, 5.0, 0.0)
    local hash = GetHashKey("S_M_Y_BusBoy_01")
    
    while (not HasModelLoaded(hash)) do
      RequestModel(hash)
      Wait(10)
    end

    local rped = CreatePed(4, hash, offset.x, offset.y, offset.z, math_random(1, 359), true, true)

    while (not DoesEntityExist(rped)) do
      Wait(100)
    end
    
    SetPedRelationshipGroupHash(rped, GetHashKey("testdamager"))
    GiveWeaponToPed(rped, GetHashKey("WEAPON_PISTOL"), 1000, false, true)
    TaskShootAtEntity(rped, ped)
    SetModelAsNoLongerNeeded(hash)
    SetRelationshipBetweenGroups(5, GetHashKey("testdamager"), GetHashKey("PLAYER"))
    PlayAmbientSpeechWithVoice(rped, "GENERIC_INSULT_HIGH", "s_m_y_sheriff_01_white_full_01", "SPEECH_PARAMS_FORCE_SHOUTED", 0)
    TaskCombatHatedTargetsAroundPed(rped, 20.0)
    print("aggressive ped spawned")
  end)
end)

RegisterNetEvent("bms:netNuiFocusDisable")
AddEventHandler("bms:netNuiFocusDisable", function()
  TriggerEvent("bms:nuiFocusDisable")
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)
    
    local ped = PlayerPedId()

    if (placemode) then
      local ppos = GetEntityCoords(ped)
      --local zcoord = GetGroundZFor_3dCoord(ppos.x, ppos.y, ppos.z, 0, 0)
      local height = GetEntityHeightAboveGround(ped)
      local zcoord = (ppos.z - height)

      if (IsControlPressed(1, 96) or IsDisabledControlPressed(1, 96)) then -- N-
        pradius = pradius + 0.5
        
        if (pradius < 1.0) then
          pradius = 1.0
        end
			end

			if (IsControlPressed(1, 97) or IsDisabledControlPressed(1, 97)) then -- N+
				pradius = pradius - 0.5
			end
      
      if (zcoord) then
        drawPmodeText(string_format("[PTools: Pos x = %s, y = %s, z = %s, Rad: %s, H: %s]", ppos.x, ppos.y, zcoord, pradius, height))
        DrawMarker(1, ppos.x, ppos.y, zcoord - 1.0001, 0, 0, 0, 0, 0, 0, pradius, pradius, 60.0, 0, 255, 0, 150, 0, 0, 0, 0, 0, 0, 0)
      end

      if (not pmodeblip) then
        --pmodeblip = AddBlipForCoord(ppos.x, ppos.y, ppos.z)
        pmodeblip = AddBlipForRadius(ppos.x, ppos.y, ppos.z, pradius)
        SetBlipSprite(pmodeblip,9)
        SetBlipColour(pmodeblip, 6)
      end

      if (pmodeblip) then
        SetBlipCoords(pmodeblip, ppos.x, ppos.y, ppos.z)
        SetBlipScale(pmodeblip, pradius)
      end
    else
      if (pmodeblip) then
        RemoveBlip(pmodeblip)
        pmodeblip = nil
      end
    end

    if (placemodebox) then
      local ppos = GetEntityCoords(ped)
      local height = GetEntityHeightAboveGround(ped)
      local zcoord = (ppos.z - height)

      if (not pbpos) then
        pbpos = ppos
      end

      if (IsControlPressed(1, 96) or IsDisabledControlPressed(1, 96)) then -- N-
        if (IsControlPressed(1, 21)) then -- Shift
          pbheight = pbheight + 0.15
        else
          pbradius = pbradius + 0.5
          
          if (pbradius < 1.0) then
            pbradius = 1.0
          end
        end
			elseif (IsControlPressed(1, 97) or IsDisabledControlPressed(1, 97)) then -- N+
        if (IsControlPressed(1, 21)) then -- Shift
          pbheight = pbheight - 0.15
        else
          pbradius = pbradius - 0.5
        end
      elseif (IsControlPressed(1, 60)) then -- N5
        pbradiusx = pbradiusx + 0.5
      elseif (IsControlPressed(1, 107)) then -- N6
        pbradiusx = pbradiusx - 0.5
      end

      offsetf = vec3(pbpos.x + pbradiusx, pbpos.y + pbradius, pbpos.z + pbheight)
      offsetb = vec3(pbpos.x - pbradiusx, pbpos.y - pbradius, pbpos.z - pbheight)

      DrawBox(offsetf.x, offsetf.y, offsetf.z, offsetb.x, offsetb.y, offsetb.z, 0, 255, 110, 80)

      if (zcoord) then
        drawPmodeText(string_format("[PToolsBox: PosForward: %s, PosBackward: %s, H: %s]", offsetf, offsetb, height))
      end
    elseif (pbpos) then
      pbpos = nil
      pbradius = 30.0
      pbradiusx = 0.0
      pbheight = 10.0
    end

    if (objectdetect) then
      local _, ent = GetEntityPlayerIsFreeAimingAt(PlayerId(), Citizen.ReturnResultAnyway())

      if (ent) then
        local head = GetEntityHeading(ent)
        local pos = GetEntityCoords(ped)
        local epos = GetEntityCoords(ent)
        drawAimingEntity(string_format("Entity: %s, %s | Heading: %s", ent, GetEntityModel(ent), head))
        DrawLine(pos.x, pos.y, pos.z + 0.5, epos.x, epos.y, epos.z, 0, 255, 120, 255)

        if (ent ~= 0) then
          lastodetect.pos = {x = epos.x, y = epos.y, z = epos.z}
          lastodetect.heading = head
          lastodetect.ent = ent
          lastodetect.model = GetEntityModel(ent)
        end
      end
    end

    if (markertest) then
      local pos = GetEntityCoords(ped)
      local opos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
      
      DrawMarker(curmarker, opos.x, opos.y, opos.z, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 1.1, 0, 255, 0, 180, 0, 0, 0, 0, 0, 0, 0)

      if (IsControlJustReleased(1, 11) or IsDisabledControlJustReleased(1, 11)) then -- pgdown
        curmarker = curmarker + 1
        TriggerEvent("chatMessage", "SERVER", {0, 255, 0}, string_format("Drawing Marker %s", curmarker))

        if (curmarker > 61) then
          curmarker = 61
        end
      end

      if (IsControlJustReleased(1, 10) or IsDisabledControlJustReleased(1, 10)) then -- pgup
        curmarker = curmarker - 1

        if (curmarker < 0) then
          curmarker = 0
        end
      end
    end

    if (deltool) then
      if (IsPlayerFreeAiming(PlayerId())) then
        local res, ent = GetEntityPlayerIsFreeAimingAt(PlayerId())

        if (IsPedShooting(ped)) then
          print(string_format("Del Tooling entity: %s, Model: %s", ent, GetEntityModel(ent)))
          SetEntityAsMissionEntity(ent, true, true)
          DeleteEntity(ent)
        end
      end
    end

    if (enttarget) then
      if (IsPlayerFreeAiming(PlayerId())) then
        local res, ent = GetEntityPlayerIsFreeAimingAt(PlayerId())

        if (IsPedShooting(ped)) then
          TriggerEvent("chatMessage", "SERVER", {255, 255, 255}, string_format("Entity Hash: %s, Pos: %s, Heading: %s", GetEntityModel(ent), GetEntityCoords(ent), GetEntityHeading(ent)))
        end
      end
    end

    if (asemode) then
      for _,id in ipairs(GetActivePlayers()) do
        local nped = GetPlayerPed(id)
        
        if (ped ~= nped) then
          local npos = GetEntityCoords(nped)
          local pos = GetEntityCoords(ped)
          local dist = #(pos - npos)
          local sid = GetPlayerServerId(id)
          local name = playerList[sid]

          if (dist < aserange) then
            local onScreen, _sx, _sy = World3dToScreen2d(npos.x, npos.y, npos.z - 0.7)

            DrawRect(_sx - 0.13, _sy - 0.11, 0.15, 0.18, 22, 22, 22, 155)
            drawAseTxt(_sx, _sy, 0.4, 0.4, 0.3, string_format("ID: %s", sid), 135, 206, 235, 255)
            drawAseTxt(_sx, _sy + 0.02, 0.4, 0.4, 0.3, string_format("Name: %s", name), 135, 206, 235, 255)
            drawAseTxt(_sx, _sy + 0.04, 0.4, 0.4, 0.3, string_format("Steam Name: %s", GetPlayerName(id)), 135, 206, 235, 255)
            drawAseTxt(_sx, _sy + 0.06, 0.4, 0.4, 0.3, string_format("Pos: x:%0.3f, y:%0.3f, z:%0.3f", npos.x, npos.y, npos.z), 135, 206, 235, 255)
            drawAseTxt(_sx, _sy + 0.08, 0.4, 0.4, 0.3, string_format("Dist: %s", dist), 135, 206, 235, 255)
            drawAseTxt(_sx, _sy + 0.10, 0.4, 0.4, 0.3, string_format("Health: %s", GetEntityHealth(nped)), 135, 206, 235, 255)
            drawAseTxt(_sx, _sy + 0.12, 0.4, 0.4, 0.3, string_format("Armor: %s", GetPedArmour(nped)), 135, 206, 235, 255)
            drawAseTxt(_sx, _sy + 0.14, 0.4, 0.4, 0.3, string_format("Speed: %s", GetEntitySpeed(nped)), 135, 206, 235, 255)
            DrawLine(pos.x, pos.y, pos.z, npos.x, npos.y, npos.z, 0, 255, 0, 150)
          end
        end
      end
    end

    if (spec.active) then
      local specPed = GetPlayerPed(spec.pl)
      
      if (specPed > 0) then
        local specPos = GetEntityCoords(GetPlayerPed(spec.pl))
        SetEntityCoords(ped, specPos.x, specPos.y, -180.0)
      else
        spec.active = false

        local ped = PlayerPedId()
        SetEntityInvincible(ped, false)
        SetPedDiesInWater(ped, true)
        TriggerServerEvent("bms:teleporter:teleportToPoint", ped, spec.oldPos)
        spec.ped = 0
        spec.oldPos = nil
      end
    end

    if (loadedprop and not hidepropdebug) then
      drawPosRotPropText()
      
      --if (IsControlPressed(1, 21)) then
        if (IsControlPressed(1, 108)) then -- N4
          propposrot.pos.x = propposrot.pos.x + 0.25
          reloadProp()
        elseif (IsControlPressed(1, 60)) then -- N5
          propposrot.pos.y = propposrot.pos.y + 0.25
          reloadProp()
          --print("pressed2")
        elseif (IsControlPressed(1, 107)) then -- N6
          propposrot.pos.z = propposrot.pos.z + 0.25
          reloadProp()
          --print("pressed3")
        elseif (IsControlPressed(1, 117)) then -- N7
          propposrot.rot.x = propposrot.rot.x + 0.25
          reloadProp()
          --print("pressed4")
        elseif (IsControlPressed(1, 96)) then -- N+: N8 fires constantly for some reason
          propposrot.rot.y = propposrot.rot.y + 0.25
          reloadProp()
          --print("pressed5")
        elseif (IsControlPressed(1, 118)) then -- N9
          propposrot.rot.z = propposrot.rot.z + 0.25
          reloadProp()
          --print("pressed6")
        end
      --end
    end

    if (drawmmarker) then
      DrawMissionMarker(0, "Test Marker", "Header 1\nHeader 2", markerpos.x, markerpos.y, markerpos.z, 15)
    end

    if (hudToggle) then
      HideHelpTextThisFrame()
      --HideHudComponentThisFrame(19) -- weapon wheel
      HideHudComponentThisFrame(1) -- Wanted Stars
      HideHudComponentThisFrame(2) -- Weapon icon
      TriggerEvent("chat:hideChat")
    end

    if (camsetupmode and debugcam ~= -1) then
      DisableFirstPersonCamThisFrame()
      BlockWeaponWheelThisFrame()

      for _,v in pairs(camdisablecontrols) do
        DisableControlAction(0, v, true)
      end

      local campos = GetCamCoord(debugcam)
      local newcampos = processCameraPosition(campos.x, campos.y, campos.z)     

      SetFocusArea(newcampos.x, newcampos.y, newcampos.z)
      SetCamCoord(debugcam, newcampos.x, newcampos.y, newcampos.z)
      SetCamRot(debugcam, offsetRotX, offsetRotY, offsetRotZ)
    end

    if (timecyclerSettings.active) then
      BlockWeaponWheelThisFrame()

      if (IsControlJustPressed(1, 241) or IsDisabledControlJustPressed(1, 241)) then -- mouse wheel up
        timecyclerSettings.cur = timecyclerSettings.cur - 1

        if (timecyclerSettings.cur < 1) then
          timecyclerSettings.cur = #timecycles
        end

        ClearTimecycleModifier()
        SetTimecycleModifier(timecycles[timecyclerSettings.cur])
        timecyclerSettings.nameref = timecycles[timecyclerSettings.cur]
      elseif (IsControlJustPressed(1, 242) or IsDisabledControlJustPressed(1, 242)) then -- mouse wheel down
        timecyclerSettings.cur = timecyclerSettings.cur + 1

        if (timecyclerSettings.cur > #timecycles) then
          timecyclerSettings.cur = 1
        end

        ClearTimecycleModifier()
        SetTimecycleModifier(timecycles[timecyclerSettings.cur])
        timecyclerSettings.nameref = timecycles[timecyclerSettings.cur]
      elseif (IsControlJustReleased(1, 314)) then -- numpad +
        timecyclerSettings.strength = timecyclerSettings.strength + 0.1
        SetTimecycleModifierStrength(timecyclerSettings.strength)
      elseif (IsControlJustReleased(1, 315)) then
        timecyclerSettings.strength = timecyclerSettings.strength - 0.1
        SetTimecycleModifierStrength(timecyclerSettings.strength)
      end

      drawPmodeText(string_format("Modifier: %s [%s], Strength: %s", timecyclerSettings.nameref, timecyclerSettings.cur, timecyclerSettings.strength))
    end

    if (objectScanner.active) then
      local pos = GetEntityCoords(ped)

      local function getIndexedObjectEntities()
        local indexes = {}

        for ent, _ in pairs(objectScanner.objects) do
          table_insert(indexes, ent)
        end

        table_sort(indexes)
        return indexes
      end

      local function countKvTable(t)
        local cnt = 0

        for _, _ in pairs(t) do
          cnt = cnt + 1
        end

        return cnt
      end

      for entity, entData in pairs(objectScanner.objects) do
        if (not entData.highlighted) then
          entData.highlighted = true
          SetEntityDrawOutline(entity, true)
        end

        local entPos = GetEntityCoords(entity)

        if (objectScanner.vehicles) then
          if (IsEntityAVehicle(entity)) then
            local plate = GetVehicleNumberPlateText(entity)

            if (plate) then
              drawText3Ds(entPos.x, entPos.y, entPos.z - 0.02, string_format("%s [%s]\nPlate: %s", entity, entData.model, plate:upper()))
            end
          end
        else
          drawText3Ds(entPos.x, entPos.y, entPos.z - 0.02, string_format("%s [%s]", entity, entData.model))
        end
        
        if (objectScanner.selectedEntity) then
          if (objectScanner.selectedEntity == entity) then
            DrawLine(pos.x, pos.y, pos.z, entPos.x, entPos.y, entPos.z, 230, 85, 41, 255)
          else
            DrawLine(pos.x, pos.y, pos.z, entPos.x, entPos.y, entPos.z, 0, 120, 120, 255)
          end
        else
          DrawLine(pos.x, pos.y, pos.z, entPos.x, entPos.y, entPos.z, 0, 120, 120, 255)
        end
      end

      BlockWeaponWheelThisFrame()
      DisableControlAction(0, 23, true)
      DisableControlAction(0, 45, true)
      DisableControlAction(0, 140, true)

      if (countKvTable(objectScanner.objects) == 0) then
        objectScanner.selectedEntityIndex = 0
      else
        if (IsControlJustReleased(1, 74)) then
          SendNUIMessage({toggleGenericInfoPopup = true, toggle = true, text = 
            "<span class='genericInfoPopupHighlight'>Wheel Up/Down</span>: Cycle targets<br/>" ..
            "<span class='genericInfoPopupHighlight'>Page Up/Down</span>: Cycle mode (Object | Vehicles)<br/>" ..
            "<span class='genericInfoPopupHighlight'>DEL</span>: Delete Target<br/>" ..
            "<span class='genericInfoPopupHighlight'>Shift-F</span>: Fill Fuel Highlighted<br/>" ..
            "<span class='genericInfoPopupHighlight'>Shift-R</span>: Repair Highlighted<br/>"
          })
        end
        
        if (IsControlJustPressed(1, 241)) then -- 241 wheel up
          objectScanner.selectedEntityIndex = objectScanner.selectedEntityIndex - 1

          if (objectScanner.selectedEntityIndex < 1) then
            objectScanner.selectedEntityIndex = countKvTable(objectScanner.objects)
          end

          local entIndexes = getIndexedObjectEntities()

          if (entIndexes) then
            objectScanner.selectedEntity = entIndexes[objectScanner.selectedEntityIndex]
          end
        elseif (IsControlJustPressed(1, 242)) then -- 242 wheel down
          objectScanner.selectedEntityIndex = objectScanner.selectedEntityIndex + 1

          if (objectScanner.selectedEntityIndex > countKvTable(objectScanner.objects)) then
            objectScanner.selectedEntityIndex = 1
          end

          local entIndexes = getIndexedObjectEntities()

          if (entIndexes) then
            objectScanner.selectedEntity = entIndexes[objectScanner.selectedEntityIndex]
          end
        elseif (IsControlJustReleased(1, 11)) then -- page down
          objectScanner.vehicles = not objectScanner.vehicles

          if (objectScanner.vehicles) then
            exports.pnotify:SendNotification({text = "Switched to Vehicles mode"})
          else
            exports.pnotify:SendNotification({text = "Switched to Objects mode"})
          end

          objectScanner.justSwitchedType = true
        elseif (IsControlJustReleased(1, 10)) then -- page up
          objectScanner.vehicles = not objectScanner.vehicles

          if (objectScanner.vehicles) then
            exports.pnotify:SendNotification({text = "Switched to Vehicles mode"})
          else
            exports.pnotify:SendNotification({text = "Switched to Objects mode"})
          end

          objectScanner.justSwitchedType = true
        elseif (IsControlJustReleased(1, 178)) then -- DEL
          -- Try client delete
          local ent = objectScanner.selectedEntity
          local model = GetEntityModel(ent)
          
          if (ent and DoesEntityExist(ent)) then
            SetEntityAsMissionEntity(ent, true, true)
            NetworkRequestControlOfEntity(ent)
            local timeout = GetGameTimer() + 10000

            DeleteEntity(ent)
            DeleteObject(ent)
            Wait(100)

            while (DoesEntityExist(ent) and not NetworkHasControlOfEntity(ent) and GetGameTimer() < timeout) do
              NetworkRequestControlOfEntity(ent)
              Wait(10)
            end

            DeleteEntity(ent)
            DeleteObject(ent)

            if (DoesEntityExist(ent)) then
              exports.pnotify:SendNotification({text = "/oscan client delete failed!  Trying server delete.."})
              TriggerServerEvent("bms:devtools:oscanDel", NetworkGetNetworkIdFromEntity(ent))
            else
              objectScanner.selectedEntity = nil
              print(("Entity [%s] deleted.  Model: %s"):format(ent, model))
              exports.pnotify:SendNotification({text = "Object deleted.. probably."})
            end
          end
        elseif (IsControlPressed(1, 21) and IsDisabledControlJustReleased(1, 23)) then -- SHIFT-F (fuel all highlighted, for events)
          for entity, _ in pairs(objectScanner.objects) do
            if (IsEntityAVehicle(entity)) then
              exports.fuel:setVehicleFuelLevel(entity, 65.0)
            end
          end

          exports.pnotify:SendNotification({text = "All highlighted vehicles have been refueled."})
        elseif (IsControlPressed(1, 21) and IsDisabledControlJustReleased(1, 45)) then -- SHIFT-R (repair all highlighted, for events)
          for entity, _ in pairs(objectScanner.objects) do
            local ent = tonumber(entity)

            SetVehicleEngineHealth(ent, 1000.0)
            SetVehicleBodyHealth(ent, 1000.0)
            SetVehicleFixed(ent)
            SetVehicleDeformationFixed(ent)
            SetVehicleUndriveable(ent, false)
          end

          exports.pnotify:SendNotification({text = "All highlighted vehicles have been repaired."})
        end

        if (objectScanner.selectedEntity and DoesEntityExist(objectScanner.selectedEntity)) then
          local entPos = GetEntityCoords(objectScanner.selectedEntity)

          DrawSphere(entPos.x, entPos.y, entPos.z, 1.0, 230, 179, 41, 0.45)
        end
      end
    end
  end
end)

Citizen.CreateThread(function() -- object scanner
  while true do
    Wait(500)

    if (objectScanner.active) then
      if (objectScanner.justSwitchedType) then
        -- clear all the glows
        for ent, _ in pairs(objectScanner.objects) do
          SetEntityDrawOutline(ent, false)
          objectScanner.objects = {}
        end
      end

      local pos = GetEntityCoords(PlayerPedId())
      local objects = {}
      
      if (objectScanner.vehicles) then
        objects = GetGamePool("CVehicle")
      else
        objects = GetGamePool("CObject")
      end

      for _, o in pairs(objects) do
        local opos = GetEntityCoords(o)
        local dist = #(pos - opos)

        if (dist < objectScanner.range) then
          objectScanner.objects[o] = {model = GetEntityModel(o)}
        elseif (objectScanner.objects[o] and DoesEntityExist(o)) then
          if (objectScanner.objects[o].highlighted) then
            SetEntityDrawOutline(o, false)
          end

          objectScanner.objects[o] = nil
        end
      end
    end
  end
end)

--[[RegisterNetEvent("bms:devtools:addblip")
AddEventHandler("bms:devtools:addblip", function(blipid)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)

  if (blipid) then
    local b = AddBlipForCoord(pos.x, pos.y, pos.z)
    SetBlipSprite(b, blipid)
    TriggerEvent("chatMessage", "SERVER", {255, 0, 0}, "Adding blip " .. blipid)
  end
end)

RegisterNetEvent("bms:devtools:playsound")
AddEventHandler("bms:devtools:playsound", function(set, sound)
  if (set and sound) then
    local ped = PlayerPedId()
    PlaySoundFromEntity(-1, GetHashKey(set), ped, GetHashKey(sound), 0, 0)
    --/ps Gold_Vault_Explosions BIG_SCORE_3B_SOUNDS
  end
end)]]

--[[RegisterNetEvent("bms:devtools:setvoiceactive")
AddEventHandler("bms:devtools:setvoiceactive", function(toggle)
  NetworkSetVoiceActive(toggle)
end)]]

--[[local houses = {}
local canHandleInput = true
local keys = {["E"] = 38}
local lastPoi]]

--[[
  Lua Code / Native Profiler
  Enable while loop below to true
  Make functions with a name and run it
  Use with 
    profiler record 4
    profiler view
  to view the results
]]
--[[
local iterations = 10000
local tests = {
  ["GetPlayerPed"] = function()
    GetPlayerPed(-1)
  end,
  ["PlayerPedId"] = function()
    PlayerPedId()
  end,
}
 
CreateThread(function()
  while true do
    Wait(0)
  
    if (ProfilerIsRecording()) then
      for test, func in next, tests do
        ProfilerEnterScope(test)

        for i = 0, iterations do
          func()
        end

        ProfilerExitScope()
      end
      Wait(0)
    end
  end
end)
--]]
