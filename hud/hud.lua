local DrawRect = DrawRect
local DrawText = DrawText

local compass = {
  cardinal={
    textSize = 0.25,
    textOffset = 0.015,
    tickShow = true,
    tickSize = {w = 0.001, h = 0.012},
    tickColour = {r = 255, g = 255, b = 255, a = 255}
  },
  intercardinal={
    show = true,
    textShow = true,
    textSize = 0.2,
    textOffset = 0.015,
    tickShow = true,
    tickSize = {w = 0.001, h = 0.006},
    tickColour = {r = 255, g = 255, b = 255, a = 255}
  },
  show = false,
  position = {x = 0.5, y = 0.07, centered = true},
  width = 0.25,
  fov = 180,
  followGameplayCam = true,
  ticksBetweenCardinals = 15.0,
  tickColour = {r = 255, g = 255, b = 255, a = 255},
  tickSize = {w = 0.001, h = 0.003},
}
local compInit = false
local pxDegree = 0
local streetName = {
  show = false, position = {x = 0.5, y = 0.02}, textSize = 0.35
}
local zones = { 
  ["AIRP"] = "Los Santos International Airport", ["ALAMO"] = "Alamo Sea", ["ALTA"] = "Vinewood", ["ARMYB"] = "Fort Zancudo", 
  ["BANHAMC"] = "Banham Canyon Dr", ["BANNING"] = "Banning", ["BEACH"] = "Vespucci Beach", ["BHAMCA"] = "Banham Canyon", 
  ["BRADP"] = "Braddock Pass", ["BRADT"] = "Braddock Tunnel", ["BURTON"] = "West Vinewood", ["CALAFB"] = "Calafia Bridge", 
  ["CANNY"] = "Raton Canyon", ["CCREAK"] = "Cassidy Creek", ["CHAMH"] = "Chamberlain Hills", ["CHIL"] = "Vinewood Hills",
  ["CHU"] = "Chumash", ["CMSW"] = "Chiliad Mountain State Wilderness", ["CYPRE"] = "Cypress Flats", ["DAVIS"] = "Downtown", 
  ["DELBE"] = "Del Perro Beach", ["DELPE"] = "Del Perro", ["DELSOL"] = "La Puerta", ["DESRT"] = "Grand Senora Desert", 
  ["DOWNT"] = "Downtown", ["DTVINE"] = "Downtown Vinewood", ["EAST_V"] = "East Vinewood", ["EBURO"] = "El Burro Heights", 
  ["ELGORL"] = "El Gordo Lighthouse", ["ELYSIAN"] = "Elysian Island", ["GALFISH"] = "Galilee", ["GOLF"] = "Golfing Society", 
  ["GRAPES"] = "Grapeseed", ["GREATC"] = "Great Chaparral", ["HARMO"] = "Harmony", ["HAWICK"] = "Vinewood", 
  ["HORS"] = "Vinewood Racetrack", ["HUMLAB"] = "Humane Labs and Research", ["JAIL"] = "Bolingbroke Penitentiary", 
  ["KOREAT"] = "Little Seoul", ["LACT"] = "Land Act Reservoir", ["LAGO"] = "Lago Zancudo", ["LDAM"] = "Land Act Dam", 
  ["LEGSQU"] = "Legion Square", ["LMESA"] = "Downtown", ["LOSPUER"] = "La Puerta", ["MIRR"] = "Mirror Park", 
  ["MORN"] = "Rockford Hills", ["MOVIE"] = "Richards Majestic", ["MTCHIL"] = "Mount Chiliad", ["MTGORDO"] = "Mount Gordo", 
  ["MTJOSE"] = "Mount Josiah", ["MURRI"] = "Murrieta", ["NCHU"] = "North Chumash", ["NOOSE"] = "N.O.O.S.E", 
  ["OCEANA"] = "Pacific Ocean", ["PALCOV"] = "Paleto Cove", ["PALETO"] = "Paleto Bay", ["PALFOR"] = "Paleto Forest", 
  ["PALHIGH"] = "Palomino Highlands", ["PALMPOW"] = "Palmer-Taylor Power Station", ["PBLUFF"] = "Pacific Bluffs", 
  ["PBOX"] = "Downtown", ["PROCOB"] = "Procopio Beach", ["RANCHO"] = "Rancho", ["RGLEN"] = "Richman Glen", 
  ["RICHM"] = "Rockford Hills", ["ROCKF"] = "Rockford Hills", ["RTRAK"] = "Redwood Lights Track", ["SANAND"] = "San Andreas", 
  ["SANCHIA"] = "San Chianski Mountain Range", ["SANDY"] = "Sandy Shores", ["SKID"] = "Mission Row", ["SLAB"] = "Stab City",
  ["STAD"] = "Maze Bank Arena", ["STRAW"] = "Downtown", ["TATAMO"] = "Tataviam Mountains", ["TERMINA"] = "Terminal", 
  ["TEXTI"] = "Downtown", ["TONGVAH"] = "Tongva Hills", ["TONGVAV"] = "Tongva Valley", ["VCANA"] = "Vespucci Canals", 
  ["VESP"] = "Vespucci", ["VINE"] = "Vinewood", ["WINDF"] = "Ron Alternates Wind Farm", ["WVINE"] = "West Vinewood", 
  ["ZANCUDO"] = "Zancudo River", ["ZP_ORT"] = "Port of South Los Santos", ["ZQ_UAR"] = "Davis Quartz" 
}
local hideHud = false
local checkEngineShowing = false
local lowFuelShowing = false
local seatbeltShowing = false
local nitrousShowing = true
local config = {
  border = {r = 255, g = 255, _b = 255, a = 100},
  dir = {r = 255, g = 255, b = 255, a = 255},
  street = {r = 255, g = 255, b = 0, a = 255},
  town = {r = 255, g = 255, b = 255, a = 255},
  lowFuel = {r = 190, g = 25, b = 25, a = 255},
  highFuel = {r = 135, g = 206, b = 250, a = 255}
}
local fuelPercentage = 0
local isElectric = false
local current_zone = nil
local streetname = nil
local direction = nil
local seatbeltToggle = false
local minimap = {}

local function vehicleFuelLevel(veh)
  return exports.fuel:vehicleFuelLevel(veh)
end

function drawTxt(x, y, font, scale, text, r, g, b, a)
  SetTextFont(font)
  SetTextScale(scale, scale)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextOutline()
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
end

-- DrawText method wrapper, draws text to the screen.
-- @param1	string	The text to draw
-- @param2	float	Screen x-axis coordinate
-- @param3	float	Screen y-axis coordinate
-- @param4	table	Optional. Styles to apply to the text
-- @return
function drawCompassText(str, x, y, style)
	if style == nil then
		style = {}
	end
	
	SetTextFont((style.font ~= nil) and style.font or 0)
	SetTextScale(0.0, (style.size ~= nil) and style.size or 1.0)
	SetTextProportional(1)
  SetTextColour(255, 255, 255, 255)
	SetTextDropShadow(0, 0, 0, 0, 255)
	SetTextCentre(true)
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(str)
	DrawText(x, y)
end

-- Converts degrees to (inter)cardinal directions.
-- @param1	float	Degrees. Expects EAST to be 90° and WEST to be 270°.
-- 					In GTA, WEST is usually 90°, EAST is usually 270°. To convert, subtract that value from 360.
--
-- @return			The converted (inter)cardinal direction.
function degreesToIntercardinalDirection(dgr)
	dgr = dgr % 360.0
	
	if (dgr >= 0.0 and dgr < 22.5) or dgr >= 337.5 then
		return "N"
	elseif dgr >= 22.5 and dgr < 67.5 then
		return "NE"
	elseif dgr >= 67.5 and dgr < 112.5 then
		return "E"
	elseif dgr >= 112.5 and dgr < 157.5 then
		return "SE"
	elseif dgr >= 157.5 and dgr < 202.5 then
		return "S"
	elseif dgr >= 202.5 and dgr < 247.5 then
		return "SW"
	elseif dgr >= 247.5 and dgr < 292.5 then
		return "W"
	elseif dgr >= 292.5 and dgr < 337.5 then
		return "NW"
	end
end

-- Begins checking resolution and scaling the hud appropriately
function initialize()
  Wait(5000)
  Citizen.CreateThread(function()
    while true do
      updateHudPos()
      Wait(60000)
    end
  end)
end

-- Retrieved from https://gitlab.com/inkietud-rp/fivem-minimap-anchors
function updateHudPos()
  -- Safezone goes from 1.0 (no gap) to 0.9 (5% gap (1/20))
  -- 0.05 * ((safezone - 0.9) * 10)
  local safezone = GetSafeZoneSize()
  local safezone_x = 1.0 / 20.0
  local safezone_y = 1.0 / 20.0
  local aspect_ratio = GetAspectRatio(0)
  if aspect_ratio > 2 then aspect_ratio = 16/9 end
  local res_x, res_y = GetActiveScreenResolution()
  local xscale = 1.0 / res_x
  local yscale = 1.0 / res_y
  minimap.width = xscale * (res_x / (4 * aspect_ratio))
  minimap.height = yscale * (res_y / 5.674)
  minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
  
  if GetAspectRatio(0) > 2 then
    minimap.left_x = minimap.left_x + minimap.width * 0.89
    minimap.width = minimap.width * 0.75
  elseif GetAspectRatio(0) > 1.8 then
    minimap.left_x = minimap.left_x + minimap.width * 0.2225
    minimap.width = minimap.width * 0.995
  end

  minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.0)) * 10)))
  minimap.right_x = minimap.left_x + minimap.width
  minimap.top_y = minimap.bottom_y - minimap.height
  minimap.x = minimap.left_x
  minimap.y = minimap.top_y
  minimap.xunit = xscale
  minimap.yunit = yscale
  
  TriggerEvent("bms:hud:updateHudPos", minimap)
  SendNUIMessage({updateHudPos = true, data = minimap})
end

function toggleVitals(val)
  if (val) then
    SendNUIMessage({showVitals = true})
  else
    SendNUIMessage({hideVitals = true})
  end
end

function updateVitals(hunger, thirst)
  SendNUIMessage({updateVitals = true, hungerval = hunger, thirstval = thirst})
end

AddEventHandler("bms:char:charLoggedIn", function()
  initialize()
end)

AddEventHandler("onResourceStart", function(resource)
  if (resource == GetCurrentResourceName()) then
    initialize()
  end
end)

RegisterNetEvent("bms:hud:hideCarHud")
AddEventHandler("bms:hud:hideCarHud", function(val)
  hideHud = val
end)

RegisterNetEvent("bms:hud:toggleSeatbelt")
AddEventHandler("bms:hud:toggleSeatbelt", function(val)
  seatbeltToggle = val
end)

RegisterNetEvent("bms:hud:toggleCompass")
AddEventHandler("bms:hud:toggleCompass", function()
  if (not compInit) then
    compass.position.x = compass.position.x - compass.width / 2
    pxDegree = compass.width / compass.fov
    compInit = true
  end

  compass.show = not compass.show
	streetName.show = not streetName.show
end)

Citizen.CreateThread(function()
  --[[local minimapScaleform = RequestScaleformMovie("minimap")
  SetRadarBigmapEnabled(true, false)
  Wait(0)
  SetRadarBigmapEnabled(false, false)]]

  while true do
    Wait(1)
    if (not hideHud) then
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local veh = GetVehiclePedIsIn(ped, false)

      -- Streetname for compass
      if (streetName.show) then                    
        drawCompassText(streetname, streetName.position.x, streetName.position.y, {size = streetName.textSize, font = 4})
      end
      -- Compass
      if (compass.show) then
        local playerHeadingDegrees = 0
        
        if (compass.followGameplayCam) then
          -- Converts [-180, 180] to [0, 360] where E = 90 and W = 270
          local camRot = Citizen.InvokeNative(0x837765A25378F0BB, 0, Citizen.ResultAsVector())
          playerHeadingDegrees = 360.0 - ((camRot.z + 360.0) % 360.0)
        else
          -- Converts E = 270 to E = 90
          playerHeadingDegrees = 360.0 - GetEntityHeading(ped)
        end
        
        local tickDegree = playerHeadingDegrees - compass.fov / 2
        local tickDegreeRemainder = compass.ticksBetweenCardinals - (tickDegree % compass.ticksBetweenCardinals)
        local tickPosition = compass.position.x + tickDegreeRemainder * pxDegree
        
        tickDegree = tickDegree + tickDegreeRemainder
        
        while (tickPosition < compass.position.x + compass.width) do
          if (tickDegree % 90.0) == 0 then
            -- Draw cardinal
            DrawRect(tickPosition, compass.position.y, compass.cardinal.tickSize.w, compass.cardinal.tickSize.h, compass.cardinal.tickColour.r, compass.cardinal.tickColour.g, compass.cardinal.tickColour.b, compass.cardinal.tickColour.a )
            
            drawCompassText(degreesToIntercardinalDirection(tickDegree), tickPosition, compass.position.y + compass.cardinal.textOffset, {size = compass.cardinal.textSize})
          elseif (tickDegree % 45.0) == 0 and compass.intercardinal.show then
            -- Draw intercardinal
            if (compass.intercardinal.tickShow) then
              DrawRect(tickPosition, compass.position.y, compass.intercardinal.tickSize.w, compass.intercardinal.tickSize.h, compass.intercardinal.tickColour.r, compass.intercardinal.tickColour.g, compass.intercardinal.tickColour.b, compass.intercardinal.tickColour.a )
            end
            
            if (compass.intercardinal.textShow) then
              drawCompassText(degreesToIntercardinalDirection(tickDegree), tickPosition, compass.position.y + compass.intercardinal.textOffset, {size = compass.intercardinal.textSize})
            end
          else
            -- Draw tick
            DrawRect(tickPosition, compass.position.y, compass.tickSize.w, compass.tickSize.h, compass.tickColour.r, compass.tickColour.g, compass.tickColour.b, compass.tickColour.a )
          end
          
          -- Advance to the next tick
          tickDegree = tickDegree + compass.ticksBetweenCardinals
          tickPosition = tickPosition + pxDegree * compass.ticksBetweenCardinals
        end
      end

      if (veh ~= 0 and veh ~= nil) then
        local vehPlate = GetVehicleNumberPlateText(veh)
        local vehEngineHealth = GetVehicleEngineHealth(veh)
        local vehBodyHealth = GetVehicleBodyHealth(veh)
        local mph = GetEntitySpeed(veh) * 2.236936
        local vehClass = GetVehicleClass(veh)

        --[[if (not IsRadarEnabled()) then
          DisplayRadar(true)
        end

        BeginScaleformMovieMethod(minimapScaleform, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()]]

        if (minimap.x) then
          --DrawRect(0.133, 0.947, 0.046, 0.03, 0, 0, 0, 100) 	-- UI: panel mph\
          --print(minimap.right_x)
          DrawRect(minimap.x + minimap.width * 0.5, minimap.y - (minimap.height * 0.07), minimap.width, minimap.height * 0.125, 0, 0, 0, 100) 	-- UI:PLATE
          drawTxt(minimap.right_x - minimap.width * 0.33333, minimap.bottom_y - minimap.height * 0.33333, 4, 0.64 , tostring(math.ceil(mph)), 255, 255, 255, 255)
          drawTxt(minimap.right_x - minimap.width * 0.33333 + 0.023, minimap.bottom_y - minimap.height * 0.33333 + 0.01, 4, 0.4, "mph", 255, 255, 255, 255)
          drawTxt(minimap.x + 0.005, minimap.y - (minimap.height * 0.125) - 0.004, 4, 0.4, "Plate: " .. vehPlate, 255, 255, 255, 255)
        else
          --DrawRect(0.133, 0.947, 0.046, 0.03, 0, 0, 0, 100) 	-- UI: panel mph
          DrawRect(0.085375, 0.7955, 0.14075, 0.021, 0, 0, 0, 100) 	-- UI:PLATE
          drawTxt(0.11, 0.926, 4, 0.64 , tostring(math.ceil(mph)), 255, 255, 255, 255)
          drawTxt(0.133, 0.936, 4, 0.4, "mph", 255, 255, 255, 255)
          drawTxt(0.020, 0.781, 4, 0.40, "Plate: " .. vehPlate, 255, 255, 255, 255)
        end
        
        if (((vehEngineHealth > 0) and (vehEngineHealth < 700)) or ((vehBodyHealth > 0) and (vehBodyHealth < 700))) then
          if (not checkEngineShowing) then
            SendNUIMessage({showCheckEngine = true})
            checkEngineShowing = true	
          end
        else
          if (checkEngineShowing) then
            SendNUIMessage({hideCheckEngine = true})
            checkEngineShowing = false
          end
        end

        if (fuelPercentage and vehClass ~= 13) then
          if (fuelPercentage < 20) then
            if (not lowFuelShowing) then
              SendNUIMessage({showLowFuel = true})
              lowFuelShowing = true
            end
          else
            if (lowFuelShowing) then
              SendNUIMessage({hideLowFuel = true})
              lowFuelShowing = false
            end
          end

          if (minimap.x) then
            if (fuelPercentage < 10) then
              drawTxt(minimap.right_x - minimap.width * 0.275, minimap.y - (minimap.height * 0.125) - 0.004, 4, 0.40, string.format("Fuel: %s%%", fuelPercentage), config.lowFuel.r, config.lowFuel.g, config.lowFuel.b, config.lowFuel.a)
            else
              drawTxt(minimap.right_x - minimap.width * 0.275, minimap.y - (minimap.height * 0.125) - 0.004, 4, 0.40, string.format("Fuel: %s%%", fuelPercentage), config.highFuel.r, config.highFuel.g, config.highFuel.b, config.highFuel.a)
            end
          else
            if (fuelPercentage < 10) then
              drawTxt(0.117, 0.781, 4, 0.40, string.format("Fuel: %s%%", fuelPercentage), config.lowFuel.r, config.lowFuel.g, config.lowFuel.b, config.lowFuel.a)
            else
              drawTxt(0.117, 0.781, 4, 0.40, string.format("Fuel: %s%%", fuelPercentage), config.highFuel.r, config.highFuel.g, config.highFuel.b, config.highFuel.a)
            end
          end
        elseif (isElectric or vehClass == 13) then
          if (lowFuelShowing) then
            SendNUIMessage({hideLowFuel = true})
            lowFuelShowing = false
          end
        end

        if (minimap.x) then
          if (streetname ~= nil) then
            drawTxt(minimap.x + 0.0282, 0.76, 4, 0.39, streetname, config.street.r, config.street.g, config.street.b, config.street.a)
          end

          if (direction ~= nil and direction ~= "") then
            drawTxt(minimap.x - 0.0035, 0.750, 4, 0.5, " | ", config.border.r, config.border.g, config.border.b, config.border.a)
            drawTxt(minimap.x + 0.0195, 0.750, 4, 0.5, " | ", config.border.r, config.border.g, config.border.b, config.border.a)

            if (direction == "N") then
              drawTxt(minimap.x + 0.0085, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            elseif (direction == "NE") then 
              drawTxt(minimap.x + 0.006, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            elseif (direction == "E") then 
              drawTxt(minimap.x + 0.0095, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            elseif (direction == "SE") then 
              drawTxt(minimap.x + 0.006, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            elseif (direction == "S") then
              drawTxt(minimap.x + 0.009, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            elseif (direction == "SW") then
              drawTxt(minimap.x + 0.0041, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)	
            elseif (direction == "W") then 
              drawTxt(minimap.x + 0.0076, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            elseif (direction == "NW") then
              drawTxt(minimap.x + 0.004, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            end
          end

          if (current_zone ~= nil) then
            drawTxt(minimap.x + 0.0285, 0.748, 6, 0.27, current_zone, config.town.r, config.town.g, config.town.b, config.town.a)
          end
        else
          if (streetname ~= nil) then
            drawTxt(0.0417, 0.76, 4, 0.39, streetname, config.street.r, config.street.g, config.street.b, config.street.a)
          end
  
          if (direction ~= nil and direction ~= "") then
            drawTxt(0.01, 0.750, 4, 0.5, " | ", config.border.r, config.border.g, config.border.b, config.border.a)
            drawTxt(0.033, 0.750, 4, 0.5, " | ", config.border.r, config.border.g, config.border.b, config.border.a)
  
            if (direction == "N") then
              drawTxt(0.022, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            elseif (direction == "NE") then 
              drawTxt(0.0195, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            elseif (direction == "E") then 
              drawTxt(0.023, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            elseif (direction == "SE") then 
              drawTxt(0.0195, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            elseif (direction == "S") then
              drawTxt(0.0225, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            elseif (direction == "SW") then
              drawTxt(0.0176, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)	
            elseif (direction == "W") then 
              drawTxt(0.0211, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            elseif (direction == "NW") then
              drawTxt(0.0175, 0.746, 4, 0.6, direction, config.dir.r, config.dir.g, config.dir.b, config.dir.a)
            end
          end
  
          if (current_zone ~= nil) then
            drawTxt(0.042, 0.748, 6, 0.27, current_zone, config.town.r, config.town.g, config.town.b, config.town.a)
          end
        end

        -- motorcycles, cycles, boats
        if (vehClass ~= 8 and vehClass ~= 13 and vehClass ~= 14) then
          if (seatbeltToggle) then
            --[[if (not seatbeltShowing) then
              SendNUIMessage({showSeatbelt = true})
              seatbeltShowing = true
            end]]
            if (minimap.x) then
              drawTxt(minimap.right_x + 0.0045, 0.968, 4, 0.4, "[Seatbelt]", 23, 232, 57, 255)
            else
              drawTxt(0.1617, 0.968, 4, 0.4, "[Seatbelt]", 23, 232, 57, 255)
            end
          else
            --[[if (seatbeltShowing) then
              SendNUIMessage({hideSeatbelt = true})
              seatbeltShowing = false
            end]]
            if (minimap.x) then
              drawTxt(minimap.right_x + 0.0045, 0.968, 4, 0.4, "[Seatbelt]", 232, 68, 56, 255)
            else
              drawTxt(0.1617, 0.968, 4, 0.4, "[Seatbelt]", 232, 68, 56, 255)
            end
          end
        elseif (vehClass == 14) then
          local anchored = IsBoatAnchoredAndFrozen(veh)

          if (minimap.x) then
            if (anchored) then
              drawTxt(minimap.right_x + 0.0045, 0.968, 4, 0.4, "[Anchored]", 23, 232, 57, 255)
            else
              drawTxt(minimap.right_x + 0.0045, 0.968, 4, 0.4, "[Anchored]", 232, 68, 56, 255)
            end
          else
            if (anchored) then
              drawTxt(0.1617, 0.968, 4, 0.4, "[Anchored]", 23, 232, 57, 255)
            else
              drawTxt(0.1617, 0.968, 4, 0.4, "[Anchored]", 232, 68, 56, 255)
            end
          end
        end
      else
        --[[if (IsRadarEnabled()) then
          DisplayRadar(false)
        end]]

        if (checkEngineShowing) then
          SendNUIMessage({hideCheckEngine = true})
          checkEngineShowing = false
        end

        if (lowFuelShowing) then
          SendNUIMessage({hideLowFuel = true})
          lowFuelShowing = false
        end

        if (nitrousShowing) then
          SendNUIMessage({updateNitrousLevel = true, hasNitrous = false, level = 0})
          nitrousShowing = false
        end

        --[[if (seatbeltShowing) then
          SendNUIMessage({hideSeatbelt = true})
          seatbeltShowing = false
        end]]
      end
    else
      if (checkEngineShowing) then
        SendNUIMessage({hideCheckEngine = true})
        checkEngineShowing = false
      end

      if (lowFuelShowing) then
        SendNUIMessage({hideLowFuel = true})
        lowFuelShowing = false
      end

      if (nitrousShowing) then
        SendNUIMessage({updateNitrousLevel = true, hasNitrous = false, level = 0})
        nitrousShowing = false
      end

      --[[if (seatbeltShowing) then
        SendNUIMessage({hideSeatbelt = true})
        seatbeltShowing = false
      end]]
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local pos = GetEntityCoords(ped)
    local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
    local heading = GetEntityHeading(ped)

    current_zone = zones[GetNameOfZone(pos.x, pos.y, pos.z)]

    if (street2 ~= 0 and street2 ~= nil) then
      streetname = string.format("%s and %s ", GetStreetNameFromHashKey(street1), GetStreetNameFromHashKey(street2))
    else
      streetname = GetStreetNameFromHashKey(street1)
    end

    direction = degreesToIntercardinalDirection(360.0 - heading)

    if (veh ~= 0 and veh ~= nil) then
      local fuel = vehicleFuelLevel(veh) or 0.0
      local fuelMaxCap = 65.0
      isElectric = exports.fuel:isModelElectric(GetEntityModel(veh))
      
      --[[if (IsThisModelAHeli(GetEntityModel(veh))) then
        fuelMaxCap = 65.0
      else
        fuelMaxCap = GetVehicleHandlingFloat(veh, "CHandlingData", "fPetrolTankVolume")
      end]]

      if (fuelMaxCap > 0.0 and not isElectric) then
        fuelPercentage = math.ceil((fuel / fuelMaxCap) * 100)
      else
        fuelPercentage = nil
      end

      local nitrousInfo = exports.vehicles:getNitrousLevel(veh)

      if (not hideHud) then
        if (nitrousInfo.hasNitrous) then
          nitrousShowing = true
        end

        SendNUIMessage({updateNitrousLevel = true, hasNitrous = nitrousInfo.hasNitrous, level = nitrousInfo.nitrousLevel * 2})
      end
    else
      if (seatbeltToggle) then
        TriggerEvent("bms:hud:toggleSeatbelt", false)
      end
    end

    Wait(1000)
  end
end)
