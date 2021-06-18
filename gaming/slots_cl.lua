local DrawMarker = DrawMarker
local slots = {}
local inSlots = false
local lastSlotIndex = 0
local gameSettings = {}
local chairNetScene

function toggleControlsForGaming(toggle)
  exports.actionmenu:toggleBlockMenu(not toggle, true)
  exports.communications:canUsePhone(toggle)
  exports.communications:canToggleTilde(toggle)
  exports.emotes:setCanEmote(toggle)
  exports.inventory:setCanTrade(toggle)
  exports.lawenforcement:setBlockIncTackle(not toggle)
  exports.chat:toggleBlockChatKeyOpen(not toggle)
end

local function draw3DGamingText(x, y, z, text, tscale)
  local onScreen, _x ,_y = GetScreenCoordFromWorldCoord(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, tscale or 0.55 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    SetTextCentre(1)
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(_x, _y)
  end
end

RegisterNetEvent("bms:gaming:slots:init")
AddEventHandler("bms:gaming:slots:init", function(data)
  slots = data.slots or {}
  gameSettings = data.gameSettings or {}
end)

RegisterNetEvent("bms:gaming:slots:ejectFromSlot")
AddEventHandler("bms:gaming:slots:ejectFromSlot", function()
  if (inSlots) then
    SendNUIMessage({exitSlotsImmediate = true})
  end
end)

RegisterNUICallback("bms:gaming:slots:exitSlots", function()
  exports.management:TriggerServerCallback("bms:gaming:slots:leaveSlots", function()
    SetNuiFocus(false, false)
    
    Citizen.CreateThread(function()
      local ped = PlayerPedId()
      
      while (not HasAnimDictLoaded(gameSettings.sittingAnim.dict)) do
        RequestAnimDict(gameSettings.sittingAnim.dict)
        Wait(5)
      end

      NetworkStopSynchronisedScene(chairNetScene)
      DisposeSynchronizedScene(chairNetScene)
      TaskPlayAnim(ped, gameSettings.sittingAnim.dict, gameSettings.sittingAnim.exitAnim, 1.0, 1.0, 2500, 0)
      Wait(2500)
      inSlots = false
    end)
  end)
end)

RegisterNUICallback("bms:gaming:slots:doSlotSpin", function()
  exports.management:TriggerServerCallback("bms:gaming:slots:doSlotSpin", function(rdata)
    if (rdata) then
      if (rdata.success) then
        SendNUIMessage({doSlotSpin = true, tileCombo = rdata.tileCombo})
      else
        SendNUIMessage({setSlotText = true, msg = rdata.msg})
        SendNUIMessage({toggleSlotAction = true, toggle = true})
      end
    end
  end, {slotIndex = lastSlotIndex})
end)

RegisterNUICallback("bms:gaming:slots:doSlotBetOne", function()
  exports.management:TriggerServerCallback("bms:gaming:slots:doSlotBetOne", function(rdata)
    if (rdata) then
      SendNUIMessage({setSlotsMachineBet = true, currentBet = rdata.currentBet, msg = rdata.msg})
    end
    
    SendNUIMessage({toggleSlotAction = true, toggle = true})
  end, {slotIndex = lastSlotIndex})
end)

RegisterNUICallback("bms:gaming:slots:doSlotBetMax", function()
  exports.management:TriggerServerCallback("bms:gaming:slots:doSlotBetMax", function(rdata)
    if (rdata) then
      SendNUIMessage({setSlotsMachineBet = true, currentBet = rdata.currentBet, msg = rdata.msg})
    end
    
    SendNUIMessage({toggleSlotAction = true, toggle = true})
  end, {slotIndex = lastSlotIndex})
end)

RegisterNUICallback("bms:gaming:slots:slotSpinComplete", function()
  exports.management:TriggerServerCallback("bms:gaming:slots:slotSpinComplete", function(rdata)
    SendNUIMessage({setSlotSpinComplete = true, msg = rdata.msg, winnings = rdata.winnings, winLevel = rdata.winLevel})
    
    if (rdata.winnings and rdata.winnings > 0) then
      if (rdata.winLevel) then
        if (rdata.winLevel == 4) then
          SendNUIMessage({setTextAnimate = true, msg = "JACKPOT", delay = 6000})
        else
          SendNUIMessage({setTextAnimate = true, msg = "WINNER", delay = 5000})
        end
      end
    end

    SendNUIMessage({toggleSlotAction = true, toggle = true})
  end, {slotIndex = lastSlotIndex})
end)

RegisterNUICallback("playSoundClient", function(data)
  if (data.sound) then
    TriggerEvent("bms:soundmgr:playSoundOnClient", data.sound, data.volume or 0.3)
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    -- TODO do master range checks to reduce overhead
    if (not inSlots) then
      for machineIndex, machine in pairs(slots) do
        local dist = #(pos - machine.pos)

        if (dist < 80) then
          DrawMarker(1, machine.pos.x, machine.pos.y, machine.pos.z, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.25, 0, 120, 120, 55)

          if (dist < 1.2) then
            local jackPotAt = 0
            
            if (GlobalState and GlobalState.slots and GlobalState.slots.jackPots[machineIndex]) then
              jackPotAt = GlobalState.slots.jackPots[machineIndex]
            end

            draw3DGamingText(machine.pos.x, machine.pos.y, machine.pos.z + 1, ("Press [~b~E~w~] to play slot ~g~($%s bet) ~b~[Jackpot: $%s]~w~."):format(machine.maxBetInc, jackPotAt), 0.31)

            if (IsControlJustReleased(1, 38)) then
              inSlots = true
              lastSlotIndex = machineIndex
              exports.management:TriggerServerCallback("bms:gaming:slots:playerJoinSlot", function(rdata)
                if (rdata) then
                  if (rdata.success) then
                    sitInGamingChair(2, machine.seatBoneIndex, machine.entityModel, function()
                      SendNUIMessage({setSlotsMachineBet = true, currentBet = rdata.currentBet})
                      SendNUIMessage({showSlots = true, machineType = rdata.machineType or 1, tileCount = rdata.tileCount or 7})
                      SetNuiFocus(true, true)
                    end)
                  else
                    exports.pnotify:SendNotification({text = rdata.msg})
                    inSlots = false
                  end
                end
              end, {slotIndex = lastSlotIndex})
            end
          end
        end
      end
    end

    if (inSlots) then
      SetPedCapsule(ped, 0.2)
      HideHudAndRadarThisFrame()
      DisableFirstPersonCamThisFrame()
      DisableVehicleFirstPersonCamThisFrame()
      DisableControlAction(0, 32, true)  -- Movement
      DisableControlAction(0, 33, true)  --
      DisableControlAction(0, 34, true)  --
      DisableControlAction(0, 35, true)  --
      DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
      DisableControlAction(0, 37, true)  -- SelectWeapon
      DisableControlAction(0, 25, true)  -- INPUT_AIM
      DisableControlAction(0, 311, true) -- Inventory
      DisableControlAction(0, 19, true) -- ActionMenu Primary
      DisableControlAction(0, 48, true) -- ActionMenu Secondary
      DisableControlAction(0, 21, true) -- Shift (Settings menu combo)
      DisableControlAction(0, 303, true) -- U (Settings menu combo)
    end
  end
end)

--[[ Chair specific to the gaming resource ]]
function getChairNetScene()
  return chairNetScene
end

--[[ Gets the bone in the entity so that we can sit down in front of the machine.  Most casino assets with chairs attached have identifiable bones in them (found with Gims Evo). ]]
function getClosestBoneIndexFromModel(model, chairCount, bonePrefix)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local anyObj = GetClosestObjectOfType(pos.x, pos.y, pos.z, 10.0, GetHashKey(model))
  local clBone = {index = -1, dist = 0}

  if (anyObj ~= 0) then    
    for i = 1, chairCount do
      local boneIndex = GetEntityBoneIndexByName(anyObj, ("%s%s"):format(bonePrefix, i))
      local bonePos = GetEntityBonePosition_2(anyObj, boneIndex)
      local distToBone = #(pos - bonePos)

      if (clBone.index == -1 or distToBone < clBone.dist) then
        clBone.index = boneIndex
        clBone.dist = distToBone
        clBone.seatIndex = i
      end
    end

    if (clBone.index > -1) then
      return clBone.index, anyObj, clBone.seatIndex
    end
  else
    print("anyObj was nil")
  end

  return -1
end

function getClosestSeatIndex(model, chairCount, bonePrefix)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local anyObj = GetClosestObjectOfType(pos.x, pos.y, pos.z, 10.0, GetHashKey(model))
  local clBone = {seatIndex = -1, dist = 0}

  if (anyObj ~= 0) then    
    for i = 1, chairCount do
      local boneIndex = GetEntityBoneIndexByName(anyObj, ("%s%s"):format(bonePrefix, i))
      local bonePos = GetEntityBonePosition_2(anyObj, boneIndex)
      local distToBone = #(pos - bonePos)

      if (clBone.seatIndex == -1 or distToBone < clBone.dist) then
        clBone.seatIndex = i
        clBone.dist = distToBone
      end
    end

    if (clBone.seatIndex > -1) then
      return clBone.seatIndex
    end
  else
    print("anyObj was nil")
  end

  return -1
end

--local boneDebugs = {}
--[[ gameType: 1 = Blackjack, 2 = slots ]]
function sitInGamingChair(gameType, boneIndex, model, cb)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local anyObj = GetClosestObjectOfType(pos.x, pos.y, pos.z, 10.0, GetHashKey(model))

  if (anyObj ~= 0) then
    local bonePos = GetEntityBonePosition_2(anyObj, boneIndex)
    local boneRot = GetEntityBoneRotation(anyObj, boneIndex)
    local settings = gameSettings

    --[[for i = 4, 4 do
      boneDebugs[i] = GetEntityBonePosition_2(anyObj, i)
    end]]

    if (#(pos - bonePos) < 3) then
      if (gameType == 1) then
        gameSettings = getBlackjackGameSettings()
      end

      if (not gameSettings) then return print("no gameSettings") end

      local sitAnim = gameSettings.sittingAnim

      Citizen.CreateThread(function()        
        while (not HasAnimDictLoaded(sitAnim.dict)) do
          RequestAnimDict(sitAnim.dict)
          Wait(5)
        end

        local initialPos = GetAnimInitialOffsetPosition(sitAnim.dict, sitAnim.enterAnim, bonePos.x, bonePos.y, bonePos.z, boneRot.x, boneRot.y, boneRot.z, 0.01, 2)
        
        chairNetScene = NetworkCreateSynchronisedScene(bonePos.x, bonePos.y, bonePos.z, boneRot.x, boneRot.y, boneRot.z, 2, 1, 0, 1065353216, 0, 1065353216)
        TaskGoStraightToCoord(ped, initialPos.x, initialPos.y, initialPos.z, 1.0, 3000, 0, 0.01)
        Wait(3000)
        TaskTurnPedToFaceCoord(ped, bonePos.x, bonePos.y, bonePos.z, 700)
        Wait(700)
        
        NetworkAddPedToSynchronisedScene(ped, chairNetScene, sitAnim.dict, sitAnim.enterAnim, 2.0, -2.0, 13, 16, 2.0, 0)
        NetworkStartSynchronisedScene(chairNetScene)
        Citizen.InvokeNative(0x79C0E43EB9B944E2, -2124244681) -- Unsure what this does, exactly.  Ripped from R* casino code, probably something to do with the net scene.
        Wait(6000)
        RemoveAnimDict(gameSettings.sittingAnim.dict)

        if (cb) then
          cb(chairNetScene)
        end
      end)
    end
  end
end

--[[ Bone Debugger ]]
--[[Citizen.CreateThread(function()
  while true do
    Wait(1)
    for boneId, bonePos in pairs(boneDebugs) do
      DrawMarker(1, bonePos.x, bonePos.y, bonePos.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.05, 0, 255, 0, 150, 0, 0, 0, 0, 0, 0, 0)
    end
  end
end)]]