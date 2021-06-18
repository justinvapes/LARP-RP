local bmfacspots = {}
local bmblips = {}
local curLoc = 0
local lastBmspot
local curBlip
local propsInit = false
local bmprophash = "prop_gun_frame"
local showingBlackmarket = false
local blockInput = false
local waiting = false
local waitTime = 0
local waitMax = 10000 -- TODO change to 10000
local wanderWarn = false
local attdata = {}
local blockPurchase = false
local globalSpot = nil

function startWaitTime()
  Citizen.CreateThread(function()
    while waiting do
      Wait(1000)
      waitTime = waitTime + 1000
      
      if (waitTime >= waitMax) then
        waiting = false
        waitTime = 0
        TriggerServerEvent("bms:blackmarket:getWeapons")
      end
    end
  end)
end

--[[function setupProps()
  for _,v in pairs(bmspots) do
    if (v.crhandle == 0) then
      local hash = GetHashKey(v.name)
      local prop = CreateObject(hash, v.crpos.x, v.crpos.y, v.crpos.z, false, false)

      PlaceObjectOnGroundProperly(prop)
      SetEntityHeading(prop, v.crpos.heading)
    end
  end
end]]

function setupSpot(bmspot)
  if (curBlip) then
    RemoveBlip(curBlip)
    curBlip = nil
  end
  
  local pos = bmspot.pos
  
  curBlip = AddBlipForCoord(pos.x, pos.y, pos.z)
  
  SetBlipSprite(curBlip, 313)
  SetBlipDisplay(curBlip, 4)
  SetBlipColour(curBlip, 1)
  SetBlipScale(curBlip, 0.9)
  SetBlipAsShortRange(curBlip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentSubstringPlayerName("Black Market Dealer")
  EndTextCommandSetBlipName(curBlip)
  
  lastBmspot = bmspot
end

function setupBlips()
  for _,v in pairs(bmfacspots) do
    local curBlip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
    
    SetBlipSprite(curBlip, 313)
    SetBlipDisplay(curBlip, 4)
    SetBlipColour(curBlip, 1)
    SetBlipScale(curBlip, 0.9)
    SetBlipAsShortRange(curBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Black Market Dealer")
    EndTextCommandSetBlipName(curBlip)

    table.insert(bmblips, curBlip)
  end
end

function pedHasWeapon(wep)
  local ped = PlayerPedId()
  local hash = GetHashKey(wep)
  
  return HasPedGotWeapon(ped, hash, false)
end

--[[RegisterNetEvent("bms:blackmarket:hasbmfac")
AddEventHandler("bms:blackmarket:hasbmfac", function(spots)
  if (spots) then
    bmfacspots = spots
  end
end)]]

RegisterNetEvent("bms:blackmarket:sendSpot")
AddEventHandler("bms:blackmarket:sendSpot", function(spot)
  if (spot == nil) then
    if (globalSpot and globalSpot.dealer) then
      DeleteEntity(globalSpot.dealer)

      if (DoesEntityExist(globalSpot.dealer)) then
        SetEntityAsNoLongerNeeded(globalSpot.dealer)
      end

      globalSpot.dealer = nil
    end

    if (globalSpot and globalSpot.spProps) then
      for i=1,#globalSpot.spProps do
        DeleteObject(globalSpot.spProps[i])

        if (DoesEntityExist(globalSpot.spProps[i])) then
          SetEntityAsNoLongerNeeded(globalSpot.spProps[i])
        end
      end

      globalSpot.spProps = nil
    end
  end
  
  globalSpot = spot
end)

RegisterNetEvent("bms:blackmarket:updateCurSpot")
AddEventHandler("bms:blackmarket:updateCurSpot", function(bmspot, spidx)
  if (not spidx or spidx == -1) then
    curLoc = 0
    
    if (curBlip) then
      RemoveBlip(curBlip)
      curBlip = nil
    end
  else
    curLoc = spidx
    
    if (bmspot.pos) then
      setupSpot(bmspot)
    end
  end
end)

RegisterNetEvent("bms:blackmarket:setWeapons")
AddEventHandler("bms:blackmarket:setWeapons", function(data)
  exports.inventory:blockTrade(true)
  exports.vehicles:blockTrunk(true)
  exports.inventory:blockInventoryOpen(true)
  SendNUIMessage({loadWeapons = true, weapons = data.weapons, tier = data.tier, open = true})
  showingBlackmarket = true
  SetNuiFocus(true, true)
end)

RegisterNetEvent("bms:blackmarket:refillAmmo")
AddEventHandler("bms:blackmarket:refillAmmo", function(weapon, ppb, hash)
  if (weapon and hash) then
    local phw = pedHasWeapon(hash)
    
    if (phw) then
      local ped = PlayerPedId()
      local ammo = GetAmmoInPedWeapon(ped, weapon.hash)
      local maxammo = 250--GetMaxAmmo(ped, weapon.hash)
      
      local price = math.ceil(maxammo - ammo) * ppb
      local newammo = maxammo - ammo
      
      local param = {}

      param.weapon = weapon
      param.weapon.hash = hash
      param.ammo = newammo      
      TriggerServerEvent("bms:blackmarket:buyAmmoRefill", price, "bms:blackmarket:ammoBought", param)
    else
      SendNUIMessage({
        setStatus = true,
        statustext = "You do not own this weapon."
      })
      
      SendNUIMessage({
        unblockAmmo = true
      })
    end
  end
end)

RegisterNetEvent("bms:blackmarket:ammoBought")
AddEventHandler("bms:blackmarket:ammoBought", function(ret)
  Citizen.Trace("hit")
  if (ret) then
    SendNUIMessage({
      unblockAmmo = true
    })
    
    SendNUIMessage({
      setStatus = true,
      statustext = "Your ammunition has been refilled."
    })
    
    if (ret.weapon and ret.ammo) then
      local ped = PlayerPedId()
      AddAmmoToPed(ped, ret.weapon.hash, ret.ammo)
    end
  else
    SendNUIMessage({
      unblockAmmo = true
    })
    
    SendNUIMessage({
      setStatus = true,
      statustext = "You can not afford to fill your ammunition."
    })
  end
end)

RegisterNetEvent("bms:blackmarket:assignItem")
AddEventHandler("bms:blackmarket:assignItem", function(data)
  if (data) then
    if (data.success) then
      local id = data.itemid
      local ped = PlayerPedId()

      if (id == 1) then
        SetPedArmour(ped, 25)
      end

      SendNUIMessage({
        unblockBuy = true
      })
      
      SendNUIMessage({
        setStatus = true,
        statustext = "You have purchased some body armor."
      })
    else
      SendNUIMessage({
        unblockBuy = true
      })
      
      SendNUIMessage({
        setStatus = true,
        statustext = "You can not afford this item."
      })
    end
  end
end)

RegisterNetEvent("bms:blackmarket:init")
AddEventHandler("bms:blackmarket:init", function(data)
  if (data) then
    local weapons = data.weapons or {}
    local attachments = data.attachments or {}

    for k,v in pairs(weapons) do
      for a,att in pairs(attachments) do
        local aid = tostring(a)

        for _,ahash in pairs(att.hashes) do
          if (DoesWeaponTakeWeaponComponent(GetHashKey(v.hash), GetHashKey(ahash))) then
            if (not attdata[v.name]) then
              attdata[v.name] = {attachments = {}}
            end

            if (not attdata[v.name].attachments[aid]) then
              attdata[v.name].attachments[aid] = {}
            end

            attdata[v.name].attachments[aid].compatible = true
            attdata[v.name].attachments[aid].price = att.price
            attdata[v.name].attachments[aid].hash = ahash
          end
        end
      end
    end

    print(string.format("attdata >> %s", exports.devtools:dump(attdata["TEC-9"])))
    SendNUIMessage({loadAttData = true, attdata = attdata})
  end
end)

RegisterNetEvent("bms:blackmarket:applyBodyArmor")
AddEventHandler("bms:blackmarket:applyBodyArmor", function(data)
  if (data and data.armor) then
    local ped = PlayerPedId()
    local carmor = GetPedArmour(ped)

    carmor = carmor + data.armor
    SetPedArmour(ped, carmor)
  end
end)

RegisterNUICallback("bms:blackmarket:bmWindowClosed", function(data, cb)
  showingBlackmarket = false
  blockInput = false
  SetNuiFocus(false, false)
  exports.inventory:blockTrade(false)
  exports.vehicles:blockTrunk(false)
  exports.inventory:blockInventoryOpen(false)
end)

RegisterNUICallback("bms:blackmarket:purchaseWeapon", function(data)
  if (data.weaponid and data.attachments and not blockPurchase) then
    blockPurchase = true
    exports.management:TriggerServerCallback("bms:blackmarket:purchaseWeapon", function(rdata)
      if (rdata) then
        if (rdata.success) then
          if (rdata.weapon) then
            local weapon = rdata.weapon
            local ped = PlayerPedId()

            GiveWeaponToPed(ped, weapon.model, weapon.ammo)
            SetAmmoInClip(ped, weapon.model, weapon.clipammo)

            for _,v in pairs(weapon.attachments) do
              GiveWeaponComponentToPed(ped, weapon.model, v.name)
            end
          end
        end

        if (rdata.msg) then
          exports.pnotify:SendNotification({text = rdata.msg})
        end
      end

      blockPurchase = false
      SendNUIMessage({togglePurchase = true, blocked = false})
    end, {weaponid = data.weaponid, attachments = data.attachments, attdata = attdata})
  end
end)

RegisterNUICallback("refillAmmo", function(data, cb)
  if (data.weapon) then
    TriggerServerEvent("bms:blackmarket:refillAmmo", data.weapon)
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    --[[if (not propsInit) then
      setupProps()
      propsInit = true
    end]]
    
    if (waiting) then
      --drawBmText(string.format("~b~%s seconds ~w~until the weapon dealer shows up.", math.ceil((waitMax - waitTime) / 1000)))
      exports.jobs:draw3DTextGlobal(lastBmspot.pos.x, lastBmspot.pos.y, lastBmspot.pos.z + 0.25, string.format("~b~%s seconds ~w~until the weapon dealer shows up.", math.ceil((waitMax - waitTime) / 1000)), 0.37)
      
      local sdist = #(pos - lastBmspot.pos)
      
      if (sdist > 20) then
        if (not wanderWarn) then
          wanderWarn = true
          exports.pnotify:SendNotification({text = "If you move too far away from this spot the deal will be cancelled."})
        end
        
        if (sdist > 15) then
          waiting = false
          waitTime = 0
          exports.pnotify:SendNotification({text = "You have wandered too far from the area and the weapon dealer was spooked."})
        end
      else
        wanderWarn = false
      end
    end
    
    if (curLoc > 0 and lastBmspot) then
      local dist = #(pos - lastBmspot.pos)

      if (dist < 45) then
        DrawMarker(1, lastBmspot.pos.x, lastBmspot.pos.y, lastBmspot.pos.z - 1.2, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.2, 200, 60, 60, 70, 0, 0, 2, 0, 0, 0, 0)
        
        if (dist < 0.9) then
          exports.jobs:draw3DTextGlobal(lastBmspot.pos.x, lastBmspot.pos.y, lastBmspot.pos.z + 0.25, "~w~Press ~b~E~w~ to talk to the ~r~Black Market~w~ dealer.", 0.37)
          
          if (not blockInput) then
            if (exports.jobs:isGameControlPressed(1, 38)) then
              blockInput = true
              TriggerServerEvent("bms:blackmarket:getWeapons")
            end
          end
        end
      end
    end
    
    if (showingBlackmarket) then
      DisableControlAction(0, 1, true) -- LookLeftRight
      DisableControlAction(0, 2, true) -- LookUpDown
      DisableControlAction(0, 24, true) -- Attack
      DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
      HideHudAndRadarThisFrame()
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1500)

    if (bmfacspots and #bmblips == 0) then
      setupBlips()
    end

    if (globalSpot and globalSpot.pos) then
      local pos = GetEntityCoords(PlayerPedId())
      local dist = #(pos - globalSpot.pos)

      if (dist < 65) then
        if (not globalSpot.dealer) then    
          local hash = GetHashKey("s_m_y_robber_01")
          RequestModel(hash)
          while (not HasModelLoaded(hash)) do
            Wait(10)
          end
          
          local dped = CreatePed(4, hash, globalSpot.pos.x, globalSpot.pos.y, globalSpot.pos.z - 1, 0, false, true)
          while (not DoesEntityExist(dped)) do
            Wait(10)
          end
          SetEntityInvincible(dped, true)
          SetBlockingOfNonTemporaryEvents(dped, true)
          TaskSetBlockingOfNonTemporaryEvents(dped, true)
          FreezeEntityPosition(dped, true)
          SetModelAsNoLongerNeeded(hash)
    
          globalSpot.dealer = dped
        end

        if (globalSpot.props and not globalSpot.spProps) then
          globalSpot.spProps = {}
          local iter = 0

          for i=1,#globalSpot.props do
            local hash = GetHashKey(globalSpot.props[i].prop)
            RequestModel(hash)
            while (not HasModelLoaded(hash)) do
              Wait(10)
            end
            
            local obj = CreateObject(hash, globalSpot.props[i].pos, false, true, false)
            while (not DoesEntityExist(obj)) do
              Wait(10)
            end
            FreezeEntityPosition(obj, true)
  
            if (globalSpot.props[i].heading) then
              SetEntityHeading(obj, globalSpot.props[i].heading)
            end
            SetModelAsNoLongerNeeded(hash)
      
            iter = iter + 1
            globalSpot.spProps[iter] = obj
          end
        end
      else
        if (globalSpot.dealer) then
          DeleteEntity(globalSpot.dealer)

          if (DoesEntityExist(globalSpot.dealer)) then
            SetEntityAsNoLongerNeeded(globalSpot.dealer)
          end

          globalSpot.dealer = nil
        end

        if (globalSpot.spProps) then
          for i=1,#globalSpot.spProps do
            DeleteObject(globalSpot.spProps[i])

            if (DoesEntityExist(globalSpot.spProps[i])) then
              SetEntityAsNoLongerNeeded(globalSpot.spProps[i])
            end
          end

          globalSpot.spProps = nil
        end
      end
    end

  end
end)
