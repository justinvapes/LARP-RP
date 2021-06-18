local blockhandsup = false
local handsup = false

function blockHandsUp(toggle)
  blockhandsup = toggle
end

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    
    if (handsup) then
      DisablePlayerFiring(ped, true)
      DisableControlAction(0, 24, true) -- Attack
      HideHudAndRadarThisFrame()
    end
  end
end)

-- Hands Up
RegisterCommand("+handsUp", function()
  if (not blockhandsup) then
    local ped = PlayerPedId()

    if (not IsPedInAnyVehicle(ped, false) and not IsPedSwimming(ped) and not IsPedShooting(ped) and not IsPedClimbing(ped) and not IsPedDiving(ped) and not IsPedFalling(ped) and not IsPedJumping(ped) and not IsPedJumpingOutOfVehicle(ped) and IsPedOnFoot(ped) and not IsPedRunning(ped) and not IsPedUsingAnyScenario(ped) and not IsPedInParachuteFreeFall(ped)) then
      if (DoesEntityExist(ped)) then
        Citizen.CreateThread(function()
          RequestAnimDict("random@mugging3")
          
          while not HasAnimDictLoaded("random@mugging3") do
            Citizen.Wait(10)
          end
          
          TaskPlayAnim(ped, "random@mugging3", "handsup_standing_base", 2.0, -2, -1, 49, 0, 0, 0, 0)
          RemoveAnimDict("random@mugging3")
          exports.csrp_gamemode:blockPointing(true)
          handsup = true
        end)
      end
    end
  end
end)

RegisterCommand("-handsUp", function()
  if (not blockhandsup) then
    local ped = PlayerPedId()

    if (DoesEntityExist(ped)) then
      if (IsEntityPlayingAnim(ped, "random@mugging3", "handsup_standing_base", 3)) then
        StopAnimTask(ped, "random@mugging3", "handsup_standing_base", 1.7)
        RemoveAnimDict("random@mugging3")
        DisablePlayerFiring(ped, false)
        exports.csrp_gamemode:blockPointing(false)
        handsup = false
      end
    end
  end
end)
RegisterKeyMapping("+handsUp", "Hands Up", "keyboard", "X")
