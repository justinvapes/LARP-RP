local table_insert = table.insert
local table_remove = table.remove
local DrawMarker = DrawMarker
local repairSpots = {}
local repairMarkers = {}
local repairModifier = 0.006
local maxRepairCost = 10000
local mechDiscount = 0.2
local repBlips = {}
local lastRepSpot = 0
local repblock = false
local repairing = false
local isMechanic = false
local mechanicspots = {
  {x = 550.1064453125, y = -179.96057128906, z = 61.136322021484, radius = 27.0},
  {x = -1146.7169189453, y = -2012.0251464844, z = 17.510654449463, radius = 41.0}
}
local mvehdefaults = {}
local meccurrentveh = {boost = 0, acceleration = 0, gearchange = 0, braking = 5, drivetrain = 5}
local mlastveh = 0
local intunermenu = false
local tunertimer = {active = false, cur = 0, max = 5}
local isResponderOnDuty = false
local isLeoOnDuty = false
local isEmsOnDuty = false
local lastVehPrice = 0
local lastVeh = nil
local empStatus = {}
--[[local carLiftSettings = {}
local carLifts = {}]]

local function ttrim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function getVehicleInDirection(coordFrom, coordTo, ignore)
  local rayHandle = StartShapeTestRay(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, ignore, 0)
  local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
  local isv = IsEntityAVehicle(vehicle)
  
  if (isv) then
    return vehicle
  else
    return 0
  end
end

local function drawTxt(text, font, centre, x, y, scale, r, g, b, a)
  SetTextFont(font)
  SetTextProportional(0)
  SetTextScale(0.32, 0.32)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(centre)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x or 0.475, y or 0.88) 
end

function drawRepBlips()
  AddTextEntry("BLIP_REP", "Vehicle Repair")
  local repText = GetHashKey("BLIP_REP")

  if (#repBlips == 0) then
    for _,v in pairs(repairSpots) do
      if (not v.hideBlip) then
        local rBlip = AddBlipForCoord(v.pos)
          
        SetBlipSprite(rBlip, 402)
        SetBlipDisplay(rBlip, 4)
        SetBlipScale(rBlip, 0.9)
        SetBlipAsShortRange(rBlip, true)

        if (v.blipColor) then
          SetBlipColour(rBlip, v.blipColor)
        end
        
        if (v.shopName) then
          BeginTextCommandSetBlipName("STRING")
          AddTextComponentString(v.shopName)
          EndTextCommandSetBlipName(rBlip)
        else
          BeginTextCommandSetBlipName("STRING")
          AddTextComponentSubstringTextLabelHashKey(repText)
          EndTextCommandSetBlipName(rBlip)
        end
        
        table_insert(repBlips, rBlip)
      end
    end
  end
end

function saveDataToDecor(veh, data)
  if (not DecorIsRegisteredAsType("boost", 1)) then
    DecorRegister("boost", 1)
  end

  DecorSetFloat(veh, "boost", data.boost)

  if (not DecorIsRegisteredAsType("acceleration", 1)) then
    DecorRegister("acceleration", 1)
  end

  DecorSetFloat(veh, "acceleration", data.acceleration)

  if (not DecorIsRegisteredAsType("gearchange", 1)) then
    DecorRegister("gearchange", 1)
  end

  DecorSetFloat(veh, "gearchange", data.gearchange)

  if (not DecorIsRegisteredAsType("drivetrain", 1)) then
    DecorRegister("drivetrain", 1)
  end

  DecorSetFloat(veh, "drivetrain", data.drivetrain)

  if (not DecorIsRegisteredAsType("braking", 1)) then
    DecorRegister("braking", 1)
  end

  DecorSetFloat(veh, "braking", data.braking)
end

function setVehicleHandlingFloat(veh, hzone, hfield, val, type) -- type is used for debugging only
  local strt = "applyTunerChanges"

  if (type == 2) then
    strt = "loadHandlingFloats"
  end
  
  SetVehicleHandlingFloat(veh, hzone, hfield, val)
  print(string.format("Setting Handling Float: %s, %s, %s, Type: %s", hzone, hfield, val, strt))
end

function applyTunerChanges(data, veh)
  local plate = string.lower(ttrim(GetVehicleNumberPlateText(veh or mlastveh)))

  if (plate == "") then return end

  local mdefveh = mvehdefaults[plate]
  meccurrentveh = {boost = data.uivalues.boost, acceleration = data.uivalues.acceleration, gearchange = data.uivalues.gearchange, braking = data.uivalues.braking, drivetrain = data.uivalues.drivetrain}
  
  if (data.uivalues.boost ~= 0) then
    local defaultTractionLoss = mdefveh.fLowSpeedTractionLossMult
    local newLoss = defaultTractionLoss + defaultTractionLoss * (data.boost / 20)

    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fInitialDriveForce", data.boost, 1)
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fLowSpeedTractionLossMult", newLoss, 1)
  else
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fInitialDriveForce", mdefveh.fInitialDriveForce, 1)
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fLowSpeedTractionLossMult", mdefveh.fLowSpeedTractionLossMult, 1)
  end

  if (data.uivalues.boost == 0 and data.uivalues.acceleration == 0) then
    print(string.format("hit 1 >> fDriveInertia: %s", mdefveh.fDriveInertia))
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fDriveInertia", mdefveh.fDriveInertia, 1)
  else
    print(string.format("hit 2 >> accel: %s, boost: %s", data.acceleration, data.boost))
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fDriveInertia", data.acceleration, 1)
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fInitialDriveForce", data.boost, 1)
  end

  if (data.uivalues.gearchange ~= 0) then
    local newDrag = (mdefveh.fInitialDragCoeff + (data.gearchange / 45))

    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fClutchChangeRateScaleUpShift", data.gearchange, 1)
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fClutchChangeRateScaleDownShift", data.gearchange, 1)
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fInitialDragCoeff", newDrag, 1)
  else
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fClutchChangeRateScaleUpShift", mdefveh.fClutchChangeRateScaleUpShift, 1)
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fClutchChangeRateScaleDownShift", mdefveh.fClutchChangeRateScaleDownShift, 1)
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fInitialDragCoeff", mdefveh.fInitialDragCoeff, 1)
  end

  if (data.uivalues.drivetrain == 5) then
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fDriveBiasFront", mdefveh.fDriveBiasFront, 1)
  else
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fDriveBiasFront", data.drivetrain, 1)
  end
  
  if (data.uivalues.braking == 5) then
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fBrakeBiasFront", mdefveh.fBrakeBiasFront, 1)
  else
    setVehicleHandlingFloat(veh or mlastveh, "CHandlingData", "fBrakeBiasFront", data.braking, 1)
  end

  saveDataToDecor(veh or mlastveh, data)
  TriggerServerEvent("bms:jobs:mechanic:saveVehicleTune", data, plate)
  exports.pnotify:SendNotification({text = "The work on this vehicle is complete."})
end

function loadHandlingFloats(veh)
  print("loading defaults or decors for vehicle.")
  local data = {}

  local plate = string.lower(ttrim(GetVehicleNumberPlateText(veh)))
  local mdefveh = mvehdefaults[plate]

  if (not mdefveh) then
    mvehdefaults[plate] = {
      fInitialDriveForce = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce"),
      fClutchChangeRateScaleUpShift = GetVehicleHandlingFloat(veh, "CHandlingData", "fClutchChangeRateScaleUpShift"),
      fClutchChangeRateScaleDownShift = GetVehicleHandlingFloat(veh, "CHandlingData", "fClutchChangeRateScaleDownShift"),
      fBrakeBiasFront = GetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront"),
      fDriveBiasFront = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront"),
      fInitialDragCoeff = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDragCoeff"),
      fLowSpeedTractionLossMult = GetVehicleHandlingFloat(veh, "CHandlingData", "fLowSpeedTractionLossMult"),
      fDriveInertia = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia")
    }
  end
  
  if (DecorExistOn(veh, "boost")) then
    data.boost = DecorGetFloat(veh, "boost")
    
    if (data.boost ~= 0) then
      local defaultTractionLoss = mdefveh.fLowSpeedTractionLossMult
      local newLoss = defaultTractionLoss + defaultTractionLoss * (data.boost / 20)
  
      setVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", data.boost, 2)
      setVehicleHandlingFloat(veh, "CHandlingData", "fLowSpeedTractionLossMult", newLoss, 2)
    else
      setVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", mdefveh.fInitialDriveForce, 2)
      setVehicleHandlingFloat(veh, "CHandlingData", "fLowSpeedTractionLossMult", mdefveh.fLowSpeedTractionLossMult, 2)
    end
  end

  if (DecorExistOn(veh, "boost") and DecorExistOn(veh, "acceleration")) then
    data.acceleration = DecorGetFloat(veh, "acceleration")
    
    if (data.boost == 0 and data.acceleration == 0) then
      setVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", mdefveh.fDriveInertia, 2)
    else
      setVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia", data.acceleration, 2)
      setVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce", data.boost, 2)
    end
  end

  if (DecorExistOn(veh, "gearchange")) then
    data.gearchange = DecorGetFloat(veh, "gearchange")

    if (data.gearchange ~= 0) then
      local newDrag = (mdefveh.fInitialDragCoeff + (data.gearchange / 45))
  
      setVehicleHandlingFloat(veh, "CHandlingData", "fClutchChangeRateScaleUpShift", data.gearchange, 2)
      setVehicleHandlingFloat(veh, "CHandlingData", "fClutchChangeRateScaleDownShift", data.gearchange, 2)
      setVehicleHandlingFloat(veh, "CHandlingData", "fInitialDragCoeff", newDrag)
    else
      setVehicleHandlingFloat(veh, "CHandlingData", "fClutchChangeRateScaleUpShift", mdefveh.fClutchChangeRateScaleUpShift, 2)
      setVehicleHandlingFloat(veh, "CHandlingData", "fClutchChangeRateScaleDownShift", mdefveh.fClutchChangeRateScaleDownShift, 2)
      setVehicleHandlingFloat(veh, "CHandlingData", "fInitialDragCoeff", mdefveh.fInitialDragCoeff, 2)
    end
  end
  
  if (DecorExistOn(veh, "braking")) then
    data.braking = DecorGetFloat(veh, "braking")

    if (data.braking == 5) then
      setVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", mdefveh.fBrakeBiasFront)
    else
      setVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront", data.braking)
    end
  end
  
  if (DecorExistOn(veh, "drivetrain")) then
    data.drivetrain = DecorGetFloat(veh, "drivetrain")

    if (data.drivetrain == 5) then
      setVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", mdefveh.fDriveBiasFront)
    else
      setVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront", data.drivetrain)
    end
  end
end

--[[ UNCOMMENT TO ENABLE ]]
--[[AddEventHandler("baseevents:enteredVehicle", function(veh, seat, name)
  if (seat == -1) then
    loadHandlingFloats(veh)
  end
end)]]

RegisterNetEvent("bms:jobs:mechanic:sendRepairSpots")
AddEventHandler("bms:jobs:mechanic:sendRepairSpots", function(repSpots)
  if (repSpots) then
    repairSpots = repSpots

    if (#repBlips > 0) then
      for _,v in pairs(repBlips) do
        RemoveBlip(v)
      end

      repBlips = {}
    end

    drawRepBlips()

    for _,shop in pairs(empStatus) do
      for _,rep in pairs(repairSpots) do
        if (rep.did == shop.did) then
          rep.isEmp = shop.isEmp
          break
        end
      end
    end

  end
end)

RegisterNetEvent("bms:jobs:mechanic:updateMechanic")
AddEventHandler("bms:jobs:mechanic:updateMechanic", function(isMech)
  isMechanic = isMech
end)

RegisterNetEvent("bms:jobs:mecanic:repairComplete")
AddEventHandler("bms:jobs:mecanic:repairComplete", function(repCosts)
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, true)
  repairing = true
  local reptime = 30000

  TriggerEvent("bms:vehicles:vehcontrol", 5)
  exports.vehicles:blockIgnition(true)

  SetVehicleDoorOpen(veh, 4)

  while (repairing) do
    Wait(1000)
    reptime = reptime - 1000
    
    if (reptime <= 0) then
      SendNUIMessage({hideJobProgress = true})
      SetVehicleFixed(veh)
      SetVehicleDeformationFixed(veh)
      SetVehicleDoorShut(veh, 4)
      exports.vehicles:blockIgnition(false)
      exports.pnotify:SendNotification({text = string.format("Your vehicle has been repaired.  The cost was <span style='color: lawngreen'>$%s</span>.", repCosts)})
      repblock = false
      repairing = false

      local repspot = repairSpots[lastRepSpot]

      if (repspot and repspot.did and repspot.event) then
        TriggerEvent(repspot.event, {repCosts = repCosts, did = repspot.did})
      end
    else
      SendNUIMessage({updateJobProgress = true, title = "Repairing your vehicle.. Please Wait", maxvalue = 30, progvalue = reptime / 1000})
    end
  end
end)

RegisterNetEvent("bms:jobs:mechanic:showHandling")
AddEventHandler("bms:jobs:mechanic:showHandling", function()
  local veh = GetVehiclePedIsIn(PlayerPedId())
  
  local fInitialDriveForce = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce")
  local fClutchChangeRateScaleUpShift = GetVehicleHandlingFloat(veh, "CHandlingData", "fClutchChangeRateScaleUpShift")
  local fClutchChangeRateScaleDownShift = GetVehicleHandlingFloat(veh, "CHandlingData", "fClutchChangeRateScaleDownShift")
  local fBrakeBiasFront = GetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront")
  local fDriveBiasFront = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront")
  local fInitialDragCoeff = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDragCoeff")
  local fLowSpeedTractionLossMult = GetVehicleHandlingFloat(veh, "CHandlingData", "fLowSpeedTractionLossMult")
  local fDriveInertia = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia")

  print(string.format("fInitialDriveForce: %s\nfClutchChangeRateScaleUpShift: %s\nfClutchChangeRateScaleDownShift: %s\nfBrakeBiasFront: %s\nfDriveBiasFront: %s\nfInitialDragCoeff: %s\nfLowSpeedTractionLossMult: %s\nfDriveInertia: %s\n",
    fInitialDriveForce, fClutchChangeRateScaleUpShift, fClutchChangeRateScaleDownShift, fBrakeBiasFront, fDriveBiasFront, fInitialDragCoeff, fLowSpeedTractionLossMult, fDriveInertia))
end)

--[[RegisterNetEvent("bms:jobs:mechanic:updateLifts")
AddEventHandler("bms:jobs:mechanic:updateLifts", function(data)  
  if (data) then
    if (data.carLiftSettings) then
      carLiftSettings = data.carLiftSettings
      carLiftSettings.blockLiftControl = false
    end

    if (data.carLifts) then
      carLifts = data.carLifts

      for _,v in pairs(carLifts) do
        if (NetworkDoesEntityExistWithNetworkId(v.entities.base)) then
          v.entities.baseLocalEnt = v.entities.base
        end

        if (NetworkDoesEntityExistWithNetworkId(v.entities.lift)) then
          v.entities.liftLocalEnt = v.entities.lift
        end
      end
    end
  end
end)]]

RegisterNUICallback("bms:jobs:tuner:menuExit", function()
  local ped = PlayerPedId()
  
  SetNuiFocus(false, false)

  if (not tunertimer.active) then
    ClearPedTasks(ped)
  end
end)

RegisterNUICallback("bms:jobs:tuner:applyTunerMods", function(data)
  if (data) then
    Citizen.CreateThread(function()
      tunertimer.active = true
      tunertimer.cur = tunertimer.max
      SetVehicleEngineOn(mlastveh, false)
      SetVehicleDoorOpen(mlastveh, 4)
      exports.emotes:setCanEmote(false)
      
      while (tunertimer.active) do
        Wait(1000)
        tunertimer.cur = tunertimer.cur - 1
        
        if (tunertimer.cur <= 0) then
          tunertimer.active = false
          SendNUIMessage({hideJobProgress = true})
          applyTunerChanges(data, mlastveh)
          exports.emotes:setCanEmote(true)
          ClearPedTasks(PlayerPedId())
          SetVehicleDoorShut(mlastveh, 4)
        else
          SendNUIMessage({updateJobProgress = true, title = "Working on this vehicle.. Please Wait", maxvalue = tunertimer.max, progvalue = tunertimer.cur})
        end
      end
    end)
  end
end)

AddEventHandler("bms:jobs:mech:sendEmployment", function(employmentStatus)
  if (employmentStatus) then
    empStatus = employmentStatus

    for _,rep in pairs(repairSpots) do
      rep.isEmp = false
    end

    if (#empStatus > 0) then
      for _,shop in pairs(empStatus) do
        for _,rep in pairs(repairSpots) do
          if (rep.did == shop.did) then
            rep.isEmp = shop.isEmp
            print(string.format("Setting emp at %s", rep.did))
            break
          end
        end
      end
    end

  end
end)

AddEventHandler("bms:lawenf:activedutyswitch", function(onDuty)
  isLeoOnDuty = onDuty

  -- Update combinational variable
  isResponderOnDuty = isLeoOnDuty or isEmsOnDuty
end)

AddEventHandler("bms:ems:activeDutySwitch", function(onDuty)
  isEmsOnDuty = onDuty

  -- Update combinational variable
  isResponderOnDuty = isLeoOnDuty or isEmsOnDuty
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    for _,v in pairs(repairMarkers) do
      DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0, 0, 0, 0, 0, 0, 0, 5.0, 5.0, 0.15, 200, 200, 0, 50, 0, 0, 2, 0, 0, 0, 0)

      if (v.dist < 15) then
        local inVeh = IsPedInAnyVehicle(ped) -- repair last if not in vehicle, this is so destroyed vehicles which you can't enter can still be pushed to a repair shop
        local veh = GetVehiclePedIsIn(ped, true)
        local vpos = GetEntityCoords(veh)
        local dist = #(pos - v.pos)
        local vdist = #(pos - vpos)

        if ((dist < 5.0 and inVeh and GetPedInVehicleSeat(veh, -1) == ped) or (dist < 5.0 and not inVeh and veh ~= 0 and vdist < 5.0)) then
          local vbh = GetVehicleBodyHealth(veh)
          local veng = GetVehicleEngineHealth(veh)
                  
          local vbrc = 1000.0 - vbh
          local verc = 1000.0 - veng
          local totalCost = 0
              
          if (not isResponderOnDuty) then
            totalCost = math.ceil(((vbrc + verc) / 2000.0) * repairModifier * lastVehPrice)

            if (totalCost > maxRepairCost) then
              totalCost = maxRepairCost
            end

            totalCost = math.ceil(totalCost * v.markup)

            if (totalCost > maxRepairCost) then
              totalCost = maxRepairCost
            end

            if (isMechanic) then
              totalCost = math.ceil(totalCost * mechDiscount)
            end

            if (v.isEmp) then
              totalCost = math.ceil(totalCost * mechDiscount)
            end
          end
          
          if (not repairing) then
            if (isResponderOnDuty) then
              drawTxt("Press ~b~[E]~w~ to repair this vehicle.  Free for on duty city agencies.", 0, 1, 0.5, 0.8, 0.6, 255, 255, 255, 255)
            else
              drawTxt(string.format("Press ~b~[E]~w~ to repair this vehicle for ~g~$%s.", totalCost), 0, 1, 0.5, 0.8, 0.6, 255, 255, 255, 255)
            end

            if (IsControlJustReleased(1, 38)) then
              if (not repblock) then
                if (vbh < 1000 or veng < 1000 or IsVehicleDamaged(veh)) then
                  repblock = true
                  lastRepSpot = v.idx
                  SetEntityVelocity(veh, 0.0, 0.0, 0.0)
                  TriggerServerEvent("bms:jobs:mechanic:repairVehicle", totalCost)
                end
              end
            end
          end
        end
      end
    end
    
    if (lastRepSpot > 0) then
      local dist = #(pos - repairSpots[lastRepSpot].pos)
      
      if (dist > 15.0) then -- High so it doesn't reset while people run around while their car is repairing
        lastRepSpot = 0
      end
    end

    --[[for liftId,v in pairs(carLifts) do
      if (v.entities and v.entities.baseLocalEnt) then
        local ent = NetworkGetEntityFromNetworkId(v.entities.baseLocalEnt)

        if (DoesEntityExist(ent)) then
          local bpos = GetEntityCoords(ent)
          local offset

          if (carLiftSettings.switchOffset) then
            offset = vec3(bpos.x + carLiftSettings.switchOffset.x, bpos.y + carLiftSettings.switchOffset.y, bpos.z + carLiftSettings.switchOffset.z)
          end

          local dist = #(pos - offset)

          --print(string.format("%s >> %s", dist, json.encode(offset)))

          if (dist < 1.0) then
            DrawMarker(1, bpos.x, bpos.y, bpos.z, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 1.2, 255, 0, 0, 255, 1, 0, 0, 0, 0, 0, 0) -- TODO disable
            draw3DTextGlobal(bpos.x, bpos.y, bpos.z, "~w~Press ~b~[H]~w~ to toggle the vehicle lift.", 0.29)

            if (IsControlJustReleased(1, 74) and not carLiftSettings.blockLiftControl) then
              carLiftSettings.blockLiftControl = true
              TriggerServerEvent("bms:jobs:mechanic:toggleLiftState", liftId)
            end
          end
        end
      end
    end]]

    -- ### NEEDS TO BE OPTIMIZED BEFORE ENABLING ###
    --[[ TEMPORARILY DISABLED - UNCOMMENT TO ENABLE ]]
    --[[if (isMechanic) then
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)

      for _,v in pairs(mechanicspots) do
        local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)

        if (dist < v.radius) then
          local veh = getVehicleInDirection(pos, GetOffsetFromEntityInWorldCoords(ped, 0.0, 3.0, 0.0), ped)

          if (veh and veh ~= 0) then
            drawTxt("~w~Press [~b~H~w~] to work on this vehicle.", 0, 1, 0.5, 0.825, 0.6, 255, 255, 255, 255)

            if (IsControlJustReleased(1, 74) or IsDisabledControlJustReleased(1, 74)) then
              local face = GetOffsetFromEntityInWorldCoords(ped, 0.0, -1.0, 0.0)

              TaskTurnPedToFaceCoord(ped, face.x, face.y, face.z, 2000)
              Wait(2000)
              TaskStartScenarioInPlace(ped, "WORLD_HUMAN_VEHICLE_MECHANIC", 0, true)
              mlastveh = veh
              
              local plate = string.lower(ttrim(GetVehicleNumberPlateText(veh)))
              local mveh = mvehdefaults[plate]

              if (not mveh) then
                mvehdefaults[plate] = {
                  fInitialDriveForce = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce"),
                  fClutchChangeRateScaleUpShift = GetVehicleHandlingFloat(veh, "CHandlingData", "fClutchChangeRateScaleUpShift"),
                  fClutchChangeRateScaleDownShift = GetVehicleHandlingFloat(veh, "CHandlingData", "fClutchChangeRateScaleDownShift"),
                  fBrakeBiasFront = GetVehicleHandlingFloat(veh, "CHandlingData", "fBrakeBiasFront"),
                  fDriveBiasFront = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveBiasFront"),
                  fInitialDragCoeff = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDragCoeff"),
                  fLowSpeedTractionLossMult = GetVehicleHandlingFloat(veh, "CHandlingData", "fLowSpeedTractionLossMult"),
                  fDriveInertia = GetVehicleHandlingFloat(veh, "CHandlingData", "fDriveInertia")
                }
                meccurrentveh = {boost = 0, acceleration = 0, gearchange = 0, braking = 5, drivetrain = 5}
              end
              local tunesettings = meccurrentveh
              local curhandling = mvehdefaults[plate]

              print(json.encode(curhandling))

              SendNUIMessage({showTuner = true, tunesettings = tunesettings, curhandling = curhandling})
              SetNuiFocus(true, true)
              intunermenu = true
            end
          end
        end
      end
    end]]
  end
end)

AddEventHandler("bms:lawenf:activedutyswitch", function(duty)
  isResponderOnDuty = duty
end)

AddEventHandler("bms:ems:activedutyswitch", function(duty)
  isResponderOnDuty = duty
end)

AddEventHandler("bms:doc:activedutyswitch", function(duty)
  isResponderOnDuty = duty
end)

Citizen.CreateThread(function()
  while true do
    Wait(1500)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local rMarkers = {}
    local iter = 0

    for i=1,#repairSpots do
      local dist = #(pos - repairSpots[i].pos)

      if (dist < 80) then
        iter = iter + 1
        rMarkers[iter] = repairSpots[i]
        rMarkers[iter].dist = dist
        rMarkers[iter].idx = i
      end
    end

    repairMarkers = rMarkers

    -- Retrieves the last vehicle price for repair diff
    local veh = GetVehiclePedIsIn(ped, true)
    if (veh ~= 0 and lastVeh ~= veh) then
      lastVeh = veh
      local model = GetEntityModel(veh)
      
      lastVehPrice = exports.vehicles:getVehiclePriceFromModel(model)
    end

  end
end)
