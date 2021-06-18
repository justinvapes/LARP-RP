local hasBeenDead = false
local weaponNames = {
  "WEAPON_KNIFE", "WEAPON_NIGHTSTICK", "WEAPON_HAMMER", "WEAPON_BAT", "WEAPON_GOLFCLUB", "WEAPON_CROWBAR",
  "WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_PISTOL50", "WEAPON_MICROSMG", "WEAPON_SMG", "WEAPON_ASSAULTSMG",
  "WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE", "WEAPON_ADVANCEDRIFLE", "WEAPON_MG", "WEAPON_COMBATMG", "WEAPON_PUMPSHOTGUN",
  "WEAPON_SAWNOFFSHOTGUN", "WEAPON_ASSAULTSHOTGUN", "WEAPON_BULLPUPSHOTGUN", "WEAPON_SNIPERRIFLE", 
  "WEAPON_HEAVYSNIPER", "WEAPON_GRENADELAUNCHER", "WEAPON_RPG", "WEAPON_MINIGUN", "WEAPON_GRENADE", "WEAPON_STICKYBOMB",
  "WEAPON_SMOKEGRENADE", "WEAPON_BZGAS", "WEAPON_MOLOTOV", "WEAPON_FIREEXTINGUISHER", "WEAPON_PETROLCAN", "WEAPON_BALL", "WEAPON_FLARE",
  "WEAPON_REVOLVER", "WEAPON_SWITCHBLADE", "WEAPON_STONE_HATCHET", "WEAPON_BOTTLE", "WEAPON_SNSPISTOL", "WEAPON_AUTOSHOTGUN", 
  "WEAPON_BATTLEAXE", "WEAPON_COMPACTLAUNCHER", "WEAPON_MINISMG", "WEAPON_PIPEBOMB", "WEAPON_POOLCUE", "WEAPON_WRENCH", 
  "WEAPON_HEAVYPISTOL", "WEAPON_SPECIALCARBINE", "WEAPON_BULLPUPRIFLE", "WEAPON_HOMINGLAUNCHER", "WEAPON_PROXMINE",
  "WEAPON_SNOWBALL", "WEAPON_BULLPUPRIFLE_MK2", "WEAPON_DOUBLEACTION", "WEAPON_MARKSMANRIFLE_MK2", "WEAPON_PUMPSHOTGUN_MK2",
  "WEAPON_REVOLVER_MK2", "WEAPON_SNSPISTOL_MK2", "WEAPON_SPECIALCARBINE_MK2", "WEAPON_RAYPISTOL", "WEAPON_RAYCARBINE",
  "WEAPON_RAYMINIGUN", "WEAPON_ASSAULTRIFLE_MK2", "WEAPON_CARBINERIFLE_MK2", "WEAPON_COMBATMG_MK2", "WEAPON_HEAVYSNIPER_MK2",
  "WEAPON_PISTOL_MK2", "WEAPON_SMG_MK2", "WEAPON_FLASHLIGHT", "WEAPON_FLAREGUN", "WEAPON_DAGGER", "WEAPON_VINTAGEPISTOL",
  "WEAPON_FIREWORK", "WEAPON_MUSKET", "WEAPON_MACHETE", "WEAPON_MACHINEPISTOL", "WEAPON_COMPACTRIFLE", "WEAPON_DBSHOTGUN",
  "WEAPON_HEAVYSHOTGUN", "WEAPON_MARKSMANRIFLE", "WEAPON_COMBATPDW", "WEAPON_KNUCKLE", "WEAPON_MARKSMANPISTOL", "WEAPON_GUSENBERG",
  "WEAPON_HATCHET", "WEAPON_RAILGUN", "WEAPON_GRENADELAUNCHER_SMOKE",
  "WEAPON_VEHICLE_ROCKET", "WEAPON_BARBED_WIRE", "WEAPON_DROWNING", "WEAPON_DROWNING_IN_VEHICLE", "WEAPON_BLEEDING", 
  "WEAPON_ELECTRIC_FENCE", "WEAPON_EXPLOSION", "WEAPON_FALL", "WEAPON_EXHAUSTION", "WEAPON_HIT_BY_WATER_CANNON", 
  "WEAPON_RAMMED_BY_CAR", "WEAPON_RUN_OVER_BY_CAR", "WEAPON_HELI_CRASH", "WEAPON_FIRE", "WEAPON_UNARMED", "WEAPON_STUNGUN",
}
local wepNameHashes = {}

function reverseWeps()
  for _, wep in pairs(weaponNames) do
    wepNameHashes[tostring(GetHashKey(wep))] = wep
  end
end

reverseWeps()

--[[function getWeaponDamagedBy()
  local ped = PlayerPedId()
  
  for i,v in ipairs(weaponNames) do
    if (HasPedBeenDamagedByWeapon(ped, GetHashKey(v), 0)) then
      return v
    end
  end

  return GetPedCauseOfDeath(ped)
end]]

function getWeaponDamagedBy(intHash)
  return wepNameHashes[tostring(intHash)]
end

Citizen.CreateThread(function()
  local isDead = false
  local diedAt
  
  while true do
    Wait(0)
    
    local player = PlayerId()
    
    if NetworkIsPlayerActive(player) then
      local ped = PlayerPedId()
      
      if (IsPedFatallyInjured(ped) and not isDead) then
        
        isDead = true
        
        if not diedAt then
          diedAt = GetGameTimer()
        end
        
        local killer = NetworkGetEntityKillerOfPlayer(player)
        local killerEntityType = GetEntityType(killer)
        local killerType = -1
        local killerInVeh = false
        local killerVehModel = ""
        local killerVehSeat = 0
        local killerSid = 0
        local killerId = GetPlayerByEntityID(killer)
        local killedVoice = exports.csrp_gamemode:getVoiceRange()
        local killerVoice = DecorGetInt(killer, "voiceRange")
        local killWep = getWeaponDamagedBy()
        local killerIsDriver = false

        if (killer == 0 or killer == -1) then
          killer = GetPedSourceOfDeath(player)
        end

        if (killerEntityType == 1) then
          killerType = GetPedType(killer)
          
          if (IsPedInAnyVehicle(killer, false) == 1) then
            killerInVeh = true
            killerVehModel = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(killer)))
            killerVehSeat = GetPedVehicleSeat(killer)
            
            if (killerVehSeat == -1 and IsPedAPlayer(killer)) then
              killerIsDriver = true
            end
          else
            killerInVeh = false
          end
        end
        
        if (killer ~= ped and killerId ~= nil and NetworkIsPlayerActive(killerId)) then
          killerId = GetPlayerServerId(killerId)
        else
          killerId = -1
        end

        --TriggerServerEvent("bms:serverprint", string.format("p: %s, k: %s, kEType: %s, kType: %s, kIVeh: %s, kVehMod: %s, kSid: %s, kId: %s, kVoice: %s, kWep: %s", 
        --  player, killer, killerEntityType, killerType, killerInVeh, killerVehModel, killerSid, killerId, killedVoice, killWep))
        
        if (killer == ped) then
          TriggerServerEvent("bms:baseevents:onPlayerDied")
          hasBeenDead = true
        else
          TriggerServerEvent("bms:onPlayerKilled", player, killerId, {killerType=killerType, killerInVeh=killerInVeh, killerVehSeat=killerVehSeat, killerVehModel=killerVehModel, killerPos=table.unpack(GetEntityCoords(ped)), killerSid = killerSid, killerIsDriver = killerIsDriver, killedVoice = killedVoice, killerVoice = killerVoice, killWep = killWep})
          hasBeenDead = true
        end
      elseif (not IsPedFatallyInjured(ped)) then
        isDead = false
        diedAt = nil
        hasBeenDead = false
      end
      
      -- check if the player has to respawn in order to trigger an event
      if (not hasBeenDead and diedAt ~= nil and diedAt > 0) then
        TriggerServerEvent("bms:baseevents:onPlayerWasted", { table.unpack(GetEntityCoords(ped)) })
        
        hasBeenDead = true
      elseif (hasBeenDead and diedAt ~= nil and diedAt <= 0) then
        hasBeenDead = false
      end
    end
  end
end)

AddEventHandler("gameEventTriggered", function(name, args)
  if (name == "CEventNetworkEntityDamage") then
    local victim = args[1]
    local attacker = args[2]
    local victimdied = args[6] == 1
    local wephash = args[7]
    local ismelee = args[12]
    local vehdmgflag = args[13]
    local ped = PlayerPedId()

    if (not hasBeenDead and victim ~= 0 and attacker ~= 0 and victimdied and victim == ped) then
      local killedVoice = exports.csrp_gamemode:getVoiceRange()
      local killerVoice = DecorGetInt(attacker, "voiceRange")
      --local wepname = getWeaponDamagedBy() -- This might not work if the client is out of sync and does not register a shot.  If not, replace with exports.devtools:getWeaponNameFromHash(wephash)
      local wepname = getWeaponDamagedBy(wephash)
      local aserverid = 0
      
      for _,id in pairs(GetActivePlayers()) do
        if (GetPlayerPed(id) == attacker) then
          aserverid = GetPlayerServerId(id)
          break
        end
      end

      local attveh = GetVehiclePedIsIn(attacker)
      local attdriving = attveh and GetPedInVehicleSeat(attveh, -1) == attacker
      local killerVehModel
      local pos = GetEntityCoords(ped)

      if (attveh and attdriving and attdriving ~= 0) then
        killerVehModel = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(attacker)))
      end
      
      TriggerServerEvent("bms:onPlayerKilled2", {victim = victim, attacker = aserverid, attackerdriving = attdriving, wephash = wephash, wepname = wepname, ismelee = ismelee, vehdmgflag = vehdmgflag, killedVoice = killedVoice, killerVoice = killerVoice, killerVehModel = killerVehModel or 0, pos = pos})
      TriggerEvent("bms:onPlayerKilled2", {victim = victim, attacker = aserverid, attackerdriving = attdriving, wephash = wephash, wepname = wepname, ismelee = ismelee, vehdmgflag = vehdmgflag, killedVoice = killedVoice, killerVoice = killerVoice, killerVehModel = killerVehModel or 0, pos = pos})
    end
  end
end)

function GetPlayerByEntityID(id)
  for _,v in ipairs(GetActivePlayers()) do
    if (GetPlayerPed(v) == id) then
      return v
    end
  end
  
  return nil
end

--[[Citizen.CreateThread(function()
    local isDead = false
    local hasBeenDead = false
	local diedAt

    while true do
        Wait(0)

        local player = PlayerId()

        if NetworkIsPlayerActive(player) then
            local ped = PlayerPedId()

            if IsPedFatallyInjured(ped) and not isDead then
                isDead = true
                if not diedAt then
                	diedAt = GetGameTimer()
                end

                local killer, killerweapon = NetworkGetEntityKillerOfPlayer(player)
				local killerentitytype = GetEntityType(killer)
				local killertype = -1
				local killerinvehicle = false
				local killervehiclename = ''
                local killervehicleseat = 0
				if killerentitytype == 1 then
					killertype = GetPedType(killer)
					if IsPedInAnyVehicle(killer, false) == 1 then
						killerinvehicle = true
						killervehiclename = GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(killer)))
                        killervehicleseat = GetPedVehicleSeat(killer)
					else killerinvehicle = false
					end
				end

				local killerid = GetPlayerByEntityID(killer)
				if killer ~= ped and killerid ~= nil and NetworkIsPlayerActive(killerid) then killerid = GetPlayerServerId(killerid)
				else killerid = -1
				end

                if killer == ped or killer == -1 then
                    TriggerEvent('baseevents:onPlayerDied', killertype, { table.unpack(GetEntityCoords(ped)) })
                    TriggerServerEvent('baseevents:onPlayerDied', killertype, { table.unpack(GetEntityCoords(ped)) })
                    hasBeenDead = true
                else
                    TriggerEvent('baseevents:onPlayerKilled', killerid, {killertype=killertype, weaponhash = killerweapon, killerinveh=killerinvehicle, killervehseat=killervehicleseat, killervehname=killervehiclename, killerpos=table.unpack(GetEntityCoords(ped))})
                    TriggerServerEvent('baseevents:onPlayerKilled', killerid, {killertype=killertype, weaponhash = killerweapon, killerinveh=killerinvehicle, killervehseat=killervehicleseat, killervehname=killervehiclename, killerpos=table.unpack(GetEntityCoords(ped))})
                    hasBeenDead = true
                end
            elseif not IsPedFatallyInjured(ped) then
                isDead = false
                diedAt = nil
            end

            -- check if the player has to respawn in order to trigger an event
            if not hasBeenDead and diedAt ~= nil and diedAt > 0 then
                TriggerEvent('baseevents:onPlayerWasted', { table.unpack(GetEntityCoords(ped)) })
                TriggerServerEvent('baseevents:onPlayerWasted', { table.unpack(GetEntityCoords(ped)) })

                hasBeenDead = true
            elseif hasBeenDead and diedAt ~= nil and diedAt <= 0 then
                hasBeenDead = false
            end
        end
    end
end)

function GetPlayerByEntityID(id)
	for i=0,64 do
		if(NetworkIsPlayerActive(i) and GetPlayerPed(i) == id) then return i end
	end
	return nil
end]]