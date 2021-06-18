local table_remove = table.remove
local table_insert = table.insert
local string_format = string.format
local nuifocus = false
local contacts = {}
local tempcontacts = {}
local voicechannel = 0
local phoneanims = {
  {dict = "cellphone@", anim = "cellphone_text_read_base"},
  {dict = "cellphone@", anim = "cellphone_call_listen_base"}
}
local cellPropHash  -- = GetHashKey("p_amb_phone_01")
local cellprop = 0
local showing = false
local ringing = false
local calling = false
local callhistory = {}
local phoneBlocked = false
local tildeBlocked = false

function canUsePhone(toggle)
  phoneBlocked = not toggle
end

function canToggleTilde(toggle)
  tildeBlocked = not toggle
end

function notifyPhone(text)
  if (text) then
    SendNUIMessage({setNotify = true, text = text})
  end
end

function getAttachedPhoneProp()
  return cellprop
end

function getPhoneAnimations()
  return phoneanims
end

function attachPhoneToPed(prop, boneidx, x, y, z, rx, ry, rz, overrideExistCheck)
  if (cellprop ~= 0 and not overrideExistCheck) then
    return
  end

  while (not HasModelLoaded(prop)) do
    RequestModel(prop)
    Wait(10)
  end
  
  local ped = PlayerPedId()
  boneidx = GetPedBoneIndex(ped, boneidx)
  local obj = CreateObject(prop, 1729.73, 6403.90, 34.56, true, true, true)
  AttachEntityToEntity(obj, ped, boneidx, x, y, z, rx, ry, rz, false, false, false, false, 2, true)
  SetModelAsNoLongerNeeded(prop)
  TriggerServerEvent("bms:management:registerSpawnedProp", NetworkGetNetworkIdFromEntity(obj))

  return obj
end

function checkTime()
  exports.serversync:getGameTime(function(time)
    SendNUIMessage({setTime = true, time = time})
    
    SetTimeout(3000, function()
      checkTime()
    end)
  end)
end

function getWeatherReport()
  local pos = GetEntityCoords(PlayerPedId())
  local curzone = GetNameOfZone(pos.x, pos.y, pos.z)

  TriggerServerEvent("bms:comms:phone:getweatherreport", curzone)

  SetTimeout(30000, function()
    getWeatherReport()
  end)
end

function isTempContact(name)
  for _,v in pairs(tempcontacts) do
    if (v.name == name) then
      return true
    end
  end
end

function ringLoop(soundFile, volume, loopDelay)
  Citizen.CreateThread(function()
    Wait(500)

    while ringing do
      TriggerEvent("bms:soundmgr:playSoundOnClient", soundFile, volume)
      Wait(loopDelay)
    end
  end)
end

function busyLoop()
  SetTimeout(2000, function()
    if (ringing) then
      TriggerEvent("bms:soundmgr:playSoundOnClient", "phone_ring_busy", 0.18)
      busyLoop()
    else
      SendNUIMessage({closeCallStatus = true})
      calling = false
    end
  end)
end

function setCallRing()
  ringing = true
  ringLoop("phone_ring_outgoing", 0.17, 5000)

  SetTimeout(30000, function()
    ringing = false
  end)
end

function setCallBusy()
  busyLoop()

  SetTimeout(10000, function()
    ringing = false
  end)
end

function setIncomingCallRing()
  ringing = true
  ringLoop("phone_ring_incoming", 0.17, 5000)

  SetTimeout(30000, function()
    ringing = false
  end)
end

function getVchan(cb)
  if (cb) then
    cb(voicechannel)
  end
end

function setPaypalBalance(amount)
  if (amount) then
    SendNUIMessage({setPaypalBalance = true, balance = amount})
  end
end

function setPhoneModel(model)
  if (model) then
    cellPropHash = GetHashKey(model)
  else
    cellPropHash = nil
  end

  SendNUIMessage({setCellPropHash = true, hash = cellPropHash})
end

RegisterNetEvent("bms:comms:phone:updatePaypalBalance")
AddEventHandler("bms:comms:phone:updatePaypalBalance", function(amount)
  if (amount) then
    setPaypalBalance(amount)
  end
end)

RegisterNetEvent("bms:comms:phone:notifyphone")
AddEventHandler("bms:comms:phone:notifyphone", function(data)
  local reset = data.reset
  local msg = data.msg
  
  if (msg) then
    notifyPhone(data.msg)
  end

  if (reset) then
    calling = false
    ringing = false
  end
end)

RegisterNetEvent("bms:comms:phone:setcontacts")
AddEventHandler("bms:comms:phone:setcontacts", function(cont, show)
  if (cont) then
    print("phone_cl.lua >> Setting phone contacts")
    -- Add our temp contacts to the end of the list.  We don't want to save them, because they are plebs.
    contacts = cont
    local tcont = {}
    local iter = 0

    for i=1,#contacts do
      iter = iter + 1
      tcont[iter] = contacts[i]
    end

    for i=1,#tempcontacts do
      iter = iter + 1
      tcont[iter] = tempcontacts[i]
    end

    SendNUIMessage({loadContacts = true, contacts = tcont})
  end
end)

RegisterNetEvent("bms:comms:phone:outgoingcall")
AddEventHandler("bms:comms:phone:outgoingcall", function(osrc, onum, time)
  if (osrc and onum) then
    SendNUIMessage({openCallStatus = true, type = 2, source = osrc, num = onum})
    setCallRing()
    callhistory[time] = {type = 2, num = onum}
    SendNUIMessage({updateCallHistory = true, callhistory = callhistory})
  end
end)

RegisterNetEvent("bms:comms:phone:incomingcall")
AddEventHandler("bms:comms:phone:incomingcall", function(isrc, inum, time)
  if (not cellPropHash) then
    TriggerServerEvent("bms:comms:phone:cancelcall")
    return
  end
  
  if (isrc and inum) then
    for _,v in pairs(contacts) do
      if (v.number == inum and v.blocked) then
        return
      end
    end

    setIncomingCallRing()
    SendNUIMessage({openCallStatus = true, type = 1, source = isrc, num = inum})
    callhistory[time] = {type = 1, num = inum}
    SendNUIMessage({updateCallHistory = true, callhistory = callhistory})
  end
end)

RegisterNetEvent("bms:comms:phone:disconnectcall")
AddEventHandler("bms:comms:phone:disconnectcall", function(msg)
  print("phone disconnect call")
  exports.playerhousing:getVchan(function(vc)
    print(string_format("Voice channel: %s", vc))
    --[[if (not vc or vc == 0) then
      NetworkClearVoiceChannel() -- default voice channel
    else
      NetworkSetVoiceChannel(vc)
    end]]
  
    voicechannel = vc

    -- send nui event
    if (msg and msg ~= "") then
      SendNUIMessage({setNotify = true, text = msg})
    else
      SendNUIMessage({setNotify = true, text = "The call was disconnected."})
    end

    SendNUIMessage({closeCallStatus = true})
    SendNUIMessage({setInCall = true, incall = false})
    calling = false
    ringing = false

    print("sending end call")
    TriggerEvent("bms:csrp_gamemode:endcall")
  end)
end)

RegisterNetEvent("bms:comms:phone:setincall")
AddEventHandler("bms:comms:phone:setincall", function(call, part)
  --[[print((call))
  print(GetPlayerFromServerId(call.part1.source))
  print(GetPlayerFromServerId(call.part2.source))]]
  --NetworkSetVoiceChannel(call.part1.source)
  voicechannel = call.part1.source
  ringing = false
  calling = true
  SendNUIMessage({openCallStatusInCall = true, call = call, part = part})
  SendNUIMessage({setInCall = true, incall = true})
  if (part == 1) then
    TriggerEvent("bms:csrp_gamemode:setincall", call.part2.source)
  else
    TriggerEvent("bms:csrp_gamemode:setincall", call.part1.source)
  end
end)

RegisterNetEvent("bms:comms:phone:textfrom")
AddEventHandler("bms:comms:phone:textfrom", function(data)
  if (data) then
    for _,v in pairs(contacts) do
      if (v.number == data.number and v.blocked) then
        return
      end
    end
    
    SendNUIMessage({addTextFrom = true, number = data.number, message = data.message})
  end
end)

RegisterNetEvent("bms:comms:phone:setweatherreport")
AddEventHandler("bms:comms:phone:setweatherreport", function(data)
  if (data) then
    --print(json.encode(data))
    --print(string_format("sending weather nui %s", data.windex))
    SendNUIMessage({setWeather = true, windex = data.windex, nindex = data.nindex})
  end
end)

RegisterNetEvent("bms:comms:phone:outgoingcallbusy")
AddEventHandler("bms:comms:phone:outgoingcallbusy", function(osrc, onum)
  if (osrc and onum) then
    SendNUIMessage({openCallStatus = true, type = 2, source = osrc, num = onum})
    ringing = true
    setCallBusy()
  end
end)

RegisterNetEvent("bms:comms:phone:setPhoneModel")
AddEventHandler("bms:comms:phone:setPhoneModel", function(model)
  setPhoneModel(model)
end)

RegisterNetEvent("bms:comms:phone:refreshEmails")
AddEventHandler("bms:comms:phone:refreshEmails", function(data)  
  if (data and data.emails) then
    SendNUIMessage({loadUserEmails = true, emails = data.emails, forceEmailView = data.forceShowEmailList})

    if (data.newEmail and cellPropHash) then
      SendNUIMessage({blinkEmailNotify = true})
    end
  end
end)

RegisterNetEvent("bms:comms:phones:advertsUpdateAll")
AddEventHandler("bms:comms:phones:advertsUpdateAll", function(data)
  if (data and data.adverts) then
    SendNUIMessage({updateAdverts = true, adverts = data.adverts, adCost = data.adCost})
  end
end)

AddEventHandler("bms:nuiFocusDisable", function()
  SetNuiFocus(false, false)
end)

AddEventHandler("bms:comms:updateDealerLogs", function(rdata)
  if (rdata) then
    if (rdata.success) then
      SendNUIMessage({updateDealerLogs = true, logdata = rdata.logdata})
      exports.pnotify:SendNotification({text = "The sales logs have been sent to your phone.", layout = "bottomRight"})
      TriggerEvent("bms:comms:playSound")
    else
      if (rdata.msg) then
        exports.pnotify:SendNotification({text = rdata.msg, layout = "bottomRight"})
      end
    end
    
    SendNUIMessage({unblockLogs = true})
  end
end)

RegisterNUICallback("bms:toggleNui", function(toggle)
  if (toggle ~= nil) then
    nuifocus = toggle
    SetNuiFocus(toggle, toggle)
  else
    nuifocus = not nuifocus
    SetNuiFocus(nuifocus, nuifocus)
  end
end)

RegisterNUICallback("bms:comms:phone:cancelcall", function(msg)
  ringing = false
  calling = false
  print("cancelling call from NUI")
  
  exports.playerhousing:getVchan(function(vc)
    if (not vc or vc == 0) then
      NetworkClearVoiceChannel()
    else
      NetworkSetVoiceChannel(vc)
    end

    print("Triggering server event to cancelcall")
    TriggerServerEvent("bms:comms:phone:cancelcall")
  end)
end)

RegisterNUICallback("bms:comms:phone:answercall", function()
  ringing = false
  calling = true
  TriggerServerEvent("bms:comms:phone:answercall")
end)

RegisterNUICallback("bms:comms:phone:addcontact", function(data)
  if (data and data.name and (data.number or data.email)) then
    if (isTempContact(data.number)) then
      local remid = 0
      
      for i,v in ipairs(tempcontacts) do
        if (v.number == data.number) then
          remid = i
          break
        end
      end

      if (remid > 0) then
        table_remove(tempcontacts, remid)
      end

    end
    TriggerServerEvent("bms:comms:phone:addcontact", data)
  end
end)

--sendData2(resource, "bms:comms:phone:editContact", {oldContact: lastEditingContact, newContact: {name: name, number: number, email: email}});
RegisterNUICallback("bms:comms:phone:editContact", function(data)
  if (data) then
    exports.management:TriggerServerCallback("bms:comms:phone:editContact", function(rdata)
      SendNUIMessage({setNotify = true, text = "Contact information updated."})
    end, data)
  end
end)

RegisterNUICallback("bms:comms:phone:addtempcontact", function(data)
  if (data and data.number) then
    table_insert(tempcontacts, {name = data.number, number = data.number})
  end
end)

RegisterNUICallback("bms:comms:phone:removecontact", function(data)
  if (data and data.name and data.number) then
    print("Removing contact")

    if (isTempContact(data.name)) then
      print("Removing temp contact")
      local remid = 0
      
      for i,v in ipairs(tempcontacts) do
        if (v.name == data.name) then
          remid = i
          break
        end
      end

      if (remid > 0) then
        table_remove(tempcontacts, remid)
      end

      local tcont = {}
      local iter = 0

      for i=1,#contacts do
        iter = iter + 1
        tcont[iter] = contacts[i]
      end

      for i=1,#tempcontacts do
        iter = iter + 1
        tcont[iter] = tempcontacts[i]
      end

      SendNUIMessage({loadContacts = true, contacts = tcont})
    else
      print("Removing saved contact")
      TriggerServerEvent("bms:comms:phone:removecontact", data, securityToken)
    end
  end
end)

RegisterNUICallback("bms:comms:phone:callperson", function(data)
  local ped = PlayerPedId()
  
  if (data and data.number) then
    -- TODO: Change to normal server event call
    --data.testtype = 2
    calling = true

    if (not IsEntityPlayingAnim(ped, phoneanims[2].dict, phoneanims[2].anim, 3)) then
      RequestAnimDict(phoneanims[2].dict)

      while (not HasAnimDictLoaded(phoneanims[2].dict)) do
        Wait(50)
      end

      TaskPlayAnim(ped, phoneanims[2].dict, phoneanims[2].anim, 2.0, 2.0, -1, 49, 0, 0, 0, 0)
      
      if (cellprop == 0) then
        cellprop = attachPhoneToPed(cellPropHash, 28422, 0, 0, 0, 0, 0, 0)
      end
      
      SetCurrentPedWeapon(ped, 2725352035, true)
      RemoveAnimDict(phoneanims[2].dict)
    end

    TriggerServerEvent("bms:comms:phone:callperson", data)
  end
end)

RegisterNUICallback("bms:comms:phone:textperson", function(data)
  if (data and data.number and data.msg) then
    TriggerServerEvent("bms:comms:phone:textperson", data, securityToken)
  end
end)

RegisterNUICallback("bms:comms:phones:phoneshowing", function(data)
  if (data) then
    showing = data.showing
    local ped = PlayerPedId()

    if (showing) then
      if (not cellPropHash) then
        exports.pnotify:SendNotification({text = "<span style='color: lawngreen'>You do not have a phone.</span><br/>You can purchase one from the <span style='color: skyblue'>Cellular Shop</span>."})
        showing = false
        return
      end

      if (not IsEntityPlayingAnim(ped, phoneanims[1].dict, phoneanims[1].anim, 3)) then
        while (not HasAnimDictLoaded(phoneanims[1].dict)) do
          RequestAnimDict(phoneanims[1].dict)
          Wait(50)
        end

        TaskPlayAnim(ped, phoneanims[1].dict, phoneanims[1].anim, 2.0, 2.0, -1, 49, 0, 0, 0, 0) -- old flag 49
        Wait(300)
        if (cellprop > 0) then
          DeleteEntity(cellprop)
        end
                
        cellprop = attachPhoneToPed(cellPropHash, 28422, 0, 0, 0, 0, 0, 0)
        SetCurrentPedWeapon(ped, 2725352035, true)
        exports.actionmenu:toggleBlockMenu(true)
      end
    else
      if (IsEntityPlayingAnim(ped, phoneanims[1].dict, phoneanims[1].anim, 3)) then
        StopEntityAnim(ped, phoneanims[1].anim, phoneanims[1].dict)
      end
      Wait(200)
      RemoveAnimDict(phoneanims[1].dict)
      DeleteEntity(cellprop)
      cellprop = 0
      exports.actionmenu:toggleBlockMenu(false)
    end
  end
end)

RegisterNUICallback("bms:comms:phone:blockperson", function(data)
  if (data) then
    TriggerServerEvent("bms:comms:phone:blockcontact", data)
  end
end)

RegisterNUICallback("bms:comms:getBankAccountTransactionHistory", function(data)
  if (data) then
    exports.management:TriggerServerCallback("bms:banking:getAccountHistoryForPhone", function(rdata)
      if (rdata) then
        if (rdata.success) then
          SendNUIMessage({showTransactionHistory = true, logs = rdata.logs, listing = rdata.listing, balance = rdata.balance})
        else
          notifyPhone(rdata.msg)
        end
      end
    end, data)
  end
end)

RegisterNUICallback("bms:comms:phone:getPhoneEmails", function()
  exports.management:TriggerServerCallback("bms:comms:phone:getUserEmails", function(rdata)
    SendNUIMessage({loadUserEmails = true, emails = rdata.emails, forceEmailView = rdata.showEmailsOnComplete})
  end, {showEmailsOnComplete = true})
end)

RegisterNUICallback("bms:comms:sendEmail", function(data)
  exports.management:TriggerServerCallback("bms:comms:phone:sendEmail", function(rdata)
    if (rdata and rdata.msg) then
      SendNUIMessage({setNotify = true, text = rdata.msg})
    end

    if (rdata and rdata.success) then
      SendNUIMessage({toggleSendEmailFields = true, toggle = true, clear = true, hideEmailCompose = true, showInbox = true})
    else
      SendNUIMessage({toggleSendEmailFields = true, toggle = true})
    end
  end, data)
end)

RegisterNUICallback("bms:comms:phone:markEmailRead", function(data)
  TriggerServerEvent("bms:comms:phone:markEmailRead", data)
end)

RegisterNUICallback("bms:comms:phone:emailDelete", function(data)
  exports.management:TriggerServerCallback("bms:comms:phone:emailDelete", function(rdata)
    if (rdata.success and rdata.emailId) then
      SendNUIMessage({deleteEmail = true, emailId = rdata.emailId})
    end
  end, data)
end)

RegisterNUICallback("bms:comms:phone:ypPostNewAdvert", function(data)
  if (data) then
    exports.management:TriggerServerCallback("bms:comms:phone:ypPostNewAdvert", function(rdata)
      if (rdata) then
        if (rdata.msg) then
          SendNUIMessage({setNotify = true, text = rdata.msg})
        end

        SendNUIMessage({toggleYpBlocker = true, toggle = false})

        if (rdata.success) then
          SendNUIMessage({clearYpFields = true})
        end
      end
    end, data)
  end
end)

RegisterNUICallback("bms:comms:phone:ypDeleteAdvert", function(data)
  if (not data) then return end

  exports.management:TriggerServerCallback("bms:comms:phone:ypDeleteAdvert", function(rdata)
    if (rdata.success and rdata.msg) then
      notifyPhone(rdata.msg)
    end
  end, data)
end)

SetTimeout(30000, function()
  checkTime()
  getWeatherReport()
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local iskb = IsInputDisabled(2)
    local handcuffed = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)

    if (iskb and not handcuffed) then
      if ((IsControlJustReleased(1, 243)) and not tildeBlocked) then -- ~ (toggle pointer)
        nuifocus = not nuifocus
        SetNuiFocus(nuifocus, nuifocus)
      end

      if (IsControlJustReleased(1, 289)) then -- F2 (toggle phone)
        cancelSelfieMode()
        
        if (cellPropHash) then
          if (not phoneBlocked) then
            SendNUIMessage({showPhone = true})
          else
            exports.pnotify:SendNotification({text = "You can not open your phone at this time."})
          end
        else
          exports.pnotify:SendNotification({text = "<span style='color: lawngreen'>You do not have a phone.</span><br/>You can purchase one from the <span style='color: skyblue'>Cellular Shop</span>."})
        end
      end
    end

    if (calling) then
      if (not IsEntityPlayingAnim(ped, phoneanims[2].dict, phoneanims[2].anim, 3)) then
        RequestAnimDict(phoneanims[2].dict)
  
        while (not HasAnimDictLoaded(phoneanims[2].dict)) do
          Wait(50)
        end
  
        TaskPlayAnim(ped, phoneanims[2].dict, phoneanims[2].anim, 2.0, 2.0, -1, 49, 0, 0, 0, 0)
        
        if (cellprop == 0) then
          cellprop = attachPhoneToPed(cellPropHash, 28422, 0, 0, 0, 0, 0, 0)
        end
        
        SetCurrentPedWeapon(ped, 2725352035, true)
      end
    end

    if (not calling and not ringing and IsEntityPlayingAnim(ped, phoneanims[2].dict, phoneanims[2].anim, 3)) then
      TriggerServerEvent("bms:management:unregisterSpawnedProp", NetworkGetNetworkIdFromEntity(cellprop))
      StopEntityAnim(ped, phoneanims[2].anim, phoneanims[2].dict)
      RemoveAnimDict(phoneanims[2].dict)
      DeleteEntity(cellprop)
      cellprop = 0
      exports.actionmenu:toggleBlockMenu(false)
    end
  end
end)
