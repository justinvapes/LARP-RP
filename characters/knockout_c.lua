local knockedOut = false
local wait = 20
local count = 60
local knockOutThreshold = 120
local afterKnockoutImmediate = false
local knockOutWeapons = {
	"WEAPON_UNARMED", "WEAPON_WRENCH", "WEAPON_POOLCUE", "WEAPON_BAT", "WEAPON_CROWBAR", "WEAPON_GOLFCLUB", "WEAPON_NIGHTSTICK", "WEAPON_HAMMER", "WEAPON_KNUCKLE", "WEAPON_FLASHLIGHT"
}
local meleeCoolDownWeapons = {
	"WEAPON_UNARMED", "WEAPON_KNUCKLE"
}
local hashedWeapons = {}
local hashedMelee = {}
local numberPunches = 1
local numberMaxPunches = 6
local lastPunchDelay = 3000
local lastPunchTime = 0
local punchCoolDown = false
local preExhaustTime = 0
local preExhaustTimeout = 5000
local isExhausted = false
local stagger = {active = false, fx = "DeathFailOut", fxout = "SwitchSceneNeutral", fxtimeout = 18000}
local pedveh = false
local handcuffed = false

function hashWeapons()
	for _,v in pairs(knockOutWeapons) do
		hashedWeapons[GetHashKey(v)] = true
	end

	for _,v in pairs(meleeCoolDownWeapons) do
		hashedMelee[GetHashKey(v)] = true
	end
end

hashWeapons()

function isValidMeleeWeapon(wep)
	for v,_ in pairs(hashedWeapons) do		
		if (v == wep) then
			return true
		end
	end
end

function isValidMeleeCoolDown(meleeWep)
	for v,_ in pairs(hashedMelee) do		
		if (v == meleeWep) then
			return true
		end
	end
end

function setStaggerEffects()
	if (not stagger.active) then
	  stagger.active = true
	  StopAllScreenEffects()
	  StartScreenEffect("DeathFailOut", 0, true)
	  local ped = PlayerPedId()
	  local sthash = "MOVE_M@BAIL_BOND_TAZERED"
  
	  while (not HasAnimSetLoaded(sthash)) do
		RequestAnimSet(sthash)
		Wait(10)
	  end
  
	  SetPedMovementClipset(ped, sthash, 1.0)
  
	  SetTimeout(stagger.fxtimeout, function()
		StopAllScreenEffects()
		ResetPedMovementClipset(ped)
		stagger.active = false
		RemoveAnimSet(sthash)
	  end)
	end
end

function exhaustPlayer()
	isExhausted = true
	Citizen.CreateThread(function()
		local ped = PlayerPedId()
		punchCoolDown = true
		--exports.pnotify:SendNotification({text = string.format("You are exhausted")})
				
		while (not HasAnimDictLoaded("move_m@_idles@out_of_breath")) do
			RequestAnimDict("move_m@_idles@out_of_breath")
			Wait(10)
		end
		
		SetTimecycleModifier("FRANKLIN")
		doTimecycleFade(true, 0.5, 1.0)
		Wait(6000)
		doTimecycleFade(false, 1.0, 0.0)
		punchCoolDown = false
		numberPunches = 1
		doEnableControl()
		--exports.pnotify:SendNotification({text = string.format("You have recovered")})
		StopAnimTask(ped, "move_m@_idles@out_of_breath", "idle_a", 2.0)
		RemoveAnimDict("move_m@_idles@out_of_breath")
		isExhausted = false
	end)
end

function doEnableControl()
	EnableControlAction(0, 24, true)
	EnableControlAction(0, 140, true)
	EnableControlAction(0, 141, true)
	EnableControlAction(0, 263, true)
	EnableControlAction(0, 264, true)
end

function doTimecycleFade(fadeIn, startStrength, toStrength)
	--true == fadeIN
	local fading = true
	local fadeCur = startStrength
	local strengthStep = 0.1
	
	SetTimecycleModifierStrength(startStrength)

	Citizen.CreateThread(function()
		while (fading) do
			if (fadeIn) then
        if (fadeCur < toStrength) then
          fadeCur = fadeCur + strengthStep
					SetTimecycleModifierStrength(fadeCur)
        else
          fading = false
				end
      else
        if (fadeCur > toStrength) then
          fadeCur = fadeCur - strengthStep
					SetTimecycleModifierStrength(fadeCur)
        else
          fading = false
        end

        if (fadeCur <= 0) then
          ClearTimecycleModifier()
        end
      end
			
			Wait(20)
		end
	end)
end

Citizen.CreateThread(function()
	while true do
		Wait(1)
		
		local ped = PlayerPedId()
		local _, wep = GetCurrentPedWeapon(ped)
		local _, meleeWep = GetCurrentPedWeapon(ped)

		if (punchCheck) then
			local currentTime = GetGameTimer()
			local difference = currentTime - lastPunchTime
			
			if (difference > lastPunchDelay) then
				numberPunches = 1
				lastPunchTime = 0
				punchCheck = false
			end
		end

		if (punchCoolDown) then
			DisableControlAction(0, 24, true)
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 141, true)
			DisableControlAction(0, 263, true)
			DisableControlAction(0, 264, true)
		end

		if (preExhaustTime > 0 and numberPunches < numberMaxPunches and not isExhausted) then
			local timeDiff = GetGameTimer() - preExhaustTime

			if (timeDiff > preExhaustTimeout) then
				preExhaustTime = 0
				doTimecycleFade(false, 0.6, 0.0)
			end
		end

		if (IsControlJustPressed(1, 24) or IsControlJustPressed(1, 140) or IsControlJustPressed(1, 263) or IsControlPressed(1, 25) and (IsControlJustPressed(1, 141) or IsControlJustPressed(1, 264))) then
			pedveh = IsPedInAnyVehicle(ped, false)
			handcuffed = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)

			if (isValidMeleeCoolDown(meleeWep) and not pedveh and not handcuffed) then
				numberPuchesPass = numberPunches
				numberPunches = numberPuchesPass + 1
				currentTime = GetGameTimer()
				lastPunchTime = currentTime
				punchCheck = false

				if (numberPunches == 4) then
					SetTimecycleModifier("FRANKLIN")
					doTimecycleFade(true, 0.1, 0.6)
					preExhaustTime = GetGameTimer()
				end

				if (numberPunches >= numberMaxPunches) then
					if (preExhaustTime > 0) then
						preExhaustTime = 0
					end

					exhaustPlayer()
				else 
					punchCheck = true
				end
			end
			if (not isValidMeleeCoolDown(meleeWep) and IsControlPressed(1, 25)) then
				DisableControlAction(0, 140, true)
				DisableControlAction(0, 263, true)
			end
		end

    if (IsPedInMeleeCombat(ped)) then
			if (isValidMeleeWeapon(wep) and HasPedBeenDamagedByWeapon(ped, wep, 0)) then
			--if (HasPedBeenDamagedByWeapon(ped, GetHashKey("WEAPON_UNARMED"), 0) )then
				if (GetEntityHealth(ped) < knockOutThreshold) then
					knockedOut = true
					SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0) 
					ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 2.5)
					setStaggerEffects()
					wait = 20
				end
			end
		end

		if (knockedOut) then
			if (not afterKnockoutImmediate) then
				afterKnockoutImmediate = true
			end
			
			SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
			ResetPedRagdollTimer(ped)
			SetTimecycleModifierStrength(1.0)
			SetTimecycleModifier("REDMIST")
			ShakeGameplayCam("VIBRATE_SHAKE", 1.0)
			
			if (wait >= 0) then
				count = count - 1
				
				if (count == 0) then
					count = 60
					wait = wait - 1
				end
			else
				SetEntityHealth(ped, knockOutThreshold + 1)
				doTimecycleFade(false, 1.0, 0.1)	
				knockedOut = false
			end
		else
			if (afterKnockoutImmediate) then
				afterKnockoutImmediate = false
			end
		end
	end
end)