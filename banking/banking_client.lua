local DrawMarker = DrawMarker
local bankcoords = {
  {pos = vec3(-113.219, 6470.161, 31.626), hasVault = true, type = 1},
  {pos = vec3(247.248, 222.645, 106.286), hasVault = true, type = 1},
  {pos = vec3(151.325, -1041.133, 29.374), hasVault = true, type = 1},
  {pos = vec3(-2963.272, 484.612, 15.703), hasVault = true, type = 1},
  {pos = vec3(1173.599, 2706.804, 38.094), hasVault = false, type = 1},
  {pos = vec3(314.123, -278.973, 54.170), hasVault = false, type = 1},
  {pos = vec3(-1212.811, -330.531, 37.787), hasVault = false, type = 1}
}
local bankMarkers = {}
local vaultcoords = {
  {pos = vec3(-105.44, 6471.79, 31.63), dpos1 = vec3(-111.156, 6465.518, 30.026), dpos2 = vec3(-108.793, 6461.576, 33.726)},  -- Paleto Blvd                 /teleport -105.44 6471.79 31.63
  {pos = vec3(253.41, 228.33, 101.68)}, -- Alta St with door            /teleport 253.41 228.33 101.68
  {pos = vec3(-2956.77, 481.62, 15.70), dpos1 = vec3(-2966.086, 480.407, 14.065), dpos2 = vec3(-2964.159, 485.142, 19.091)},  -- Great Ocean Hwy             /teleport -2956.77 481.62 15.70
  {pos = vec3(146.89, -1045.83, 29.37), dpos1 = vec3(152.681, -1040.276, 27.380), dpos2 = vec3(148.184, -1037.945, 31.931)},  -- Vespucci Blvd & Elgin Ave   /teleport 146.89 -1045.83 29.37
  {pos = vec3(1176.25, 2712.68, 38.09), dpos1 = vec3(1172.743, 2703.870, 36.338), dpos2 = vec3(1178.216, 2705.424, 40.638)},  -- Route 68                    /teleport 1176.25 2712.68 38.09
  {pos = vec3(311.27, -284.22, 54.16), dpos1 = vec3(318.000, -284.723, 52.739), dpos2 = vec3(306.061, -276.666, 56.314)},     -- Meteor St & Hawick Ave       /teleport 311.27 -284.22 54.16
  {pos = vec3(-1210.99, -336.39, 37.78), dpos1 = vec3(-1206.867, -327.460, 36.416), dpos2 = vec3(-1215.783, -338.487, 40.616)}-- Boulevard Del Perro         /teleport -1210.99 -336.39 37.78
}
local vaultMarkers = {}
-- TBD: marking it here for now, if someone walks through the gates @ alta to head into the vault and have a gun out we trigger a silent alarm
local tresspassingCoords = {
  { x = 261.88415527344, y = 221.95053100586, z = 106.28426361084 }
}
local cleanspotcoords = {}
local clspots = {}
local cleanMarkers = {}
local bankblips = {}
local cleanerblips = {}
local lastvault = 0
local lastCleaner = 0
local robtime = 300000
local robelapsed = 0
local vaultopen = false
local vaultelapsed = 0
local vaulttime = 90000
local copmintorob = 7
local robInProgress = false
local checkedCops = false
local warnMsg = false
local soundids = {}
local atmpos = {
  {pos = vec3(-717.651, -915.619, 19.215), type = 2},
  {pos = vec3(-1315.867, -834.832, 16.961), type = 2},
  {pos = vec3(288.923, -1256.765, 29.441), type = 2},
  {pos = vec3(-56.838, -1752.119, 29.421), type = 2},
  {pos = vec3(-845.966, -341.163, 38.681), type = 2},
  {pos = vec3(1153.797, -326.707, 69.205), type = 2},
  {pos = vec3(1769.342, 3337.526, 41.433), type = 2, spos = {x = 1769.801, y = 3336.802, z = 41.433, heading = 211.5}, loadprop = true},
  {pos = vec3(174.312, 6637.667, 31.573), type = 2},
  {pos = vec3(-2538.903, 2317.082, 33.215), type = 2, spos = {x = -2538.834, y = 2315.985, z = 33.215, heading = 186.001}, loadprop = true},
  {pos = vec3(2559.105, 350.899, 108.621), type = 2},
  {pos = vec3(-1091.2850341797, 2708.4794921875, 18.958734512329), type = 2},
  {pos = vec3(89.40185546875, 1.821033000946, 68.382041931152), type = 2},
  {pos = vec3(-710.17315673828, -819.29937744141, 23.729522705078), type = 2},
  {pos = vec3(33.253875732422, -1347.8095703125, 29.497020721436), type = 2},
  {pos = vec3(129.3643951416, -1292.0042724609, 29.269527435303), type = 2},
  {pos = vec3(119.64864349365, -883.96478271484, 31.123052597046), type = 2},
  {pos = vec3(526.77069091797, -160.62245178223, 57.079956054688), type = 2},
  {pos = vec3(380.90927124023, 323.77828979492, 103.56635284424), type = 2},
  {pos = vec3(-1827.0614013672, 785.16076660156, 138.29779052734), type = 2},
  {pos = vec3(1967.8754882813, 3743.8420410156, 32.343730926514), type = 2},
  {pos = vec3(2565.0783691406, 2585.0063476563, 38.083095550537), type = 2},
  {pos = vec3(2682.8427734375, 3286.8139648438, 55.241146087646), type = 2},
  {pos = vec3(1702.8328857422, 4933.3198242188, 42.063671112061), type = 2},
  {pos = vec3(1735.5168457031, 6410.8051757813, 35.037223815918), type = 2},
  {pos = vec3(-526.525, -1222.705, 18.455), type = 2},
  {pos = vec3(472.562, -1001.573, 30.692), type = 2}
}
local atmMarkers = {}
local atmblips = {}
local atmblipid = {bid = 277, bcolor = 2}
local cmaxamount = 25000
local cwait = false
local search = {anim = "mp_bank_heist_1", entry = "hack_loop"}

function initSpots()
  clspots = cleanspotcoords

  for _,v in pairs(clspots) do
    v.amount = cmaxamount
  end
end

function draw3DText(x, y, z, text)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (1.5 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, 0.55 * scale)
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

function startRobbery(streetname)
  TriggerServerEvent("bms:banking:startRobbery", vaultcoords[lastvault].pos, lastvault, streetname)
  
  Citizen.CreateThread(function()    
    local ped = PlayerPedId()

    local VaultDoor1 = GetClosestObjectOfType(253.41, 228.33, 101.68, 100.0, 961976194, 0, 0, 0) -- Alta Bank
    local vaultHeading1 = GetEntityHeading(VaultDoor1)
    SetEntityDynamic(VaultDoor1, true)

    RequestAnimDict(search.anim)
    while (not HasAnimDictLoaded(search.anim)) do
      Wait(50)
    end

    while robInProgress do      
      if (robelapsed >= robtime) then
        robInProgress = false
        vaultopen = true
        TriggerServerEvent("bms:banking:robberySuccess", vaultcoords[lastvault].pos, lastvault)
        ClearPedTasksImmediately(ped)
        SetEntityHeading(VaultDoor1, 90.0)
      else
        if (not IsEntityPlayingAnim(ped, search.anim, search.entry, 3)) then
          TaskPlayAnim(ped, search.anim, search.entry, 8.0, -8, -1, 49, 0, 1, 1, 1)
        end
      end

      Wait(500)
      robelapsed = robelapsed + 500
    end
      
    while (vaultopen) do
      if (vaultelapsed >= vaulttime) then
        SetEntityHeading(VaultDoor1, 160.0)
        vaultopen = false
        vaultelapsed = 0
        robelapsed = 0
      end

      Wait(1000)
      vaultelapsed = vaultelapsed + 1000
    end
  end)
end

function drawText(text, x, y)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.32, 0.32)
  SetTextColour(255, 255, 255, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
end

function spawnAtmProps()
  local atmhash = -870868698
  
  for _,v in pairs(atmpos) do
    if (v.loadprop) then
      local ent = CreateObject(atmhash, v.spos.x, v.spos.y, v.spos.z - 1.0001, true, false)
      
      SetEntityHeading(ent, v.spos.heading)
    end
  end
end

RegisterNetEvent("bms:banking:init")
AddEventHandler("bms:banking:init", function(data)
  if (data) then
    if (data.cleaners) then
      cleanspotcoords = data.cleaners
    end

    spawnAtmProps()
    initSpots()

    if (data.dailyCheckDepType) then
      SendNUIMessage({setBankDailyCheckDepType = true, depType = data.dailyCheckDepType})
    end
  end
end)

RegisterNetEvent("bms:robberies:changemintorob")
AddEventHandler("bms:robberies:changemintorob", function(min)
  copmintorob = min or copmintorob
end)

-- start robbery
RegisterNetEvent("bms:banking:getNumCopsOnDuty")
AddEventHandler("bms:banking:getNumCopsOnDuty", function(num, oncooldown, onstartcooldown)
  if (num >= copmintorob) then
    if (onstartcooldown) then
      TriggerEvent("chatMessage", "BANK", {255, 0, 0}, "You must wait 20 minutes after city reawakening to start a robbery.")
    elseif (not oncooldown) then
      -- rob
      if (not robInProgress) then
        robInProgress = true
        
        local ped = PlayerPedId()
        local pos = GetEntityCoords(PlayerPedId())
        local street = table.pack(GetStreetNameAtCoord(pos.x, pos.y, pos.z))
        local streetname
        RequestAnimDict(search.anim)

        while (not HasAnimDictLoaded(search.anim)) do
          Wait(50)
        end

        TaskPlayAnim(ped, search.anim, search.entry, 8.0, -8, -1, 49, 0, 1, 1, 1)
        
        if street[2] ~= 0 and street[2] ~= nil then
          streetname = string.format("%s and %s", GetStreetNameFromHashKey(street[1]), GetStreetNameFromHashKey(street[2]))
        else
          streetname = string.format("%s", GetStreetNameFromHashKey(street[1]))
        end
        
        startRobbery(streetname)
        RemoveAnimDict(search.anim)
      else
        exports.pnotify:SendNotification({text = "You are already robbing this bank."})
      end
    else
      TriggerEvent("chatMessage", "BANK", {255, 0, 0}, "This bank was robbed recently.")
    end
  else
    TriggerEvent("chatMessage", "BANK", {255, 0, 0}, "There must be at least " .. copmintorob .. " police officers online to commit this robbery.")
  end
end)

function stopAllVaultSounds()
  for k,_ in pairs(soundids) do
    StopSound(k)
    ReleaseSoundId(k)
  end

  soundids = {}
end

function stopVaultSoundFromCoord(pos)
  for k,v in pairs(soundids) do
    if (v.pos == pos) then
      StopSound(k)
      ReleaseSoundId(k)
      soundids[k] = nil
      break
    end
  end
end

RegisterNetEvent("bms:banking:playSoundForVault")
AddEventHandler("bms:banking:playSoundForVault", function(pos, vaultid)
  stopVaultSoundFromCoord(pos)

  local soundid = GetSoundId()

  soundids[soundid] = {pos = pos}
  PlaySoundFromCoord(soundid, "VEHICLES_HORNS_AMBULANCE_WARNING", pos.x, pos.y, pos.z)
end)

RegisterNetEvent("bms:banking:stopSoundForVault")
AddEventHandler("bms:banking:stopSoundForVault", function(pos, vaultid)
  stopVaultSoundFromCoord(pos)
end)

RegisterNetEvent("bms:banking:resetAlarm")
AddEventHandler("bms:banking:resetAlarm", function()
  local nearBank = false
  local bankid = 0
  
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  
  for i,v in ipairs(bankcoords) do
    local dist = #(pos - v.pos)
    
    if (dist < 20) then
      nearBank = true
      bankid = i
    end
  end
  
  if (nearBank) then
    TriggerServerEvent("bms:banking:resetAlarm", vaultcoords[bankid].pos, bankid)
  else
    -- not near a bank, check stores/jewelry
    TriggerEvent("bms:jobs:robbery:resetAlarm")
  end
end)

RegisterNetEvent("bms:banking:resetAllAlarms")
AddEventHandler("bms:banking:resetAllAlarms", function()
  stopAllVaultSounds()
end)

RegisterNetEvent("bms:banking:setcleaners")
AddEventHandler("bms:banking:setcleaners", function(cls)
  if (cls) then
    clspots = cls
  end

  cwait = false
end)

RegisterNetEvent("bms:banking:setBankDetails")
AddEventHandler("bms:banking:setBankDetails", function(data)
  if (data) then
    local bal = data.balance

    SendNUIMessage({openatm = true, balance = bal, type = data.type})
    SetNuiFocus(true, true)
  end
end)

RegisterNetEvent("bms:banking:transactionstatus")
AddEventHandler("bms:banking:transactionstatus", function(data)
  if (data) then
    local success = data.success
    local msg = data.msg
    local newbal = data.newbal

    if (success) then
      if (newbal >= 0) then
        exports.communications:setPaypalBalance(newbal)
        exports.pnotify:SendNotification({text = string.format("<font color='skyblue'>Transaction complete.</font><br/><br/>Your new bank balance is <font color='skyblue'>$%s</font>", math.floor(newbal))})
      elseif (newbal < 0) then
        exports.pnotify:SendNotification({text = string.format("<font color='skyblue'>Transaction complete.</font><br/><br/>Your new bank balance is <font color='red'>$%s</font>", math.floor(newbal))})
      end
    else
      exports.pnotify:SendNotification({text = msg})
    end
  end

  atmopen = false
  SetNuiFocus(false, false)
end)

RegisterNetEvent("bms:banking:setBankStatusText")
AddEventHandler("bms:banking:setBankStatusText", function(text)
  if (text) then
    SendNUIMessage({setStatusText = true, text = text})
  end
end)

RegisterNetEvent("bms:banking:updateAccount")
AddEventHandler("bms:banking:updateAccount", function(data)
  SendNUIMessage({checkUpdateAccount = true, accountid = data.accountid, accountData = data.accountData})
end)

RegisterNetEvent("bms:banking:updateAccountField")
AddEventHandler("bms:banking:updateAccountField", function(data)
  SendNUIMessage({updateAccountField = true, data = data})
end)

RegisterNetEvent("bms:banking:closeBankAccounts")
AddEventHandler("bms:banking:closeBankAccounts", function()
  SendNUIMessage({closeBankAccounts = true})
end)

RegisterNUICallback("bms:banking:withdraw", function(data, cb)
  if (data.amount) then
    TriggerServerEvent("bms:banking:atmwithdraw", data.amount, securityToken)
  end
end)

RegisterNUICallback("bms:banking:deposit", function(data, cb)
  if (data.amount) then
    TriggerServerEvent("bms:banking:atmdeposit", data.amount, securityToken)
  end
end)

RegisterNUICallback("bms:banking:submitAccountDonation", function(data)
  if (data) then
    exports.management:TriggerServerCallback("bms:banking:submitAccountDonation", function(rdata)
      if (rdata.success) then
        local anonstr = " anonymous"
        
        if (not rdata.anon) then
          anonstr = ""
        end

        SendNUIMessage({updateBankAtmStatus = true, text = string.format("<span style='color: lawngreen; font-size: 12px'>Your%s donation in the amount of $%s was submitted successfully.</span>", anonstr, rdata.amount)})
      else
        if (rdata.msg) then
          SendNUIMessage({updateBankAtmStatus = true, text = rdata.msg})
        end
      end

      SendNUIMessage({blockDirectDeposit = true, val = false})
    end, data)
  end
end)

RegisterNUICallback("closeatm", function(data, cb)
  atmopen = false
  SetNuiFocus(false, false)
end)

RegisterNUICallback("bms:banking:createAccount", function(data)
  if (data and data.name) then
    exports.management:TriggerServerCallback("bms:banking:createAccountPrecheck", function(rdata)
      if (rdata) then
        if (rdata.success) then
          exports.management:TriggerServerCallback("bms:banking:createAccount", function(cdata)
            if (cdata and cdata.accounts) then
              SendNUIMessage({openAccounts = true, accounts = cdata.accounts})
              SendNUIMessage({updateStatusText = true, text = string.format("Account '%s' was created successfully.  Open the Account Manager to manage this account.", cdata.name)})
              SendNUIMessage({blockCreate = true, val = false})
            end
          end, {name = data.name})
        else
          if (rdata.msg) then
            SendNUIMessage({updateStatusText = true, text = rdata.msg, msgDialog = rdata.msgDialog})
            SendNUIMessage({blockCreate = true, val = false})
          end
        end
      end
    end)
  end
end)

RegisterNUICallback("bms:banking:changePermissions", function(data)
  if (data and data.permissions) then
    exports.management:TriggerServerCallback("bms:banking:changeMember", function(rdata)
      if (rdata) then
        if (rdata.success) then
          SendNUIMessage({updateMember = true, changedMember = rdata.changedMember, accountid = rdata.accountid, memberid = rdata.memberid, charname = rdata.charname})
          SendNUIMessage({blockPermChange = true, val = false})
        end
      end
    end, data)
  end
end)

RegisterNUICallback("bms:banking:deleteAccountMember", function(data)
  if (data) then
    exports.management:TriggerServerCallback("bms:banking:deleteAccountMember", function(rdata)
      if (rdata) then
        if (rdata.success) then
          SendNUIMessage({deleteMember = true, accountid = rdata.accountid, memberid = rdata.memberid})
        end
        
        if (rdata.msg) then
          SendNUIMessage({updateStatusText = true, text = rdata.msg})
        end
      end
    end, data)
  end
end)

RegisterNUICallback("bms:banking:closeBankManager", function()
  SetNuiFocus(false, false)
end)

RegisterNUICallback("bms:banking:submitBankingTransaction", function(data)
  exports.management:TriggerServerCallback("bms:banking:submitBankingTransaction", function(rdata)
    if (rdata) then
      if (rdata.success) then
        SendNUIMessage({updateStatusText = true, text = string.format("A transaction in the amount of $%s was successful.", rdata.amount)})
      else
        SendNUIMessage({updateStatusText = true, text = rdata.msg})
      end

      SendNUIMessage({blockTransactions = true, val = false})
    end
  end, data)
end)

RegisterNUICallback("bms:banking:addMemberToAccount", function(data)
  if (data) then
    exports.management:TriggerServerCallback("bms:banking:addMemberToAccount", function(rdata)
      if (rdata) then
        if (rdata.success) then
          SendNUIMessage({updateStatusText = true, text = "The person was added to your member list."})
          SendNUIMessage({updateMember = true, changedMember = rdata.changedMember, accountid = rdata.accountid, memberid = rdata.memberid, charname = rdata.charname})
        else
          if (rdata.msg) then
            SendNUIMessage({updateStatusText = true, text = rdata.msg, msgDialog = rdata.msgDialog})
          end
        end

        SendNUIMessage({blockAddMember = true, val = false});
      end
    end, data)
  end
end)

RegisterNUICallback("bms:banking:getAccountActivity", function(data)
  if (data) then
    exports.management:TriggerServerCallback("bms:banking:getAccountActivity", function(rdata)
      if (rdata) then
        if (rdata.success and rdata.logs) then
          SendNUIMessage({updateXferLogs = true, logs = rdata.logs})
        end

        if (rdata.msg) then
          SendNUIMessage({updateStatusText = true, text = rdata.msg})
        end

        SendNUIMessage({blockGetActivity = true, val = false})
      end
    end, data)
  end
end)

RegisterNUICallback("bms:banking:deleteAccount", function(data)
  if (data) then
    exports.management:TriggerServerCallback("bms:banking:deleteAccount", function(rdata)
      if (rdata) then
        if (rdata.success) then
          SendNUIMessage({removeAccount = true, accountid = rdata.accountid})
        end

        if (rdata.msg) then
          SendNUIMessage({updateStatusText = true, text = rdata.msg})
        end

        SendNUIMessage({blockCreate = true, val = false})
      end
    end, data)
  end
end)

RegisterNUICallback("bms:banking:leaveAccount", function(data)
  if (data) then
    exports.management:TriggerServerCallback("bms:banking:leaveAccount", function(rdata)
      if (rdata) then
        if (rdata.success) then
          SendNUIMessage({removeAccount = true, accountid = rdata.accountid})
        end

        if (rdata.msg) then
          SendNUIMessage({updateStatusText = true, text = rdata.msg})
        end

        SendNUIMessage({blockCreate = true, val = false})
      end
    end, data)
  end
end)

RegisterNUICallback("bms:banking:setDailyCheckType", function(data)
  if (data and data.val) then
    TriggerServerEvent("bms:banking:setDailyCheckType", data)
  end
end)

RegisterNetEvent("bms:banking:dailyCheckTypeSet")
AddEventHandler("bms:banking:dailyCheckTypeSet", function()
  SendNUIMessage({blockCreate = true, val = false})
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)
    
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    for _,v in pairs(bankMarkers) do
      DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.15, 0, 180, 255, 50, 0, 0, 2, 0, 0, 0, 0)

      if (v.dist < 10) then
        local dist = #(pos - v.pos)
        
        if (dist < 0.55 and not atmopen) then
          drawText("Press ~b~[E]~w~ to use the bank.\nPress ~b~[H]~w~ to manage personal accounts.", 0.475, 0.88)
          
          if (IsControlJustReleased(1, 38)) then
            atmopen = true
            RequestModel(GetHashKey("prop_cs_credit_card"))
  
            while not HasModelLoaded(GetHashKey("prop_cs_credit_card")) do
              Wait(10)
            end
        
            RequestAnimDict("mp_common")
            while (not HasAnimDictLoaded("mp_common")) do
              Wait(10)
            end
        
            local ppos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
            ccspawned = CreateObject(GetHashKey("prop_cs_credit_card"), ppos.x, ppos.y, ppos.z, true, false, false)
            SetCurrentPedWeapon(ped, 0xA2719263)
            SetModelAsNoLongerNeeded(GetHashKey("prop_cs_credit_card"))
            AttachEntityToEntity(ccspawned, ped, GetPedBoneIndex(ped, 57005), 0.19, 0.04, -0.05, 180.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
            TaskPlayAnim(ped, "mp_common", "givetake1_a", 2.0, 2.0, -1, 49, 0, 0, 0, 0)
            Wait(2000)
            ClearPedTasks(ped)
            DetachEntity(ccspawned, 1, 1)
            DeleteEntity(ccspawned)
            RemoveAnimDict("mp_common")
            TriggerServerEvent("bms:banking:getBankDetails", v.type)
          elseif (IsControlJustReleased(1, 74)) then
            exports.management:TriggerServerCallback("bms:banking:getPlayerAccounts", function(rdata)
              if (rdata and rdata.accounts) then
                SendNUIMessage({openAccounts = true, accounts = rdata.accounts})
                SetNuiFocus(true, true)
              end
            end)
          end
        end
      end
    end
    
    for _,v in pairs(vaultMarkers) do
      DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 1.6, 255, 0, 0, 1, 0, 0, 2, 0, 0, 0, 0)

      if (v.dist < 10) then
        local dist = #(pos - v.pos)       
        
        if (dist < 1) then
          lastvault = v.idx
              
          if (not vaultopen) then
            if (not robInProgress) then
              drawText("Security Terminal requires an Advanced Lockpick", 0.475, 0.88)
            end
          else
            drawText(string.format("Vault Security will reboot in %s seconds", math.floor((vaulttime - vaultelapsed) / 1000)), 0.475, 0.88)
          end
        end
      end
    end
    
    for _,v in pairs(cleanMarkers) do
      DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0001, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.15, 255, 180, 50, 50, 0, 0, 2, 0, 0, 0, 0)
        
      if (v.dist < 10.0) then
        local dist = #(pos - v.pos)
        
        if (dist < 1.5 and not cwait) then
          draw3DText(v.pos.x, v.pos.y, v.pos.z + 0.28, string.format("Available to Launder:\n~g~$%s", clspots[v.idx].amount))
          drawText("Press ~b~E~w~ to launder your dye stained money.", 0.475, 0.88)
          
          if (IsControlJustReleased(1, 38)) then
            cwait = true
            lastCleaner = v.idx
            TriggerServerEvent("bms:banking:cleanDirtyMoney", lastCleaner)
          end
        end
      end
    end
    
    if (lastvault > 0) then
      local lastdist = Vdist(pos, vaultcoords[lastvault].pos)
        
      if (lastdist > 1.1 and not robInProgress) then
        lastvault = 0
        checkedCops = false
      end
      
      if (lastdist >= 10.0 and robInProgress and not warnMsg) then
        warnMsg = true
        exports.pnotify:SendNotification({text = "If you go too far from the vault, the robbery will fail."})
      end

      if (lastdist < 10.0 and robInProgress and warnMsg) then
        warnMsg = false
      end

      if (lastdist > 15.0 and robInProgress) then
        robInProgress = false
        robelapsed = 0
        checkedCops = false
        exports.pnotify:SendNotification({text = "You have left the area and the robbery was a <font color='crimson'>failure</font>."})
        TriggerServerEvent("bms:banking:stopRobbery", vaultcoords[lastvault].pos, lastvault)
        
        lastvault = 0
      end
    end
    
    if (robInProgress) then
      drawText(string.format("Time Remaining: ~r~%s seconds", math.floor((robtime - robelapsed) / 1000)), 0.475, 0.9)
      drawText("Press ~b~[H]~s~ to cancel the robbery", 0.475, 0.92)

      if (IsControlJustPressed(1, 74)) then -- H
        robInProgress = false
        robelapsed = 0
        checkedCops = false
        exports.pnotify:SendNotification({text = "You have left the area and the robbery was a <font color='crimson'>failure</font>."})
        TriggerServerEvent("bms:banking:stopRobbery", vaultcoords[lastvault].pos, lastvault)
        ClearPedTasksImmediately(ped)
      end
    end

    for _,v in pairs(atmMarkers) do
      DrawMarker(29, v.pos.x, v.pos.y, v.pos.z, 0, 0, 0, 0, 0, 0, 0.5, 0.4, 0.5, 0, 255, 190, 50, 0, 0, 0, 1, 0, 0, 0)

      if (v.dist < 10) then
        local dist = #(pos - v.pos)
        
        if (dist < 1) then
          drawText("Press ~b~E~w~ to use the ~g~ATM~w~.", 0.475, 0.88)

          if (IsControlJustReleased(1, 38)) then
            if (not atmopen) then
              atmopen = true
              RequestModel(GetHashKey("prop_cs_credit_card"))
  
              while not HasModelLoaded(GetHashKey("prop_cs_credit_card")) do
                Wait(10)
              end
          
              RequestAnimDict("mp_common")
              while (not HasAnimDictLoaded("mp_common")) do
                Wait(10)
              end
          
              local ppos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
              ccspawned = CreateObject(GetHashKey("prop_cs_credit_card"), ppos.x, ppos.y, ppos.z, true, false, false)
              SetCurrentPedWeapon(ped, 0xA2719263)
              SetModelAsNoLongerNeeded(GetHashKey("prop_cs_credit_card"))
              AttachEntityToEntity(ccspawned, ped, GetPedBoneIndex(ped, 57005), 0.19, 0.04, -0.05, 180.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
              TaskPlayAnim(ped, "mp_common", "givetake1_a", 2.0, 2.0, -1, 49, 0, 0, 0, 0)
              Wait(2000)
              ClearPedTasks(ped)
              DetachEntity(ccspawned, 1, 1)
              DeleteEntity(ccspawned)
              RemoveAnimDict("mp_common")
              TriggerServerEvent("bms:banking:getBankDetails", v.type)
            end
          end
        end
      end
    end
    
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(100)

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, true)

    for _,v in pairs(vaultMarkers) do
      if (v.dpos1 and v.dpos2) then
        if (IsEntityInArea(veh, v.dpos1, v.dpos2, 0, 1, 0) and not IsVehicleTyreBurst(veh, 0, false)) then
          exports.vehicles:burstTires(veh, {0, 1, 2, 3, 4, 5, 6, 7}, true)
        end

        --[[DrawLine(v.dpos1.x, v.dpos1.y, (v.dpos2.z + v.dpos1.z) / 2, v.dpos1.x, v.dpos2.y, (v.dpos2.z + v.dpos1.z) / 2, 0, 0, 255, 255)
        DrawLine(v.dpos1.x, v.dpos2.y, (v.dpos2.z + v.dpos1.z) / 2, v.dpos2.x, v.dpos2.y, (v.dpos2.z + v.dpos1.z) / 2, 0, 0, 255, 255)
        DrawLine(v.dpos2.x, v.dpos1.y, (v.dpos2.z + v.dpos1.z) / 2, v.dpos2.x, v.dpos2.y, (v.dpos2.z + v.dpos1.z) / 2, 0, 0, 255, 255)
        DrawLine(v.dpos1.x, v.dpos1.y, (v.dpos2.z + v.dpos1.z) / 2, v.dpos2.x, v.dpos1.y, (v.dpos2.z + v.dpos1.z) / 2, 0, 0, 255, 255)
        DrawLine(v.dpos1.x, v.dpos1.y, (v.dpos2.z + v.dpos1.z) / 2, v.dpos2.x, v.dpos2.y, (v.dpos2.z + v.dpos1.z) / 2, 0, 0, 255, 255)]]
      end
    end
  end
end)

Citizen.CreateThread(function()
  Wait(1000)

  if (#atmblips == 0) then
    for _,v in pairs(atmpos) do
      local blip = AddBlipForCoord(v.pos)

      SetBlipSprite(blip, atmblipid.bid)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 0.85)
      SetBlipColour(blip, atmblipid.bcolor)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("ATM")
      EndTextCommandSetBlipName(blip)
      
      table.insert(atmblips, blip)
    end
  end

  if (#bankblips == 0) then
    for i=1,#bankcoords do
      local blip = AddBlipForCoord(bankcoords[i].pos)
      SetBlipSprite(blip, 207)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 0.8)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Bank")
      EndTextCommandSetBlipName(blip)
      
      table.insert(bankblips, blip)
    end
  end

  while true do
    Wait(1500)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local aMarkers = {}
    local iter = 0

    for i=1,#atmpos do
      local dist = #(pos - atmpos[i].pos)

      if (dist < 65) then
        iter = iter + 1
        aMarkers[iter] = atmpos[i]
        aMarkers[iter].dist = dist
      end
    end

    atmMarkers = aMarkers

    local cMarkers = {}
    iter = 0

    for i=1,#cleanspotcoords do
      local dist = #(pos - cleanspotcoords[i].pos)

      if (dist < 65) then
        iter = iter + 1
        cMarkers[iter] = cleanspotcoords[i]
        cMarkers[iter].dist = dist
        cMarkers[iter].idx = i
      end
    end

    cleanMarkers = cMarkers

    local vMarkers = {}
    iter = 0

    for i=1,#vaultcoords do
      local dist = #(pos - vaultcoords[i].pos)

      if (dist < 65) then
        iter = iter + 1
        vMarkers[iter] = vaultcoords[i]
        vMarkers[iter].dist = dist
        vMarkers[iter].idx = i
      end
    end

    vaultMarkers = vMarkers

    local bMarkers = {}
    iter = 0

    for i=1,#bankcoords do
      local dist = #(pos - bankcoords[i].pos)

      if (dist < 65) then
        iter = iter + 1
        bMarkers[iter] = bankcoords[i]
        bMarkers[iter].dist = dist
      end
    end

    bankMarkers = bMarkers

    if (lastCleaner > 0) then
      local lastdist = #(pos - cleanspotcoords[lastCleaner].pos)
        
      if (lastdist > 1.1) then
        lastCleaner = 0
      end
    end
  end
end)