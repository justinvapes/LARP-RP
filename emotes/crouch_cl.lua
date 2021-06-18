local crouched = false
local crouchKey = 36 -- Left Control
local blockCrouching = false
local reactivateTime = {cur = 0, time = 5000} -- Reactivation time is randomized to stop idiots from macro tea bagging, though Broodjoker would love to have nuts in his mouth constantly. +/- 5 ms

function blockCrouch(val)
  blockCrouching = val
end

Citizen.CreateThread(function()
	while true do
    Wait(1)
    
    DisableControlAction(0, crouchKey, true)

    if (not IsPauseMenuActive()) then
      local ped = PlayerPedId()
      local dead = IsPedDeadOrDying(ped)

      if (GetPedStealthMovement(ped) or IsPedPerformingStealthKill(ped)) then
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 140, true)
        DisableControlAction(0, 141, true)
        DisableControlAction(0, 142, true)
      end

      if (not dead) then
        if (crouched) then
          SetPedCanPlayAmbientAnims(ped, false)
          SetPedCanPlayAmbientIdles(ped, false, false)
        end
        
        if (IsDisabledControlJustPressed(0, crouchKey)) then
          local handcuffed = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)
          local inVeh = IsPedInAnyVehicle(ped)
          local tased = IsPedBeingStunned(ped)
          local inWater = IsEntityInWater(ped)

          if (not handcuffed and not inVeh and not tased and not inWater and not blockCrouching) then
            local time = GetGameTimer()

            if (time > reactivateTime.cur) then
              ResetPedMovementClipset(ped, 0.0)
              
              while (not HasAnimSetLoaded("move_ped_crouched")) do
                RequestAnimSet("move_ped_crouched")
                Wait(10)
              end
              
              if (crouched) then
                ResetPedMovementClipset(ped, 0.0)
                crouched = false
                reactivateTime.cur = time + math.random(reactivateTime.time - 2000, reactivateTime.time)
              elseif (not crouched) then
                SetPedMovementClipset(ped, "move_ped_crouched", 0.55)
                crouched = true
              end

              RemoveAnimSet("move_ped_crouched")
            else
              exports.pnotify:SendNotification({text = string.format("Do not spam crouch.  You are not a frog.  Try again in <span style='color: skyblue'>%s</span> seconds.", math.ceil((reactivateTime.cur - time) / 1000))})
            end
          end
        end
      elseif (crouched) then
        crouched = false
      end
    end
  end
end)
