local ishigh = false
local isdrunk = false
local hightime = 120000
local curhightime = 0
local drunktime = 600000--480000
local curdrunktime = 0
local drinknum = 0

function getAlcoholLevel(cb)
  local level = 0.000
  
  if (drinknum > 0) then
    if (drinknum < 2) then
      level = 0.020
    elseif (drinknum < 4) then
      level = 0.060
    elseif (drinknum < 5) then
      level = 0.090
    elseif (drinknum > 5) then
      level = (drinknum + 5) * 0.01
    end
  end

  if (cb) then
    cb(level)
  end

  return level
end

AddEventHandler("bms:drugdealer:useJoint", function()
  ishigh = true
  curhightime = 0
  TriggerServerEvent("localChatAction", GetPlayerServerId(PlayerId()), -1, {0, 255, 0}, "is smoking a Joint.")
  TriggerServerEvent("bms:remCharacterInvItem", GetPlayerServerId(PlayerId()), "Joint", 1)
  TriggerEvent("bms:emotes:doEmote", "smokepot")
end)

RegisterNetEvent("bms:drugdealer:useAlcohol")
AddEventHandler("bms:drugdealer:useAlcohol", function(itemName)
  isdrunk = true
  drinknum = drinknum + 1
  curdrunktime = 0
  TriggerServerEvent("localChatAction", GetPlayerServerId(PlayerId()), -1, {0, 255, 0}, string.format("is drinking a %s", itemName))
  --TriggerServerEvent("bms:remCharacterInvItem", GetPlayerServerId(PlayerId()), itemName, 1) -- handled server side now
end)

RegisterNetEvent("bms:drugdealer:showbal")
AddEventHandler("bms:drugdealer:showbal", function()
  local level = getAlcoholLevel()
  TriggerEvent("chatMessage", "SERVER", {0, 255, 0}, string.format("BAL: %s", level))
end)

Citizen.CreateThread(function()
  while true do
    Wait(1000)

    if (ishigh) then
      if (not GetScreenEffectIsActive("DrugsDrivingIn")) then
        StartScreenEffect("DrugsDrivingIn", 0, true)
      end
      
      curhightime = curhightime + 1000

      if (curhightime >= hightime) then
        ishigh = false

        if (GetScreenEffectIsActive("DrugsDrivingIn")) then
          StopScreenEffect("DrugsDrivingIn")
          StartScreenEffect("DrugsDrivingOut", 0, false)
        end
      end
    end

    if (isdrunk) then
      local ped = PlayerPedId()
      
      --SetTimecycleModifier("spectator5")
      --SetPedMotionBlur(ped, true)
      SetPedIsDrunk(ped, true)

      if (drinknum < 5) then
        if (not HasAnimSetLoaded("MOVE_M@DRUNK@SLIGHTLYDRUNK")) then
          RequestAnimSet("MOVE_M@DRUNK@SLIGHTLYDRUNK")
        
          while (not HasAnimSetLoaded("MOVE_M@DRUNK@SLIGHTLYDRUNK")) do
            Wait(0)
          end

          SetPedMovementClipset(ped, "MOVE_M@DRUNK@SLIGHTLYDRUNK", 1.0)
        end
      else
        --SetPedMotionBlur(ped, true)
        --SetPedIsDrunk(ped, true)
        SetTimecycleModifier("spectator5")

        if (not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK")) then
          RequestAnimSet("MOVE_M@DRUNK@VERYDRUNK")
        
          while (not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK")) do
            Wait(0)
          end

          SetPedMovementClipset(ped, "MOVE_M@DRUNK@VERYDRUNK", 1.0)
        end
      end
      
      curdrunktime = curdrunktime + 1000

      if (curdrunktime >= drunktime) then
        isdrunk = false
        curdrunktime = 0
        drinknum = 0
        ResetPedMovementClipset(ped, 0)
        ClearTimecycleModifier()
        ResetScenarioTypesEnabled()
        SetPedIsDrunk(ped, false)
        SetPedMotionBlur(ped, false)
      end
    end
  end
end)
