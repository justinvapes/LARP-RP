-- action menu format
--  <div class="amitem" data-resource="lawenforcement" data-action="detain" data-detect="ped">Detain Suspect</div>

--[[
  Categories: 
    0 - General, 
    1 - Law Enforcement, 
    2 - Emotes, 
    3 - Vehicles, 
    4 - Employment, 
    5 - Tow, 
    6 - Stances, 
    7 - Statistics,
    8 - Props,
    9 - Car Dealership,
    10 - Group Emotes,
    11 - EMS
    12 - DOC
    13 - Prop Emotes
    14 - Expressions
]]
local table_insert = table.insert
local showMenu = false
local showDialog = false
local lastDetPed = -1
local lastDetVeh
local lastDetCharName
local inputText = false
local canShowMenu = true
local zActionMenuToggle = false
local loggedIn = false

function getVehicleInDirection(coordFrom, coordTo, ignore)
  local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, ignore, 0)
  local _, _, _, _, vehicle = GetRaycastResult(rayHandle)
  return vehicle
end

function getPedInDirection(coordFrom, coordTo, ignore)
  local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 12, ignore, 0)
  local _, _, _, _, ped = GetRaycastResult(rayHandle)
  return ped
end

function enableUi(toggle)
  SetNuiFocus(toggle, toggle)
  showMenu = toggle
  
  if (showMenu) then
    SendNUIMessage({
      showMenu = true
    })
  else
    SendNUIMessage({
      hideMenu = true
    })
  end
end

function enableDialog(toggle)
  SetNuiFocus(toggle, toggle)
  showDialog = toggle
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

RegisterNetEvent("bms:actionmenu:initializemenu")
AddEventHandler("bms:actionmenu:initializemenu", function()
  addCategory("General", 0)
  addCategory("Vehicles", 3)
  addCategory("Employment", 4)
  addAction("characters", "showid", "none", "Show ID", 0, "")
  addAction("characters", "givemoney", "ped", "Give Money", 0, "")
  addAction("characters", "givedirtymoney", "ped", "Give Dirty Money", 0, "")
  addAction("characters", "robplayer", "ped", "Rob Player", 0, "")
  addAction("characters", "takephone", "ped", "Take Player Phone", 0, "")
  addAction("characters", "carryplayer", "ped", "Carry Player", 0, "")
  addAction("characters", "dragthem", "ped", "Escort Ziptied Player", 0, "")
  addAction("characters", "getintrunk", "ped", "Get in/out of Trunk", 0, "")
  addAction("characters", "putintrunk", "ped", "Force into Trunk", 0, "")
  addAction("characters", "takefromtrunk", "ped", "Force out of Trunk", 0, "")
  addAction("characters", "voice", "none", "Voice Default", 0, 0)
  addAction("characters", "voice", "none", "Voice Whisper", 0, 1)
  addAction("characters", "voice", "none", "Voice Shout", 0, 2)
  addAction("characters", "togglemask", "none", "Toggle Mask", 0, "")
  addAction("characters", "toggleglasses", "none", "Toggle Glasses", 0, "")
  addAction("characters", "togglehelmet", "none", "Toggle Helmet", 0, "")
  addAction("csrp_gamemode", "togglecompass", "none", "Toggle Compass", 0, "")
  addAction("diving", "unequipscuba", "none", "Unequip Scuba", 0, "")

  loggedIn = true
end)

function addAction(resname, action, detecttype, dispname, category, extra, extra2)
  SendNUIMessage({addAction = true, data = {resname = resname, action = action, detecttype = detecttype, dispname = dispname, extra = extra, extra2 = extra2}, category = category})
end

function addCategory(catname, catid, hidden)
  if (catname and catid) then
    SendNUIMessage({addCategory = true, catname = catname, catid = catid, hide = hidden or false})
  end
end

function removeCategory(catname)
  if (catname) then
    SendNUIMessage({removeCategory = true, catname = catname})
  end
end

function hideCategory(catname)
  if (catname) then
    SendNUIMessage({hideCategory = true, catname = catname})
  end
end

function showCategory(catname)
  if (catname) then
    SendNUIMessage({showCategory = true, catname = catname})
  end
end

function removeAction(dispname, catid)
  if (dispname) then
    SendNUIMessage({removeAction = true, dispname = dispname, catid = catid})
  end
end

function changeAction(dispname, changeto)
  if (dispname and changeto) then
    SendNUIMessage({changeAction = true, dispname = dispname, changeto = changeto})
  end
end

function showMenuTimeout()
  SetTimeout(1000, function()
    canShowMenu = true
  end)
end

function toggleZActionMenu(toggle)
  zActionMenuToggle = toggle
end

function toggleBlockMenu(block, forceClose)
  canShowMenu = not block

  if (forceClose) then
    SendNUIMessage({hideMenu = true})
  end
end

RegisterNetEvent("bms:actionmenu:removeCategory")
AddEventHandler("bms:actionmenu:removeCategory", function(catname)
  if (catname) then
    SendNUIMessage({removeCategory = true, catname = catname})
  end
end)

RegisterNetEvent("bms:devtools:fixgui")
AddEventHandler("bms:devtools:fixgui", function()
  SetNuiFocus(false, false)
  SendNUIMessage({hideMenu = true})
  showMenu = false
  showDialog = false
  TriggerEvent("bms:inv:closeInventoryProper")
end)

RegisterNUICallback("selectAction", function(data, cb)
  local action = data.action
  local dettype = data.detect -- detecttype can be none, ped, vehicle, all
  local extra = data.extra
  local lazyaction
  local lazyparam
  local showInput = 0
  
  local ped = PlayerPedId()
  local drvveh = GetVehiclePedIsIn(ped, false)
  
  if (action == "duty") then
    TriggerServerEvent("bms:action:lawenf:duty", extra)
  elseif (action == "showid") then
    TriggerServerEvent("bms:action:showid")
 -- elseif (action == "cuff") then  
    --TriggerServerEvent("bms:cuff:setHandcuffsOnPed", lastDetPed, true)
  --elseif (action == "softcuff") then
--    TriggerServerEvent("bms:cuff:setSoftHandcuffsOnPed", lastDetPed, true)
  --elseif (action == "uncuff") then
    --TriggerServerEvent("bms:cuff:setHandcuffsOnPed", lastDetPed, false)
  elseif (action == "escort") then
    if (extra == "start") then
      exports.lawenforcement:setEscorting(true, lastDetPed)
      TriggerServerEvent("bms:lawenf:notifyAttachEntity", lastDetPed)
    elseif (extra == "end") then
      exports.lawenforcement:setEscorting(false, lastDetPed)
      TriggerServerEvent("bms:lawenf:notifyDetachEntity", lastDetPed)
    end
  elseif (action == "emote") then
    if (extra) then
      exports.emotes:doEmoteById(extra)
    end
  elseif (action == "stance") then
    if (extra) then
      exports.emotes:doStanceById(extra)
    end
  elseif (action == "prop") then
    if (extra) then
      exports.emotes:getProp(extra)
    end
  elseif (action == "propemote") then
    if (extra) then
      TriggerServerEvent("bms:emotes:doPropEmote", extra)
    end
  elseif (action == "expressions") then
    if (extra) then
      exports.emotes:doExpressionById(extra)
    end
  elseif (action == "groupanim") then
    TriggerEvent("bms:emotes:actionDoGroupEmote", lastDetPed, extra)
  elseif (action == "runplate") then
    TriggerEvent("bms:lawenf:runPlate")
  elseif (action == "scuba") then
    TriggerEvent("jobs:diving:toggleCopScuba")
  elseif (action == "unequipscuba") then
    TriggerEvent("jobs:diving:expireScuba")
  elseif (action == "search") then
    TriggerEvent("bms:lawenf:search")
  elseif (action == "searchveh") then
    TriggerEvent("bms:lawenf:searchvehicle")
  elseif (action == "removeweapons") then
    TriggerEvent("bms:lawenf:removeweapons")
  elseif (action == "removecontraveh") then
    TriggerEvent("bms:lawenf:removecontraveh")
  elseif (action == "seat") then
    TriggerServerEvent("bms:lawenf:notifyDetachEntity", lastDetPed)
    TriggerServerEvent("bms:lawenf:detainPlayer", lastDetPed)
  elseif (action == "unseat") then
    TriggerServerEvent("bms:lawenf:removeSelfFromCar", lastDetPed)
  --elseif (action == "prison") then
    --TriggerEvent("bms:lawenf:openMdcCharge")
  elseif (action == "mdccharge") then
    lazyaction = "bms:lawenf:openMdcCharge"
  elseif (action == "mdcsearch") then
    lazyaction = "bms:lawenf:openMdcFrontend"
  elseif (action == "engine") then
    if (drvveh) then
      TriggerEvent("bms:vehicles:vehcontrol", 1)
    end
  elseif (action == "hood") then
    if (drvveh) then
      TriggerEvent("bms:vehicles:vehcontrol", 2)
    end
  elseif (action == "trunk") then
    if (drvveh) then
      TriggerEvent("bms:vehicles:vehcontrol", 3)
    end
  elseif (action == "opendoor") then
    TriggerEvent("bms:vehicles:opendoor", extra)
  elseif (action == "toggleneon") then
    TriggerEvent("bms:vehicles:toggleneon")
  elseif (action == "givemoney") then
    if (lastDetPed > 0) then
      showInput = 1
    else
      exports.pnotify:SendNotification({text = "No players found nearby."})
    end
  elseif (action == "givedirtymoney") then
    if (lastDetPed > 0) then
      showInput = 2
    else
      exports.pnotify:SendNotification({text = "No players found nearby."})
    end
  elseif (action == "radar") then
    TriggerEvent("bms:lawenf:setRadar")
  elseif (action == "marktow") then
    TriggerEvent("bms:lawenf:markTow", lastDetVeh)
  elseif (action == "impoundvehicle") then
    TriggerEvent("bms:lawenf:impoundvehicle", lastDetVeh)
  elseif (action == "revive") then
    TriggerEvent("bms:ems:revive")
  elseif (action == "heal") then
    TriggerEvent("bms:ems:heal")
  elseif (action == "cpr") then
    TriggerEvent("bms:ems:performCpr", lastDetPed)
  elseif (action == "glucagon") then
    TriggerServerEvent("bms:ems:administerdrug", 1, lastDetPed)
  elseif (action == "saline") then
    TriggerServerEvent("bms:ems:administerdrug", 2, lastDetPed)
  elseif (action == "emsduty") then
    TriggerServerEvent("bms:ems:setActiveDuty", extra)
  elseif (action == "robplayer") then
    TriggerEvent("bms:csrp_gamemode:robPlayer", lastDetPed)
  elseif (action == "takephone") then
    TriggerEvent("bms:comms:phoneStore:takeOtherPlayerPhone", lastDetPed)
  elseif (action == "carryplayer") then
    TriggerEvent("bms:characters:carryPed:amToggle", lastDetPed)
  elseif (action == "towduty") then
    TriggerEvent("bms:jobs:tow:stationProxCheck", extra)
  elseif (action == "towvehicle") then
    TriggerEvent("bms:jobs:tow:towvehicle", lastDetVeh, extra)
  elseif (action == "unloadvehicle") then
    TriggerEvent("bms:jobs:tow:unloadvehicle", lastDetVeh, extra)
  elseif (action == "showphone") then
    lazyaction = "bms:comms:openPhone"
  elseif (action == "keyring") then
    lazyparam = lastDetPed
    lazyaction = "bms:housing:showKeyRing"
  elseif (action == "voice") then
    TriggerEvent("bms:csrp_gamemode:setVoice", extra)
  elseif (action == "mdcwarrants") then
    lazyaction = "bms:lawenf:showWarrantsMdc"
  elseif (action == "gsrtest") then
    TriggerServerEvent("bms:lawenf:runGsrTest", lastDetPed)
  elseif (action == "baltest") then
    TriggerServerEvent("bms:lawenf:runBalTest", lastDetPed)
  elseif (action == "togglemask") then
    TriggerEvent("bms:charcreator:mask")
  elseif (action == "toggleglasses") then
    TriggerEvent("bms:charcreator:toggleglasses")
  elseif (action == "togglehelmet") then
    TriggerEvent("bms:charcreator:togglehelmet")
  elseif (action == "showbadge") then
    TriggerEvent("bms:lawenf:showbadge")
  elseif (action == "togglecompass") then
    TriggerEvent("bms:hud:toggleCompass")
  elseif (action == "monitor") then
    TriggerServerEvent("bms:lawenf:anklebracelet", lastDetPed)
  elseif (action == "fingerprint") then
    TriggerServerEvent("bms:lawenf:fingerPrint", lastDetPed)
  elseif (action == "addroadblock") then
    TriggerEvent("bms:lawenforcement:rb:addroadblock", lastDetVeh)
  elseif (action == "remroadblock") then
    TriggerEvent("bms:lawenforcement:rb:remroadblock", lastDetVeh)
  elseif (action == "addpoliceline") then
    TriggerEvent("bms:lawenforcement:rb:addPoliceLine")
  elseif (action == "rempoliceline") then
    TriggerEvent("bms:lawenforcement:rb:remPoliceLine")
  elseif (action == "inspectwounds") then
    TriggerServerEvent("bms:ems:inspectWounds", lastDetPed)
  elseif (action == "stockmarket") then
    lazyaction = "bms:stockmarket:openstockmarket"
  elseif (action == "gametips") then
    lazyaction = "bms:management:showgametips"
  elseif (action == "wsaction") then
    TriggerServerEvent("bms:services:hungersystem:wsactionTrigger", extra)
  elseif (action == "skills") then
    TriggerEvent("bms:crafting:toggleSkills")
  elseif (action == "fishinglb") then
    TriggerEvent("bms:jobs:fishing:toggleLeaderboard")
  elseif (action == "getforensicsbag") then
    TriggerEvent("bms:forensics:getForensicsBag", lastDetVeh)
  elseif (action == "seedinventory") then
    lazyaction = "bms:jobs:seedinventory:showSeedInventory"
  elseif (action == "sellbags") then
    TriggerEvent("bms:jobs:sd:activateStreetDeal", "bags")
  elseif (action == "getintrunk") then
    TriggerEvent("bms:zipties:getInTrunk")
  elseif (action == "putintrunk") then
    TriggerEvent("bms:zipties:putInTrunk")
  elseif (action == "takefromtrunk") then
    TriggerEvent("bms:zipties:takeFromTrunk")
  elseif (action == "dragthem") then
    TriggerEvent("bms:zipties:escortCiv")
  elseif (action == "hireemp") then
    TriggerEvent("bms:cardealership:hireEmployee", lastDetPed)
  elseif (action == "hiremec") then
    TriggerEvent("bms:cardealership:hireMecEmployee", lastDetPed)
  elseif (action == "hirepartner") then
    TriggerEvent("bms:cardealership:hirePartner", lastDetPed)
  elseif (action == "removemask") then
    TriggerServerEvent("bms:lawenf:removePlayerMask", lastDetPed)
  elseif (action == "removevest") then
    TriggerServerEvent("bms:lawenf:removePlayerVest", lastDetPed)
  elseif (action == "docduty") then
    TriggerEvent("bms:lawenf:docDutySwitch")
  elseif (action == "hiremech") then
    TriggerEvent("bms:businesses:mech:hireMechanic", lastDetPed)
  elseif (action == "newscam") then
    TriggerServerEvent("bms:jobs:news:getNewsCam")
  elseif (action == "newsmic") then
    TriggerServerEvent("bms:jobs:news:getNewsMic")
  elseif (action == "newsboommic") then
    TriggerServerEvent("bms:jobs:news:getNewsBoomMic")
  end
  
  enableUi(false)
  
  if (lazyaction) then
    if (lazyparam) then
      TriggerEvent(lazyaction, lazyparam)
    else
      TriggerEvent(lazyaction)
    end
  else
    if (showInput == 1 or showInput == 2) then
      exports.management:TriggerServerCallback("bms:characters:getClosestPlayerName", function(data)
        if (data) then
          if (data.success and data.charname) then
            print(data.charname)
            if (showInput == 1) then
              enableDialog(true)              
              SendNUIMessage({
                showInputDialog = true,
                interactText = string.format("Interacting with %s", data.charname),
                actionText = "Enter whole amount below.",
                buttonText = "Send Money",
                lastPedId = lastDetPed,
                inputActionId = 1
              })
            elseif (showInput == 2) then
              enableDialog(true)              
              SendNUIMessage({
                showInputDialog = true,
                interactText = string.format("Interacting with %s", data.charname),
                actionText = "Enter whole amount below.",
                buttonText = "Send Dirty Money",
                lastPedId = lastDetPed,
                inputActionId = 2
              })
            end
          elseif (data.msg) then
            exports.pnotify:SendNotification({text = data.msg})
          end
        end
      end)
    end
  end
  
  lastDetPed = -1
  lastDetVeh = nil
end)

RegisterNUICallback("inputDialogResult", function(data, cb)
  local actionid = data.inputActionId
  local inputval = data.inputtext
  local pedid = data.lastPedId
  
  enableDialog(false)
  
  if (actionid == 1) then -- givemoney result
    local amount = tonumber(inputval)
    if (amount ~= nil and math.floor(amount) == amount) then
      
      TriggerServerEvent("bms:char:giveMoneyToCharacter", pedid, amount)
    else
      exports.pnotify:SendNotification({text = "You must enter a non-decimal amount in the input box."})
    end
  elseif (actionid == 2) then -- givedirtymoney result
    local amount = tonumber(inputval)
    
    if (amount == 0) then
      exports.pnotify:SendNotification({text = "You must enter a positive amount in the input box."})
      return
    end

    if (amount ~= nil and math.floor(amount) == amount) then  
      TriggerServerEvent("bms:char:giveDirtyMoneyToCharacter", pedid, amount)
    else
      exports.pnotify:SendNotification({text = "You must enter a non-decimal amount in the input box."})
    end
  end
end)

RegisterNUICallback("escape", function(data, cb)
  enableUi(false)
end)

RegisterNUICallback("playsound", function(data, cb)
  if (data) then
    PlaySoundFrontend(-1, data.name, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
  end
end)

RegisterNUICallback("debug", function(data, cb)
  TriggerServerEvent("bms:serverprint", data)
end)

RegisterNetEvent("bms:actionmenu:getPlayerCharName")
AddEventHandler("bms:actionmenu:getPlayerCharName", function(charname)
  lastDetCharName = charname
end)

Citizen.CreateThread(function()
  while not loggedIn do
    Wait(1000)
  end

  while true do
    Wait(1)

    local ped = PlayerPedId()
    
    if (showMenu or showDialog) then
      DisableControlAction(0, 1, true) -- LookLeftRight
      DisableControlAction(0, 2, true) -- LookUpDown
      DisableControlAction(0, 24, true) -- Attack
      DisablePlayerFiring(ped, true) -- Disable weapon firing
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
      --HideHudAndRadarThisFrame()
      --DisableFirstPersonCamThisFrame()
      --DisableVehicleFirstPersonCamThisFrame()
    end
    
    local iskb = GetLastInputMethod(2)
    
    -- 19 - Left Alt
    local key = 19

    if (zActionMenuToggle) then
      key = 48
    end

    if (iskb and (IsControlJustReleased(1, key) or IsDisabledControlJustReleased(1, key)) and canShowMenu and not showMenu) then
      canShowMenu = false
      showMenuTimeout()

      local clplayer, cldist = getClosestPlayer()
      local sid = GetPlayerServerId(clplayer)
      local pos = GetEntityCoords(ped)
      local nped = GetPlayerPed(sid)
      
      if (clplayer and cldist < 1.5) then
        if (sid > 0) then
          TriggerServerEvent("bms:char:getPlayerCharName", sid)
          lastDetPed = sid
        end
      end
      
      local offset = GetOffsetFromEntityInWorldCoords(ped, 0, 5.0, 0)
      lastDetVeh = getVehicleInDirection(pos, offset, ped)
      if (lastDetVeh == 0 or lastDetVeh == nil) then
        lastDetVeh = GetClosestVehicle(pos.x, pos.y, pos.z, 3.0, 0, 70)
      end
      
      enableUi(true)
    end
  end
end)
