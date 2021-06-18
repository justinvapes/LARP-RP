local table_insert = table.insert
local table_remove = table.remove
local table_pack = table.pack
local json_decode = json.decode
local string_match = string.match
local string_format = string.format
local math_random = math.random
local math_randomseed = math.randomseed
local guiEnabled = false
local skinName = ""
--local personalVehicle
local loadCamCoords = {x = 494.639, y = 724.508, z = 245.503, rx = 0, ry = 0, rz = 0}
local loadCams = {}
local spawnArea = 1
local chances = {
  {id = 1, perc = 0.18, desc = "[10-71] Reports of shots fired." }, -- shooting a weapon in public
  {id = 2, perc = 0.90, desc = "[10-31] Hold Up and Robbery in progress."}, -- robbery of a player
  {id = 3, perc = 0.72, desc = "[10-66] Suspicious person seen dealing narcotics."},
  {id = 4, perc = 1.00, desc = "[10-69] Konig is comitting a violent crime."}, -- unused at this time
  {id = 5, perc = 0.80, desc = "[10-31] Someone breaking into a vehicle"},
  {id = 6, perc = 1.00, desc = "[529] Explosion reported at location."},
  {id = 7, perc = 1.00, desc = "[10-31] Robbery in progress."}
}
--[[
    1 [10-71] Reports of shots fired."
    2 [10-31] Hold Up and Robbery in progress."
    3 [10-66] Suspicious person seen dealing narcotics."
    4 Carjacking - make and model and color of vehicle
    5 Public intoxication
    6 Automotive accident (vehicle disabled)
    7 Loitering (~5 people standing in area for more than 10 minutes)
    8 Shots fired from vehicle (w/ make/model/color, small chance for plate)
    9 Explosion / fire (include meth lab)
    10 [10-90] Bank Alarm Triggered
    11 Alarm Triggered
    12 Person brandishing large weapon
    13 Officer Down
    14 Officer in distress
    15 Physical Altercation
    16 Trespassing reports
    BOOL _CAN_PED_SEE_PED(Ped ped1, Ped ped2); CanPedSeePed Returns true if ped1 can see ped2 in their line of vision
    GetPedNearbyPeds(Ped, int* sizeAndPeds, int ignore)
    GetPedsJacker()
    SetPedCanSmashGlass
    GetHashOfMapAreaAtCoords
    jobs\tacotruck\tacotruck_cl.lua:98
]]

local crimeReportFlag = false
local checkingForPeds = false
local lastCheckedForPedsTime = 0
local witnessCrimeDelay = 10000
local pedSent = false
local isWitnessReportingCrime = false
local witnessActive = false
local lastped
local witnessPed
local crimeRange = 50.0
local waitingforped = false
local activeCrime = false
local crimeReportCooldownTime = 18000
local crimeReportChance = nil
local crimeDetails = {}
local witnessedRecently = {}
local pedsinrange = {}
local recentpeds = {}
local comphashes = {}
local crcooldown = false
local loadCamSpots = {
  {pos = {x = 494.639, y = 724.508, z = 245.503}, rot = {x = 0.0, y = 0.0, z = 0.0}},
  --{pos = {x = -1232.6735839844, y = -1766.3537597656, z = 42.688682556152}, rot = {x = -19.0, y = 0.0, z = -1.88}}
  {pos = {x = -417.24810791016, y = -71.495277404785, z = 152.69340515137}, rot = {x = -19.0, y = 0.0, z = -1.88}}
}
local loadCamSequencing = false
--local bandage = {dict = "amb@medic@standing@kneel@idle_a", anim = "idle_a", time = 5000}
local bandage = {anims = {{dict = "anim@mp_yacht@shower@male@", anim = "male_shower_idle_a", time = 4900}, {dict = "amb@medic@standing@kneel@idle_a", anim = "idle_a", time = 4000}}}
local standup = {dict = "get_up@first_person@directional@movement@from_knees@standard", anim = "getup_l_0"}
local medprop = {ent = 0, off = {x = 0.1, y = 0.1, z = 0}}
local loaded = false
local timecycleTransition = {active = false, curStrength = 1.0, toStrength = 1.0, strengthStep = 0.001, opIn = true, killOnZero = true}
local inHousingInstance = false

function enableGui(enable, data)
  local postNuiDisable
  local postNuiDisableEvent

  if (data) then
    postNuiDisable = data.postNuiDisable
    postNuiDisableEvent = data.postNuiDisableEvent
  end
  
  DisplayHud(not enable)  
  SetNuiFocus(enable, enable)  
  guiEnabled = enable

  if (postNuiDisable) then
    if (postNuiDisableEvent and postNuiDisableEvent ~= "") then
      TriggerEvent(postNuiDisableEvent)
    end
  end
end

function hasValue(tab, val)
  for index, value in ipairs(tab) do
    if value == val then
      return true
    end
  end
  return false
end

function setupLoadCamera(enable)
  if (enable) then
    loadCamSequencing = true

    for _,v in pairs(loadCamSpots) do
      v.cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", v.pos.x, v.pos.y, v.pos.z, 0, 0, 0, GetGameplayCamFov(), 0, 0)
      SetCamRot(v.cam, v.rot.x or 0.0, v.rot.y or 0.0, v.rot.z or 0.0, 2)
    end

    SetCamActive(loadCamSpots[1].cam, true)
    RenderScriptCams(1, 0, 3000, 1, 0)
    SetCamActiveWithInterp(loadCamSpots[2].cam, loadCamSpots[1].cam, 120000, 1, 1)
  else
    loadCamSequencing = false
    
    for _,v in pairs(loadCamSpots) do
      RenderScriptCams(0, 0, 3000, 1, 0)
      v.cam = nil
    end

    loadCamSpots = {}
    ClearFocus()
  end
end

function getSpawnArea(cb)
  if (cb) then
    cb(spawnArea)
  end
end

function getAddressAtPos(pos)
  local street = table_pack(GetStreetNameAtCoord(pos.x, pos.y, pos.z))
  local address

  address = GetStreetNameFromHashKey(street[1])
  
  if (street[2] ~= nil and street[2] ~= "") then
    local street2 = GetStreetNameFromHashKey(street[2])

    if (street2 ~= "") then
      address = address .. " and " .. street2
    end
  end

  return address or "Unknown"
end

function crCooldownTimeout()
  crcooldown = true
  
  SetTimeout(crimeReportCooldownTime, function()
    crcooldown = false
  end)
end

function inGunRange(ped)
  if (IsEntityInArea(ped, 5.7184, -1066.3647, 33.8026, 20.8623, -1102.5071, 27.8526, 0, 1, 0) or -- Ammunation by Legion
      IsEntityInArea(ped, 827.7852, -2193.5911, 33.1568, 815.2983, -2148.6924, 27.6817, 0, 1, 0)) then  -- Ammunation by the docks
    return true
  else
    return false
  end
end

function crimeReportChanceCalc()
  crimeReportChance = nil
  math_randomseed(GetGameTimer())
  crimeReportChance = math_random()
end

function startReportingCrime(details)
  witnessPed = nil
  witnessActive = true
  activeCrime = true
  if (details ~= {}) then
    crimeDetails = details
  end
  crimeReportChanceCalc()
end

function stopReportingCrime()
  witnessActive = false
  checkingForPeds = false

  local ped = PlayerPedId()

  if (inscenerio) then
    ClearPedTasks(ped)
    inscenerio = false
  end

  if (witnessPed) then
    ClearPedSecondaryTask(witnessPed)
  end

  witnessPed = nil
  activeCrime = false
  crimeDetails = {}
end

function checkForPedsAtCoord(x, y, z, rad)
  local foundped = nil
  local lastCheckedForPedsTime = GetGameTimer()
  local difference = 0
  local pedChecking = true
  
  Citizen.CreateThread(function()
    while pedChecking do
      Wait(0)
      local currentTime = GetGameTimer()

      difference = currentTime - lastCheckedForPedsTime
      
      if (witnessActive and not witnessPed and (difference < witnessCrimeDelay)) then
        local nearbyPeds = GetNearbyPeds(x, y, z, rad)
        
        if (nearbyPeds ~= nil) then
          foundped = nearbyPeds[1]
        end
        
        if (foundped ~= nil and not witnessContains(foundped)) then
          witnessPed = foundped
          checkingForPeds = false
        end
        
        Wait(1000)
      elseif (difference > witnessCrimeDelay) then
        stopReportingCrime()
        pedChecking = false
      end
    end
  end)
end

function GetNearbyPeds(x, y, z, radius)
  local nearbyPeds = {}

  if (tonumber(x) and tonumber(y) and tonumber(z)) then
    if (tonumber(radius)) then
      local pos = vec3(x, y, z)

      for _, ped in pairs(GetGamePool("CPed")) do
        if DoesEntityExist(ped) then
          if (IsPedHuman(ped) and not IsPedAPlayer(ped)) then
            local pedPos = GetEntityCoords(ped, false)
            
            if (#(pos - pedPos) <= radius) then
              table_insert(nearbyPeds, ped)
            end
          end
        end
      end
    end
  end
  
  return nearbyPeds
end

function witnessReport(rped, anim, clip, flags, crimeDetails)
  isWitnessReportingCrime = true

  Citizen.CreateThread(function()

    flags = flags or 34
    RequestAnimDict(anim)

    while not HasAnimDictLoaded(anim) do
      Citizen.Wait(100)
    end

    while (isWitnessReportingCrime) do
      Wait(1)
      if (crimeDetails == {}) then
        --print("No details for crime")
      end

      local ped = PlayerPedId()
      TaskTurnPedToFaceEntity(rped, ped, 0)
      TaskPlayAnim(rped, anim, clip, 8.0, -8, -1, 0, 0, 0, 0, 0)
      -- Wait 7 seconds to make phone call to 911 
      Wait(7000)

      if (not IsEntityDead(rped)) then
        TriggerEvent("bms:characters:setcrimereport", crimeDetails.id, crimeDetails.data)
      end  
      isWitnessReportingCrime = false
    end
    RemoveAnimDict(anim)
    stopReportingCrime()
    pedSent = false
    
    witnessPed = nil
    witnessActive = false
    pedInCar = false
  end)
end

function addWitnessPed(ped)
  if (#witnessedRecently > 30) then
    table_remove(witnessedRecently, 1)
  end
  table_insert(witnessedRecently, ped)
end

function witnessContains(ped)
  for _,v in pairs(witnessedRecently) do
    if (v == ped) then
      return true
    end
  end

  return false
end

function drawDebugText(text)
  SetTextFont(4)
  SetTextProportional(0)
  SetTextScale(0.42, 0.42)
  SetTextColour(135, 206, 250, 255)
  SetTextDropShadow(25, 25, 112, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(0)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.45, 0.884)
end

function filterCrimeByWitness(witnessPed, pos, pedSent)
  local dpos = GetEntityCoords(witnessPed)
  local ddist = #(pos - dpos)
  local chance = chances[crimeDetails.id].perc

  if (crimeReportChance <= chance) then
    if (DoesEntityExist(witnessPed) and not pedSent) then
      if (not IsPedInAnyVehicle(witnessPed)) then
        if (ddist < crimeRange) then
          if (not isWitnessReportingCrime) then
            witnessReport(witnessPed, "amb@world_human_stand_mobile@female@standing@call@base", "base", 0, crimeDetails)
          else
            stopReportingCrime()
          end
        else
          stopReportingCrime()
        end
      end
    
      addWitnessPed(witnessPed)
      pedSent = true
    end
  end
end

if (drawdebug) then
  Citizen.CreateThread(function()
    while true do
      Wait(1)

      debugtext = ""

      for _,v in pairs(pedsinrange) do
        debugtext = debugtext .. string_format("%s, ", v)
      end

      if (debugtext ~= "") then
        drawDebugText(debugtext)
      end
    end
  end)
end

function attachEntityToPed(prop, boneidx, x, y, z, rx, ry, rz)
  local ped = PlayerPedId()
  boneidx = GetPedBoneIndex(ped, boneidx)
  local obj = CreateObject(prop, 1729.73, 6403.90, 34.56, true, true, 0)
      
  AttachEntityToEntity(obj, ped, boneidx, x, y, z, rx, ry, rz, false, false, false, false, 2, true)

  return obj
end

function doBandageSelf()
  if (bandage.bandaging) then
    return
  end
  
  Citizen.CreateThread(function()
    bandage.bandaging = true
    local ped = PlayerPedId()
    local curhealth = GetEntityHealth(ped)
    local maxhealth = GetPedMaxHealth(ped)
    
    if (curhealth < maxhealth) then
      local sid = GetPlayerServerId(PlayerId())
      
      for _,v in pairs(bandage.anims) do
        while (not HasAnimDictLoaded(v.dict)) do
          RequestAnimDict(v.dict)
          Wait(10)
        end
      end

      while (not HasAnimDictLoaded(standup.dict)) do
        RequestAnimDict(standup.dict)
        Wait(10)
      end

      local hash = GetHashKey("prop_ld_health_pack")

      while (not HasModelLoaded(hash)) do
        RequestModel(hash)
        Wait(10)
      end

      if (medprop.ent ~= 0) then
        DeleteObject(medprop.ent)
      end

      local pedveh = GetVehiclePedIsIn(ped)
      local pedflag = 1

      if (pedveh ~= 0) then
        pedflag = 49
      end
      
      exports.emotes:setCanEmote(false)
      
      if (IsPedHuman(ped)) then
        TaskPlayAnim(ped, bandage.anims[1].dict, bandage.anims[1].anim, 2.0, 2.0, -1, pedflag, 0, 0, 0, 0)
        Wait(550)
        medprop.ent = attachEntityToPed(hash, 60309, medprop.off.x, medprop.off.y, medprop.off.z, 45.0, 90.0, -90.0)
        Wait(bandage.anims[1].time - 750)
        TaskPlayAnim(ped, bandage.anims[2].dict, bandage.anims[2].anim, 2.0, 2.0, -1, pedflag, 0, 0, 0, 0)
        Wait(bandage.anims[2].time)
      end
      
      exports.emotes:setCanEmote(true)
      exports.management:TriggerServerCallback("bms:characters:doBandageSelf", function(hval)
        if (IsPedHuman(ped)) then
          if (pedveh == 0) then
            TaskPlayAnim(ped, standup.dict, standup.anim, 8.0, -8, -1, pedflag, 0, 0, 0, 0)        
            Wait(1000)
          end
        end

        SetEntityHealth(ped, curhealth + hval)
        bandage.bandaging = false
        ClearPedTasks(ped)
        
        for _,v in pairs(bandage.anims) do
          RemoveAnimDict(v.dict)
        end

        RemoveAnimDict(standup.dict)
        SetModelAsNoLongerNeeded(hash)
        
        if (medprop.ent ~= 0) then
          DeleteObject(medprop.ent)
        end
      end)
    else
      TriggerEvent("chatMessage", "CHARACTER", {255, 0, 0}, "You are already at maximum health.")
      bandage.bandaging = false
    end
  end)
end

RegisterNetEvent("bms:char:setPlayerDecorator")
AddEventHandler("bms:char:setPlayerDecorator", function(key, value, type)
  local ped = PlayerPedId()
  
  if (not DecorExistOn(ped, key)) then
    DecorRegister(key, type)
  end
  
  if (type == 1) then
    DecorSetFloat(ped, key, value)
  elseif (type == 2) then
    DecorSetBool(ped, key, value)
  elseif (type == 3) then
    DecorSetInt(ped, key, value)
  end
end)

RegisterNetEvent("bms:activateCharMoney")
AddEventHandler("bms:activateCharMoney", function(e)
  exports.inventory:setCharMoney(e)
  SendNUIMessage({setmoney = true, money = e})
end)

RegisterNetEvent("bms:activateCharDirtyMoney")
AddEventHandler("bms:activateCharDirtyMoney", function(e)
  SendNUIMessage({setdirtymoney = true, dirtymoney = e})
end)

RegisterNetEvent("bms:addedCharMoney")
AddEventHandler("bms:addedCharMoney", function(m)
  SendNUIMessage({addcash = true, money = m})
end)

RegisterNetEvent("bms:addedCharDirtyMoney")
AddEventHandler("bms:addedCharDirtyMoney", function(m)
  SendNUIMessage({adddirtymoney = true, dirtymoney = m})
end)

RegisterNetEvent("bms:removedCharMoney")
AddEventHandler("bms:removedCharMoney", function(m)
  SendNUIMessage({removecash = true, money = m})
end)

RegisterNetEvent("bms:removedCharDirtyMoney")
AddEventHandler("bms:removedCharDirtyMoney", function(m)
  SendNUIMessage({removedirtymoney = true, dirtymoney = m})
end)

RegisterNetEvent("bms:setCharMoneyDisplay")
AddEventHandler("bms:setCharMoneyDisplay", function(val)
  SendNUIMessage({setDisplay = true, display = val})
end)

RegisterNetEvent("bms:setCharDirtyMoneyDisplay")
AddEventHandler("bms:setCharDirtyMoneyDisplay", function(val)
  SendNUIMessage({setDirtyDisplay = true, display = val})
end)

RegisterNetEvent("bms:showCharDialog")
AddEventHandler("bms:showCharDialog", function()
  enableGui(true)
  SendNUIMessage({meta = "openCharDialog"})
end)

RegisterNUICallback("escape", function(data, cb)
  enableGui(false)
  SendNUIMessage({meta = "closeCharDialog"})
end)

RegisterNUICallback("createCharacter", function(data, cb)
  if (data.firstName and data.lastName) then
    TriggerServerEvent("bms:char:createNewCharacter", data.firstName, data.lastName)
  end
end)

RegisterNUICallback("changeName", function(data, cb)
  if (data.firstName and data.lastName and data.oldName) then
    TriggerServerEvent("bms:char:changeCharacterName", data.firstName, data.lastName, data.oldName)
  end
end)

RegisterNetEvent("bms:char:charCreateSuccess")
AddEventHandler("bms:char:charCreateSuccess", function()
  --[[SendNUIMessage({
    meta = "closeCharDialog"
  })]]
    
  --enableGui(false)
end)

RegisterNUICallback("debug", function(data, cb)
  if (data) then
    TriggerServerEvent("bms:serverprint", "debug: " .. tostring(data))
  else
    TriggerServerEvent("bms:serverprint", "debug: no data")
  end
end)

RegisterNUICallback("selectChar", function(data, cb)
  if (data.character) then
    spawnArea = data.spawnarea
    TriggerServerEvent("bms:char:selectChar", data.character, data.spawnarea)
    
    exports.weaponshop:getWsCompHashes(function(hashes)
      comphashes = hashes
    end)
  end
end)

RegisterNUICallback("finishedLoading", function(data, cb)
  if (data.loaded) then
    loaded = true
  end
end)

RegisterNetEvent("bms:charCreateFail")
AddEventHandler("bms:charCreateFail", function(status)
  if (status == "exists") then
    SendNUIMessage({meta = "charExists"})
  end
end)

RegisterNetEvent("bms:nameChangeFail")
AddEventHandler("bms:nameChangeFail", function(status)
  if (status == "exists") then
    SendNUIMessage({meta = "charExists"})
  end
end)

RegisterNetEvent("bms:freezePlayer")
AddEventHandler("bms:freezePlayer", function()
  local ped = PlayerPedId()
  
  FreezeEntityPosition(ped, true)
  SetEnableHandcuffs(ped, true)
end)

RegisterNetEvent("bms:unfreezePlayer")
AddEventHandler("bms:unfreezePlayer", function()
  local ped = PlayerPedId()
  
  FreezeEntityPosition(ped, false)
  SetEnableHandcuffs(ped, false)
end)

RegisterNetEvent("bms:spawnBlackout")
AddEventHandler("bms:spawnBlackout", function()
  enableGui(true)
  SendNUIMessage({meta = "spawnBlackout"})
  -- load camera
  setupLoadCamera(true)
end)

RegisterNetEvent("bms:characterSelectPostInit")
AddEventHandler("bms:characterSelectPostInit", function(data)
  SendNUIMessage({meta = "disableBlackout"})
  enableGui(false, data)
  setupLoadCamera(false)
end)

RegisterNetEvent("bms:char:loginForumFailed")
AddEventHandler("bms:char:loginForumFailed", function()
  SendNUIMessage({meta = "loginFailed"})
end)

RegisterNetEvent("bms:char:noForumUser")
AddEventHandler("bms:char:noForumUser", function()
  SendNUIMessage({meta = "loginFailedUsername"})
end)

RegisterNetEvent("bms:setCharacterSkin")
AddEventHandler("bms:setCharacterSkin", function(skin)
  if (not skin) then
    return
  end
  
  Citizen.CreateThread(function()
    Wait(0)

    local model = GetHashKey(skin)
  
    RequestModel(model)

    while (not HasModelLoaded(model)) do
      RequestModel(model)
      Wait(0)
    end
    
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
  end)
  
  TriggerEvent("bms:characterSelectPostInit")
end)

RegisterNetEvent("bms:showCharList")
AddEventHandler("bms:showCharList", function(charList)
  -- charList is a table of char names
  SendNUIMessage({meta = "showCharList"})
  
  for _,v in pairs(charList) do    
    SendNUIMessage({meta = "addCharacter", charName = v})
  end
  
  SendNUIMessage({meta = "addCreateButton"})
end)

RegisterNetEvent("bms:char:giveMoneyAnim")
AddEventHandler("bms:char:giveMoneyAnim", function()
  local ped = PlayerPedId()

  RequestModel(GetHashKey("prop_cash_pile_01"))

  while (not HasModelLoaded(GetHashKey("prop_cash_pile_01"))) do
    Wait(10)
  end

  RequestAnimDict("mp_common")

  while (not HasAnimDictLoaded("mp_common")) do
    Wait(10)
  end
  
  local ppos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)

  gmSpawned = CreateObject(GetHashKey("prop_cash_pile_01"), ppos.x, ppos.y, ppos.z, true, false, false)
  SetModelAsNoLongerNeeded(GetHashKey("prop_cash_pile_01"))
  AttachEntityToEntity(gmSpawned, ped, GetPedBoneIndex(ped, 57005), 0.19, 0.04, -0.05, 180.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
  TaskPlayAnim(ped, "mp_common", "givetake1_a", 2.0, 2.0, -1, 48, 0, 0, 0, 0)
  Wait(800)
  DetachEntity(gmSpawned, 1, 1)
  DeleteEntity(gmSpawned)
  Wait(1000)
  RemoveAnimDict("mp_common")
end)

RegisterNetEvent("bms:char:takeMoneyAnim")
AddEventHandler("bms:char:takeMoneyAnim", function()
  local ped = PlayerPedId()

  RequestAnimDict("anim@heists@narcotics@trash")

  while (not HasAnimDictLoaded("anim@heists@narcotics@trash")) do
    Wait(10)
  end
  
  Wait(500)
  TaskPlayAnim(ped, "anim@heists@narcotics@trash", "drop_front", 2.0, 2.0, -1, 48, 0, 0, 0, 0)
  Wait(1000)
  RemoveAnimDict("anim@heists@narcotics@trash")
end)

RegisterNetEvent("bms:char:loadCharacterData")
AddEventHandler("bms:char:loadCharacterData", function(d)
  Citizen.CreateThread(function()
    while (not loaded) do
      Wait(1000)
    end
  
    if (d) then
      local data = d.results

      for _,v in pairs(data) do
        if (v.lastpos and v.lastpos ~= "") then
          v.lastpos = getAddressAtPos(json_decode(v.lastpos))
        else
          v.lastpos = "Unknown"
        end
      end
      
      SendNUIMessage({loadCharData = true, data = data})
    end
  end)
end)

RegisterNetEvent("bms:showCharId")
AddEventHandler("bms:showCharId", function(id, charName)
  local strFmt = "[ ID: ^2" .. tostring(id) .. "^0, Name: ^3" .. charName .. "^0 ]"
  local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(id)))
  
  if (dist < 19.999) then
    TriggerEvent("chatMessage", "LOCAL", {0, 255, 0}, strFmt)
  end
end)

RegisterNetEvent("bms:char:movePlayerToSpawn")
AddEventHandler("bms:char:movePlayerToSpawn", function(spawnAreas, lastKnownPos, homePos)
  exports.characters:getSpawnArea(function(area)
    --print("Last Known: " .. exports.devtools:dump(lkp) .. "\nHouse: " .. exports.devtools:dump(hp) .. "\nSpawn Chosen: " .. area) 
    
    local ped = PlayerPedId()
    local sarea
    
    if (area <= 3) then
      sarea = spawnAreas[area].pos
    elseif (area == 4) then
      sarea = lastKnownPos.pos
    elseif (area == 5) then
      if (homePos ~= nil) then
        sarea = homePos.pos
      else
        sarea = lastKnownPos.pos
      end
    else
      sarea = spawnAreas[1].pos
    end
    
    TriggerServerEvent("bms:teleporter:teleportToPoint", 0, sarea)
  end)
end)

AddEventHandler("bms:characters:setcrimereport", function(type, data)
  local ch = chances[type]
  local pos = data.pos
  local address = data.address
  local suspect = data.suspect
  local accurateDetails = data.accurateDetails
  local override = data.override
  local ped = PlayerPedId()

  if (not pos) then    
    pos = GetEntityCoords(ped)
  end

  if (not address) then
    address = getAddressAtPos(pos)
  end

  if (not override) then
    override = { flag = false }
  else
    override = { flag = true }
  end

  if (not accurateDetails) then
    accurateDetails = "None"
  end

  if (not suspect and not override.flag) then
    local ped = PlayerPedId()
    local genderEntityModel = GetEntityModel(ped)
    local male = 1885233650
    local female = -1667301416

    if (genderEntityModel == male) then
      suspect = { gender = "male" }
    elseif (genderEntityModel == female) then
      suspect = { gender = "female" }
    else
      -- this would happen if someone is in a non mp_freemode skin (e.g. lost mc or a cop in /skin, etc)
      suspect = { gender = "unknown" }
    end
  else
    -- set to unknown if theres no details on suspect/override is true
    suspect = { gender = "unknown" }
  end

  crimeReportChanceCalc()
  
  if (crimeReportChance <= ch.perc) then
    crCooldownTimeout()
    TriggerServerEvent("bms:characters:setcrimereport", {pos = {x = pos.x, y = pos.y, z = pos.z}, address = address, desc = ch.desc, accurateDetails = accurateDetails, suspect = suspect.gender, override = override.flag })
  end
end)

RegisterNetEvent("bms:char:broadcastCharLoggedIn")
AddEventHandler("bms:char:broadcastCharLoggedIn", function(user)
  if (user) then
    TriggerEvent("bms:char:charLoggedIn", user)
  end
end)

RegisterNetEvent("bms:char:findOwnerForEntity")
AddEventHandler("bms:char:findOwnerForEntity", function()
  local ped = PlayerPedId()
  local inveh = GetVehiclePedIsIn(ped)

  if (inveh and inveh ~= 0) then
    local netid = NetworkGetNetworkIdFromEntity(inveh)

    TriggerServerEvent("bms:char:findOwnerForEntity", netid)
  end
end)

RegisterNetEvent("bms:char:timecycleTransition")
AddEventHandler("bms:char:timecycleTransition", function(modifierName, startStrength, toStrength, strengthStep, fadeIn, killOnZero)
  if (timecycleTransition.active) then return end

  timecycleTransition.curStrength = startStrength
  timecycleTransition.toStrength = toStrength
  timecycleTransition.strengthStep = strengthStep
  timecycleTransition.opIn = fadeIn
  timecycleTransition.killOnZero = killOnZero or true

  ClearTimecycleModifier()
  SetTimecycleModifierStrength(startStrength)
  SetTimecycleModifier(modifierName)
  timecycleTransition.active = true
end)

RegisterNetEvent("bms:characters:init") -- for hot restarting resource
AddEventHandler("bms:characters:init", function()
  exports.weaponshop:getWsCompHashes(function(hashes)
    comphashes = hashes
  end)
end)

AddEventHandler("onClientResourceStart", function(res)
  if (res == GetCurrentResourceName()) then
    Citizen.CreateThread(function()
      Wait(2000)

      exports.weaponshop:getWsCompHashes(function(hashes)
        comphashes = hashes
      end)
    end)
  end
end)

AddEventHandler("bms:housing:enteredHousingInstance", function()
  inHousingInstance = true
end)

AddEventHandler("bms:housing:leftHousingInstance", function()
  inHousingInstance = false
end)

AddEventHandler("playerSpawned", function()
	TriggerServerEvent("bms:char:onlogin")
end)

Citizen.CreateThread(function()
  while true do
    if (guiEnabled) then
      DisableControlAction(0, 1, true) -- LookLeftRight
      DisableControlAction(0, 2, true) -- LookUpDown
      DisableControlAction(0, 24, true) -- Attack
      DisablePlayerFiring(ped, true) -- Disable weapon firing
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
      
      HideHudAndRadarThisFrame()
    end
    
    Wait(0)
  end
end)

-- disable pistol whipping
Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    
    if (IsPedArmed(ped, 6)) then
      DisableControlAction(1, 140, true)
      DisableControlAction(1, 141, true)
      DisableControlAction(1, 142, true)
    end

    if (timecycleTransition.active) then
      if (timecycleTransition.opIn) then
        if (timecycleTransition.curStrength < timecycleTransition.toStrength) then
          timecycleTransition.curStrength = timecycleTransition.curStrength + timecycleTransition.strengthStep
          SetTimecycleModifierStrength(timecycleTransition.curStrength)
        else
          timecycleTransition.active = false
        end
      else
        if (timecycleTransition.curStrength > timecycleTransition.toStrength) then
          timecycleTransition.curStrength = timecycleTransition.curStrength - timecycleTransition.strengthStep
          SetTimecycleModifierStrength(timecycleTransition.curStrength)
        else
          timecycleTransition.active = false
        end

        if (timecycleTransition.curStrength <= 0 and timecycleTransition.killOnZero) then
          ClearTimecycleModifier()
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()

    if (not crcooldown and witnessActive) then
      if (activeCrime) then -- crime report

        local pos = GetEntityCoords(ped)

        lastped = nil
        crimeRange = 50.0

        if (not checkingForPeds) then
          checkForPedsAtCoord(pos.x, pos.y, pos.z, crimeRange)
          checkingForPeds = true
        end

        if (witnessPed) then
          filterCrimeByWitness(witnessPed, pos, pedSent)
          Wait(1000)
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  local jacking = false
  
  while true do
    Wait(1)

    local ped = PlayerPedId()

    if (IsPedJacking(ped) and not jacking) then
      jacking = true

      local veh = GetVehiclePedIsUsing(ped)
      
      if (veh) then
        local plate = GetVehicleNumberPlateText(veh)

        if (plate ~= nil) then
          if (string_match(plate, "%d%d%a%a%a%d%d")) then -- Local plate
            local hash = GetEntityModel(veh)
            local model = GetDisplayNameFromVehicleModel(hash)

            TriggerServerEvent("bms:vehicles:markStolenVeh", plate, model or "Unknown model")
            Wait(5000)
            jacking = false
          end
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  local debugShockingEvents = false
  
  while (debugShockingEvents) do
    Wait(50)

    local shockingEvents = nil
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    local carAlarm = { id = 75, active = false }
    local carPileUp = { id = 79, active = false }
    local deadBody = { id = 82, active = false }
    local explosion = { id = 86, active = false, overrideWitness = true }
    local injuredPed = { id = 95, active = false }
    local pedRunOver = { id = 101, active = false }
    local pedShot = { id = 102, active = false }
    local pouringGas = { id = 104, active = false }
    local meleeOnCar = { id = 105, active = false }
    local seenCarStolen = { id = 108, active = false }
    local seenMeleeAction = { id = 112, active = false }
    local seenPedKilled = { id = 114, active = false }
    local visibleWeapon = { id = 121, active = false }

    eventTable = { carAlarm, carPileUp, deadBody, explosion, injuredPed, pedRunOver, pedShot, pouringGas, meleeOnCar, seenCarStolen, seenMeleeAction, seenPedKilled, visibleWeapon }

    for _,v in pairs(eventTable) do
      if (IsShockingEventInSphere(v.id, pos.x, pos.y, pos.z, 150.00) and not v.active) then
        v.active = true
        print("detected shocking event %s:", v.id)
      else
        -- nada for now
      end
    end
    --[[
      75 - CEventShockingCarAlarm
      76 - CEventShockingCarChase
      77 - CEventShockingCarCrash
      78 - CEventShockingBicycleCrash
      79 - CEventShockingCarPileUp
      80 - CEventShockingCarOnCar
      81 - CEventShockingDangerousAnimal
      82 - CEventShockingDeadBody
      83 - CEventShockingDrivingOnPavement
      85 - CEventShockingEngineRevved
      86 - CEventShockingExplosion
      87 - CEventShockingFire
      88 - CEventShockingGunFight
      89 - CEventShockingGunshotFired
      90 - CEventShockingHelicopterOverhead
      91 - CEventShockingParachuterOverhead
      93 - CEventShockingHornSounded
      95 - CEventShockingInjuredPed
      96 - CEventShockingMadDriver
      97 - CEventShockingMadDriverExtreme
      99 - CEventShockingMugging
      100 - CEventShockingNonViolentWeaponAimedAt
      101 - CEventShockingPedRunOver
      102 - CEventShockingPedShot
      103 - CEventShockingPlaneFlyby
      104, 105 - CEventShockingPropertyDamage
      106 - CEventShockingRunningPed
      107 - CEventShockingRunningStampede
      108 - CEventShockingSeenCarStolen
      109 - CEventShockingSeenConfrontation
      110 - CEventShockingSeenGangFight
      111 - CEventShockingSeenInsult
      112 - CEventShockingSeenMeleeAction
      113 - CEventShockingSeenNiceCar
      114 - CEventShockingSeenPedKilled
      115 - CEventShockingVehicleTowed
      116 - CEventShockingWeaponThreat
      117 - CEventShockingWeirdPed
      118 - CEventShockingWeirdPedApproaching
      119 - CEventShockingSiren
      120 - CEventShockingStudioBomb
      121 - CEventShockingVisibleWeapon
    ]]--
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    if (not crcooldown) then
      if (#comphashes > 0) then
        local ped = PlayerPedId()

        if (IsPedShooting(ped) and IsPedArmed(ped, 4) and not inGunRange(ped) and not inHousingInstance) then
          local supressed = IsPedCurrentWeaponSilenced(ped)
          local chancemod = chances[1].perc

          if (supressed) then
            chancemod = chancemod - 0.13
          end

          math_randomseed(GetGameTimer())

          local rnd = math_random()

          if (rnd < chancemod) then
            -- fire a crime report
            local pos = GetEntityCoords(ped)
            local address = getAddressAtPos(pos)

            crCooldownTimeout()
            TriggerEvent("bms:characters:setcrimereport", 1, {pos = {x = pos.x, y = pos.y, z = pos.z}, address = address, desc = chances[1].desc, override = true})
          end
        end
      end
    end

    if (loadCamSequencing) then
      local cam = GetRenderingCam()
      local campos = GetCamCoord(cam)
      
      if (cam) then
        SetFocusArea(campos.x, campos.y, campos.z)
      end
    end
  end
end)
