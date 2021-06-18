local json_encode = json.encode
local DrawMarker = DrawMarker
local tableSpots
local inGame = false
local inCasino = false
local blockInput = false
local lastTableIndex
local gameSettings = {}
local idleNetScene
local radioEmitters = {
  "se_vw_dlc_casino_main_rm_lounge_02_radio",
  "se_vw_dlc_casino_main_rm_lounge_01_radio",
  "se_vw_dlc_casino_main_rm_shop_radio",
  "se_vw_dlc_casino_main_rm_gamingfloor_02_slots_radio",
  "se_vw_dlc_casino_main_rm_gamingfloor_01_slots_radio",
  "se_vw_dlc_casino_main_rm_gamingfloor_01_bar_radio",
  "se_vw_dlc_casino_main_rm_reception_radio",
  "se_vw_dlc_casino_main_rm_toilet_02_radio",
  "se_vw_dlc_casino_main_rm_toilet_01_radio",
  "se_vw_dlc_casino_main_rm_bettingroom_radio",
  "se_vw_dlc_casino_main_rm_gamingfloor_03_slots_radio",
  "se_vw_dlc_casino_main_rm_bettingroom_main_floor_radio",
  "se_vw_dlc_casino_exterior_main_entrance",
  "se_vw_dlc_casino_exterior_terrace_01",
  "se_vw_dlc_casino_exterior_terrace_02",
  "se_vw_dlc_casino_exterior_terrace_03",
  "se_vw_dlc_casino_exterior_terrace_bar"
}
local casinoRadioStationHash = "RADIO_03_HIPHOP_NEW" -- Radio Los Santos

function getBlackjackGameSettings()
  return gameSettings
end

function playSoundClient(sound, volume)
  TriggerEvent("bms:soundmgr:playSoundOnClient", sound, volume or 0.3)
end

local function draw3DGamingText(x, y, z, text, tscale)
  local onScreen, _x ,_y = GetScreenCoordFromWorldCoord(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, tscale or 0.55 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    SetTextCentre(1)
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(_x, _y)
  end
end

RegisterNetEvent("bms:gaming:init")
AddEventHandler("bms:gaming:init", function(data)
  Citizen.CreateThread(function()
    while (not GlobalState.gaming.gameSettings) do -- Race condition in gameSettings sync
      Wait(60)
    end
    
    if (not tableSpots) then
      tableSpots = GlobalState.gaming.gameSettings.tableSpots
    end

    gameSettings = data.gameSettings

    Wait(2500) -- More race conditions

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local int = GetInteriorAtCoords(pos.x, pos.y, pos.z)

    if (int == 275201) then
      TriggerServerEvent("bms:gaming:setInsideCasinoInterior")
    end
  end)
end)

RegisterNetEvent("bms:gaming:updateGame")
AddEventHandler("bms:gaming:updateGame", function(data)
  if (not data) then return end

  SendNUIMessage({updateGame = true, gameId = data.gameId, game = data.game, fullRedraw = data.fullRedraw})
end)

RegisterNetEvent("bms:gaming:updateReadyRoom")
AddEventHandler("bms:gaming:updateReadyRoom", function(data)
  if (not data) then return end

  SendNUIMessage({toggleReadyRoom = data.toggle, gameId = data.gameId, game = data.game, toggle = data.toggle, charData = data.charData})
end)

RegisterNetEvent("bms:gaming:getUpFromChair")
AddEventHandler("bms:gaming:getUpFromChair", function()
  local ped = PlayerPedId()
  local netScene = getChairNetScene()

  if (netScene == 0) then return end
  
  while (not HasAnimDictLoaded(gameSettings.sittingAnim.dict)) do
    RequestAnimDict(gameSettings.sittingAnim.dict)
    Wait(5)
  end

  NetworkStopSynchronisedScene(chairNetScene)
  NetworkStopSynchronisedScene(idleNetScene)
  DisposeSynchronizedScene(chairNetScene)
  DisposeSynchronizedScene(idleNetScene)
  RemoveAnimDict("anim_casino_b@amb@casino@games@shared@player@")
  TaskPlayAnim(ped, gameSettings.sittingAnim.dict, gameSettings.sittingAnim.exitAnim, 1.0, 1.0, 2500, 0)
  inGame = false
  blockInput = false
  toggleControlsForGaming(true)
end)

RegisterNetEvent("bms:gaming:closeAndResetGameInterface")
AddEventHandler("bms:gaming:closeAndResetGameInterface", function()
  SendNUIMessage({closeAndReset = true})
  SetNuiFocusKeepInput(false)
  SetNuiFocus(false, false)
  inGame = false
  blockInput = false
  toggleControlsForGaming(true)
end)

RegisterNetEvent("bms:gaming:showFinalScores")
AddEventHandler("bms:gaming:showFinalScores", function(data)
  SendNUIMessage({toggleFinalScore = true, toggle = true, game = data.game, timerTime = data.timerTime})
end)

RegisterNetEvent("bms:gaming:showClientGames")
AddEventHandler("bms:gaming:showClientGames", function()
  print(json_encode(GlobalState.gaming.activeGames, {indent = true}))
end)

RegisterNetEvent("bms:gaming:inCasino")
AddEventHandler("bms:gaming:inCasino", function(tog)
  inCasino = tog
  SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"))

  if (inCasino) then
    SetTimeout(3500, function()
      SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"))
    end)
  else
    inGame = false
    blockInput = false
    toggleControlsForGaming(true)
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
  end
end)

RegisterNetEvent("bms:gaming:toggleBlockFromCasino")
AddEventHandler("bms:gaming:toggleBlockFromCasino", function(remove)
  if (remove) then
    exports.teleporter:blockAccess("Diamond Casino", true, true)
  else
    exports.teleporter:blockAccess("Diamond Casino", false)
  end
end)

AddEventHandler("bms:nuiFocusDisable", function()
  SetNuiFocusKeepInput(false)
  SetNuiFocus(false, false)
  exports.emotes:setCanEmote(true)
end)

RegisterNUICallback("bms:gaming:readyUpToggle", function(data)
  TriggerServerEvent("bms:gaming:setReadyUpStatus", data)
end)

RegisterNUICallback("bms:gaming:doPlayerAction", function(data)
  playSoundClient("interface_2", 0.3)
  TriggerServerEvent("bms:gaming:doPlayerAction", data)
end)

RegisterNUICallback("bms:gaming:playerLeaveGame", function()
  exports.management:TriggerServerCallback("bms:gaming:leaveGame", function(rdata)
    Citizen.CreateThread(function()
      local ped = PlayerPedId()
        
      while (not HasAnimDictLoaded(gameSettings.sittingAnim.dict)) do
        RequestAnimDict(gameSettings.sittingAnim.dict)
        Wait(5)
      end

      local netScene = getChairNetScene()

      NetworkStopSynchronisedScene(chairNetScene)
      NetworkStopSynchronisedScene(idleNetScene)
      DisposeSynchronizedScene(chairNetScene)
      DisposeSynchronizedScene(idleNetScene)
      RemoveAnimDict("anim_casino_b@amb@casino@games@shared@player@")
      TaskPlayAnim(ped, gameSettings.sittingAnim.dict, gameSettings.sittingAnim.exitAnim, 1.0, 1.0, 2500, 0)
      inGame = false
      blockInput = false
      SetNuiFocusKeepInput(false)
      SetNuiFocus(false, false)
      toggleControlsForGaming(true)

      if (rdata and rdata.msg) then
        exports.pnotify:SendNotification({text = rdata.msg})
      end
    end)
  end, {lastTableIndex = lastTableIndex})
end)

RegisterNUICallback("bms:gaming:cancelMaxBet", function()
  inGame = false
  blockInput = false
  toggleControlsForGaming(true)
  SetNuiFocusKeepInput(false)
  SetNuiFocus(false, false)
end)

RegisterNUICallback("bms:gaming:acceptMaxBet", function(data)
  local seatIndex = getClosestSeatIndex(gameSettings.tableSpots[lastTableIndex].tableModel, gameSettings.tablesChairCount, gameSettings.tablesBoneNamePrefix)

  if (seatIndex == -1) then
    exports.pnotify:SendNotification({text = "Could not find a valid seat nearby.  Try again in a moment."})
    return
  end

  exports.management:TriggerServerCallback("bms:gaming:createGame", function(rdata)
    if (not rdata) then return end
    
    if (rdata.success) then
      inGame = true
      SetNuiFocus(true, true)
      SetNuiFocusKeepInput(true)
      toggleControlsForGaming(false)
      playSoundClient("interface_1", 0.3)
      local chairBoneIndex, tableEnt = getClosestBoneIndexFromModel(gameSettings.tableSpots[lastTableIndex].tableModel, gameSettings.tablesChairCount, gameSettings.tablesBoneNamePrefix)
      local bonePos = GetEntityBonePosition_2(tableEnt, chairBoneIndex)
      local boneRot = GetEntityBoneRotation(tableEnt, chairBoneIndex)

      if (chairBoneIndex > -1) then
        sitInGamingChair(1, chairBoneIndex, gameSettings.tableSpots[lastTableIndex].tableModel, function()
          Citizen.CreateThread(function()
            local ped = PlayerPedId()

            while (not HasAnimDictLoaded(gameSettings.idleAnim.dict)) do
              RequestAnimDict(gameSettings.idleAnim.dict)
              Wait(5)
            end

            idleNetScene = NetworkCreateSynchronisedScene(bonePos.x, bonePos.y, bonePos.z, boneRot.x, boneRot.y, boneRot.z, 2, true, true, 1065353216, 0, 1065353216)
            
            NetworkAddPedToSynchronisedScene(ped, idleNetScene, gameSettings.idleAnim.dict, gameSettings.idleAnim.anim, 2.0, -2.0, 13, 16, 1148846080, 0)
            NetworkStartSynchronisedScene(idleNetScene)
            Citizen.InvokeNative(0x79C0E43EB9B944E2, -2124244681)
          end)
        end)
      end
    else
      inGame = false
      blockInput = false
      toggleControlsForGaming(true)
      SetNuiFocusKeepInput(false)
      SetNuiFocus(false, false)
    end

    if (rdata.msg) then
      exports.pnotify:SendNotification({text = rdata.msg})
    end
  end, {tableIndex = lastTableIndex, maxBet = data.maxBet, seatIndex = seatIndex})
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    if (inCasino) then
      local ped = PlayerPedId()

      BlockWeaponWheelThisFrame()
      DisableControlAction(0, 24, true) -- Attack
      DisablePlayerFiring(ped, true) -- Disable weapon firing
      DisableControlAction(0, 142, true) -- MeleeAttackAlternate
      DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT R punch
      DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY Q kick
    end

    if (inGame) then
      SetPedCapsule(ped, 0.2)
      HideHudAndRadarThisFrame()
      DisableFirstPersonCamThisFrame()
      DisableVehicleFirstPersonCamThisFrame()
      DisableControlAction(0, 32, true)  -- Movement
      DisableControlAction(0, 33, true)  --
      DisableControlAction(0, 34, true)  --
      DisableControlAction(0, 35, true)  --
      DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
      DisableControlAction(0, 37, true)  -- SelectWeapon
      DisableControlAction(0, 25, true)  -- INPUT_AIM
      DisableControlAction(0, 311, true) -- Inventory
      DisableControlAction(0, 19, true) -- ActionMenu Primary
      DisableControlAction(0, 48, true) -- ActionMenu Secondary
      DisableControlAction(0, 21, true) -- Shift (Settings menu combo)
      DisableControlAction(0, 303, true) -- U (Settings menu combo)
      DisableControlAction(0, 200, true) -- ESCAPE Pause Menu
      --DisableControlAction(0, 245, true) -- chat is handled by keybind
    end

    if (tableSpots) then
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local masterDist = #(pos - tableSpots[1].radPos)

      if (masterDist < 80) then
        for tableIndex, tSpot in pairs(tableSpots) do
          local dist = #(pos - tSpot.radPos)

          if (dist < 2.25) then
            if (not inGame) then
              local gameExists = false
              local tableMaxBet = tSpot.tableMaxBet
              local gameMaxBet = 0

              for gameIndex, gameData in pairs(GlobalState.gaming.activeGames) do
                if (gameData.tableIndex == tableIndex) then
                  gameMaxBet = gameData.maxBet
                  gameExists = true
                  break
                end
              end
              
              if (gameExists) then
                draw3DGamingText(tSpot.radPos.x, tSpot.radPos.y, tSpot.radPos.z + 0.255, ("Press [~b~E~w~] to join this game ~g~($%s buy in)~w~."):format(gameMaxBet))
              else
                draw3DGamingText(tSpot.radPos.x, tSpot.radPos.y, tSpot.radPos.z + 0.255, "Press [~b~E~w~] to create this game.")
              end

              if (IsControlJustReleased(1, 38) and not blockInput) then
                lastTableIndex = tableIndex
                blockInput = true

                if (gameExists) then
                  local closestSeat = getClosestSeatIndex(gameSettings.tableSpots[lastTableIndex].tableModel, gameSettings.tablesChairCount, gameSettings.tablesBoneNamePrefix)

                  if (closestSeat == -1) then
                    exports.pnotify:SendNotification({text = "Could not find a seat to sit in.  Move a bit and try again."})
                    blockInput = false
                  else
                    exports.management:TriggerServerCallback("bms:gaming:joinGame", function(rdata)
                      if (rdata) then                    
                        if (rdata.success) then
                          inGame = true
                          SetNuiFocus(true, true)
                          SetNuiFocusKeepInput(true)
                          toggleControlsForGaming(false)
                          playSoundClient("interface_1", 0.3)

                          local seatIndex = rdata.seatIndex
                          local tableObj = GetClosestObjectOfType(pos.x, pos.y, pos.z, 10.0, GetHashKey(gameSettings.tableSpots[lastTableIndex].tableModel))
                          local boneIndex = GetEntityBoneIndexByName(tableObj, ("%s%s"):format(gameSettings.tablesBoneNamePrefix, seatIndex))
                          local bonePos = GetEntityBonePosition_2(tableObj, boneIndex)
                          local boneRot = GetEntityBoneRotation(tableObj, boneIndex)

                          sitInGamingChair(1, boneIndex, gameSettings.tableSpots[lastTableIndex].tableModel, function()
                            Citizen.CreateThread(function()
                              local ped = PlayerPedId()

                              while (not HasAnimDictLoaded(gameSettings.idleAnim.dict)) do
                                RequestAnimDict(gameSettings.idleAnim.dict)
                                Wait(5)
                              end

                              idleNetScene = NetworkCreateSynchronisedScene(bonePos.x, bonePos.y, bonePos.z, boneRot.x, boneRot.y, boneRot.z, 2, true, true, 1065353216, 0, 1065353216)
                              
                              NetworkAddPedToSynchronisedScene(ped, idleNetScene, gameSettings.idleAnim.dict, gameSettings.idleAnim.anim, 2.0, -2.0, 13, 16, 1148846080, 0)
                              NetworkStartSynchronisedScene(idleNetScene)
                              Citizen.InvokeNative(0x79C0E43EB9B944E2, -2124244681)
                            end)
                          end)

                          if (rdata.msg) then
                            exports.pnotify:SendNotification({text = rdata.msg})
                          end
                        else
                          if (rdata.msg) then
                            exports.pnotify:SendNotification({text = rdata.msg})
                          end

                          blockInput = false
                          toggleControlsForGaming(true)
                        end
                      end
                    end, {tableIndex = tableIndex, seatIndex = closestSeat})
                  end
                else
                  SendNUIMessage({showCreateMaxBet = true, tableMaxBet = tableMaxBet})
                  SetNuiFocus(true, true)
                  SetNuiFocusKeepInput(true)
                end
              end
            end
          end
          
          DrawMarker(1, tSpot.radPos.x, tSpot.radPos.y, tSpot.radPos.z, 0, 0, 0, 0, 0, 0, 2.75, 2.75, 0.25, 15, 120, 120, 40)
        end
      end
    end
  end
end)

--[[ Messy assed IPL init, move to csrp_gamemode eventually ]]
function initCasino()
  RequestIpl("vw_casino_main")
  RequestIpl("vw_casino_garage")
  RequestIpl("vw_casino_carpark")
  RequestIpl("vw_casino_penthouse")
  RequestIpl("hei_dlc_casino_aircon")
  RequestIpl("hei_dlc_casino_aircon_lod")
  RequestIpl("hei_dlc_casino_door")
  RequestIpl("hei_dlc_casino_door_lod")
  RequestIpl("hei_dlc_vw_roofdoors_locked")
  RequestIpl("hei_dlc_windows_casino")
  RequestIpl("hei_dlc_windows_casino_lod")
  RequestIpl("vw_ch3_additions")
  RequestIpl("vw_ch3_additions_long_0")
  RequestIpl("vw_ch3_additions_strm_0")
  RequestIpl("vw_dlc_casino_door")
  RequestIpl("vw_dlc_casino_door_lod")
  RequestIpl("vw_casino_billboard")
  RequestIpl("vw_casino_billboard_lod(1)")
  RequestIpl("vw_casino_billboard_lod")
  RequestIpl("vw_int_placement_vw")
  RequestIpl("vw_dlc_casino_apart")

  local int = GetInteriorAtCoords(2488.348, -267.3637, -71.64563) -- Vault

  EnableInteriorProp(int, "set_vault_door")
  RefreshInterior(int)

  local int = GetInteriorAtCoords(2730.000, -380.000, -50.000) -- Arcade (broken)

  ActivateInteriorEntitySet(int, "casino_arcade_style_01")
  ActivateInteriorEntitySet(int, "casino_arcade_extraprops_texture_style_03")
  ActivateInteriorEntitySet(int, "casino_arcade_extraprops_wall_04")
  ActivateInteriorEntitySet(int, "casino_arcade_extraprops_streetgames_01")
  ActivateInteriorEntitySet(int, "casino_arcade_extraprops_wallmonitors")
  ActivateInteriorEntitySet(int, "casino_arcade_no_idea") -- Some floor stuff
  ActivateInteriorEntitySet(int, "casino_arcade_no_idea2") -- Neon stuff i think
  ActivateInteriorEntitySet(int, "casino_arcade_extraprops_barstuff")
  ActivateInteriorEntitySet(int, "casino_arcade_extraprops_walltv")
  ActivateInteriorEntitySet(int, "casino_arcade_extraprops_lights_01") -- This also has trophies etc
  ActivateInteriorEntitySet(int, "casino_arcade_extraprops_lights_02")
  ActivateInteriorEntitySet(int, "casino_arcade_extraprops_wire") -- This has extra added arcade game props
  RefreshInterior(int)

  local int = GetInteriorAtCoords(2697.615, -376.3892, -56.46193) -- Plan Garage (broken?)
  
    -- PROPS: Can all be used at same time without colliding
  ActivateInteriorEntitySet(int, "casino_plan_hacking")
  ActivateInteriorEntitySet(int, "casino_plan_keypads")
  ActivateInteriorEntitySet(int, "casino_plan_hacking2")
  ActivateInteriorEntitySet(int, "casino_plan_work")
  ActivateInteriorEntitySet(int, "casino_plan_work2")
  ActivateInteriorEntitySet(int, "casino_plan_vaultplan")
  ActivateInteriorEntitySet(int, "casino_plan_work3")
  ActivateInteriorEntitySet(int, "casino_plan_casino_tablemodel") -- Has to be used together with: casino_plan_work3 (its on a table)
  ActivateInteriorEntitySet(int, "casino_plan_work4")
  ActivateInteriorEntitySet(int, "casino_plan_work5")
  ActivateInteriorEntitySet(int, "casino_plan_board_drawing")
  ActivateInteriorEntitySet(int, "casino_plan_machines")
  ActivateInteriorEntitySet(int, "casino_plan_blueprints")
  ActivateInteriorEntitySet(int, "casino_plan_c4")
  ActivateInteriorEntitySet(int, "casino_plan_insect")
  ActivateInteriorEntitySet(int, "casino_plan_equipment_01")
  ActivateInteriorEntitySet(int, "casino_plan_equipment_02")
  ActivateInteriorEntitySet(int, "casino_plan_equipment_03")
  ActivateInteriorEntitySet(int, "casino_plan_equipment_04")
  ActivateInteriorEntitySet(int, "casino_plan_equipment_05")
  ActivateInteriorEntitySet(int, "casino_plan_equipment_hat")
  ActivateInteriorEntitySet(int, "casino_plan_drone")
  ActivateInteriorEntitySet(int, "casino_plan_noidea_xd")
  ActivateInteriorEntitySet(int, "casino_plan_equipment_07")
  RefreshInterior(int)

  local int = 274689 -- Penthouse [976.636, 70.295, 115.164]

  ActivateInteriorEntitySet(int, "Set_Pent_Tint_Shell")
  
  --[[
    default = 0,
    sharp = 1,
    vibrant = 2,
    timeless = 3
  ]]
  
  SetInteriorEntitySetColor(int, "Set_Pent_Tint_Shell", 3)

  --[[
    pattern01 = "Set_Pent_Pattern_01", pattern02 = "Set_Pent_Pattern_02", pattern03 = "Set_Pent_Pattern_03",
    pattern04 = "Set_Pent_Pattern_04", pattern05 = "Set_Pent_Pattern_05", pattern06 = "Set_Pent_Pattern_06",
    pattern07 = "Set_Pent_Pattern_07", pattern08 = "Set_Pent_Pattern_08", pattern09 = "Set_Pent_Pattern_09",
  ]]

  ActivateInteriorEntitySet(int, "Set_Pent_Pattern_08")
  ActivateInteriorEntitySet(int, "Set_Pent_Spa_Bar_Open") --[[ open = "Set_Pent_Spa_Bar_Open", closed = "Set_Pent_Spa_Bar_Closed" ]]
  ActivateInteriorEntitySet(int, "Set_Pent_Media_Bar_Open") --[[ open = "Set_Pent_Media_Bar_Open", closed = "Set_Pent_Media_Bar_Closed", ]]
  ActivateInteriorEntitySet(int, "Set_Pent_Dealer") --[[ open = "Set_Pent_Dealer", closed = "Set_Pent_NoDealer", ]]
  ActivateInteriorEntitySet(int, "Set_Pent_Arcade_Modern") --[[ none = "", retro = "Set_Pent_Arcade_Retro", modern = "Set_Pent_Arcade_Modern" ]]
  ActivateInteriorEntitySet(int, "Set_Pent_Bar_Clutter") --[[ bar = "Set_Pent_Bar_Clutter", clutter01 = "Set_Pent_Clutter_01", clutter02 = "Set_Pent_Clutter_02", clutter03 = "Set_Pent_Clutter_03" ]]
  ActivateInteriorEntitySet(int, "set_pent_bar_light_01") --[[ none = "", light0 = "set_pent_bar_light_0", light1 = "set_pent_bar_light_01", light2 = "set_pent_bar_light_02", ]]
  ActivateInteriorEntitySet(int, "") --[[ none = "", party0 = "set_pent_bar_party_0", party1 = "set_pent_bar_party_1", party2 = "set_pent_bar_party_2", partyafter = "set_pent_bar_party_after", ]]
  RefreshInterior(int)

  local int = GetInteriorAtCoords(1550.0, 250.0, -48.0) -- Casino Nightclub

  ActivateInteriorEntitySet(int, "dj_01_lights_03")
  ActivateInteriorEntitySet(int, "dj_02_lights_03")
  ActivateInteriorEntitySet(int, "dj_03_lights_03")
  ActivateInteriorEntitySet(int, "dj_04_lights_03")
  ActivateInteriorEntitySet(int, "int01_ba_bar_content")
  ActivateInteriorEntitySet(int, "int01_ba_booze_02")
  ActivateInteriorEntitySet(int, "int01_ba_dj03")
  ActivateInteriorEntitySet(int, "int01_ba_dj_keinemusik")
  ActivateInteriorEntitySet(int, "int01_ba_dry_ice")
  ActivateInteriorEntitySet(int, "int01_ba_equipment_setup")
  ActivateInteriorEntitySet(int, "int01_ba_equipment_upgrade")
  ActivateInteriorEntitySet(int, "int01_ba_lightgrid_01")
  ActivateInteriorEntitySet(int, "int01_ba_lights_screen")
  ActivateInteriorEntitySet(int, "int01_ba_screen")
  ActivateInteriorEntitySet(int, "int01_ba_security_upgrade")
  ActivateInteriorEntitySet(int, "int01_ba_style02_podium")
  ActivateInteriorEntitySet(int, "EntitySet_DJ_Lighting")
  RefreshInterior(int)
end

Citizen.CreateThread(function()
  Wait(500)
  initCasino()

  for _, emitter in pairs(radioEmitters) do
    SetEmitterRadioStation(emitter, casinoRadioStationHash)
  end
end)

--[[ Placing here temporarily ]]
local islandEnabled = true
local islandVec = vector3(4840.571, -5174.425, 2.0)
local inIsland = false

Citizen.CreateThread(function()
  while true do
    if (not islandEnabled) then return end

    local pos = GetEntityCoords(PlayerPedId())		
    local dist = #(pos - islandVec)

    if (dist < 2000.0) then
      if (not inIsland) then
        Citizen.InvokeNative("0x9A9D1BA639675CF1", "HeistIsland", true)  -- load the map and removes the city
        Citizen.InvokeNative("0x5E1460624D194A38", true) -- load the minimap/pause map and removes the city minimap/pause map
        inIsland = true
      end
    else
      if (inIsland) then
        Citizen.InvokeNative("0x9A9D1BA639675CF1", "HeistIsland", false)
        Citizen.InvokeNative("0x5E1460624D194A38", false)
        inIsland = false
      end
    end
      
    Wait(5000)
  end
end)