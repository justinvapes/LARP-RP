local table_insert = table.insert
local DrawMarker = DrawMarker
--local creatorCoords = {x = 402.880, y = -996.321, z = -99.0002, heading = 181.069}
local creatorCoords = {x = -1448.3446044922, y = -241.79663085938, z = 49.819149017334, heading = 229.896} --/teleport -1448 -241 49
local crCamCoords = {
  {x = -1446.2739257813, y = -243.32298278809, z = 50.324142456055, heading = 60.342}, -- default body
  {x = 0, y = 0, z = 0, heading = 0}, -- face
  {x = -1446.2739257813, y = -244.32298278809, z = 51.324142456055, heading = 60.342} -- zoom out body
}
local shopCoords = {
  {pos = vec3(75.948, -1392.225, 29.376)},
  {pos = vec3(125.764, -222.010, 54.557)},
  {pos = vec3(3.484, 6511.926, 31.877)},
  {pos = vec3(1193.137, 2714.616, 38.228)},
  {pos = vec3(-3170.366, 1045.199, 20.863)},
  {pos = vec3(-1106.5393066406, 2711.7370605469, 19.107872009277)},
  {pos = vec3(1693.4517822266, 4822.0048828125, 42.063129425049)},
  {pos = vec3(425.08575439453, -807.07043457031, 29.491123199463)},
  {pos = vec3(-1195.4951171875, -1577.7381591797, 4.6088328361511)},
  {pos = vec3(-1194.50708, -769.52008, 17.31926)},
  {pos = vec3(615.030, 2761.340, 42.088)} -- Rt. 68 Shop 2
}
local shopMarkers = {}
local copShopCoords = {
  {pos = vec3(461.814, -996.625, 30.690)},
  {pos = vec3(640.165, 5.64, 82.786)},
  {pos = vec3(-1107.875, -846.048, 19.316)},
  {pos = vec3(1841.4572753906, 3691.4338378906, 34.286647796631)},
  {pos = vec3(-438.086, 5988.745, 31.716)},
  {pos = vec3(-561.702, -131.482, 38.212)},
  {pos = vec3(826.90740966797, -1292.2308349609, 28.240659713745)},
  {pos = vec3(1707.0109863281, 2570.3903808594, -69.408515930176)},
  {pos = vec3(1833.816, 2583.627, 45.891)} -- prison
}
local copMarkers = {}
local docShopCoords = {
  {pos = vec3(1833.891, 2581.522, 45.891)}
}
local docMarkers = {}
local emsShopCoords = {
  {pos = vec3(336.202, -562.133, 28.743)},
  {pos = vec3(-635.554, -128.554, 39.014)},
  {pos = vec3(-731.262, 309.595, 85.092)},
  {pos = vec3(1817.637, 3680.117, 34.276)},
  {pos = vec3(-379.283, 6120.310, 31.631)},
  {pos = vec3(1185.4263916016, -1462.9750976563, 34.901607513428)},
  {pos = vec3(-1490.7801513672, -1026.5770263672, 6.2976603507996)},
  {pos = vec3(299.023, -598.102, 43.284)},
  {pos = vec3(199.09106445313, -1651.318359375, 29.803216934204)}
}
local emsMarkers = {}
local closetCoords = {
  {pos = vec3(-798.890, 328.336, 220.438)}, -- apartment a
  {pos = vec3(-798.890, 328.336, 190.713)}, -- apartment b
  {pos = vec3(-762.122, 329.360, 199.486)}, -- apartment c
}
local exClosetCoords = {}
--[[local closetCoords = {
  {pos = vec3(351.241, -993.794, -99.196)}, -- ipl1, ipl2
  {pos = vec3(259.782, -1004.025, -99.008)}, -- ipl3
  {pos = vec3(-1286.060, 438.082, 94.094)}, -- ipl4
  {pos = vec3(1969.218, 3814.665, 33.428)}, -- ipl5
  {pos = vec3(-798.890, 328.336, 220.438)}, -- apartment a
  {pos = vec3(-798.890, 328.336, 190.713)}, -- apartment b
  {pos = vec3(-762.122, 329.360, 199.486)}, -- apartment c
  --{pos = vec3(-56.318, -1289.590, 30.905)}, -- Gym
}]]
local closetMarkers = {}
local blips = {}
local copShopBlips = {}
local docShopBlips = {}
local emsShopBlips = {}
local showCreator = false
local lastPos = {x = 0, y = 0, z = 0}
local settingParts = false
local settingProps = false
local partidxs = {cur = 0, max = 0}
local textureidxs = {cur = 0, max = 0}
local proptextureidxs = {cur = 0, max = 0}
local paletteidxs = {cur = 2, max = 3}
local propidxs = {cur = 0, max = 0}
local overlayidxs = {cur = 0, max = 0}
local catid = 0
local curhaircol = 0
local curoverlaycol = 0
local components = {}
local props = {}
local mpoverlays = {}
local roomCam = -1
local curcamtype = 1
local debug = true -- displays debug labels
local savedcomps
local savedprops
local savedoverlays
local currcomps
local currprops
local curroverlays
local lastGenderId = 0
local lastTattoos
local iscop = false
local isdoc = false
local isems = false
local blockInput = false
local maskon = true
local veston = true
local blockvest = false
local lastselection = {cid = 1, pid = 0, added = false}
local lasttotalcosts = 0
local saveSlot = 1
local currSave = 1
local defaultComps = { -- 445 chars
  {cid = 0,tex = 0,draw = 0,pid = 2},{cid = 1,tex = 0,draw = 0,pid = 2},{cid = 2,tex = 4,draw = 11,pid = 2},{cid = 3,tex = 0,draw = 0,pid = 2},{cid = 4,tex = 5,draw = 1,pid = 2},{cid = 5,tex = 0,draw = 0,pid = 2},{cid = 6,tex = 0,draw = 1,pid = 2},{cid = 7,tex = 0,draw = 0,pid = 2},{cid = 8,tex = 0,draw = 0,pid = 2},{cid = 9,tex = 0,draw = 0,pid = 2},{cid = 10,tex = 0,draw = 0,pid = 2},{cid = 11,tex = 2,draw = 7,pid = 2},{cid = 100,hcol = 0}
}
local defaultProps = { -- 146
  {cid = 0,tex = -1,draw = -1},{cid = 1,tex = -1,draw = -1},{cid = 2,tex = -1,draw = -1},{cid = 6, tex = -1, draw = -1}, {cid = 7, tex = -1, draw = -1}
}
local defaultOverlays = { -- 351
  {cid = 0,tex = 0,draw = 255},{cid = 1,tex = 0,draw = 255},{cid = 2,tex = 0,draw = 255},{cid = 3,tex = 0,draw = 255},{cid = 4,tex = 0,draw = 255},{cid = 5,tex = 0,draw = 255},{cid = 6,tex = 0,draw = 255},{cid = 7,tex = 0,draw = 255},{cid = 8,tex = 0,draw = 255},{cid = 9,tex = 0,draw = 255},{cid = 10,tex = 0,draw = 255},{cid = 11,tex = 0,draw = 255}
}
local blockDbCall = false
local showdescript = false
local descriptors = {}
local lastDescId = 0
local didchanges = false
local inStore = false
local partcosts = {}
local ownedcomps = {}
local playerDispMode = 1
local exited = false
local showingrules = false
local lastArmor = 0
--[[local firstrun = true -- TODO change to true after test runs or the character selector will not close correctly

if (not firstrun) then
  print("-------------------------------------")
  print("cc_client.lua >> firstrun is set to false.  This should be set to true in a non testing environment or players will not get past the character selector.")
  print("-------------------------------------")
end]]

function initialize()
  for i = 0, 11 do
    local newc = {cid = i, draw = 0, tex = 0}
    local newo = {cid = i, draw = 255, tex = 0}

    table_insert(components, newc)
    table_insert(mpoverlays, newo)
  end

  local propindexes = {0, 1, 2, 6, 7}

  for i = 1, #propindexes do
    local cid = propindexes[i]
    local newp = {cid = cid, draw = -1, tex = -1}
    
    table_insert(props, newp)
  end
end

function setupCcBlips()
  for _,v in pairs(shopCoords) do
    local blip = AddBlipForCoord(v.pos)
    
    SetBlipSprite(blip, 366)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Clothing Shop")
    EndTextCommandSetBlipName(blip)
    
    table_insert(blips, blip)
  end
end

function setupCopBlips()
  for _,v in pairs(copShopCoords) do
    local blip = AddBlipForCoord(v.pos)
    
    SetBlipSprite(blip, 366)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Clothing Shop")
    EndTextCommandSetBlipName(blip)
    
    table_insert(copShopBlips, blip)
  end
end

function setupDocBlips()
  for _,v in pairs(docShopCoords) do
    local blip = AddBlipForCoord(v.pos)
    
    SetBlipSprite(blip, 366)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Clothing Shop")
    EndTextCommandSetBlipName(blip)
    
    table_insert(docShopBlips, blip)
  end
end

function setupEmsBlips()
  for _,v in pairs(emsShopCoords) do
    local blip = AddBlipForCoord(v.pos)
    
    SetBlipSprite(blip, 366)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Clothing Shop")
    EndTextCommandSetBlipName(blip)
    
    table_insert(emsShopBlips, blip)
  end
end

function drawCcText(text)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.32, 0.32)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(0.475, 0.88)
end

function removeCopBlips()
  for _,v in pairs(copShopBlips) do
    RemoveBlip(v)
  end
  
  copShopBlips = {}
end

function removeEmsBlips()
  for _,v in pairs(emsShopBlips) do
    RemoveBlip(v)
  end
  
  emsShopBlips = {}
end

function setPedComponents(cid, did, tid, pid)
  if (cid and did and tid and pid) then
    for i = 1, #components do
      if (components[i].cid == cid) then
        local comp = components[i]
        
        comp.draw = did
        comp.tex = tid
        comp.pid = pid
        
        break
      end
    end
  end
end

function setPedProps(cid, did, tid)
  if (cid and did and tid) then
    for i = 1, #props do
      if (props[i].cid == cid) then
        local prop = props[i]
        
        prop.draw = did
        prop.tex = tid
        
        break
      end
    end
  end
end

function setPedOverlays(cid, did, tid)
  if (cid and did) then
    print(string.format("setpedoverlays: %s, %s, %s", cid, did, tid))
    
    for i = 1, #mpoverlays do
      if (mpoverlays[i].cid == cid) then
        local ov = mpoverlays[i]

        ov.draw = did
        ov.tex = tid
        break
      end
    end
  end
end

function teleportToCreator(loaddefaults, comps, props, overlays, gender, plmoney)
  if (loaddefaults) then
    local ped = PlayerPedId()
    lastArmor = GetPedArmour(ped)
    local model = GetHashKey(gender)
    
    if IsModelInCdimage(model) and IsModelValid(model) then
      RequestModel(model)
      
      while not HasModelLoaded(model) do
        Citizen.Wait(10)
      end
      
      SetPlayerModel(PlayerId(), model)
      
      SetPedComponentVariation(ped, 0, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 1, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 2, 11, 4, 2)
      setPedComponents(2, 11, 4, 2)
      SetPedComponentVariation(ped, 3, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 4, 1, 5, 2)
      setPedComponents(4, 1, 5, 2)
      SetPedComponentVariation(ped, 5, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 6, 1, 0, 2)
      setPedComponents(6, 1, 0, 2)
      SetPedComponentVariation(ped, 7, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 8, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 9, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 10, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 11, 7, 2, 2)
      setPedComponents(11, 7, 2, 2)
      
      ClearPedProp(ped, 0)
      setPedProps(0, -1, -1)
      ClearPedProp(ped, 1)
      setPedProps(1, -1, -1)
      ClearPedProp(ped, 2)
      setPedProps(2, -1, -1)
      
      for _,v in pairs(mpoverlays) do
        SetPedHeadOverlay(ped, v.cid, 0, 1.0)
        setPedOverlays(v.cid, 255, 0)
      end

      SetModelAsNoLongerNeeded(model)
    end
  else
    -- load current model setup
    if (comps) then
      savedcomps = comps
      currSave = savedcomps.curr
      currcomps = savedcomps.saves[currSave]

      for _,v in pairs(currcomps) do
        if (v.cid == 100) then
          curhaircol = v.hcol
    
          local headid = getHeadId()
          SetPedHeadBlendData(ped, headid, headid, 0, headid, headid, 0, 0, 0, 0, 0)
          SetPedHairColor(ped, curhaircol, curhaircol)
        else
          setPedComponents(v.cid, v.draw, v.tex, v.pal or 2)
        end
      end
    end
    
    if (props) then
      savedprops = props
      currprops = savedprops.saves[currSave]
      
      for _,v in pairs(currprops) do
        setPedProps(v.cid, v.draw, v.tex)
      end
    --[[else
      TriggerServerEvent("bms:serverprint", "props was nil")]]
    end

    if (overlays) then
      savedoverlays = overlays
      curroverlays = savedoverlays.saves[currSave]

      for _,v in pairs(curroverlays) do
        local headid = getHeadId()
        SetPedHeadBlendData(ped, headid, headid, 0, headid, headid, 0, 0, 0, 0, 0)
        SetPedHeadOverlay(ped, v.cid, v.draw, 1.0)
        SetPedHeadOverlayColor(ped, v.cid, 1, v.tex, v.tex)
        setPedOverlays(v.cid, v.draw, v.tex)
      end
    end
  end
  
  teleport()
end

function teleport()
  local ped = PlayerPedId()
  
  SetPlayerForcedZoom(PlayerId(), true)
  SetFollowPedCamViewMode(1)
  
  while (not IsFollowPedCamActive()) do
    Citizen.Wait(1)
  end
  
  TriggerServerEvent("bms:teleporter:teleportToPoint", ped, {x = creatorCoords.x, y = creatorCoords.y, z = creatorCoords.z, h = creatorCoords.heading})
  
  Wait(10)
  setupCamera()
  blockInput = false
end

function setupCamera()
  local ped = PlayerPedId()
  
  if (roomCam == -1) then
    roomCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", crCamCoords.x, crCamCoords.y, crCamCoords.z, 0, 0, 0, GetGameplayCamFov(), 0, 0)
  end
  
  SetCamActive(roomCam, true)
  RenderScriptCams(1, 0, 3000, 1, 0)
  switchCamera(1)
end

function switchCamera(type)
  local ped = PlayerPedId()
  
  if (type == 2) then
    local bc = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0)

    SetCamCoord(roomCam, bc.x + 0.5, bc.y - 0.5, bc.z)
    PointCamAtCoord(roomCam, bc.x, bc.y, bc.z)
  else
    SetCamCoord(roomCam, crCamCoords[type].x, crCamCoords[type].y, crCamCoords[type].z)
    PointCamAtEntity(roomCam, ped)
  end
end

function checkPartOwnership()
  local ped = PlayerPedId()
  
  for k,v in pairs(partcosts) do
    if (k > 0 and k <= 11) then
      for _,v in pairs(components) do
        if (v.cid == k and not isCompOwned(k, v.draw)) then
          setPedComponents(k, -1, 0, 2)
          SetPedComponentVariation(ped, k, -1, 0, 2)
        end
      end
    elseif (k >= 50 and k <= 51) then -- prop support only for wrist/watch at the moment
      for _,v in pairs(props) do
        local cid = v.cid
        
        if (k == 50) then -- watch
          k = 6
        elseif (k == 51) then -- bracelet
          k = 7
        end

        if (v.cid == k and not isCompOwned(k, v.draw)) then
          setPedProps(k, -1, 0)
          ClearPedProp(ped, k)
        end
      end
    end
  end
end

function exitCreator()
  local ped = PlayerPedId()
  
  TriggerServerEvent("bms:teleporter:teleportToPoint", ped, lastPos)
  RenderScriptCams(0, 0, 3000, 1, 0)
  SetPlayerForcedZoom(PlayerId(), false)  
  playerDispMode = 1
  exited = true
  TriggerServerEvent("bms:csrp_gamemode:setTickDispMode", 1)
  FreezeEntityPosition(ped, false)
  SetPedArmour(ped, lastArmor)

  if (didchanges) then
    didchanges = false
    TriggerEvent("bms:cc:componentsChanged", components, props, mpoverlays, nil, nil) --function(comps, props, overlays, tattoos, mpskin)
  end

  checkPartOwnership()
  
  --[[
    elseif (cid > 0 and cid <= 11) then
      textureidxs.max = GetNumberOfPedTextureVariations(ped, cid, partidxs.cur)
      textureidxs.cur = 0
      SendNUIMessage({setTextureMax = true, cid = cid, texmax = textureidxs.max})
    elseif (cid >= 15 and cid < 18) then
      overlayidxs.cur = partidx
      overlayidxs.max = GetNumHeadOverlayValues(cid - 15)

      setPedOverlays(cid - 15, overlayidxs.cur, curoverlaycol)
      SetPedHeadOverlay(ped, cid - 15, overlayidxs.cur, 1.0)
    else
  ]]
  
  --[[if (not isCompOwned(lastselection.cid, lastselection.pid)) then
    if (lastselection.cid == 18 or lastselection.cid == 19) then
      setPedProps(lastselection.cid - 12, -1, 0)
      ClearPedProp(ped, lastselection.cid - 12)
    else
      setPartDirect(lastselection.cid, -1)
    end
  end]]
end

function loadMpSkinFromComponents(comps, pr, ovl, tattoos, armor, postNuiDisable, postNuiDisableEvent)
  local ped = PlayerPedId()
  local headid = 0

  components = comps
  
  if (pr and #pr > 0) then
    props = pr
  end
  
  --print(string.format("loadMpSkinFromComponents, %s, %s", tostring(ovl == nil), #ovl))
  
  if (#ovl > 0) then
    mpoverlays = ovl
  end

  print("loading overlays #: " .. #mpoverlays)

  for id = 1, #comps do
    local comp = comps[id]
    
    if (comp.cid == 0) then
      headid = comp.draw
    end

    if (comp.cid == 100) then
      curhaircol = comp.hcol
      SetPedHeadBlendData(ped, headid, headid, 0, headid, headid, 0, 0, 0, 0, 0)
      SetPedHairColor(ped, curhaircol, curhaircol)
    else
      local cost = getCostForPart(tonumber(comp.cid), tostring(comp.draw))

      if (cost > 0) then
        if (isCompOwned(comp.cid, comp.draw)) then
          SetPedComponentVariation(ped, tonumber(comp.cid), tonumber(comp.draw), tonumber(comp.tex), 2)
        else
          SetPedComponentVariation(ped, tonumber(comp.cid), -1, 2)
        end
      else
        SetPedComponentVariation(ped, tonumber(comp.cid), tonumber(comp.draw), tonumber(comp.tex), 2)
      end
    end
  end
  
  if (pr) then
    for id = 1, #pr do
      local prop = pr[id]
      
      if (prop.draw > -1) then
        local cost = getCostForPart(prop.cid, prop.draw)

        if (cost > 0) then
          if (isCompOwned(prop.cid, prop.draw)) then
            SetPedPropIndex(ped, prop.cid, prop.draw, prop.tex, true)
          else
            ClearPedProp(ped, prop.cid)
          end
        else
          SetPedPropIndex(ped, prop.cid, prop.draw, prop.tex, true)
        end
      end
    end
  end

  if (ovl) then
    for id = 1, #ovl do
      local ov = ovl[id]

      SetPedHeadOverlay(ped, ov.cid, ov.draw, 1.0)
      SetPedHeadOverlayColor(ped, ov.cid, 1, ov.tex, ov.tex) -- store color type in the future
    end
  end
  
  if (tattoos and tattoos ~= nil) then
    lastTattoos = tattoos
    exports.tattooshop:loadPlayerTattoos(tattoos)
  end
  
  TriggerServerEvent("bms:weapons:loadPlayerWeapons")

  if (armor and armor > 0) then
    SetPedArmour(ped, armor)
  end

  if (not inStore) then
    TriggerEvent("bms:characterSelectPostInit", {postNuiDisable = postNuiDisable, postNuiDisableEvent = postNuiDisableEvent})
  end
end

function isMpSkin()
  local ped = PlayerPedId()
  return IsPedModel(ped, "mp_f_freemode_01") or IsPedModel(ped, "mp_m_freemode_01")
end

function getHeadId()
  for _,v in pairs(components) do
    if (v.cid == 0) then
      return v.draw
    end
  end
end

function setHairColorDirect(colorid)
  local ped = PlayerPedId()
  local headid = getHeadId()

  curhaircol = colorid
  SetPedHeadBlendData(ped, headid, headid, 0, headid, headid, 0, 0, 0, 0, 0)
  SetPedHairColor(ped, curhaircol, curhaircol)
end

function setNextOverlayColor()
  curoverlaycol = curoverlaycol + 1
  local ped = PlayerPedId()
  local cols = 63

  if (curoverlaycol > cols) then
    curoverlaycol = 0
  end

  if (catid >= 15) then
    setPedOverlays(catid - 15, overlayidxs.cur, curoverlaycol)
    SetPedHeadOverlayColor(ped, catid - 15, 1, curoverlaycol, curoverlaycol)
  end
end

function setPrevOverlayColor()
  curoverlaycol = curoverlaycol - 1
  local ped = PlayerPedId()
  local cols = 63

  if (curoverlaycol < 0) then
    curoverlaycol = cols
  end

  if (catid >= 15) then
    setPedOverlays(catid - 15, overlayidxs.cur, curoverlaycol)
    SetPedHeadOverlayColor(ped, catid - 15, 1, curoverlaycol, curoverlaycol)
  end
end

function changeInfoText()
  if (debug) then
    local text = string.format("Cat: %s, Part: %s of %s, Tex: %s of %s, PCat: %s, Prop: %s, PTex: %s, TexVar: %s, PalVar: %s", catid, partidxs.cur, partidxs.max, textureidxs.cur, textureidxs.max, catid - 12, propidxs.cur, proptextureidxs.cur, GetNumberOfPedTextureVariations(PlayerPedId(),catid,partidxs.cur), GetPedPaletteVariation(PlayerPedId(), catid))
    
    SendNUIMessage({
      changeInfoText = true,
      text = text,
      changeNow = true
    })
  end
end

function changeDebugText()
  if (debug) then
    local text = string.format("Category: %s, Part: %s of %s, Texture: %s of %s, Prop: %s, Prop Texture: %s", catid, partidxs.cur, partidxs.max, textureidxs.cur, textureidxs.max, propidxs.cur, proptextureidxs.cur)
    
    SendNUIMessage({
      changeDebugText = true,
      text = text,
      changeNow = true
    })
  end
end

function setPartDirect(cid, partidx)
  print(string.format(string.format("setPartDirect called: %s, %s", cid, partidx)))
  lastselection.pid = partidxs.cur
  partidxs.cur = partidx

  local ped = PlayerPedId()

  setPedComponents(cid, partidxs.cur, textureidxs.cur, paletteidxs.cur or 2)  
  SetPedComponentVariation(ped, cid, partidxs.cur, textureidxs.cur, GetPedPaletteVariation(ped, cid))

  if (cid == 0) then
    SetPedHeadBlendData(ped, partidxs.cur, partidxs.cur, 0, partidxs.cur, partidxs.cur, 0, 0, 0, 0, 0)
  elseif (cid > 0 and cid <= 11) then
    textureidxs.max = GetNumberOfPedTextureVariations(ped, cid, partidxs.cur)
    textureidxs.cur = 0
    SendNUIMessage({setTextureMax = true, cid = cid, texmax = textureidxs.max})
  elseif (cid >= 15 and not (cid == 50 or cid == 51)) then
    overlayidxs.cur = partidx
    overlayidxs.max = GetNumHeadOverlayValues(cid - 15)

    setPedOverlays(cid - 15, overlayidxs.cur, curoverlaycol)
    SetPedHeadOverlay(ped, cid - 15, overlayidxs.cur, 1.0)
  else
    if (cid == 50) then -- watch
      cid = 18
    elseif (cid == 51) then -- bracelet
      cid = 19
    end

    propidxs.cur = partidx
    propidxs.max = GetNumberOfPedPropDrawableVariations(ped, partidx)
    proptextureidxs.max = GetNumberOfPedPropTextureVariations(ped, cid - 12, partidx)
    proptextureidxs.cur = 0

    setPedProps(cid - 12, propidxs.cur, proptextureidxs.cur)
    ClearPedProp(ped, cid - 12)
    --print(json.encode({cid = cid, propidxs = propidxs, proptextureidxs = proptextureidxs}))
    SetPedPropIndex(ped, cid - 12, propidxs.cur, proptextureidxs.cur, true)

    if (cid == 18) then
      cid = 50
    elseif (cid == 19) then
      cid = 51
    end

    SendNUIMessage({setTextureMax = true, cid = cid, texmax = proptextureidxs.max})
  end

  lastselection.cid = cid
  didchanges = true
  --print(string.format("components: %s", exports.devtools:dump(components)))
  --print(string.format("props: %s", exports.devtools:dump(props)))
end

function setTextureDirect(cid, textureidx)
  print(string.format("setTextureDirect called: %s, %s", cid, textureidx))
  local ped = PlayerPedId()

  if (cid > 0 and cid <= 11) then -- part
    textureidxs.cur = textureidx
    setPedComponents(cid, partidxs.cur, textureidxs.cur, paletteidxs.cur or 2)
    SetPedComponentVariation(ped, cid, partidxs.cur, textureidxs.cur, GetPedPaletteVariation(ped, cid))
  elseif (cid >= 15 and not (cid == 50 or cid == 51)) then -- overlays (might be unnecessary)
    setPedOverlays(cid - 15, overlayidxs.cur, textureidx)
    SetPedHeadOverlayColor(ped, cid - 15, 1, textureidx, textureidx)
  else
    if (cid == 50) then -- watch
      cid = 18
    elseif (cid == 51) then -- bracelet
      cid = 19
    end

    proptextureidxs.cur = textureidx
    setPedProps(cid - 12, propidxs.cur, proptextureidxs.cur)
    ClearPedProp(ped, cid - 12)
    SetPedPropIndex(ped, cid - 12, propidxs.cur, proptextureidxs.cur, true)
  end
    
  didchanges = true
end

function setNextPalette()
  paletteidxs.cur = paletteidxs.cur + 1
  
  if (paletteidxs.cur > paletteidxs.max) then
    paletteidxs.cur = 0
  end
  
  local ped = PlayerPedId()
  
  setPedComponents(catid, partidxs.cur, textureidxs.cur, paletteidxs.cur or 2)
  SetPedComponentVariation(ped, catid, partidxs.cur, textureidxs.cur, GetPedPaletteVariation(ped, catid))
end

function setPrevPalette()
  paletteidxs.cur = paletteidxs.cur - 1
  
  if (paletteidxs.cur < 0) then
    paletteidxs.cur = paletteidxs.max
  end
  
  local ped = PlayerPedId()
  
  setPedComponents(catid, partidxs.cur, textureidxs.cur, paletteidxs.cur or 2)
  SetPedComponentVariation(ped, catid, partidxs.cur, textureidxs.cur, GetPedPaletteVariation(ped, catid))
end

function loadSkinAndDefaultComponents(skin)
  if (skin) then
    local model = GetHashKey(skin)
    
    if IsModelInCdimage(model) and IsModelValid(model) then
      RequestModel(model)
      
      while not HasModelLoaded(model) do
        Citizen.Wait(100)
      end
      
      SetPlayerModel(PlayerId(), model)
      local ped = PlayerPedId()
      
      SetPedComponentVariation(ped, 0, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 1, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 2, 11, 4, 2)
      setPedComponents(2, 11, 4, 2)
      SetPedComponentVariation(ped, 3, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 4, 1, 5, 2)
      setPedComponents(4, 1, 5, 2)
      SetPedComponentVariation(ped, 5, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 6, 1, 0, 2)
      setPedComponents(6, 1, 0, 2)
      SetPedComponentVariation(ped, 7, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 8, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 9, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 10, 0, 0, 2)
      setPedComponents(0, 0, 0, 2)
      SetPedComponentVariation(ped, 11, 7, 2, 2)
      setPedComponents(11, 7, 2, 2)
      
      ClearPedProp(ped, 0)
      setPedProps(0, -1, -1)
      ClearPedProp(ped, 1)
      setPedProps(1, -1, -1)
      ClearPedProp(ped, 2)
      setPedProps(2, -1, -1)
      ClearPedProp(ped, 6)
      setPedProps(6, -1, -1)

      SetPedHeadOverlay(ped, 1, 0, 0.0)
      setPedOverlays(1, 255, 0)
      SetPedHeadOverlay(ped, 2, 0, 0.0)
      setPedOverlays(2, 255, 0)
      
      SetModelAsNoLongerNeeded(model)
    end    
  end
  
  if (lastTattoos) then
    exports.tattooshop:loadPlayerTattoos(lastTattoos)
  end

  TriggerServerEvent("bms:weapons:loadPlayerWeapons")
end

--[[function calculateCosts(cid, pid)
  -- pid set on setNextPart()
  if (partcosts[tostring(catid)]) then
    --print("setting")

    --if (lastselection.cid ~= catid) then
      --lastselcosts = partcosts[tostring(catid)].global
    --end

    if (not lastselection.added) then
      lastselection.added = true
      lasttotalcosts = lasttotalcosts + partcosts[tostring(catid)].global
    end

    --SendNUIMessage({setprice = true, selected = true, price = lastselcosts})
    SendNUIMessage({setprice = true, total = true, price = lasttotalcosts})
  --else
    --print("not found for " .. catid)
  end
end]]

function blockDb()
  blockDbCall = true
  SetTimeout(1500, function()
    blockDbCall = false
  end)
end

function sendPartMaxesToSliders()
  local ped = PlayerPedId()
  local maxes = {}

  for cid = 0, 26 do
    local max = GetNumberOfPedDrawableVariations(ped, cid)

    if (max > 0) then
      table_insert(maxes, {cid = cid, max = max})
    end
  end

  SendNUIMessage({setSliderPartMaxes = true, maxes = maxes})
end

function getPartMaxes()
  local ped = PlayerPedId()
  local maxes = {}

  for cid = 0, 26 do
    local max = GetNumberOfPedDrawableVariations(ped, cid)

    if (max > 0) then
      table_insert(maxes, {cid = cid, max = max})
    end
  end

  return maxes
end

function getDescriptor()
  local dstr = "No description found for this item."
  local id = 0

  for _,v in pairs(descriptors) do
    local data = json.decode(v.data)

    if (data.cat == catid and data.draw == partidxs.cur and data.tex == textureidxs.cur) then
      dstr = data.desc
      id = data.id
      break
    end
  end

  lastDescId = id
  SendNUIMessage({setDescriptor = true, description = dstr})
end

function openCloset()
  TriggerServerEvent("bms:cc:fetchSaves")
  SendNUIMessage({
    showCloset = true
  })
  SetNuiFocus(true, true)
end

function getLastComps(cb)
  if (cb) then
    cb(components)
  end
end

function getPedCurrentConfig()
  local ped = PlayerPedId()
  local table_insert = table_insert
  local ret = {parts = {}, props = {}, overlays = {}}
  
  for i = 0, 11 do
    local dv = GetPedDrawableVariation(ped, i)
    local tv = GetPedTextureVariation(ped, i)
    local tmax = GetNumberOfPedTextureVariations(ped, i, tv)
    local pv = GetPedPaletteVariation(ped, i)

    table_insert(ret.parts, {cid = i, drawable = dv, texture = tv, texmax = tmax, palette = pv})
  end

  for i = 0, 12 do
    local ov = GetPedHeadOverlayValue(ped, i)
    local omax = GetNumHeadOverlayValues(i)
    local tmax = 63
    local success, _, _, fcolor, scolor, opac = GetPedHeadOverlayData(ped, i)

    table_insert(ret.overlays, {cid = i, overlay = ov, ovmax = omax, fcolor = fcolor, scolor = scolor, opac = opac, texmax = tmax})
  end

  local propindexes = {0, 1, 2, 6, 7}

  for i = 1, #propindexes do
    local index = propindexes[i]
    local pv = GetPedPropIndex(ped, index)
    local pmax = GetNumberOfPedPropDrawableVariations(ped, index)
    local tmax = GetNumberOfPedPropTextureVariations(ped, index, pv)
    local pti = GetPedPropTextureIndex(ped, index)

    table_insert(ret.props, {cid = index, prop = pv, propmax = pmax, pti = pti, texmax = tmax})
  end

  return ret
end

function getCostForPart(cat, comp)
  local part = partcosts[cat]

  if (part) then
    return part[comp] or part.global or 0
  else
    return 0
  end
end

function isPartPurchaseable(cat, pidx)
  return (partcosts[cat] and partcosts.global) or (partcosts[cat] and partcosts[cat][pidx])
end

function isCompOwned(cat, pidx)
  cat = tostring(cat)
  pidx = tostring(pidx)
  
  --print(string.format("isCompOwned: %s [%s], %s [%s] >> returning %s", cat, type(cat), pidx, type(pidx), ownedcomps[cat] and ownedcomps[cat][pidx] == 1))
  --print(string.format("ownedcomps >> %s", json.encode(ownedcomps)))
  
  return ownedcomps[cat] and ownedcomps[cat][pidx] == 1
end

function purchaseComp(sel)
  exports.management:TriggerServerCallback("bms:charcreator:purchaseComp", function(rdata)
    if (rdata.success) then
      exports.pnotify:SendNotification({text = string.format("You have purchased a clothing item for <span style='color: lawngreen'>$%s</span>.", rdata.price)})
      
      if (rdata.ownedcomps) then
        --print(string.format("RDATA returned: %s", exports.devtools:dump(rdata)))
        ownedcomps = rdata.ownedcomps
      end
    else
      if (rdata.msg) then
        exports.pnotify:SendNotification({text = rdata.msg})
      end
    end

    SendNUIMessage({unblockCompPurchase = true})
  end, {selection = sel})
end

function setIsDoc(val)
  isdoc = val
end

function registerCloset(ent, pos)
  exClosetCoords[ent] = {pos = pos}
end

function clearRegisteredClosets()
  exClosetCoords = {}
end

RegisterNetEvent("bms:cc:setMpCharacterSkin")
AddEventHandler("bms:cc:setMpCharacterSkin", function(data)
  --TriggerServerEvent("bms:serverprint", "skin stuff : " .. type(mpskin))
  local comps, props, overlays

  if (data.comps.curr) then
    saveSlot = data.comps.curr
    comps = data.comps.saves[saveSlot]
    props = data.props.saves[saveSlot]
    overlays = data.overlays.saves[saveSlot]
  else
    comps = data.comps
    props = data.props
    overlays = data.overlays
  end
  local tattoos = data.tattoos
  local mpskin = data.mpskin
  local armor = data.armor
  local postNuiDisable = data.postNuiDisable
  local postNuiDisableEvent = data.postNuiDisableEvent
  
  if (mpskin and mpskin == "mp_f_freemode_01") then
    lastGenderId = 1
  else
    lastGenderId = 0
  end
  
  if (comps) then
    local model = GetHashKey(mpskin)
  
    if IsModelInCdimage(model) and IsModelValid(model) then
      RequestModel(model)
    
      while not HasModelLoaded(model) do
        Wait(1)
      end
    
      SetPlayerModel(PlayerId(), model)
      SetModelAsNoLongerNeeded(model)
    end
    
    loadMpSkinFromComponents(comps, props, overlays, tattoos, armor, postNuiDisable, postNuiDisableEvent)
    lastTattoos = tattoos
    exports.csrp_gamemode:setHealthStage(true, 0)

    TriggerEvent("bms:cc:componentsChanged", comps, props, overlays, tattoos, mpskin)
  else
    --TriggerEvent("bms:cc:showCreator") -- disable auto loading
  end
end)

RegisterNetEvent("bms:cc:showCreator")
AddEventHandler("bms:cc:showCreator", function(data)
  local gender = data.gender
  local plmoney = data.plmoney
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local pcc = getPedCurrentConfig()
  local maxes = getPartMaxes()
  
  partcosts = data.pcosts
  ownedcomps = data.ownedcomps or {}
  lastPos.x = pos.x
  lastPos.y = pos.y
  lastPos.z = pos.z
  
  playerDispMode = 2
  TriggerServerEvent("bms:csrp_gamemode:setTickDispMode", 4)
  teleportToCreator(true, nil, nil, nil, gender, plmoney)
  SendNUIMessage({showCostDisplay = true, cost = 0})
  SendNUIMessage({showCreator = true, gender = gender, pedconfig = pcc, maxes = maxes, plmoney = plmoney})
  SetNuiFocus(true, true)
  showCreator = true
end)

RegisterNetEvent("bms:cc:showCreatorLoadCurrent")
AddEventHandler("bms:cc:showCreatorLoadCurrent", function(data)
  if (data and data.comps) then
    local comps = data.comps
    local props = data.props
    local overlays = data.overlays
    local mpskin = data.mpskin
    local plmoney = data.plmoney
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local pcc = getPedCurrentConfig()
    local maxes = getPartMaxes()

    partcosts = data.pcosts
    ownedcomps = data.ownedcomps or {}
    lastPos.x = pos.x
    lastPos.y = pos.y
    lastPos.z = pos.z
  
    playerDispMode = 2
    TriggerServerEvent("bms:csrp_gamemode:setTickDispMode", 4)
    
    if (mpskin and mpskin == "mp_f_freemode_01") then
      lastGenderId = 1
    else
      lastGenderId = 0
    end
    
    local changed = false
    if (not comps.saves) then
      changed = true
      comps = {
        saves = {comps, defaultComps, defaultComps},
        curr = 1
      }
    end
    if (not props.saves) then
      changed = true
      props = {
        saves = {props, defaultProps, defaultProps}
      }
    end
    if (not overlays.saves) then
      changed = true
      overlays = {
        saves = {overlays, defaultOverlays, defaultOverlays}
      }
    end
    if (not comps.saves[4]) then
      changed = true
      comps.saves[4] = defaultComps
      comps.saves[5] = defaultComps
    end
    if (not props.saves[4]) then
      changed = true
      props.saves[4] = defaultProps
      props.saves[5] = defaultProps
    end
    if (not overlays.saves[4]) then
      changed = true
      overlays.saves[4] = defaultOverlays
      overlays.saves[5] = defaultOverlays
    end
    if (comps.curr) then
      currSave = comps.curr
    end
    if (changed) then
      TriggerServerEvent("bms:cc:saveMpSkinComponents", comps, props, overlays, lastGenderId, 0)
    end

    teleportToCreator(false, comps, props, overlays, mpskin, plmoney)
    SendNUIMessage({showCostDisplay = true, cost = 0})
    SendNUIMessage({showCreator = true, gender = lastGenderId, pedconfig = pcc, maxes = maxes, plmoney = plmoney})
    SetNuiFocus(true, true)
    showCreator = true
  end
end)

RegisterNetEvent("bms:charcreator:setIsCop")
AddEventHandler("bms:charcreator:setIsCop", function(val)
  if (val == 1) then
    iscop = true
  else
    iscop = false
    removeCopBlips()
  end
end)

RegisterNetEvent("bms:charcreator:setIsEms")
AddEventHandler("bms:charcreator:setIsEms", function(val)
  if (val == 1) then
    isems = true
  else
    isems = false
    removeEmsBlips()
  end
end)

RegisterNetEvent("bms:charcreator:mask")
AddEventHandler("bms:charcreator:mask", function(leorem)
  if (components) then
    local ped = PlayerPedId()
    local mcomp = components[2]
    local maskanims = {puton = {dict = "mp_masks@on_foot", anim = "put_on_mask"}, takeoff = {dict = "missfbi4", anim = "takeoff_mask"}}
    local handcuffed = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)

    if (handcuffed and not leorem) then
      exports.pnotify:SendNotification({text = "You can not do that while handcuffed.  Ask someone to do it for you."})
    else
      maskon = not maskon
      
      Citizen.CreateThread(function()
        if (not maskon) then
          if (not leorem) then
            while (not HasAnimDictLoaded(maskanims.takeoff.dict)) do
              RequestAnimDict(maskanims.takeoff.dict)
              Wait(10)
            end

            TaskPlayAnim(ped, maskanims.takeoff.dict, maskanims.takeoff.anim, 8.0, -8.0, -1, 48, 0, 0, 0, 0)
            Wait(500)
            StopAnimTask(ped, maskanims.takeoff.dict, maskanims.takeoff.anim, 2.0)
          else
            exports.pnotify:SendNotification({text = "An officer has removed your mask."})
          end

          SetPedComponentVariation(ped, 1, 0, 0, 2)
          RemoveAnimDict(maskanims.takeoff.dict)
        else
          if (not leorem) then
            while (not HasAnimDictLoaded(maskanims.puton.dict)) do
              RequestAnimDict(maskanims.puton.dict)
              Wait(10)
            end

            TaskPlayAnim(ped, maskanims.puton.dict, maskanims.puton.anim, 8.0, -8, -1, 48, 0, 0, 0, 0)
            Wait(400)
            StopAnimTask(ped, maskanims.puton.dict, maskanims.puton.anim, 2.0)
          else
            exports.pnotify:SendNotification({text = "An officer has put your mask back on."})
          end

          SetPedComponentVariation(ped, 1, mcomp.draw, mcomp.tex, 2)
          RemoveAnimDict(maskanims.puton.dict)
        end
      end)
    end
  end
end)

RegisterNetEvent("bms:charcreator:vest")
AddEventHandler("bms:charcreator:vest", function(leorem)
  if (components and not blockvest) then
    local ped = PlayerPedId()
    local vcomp = components[10]
    local vestanims = {takeoff = {dict = "clothingshirt", anim = "try_shirt_positive_d"}}
    local handcuffed = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)
    
    if (vcomp.draw == 0) then
      exports.pnotify:SendNotification({text = "You do not have a vest on."})
      return
    end

    if (handcuffed and not leorem) then
      exports.pnotify:SendNotification({text = "You can not do that while handcuffed. Ask someone to do it for you."})
    else
      veston = not veston

      Citizen.CreateThread(function()
        blockvest = true

        if (not veston) then
          if (not leorem) then
            while (not HasAnimDictLoaded(vestanims.takeoff.dict)) do
              RequestAnimDict(vestanims.takeoff.dict)
              Wait(10)
            end

            TaskPlayAnim(ped, vestanims.takeoff.dict, vestanims.takeoff.anim, 8.0, -8, -1, 49, 0, 0, 0, 0)
            Wait(7500)
            StopAnimTask(ped, vestanims.takeoff.dict, vestanims.takeoff.anim, 1.0)
          else
            exports.pnotify:SendNotification({text = "A LEO/EMS has removed your vest."})
          end

          SetPedComponentVariation(ped, 9, 0, 0, 0)
          RemoveAnimDict(vestanims.takeoff.dict)
          blockvest = false
        else
          if (not leorem) then
            while (not HasAnimDictLoaded(vestanims.takeoff.dict)) do
              RequestAnimDict(vestanims.takeoff.dict)
              Wait(10)
            end            
            
            TaskPlayAnim(ped, vestanims.takeoff.dict, vestanims.takeoff.anim, 1.0, -1, -1, 49, 0, 0, 0, 0)
            Wait(7500)
            StopAnimTask(ped, vestanims.takeoff.dict, vestanims.takeoff.anim, 1.0)
          else
            exports.pnotify:SendNotification({text = "A LEO/EMS has put your vest back on."})
          end

          SetPedComponentVariation(ped, 9, vcomp.draw, vcomp.tex, 2)
          blockvest = false
          RemoveAnimDict(vestanims.takeoff.dict)
        end
      end)
    end
  end
end)

RegisterNetEvent("bms:charcreator:toggleglasses")
AddEventHandler("bms:charcreator:toggleglasses", function()
  local ped = PlayerPedId()
  local pridx = GetPedPropIndex(ped, 1)
  local glassesanims = {dict = "clothingspecs", anim = "try_glasses_negative_b"}

  if (pridx > 0) then
    while (not HasAnimDictLoaded(glassesanims.dict)) do
      RequestAnimDict(glassesanims.dict)
      Wait(10)
    end
    
    TaskPlayAnim(ped, glassesanims.dict, glassesanims.anim, 8.0, -8, -1, 49, 0, 0, 0, 0)
    Wait(500)
    StopAnimTask(ped, glassesanims.dict, glassesanims.anim, 1.0)
    ClearPedProp(ped, 1)
    RemoveAnimDict(glassesanims.dict)
  else
    while (not HasAnimDictLoaded(glassesanims.dict)) do
      RequestAnimDict(glassesanims.dict)
      Wait(10)
    end

    TaskPlayAnim(ped, glassesanims.dict, glassesanims.anim, 8.0, -8, -1, 49, 0, 0, 0, 0)
    Wait(500)
    StopAnimTask(ped, glassesanims.dict, glassesanims.anim, 1.0)
    SetPedPropIndex(ped, 1, props[2].draw, props[2].tex, true)
    RemoveAnimDict(glassesanims.dict)
  end

  didchanges = true
end)

RegisterNetEvent("bms:charcreator:togglehelmet")
AddEventHandler("bms:charcreator:togglehelmet", function()
  local ped = PlayerPedId()
  local pridx = GetPedPropIndex(ped, 0)
  local helmetanims = {dict = "mp_masks@standard_car@ds@", anim = "put_on_mask"}

  if (pridx > 0) then
    while (not HasAnimDictLoaded(helmetanims.dict)) do
      RequestAnimDict(helmetanims.dict)
      Wait(30)
    end

    TaskPlayAnim(ped, helmetanims.dict, helmetanims.anim, 1.2, -10, -1, 49, 0, 0, 0, 0)
    Wait(950)
    StopAnimTask(ped, helmetanims.dict, helmetanims.anim, -5.0)
    ClearPedProp(ped, 0)
    RemoveAnimDict(helmetanims.dict)
  else
    while (not HasAnimDictLoaded(helmetanims.dict)) do
      RequestAnimDict(helmetanims.dict)
      Wait(30)
    end
    
    TaskPlayAnim(ped, helmetanims.dict, helmetanims.anim, 1.2, -10, -1, 49, 0, 0, 0, 0)
    Wait(950)
    StopAnimTask(ped, helmetanims.dict, helmetanims.anim, -5.0) 
    SetPedPropIndex(ped, 0, props[1].draw, props[1].tex, true)
    RemoveAnimDict(helmetanims.dict)
  end

  didchanges = true
end)

RegisterNUICallback("escape", function(data, cb)
  exitCreator()
  
  settingParts = false
  showCreator = false
  SetNuiFocus(false, false)
end)

RegisterNUICallback("playsound", function(data, cb)
  if (data) then
    PlaySoundFrontend(-1, data.name, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
  
    if (cb) then
      cb("ok")
    end
  end
end)

RegisterNUICallback("debug", function(data, cb)
  TriggerServerEvent("bms:serverprint", data)
  cb("ok")
end)

RegisterNUICallback("setGender", function(data, cb)
  local gender = data.gender
  
  if (gender == 0) then -- male
    loadSkinAndDefaultComponents("mp_m_freemode_01")
  elseif (gender == 1) then -- female
    loadSkinAndDefaultComponents("mp_f_freemode_01")
  end

  didchanges = true
end)

--[[
  This will clean out the components added by errorneous code to do inserts without a check first
]]
function addHair(haircomp)
  if (haircomp) then -- delete all the entries with cid 100 and readd haircomp to the end
    for i = #components, 1, -1 do
      local v = components[i]
      
      if (v.cid == 100) then
        table.remove(components, i)
      end
    end

    table_insert(components, haircomp)
  end
end

RegisterNUICallback("saveCharacterSkin", function(data, cb)
  if (not blockDbCall) then
    blockDb()

    -- save all parts in the database
    local gid = tonumber(data.gender)
    lastGenderId = gid
    
    local haircomp = {cid = 100, hcol = curhaircol}
    
    addHair(haircomp)
    
    print("overlay count: " .. #mpoverlays)

    print(string.format("saveSlot: %s", saveSlot))
    print(string.format("components: %s", exports.devtools:dump(components)))
    print(string.format("props: %s", exports.devtools:dump(props)))
    print(string.format("overlays: %s", exports.devtools:dump(mpoverlays)))

    savedcomps.curr = saveSlot
    savedcomps.saves[saveSlot] = components
    savedprops.saves[saveSlot] = props
    savedoverlays.saves[saveSlot] = mpoverlays
    print(string.format("savedcomps: %s", exports.devtools:dump(savedcomps)))
    print(string.format("savedprops: %s", exports.devtools:dump(savedprops)))
    print(string.format("savedoverlays: %s", exports.devtools:dump(savedoverlays)))
    TriggerServerEvent("bms:cc:saveMpSkinComponents", savedcomps, savedprops, savedoverlays, gid)
    lastselection = {cid = 1, pid = 0, added = false}
    
    SendNUIMessage({
      savedSkin = true
    })
  else
    SendNUIMessage({
      blockDb = true
    })
  end
end)

RegisterNetEvent("bms:cc:fetchSaves")
AddEventHandler("bms:cc:fetchSaves", function(comps, props, overlays, mpskin)
  savedcomps = comps
  savedprops = props
  savedoverlays = overlays
end)

RegisterNetEvent("bms:cc:enableDescribe")
AddEventHandler("bms:cc:enableDescribe", function(desc)
  if (desc) then
    showdescript = true
    descriptors = desc
    SendNUIMessage({enableDescribe = true})
  end
end)

RegisterNetEvent("bms:cc:updateDescriptors")
AddEventHandler("bms:cc:updateDescriptors", function(desc)
  if (desc) then
    descriptors = desc
  end
end)

RegisterNetEvent("bms:cc:revertSave")
AddEventHandler("bms:cc:revertSave", function(data)
  local comps, props, overlays

  if (data.comps.curr) then
    comps = data.comps.saves[saveSlot]
    props = data.props.saves[saveSlot]
    overlays = data.overlays.saves[saveSlot]
  else
    comps = data.comps
    props = data.props
    overlays = data.overlays
  end
  local tattoos = data.tattoos
  local weapons = data.weapons
  local mpskin = data.mpskin
  local armor = lastArmor
  
  if (mpskin and mpskin == "mp_f_freemode_01") then
    lastGenderId = 1
  else
    lastGenderId = 0
  end

  if (comps) then
    local model = GetHashKey(mpskin)
  
    if IsModelInCdimage(model) and IsModelValid(model) then
      RequestModel(model)
    
      while not HasModelLoaded(model) do
        Wait(1)
      end
    
      SetPlayerModel(PlayerId(), model)
      SetModelAsNoLongerNeeded(model)
    end
    
    loadMpSkinFromComponents(comps, props, overlays, tattoos, armor, false)
    lastTattoos = tattoos
    exports.csrp_gamemode:setHealthStage(true, 0)
  end
end)

RegisterNetEvent("bms:cc:enableDescribe")
AddEventHandler("bms:cc:enableDescribe", function(desc)
  if (desc) then
    showdescript = true
    descriptors = desc
    SendNUIMessage({enableDescribe = true})
  end
end)

RegisterNetEvent("bms:cc:updateDescriptors")
AddEventHandler("bms:cc:updateDescriptors", function(desc)
  if (desc) then
    descriptors = desc
  end
end)

RegisterNUICallback("reverttosaved", function(data, cb)
  if (not blockDbCall) then
    blockDb()

    local ped = PlayerPedId()

    TriggerServerEvent("bms:cc:fetchSaves")
    if (savedcomps and savedcomps.saves[saveSlot]) then
      currSave = saveSlot
      currcomps = savedcomps.saves[currSave]
      for _,v in pairs(currcomps) do
        if (v.cid == 100) then
          curhaircol = v.hcol
    
          local headid = getHeadId()
          SetPedHeadBlendData(ped, headid, headid, 0, headid, headid, 0, 0, 0, 0, 0)
          SetPedHairColor(ped, curhaircol, curhaircol)
        else
          SetPedComponentVariation(ped, v.cid, v.draw, v.tex, 2)
          setPedComponents(v.cid, v.draw, v.tex, v.pal or 2)
        end
      end
    end
    
    if (savedprops and savedprops.saves[saveSlot]) then
      currprops = savedprops.saves[currSave]
      for _,v in pairs(currprops) do
        ClearPedProp(ped, v.cid)
        SetPedPropIndex(ped, v.cid, v.draw, v.tex, true)
        setPedProps(v.cid, v.draw, v.tex)
      end
    end

    if (savedoverlays and savedoverlays.saves[saveSlot]) then
      curroverlays = savedoverlays.saves[currSave]
      for _,v in pairs(curroverlays) do
        local headid = getHeadId()
        SetPedHeadBlendData(ped, headid, headid, 0, headid, headid, 0, 0, 0, 0, 0)
        SetPedHeadOverlay(ped, v.cid, v.draw, 1.0)
        SetPedHeadOverlayColor(ped, v.cid, 1, v.tex, v.tex)
        setPedOverlays(v.cid, v.draw, v.tex)
      end
    end

    savedcomps.curr = currSave
    cb("ok")
    didchanges = true
  else
    SendNUIMessage({
      blockDb = true
    })
  end
end)

RegisterNUICallback("navigateToPart", function(data, cb)
  if (data) then
    local cid = data.cid
    local partidx = data.partidx
    local cost = getCostForPart(cid, partidx)

    if (isCompOwned(cid, partidx)) then
      SendNUIMessage({showCostDisplay = true, owned = true})
    else
      SendNUIMessage({showCostDisplay = true, cost = cost})
    end
    
    if (cid ~= lastselection.cid and isPartPurchaseable(lastselection.cid, lastselection.pid)) then
      if (not isCompOwned(lastselection.cid, lastselection.pid)) then
        -- remove part if not owned
        setPartDirect(lastselection.cid, 0)
      end
    end

    setPartDirect(cid, partidx)
  end
end)

RegisterNUICallback("navigateToTexture", function(data, cb)
  if (data) then
    local cid = data.cid
    local textureidx = data.textureidx

    setTextureDirect(cid, textureidx)
  end
end)

RegisterNUICallback("setHairColor", function(data, cb)
  if (data) then
    local colorid = data.colorid

    setHairColorDirect(colorid)
  end
end)

RegisterNUICallback("setNullValueComponent", function(data, cb)  
  if (data) then
    local ped = PlayerPedId()
    local cid = data.cid

    setPartDirect(cid, -1)
    
    if (cb) then
      cb()
    end
  end
end)

RegisterNUICallback("resetpartforcat", function(data, cb)
  local ped = PlayerPedId()

  if (settingParts) then
    SetPedComponentVariation(ped, catid, 0, 0, 2)
    partidxs.cur = GetPedDrawableVariation(ped, catid)
    setPedComponents(catid, 0, 0, 2)
  elseif (settingProps) then
    ClearPedProp(ped, catid - 12)
    propidxs.cur = GetPedPropIndex(ped, catid - 12)
    setPedProps(catid - 12, -1, -1)
  elseif (settingoverlays) then
    if (catid >= 15) then
      SetPedHeadOverlay(ped, catid - 15, 255, 1.0)
      overlayidxs.cur = GetPedHeadOverlayValue(ped, catid - 15)
      setPedOverlays(catid - 15, 255, 0)
    end
  end

  didchanges = true
end)

RegisterNUICallback("resettodefault", function(data, cb)
  local ped = PlayerPedId()
  partidxs.cur = 0
  propidxs.cur = 0
  overlayidxs.cur = 0

  SetPedComponentVariation(ped, 0, 0, 0, 2)
  setPedComponents(0, 0, 0, 2)
  SetPedComponentVariation(ped, 1, 0, 0, 2)
  setPedComponents(0, 0, 0, 2)
  SetPedComponentVariation(ped, 2, 11, 4, 2)
  setPedComponents(2, 11, 4, 2)
  SetPedComponentVariation(ped, 3, 0, 0, 2)
  setPedComponents(0, 0, 0, 2)
  SetPedComponentVariation(ped, 4, 1, 5, 2)
  setPedComponents(4, 1, 5, 2)
  SetPedComponentVariation(ped, 5, 0, 0, 2)
  setPedComponents(0, 0, 0, 2)
  SetPedComponentVariation(ped, 6, 1, 0, 2)
  setPedComponents(6, 1, 0, 2)
  SetPedComponentVariation(ped, 7, 0, 0, 2)
  setPedComponents(0, 0, 0, 2)
  SetPedComponentVariation(ped, 8, 0, 0, 2)
  setPedComponents(0, 0, 0, 2)
  SetPedComponentVariation(ped, 9, 0, 0, 2)
  setPedComponents(0, 0, 0, 2)
  SetPedComponentVariation(ped, 10, 0, 0, 2)
  setPedComponents(0, 0, 0, 2)
  SetPedComponentVariation(ped, 11, 7, 2, 2)
  setPedComponents(11, 7, 2, 2)
  
  ClearPedProp(ped, 0)
  setPedProps(0, -1, -1)
  ClearPedProp(ped, 1)
  setPedProps(1, -1, -1)
  ClearPedProp(ped, 2)
  setPedProps(2, -1, -1)

  for _,v in pairs(mpoverlays) do
    SetPedHeadOverlay(ped, v.cid, 0, 1.0)
    setPedOverlays(v.cid, 255, 0)
  end
end)

RegisterNUICallback("switchcam", function(data, cb)
  curcamtype = curcamtype + 1

  if (curcamtype > #crCamCoords) then
    curcamtype = 1
  end

  switchCamera(curcamtype)
end)

RegisterNUICallback("turntoface", function(data)
  if (data) then
    local ped = PlayerPedId()
    local dir = data.dir
    local offset

    -- dir: 1 right, 2 left (relative to character)
    if (dir == 2) then
      offset = GetOffsetFromEntityInWorldCoords(ped, -1.0, 0.0, 0.0)
    elseif (dir == 1) then
      offset = GetOffsetFromEntityInWorldCoords(ped, 1.0, 0.0, 0.0)
    end

    TaskTurnPedToFaceCoord(ped, offset.x, offset.y, offset.z, 1100)
  end
end)

RegisterNUICallback("setSaveSlot", function(data)
  if (data) then
    saveSlot = data.slot
  end
end)

RegisterNUICallback("loadFromSave", function(data)
  if (data) then
    saveSlot = data.slot
    lastArmor = GetPedArmour(PlayerPedId())
    TriggerServerEvent("bms:cc:revertSave")
    SendNUIMessage({setInfoText = true, text = string.format("Slot #%s has been loaded.", data.slot), delay = 8000})
  end
end)

RegisterNUICallback("setDescribe", function(data)
  if (data.description) then
    TriggerServerEvent("bms:cc:setPartDescribe", {cat = catid, draw = partidxs.cur, tex = textureidxs.cur, prop = settingProps, did = lastDescId, desc = data.description})
  end
end)

RegisterNUICallback("closeCloset", function(data)
  if (data) then
    saveSlot = data.slot
    lastArmor = GetPedArmour(PlayerPedId())
    TriggerServerEvent("bms:cc:revertSave")
  end
  
  blockInput = false
  SetNuiFocus(false, false)
end)

RegisterNUICallback("bms:charcreator:rulesexit", function()
  SetNuiFocus(false, false)
  showingrules = false
end)

RegisterNetEvent("bms:charcreator:showRules")
AddEventHandler("bms:charcreator:showRules", function()
  showingrules = true
  SendNUIMessage({showRules = true})
  SetNuiFocus(true, true)
end)

RegisterNUICallback("bms:charcreator:purchaseComp", function()
  purchaseComp(lastselection)
end)

initialize()

Citizen.CreateThread(function()
  while true do
    Wait(1)
    
    local pos = GetEntityCoords(PlayerPedId())
    
    for _,v in pairs(shopMarkers) do
      DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.15, 0, 180, 255, 50, 0, 0, 2, 0, 0, 0, 0)

      if (v.dist < 10) then
        local dist = #(pos - v.pos)
        
        if (dist < 1.0) then
          drawCcText("~w~Press ~b~E~w~ to enter the clothing shop.")
          
          if (IsControlJustReleased(1, 38)) then -- E
            if (not blockInput) then
              blockInput = true
              inStore = true
              TriggerServerEvent("bms:cc:activateMpSkinShop")
            end
          end
        end
      end
    end

    for _,v in pairs(closetMarkers) do
      --DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0, 0, 0, 0, 0, 0, 0, 0.75, 0.75, 0.15, 186, 255, 252, 50, 0, 0, 2, 0, 0, 0, 0)

      if (v.dist < 10) then
        local dist = #(pos - v.pos)      
        local closetRange = 0.74
        
        if (v.exCloset) then closetRange = 1.6 end

        if (dist < closetRange) then
          drawCcText("~w~Press ~b~E~w~ to open the closet.")
          
          if (IsControlJustReleased(1, 38)) then -- E
            if (not blockInput) then
              blockInput = true
              inStore = true
              openCloset()
            end
          end
        end
      end
    end
 
    if (iscop) then
      for _,v in pairs(copMarkers) do
        DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.15, 255, 131, 209, 50, 0, 0, 2, 0, 0, 0, 0)
        
        if (v.dist < 10) then
          local dist = #(pos - v.pos)

          if (dist < 1.0) then
            drawCcText("~w~Press ~b~E~w~ to enter the officer locker room.")
            
            if (IsControlJustReleased(1, 38)) then -- E
              inStore = true
              TriggerServerEvent("bms:cc:activateMpSkinShop")
            end
          end
        end
      end
    end

    if (isdoc) then
      for _,v in pairs(docMarkers) do
        DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.15, 255, 131, 50, 155, 0, 0, 2, 0, 0, 0, 0)
        
        if (v.dist < 10) then
          local dist = #(pos - v.pos)

          if (dist < 1.0) then
            drawCcText("~w~Press ~b~E~w~ to enter the DOC locker room.")
            
            if (IsControlJustReleased(1, 38)) then -- E
              inStore = true
              TriggerServerEvent("bms:cc:activateMpSkinShop")
            end
          end
        end
      end
    end

    if (isems) then     
      for _,v in pairs(emsMarkers) do
        DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 0.15, 255, 131, 209, 50, 0, 0, 2, 0, 0, 0, 0)  

        if (v.dist < 10) then
          local dist = #(pos - v.pos)         

          if (dist < 1.0) then
            drawCcText("~w~Press ~b~E~w~ to enter the LAFD locker room.")
            lastEmsSpot = i
            
            if (IsControlJustReleased(1, 38)) then -- E
              inStore = true
              TriggerServerEvent("bms:cc:activateMpSkinShop")
            end
          end
        end
      end
    end
    
    if (showCreator or showingrules) then
      local ped = PlayerPedId()
      
      DisableControlAction(0, 1, true) -- LookLeftRight
      DisableControlAction(0, 2, true) -- LookUpDown
      DisableControlAction(0, 24, true) -- Attack
      DisablePlayerFiring(ped, true) -- Disable weapon firing
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
      HideHudAndRadarThisFrame()
      DisableFirstPersonCamThisFrame()
      DisableVehicleFirstPersonCamThisFrame()
    end
  end
end)

Citizen.CreateThread(function()
  Wait(2000)

  if (#blips == 0) then
    setupCcBlips()
  end

  while true do
    Wait(1500)

    local pos = GetEntityCoords(PlayerPedId())
    local sMarkers = {}
    local iter = 0

    for i=1,#shopCoords do
      local dist = #(pos - shopCoords[i].pos)

      if (dist < 65) then
        iter = iter + 1
        sMarkers[iter] = shopCoords[i]
        sMarkers[iter].dist = dist
      end
    end

    shopMarkers = sMarkers

    local cMarkers = {}
    iter = 0

    for i=1,#closetCoords do
      local dist = #(pos - closetCoords[i].pos)

      if (dist < 65) then
        iter = iter + 1
        cMarkers[iter] = closetCoords[i]
        cMarkers[iter].dist = dist
      end
    end

    for _, v in pairs(exClosetCoords) do
      local dist = #(pos - v.pos)

      if (dist < 65) then
        iter = iter + 1
        cMarkers[iter] = v
        cMarkers[iter].dist = dist
        cMarkers[iter].exCloset = true
      end
    end

    closetMarkers = cMarkers

    if (iscop) then
      if (#copShopBlips == 0) then
        setupCopBlips()
      end

      local pMarkers = {}
      iter = 0

      for i=1,#copShopCoords do
        local dist = #(pos - copShopCoords[i].pos)

        if (dist < 65) then
          iter = iter + 1
          pMarkers[iter] = copShopCoords[i]
          pMarkers[iter].dist = dist
        end
      end

      copMarkers = pMarkers
    end

    if (isdoc) then
      if (#docShopBlips == 0) then
        setupDocBlips()
      end

      local pMarkers = {}
      iter = 0

      for i=1,#docShopCoords do
        local dist = #(pos - docShopCoords[i].pos)

        if (dist < 65) then
          iter = iter + 1
          pMarkers[iter] = docShopCoords[i]
          pMarkers[iter].dist = dist
        end
      end

      docMarkers = pMarkers
    end

    if (isems) then
      if (#emsShopBlips == 0) then
        setupEmsBlips()
      end
      
      local eMarkers = {}
      iter = 0

      for i=1,#emsShopCoords do
        local dist = #(pos - emsShopCoords[i].pos)
        
        if (dist < 65) then
          iter = iter + 1
          eMarkers[iter] = emsShopCoords[i]
          eMarkers[iter].dist = dist
        end
      end

      emsMarkers = eMarkers
    end
    
    local players = GetActivePlayers()

    -- 1 = show all players including self, 2 = hide all players except self, 3 = hide all players except self and selective
    if (playerDispMode == 1 and exited) then
      for i=1,#players do
        local pIdx = GetPlayerFromServerId(GetPlayerServerId(players[i]))

        if (NetworkIsPlayerConcealed(pIdx)) then
          NetworkConcealPlayer(pIdx, false, false)
        end

        SetEntityVisible(GetPlayerPed(players[i]), true)
      end

      exited = false
    elseif (playerDispMode == 2) then
      local playId = PlayerId()

      if (NetworkIsPlayerConcealed(playId)) then
        NetworkConcealPlayer(pIdx, false, false)
      end

      for i=1,#players do
        local pIdx = GetPlayerFromServerId(GetPlayerServerId(players[i]))

        if (pIdx ~= playId and not NetworkIsPlayerConcealed(pIdx)) then
          NetworkConcealPlayer(pIdx, true, true)
        end
      end
    --[[elseif (playerDispMode == 3) then
      local playId = PlayerId()

      if (NetworkIsPlayerConcealed(playId)) then
        NetworkConcealPlayer(pIdx, false, false)
      end

      for i=1,#players do
        local sid = GetPlayerServerId(players[i])
        local pIdx = GetPlayerFromServerId(sid)

        if (selectiveExists(sid)) then
          if(NetworkIsPlayerConcealed(pIdx)) then
            NetworkConcealPlayer(pIdx, false, false)
          end
        elseif (not NetworkIsPlayerConcealed(pIdx)) then
          NetworkConcealPlayer(pIdx, true, true)
        end
      end]]
    end
  end
end)