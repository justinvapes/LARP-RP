local table_insert = table.insert
local table_remove = table.remove
local table_pack = table.pack
local string_format = string.format
local string_len = string.len
local string_sub = string.sub
local json_encode = json.encode
local json_decode = json.decode
local phoneNumber = 0
local emailAddress
local showPhone = false
local blips911 = {}
local textsid = 0
local gpstest = false
local gpsTrackedEnt
local silentmode = false
local hidenotifications = false
local tbarkposition = "bottomRight"

function enableUi(toggle)
  SetNuiFocus(toggle, toggle)
  showPhone = toggle
  
  if (showPhone) then
    SendNUIMessage({showPhone = true})
  else
    SendNUIMessage({hidePhone = true})
  end
end

function add911Blip(data)
  if (data) then
    local pos = data.position
    local blip = AddBlipForCoord(pos.x, pos.y, pos.z)

    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 69)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("911 Emergency")
    EndTextCommandSetBlipName(blip)

    local nineblip = {call = data, blip = blip}

    table_insert(blips911, nineblip)
  end
end

function clear911Calls()
  for _,v in pairs(blips911) do
    RemoveBlip(v.blip)
  end

  blips911 = {}
end

function gpsTrackEntity(ent)
  if (ent) then
    gpsTrackedEnt = ent
    SendNUIMessage({toggleGpsPin = true, toggle = true})
  end
end

function gpsUntrack()
  gpsTrackedEnt = nil
  SendNUIMessage({toggleGpsPin = true, toggle = false})
end

function getPhoneStrFromNum(id)
  if (id) then
    id = tostring(id)
    local ac = id:sub(1, 3)
    local pre = id:sub(4, 6)
    local suf = id:sub(7, 10)

    return string_format("%s-%s-%s", ac, pre, suf)
  end
end

RegisterNetEvent("bms:comms:pnotify")
AddEventHandler("bms:comms:pnotify", function(options)
  exports.pnotify:SendNotification(options)
end)

RegisterNetEvent("bms:comms:setPhoneDetails")
AddEventHandler("bms:comms:setPhoneDetails", function(data)
  phoneNumber = data.phoneNumber
  emailAddress = data.emailAddress
  SendNUIMessage({setPnDisplay = true, charName = data.charName, phoneNumber = getPhoneStrFromNum(phoneNumber), emailAddress = emailAddress})
  
  if (data.contacts) then
    SendNUIMessage({loadContacts = true, contacts = data.contacts})
  end
end)

RegisterNetEvent("bms:comms:radioMessage")
AddEventHandler("bms:comms:radioMessage", function(message, char)
  if (message) then
    TriggerServerEvent("bms:comms:getMyGroup", message, char)
  end
end)

RegisterNetEvent("bms:comms:getMyGroup")
AddEventHandler("bms:comms:getMyGroup", function(group, message, char)
  if (group == "LawEnf") then
    TriggerEvent("chatMessage", string_format("[Radio - %s]", group), {255, 0, 0}, string_format("(%s) | %s", char, message))
  end
end)

RegisterNetEvent("bms:comms:openPhone")
AddEventHandler("bms:comms:openPhone", function()
  enableUi(true)
end)

RegisterNetEvent("bms:comms:phone:addContact")
AddEventHandler("bms:comms:phone:addContact", function(name)
  if (name and name ~= -1) then
    exports.pnotify:SendNotification({text = "Contact Added to your phone.", layout = "bottomLeft"})
  end
  
  SendNUIMessage({
    addContact = true,
    name = name
  })
end)

RegisterNetEvent("bms:comms:phone:addTextMessage")
AddEventHandler("bms:comms:phone:addTextMessage", function(fromchar, msg)
  -- Do not check for silent/notif hide.  I think system sent texts should push notify either way.
  PlaySoundFrontend(-1, "MP_5_SECOND_TIMER", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
  
  local fc = ""

  if (string_len(msg) >= 128) then
    fc = string_sub(msg, 1, 128) .. " ...(more)"
  else
    fc = msg
  end

  exports.pnotify:SendNotification({text = string_format("New text message from <font color='skyblue'>%s</font><br/> -> <font color='gray'>%s</font>", fromchar, fc), layout = "bottomLeft"})
  TriggerEvent("chatMessage", "", {0, 255, 0}, "Text Message Received.")
  
  SendNUIMessage({
    addTextMessage = true,
    fromChar = fromchar,
    message = msg
  })
end)

RegisterNetEvent("bms:comms:addPhoneNotify")
AddEventHandler("bms:comms:addPhoneNotify", function(text)
  SendNUIMessage({setNotify = true, text = text})
end)

RegisterNetEvent("bms:comms:playSound")
AddEventHandler("bms:comms:playSound", function()
  PlaySoundFrontend(-1, "MP_5_SECOND_TIMER", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)  
end)

--[[local soundid = -1

RegisterNetEvent("bms:comms:playSoundEntityAllClients")
AddEventHandler("bms:comms:playSoundEntityAllClients", function(data)
  if (data) then
    if (data.pid > -1) then
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local rped = GetPlayerPed(GetPlayerFromServerId(data.pid))
      local rpos = GetEntityCoords(rped)
      local dist = Vdist(pos.x, pos.y, pos.z, rpos.x, rpos.y, rpos.z)

      if (ped ~= rped) then
        if (dist < 30 and ped ~= rped) then
          print(rpos.x)

          if (soundid > -1) then
            ReleaseSoundId(soundid)
          end

          soundid = GetSoundId()

          PlaySoundFromCoord(soundid, data.sound, rpos.x, rpos.y, rpos.z, data.audioref, 0, 20.0, 0)
        end
        -- PlaySoundFromEntity(-1,"Bomb_Disarmed",PlayerPedId(),"GTAO_Speed_Convoy_Soundset")
      end
    end
  end
end)]]

RegisterNetEvent("bms:comms:playSoundTest")
AddEventHandler("bms:comms:playSoundTest", function(sound, audioref)
  if (sound) then
    local ped = PlayerPedId()

    PlaySoundFromEntity(-1, sound, ped, audioref)
  end
end)

--[[RegisterNUICallback("sendText", function(data, cb) -- deprecated
  local char = data.charname
  local msg = data.message
  
  if (msg) then
    exports.pnotify:SendNotification({text = "Text message sent to <font color='green'>" .. char .. "</font>", layout = "bottomLeft"})
    TriggerServerEvent("bms:comms:sendMessage", char, msg)
  end
  
  
end)]]

RegisterNUICallback("saveContacts", function(data, cb)
  if (data.contacts) then
    TriggerServerEvent("bms:char:saveContacts", data.contacts)
  end
end)

RegisterNUICallback("tryAddContact", function(data, cb)
  local name = data.contact

  if (name) then
    TriggerServerEvent("bms:comms:phone:tryAddContact", name)
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

RegisterNUICallback("bms:comms:e911request", function(data)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local street = table_pack(GetStreetNameAtCoord(pos.x, pos.y, pos.z))
  local address

  address = GetStreetNameFromHashKey(street[1])
  
  if (street[2] ~= nil and street[2] ~= "") then
    local street2 = GetStreetNameFromHashKey(street[2])

    if (street2 ~= "") then
      address = address .. " and " .. street2
    end
  end

  TriggerServerEvent("bms:comms:e911request", {emdetails = data.emdetails, street = address, pos = {x = pos.x, y = pos.y, z = pos.z}})
end)

RegisterNUICallback("bms:comms:e911attemptCancel", function(data)
  exports.management:TriggerServerCallback("bms:comms:clearActive911Call", function(data)
    if (data) then
      if (data.msg) then
        SendNUIMessage({updateCancelMessage = true, msg = data.msg, cleared = data.cleared})
      end
    end
  end)
end)

RegisterNUICallback("bms:comms:e911addmessage", function(data)
  if (data) then
    TriggerServerEvent("bms:comms:e911addmessage", data)
  end
end)

RegisterNUICallback("bms:comms:e911remove", function(data)
  if (data) then
    TriggerServerEvent("bms:comms:e911remove", data)
  end
end)

RegisterNUICallback("bms:comms:e911doping", function(data)
  if (data) then
    local id = data.id

    for _,v in pairs(blips911) do
      local call = v.call

      if (call.callid == id) then
        local loc = call.position

        SetNewWaypoint(loc.x, loc.y)
        exports.pnotify:SendNotification({text = "<span style='color: skyblue;'>Waypoint</span> has been set to this <span style='color:red;'>911 call</span>."})
        break
      end
    end
  end
end)

RegisterNUICallback("bms:comms:e911enroute", function(data)
  if (data) then
    TriggerServerEvent("bms:comms:e911enroute", data)
  end
end)

RegisterNetEvent("bms:comms:e911addnew")
AddEventHandler("bms:comms:e911addnew", function(data)
  if (data) then
    SendNUIMessage({e911addnew = true, call = data})
    exports.pnotify:SendNotification({text = "Incoming <span style='color: red;'>911 call..</span>"})
    TriggerEvent("chatMessage", "[911 Dispatch]", {255, 0, 0}, string_format("Incoming 911 Call...\n\t[Ping Details | Number: %s, Location: %s]\n\t[Message: %s]", data.number, data.location, data.chat[1].text))
    add911Blip(data) -- new blips will stay on the map until the call is cleared by responding officers/ems or the player either 1) respawns or 2) disconnects
  end
end)

RegisterNetEvent("bms:comms:addAll911Calls")
AddEventHandler("bms:comms:addAll911Calls", function(e911Calls)
  if (not e911Calls) then return end

  SendNUIMessage({e911AddAll = true, calls = e911Calls})

  for _, call in pairs(e911Calls) do
    add911Blip(call)
  end
end)

RegisterNetEvent("bms:comms:e911addmessage")
AddEventHandler("bms:comms:e911addmessage", function(data)
  if (data) then
    SendNUIMessage({e911addmessage = true, call = data})
  end
end)

RegisterNetEvent("bms:lawenf:setActiveDuty")
AddEventHandler("bms:lawenf:setActiveDuty", function(_, _, tog)
  SendNUIMessage({setIsLeo = true, toggle = tog})
end)

RegisterNetEvent("bms:ems:setActiveDuty")
AddEventHandler("bms:ems:setActiveDuty", function(tog)
  SendNUIMessage({setIsEms = true, toggle = tog})
end)

RegisterNetEvent("bms:comms:leoToggleDispatchHud")
AddEventHandler("bms:comms:leoToggleDispatchHud", function(tog)
  SendNUIMessage({setIsLeo = true, toggle = tog})
end)

RegisterNetEvent("bms:comms:emsToggleDispatchHud")
AddEventHandler("bms:comms:emsToggleDispatchHud", function(tog)
  SendNUIMessage({setIsEms = true, toggle = tog})
end)

RegisterNetEvent("bms:comms:e911remove")
AddEventHandler("bms:comms:e911remove", function(data)
  if (data) then
    local id = data.id
    local remidx = 0

    for i,v in ipairs(blips911) do
      if (v.call.callid == id) then
        RemoveBlip(v.blip)
        remidx = i
      end
    end

    if (remidx > 0) then
      table_remove(blips911, remidx)
    end
    
    SendNUIMessage({e911remove = true, id = id})
  end
end)

RegisterNetEvent("bms:comms:e911enroute")
AddEventHandler("bms:comms:e911enroute", function(data)
  if (data) then
    SendNUIMessage({toggleEnroute = true, data = data})
  end
end)

RegisterNetEvent("sbc:sendss")
AddEventHandler("sbc:sendss", function(data)
  local d = data.ssd
  local f = data.filename

  exports.sbc:requestScreenshotUpload(d, "files", function(sdata)
    local resp = json_decode(sdata)
    local error = sdata.error
    
    if (resp.message) then
      TriggerServerEvent("sbc:sendss", {error = error, msg = resp.message, s = data.s})
    end
  end)
end)

RegisterNetEvent("bms:comms:addTweet")
AddEventHandler("bms:comms:addTweet", function(data)
  if (data) then
    SendNUIMessage({addTweet = true, msg = data.msg, sender = data.sender})
  end
end)

RegisterNetEvent("bms:comms:loadPhoneSettings")
AddEventHandler("bms:comms:loadPhoneSettings", function(data)
  SendNUIMessage({loadPhoneSettings = true, settings = data.settings})

  silentmode = data.settings.silentmode
  tbarkposition = data.settings.tbarkposition or "bottomRight"
end)

RegisterNetEvent("bms:comms:gpstest")
AddEventHandler("bms:comms:gpstest", function()
  gpstest = not gpstest
  SendNUIMessage({toggleGpsPin = true, toggle = gpstest})
end)

RegisterNetEvent("bms:comms:unblockMechanicReq")
AddEventHandler("bms:comms:unblockMechanicReq", function()
  SendNUIMessage({unblockTowReq = true})
end)

AddEventHandler("bms:comms:updateVehiclePhoneData", function(data)
  if (data) then
    SendNUIMessage({updateCarmaxData = true, price = data.price, modinfo = data.modinfo, model = data.model})
  end
end)

AddEventHandler("bms:comms:unblockVehPurchase", function()
  SendNUIMessage({unblockVehPurchase = true})
end)

RegisterNUICallback("bms:comms:paypalsend", function(data)
  exports.management:TriggerServerCallback("bms:comms:paypalsend", function(data)
    local success = data.success

    if (success) then
      SendNUIMessage({setNotify = true, text = string_format("$%s was sent successfully.", data.amount)})

      exports.management:TriggerServerCallback("bms:comms:paypalgetbalandhist", function(data)
        if (data) then
          SendNUIMessage({setPaypalBalance = true, balance = data.balance})
          SendNUIMessage({setPaypalTransHistory = true, transfers = data.transfers})
        end
      end)
    else
      SendNUIMessage({setNotify = true, text = data.msg})
    end

    SendNUIMessage({unblockPaypal = true})
  end, data)
end)

RegisterNUICallback("bms:comms:paypalgetbal", function(data)
  exports.management:TriggerServerCallback("bms:comms:paypalgetbalandhist", function(data)
    if (data) then
      SendNUIMessage({setPaypalBalance = true, balance = data.balance})
      SendNUIMessage({setPaypalTransHistory = true, transfers = data.transfers})
    end
  end)
end)

RegisterNUICallback("bms:comms:sendTweet", function(data)
  if (data and data.msg) then
    TriggerServerEvent("bms:comms:sendTweet", data)
  end
end)

RegisterNUICallback("bms:comms:phoneSettingChanged", function(data)  
  if (data) then
    local tname = data.tname
    local tvalue = data.tvalue
    local sname = data.sname
    local svalue = data.svalue
    local hname = data.hname
    local hvalue = data.hvalue
    local bname = data.bname
    local bvalue = data.bvalue
    local tbpname = data.tbpname
    local tbpvalue = data.tbpvalue
    local settingsToBeChanged = {}
    local iter = 0

    if (tname) then
      iter = iter + 1
      settingsToBeChanged[iter] = {name = tname, val = tvalue}
    end

    if (sname) then
      iter = iter + 1
      settingsToBeChanged[iter] = {name = sname, val = svalue}
      silentmode = svalue
    end

    if (hname) then
      iter = iter + 1
      settingsToBeChanged[iter] = {name = hname, val = hvalue}
      hidenotifications = hvalue
    end

    if (bname) then
      iter = iter + 1
      settingsToBeChanged[iter] = {name = bname, val = bvalue}
    end

    if (tbpname) then
      iter = iter + 1
      settingsToBeChanged[iter] = {name = tbpname, val = tbpvalue}
      tbarkposition = tbpvalue
    end

    if (#settingsToBeChanged > 0) then
      TriggerServerEvent("bms:comms:savePhoneSetting", settingsToBeChanged)
    end
  end
end)

RegisterNUICallback("bms:comms:showTwitterBark", function(data)
  if (data) then
    exports.pnotify:SendNotification({text = string_format("<span style='color: skyblue'>%s</span><br/>%s", data.sender, data.msg), theme = "tbark", layout = tbarkposition or "bottomRight", timeout = 8000})
  end
end)

RegisterNUICallback("bms:comms:activateLojack", function(data)
  if (data and data.plate) then
    exports.management:TriggerServerCallback("bms:comms:lojackPrecheck", function(cn)
      if (cn) then
        exports.vehicles:isVehiclePlayerOwnedByPlate(data.plate, cn, function(owned)
          if (owned) then
            exports.vehicles:getNetIdForPersonalVehicleByPlate(data.plate, function(netid)
              if (netid ~= 0) then
                local ent = NetToVeh(netid)

                Wait(500)

                if (ent and DoesEntityExist(ent)) then
                  gpsTrackEntity(ent)
                end
              else
                print(string_format("bms:comms:activateLojack >> netid was 0 for plate [%s]", data.plate))
                SendNUIMessage({setNotify = true, text = "The vehicle could not be located."})
              end
            end)
          else
            print("vehicle not owned by local player")
          end
        end)
      else
        print("pcdata.cn was nil")
      end
    end)
  else
    SendNUIMessage({setNotify = true, text = "The vehicle could not be located."})
  end
end)

RegisterNUICallback("bms:comms:deactivateLojack", function()
  gpsUntrack()
end)

RegisterNUICallback("bms:comms:contactMechanic", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local spos = {x = pos.x, y = pos.y, z = pos.z}
  local street = table_pack(GetStreetNameAtCoord(pos.x, pos.y, pos.z))
  local address

  address = GetStreetNameFromHashKey(street[1])
  
  if (street[2] ~= nil and street[2] ~= "") then
    local street2 = GetStreetNameFromHashKey(street[2])

    if (street2 ~= "") then
      address = address .. " and " .. street2
    end
  end

  TriggerServerEvent("bms:tow:contactMechanic", {pos = spos, address = address or "Unknown"})
end)

RegisterNUICallback("bms:comms:carmaxPurchaseVehicle", function()
  TriggerEvent("bms:cardealer:carmaxPurchaseVehicle")
end)

RegisterNUICallback("bms:comms:clearCarDealerLogs", function()
  TriggerServerEvent("bms:cardealer:clearDealerLogs")
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)
    
    if (showPhone) then
      local ped = PlayerPedId()
      
      DisableControlAction(0, 1, true) -- LookLeftRight
      DisableControlAction(0, 2, true) -- LookUpDown
      DisableControlAction(0, 24, true) -- Attack
      DisablePlayerFiring(ped, true) -- Disable weapon firing
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(100)

    if (gpstest) then
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)

      SendNUIMessage({moveGpsPin = true, coords = {x = pos.x, y = pos.y}})
    end

    if (gpsTrackedEnt) then
      local pos = GetEntityCoords(gpsTrackedEnt)

      SendNUIMessage({moveGpsPin = true, coords = {x = pos.x, y = pos.y}})
    end
  end
end)

Citizen.CreateThread(function() -- GPS check for deletion or dead network id of tracked entity
  while true do
    Wait(500)

    if (gpsTrackedEnt) then
      local nid = VehToNet(gpsTrackedEnt)

      if (not DoesEntityExist(gpsTrackedEnt) or not NetworkDoesNetworkIdExist(nid)) then
        gpsUntrack()
      end
    end
  end
end)