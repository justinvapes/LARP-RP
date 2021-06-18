local camModels = {
  "prop_v_cam_01",
  "prop_v_cam_custom_1",
  "prop_v_cam_custom_2"
}
local camAnimDict = "missfinale_c2mcs_1"
local camAnimName = "fin_c2_mcs_1_camman"
local micModel = "p_ing_microphonel_01"
local micAnimDict = "missheistdocksprep1hold_cellphone"
local micAnimName = "hold_cellphone"
local bmicModel = "prop_v_bmike_01"
local bmicAnimDict = "missfra1"
local bmicAnimName = "mcs2_crew_idle_m_boom"
local boomMicNetId = nil
local micNetId = nil
local camNetId = nil
local movieCamera = false
local newsCamera = false
-- camera
local fovMax = 70.0
local fovMin = 5.0
local zoomspeed = 10.0
local speedLr = 8.0
local speedUd = 8.0
local fov = (fovMax + fovMin) * 0.5
local UI = { 
	x = 0.000,
	y = -0.001,
}
local isNewsFac = false
local showNewsOverlay = true
local newsOverlayText = "Breaking News"
local newZ
local newX
local overlays = {active = 0, strength = 1.0, hashes = {"ArenaEMP", "ArenaEMP_Blend", "CAMERA_BW", "CAMERA_secuirity", "CAMERA_secuirity_FUZZ", "NG_filmic04", "NG_filmic06", "OrbitalCannon", "REDMIST", "RemixDrone", "eyeINtheSKY", "heliGunCam", "mugShot"}}
local showChatOnMessageVal = true
local helpKeyWasPressed = false
local taskWait = false
local vanSpots = {}
local heliSpots = {}
local blockSpawn = false
local newsVehicles = {heliHash = "polmav", vanHash = "weazelvan"}
local curNewsVehicle = 0
local newsBlips = {}
local lockSpots = {}
local blockLocks = false

local function math_round(num, numDecimalPlaces) -- TODO there are so many round functions in jobs resource, all global probably being called at once when something calls it.  They need localized.
  local mult = 10 ^ (numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

local function draw3DNewsText(x, y, z, text, sc)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, sc or 0.55 * scale)
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

local function addNewsBlips()
	for _,v in pairs(vanSpots) do
		local blip = AddBlipForCoord(v.pos)
							
		SetBlipSprite(blip, 562)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.9)
		SetBlipColour(blip, 3)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("News Van Pickup")
		EndTextCommandSetBlipName(blip)
		newsBlips[blip] = blip
	end

	for _,v in pairs(heliSpots) do
		local blip = AddBlipForCoord(v.pos)
							
		SetBlipSprite(blip, 602)
		SetBlipDisplay(blip, 4)
		SetBlipScale(blip, 0.9)
		SetBlipColour(blip, 3)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("News Helipad")
		EndTextCommandSetBlipName(blip)
		newsBlips[blip] = blip
	end
end

function hideHUDThisFrame()
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
	HideHudComponentThisFrame(1)
	HideHudComponentThisFrame(2)
	HideHudComponentThisFrame(3)
	HideHudComponentThisFrame(4)
	HideHudComponentThisFrame(6)
	HideHudComponentThisFrame(7)
	HideHudComponentThisFrame(8)
	HideHudComponentThisFrame(9)
	HideHudComponentThisFrame(13)
	HideHudComponentThisFrame(11)
	HideHudComponentThisFrame(12)
	HideHudComponentThisFrame(15)
	HideHudComponentThisFrame(18)
	HideHudComponentThisFrame(19)
end

function checkInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
  local rotation = GetCamRot(cam, 2)
  
	if (rightAxisX ~= 0.0 or rightAxisY ~= 0.0) then
		newZ = rotation.z + rightAxisX * -1.0 * (speedUd) * (zoomvalue + 0.1)
		newX = math.max(math.min(20.0, rotation.x + rightAxisY * -1.0 * (speedLr) * (zoomvalue + 0.1)), -89.5)
    SetCamRot(cam, newX, 0.0, newZ, 2)
	end
end

function handleZoom(cam)
  local lPed = PlayerPedId()
  
	if (not (IsPedInAnyVehicle(lPed, false))) then
		if (IsControlJustPressed(0, 241)) then
			fov = math.max(fov - zoomspeed, fovMin)
    end
    
		if (IsControlJustPressed(0, 242)) then
			fov = math.min(fov + zoomspeed, fovMax)
    end
    
    local current_fov = GetCamFov(cam)
    
		if (math.abs(fov - current_fov) < 0.1) then
			fov = current_fov
    end
    
		SetCamFov(cam, current_fov + (fov - current_fov) * 0.05)
	else
		if (IsControlJustPressed(0, 17)) then
			fov = math.max(fov - zoomspeed, fovMin)
    end
    
		if (IsControlJustPressed(0, 16)) then
			fov = math.min(fov + zoomspeed, fovMax)
    end
    
    local current_fov = GetCamFov(cam)
    
		if (math.abs(fov - current_fov) < 0.1) then
			fov = current_fov
    end
    
		SetCamFov(cam, current_fov + (fov - current_fov) * 0.05)
	end
end

function drawRct(x, y, width, height, r, g, b, a)
	DrawRect(x + width / 2, y + height / 2, width, height, r, g, b, a)
end

function drawOverlayText(text)
  SetTextColour(255, 255, 255, 255)
  SetTextFont(8)
  SetTextScale(1.2, 1.2)
  SetTextWrap(0.0, 1.0)
  SetTextCentre(false)
  SetTextDropshadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 205)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(0.2, 0.85)
end

function newsTimeoutPanel()
	SendNUIMessage({newsTimeoutOverlay = true, overlays = overlays})
end

local function taskAnimTimeout()
	taskWait = true
	
	SetTimeout(500, function()
		taskWait = false
	end)
end

local function playCamAnim()
	local ped = PlayerPedId()
	
	while (not HasAnimDictLoaded(camAnimDict)) do
		RequestAnimDict(camAnimDict)
		Wait(10)
	end
	
	TaskPlayAnim(ped, camAnimDict, camAnimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
	RemoveAnimDict(camAnimDict)
	taskAnimTimeout()
end

local function spawnNewsVan(spawn, plate)
	if (not spawn) then return end

	local hash = GetHashKey(newsVehicles.vanHash)

	while (not HasModelLoaded(hash)) do
		RequestModel(hash)
		Wait(10)
	end

	local van = CreateVehicle(hash, spawn.pos.x, spawn.pos.y, spawn.pos.z, spawn.heading, true, false)

	while (not DoesEntityExist(van)) do
		Wait(10)
	end

	local netid = NetworkGetNetworkIdFromEntity(van)

	SetVehicleNumberPlateText(van, plate)
	SetVehicleHasBeenOwnedByPlayer(van, true)
	SetVehicleNeedsToBeHotwired(van, false)
	SetVehicleDoorsLocked(van, 1)
  SetVehicleDoorsLockedForPlayer(van, PlayerId(), false)
	SetEntityAsMissionEntity(van, true, true)
	SetVehicleDirtLevel(van, 0)
  TriggerEvent("frfuel:filltankForVeh", van)	
	exports.vehicles:registerPulledVehicle(van)  
	TriggerServerEvent("bms:vehicles:registerJobVehicle", plate, newsVehicles.vanHash)
	TriggerServerEvent("bms:jobs:news:registerNewsVehicle", {netid = netid, plate = plate})
	SetModelAsNoLongerNeeded(hash)
	return van
end

local function spawnNewsHeli(spawn, plate)
	if (not spawn) then return end

	local hash = GetHashKey(newsVehicles.heliHash)

	while (not HasModelLoaded(hash)) do
		RequestModel(hash)
		Wait(10)
	end

	local heli = CreateVehicle(hash, spawn.pos.x, spawn.pos.y, spawn.pos.z, spawn.heading, true, false)

	while (not DoesEntityExist(heli)) do
		Wait(10)
	end

	local netid = NetworkGetNetworkIdFromEntity(heli)

	SetVehicleLivery(heli, 2)
	SetVehicleNumberPlateText(heli, plate)
	SetVehicleHasBeenOwnedByPlayer(heli, true)
	SetVehicleNeedsToBeHotwired(heli, false)
	SetVehicleDoorsLocked(heli, 1)
  SetVehicleDoorsLockedForPlayer(heli, PlayerId(), false)
	SetEntityAsMissionEntity(heli, true, true)
	SetVehicleDirtLevel(heli, 0)
  TriggerEvent("frfuel:filltankForVeh", heli)
	exports.vehicles:registerPulledVehicle(heli)  
  TriggerServerEvent("bms:vehicles:registerJobVehicle", plate, newsVehicles.heliHash)
	TriggerServerEvent("bms:jobs:news:registerNewsVehicle", {netid = netid, plate = plate})
	SetModelAsNoLongerNeeded(hash)
	return heli
end

RegisterNetEvent("bms:jobs:news:initializeNews")
AddEventHandler("bms:jobs:news:initializeNews", function(data)
	isNewsFac = true
	exports.actionmenu:addAction("Employment", "newscam", "none", "Get Camera", 4, "")
	exports.actionmenu:addAction("Employment", "newsmic", "none", "Get Microphone", 4, "")
	exports.actionmenu:addAction("Employment", "newsboommic", "none", "Get Boom Mic", 4, "")

	if (data.vanSpots) then
		vanSpots = data.vanSpots
	end

	if (data.heliSpots and data.heliFac) then
		heliSpots = data.heliSpots
	end

	addNewsBlips()
end)

RegisterNetEvent("bms:jobs:news:updateLocks")
AddEventHandler("bms:jobs:news:updateLocks", function(data)
	lockSpots = data.lockSpots or {}
end)

RegisterNetEvent("bms:jobs:news:togglenewscam")
AddEventHandler("bms:jobs:news:togglenewscam", function(overlayText)
	local ped = PlayerPedId()
	local veh = GetVehiclePedIsIn(ped)
  local cuffed = exports.cuff:isCuffed()
  local camModel = camModels[1]

  if (tonumber(overlayText) == 1) then
    camModel = camModels[2]
    overlayText = nil
  elseif (tonumber(overlayText) == 2) then
    camModel = camModels[3]
    overlayText = nil
  end

	if (not holdingCam) then
		local driver = veh and veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped

		if (driver) then
			exports.pnotify:SendNotification({text = "You can not use the news/movie camera while driving."})
			return
		end

		if (cuffed) then
			exports.pnotify:SendNotification({text = "You can not use the news/movie camera while hand cuffed."})
			return
		end

		if (overlayText) then
			newsOverlayText = overlayText
		end

		showChatOnMessageVal = exports.chat:showChatOnMessageValue()
        
    while not HasModelLoaded(GetHashKey(camModel)) do
			RequestModel(GetHashKey(camModel))
			Wait(100)
    end

    local ppos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
    local camspawned = CreateObject(GetHashKey(camModel), ppos.x, ppos.y, ppos.z, 1, 1, 1)
    
    Wait(1000)

    local netid = ObjToNet(camspawned)
		
		SetModelAsNoLongerNeeded(GetHashKey(camModel))
    SetNetworkIdExistsOnAllMachines(netid, true)
    NetworkSetNetworkIdDynamic(netid, true)
    AttachEntityToEntity(camspawned, ped, GetPedBoneIndex(ped, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
		TaskPlayAnim(ped, camAnimDict, camAnimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
    camNetId = netid
		holdingCam = true		
		exports.pnotify:SendNotification({text = "Hold <span style='color: skyblue'>H</span> for camera help."})
		exports.chat:toggleShowChatOnMessage(false)
  else
    ClearPedSecondaryTask(ped)
    DetachEntity(NetToObj(camNetId), 1, 1)
    DeleteEntity(NetToObj(camNetId))
    camNetId = nil
    holdingCam = false
		usingCam = false
		movieCamera = false
		newsCamera = false
		exports.pnotify:SendNotification({text = "Camera mode toggled off."})
		exports.chat:toggleShowChatOnMessage(showChatOnMessageVal)
		ClearTimecycleModifier()
		TriggerEvent("es:setMoneyDisplay", true)
		TriggerEvent("bms:csrp_gamemode:hideVoiceHud", false)
		SendNUIMessage({hideNewsOverlay = true})
		SendNUIMessage({hideNewsHelp = true})
  end
end)

RegisterNetEvent("bms:jobs:news:togglemic")
AddEventHandler("bms:jobs:news:togglemic", function()
	if (not holdingMic) then
		local cuffed = exports.cuff:isCuffed()

		if (cuffed) then
			exports.pnotify:SendNotification({text = "You can not use the mic while hand cuffed."})
			return
		end
    
    while not HasModelLoaded(GetHashKey(micModel)) do
			RequestModel(GetHashKey(micModel))
			Wait(100)
    end
  
    while not HasAnimDictLoaded(micAnimDict) do
      RequestAnimDict(micAnimDict)
      Wait(100)
    end

    local plyCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
    local micspawned = CreateObject(GetHashKey(micModel), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
    
    Wait(1000)
    
    local netid = ObjToNet(micspawned)
		
		SetModelAsNoLongerNeeded(GetHashKey(micModel))
		SetNetworkIdExistsOnAllMachines(netid, true)
    NetworkSetNetworkIdDynamic(netid, true)
    AttachEntityToEntity(micspawned, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.055, 0.05, 0.0, 240.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
    TaskPlayAnim(PlayerPedId(), micAnimDict, micAnimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
    RemoveAnimDict(micAnimDict)
    micNetId = netid
    holdingMic = true
  else
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(NetToObj(micNetId), 1, 1)
    DeleteEntity(NetToObj(micNetId))
    micNetId = nil
    holdingMic = false
    usingMic = false
  end
end)

RegisterNetEvent("bms:jobs:news:toggleboommic")
AddEventHandler("bms:jobs:news:toggleboommic", function()
	if (not holdingBmic) then
		local cuffed = exports.cuff:isCuffed()

		if (cuffed) then
			exports.pnotify:SendNotification({text = "You can not use the boom mic while hand cuffed."})
			return
		end
    
    while not HasModelLoaded(GetHashKey(bmicModel)) do
			RequestModel(GetHashKey(bmicModel))
			Wait(100)
    end

    local plyCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
    local bmicspawned = CreateObject(GetHashKey(bmicModel), plyCoords.x, plyCoords.y, plyCoords.z, true, true, false)
		
		while (not DoesEntityExist(bmicspawned)) do
			Wait(10)
		end
    
    local netid = ObjToNet(bmicspawned)
		
		SetModelAsNoLongerNeeded(GetHashKey(bmicModel))
    SetNetworkIdExistsOnAllMachines(netid, true)
    NetworkSetNetworkIdDynamic(netid, true)
    AttachEntityToEntity(bmicspawned, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), -0.08, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
    TaskPlayAnim(PlayerPedId(), bmicAnimDict, bmicAnimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
    boomMicNetId = netid
    holdingBmic = true
  else
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(NetToObj(boomMicNetId), 1, 1)
    DeleteEntity(NetToObj(boomMicNetId))
    boomMicNetId = nil
    holdingBmic = false
    usingBmic = false
  end
end)

RegisterNetEvent("bms:jobs:news:newsOverlay")
AddEventHandler("bms:jobs:news:newsOverlay", function(message)
	if (not message) then return end
	
	if (message:sub(1, 3) == "off") then
		showNewsOverlay = false
		return
	end

	newsOverlayText = message
end)

Citizen.CreateThread(function()
	while true do
    Wait(1)
    
		if (holdingBmic) then
			local ped = PlayerPedId()

			while (not HasAnimDictLoaded(bmicAnimDict)) do
				RequestAnimDict(bmicAnimDict)
				Wait(10)
			end

			local ragdoll = IsPedRagdoll(ped)

			if (not IsEntityPlayingAnim(ped, bmicAnimDict, bmicAnimName, 3) or ragdoll) then
				TaskPlayAnim(ped, bmicAnimDict, bmicAnimName, 1.0, -1, -1, 50, 0, 0, 0, 0)
			end
			
      RemoveAnimDict(bmicAnimDict)
			DisablePlayerFiring(PlayerId(), true)
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0, 44,  true) -- INPUT_COVER
			DisableControlAction(0,37,true) -- INPUT_SELECT_WEAPON
			SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
			
			if ((IsPedInAnyVehicle(ped) and GetPedVehicleSeat(ped) == -1) or IsPedCuffed(ped)) then
				ClearPedSecondaryTask(ped)
				DetachEntity(NetToObj(boomMicNetId), 1, 1)
				DeleteEntity(NetToObj(boomMicNetId))
				boomMicNetId = nil
				holdingBmic = false
				usingBmic = false
			end
		else
			Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
    Wait(1)
    
		if (holdingCam) then
			local ped = PlayerPedId()

			while (not HasAnimDictLoaded(camAnimDict)) do
				RequestAnimDict(camAnimDict)
				Wait(10)
			end
			
			local ragdoll = IsPedRagdoll(ped)

			if (not IsEntityPlayingAnim(ped, camAnimDict, camAnimName, 3) or ragdoll) then
				playCamAnim()
			end
        
      RemoveAnimDict(camAnimDict)
			DisablePlayerFiring(PlayerId(), true)
			DisableControlAction(0,25,true) -- disable aim
			DisableControlAction(0, 44,  true) -- INPUT_COVER
			DisableControlAction(0,37,true) -- INPUT_SELECT_WEAPON
			SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)

			if (IsControlJustPressed(1, 74)) then
				if (not helpKeyWasPressed) then
					helpKeyWasPressed = true
					SendNUIMessage({toggleCameraHelp = true, val = true})
				end
			elseif (IsControlJustReleased(1, 74)) then
				helpKeyWasPressed = false
				SendNUIMessage({toggleCameraHelp = true, val = false})
			end

			if (movieCamera) then
				if (IsControlJustPressed(1, 111) or IsDisabledControlJustPressed(1, 111)) then -- num 8
					overlays.active = overlays.active - 1
	
					if (overlays.active < 1) then
						overlays.active = #overlays.hashes
					end

					if (overlays.active == 0) then
						ClearTimecycleModifier()
						overlays.nameref = "Default"
						newsTimeoutPanel()
					else	
						ClearTimecycleModifier()
						SetTimecycleModifier(overlays.hashes[overlays.active])
						overlays.nameref = overlays.hashes[overlays.active]
						newsTimeoutPanel()
					end
				elseif (IsControlJustPressed(1, 110) or IsDisabledControlJustPressed(1, 110)) then -- num 5
					overlays.active = overlays.active + 1
	
					if (overlays.active > #overlays.hashes) then
						overlays.active = 0
					end

					if (overlays.active == 0) then
						ClearTimecycleModifier()
						overlays.nameref = "Default"
						newsTimeoutPanel()
					else	
						ClearTimecycleModifier()
						SetTimecycleModifier(overlays.hashes[overlays.active])
						overlays.nameref = overlays.hashes[overlays.active]
						newsTimeoutPanel()
					end
				elseif (IsControlJustReleased(1, 314)) then -- num +
					overlays.strength = overlays.strength + 0.05

					if (overlays.strength > 1) then
						overlays.strength = 1
					end
					
					SetTimecycleModifierStrength(overlays.strength)
					newsTimeoutPanel()
				elseif (IsControlJustReleased(1, 315)) then -- num -
					overlays.strength = overlays.strength - 0.05

					if (overlays.strength < 0) then
						overlays.strength = 0
					end

					SetTimecycleModifierStrength(overlays.strength)
					newsTimeoutPanel()
				end
			end
		else
			Wait(500)
		end
	end
end)

-- movie camera
Citizen.CreateThread(function()
	while true do
		Wait(1)

		if (holdingCam and IsControlJustReleased(1, 244) and not newsCamera) then
			local lPed = PlayerPedId()

			exports.hud:toggleVitals(false)
			movieCamera = true
      			
			local scaleform = RequestScaleformMovie("security_camera")

			while (not HasScaleformMovieLoaded(scaleform)) do
				Wait(10)
			end

			local lPed = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(lPed)
			local cam1 = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

			AttachCamToEntity(cam1, lPed, 0.0,0.0,1.0, true)
			SetCamRot(cam1, 2.0, 1.0, GetEntityHeading(lPed))
			SetCamFov(cam1, fov)
			RenderScriptCams(true, false, 0, 1, 0)
			PushScaleformMovieFunction(scaleform, "security_camera")
			PopScaleformMovieFunctionVoid()
			TriggerEvent("es:setMoneyDisplay", false)
			TriggerEvent("bms:csrp_gamemode:hideVoiceHud", true)

			while (movieCamera and not IsEntityDead(lPed) and (GetVehiclePedIsIn(lPed) == vehicle) and true) do
				if (IsControlJustReleased(0, 244)) then
					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
					movieCamera = false
					exports.hud:toggleVitals(true)
				end
				
				SetEntityRotation(lPed, 0, 0, newZ, 2, true)

				local zoomvalue = (1.0 / (fovMax-fovMin)) * (fov - fovMin)
        
        checkInputRotation(cam1, zoomvalue)
				handleZoom(cam1)
				hideHUDThisFrame()
				drawRct(UI.x + 0.0, UI.y + 0.0, 1.0, 0.15, 0, 0, 0, 255) -- Top Bar
				DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
				drawRct(UI.x + 0.0, UI.y + 0.85, 1.0, 0.16, 0, 0, 0, 255) -- Bottom Bar
				
				local camHeading = GetGameplayCamRelativeHeading()
				local camPitch = GetGameplayCamRelativePitch()
        
        if (camPitch < -70.0) then
					camPitch = -70.0
				elseif (camPitch > 42.0) then
					camPitch = 42.0
        end
        
				camPitch = (camPitch + 70.0) / 112.0
				
				if (camHeading < -180.0) then
					camHeading = -180.0
				elseif (camHeading > 180.0) then
					camHeading = 180.0
        end
        
				camHeading = (camHeading + 180.0) / 360.0				
				Citizen.InvokeNative(0xD5BB4025AE449A4E, PlayerPedId(), "Pitch", camPitch)
				Citizen.InvokeNative(0xD5BB4025AE449A4E, PlayerPedId(), "Heading", camHeading * -1.0 + 1.0)

				if (not IsEntityPlayingAnim(lPed, camAnimDict, camAnimName, 3) and not taskWait) then
					playCamAnim()
				end

				Wait(1)
			end

			movieCamera = false
			fov = (fovMax + fovMin) * 0.5
			RenderScriptCams(false, false, 0, 1, 0)
			SetScaleformMovieAsNoLongerNeeded(scaleform)
			DestroyCam(cam1, false)
			SetNightvision(false)
			SetSeethrough(false)
			ClearTimecycleModifier()
			TriggerEvent("es:setMoneyDisplay", true)
			TriggerEvent("bms:csrp_gamemode:hideVoiceHud", false)
		end
	end
end)

-- news camera
Citizen.CreateThread(function()
	while true do
		Wait(1)

		if (holdingCam and IsControlJustReleased(1, 38) and not movieCamera) then
			local lPed = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(lPed)
			local scaleform
			local scaleform2

			exports.hud:toggleVitals(false)
			newsCamera = true
			
			if (showNewsOverlay) then
				scaleform = RequestScaleformMovie("security_camera")
				scaleform2 = RequestScaleformMovie("breaking_news")

				while (not HasScaleformMovieLoaded(scaleform)) do
					Wait(10)
				end
				
				while (not HasScaleformMovieLoaded(scaleform2)) do
					Wait(10)
				end

				PushScaleformMovieFunction(scaleform, "SET_CAM_LOGO")
				PushScaleformMovieFunction(scaleform2, "breaking_news")
				PopScaleformMovieFunctionVoid()
			end

			local lPed = PlayerPedId()
			local vehicle = GetVehiclePedIsIn(lPed)
			local cam2 = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

			AttachCamToEntity(cam2, lPed, 0.0, 0.0, 1.0, true)
			SetCamRot(cam2, 2.0, 1.0,GetEntityHeading(lPed))
			SetCamFov(cam2, fov)
			RenderScriptCams(true, false, 0, 1, 0)
			TriggerEvent("es:setMoneyDisplay", false)
			TriggerEvent("bms:csrp_gamemode:hideVoiceHud", true)

			while (newsCamera and not IsEntityDead(lPed) and (GetVehiclePedIsIn(lPed) == vehicle) and true) do
				if (IsControlJustReleased(1, 38)) then
					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
					newsCamera = false
					exports.hud:toggleVitals(true)
				end

				SetEntityRotation(lPed, 0, 0, newZ, 2, true)
					
				local zoomvalue = (1.0 / (fovMax - fovMin)) * (fov - fovMin)

        checkInputRotation(cam2, zoomvalue)
				handleZoom(cam2)
				hideHUDThisFrame()

				if (showNewsOverlay) then
					DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
					DrawScaleformMovie(scaleform2, 0.5, 0.63, 1.0, 1.0, 255, 255, 255, 255)
					drawOverlayText(newsOverlayText)
				end
				
				local camHeading = GetGameplayCamRelativeHeading()
				local camPitch = GetGameplayCamRelativePitch()
        
        if (camPitch < -70.0) then
					camPitch = -70.0
				elseif (camPitch > 42.0) then
					camPitch = 42.0
        end
        
				camPitch = (camPitch + 70.0) / 112.0
				
				if (camHeading < -180.0) then
					camHeading = -180.0
				elseif (camHeading > 180.0) then
					camHeading = 180.0
        end
        
				camHeading = (camHeading + 180.0) / 360.0
				Citizen.InvokeNative(0xD5BB4025AE449A4E, lPed, "Pitch", camPitch)
				Citizen.InvokeNative(0xD5BB4025AE449A4E, lPed, "Heading", camHeading * -1.0 + 1.0)
				
				if (not IsEntityPlayingAnim(lPed, camAnimDict, camAnimName, 3) and not taskWait) then
					playCamAnim()
				end
				
				Wait(1)
			end

			newsCamera = false
			fov = (fovMax + fovMin) * 0.5
			RenderScriptCams(false, false, 0, 1, 0)
			
			if (scaleform) then
				SetScaleformMovieAsNoLongerNeeded(scaleform)
			end

			if (scaleform2) then
				SetScaleformMovieAsNoLongerNeeded(scaleform2)
			end

			DestroyCam(cam2, false)
			SetNightvision(false)
			SetSeethrough(false)
			ClearTimecycleModifier()
			TriggerEvent("es:setMoneyDisplay", true)
			TriggerEvent("bms:csrp_gamemode:hideVoiceHud", false)
		end
	end
end)

--[[ Master thread ]]
Citizen.CreateThread(function()
	while true do
		Wait(1)

		local ped = PlayerPedId()

		for _,v in pairs(vanSpots) do
			local pos = GetEntityCoords(ped)
			local dist = #(pos - v.pos)

			if (dist < 80) then
				if (curNewsVehicle ~= 0) then
					DrawMarker(1, v.retpos.x, v.retpos.y, v.retpos.z - 1.00001, 0, 0, 0, 0, 0, 0, 3.1, 3.1, 0.15, 240, 70, 70, 50, 0, 0, 0, 1, 0, 0, 0)
					dist = #(pos - v.retpos)

					if (dist < 1.55) then
						draw3DNewsText(v.retpos.x, v.retpos.y, v.retpos.z + 0.25, "Press ~b~[E]~w~ to return your ~g~news van~w~.", 0.26)
						
						if (IsControlJustReleased(1, 38) and not blockSpawn) then
							blockSpawn = true
							exports.management:TriggerServerCallback("bms:jobs:news:returnNewsVehicle", function(rdata)
								curNewsVehicle = 0
								blockSpawn = false
							end)
						end
					end
				else
					DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.00001, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 0.15, 120, 255, 70, 50, 0, 0, 0, 0, 0, 0, 0)
					
					if (dist < 0.6) then
						draw3DNewsText(v.pos.x, v.pos.y, v.pos.z + 0.25, "Press ~b~[E]~w~ to get a ~g~KTLA~w~ van.", 0.26)

						if (IsControlJustReleased(1, 38) and not blockSpawn) then
							if (curNewsVehicle ~= 0) then
								exports.pnotify:SendNotification({text = "You already have a news vehicle.  Return it before pulling another one."})
								return
							end
							
							blockSpawn = true
							exports.management:TriggerServerCallback("bms:jobs:news:spawnNewsVan", function(rdata)
								if (rdata) then
									if (rdata.success) then
                    curNewsVehicle = spawnNewsVan(v.spawn, rdata.plate)
                    SetVehicleLivery(curNewsVehicle, 0)
									else
										exports.pnotify:SendNotification({text = rdata.msg})
									end
								end
								
								blockSpawn = false
							end)
            end
					end
				end
			end
		end

		for _,v in pairs(heliSpots) do
			local pos = GetEntityCoords(ped)
			local dist = #(pos - v.pos)

			if (dist < 80) then
				if (curNewsVehicle ~= 0) then
					DrawMarker(1, v.retpos.x, v.retpos.y, v.retpos.z - 0.90001, 0, 0, 0, 0, 0, 0, 4.1, 4.1, 0.15, 240, 70, 70, 50, 0, 0, 0, 1, 0, 0, 0)
					dist = #(pos - v.retpos)

					if (dist < 1.55) then
						draw3DNewsText(v.retpos.x, v.retpos.y, v.retpos.z + 0.25, "Press ~b~[E]~w~ to return your ~g~news chopper~w~.", 0.26)
						
						if (IsControlJustReleased(1, 38) and not blockSpawn) then
							blockSpawn = true
							exports.management:TriggerServerCallback("bms:jobs:news:returnNewsVehicle", function(rdata)
								curNewsVehicle = 0
								blockSpawn = false
							end)
						end
					end
				else
					DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.00001, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 0.15, 120, 255, 70, 50, 0, 0, 0, 0, 0, 0, 0)
					
					if (dist < 0.6) then
						draw3DNewsText(v.pos.x, v.pos.y, v.pos.z + 0.25, "Press ~b~[E]~w~ to get a ~g~news chopper~w~.", 0.26)

						if (IsControlJustReleased(1, 38) and not blockSpawn) then
							if (curNewsVehicle ~= 0) then
								exports.pnotify:SendNotification({text = "You already have a news vehicle.  Return it before pulling another one."})
								return
							end
							
							blockSpawn = true
							exports.management:TriggerServerCallback("bms:jobs:news:spawnNewsChopper", function(rdata)
								if (rdata) then
									if (rdata.success) then
										curNewsVehicle = spawnNewsHeli(v.spawn, rdata.plate)
									else
										exports.pnotify:SendNotification({text = rdata.msg})
									end
								end
								
								blockSpawn = false
							end)
						end
					end
				end
			end
		end

		for lockSpotIndex, lockSpot in pairs(lockSpots) do
			local pos = GetEntityCoords(ped)
			local odist = #(pos - lockSpot.origin)

			if (odist < 80.0) then
				for lockIndex, lock in pairs(lockSpot.locks) do
					local ldist = #(pos - lock.pos)

					if (ldist < 5.0) then
						local door = GetClosestObjectOfType(lock.pos.x, lock.pos.y, lock.pos.z, 5.0, lock.hash, false)

						if (door) then
							if (lock.locked) then
								SetEntityHeading(door, lock.heading)
							elseif (lock.perm) then
								FreezeEntityPosition(door, true)
							end
						end

						if (ldist < 1.5 and not blockLocks and isNewsFac) then
							if (not lock.perm) then
								if (lock.locked) then
									draw3DNewsText(lock.pos.x, lock.pos.y, lock.pos.z, "Press ~b~[E]~w~ to ~g~unlock~w~ this door.", 0.28)
								else
									draw3DNewsText(lock.pos.x, lock.pos.y, lock.pos.z, "Press ~b~[E]~w~ to ~r~lock~w~ this door.", 0.28)
								end

								if (IsControlJustReleased(1, 38)) then
									blockLocks = true
									exports.management:TriggerServerCallback("bms:jobs:news:toggleLock", function(rdata)
										blockLocks = false
									end, {lockSpotIndex = lockSpotIndex, lockIndex = lockIndex, locked = not lock.locked})
								end
							end
						end
					end
				end
			end
		end
	end
end)