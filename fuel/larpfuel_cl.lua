local DrawMarker = DrawMarker
local table_insert = table.insert
local debug = false
local registrySpots = {
  vec3(42.683, -2634.747, 6.037),
  vec3(-247.617, 6067.612, 32.345)
}
local tankerSpots = { -- types, 1 = full available.  2 = half available, ppu = price per unit, max 5000 units per tanker
  {truck = {pos = vec3(34.015, -2651.674, 6.005), heading = 359.341}, tanker = {pos = vec3(33.876, -2663.178, 6.007), heading = 359.341}, ppu = 0.8, fuelfortanker = 5000},
  {truck = {pos = vec3(-273.64749145508, 6046.5629882813, 31.634963989258), heading = 48.024}, tanker = {pos = vec3(-266.06256103516, 6039.67578125, 31.837842941284), heading = 48.024}, ppu = 0.8, fuelfortanker = 5000},
}
local refuelspots = {
  vec3(-60.881, -2531.161, 6.012),
  vec3(1492.691, -1939.486, 70.837),
  vec3(-270.375, 6053.073, 31.591)
}
local curVehInit = false
local fuelCapacity = 65.0
local fuelRpmImpact = 0.0003
local fuelPlaneRpmImpact = 0.000015
local fuelAccelImpact = 0.0002
local speedThreshold = 165 / 2.236936 -- mph divided by constant
local fuelSpeedImpact = 0.000775
local lastVehicle = 0
local gsblips = {}
local isPumping = false
local addedFuel = 0.0
local animState = 3
local registryBlips = {}
local canRegisterForTanker = true
local canPickupTanker = true
local canUnloadFuel = true
local lastStation = 0
local fuelChecked = false
local lastStationFuel = {}
local curRegPickup = 0
local pickupBlip = {}
local trucks = {"HAULER", "PACKER", "PHANTOM"}
local tanker = "TANKER"
local jobTruck
local jobTrailer
local hasTanker = false
local maxtankerfuel = 5000
local tankerfuel = 0
local refuelBlips = {}
local refuelCost = 0.6
local canBuyFuel = true
local distwarn = false
local wep_fuelcan = 0x34A67B97
local lastpump
local gsdists = {pump = 3.05, bone = 2.05, default = 3.5}
local cconsumers = { -- custom fuel consumer numbers
  --[[[GetHashKey("jugular")] = 0.000025,
  [GetHashKey("krieger")] = 0.000025,
  [GetHashKey("s80")] = 0.000025,
  [GetHashKey("zorrusso")] = 0.000025,
  [GetHashKey("locust")] = 0.000025,
  [GetHashKey("emerus")] = 0.000025,
  [GetHashKey("raptor")] = 0.000025]]
}
local electricCars = {
  [GetHashKey("airtug")] = true,
  [GetHashKey("caddy")] = true,
  [GetHashKey("caddy2")] = true,
  [GetHashKey("caddy3")] = true,
  [GetHashKey("cyclone")] = true,
  [GetHashKey('dilettante')] = true,
  [GetHashKey("imorgon")] = true,
  [GetHashKey("khamelion")] = true,
  [GetHashKey("neon")] = true,
  [GetHashKey("raiden")] = true,
  [GetHashKey("rcbandito")] = true,
  [GetHashKey("surge")] = true,
  [GetHashKey("tezeract")] = true,
  [GetHashKey("voltic")] = true
}
local curRpmImpact = 1.0 -- Set via fuelRpmImpact
local gasMarkers = {}
local playerInfo = {}

local function drawFuelText(text, y)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.30, 0.30)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(0.475, y)
end

function getRandomPlate(randomseed)
  math.randomseed(randomseed)
    
  local charset = {}

  for i = 65,  90 do table_insert(charset, string.char(i)) end
  for i = 97, 122 do table_insert(charset, string.char(i)) end
  
  local rndstr = ""
  
  for i = 1, 7 do
    rndstr = rndstr .. charset[math.random(1, #charset)]
  end
  
  return rndstr
end

function setupGsBlips()
  for _,v in pairs(gasstations) do
    if (not v.helirefuel) then
      local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
      
      SetBlipSprite(blip, 361)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 0.85)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Gas Station")
      EndTextCommandSetBlipName(blip)
      
      table_insert(gsblips, blip)
    end
  end
end

function setupRegistryBlips()
  for _,v in pairs(registrySpots) do
    local blip = AddBlipForCoord(v.x, v.y, v.z)
    
    SetBlipSprite(blip, 67)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.88)
    SetBlipColour(blip, 17)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Gas Tanker Registry")
    EndTextCommandSetBlipName(blip)
    
    table_insert(registryBlips, blip)
  end
end

function showRefuelBlips()
  if (#refuelBlips == 0) then
    for _,v in pairs(refuelspots) do
      local blip = AddBlipForCoord(v.x, v.y, v.z)
      
      SetBlipSprite(blip, 361)
      SetBlipDisplay(blip, 4)
      SetBlipScale(blip, 0.85)
      SetBlipColour(blip, 17)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Tanker Refuel Station")
      EndTextCommandSetBlipName(blip)
      
      table_insert(refuelBlips, blip)
    end
  end
end

function hideRefuelBlips()
  for _,v in pairs(refuelBlips) do
    RemoveBlip(v)
  end

  refuelBlips = {}
end

function initFuelDecor()
  DecorRegister("larp_fuel", 1)
end

function randomFuelLevel(cap)
  local min = cap / 3.0
  local max = cap - (cap / 4)
  
  return (GetRandomFloatInRange(0.0, 1.0) * (max - min)) + min
end

function setVehicleFuelLevel(veh, fuel)
  --local maxfuel = Citizen.InvokeNative(0x642FC12F, Citizen.PointerValueIntInitialized(veh), "CHandlingData", "fPetrolTankVolume") or 65.0
  
  if (not DecorExistOn(veh, "larp_fuel")) then
    initFuel(veh)
  end

  if (fuel >= fuelCapacity) then
    fuel = fuelCapacity
  end

  local isElectric = isModelElectric(GetEntityModel(veh))

  if (fuel == 0.0 and not isElectric) then
    TriggerEvent("bms:vehicles:vehcontrol", 5)
  elseif (fuel <= 0.01) then
    SetVehicleFuelLevel(veh, fuel)
  elseif (fuel <= 6.5) then
    SetVehicleFuelLevel(veh, 6.6)
  else
    SetVehicleFuelLevel(veh, fuel)
  end
  DecorSetFloat(veh, "larp_fuel", fuel)
end

function initFuel(veh)
  curVehInit = true
  fuelCapacity = 65.0
  
  if (not DecorExistOn(veh, "larp_fuel")) then
    DecorSetFloat(veh, "larp_fuel", randomFuelLevel(fuelCapacity))
  end
  
  setVehicleFuelLevel(veh, DecorGetFloat(veh, "larp_fuel"))
end

local function modelValid(model)
  return IsThisModelABike(model) or IsThisModelACar(model) or IsThisModelAQuadbike(model) or IsThisModelAPlane(model) or IsThisModelAHeli(model)
end

-- export used by vehicles_cl
function getVehicleFuelLevel(veh, cb)
  if (cb) then
    cb(vehicleFuelLevel(veh))
  end
end

function vehicleFuelLevel(veh)
  if (DecorExistOn(veh, "larp_fuel")) then
    return DecorGetFloat(veh, "larp_fuel")
  else
    return 65.0
  end
end

function consumeFuel(veh, isPlane)
  local fuel = vehicleFuelLevel(veh)
  
  if (fuel > 0 and GetIsVehicleEngineRunning(veh)) then
    local rpm = GetVehicleCurrentRpm(veh) ^ 1.5
    
    if (isPlane) then
      fuel = fuel - rpm * fuelPlaneRpmImpact
      fuel = fuel - GetVehicleAcceleration(veh) * fuelAccelImpact * 0.2
    else
      local speed = GetEntitySpeed(veh) / speedThreshold
      local speedImpact = speed * speed * fuelSpeedImpact

      --[[drawFuelText(string.format("rpm: %s, consumption: %s", rpm, rpm * fuelRpmImpact), 0.86)
      drawFuelText(string.format("accel: %s, consumption: %s", GetVehicleAcceleration(veh), GetVehicleAcceleration(veh) * fuelAccelImpact), 0.88)
      drawFuelText(string.format("speed: %s, consumption: %s", speed, speedImpact), 0.9)]]
      
      fuel = fuel - rpm * fuelRpmImpact
      fuel = fuel - GetVehicleAcceleration(veh) * fuelAccelImpact
      fuel = fuel - speedImpact
    end
    
    if (fuel < 0.0) then
      fuel = 0.0
    end
    
    setVehicleFuelLevel(veh, fuel)
  end
end

function renderUi(fuel, fuelcap)
  --function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
  SetTextFont(4)
  SetTextProportional(0)
  SetTextScale(0.39, 0.39)
  SetTextColour(135, 206, 250, 255)
  SetTextDropShadow(25, 25, 112, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(0)
  BeginTextCommandDisplayText("STRING")
  AddTextComponentSubstringPlayerName(string.format("Fuel: %s%%", math.ceil((fuel / fuelcap) * 100)))
  EndTextCommandDisplayText(0.117, 0.7815)
end

function drawTankerFuelText(text) -- right non centered
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.32, 0.32)
  SetTextColour(135, 206, 235, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(0)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(0.9, 0.935)
end

local function draw3DFuelText(pos, text)
  local onScreen, _x ,_y = World3dToScreen2d(pos.x, pos.y, pos.z)
  local scale = (1 / #(GetGameplayCamCoords() - pos))
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

function boneWithinDist(pos, ent)
  local bname = "door_dside_r"
  local bindex = GetEntityBoneIndexByName(ent, bname)
  
  if (bindex and bindex ~= -1) then
    bpos = GetWorldPositionOfEntityBone(ent, bindex)
    local dist = #(pos - bpos)
    
    return (dist <= gsdists.bone), bpos
  else
    local epos = GetEntityCoords(ent)
    local dist = #(pos - epos)

    return (dist <= gsdists.default), epos
  end
end

function spawnTanker(spot, plate)  
  math.randomseed(GetGameTimer())
  local rnd = math.random(1, #trucks)
  local ped = PlayerPedId()
  local hash = GetHashKey(trucks[rnd])
  
  RequestModel(hash)
  
  while (not HasModelLoaded(hash)) do
    Wait(100)
  end
  
  jobTruck = CreateVehicle(hash, spot.truck.pos.x, spot.truck.pos.y, spot.truck.pos.z, spot.truck.heading, true, true)

  while (not DoesEntityExist(jobTruck)) do
    Wait(100)
  end

  SetVehicleOnGroundProperly(jobTruck)
  SetVehicleNumberPlateText(jobTruck, plate)
  SetVehRadioStation(jobTruck, "OFF")
  SetPedIntoVehicle(ped, jobTruck, -1)
  SetVehicleEngineOn(jobTruck, true, false, false)
  SetVehicleHasBeenOwnedByPlayer(jobTruck, true)
  SetEntityAsMissionEntity(jobTruck, true, true)
  SetModelAsNoLongerNeeded(hash)
  TriggerEvent("frfuel:filltankForVeh", jobTruck)
  
  exports.vehicles:registerPulledVehicle(jobTruck)
  
  local plate = string.lower(GetVehicleNumberPlateText(jobTruck))
  
  TriggerServerEvent("bms:vehicles:registerJobVehicle", plate, trucks[rnd])
  --AttachVehicleToTrailer(vehicle, trailer, radius)

  hash = GetHashKey(tanker)
  RequestModel(hash)

  while (not HasModelLoaded(hash)) do
    Wait(100)
  end

  jobTrailer = CreateVehicle(hash, spot.tanker.pos.x, spot.tanker.pos.y, spot.tanker.pos.z, spot.tanker.heading, true, true)

  while (not DoesEntityExist(jobTrailer)) do
    Wait(100)
  end

  SetVehicleOnGroundProperly(jobTrailer)
  SetVehicleNumberPlateText(jobTrailer, plate)
  SetVehicleHasBeenOwnedByPlayer(jobTrailer, true)
  SetEntityAsMissionEntity(jobTrailer, true, true)
  SetEntityInvincible(jobTrailer, true)

  Wait(100)

  AttachVehicleToTrailer(jobTruck, jobTrailer, 10.0)
  hasTanker = true
  tankerfuel = maxtankerfuel
  SetModelAsNoLongerNeeded(hash)
end

function isModelElectric(model)
  return electricCars[model] or false
end

RegisterNetEvent("bms:fuel:fillFuel")
AddEventHandler("bms:fuel:fillFuel", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  
  if (veh) then
    setVehicleFuelLevel(veh, 65.0)
    exports.pnotify:SendNotification({text = "Your fuel has been filled up.  ONLY use this in <font color='red'>EMERGENCIES!</font>"})
  end
end)

RegisterNetEvent("bms:fuel:fuelLevel")
AddEventHandler("bms:fuel:fuelLevel", function(level)
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)
  
  if (veh and level) then
    if (level > 65.0) then
      level = 65.0
    elseif (level < 0.0) then
      level = 0.0
    end
    
    setVehicleFuelLevel(veh, level)
    --exports.pnotify:SendNotification({text = "Fuel level set.  ONLY use this in <font color='red'>EMERGENCIES!</font>"})
  end
end)

-- legacy support for old fuel system
RegisterNetEvent("frfuel:filltankForVeh")
AddEventHandler("frfuel:filltankForVeh", function(veh, directamount)
  if (veh) then
    setVehicleFuelLevel(veh, directamount or 65.0)
  end
end)

RegisterNetEvent("bms:fuel:addfueltovehicle")
AddEventHandler("bms:fuel:addfueltovehicle", function(data)
  if (data) then
    local success = data.success
    local msg = data.msg

    if (success) then
      setVehicleFuelLevel(lastVehicle, data.fuelval)
    end

    if (msg) then
      exports.pnotify:SendNotification({text = msg})
    end
  end
end)

RegisterNetEvent("bms:fuel:depositfuel")
AddEventHandler("bms:fuel:depositfuel", function(data)  
  local ped = PlayerPedId()
  local overflow = data.fueloverflow
  local payout = data.payout
  local bonus = data.delbonus or 0
  local cityDelBonus = data.cityFuelDelBonus or 0

  if (data.success) then
    exports.pnotify:SendNotification(
      {text = string.format("You have delivered <font color='skyblue'>%s</font> units of fuel.  The station now has <font color='skyblue'>%s</font> units of fuel.<br><br>Your tanker has <font color='skyblue'>%s</font> units of fuel remaining.<br><br>You were paid $%s ($%.0f bonus, $%.0f city bonus) for delivering the fuel.",
        overflow, data.stationfuel, tankerfuel - overflow, payout, bonus, cityDelBonus), timeout = 15000})
    
    if (overflow > 0) then
      tankerfuel = tankerfuel - overflow
    else
      tankerfuel = 0
    end
  else
    exports.pnotify:SendNotification({text = data.msg})
  end

  canUnloadFuel = true
  showRefuelBlips()
end)

RegisterNetEvent("bms:fuel:depositfuelnotowned")
AddEventHandler("bms:fuel:depositfuelnotowned", function(data)
  local ped = PlayerPedId()
  local overflow = data.fueloverflow

  if (data.success) then
    if (overflow > 0) then
      tankerfuel = overflow
    else
      tankerfuel = 0
    end

    if (data.payamount == 0) then
      exports.pnotify:SendNotification({text = string.format("You have delivered <font color='skyblue'>%s</font> units of fuel.  The station now has <font color='skyblue'>%s</font> units of fuel.<br><br>Your tanker has <font color='skyblue'>%s</font> units of fuel remaining.", data.tankerfuel, data.stationfuel, tankerfuel)})
    else
      exports.pnotify:SendNotification({text = string.format("You have delivered <font color='skyblue'>%s</font> units of fuel.  The station now has <font color='skyblue'>%s</font> units of fuel.<br><br>You have been paid <font color='skyblue'>%s</font> for the delivery.<br><br>Your tanker has <font color='skyblue'>%s</font> units of fuel remaining.", data.tankerfuel, data.stationfuel, data.payamount, tankerfuel)})
    end
  else
    exports.pnotify:SendNotification({text = data.msg})
  end

  canUnloadFuel = true
  showRefuelBlips()
end)

RegisterNetEvent("bms:fuel:buytanker")
AddEventHandler("bms:fuel:buytanker", function(data)
  if (data.success) then
    tankerfuel = data.fuelfortanker
    spawnTanker(data.spot, getRandomPlate(GetGameTimer()))
    exports.pnotify:SendNotification({text = "You have purchased a tanker full of fuel."})
  else
    exports.pnotify:SendNotification({text = data.msg})
    canPickupTanker = true
  end

  if (#pickupBlip > 0) then
    for _,v in pairs(pickupBlip) do
      RemoveBlip(v)
    end

    pickupBlip = {}
  end
end)

RegisterNetEvent("bms:fuel:stationnotowned")
AddEventHandler("bms:fuel:stationnotowned", function()
  canUnloadFuel = true
  exports.pnotify:SendNotification({text = "This station is not owned by anyone.  Maybe you should consider purchasing it?"})
end)

RegisterNetEvent("bms:fuel:buyfuelfortanker")
AddEventHandler("bms:fuel:buyfuelfortanker", function(data)
  if (data.success) then
    tankerfuel = tankerfuel + data.fuel
    exports.pnotify:SendNotification({text = "Your tanker has been filled with fuel."})
  else
    exports.pnotify:SendNotification({text = data.msg})
  end

  canBuyFuel = true
end)

RegisterNetEvent("bms:fuel:settankerfuel")
AddEventHandler("bms:fuel:settankerfuel", function(level)
  if (level) then
    tankerfuel = level
    exports.pnotify:SendNotification({text = "Tanker fuel updated."})
  end
end)

RegisterNetEvent("bms:fuel:saddfuel")
AddEventHandler("bms:fuel:saddfuel", function(amount)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local cl = 0

  for i,v in ipairs(gasstations) do
    local dist = #(pos - v.pos)
    
    if (dist < 100) then
      cl = i
    end
  end

  if (cl > 0) then
    TriggerServerEvent("bms:businesses:saddfuel", {closest = cl, amount = amount})
  else
    exports.pnotify:SendNotification({text = "No gas stations found nearby."})
  end
end)

RegisterNetEvent("bms:fuel:saddmoney")
AddEventHandler("bms:fuel:saddmoney", function(amount)
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local cl = 0

  for i,v in ipairs(gasstations) do
    local dist = #(pos - v.pos)
    
    if (dist < 100) then
      cl = i
    end
  end

  if (cl > 0) then
    TriggerServerEvent("bms:businesses:saddmoney", {closest = cl, amount = amount})
  else
    exports.pnotify:SendNotification({text = "No gas stations found nearby."})
  end
end)

RegisterNetEvent("bms:fuel:sresetmanage")
AddEventHandler("bms:fuel:sresetmanage", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local cl = 0

  for i,v in ipairs(gasstations) do
    local dist = #(pos - v.pos)
    
    if (dist < 100) then
      cl = i
    end
  end

  if (cl > 0) then
    TriggerServerEvent("bms:businesses:sresetmanage", {closest = cl})
  else
    exports.pnotify:SendNotification({text = "No gas stations found nearby."})
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(2000)
    
    if (isPumping) then
      PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", 1)
    end
  end
end)

Citizen.CreateThread(function()
  initFuelDecor()

  local waitTime = 1
  local ped = 0
  local veh = 0
  local model = 0
  local isValidModel = false
  local isPlane = false

  while true do
    Wait(waitTime) -- 1
    
    ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    veh = GetVehiclePedIsIn(ped, false)
    local inVeh = veh ~= 0
    local isdriver = inVeh and GetPedInVehicleSeat(veh, -1) == ped
    playerInfo.ped = ped
    playerInfo.veh = veh

    if (lastVehicle ~= veh and veh ~= 0) then
      lastVehicle = veh
      model = GetEntityModel(veh)
      playerInfo.model = model
      isValidModel = modelValid(model)
      curVehInit = false
    end

    if (veh and isdriver and isValidModel and not IsEntityDead(veh)) then
      if (not curVehInit) then
        initFuel(veh)
        curRpmImpact = fuelRpmImpact
        isPlane = IsThisModelAPlane(model) or IsThisModelAHeli(model)

        for k,v in pairs(cconsumers) do          
          if (k == model) then
            curRpmImpact = v
            break
          end
        end
      end
      
      consumeFuel(veh, isPlane)
    else
      curVehInit = false
    end
    
    if (veh or lastVehicle) then
      for _,v in pairs(gasMarkers) do
        if (v.dist < 50) then
          lastStation = v.idx

          if (not v.helirefuel and not fuelChecked and inVeh) then
            fuelChecked = true
            exports.management:TriggerServerCallback("bms:businesses:checkfuelforstation", function(data)
              lastStationFuel = {stationfuel = data.stationfuel, fuelprice = data.fuelprice}
            end, {index = lastStation})
          end

          if (v.forcemarker) then
            DrawMarker(27, v.pos.x, v.pos.y, v.pos.z - 0.99, 0, 0, 0, 0, 0, 0, 3.8, 3.8, 1.0, 160, 160, 0, 50, 0, 0, 0, true, 0, 0, 0)
          end

          if (lastpump ~= nil) then
            local bwdist, bpos = boneWithinDist(pos, lastVehicle)

            if (lastVehicle and bwdist and not inVeh) then
              local running = GetIsVehicleEngineRunning(lastVehicle)

              if (running) then
                draw3DFuelText(bpos, "~r~Turn the vehicle engine off first.")
              elseif (vehicleFuelLevel(lastVehicle) >= 65) then
                draw3DFuelText(bpos, "~r~The vehicle is already full of fuel.")
              elseif (v.helirefuel or lastStationFuel.stationfuel > 0) then
                exports.vehicles:blockTrunk(true)

                if (isPumping) then
                  draw3DFuelText(bpos, "~b~Pumping fuel..")
                else
                  if (v.helirefuel) then
                    draw3DFuelText(bpos, "Hold ~b~H~w~ to fill your ~b~gas~w~ tank.")
                  else
                    draw3DFuelText(bpos, string.format("Hold ~b~H~w~ to fill your ~b~gas~w~ tank.\n~g~Price:~w~ $%s per unit.\n~r~Fuel:~w~ %s units.", lastStationFuel.fuelprice, lastStationFuel.stationfuel))
                  end
                end
                
                if (IsControlPressed(1, 74)) then -- H
                  isPumping = true
                  local fuel = vehicleFuelLevel(lastVehicle)
                  local afuel = fuel + addedFuel
                  
                  if (afuel <= fuelCapacity) then
                    addedFuel = addedFuel + 0.1
                    renderUi(fuel + addedFuel, fuelCapacity)
                  end
                end
                
                if (IsControlJustReleased(1, 74)) then
                  if (isPumping) then
                    isPumping = false
                    local fuel = vehicleFuelLevel(lastVehicle)

                    if (not v.helirefuel) then
                      TriggerServerEvent("bms:fuel:payForFuel", {stationindex = v.idx, addedfuel = addedFuel, fuelval = fuel + addedFuel})                    
                      TriggerServerEvent("bms:businesses:removefuelfromstation", {stationindex = v.idx, addedfuel = addedFuel})
                    else
                      exports.pnotify:SendNotification({text = "Your helicopter has been refueled."})
                      setVehicleFuelLevel(lastVehicle, 65.0)
                    end
                    
                    addedFuel = 0.0
                  end
                end
              else
                drawFuelText("~b~This gas station is completely out of fuel.  Try a different one.", 0.88)
              end
            end
          else
            for _,p in pairs(v.pumps) do
              local pdist = #(pos - p)
              
              if (pdist < 50) then
                -- DrawMarker(1, p.x, p.y, p.z - 1.0001, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.8, 255, 255, 0, 180, 0, 0, 2, 0, 0, 0, 0)
                
                if (pdist < gsdists.pump) then
                  lastpump = p
                end
              end
            end
          end
        end
      end

      if (lastpump ~= nil) then
        local dist = #(pos - lastpump)

        if (dist > gsdists.pump) then
          lastpump = nil
          exports.vehicles:blockTrunk(false)
        end
      end

      if (lastStation > 0) then
        local dist = #(pos - gasstations[lastStation].pos)

        if (dist > 80) then
          lastStation = 0
          fuelChecked = false
        end
      end
    end
    
    -- manual refuel
    local wep = GetSelectedPedWeapon(ped, true)
    
    if (wep == wep_fuelcan and lastVehicle) then
      local vpos = GetEntityCoords(lastVehicle)
      local dist = #(pos - vpos)
      
      if (dist < 2.0 and DecorExistOn(lastVehicle, "larp_fuel")) then
        local max = 16.25
        local fuel = vehicleFuelLevel(lastVehicle)
        
        if (fuel > (max - 0.1)) then
          drawFuelText("You can only use the fuel can to fill nearly empty tanks.", 0.88)
        else
          drawFuelText("~w~Hold ~b~Attack~w~ to fill this gas tank.", 0.88)
        end
        
        if (IsControlPressed(0, 24)) then
          if (animState == 3) then
            RequestAnimDict("weapon@w_sp_jerrycan")
      
            while not HasAnimDictLoaded("weapon@w_sp_jerrycan") do
              Wait(10)
            end
            
            --TaskPlayAnim(ped, "weapon@w_sp_jerrycan", "fire_intro", 8.0, -8, -1, 17, 0, 0, 0, 0)
            TaskPlayAnim(ped, "weapon@w_sp_jerrycan", "fire_intro", 8.0, -8, -1, 0, 0, 0, 0, 0)
            animState = 1
          elseif (animState == 1) then
            if (not IsEntityPlayingAnim(ped, "weapon@w_sp_jerrycan", "fire_intro", 3)) then
              RequestAnimDict("weapon@w_sp_jerrycan")
      
              while not HasAnimDictLoaded("weapon@w_sp_jerrycan") do
                Wait(10)
              end
              
              TaskPlayAnim(ped, "weapon@w_sp_jerrycan", "fire", 50.0, -8, -1, 1, 0, 0, 0, 0)
              animState = 2
            end
          end
          
          if (fuel < max) then
            renderUi(fuel, fuelCapacity)

            if (fuel + 0.1 >= max) then
              setVehicleFuelLevel(lastVehicle, max)
            else
              local gasInCan = GetAmmoInPedWeapon(ped, wep_fuelcan)
              if (gasInCan > 0) then
                setVehicleFuelLevel(lastVehicle, fuel + 0.08) -- 0.2
                -- Fuel Can Max Ammo: 4500 (100%)
                -- Fuel Can Empty: 0 (0%)
                -- 1 ammo = 45 units
                -- Roughly equates to 25 "ammo" being used per 25% gas filled in car
                SetPedAmmo(ped, wep_fuelcan, math.floor(gasInCan - 5))
              end
            end
          end
        end
        
        if (IsControlJustReleased(0, 24)) then
          RequestAnimDict("weapon@w_sp_jerrycan")
      
          while not HasAnimDictLoaded("weapon@w_sp_jerrycan") do
            Wait(100)
          end
          
          StopEntityAnim(ped, "fire", "weapon@w_sp_jerrycan", 3)
          TaskPlayAnim(ped, "weapon@w_sp_jerrycan", "fire_outro", 8.0, -1, 128)
          animState = 3
          RemoveAnimDict("weapon@w_sp_jerrycan")
        end
      end
    end

    -- tanker registry
    if (not jobTruck) then
      for r,v in pairs(registrySpots) do
        local dist = #(pos - v)

        if (dist < 80) then
          DrawMarker(1, v.x, v.y, v.z - 1.00001, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.15, 120, 255, 70, 50, 0, 0, 0, 0, 0, 0, 0)

          if (dist < 0.6) then
            if (canRegisterForTanker) then
              drawFuelText("~w~Press ~b~E~w~ to register a tanker pick up.", 0.88)

              if (IsControlJustReleased(1, 38)) then
                canRegisterForTanker = false
                curRegPickup = r
                SetNewWaypoint(tankerSpots[curRegPickup].truck.pos.x, tankerSpots[curRegPickup].truck.pos.y)

                if (#pickupBlip > 0) then
                  for _,v in pairs(pickupBlip) do
                    RemoveBlip(v)
                  end

                  pickupBlip = {}
                end
                
                local blip = AddBlipForCoord(tankerSpots[curRegPickup].truck.pos.x, tankerSpots[curRegPickup].truck.pos.y, tankerSpots[curRegPickup].truck.pos.z)
                
                SetBlipSprite(blip, 67)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, 0.85)
                SetBlipColour(blip, 14)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Tanker Pickup")
                EndTextCommandSetBlipName(blip)
                table_insert(pickupBlip, blip)

                exports.pnotify:SendNotification({text = "The tanker pickup location has been marked on your <font color='skyblue'>GPS</font> as a waypoint."})
              end
            end
          end
        end
      end
    end

    if (curRegPickup > 0 and not jobTruck and not jobTrailer) then
      local spot = tankerSpots[curRegPickup].truck.pos
      local dist = #(pos - spot)

      if (dist < 50) then
        DrawMarker(1, spot.x, spot.y, spot.z - 1.00001, 0, 0, 0, 0, 0, 0, 3.0, 3.0, 0.15, 120, 255, 70, 50, 0, 0, 0, 1, 0, 0, 0)

        if (dist < 1.5) then
          local info = tankerSpots[curRegPickup]
          
          if (canPickupTanker) then
            drawFuelText(string.format("~w~Press ~b~E~w~ to pick up your tanker.  It will cost ~g~$%.0f~w~ for the fuel.", info.ppu * info.fuelfortanker), 0.88)

            if (IsControlJustReleased(1, 38)) then
              canPickupTanker = false
              TriggerServerEvent("bms:fuel:buytanker", {spot = tankerSpots[curRegPickup], ppu = info.ppu, fuelfortanker = info.fuelfortanker})
              --spawnTanker(tankerSpots[curRegPickup], getRandomPlate(GetGameTimer()))
            end
          end
        end
      end
    end

    if (jobTruck and jobTrailer) then
      if (veh == jobTruck and IsVehicleAttachedToTrailer(jobTruck)) then
        drawTankerFuelText(string.format("Tanker Fuel: %s", tankerfuel))
        
        for i,v in ipairs(gasstations) do
          local dist = #(pos - v.pos)

          if (dist < 80 and not v.helirefuel) then
            DrawMarker(27, v.pos.x, v.pos.y, v.pos.z - 0.90001, 0, 0, 0, 0, 0, 0, 10.1, 10.1, 0.1, 200, 200, 0, 50, 0, 0, 0, 1, 0, 0, 0)

            if (dist < 10.1) then
              if (tankerfuel > 0) then
                drawFuelText("~w~Press ~b~E~w~ to unload fuel at this station.", 0.88)

                if (canUnloadFuel) then
                  if (IsControlJustReleased(1, 38)) then
                    canUnloadFuel = false
                    TriggerServerEvent("bms:businesses:depositfuel", {index = i, fuelfortanker = tankerfuel})
                  end
                end
              else
                drawFuelText("Your tanker is empty.  You can purchase more fuel at a Tanker Fueling Station.", 0.88)
                drawFuelText("To cancel your job, run a far distance from your truck.", 0.9)
              end
            end
          end
        end

        for _,v in pairs(refuelspots) do
          local dist = #(pos - v)

          if (dist < 80) then
            DrawMarker(27, v.x, v.y, v.z - 0.90001, 0, 0, 0, 0, 0, 0, 4.1, 4.1, 0.1, 200, 200, 0, 50, 0, 0, 0, 1, 0, 0, 0)

            if (dist < 3.1) then
              local fuel = 500
              local maxfuel = maxtankerfuel

              if ((tankerfuel + fuel) <= maxtankerfuel) then
                maxfuel = fuel
              else
                maxfuel = maxtankerfuel - tankerfuel
              end

              if (maxfuel > 0) then
                drawFuelText(string.format("~w~Press ~b~E~w~ to refill your tanker.  It will cost ~g~$%.0f~w~ for ~g~%s~w~ units of fuel.", refuelCost * maxfuel, maxfuel), 0.88)

                if (canBuyFuel) then
                  if (IsControlJustPressed(1, 38) or IsDisabledControlJustPressed(1, 38)) then
                    canBuyFuel = false
                    TriggerServerEvent("bms:fuel:buyfuelfortanker", {cost = maxfuel * refuelCost, fuel = maxfuel})
                  end                
                end
              else
                drawFuelText("Your tanker is already full of fuel.", 0.88)
              end
            end
          end
        end
      else
        drawFuelText("You must be in your job truck and\nhave a tanker to complete this delivery.", 0.9)
      end

      local tpos = GetEntityCoords(jobTruck)
      local dist = #(pos - tpos)

      if (dist > 40) then
        if (not distwarn) then
          distwarn = true
          exports.pnotify:SendNotification({text = "If you get too far from your truck your contract will be cancelled."})
        end

        if (dist > 60) then
          DeleteVehicle(jobTruck)
          DeleteVehicle(jobTrailer)
          jobTruck = nil
          jobTrailer = nil
          curRegPickup = 0
          canRegisterForTanker = true
          canPickupTanker = true
          canUnloadFuel = true
          distwarn = false
          hasTanker = false
          hideRefuelBlips()
          exports.pnotify:SendNotification({text = "You moved too far away from your job truck and it was towed."})
        end
      end
    end

    if (hasTanker) then
      if (not DoesEntityExist(jobTruck)) then
        jobTruck = nil
        jobTrailer = nil
        DeleteVehicle(jobTruck)
        DeleteVehicle(jobTrailer)
        local plate = GetVehicleNumberPlateText(jobTruck, false)

        if (plate ~= "") then
          TriggerServerEvent("bms:vehicles:unregisterJobVehicle", plate)
        end

        exports.pnotify:SendNotification({text = "You have lost your truck or trailer.  The delivery has been cancelled."})
        curRegPickup = 0
        canRegisterForTanker = true
        canPickupTanker = true
        canUnloadFuel = true
        hasTanker = false
        hideRefuelBlips()
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1500)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local gMarkers = {}
    local iter = 0

    if (#gsblips == 0) then
      setupGsBlips()
    end

    if (#registryBlips == 0) then
      setupRegistryBlips()
    end

    for i,v in ipairs(gasstations) do
      local dist = #(pos - v.pos)
      
      if (dist < 65) then
        iter = iter + 1
        gMarkers[iter] = v
        gMarkers[iter].dist = dist
        gMarkers[iter].idx = i
      end
    end

    gasMarkers = gMarkers
  end
end)

Citizen.CreateThread(function() -- Needs exceptions for electric vehicles
  math.randomseed(GetGameTimer())
  local waitTime = 1
  local ped = 0
  local veh = 0
  
  while true do
    Wait(waitTime)

    ped = playerInfo.ped
    veh = playerInfo.veh

    if (veh ~= 0) then
      local model = playerInfo.model

      if (electricCars[model] == nil) then
        Wait(math.random(1,15000))
        local fuelLevel = vehicleFuelLevel(veh)

        if (fuelLevel < 6.5) then
          local stopTime = math.random(1000, 1000 + math.floor(6500 - fuelLevel * 1000))
          local controlResume = false

          SetTimeout(stopTime, function()
            controlResume = true
          end)

          while (not controlResume and veh ~= 0) do
            Wait(1)

            veh = playerInfo.veh
            local speed = GetEntitySpeedVector(veh, true).y

            if (speed > 1.0) then
              DisableControlAction(0, 71, true) -- W
            elseif (speed < -1.0) then
              DisableControlAction(0, 72, true) -- S
            else
              DisableControlAction(0, 71, true) -- W
              DisableControlAction(0, 72, true) -- S
            end
          end
        end
      end
    else
      Wait(5000)
    end
  end
end)
