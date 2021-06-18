local phoneShops = {}
local phones = {}
local phoneProps = {}
local shopBlips = {} -- TODO upload minimap.ytd to live
local lastShop = 0
local browseCams = -1
local browsing = {cur = 1, camOffsetZ = 0.55}
local blockAction = false
local blockNav = false
local blockBuy = false
local moveProp = {active = false}

local function draw3dPhoneShopText(x, y, z, text, sc)
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

function spawnPhoneProps(shopIndex)
  Citizen.CreateThread(function()
    local shop = phoneShops[shopIndex]

    if (not shop) then return end

    if (shop.props) then
      clearPhoneProps()

      for prIndex, prop in pairs(shop.props) do
        local hash = GetHashKey(prop.model)

        while (not HasModelLoaded(hash)) do
          RequestModel(hash)
          Wait(10)
        end

        local pr = CreateObject(hash, prop.pos, prop.rot, false)

        SetEntityRotation(pr, prop.rot.x, prop.rot.y, prop.rot.z, 2)
        phoneProps[prIndex] = pr
        SetModelAsNoLongerNeeded(hash)
      end
    end
  end)
end

function clearPhoneProps()
  for _, prop in pairs(phoneProps) do
    DeleteEntity(prop)
  end

  phoneProps = {}
end

function toggleBrowseCam(shopIndex)
  local shop = phoneShops[shopIndex]

  if (browseCams ~= -1) then
    RenderScriptCams(0, 0, 3000, 1, 0)

    for _,cam in pairs(browseCams) do
      DestroyCam(cam)
    end

    browseCams = -1
    SendNUIMessage({togglePhoneInfo = true, toggle = false})
  else
    browseCams = {}
    
    for index ,prop in pairs(shop.props) do
      local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", prop.pos.x, prop.pos.y, prop.pos.z + browsing.camOffsetZ, 0, 0, 0, GetGameplayCamFov(), 0, 0)
      local phoneProp = phoneProps[index]

      SetCamFov(cam, 60.0)
      SetCamRot(cam, -90.0, 0.0, 29.0)
      browseCams[index] = cam
    end

    SetCamActive(browseCams[1], true)
    RenderScriptCams(1, 0, 3000, 1, 0)
    SendNUIMessage({togglePhoneInfo = true, toggle = true})

    local shop = phoneShops[lastShop].props[browsing.cur]
    local phone = phones[shop.model]
    local price = phone.price

    SendNUIMessage({setCurrentPhone = true, text = string.format("%s [$%s]", phone.desc, phone.price)})
  end
end

function doCameraLerp(lastCam)
  local fromCam = browseCams[lastCam]
  local toCam = browseCams[browsing.cur]

  if (toCam and toCam ~= -1 and fromCam and fromCam ~= -1) then
    SetCamActiveWithInterp(toCam, fromCam, 500, true, true)
  else
    print(string.format("%s, %s", GetRenderingCam(), browseCams[lastShop]))
  end

  local shop = phoneShops[lastShop].props[browsing.cur]
  local phone = phones[shop.model]
  local price = phone.price

  SendNUIMessage({setCurrentPhone = true, text = string.format("%s [$%s]", phone.desc, phone.price)})
end

RegisterNetEvent("bms:comms:phoneShop:init")
AddEventHandler("bms:comms:phoneShop:init", function(data)
  if (not data) then return end

  phoneShops = data.phoneShops or {}
  phones = data.phones or {}

  for _, shop in pairs(phoneShops) do
    local blip = AddBlipForCoord(shop.pos.x, shop.pos.y, shop.pos.z)

    SetBlipSprite(blip, 491)
    SetBlipColour(blip, 32)
    SetBlipDisplay(blip, 4)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Cellphone Shop")
    EndTextCommandSetBlipName(blip)
    shopBlips[blip] = blip
  end
end)

RegisterNetEvent("bms:comms:phone:setPhoneModel")
AddEventHandler("bms:comms:phone:setPhoneModel", function(model)
  lastPhoneModel = model

  local phone = phones[lastPhoneModel]
  local phModel = "None"

  for m, d in pairs(phones) do
    if (m == lastPhoneModel) then
      phModel = d.desc
      break
    end
  end

  SendNUIMessage({setPhoneModel = true, model = phModel})
end)

RegisterNetEvent("bms:comms:phoneStore:movePhone")
AddEventHandler("bms:comms:phoneStore:movePhone", function(model)
  if (not model) then return end

  if (model == "save") then
    print(json.encode(moveProp.pos, {indent = true}))
    exports.pnotify:SendNotification({text = "Phone data saved to console."})
    return
  end

  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local atIndex = 1
  local propIndex = 1

  for shopIndex, shop in pairs(phoneShops) do
    local dist = #(pos - shop.pos)

    if (dist < 20.0) then
      atIndex = shopIndex
      break
    end
  end

  local shop = phoneShops[atIndex]

  if (not shop) then
    exports.pnotify:SendNotification({text = "Could not find closest shop."})
    return
  end

  for prIndex, pr in pairs(shop.props) do
    if (pr.model == model) then
      propIndex = prIndex
      break
    end
  end

  moveProp.prop = phoneProps[propIndex]

  if (moveProp.prop and DoesEntityExist(moveProp.prop)) then
    moveProp.pos = GetEntityCoords(moveProp.prop)
    moveProp.active = true
  else
    exports.pnotify:SendNotification({text = "Could not find prop."})
  end
end)

AddEventHandler("bms:comms:phoneStore:takeOtherPlayerPhone", function(nearByPed)
  local nearPed = GetPlayerPed(GetPlayerFromServerId(nearByPed))
  local otherPedZipped = DecorGetBool(nearPed, "ziptied")
  local otherPedCuffed = IsEntityPlayingAnim(nearPed, "mp_arresting", "idle", 3)
  local otherPlayer
  
  if (otherPedCuffed or otherPedZipped) then
    for _,id in pairs(GetActivePlayers()) do
      local rped = GetPlayerPed(id)

      if (rped == nearPed) then
        otherPlayer = id
        break
      end
    end

    if (otherPlayer and not blockAction) then
      blockAction = true
      exports.management:TriggerServerCallback("bms:comms:phoneStore:takePlayerPhone", function(rdata)
        if (rdata and rdata.msg) then
          exports.pnotify:SendNotification({text = rdata.msg})
        end

        blockAction = false
      end, {otherPlayerSid = GetPlayerServerId(otherPlayer)})
    end
  else
    exports.pnotify:SendNotification({text = "You can only take someones phone if they are hand/zip cuffed."})
  end
end)

RegisterNUICallback("bms:comms:phoneStore:confirmBuy", function()
  SetNuiFocus(false, false)
  
  local phone = phoneShops[lastShop].props[browsing.cur]
  
  exports.management:TriggerServerCallback("bms:comms:phoneStore:purchasePhone", function(rdata)
    if (rdata) then
      if (rdata.msg) then
        exports.pnotify:SendNotification({text = rdata.msg})
      end
    end

    blockBuy = false
  end, {shop = lastShop, model = phone.model})
end)

RegisterNUICallback("bms:comms:phoneStore:cancelBuy", function()
  blockBuy = false
  SetNuiFocus(false, false)
end)

AddEventHandler("onResourceStop", function(res)
  if (res == GetCurrentResourceName()) then
    clearPhoneProps()
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(150)

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    for shopIndex, shop in pairs(phoneShops) do
      local dist = #(pos - shop.pos)

      if (dist < 50.0 and lastShop == 0) then
        lastShop = shopIndex
        spawnPhoneProps(shopIndex)
      end
    end

    if (lastShop > 0) then
      local shop = phoneShops[lastShop]
      
      if (shop) then
        local dist = #(pos - shop.pos)

        if (dist > 50.0) then
          lastShop = 0
          clearPhoneProps()
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    if (lastShop > 0) then
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local shop = phoneShops[lastShop]

      if (shop) then
        local dist = #(pos - shop.browseSpot)

        if (dist < 30.0) then
          DrawMarker(1, shop.browseSpot.x, shop.browseSpot.y, shop.browseSpot.z - 1, 0, 0, 0, 0, 0, 0, 1.1, 1.1, 0.35, 0, 110, 120, 45)
          
          if (dist < 0.55 and not blockAction) then
            draw3dPhoneShopText(shop.browseSpot.x, shop.browseSpot.y, shop.browseSpot.z + 0.25, "Press ~b~[H]~w~ to browse the phones.", 0.29)

            if (IsControlJustReleased(1, 74)) then
              blockAction = true
              browsing.cur = 1
              toggleBrowseCam(lastShop)
            end
          end
        end

        if (browseCams ~= -1) then
          DisableControlAction(0, 32, true)  -- Movement
          DisableControlAction(0, 31, true)  --
          DisableControlAction(0, 34, true)  --
          DisableControlAction(0, 30, true)  --
          DisableControlAction(0, 24, true)  -- Attack
          DisablePlayerFiring(ped, true)     -- Disable weapon firing
          DisableControlAction(0, 142, true) -- MeleeAttackAlternate
          DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
          DisableControlAction(0, 37, true)  -- SelectWeapon
          DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
          DisableControlAction(0, 25, true)  -- INPUT_AIM
          HideHudAndRadarThisFrame()
          blockNav = IsCamInterpolating(GetRenderingCam())

          if (not blockNav) then
            if (IsDisabledControlJustReleased(1, 34)) then -- A
              local lastCam = browsing.cur
              
              browsing.cur = browsing.cur - 1
              
              if (browsing.cur < 1) then
                browsing.cur = #shop.props
              end

              doCameraLerp(lastCam)
            elseif (IsDisabledControlJustReleased(1, 35)) then -- D
              local lastCam = browsing.cur
              
              browsing.cur = browsing.cur + 1

              if (browsing.cur > #shop.props) then
                browsing.cur = 1
              end

              doCameraLerp(lastCam)
            elseif (IsControlJustReleased(1, 177)) then -- Backspace
              browsing.cur = 1
              toggleBrowseCam()
              blockAction = false
            elseif (IsControlJustReleased(1, 38) and not blockBuy) then -- E
              blockBuy = true
              local shop = phoneShops[lastShop].props[browsing.cur]
              local phone = phones[shop.model]
              local price = phone.price

              SetNuiFocus(true, true)
              SendNUIMessage({showBuyDialog = true, desc = phone.desc, price = phone.price})
            end
          end
        end
      end
    end

    if (moveProp.active and moveProp.prop) then
      local xOffset = moveProp.pos.x
      local yOffset = moveProp.pos.y
      
      if (IsControlPressed(1, 172)) then -- arrow up
        yOffset = yOffset + 0.001
      elseif (IsControlPressed(1, 173)) then -- arrow down
        yOffset = yOffset - 0.001
      elseif (IsControlPressed(1, 174)) then -- arrow left
        xOffset = xOffset - 0.001
      elseif (IsControlPressed(1, 175)) then -- arrow right
        xOffset = xOffset + 0.001
      end

      SetEntityCoords(moveProp.prop, xOffset, yOffset, moveProp.pos.z)
      moveProp.pos = GetEntityCoords(moveProp.prop)
    end
  end
end)