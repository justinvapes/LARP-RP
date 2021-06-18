local states = {
	frozen = false,
	frozenPos = nil
}
local noclip = false
local ncslevel = 1.0

RegisterNetEvent("2jZXjAwqzqd92ZWFzfWo")
AddEventHandler("2jZXjAwqzqd92ZWFzfWo", function(v)
	local hash = GetHashKey(v)
	local ped = PlayerPedId()
	
	if (IsModelInCdimage(hash)) then
		while (not HasModelLoaded(hash)) do
			RequestModel(hash)
			Wait(10)
		end

		local pos = GetEntityCoords(ped)
		local head = GetEntityHeading(ped)

		local veh = CreateVehicle(hash, pos, head, true, false)
		
		while (not (DoesEntityExist(veh))) do
			Wait(10)
		end
		
		SetModelAsNoLongerNeeded(hash)
		SetEntityAsMissionEntity(veh, true, true)
		SetVehicleHasBeenOwnedByPlayer(veh, true)
		SetVehicleDirtLevel(veh, 0.0)
		SetVehicleNeedsToBeHotwired(veh, false)
							
		local id = NetworkGetNetworkIdFromEntity(veh)
		
		TaskWarpPedIntoVehicle(ped, veh, -1)
		ToggleVehicleMod(veh, 18, true)
		ToggleVehicleMod(veh, 22, true)
		SetVehicleModKit(veh, 0)
		SetVehicleMod(veh, 13, 2)
		SetVehicleMod(veh, 12, 2)
		SetVehicleMod(veh, 11, 2)
		SetVehicleMod(veh, 16, 4)
		exports.vehicles:registerPulledVehicle(veh)
		exports.fuel:setVehicleFuelLevel(veh, 65.0)
	else
		print("Model was not found in CdImage.")
	end
end)

RegisterNetEvent("es_admin:doHashes")
AddEventHandler("es_admin:doHashes", function(hashes)
	local done = 1
	Citizen.CreateThread(function()
		while done - 1 < #hashes do
			Citizen.Wait(50)
			TriggerServerEvent("es_admin:givePos", hashes[done] .. "=" .. GetHashKey(hashes[done]) .. "\n")
			TriggerEvent("chatMessage", "SYSTEM", {255, 0, 0}, "Vehicles left: " .. (#hashes - done) )
			done = done + 1
		end
	end)
end)

RegisterNetEvent("es_admin:getHash")
AddEventHandler("es_admin:getHash", function(h)
	TriggerEvent("chatMessage", "HASH", {255, 0, 0}, tostring(GetHashKey(h)))
end)

RegisterNetEvent("es_admin:freezePlayer")
AddEventHandler("es_admin:freezePlayer", function(state)
	local player = PlayerId()

	local ped = PlayerPedId()

	states.frozen = state
	states.frozenPos = GetEntityCoords(ped, false)

	if not state then
		if not IsEntityVisible(ped) then
			SetEntityVisible(ped, true)
		end

		if not IsPedInAnyVehicle(ped) then
			SetEntityCollision(ped, true)
		end

		FreezeEntityPosition(ped, false)
		--SetCharNeverTargetted(ped, false)
		SetPlayerInvincible(player, false)
	else
		SetEntityCollision(ped, false)
		FreezeEntityPosition(ped, true)
		--SetCharNeverTargetted(ped, true)
		SetPlayerInvincible(player, true)
		--RemovePtfxFromPed(ped)

		if not IsPedFatallyInjured(ped) then
			ClearPedTasksImmediately(ped)
		end
	end
end)

RegisterNetEvent("es_admin:slap")
AddEventHandler("es_admin:slap", function()
	local ped = PlayerPedId()

	ApplyForceToEntity(ped, 1, 9500.0, 3.0, 7100.0, 1.0, 0.0, 0.0, 1, false, true, false, false)
end)

RegisterNetEvent("es_admin:givePosition")
AddEventHandler("es_admin:givePosition", function()
	local pos = GetEntityCoords(PlayerPedId())
	local string = "{ ['x'] = " .. pos.x .. ", ['y'] = " .. pos.y .. ", ['z'] = " .. pos.z .. " },\n"
	TriggerServerEvent("es_admin:givePos", string)
	TriggerEvent("chatMessage", "SYSTEM", {255, 0, 0}, "Position saved to file.")
end)

RegisterNetEvent("es_admin:kill")
AddEventHandler("es_admin:kill", function()
	SetEntityHealth(PlayerPedId(), 0)
end)

RegisterNetEvent("es_admin:heal")
AddEventHandler("es_admin:heal", function()
	SetEntityHealth(PlayerPedId(), 200)
end)

RegisterNetEvent("es_admin:crash")
AddEventHandler("es_admin:crash", function()
	while true do
	end
end)

function drawCoords(text)
  --function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.32, 0.32)
  SetTextColour(255, 255, 0, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(0)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(text)
  EndTextCommandDisplayText(0.2, 0.94)
end

RegisterNetEvent("es_admin:noclip")
AddEventHandler("es_admin:noclip", function(t)
	local msg = "disabled"
  
  noclip = not noclip

	if(noclip)then
    msg = "enabled"
    noclip_pos = GetEntityCoords(PlayerPedId(), false)
  else 
    
  end

	TriggerEvent("chatMessage", "ADMIN", {255, 0, 0}, "Noclip has been ^2^*" .. msg)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
    if(states.frozen)then
      local ped = PlayerPedId()
			ClearPedTasksImmediately(ped)
			SetEntityCoords(ped, states.frozenPos)
		end
	end
end)

local heading = 0

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
    if (noclip) then

      DisableControlAction(0, 16, true)
      DisableControlAction(0, 17, true)
      
			local ped = PlayerPedId()
			local veh = GetVehiclePedIsIn(ped, false)
			local entity

			if (veh ~= 0) then
				entity = veh
			else
				entity = ped
			end

			drawCoords(string.format("[%s, %s, %s (Heading: %s, Speed: %s)]", noclip_pos.x, noclip_pos.y, noclip_pos.z, heading, ncslevel))
			SetEntityCoordsNoOffset(entity,  noclip_pos.x,  noclip_pos.y,  noclip_pos.z,  0, 0, 0)

			if (IsControlPressed(1, 34)) then
				heading = heading + 1.5
				if (heading > 360) then
					heading = 0
				end
				SetEntityHeading(entity,  heading)
			end
			
			if (IsControlPressed(1, 9)) then
				heading = heading - 1.5
				
				if (heading < 0) then
					heading = 360
				end
				
				SetEntityHeading(entity,  heading)
			end

			if (IsControlJustReleased(1, 96) or IsDisabledControlJustReleased(1, 96)) then
				if (ncslevel == 0.025) then
					ncslevel = 1.0
				elseif (ncslevel == 1.0) then
					ncslevel = 3.0
				elseif (ncslevel == 3.0) then
					ncslevel = 0.025
				end
			end

			if (IsControlJustReleased(1, 97) or IsDisabledControlJustReleased(1, 97)) then
				if (ncslevel == 3.0) then
					ncslevel = 1.0
				elseif (ncslevel == 1.0) then
					ncslevel = 0.025
				elseif (ncslevel == 0.025) then
					ncslevel = 3.0
				end
			end

			if (IsControlPressed(1, 8)) then
				noclip_pos = GetOffsetFromEntityInWorldCoords(entity, 0.0, ncslevel, 0.0)
			end
			
			if (IsControlPressed(1, 32)) then
				noclip_pos = GetOffsetFromEntityInWorldCoords(entity, 0.0, -ncslevel, 0.0)
			end

			if (IsControlPressed(1, 27)) then
				noclip_pos = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, ncslevel)
			end

			if (IsControlPressed(1, 173)) then
				noclip_pos = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, -ncslevel)
			end
		end
	end
end)
