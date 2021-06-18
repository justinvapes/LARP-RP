local playerHasProp = false
local holdingEprop = false
local ePropSpawned
local ePropIndex = 0
local propEmotes = {}
local ePropTable = {
  [1] = {dict = "amb@world_human_drinking@beer@male@idle_a", anim = "idle_a", flag = 49, prop = "prop_cs_beer_bot_40oz_02", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [2] = {dict = "amb@world_human_drinking@beer@male@idle_a", anim = "idle_b", flag = 49, prop = "prop_cs_beer_bot_40oz_02", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [3] = {dict = "amb@world_human_drinking@beer@female@idle_a", anim = "idle_a", flag = 49, prop = "prop_cs_beer_bot_40oz_02", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [4] = {dict = "amb@world_human_drinking@beer@female@idle_a", anim = "idle_e", flag = 49, prop = "prop_cs_beer_bot_40oz_02", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [5] = {dict = "amb@code_human_in_bus_passenger_idles@female@tablet@base", anim = "base", flag = 49, prop = "prop_cs_tablet", pos = vec3(0.2, 0.07, 0.13), rot = vec3(180.0, 0.0, 20.0), bone = 18905},
  [6] = {dict = "amb@medic@standing@timeofdeath@base", anim = "base", flag = 49, prop = "prop_notepad_01", pos = vec3(0.15, 0.0, 0.03), rot = vec3(310.0, 0.0, 0.0), bone = 18905},
  [7] = {dict = "amb@code_human_wander_drinking@beer@male@base", anim = "static", flag = 49, prop = "p_amb_brolly_01", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [8] = {dict = "amb@world_human_aa_smoke@male@idle_a", anim = "idle_a", flag = 49, prop = "prop_cs_ciggy_01", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [9] = {dict = "amb@world_human_aa_smoke@male@idle_a", anim = "idle_c", flag = 49, prop = "prop_cs_ciggy_01", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [10] = {dict = "amb@world_human_smoking@female@idle_a", anim = "idle_b", flag = 49, prop = "prop_cs_ciggy_01", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [11] = {dict = "anim@amb@nightclub@lazlow@hi_railing@", anim = "ambclub_13_mi_hi_sexualgriding_laz", flag = 1, prop = "ba_prop_battle_glowstick_01", pos = vec3(0.0700, 0.1400, 0.0), rot = vec3(-80.0, 20.0, 0.0), bone = 28422, prop2 = "ba_prop_battle_glowstick_01", pos2 = vec3(0.0700, 0.0900, 0.0), rot2 = vec3(-120.0, -20.0, 0.0), bone2 = 60309},
  [12] = {dict = "anim@amb@nightclub@lazlow@hi_railing@", anim = "ambclub_09_mi_hi_bellydancer_laz", flag = 1, prop = "ba_prop_battle_glowstick_01", pos = vec3(0.0700, 0.1400, 0.0), rot = vec3(-80.0, 20.0, 0.0), bone = 28422, prop2 = "ba_prop_battle_glowstick_01", pos2 = vec3(0.0700, 0.0900, 0.0), rot2 = vec3(-120.0, -20.0, 0.0), bone2 = 60309},
  [13] = {dict = "anim@amb@nightclub@lazlow@hi_railing@", anim = "ambclub_12_mi_hi_bootyshake_laz", flag = 1, prop = "ba_prop_battle_glowstick_01", pos = vec3(0.0700, 0.1400, 0.0), rot = vec3(-80.0, 20.0, 0.0), bone = 28422, prop2 = "ba_prop_battle_glowstick_01", pos2 = vec3(0.0700, 0.0900, 0.0), rot2 = vec3(-120.0, -20.0, 0.0), bone2 = 60309},
  [14] = {dict = "anim@amb@nightclub@lazlow@hi_dancefloor@", anim = "dancecrowd_li_15_handup_laz", flag = 1, prop = "ba_prop_battle_hobby_horse", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [15] = {dict = "anim@amb@nightclub@lazlow@hi_dancefloor@", anim = "crowddance_hi_11_handup_laz", flag = 1, prop = "ba_prop_battle_hobby_horse", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [16] = {dict = "anim@amb@nightclub@lazlow@hi_dancefloor@", anim = "dancecrowd_li_11_hu_shimmy_laz", flag = 1, prop = "ba_prop_battle_hobby_horse", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [17] = {dict = "amb@world_human_maid_clean@base", anim = "base", flag = 49, prop = "prop_rag_01", pos = vec3(0.1, 0.0, -0.05), rot = vec3(180.0, 0.0, 0.0), bone = 57005},
  [18] = {dict = "mp_character_creation@customise@male_a", anim = "loop", flag = 49, prop = "prop_police_id_board", pos = vec3(0.12, 0.24, 0.0), rot = vec3(5.0, 0.0, 70.0), bone = 58868},
  [19] = {dict = "amb@world_human_drinking@coffee@male@idle_a", anim = "idle_c", flag = 49, prop = "p_amb_coffeecup_01", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [20] = {dict = "amb@world_human_drinking@coffee@male@idle_a", anim = "idle_c", flag = 49, prop = "prop_drink_whisky", pos = vec3(0.01, -0.01, -0.06), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [21] = {dict = "amb@world_human_leaning@male@wall@back@beer@idle_a", anim = "idle_b", flag = 49, prop = "prop_amb_beer_bottle", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [22] = {dict = "amb@prop_human_seat_chair_drink_beer@female@idle_a", anim = "idle_a", flag = 49, prop = "prop_amb_beer_bottle", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [23] = {dict = "mp_player_inteat@burger", anim = "mp_player_int_eat_burger", flag = 49, prop = "prop_amb_donut", pos = vec3(0.13, 0.05, 0.02), rot = vec3(-50.0, 16.0, 60.0), bone = 18905},
  [24] = {dict = "mp_player_inteat@burger", anim = "mp_player_int_eat_burger", flag = 49, prop = "prop_cs_burger_01", pos = vec3(0.13, 0.05, 0.02), rot = vec3(-50.0, 16.0, 60.0), bone = 18905},
  [25] = {dict = "mp_player_inteat@burger", anim = "mp_player_int_eat_burger", flag = 49, prop = "prop_sandwich_01", pos = vec3(0.13, 0.05, 0.02), rot = vec3(-50.0, 16.0, 60.0), bone = 18905},
  [26] = {dict = "amb@world_human_drinking@coffee@male@idle_a", anim = "idle_c", flag = 49, prop = "prop_ecola_can", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 130.0), bone = 28422},
  [27] = {dict = "mp_player_inteat@burger", anim = "mp_player_int_eat_burger", flag = 49, prop = "prop_choc_ego", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 60309},
  [28] = {dict = "anim@heists@humane_labs@finale@keycards", anim = "ped_a_enter_loop", flag = 49, prop = "prop_drink_redwine", pos = vec3(0.10, -0.03, 0.03), rot = vec3(-100.0, 0.0, -10.0), bone = 18905},
  [29] = {dict = "anim@heists@humane_labs@finale@keycards", anim = "ped_a_enter_loop", flag = 49, prop = "prop_drink_champ", pos = vec3(0.10, -0.10, 0.03), rot = vec3(-100.0, 0.0, -10.0), bone = 18905},
  [30] = {dict = "amb@world_human_aa_smoke@male@idle_a", anim = "idle_a", flag = 49, prop = "prop_cigar_02", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 180.0, 0.0), bone = 28422},
  [31] = {dict = "amb@world_human_aa_smoke@male@idle_a", anim = "idle_c", flag = 49, prop = "prop_cigar_01", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 180.0, 0.0), bone = 28422},
  [32] = {dict = "cellphone@", anim = "cellphone_text_read_base", flag = 49, prop = "prop_novel_01", pos = vec3(0.09, 0.03, -0.065), rot = vec3(-20.0, 180.0, 270.0), bone = 6286},
  [33] = {dict = "missfam4", anim = "base", flag = 49, prop = "prop_fib_clipboard", pos = vec3(0.16, 0.08, 0.1), rot = vec3(-130.0, -50.0, 0.0), bone = 36029},
  [34] = {dict = "amb@world_human_tourist_map@male@base", anim = "base", flag = 49, prop = "prop_tourist_map_01", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
  [35] = {dict = "amb@world_human_bum_freeway@male@base", anim = "base", flag = 49, prop = "prop_beggers_sign_03", pos = vec3(0.19, 0.15, 0.0), rot = vec3(5.0, 0.0, 40.0), bone = 58868},
  [36] = {dict = "timetable@gardener@smoking_joint", anim = "smoke_idle", flag = 49, prop = "p_cs_joint_02", pos = vec3(0.07, 0.05, -0.050), rot = vec3(0.0, 0.0, 50.0), bone = 28422},
  [37] = {dict = "timetable@floyd@clean_kitchen@base", anim = "base", flag = 49, prop = "prop_sponge_01", pos = vec3(0.0, 0.0, -0.01), rot = vec3(90.0, 0.0, 0.0), bone = 28422},
  [38] = {dict = "amb@world_human_mobile_film_shocking@male@base", anim = "base", flag = 49, prop = "prop_npc_phone_02", pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0), bone = 28422},
}

function toggleEmoteBlock(toggle)
  exports.emotes:blockHandsUp(toggle)
  exports.emotes:setCanEmote(not toggle)
  exports.csrp_gamemode:blockPointing(toggle)
end

RegisterNetEvent("bms:propEmotes:init")
AddEventHandler("bms:propEmotes:init", function(prEmotes)
  if (prEmotes) then
    propEmotes = prEmotes
  end

  if (#propEmotes > 0) then
    -- add my categories
    exports.actionmenu:addCategory("Emote Props", 13)

    for id, v in pairs(propEmotes) do
      exports.actionmenu:addAction("emotes", "propemote", "none", v.dispName, 13, id)
    end
  end
end)

RegisterNetEvent("bms:charcreator:toggleeprop")
AddEventHandler("bms:charcreator:toggleeprop", function(index)
  local ped = PlayerPedId()  
  local handcuffed = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)
  local pedveh = IsPedInAnyVehicle(ped, false)
 
  if (index == 0) then 

    if (not holdingEprop) then return end

    StopAnimTask(ped, ePropTable[ePropIndex].dict, ePropTable[ePropIndex].anim, 1.0)
    Wait(400)
    DetachEntity(ePropSpawned, 1, 1)
    DetachEntity(ePropSpawned2, 1, 1)
    DeleteEntity(ePropSpawned)
    DeleteEntity(ePropSpawned2)
    holdingEprop = false
    playerHasProp = false
    toggleEmoteBlock(false)
    return
  end
  
  if (handcuffed) then
    exports.pnotify:SendNotification({text = "You can not do that while handcuffed."})
    return
  end

  if (pedveh) then
    exports.pnotify:SendNotification({text = "You can not do that while in a vehicle."})
    return
  end
    
  if (playerHasProp) then
    if (not holdingEprop) then
      exports.pnotify:SendNotification({text = "End your current prop emote first."})
      return
    end
  end 

  if (not holdingEprop) then
    while (not HasModelLoaded(GetHashKey(ePropTable[index].prop))) do
      RequestModel(GetHashKey(ePropTable[index].prop))
      Wait(10)
    end

    while (not HasAnimDictLoaded(ePropTable[index].dict)) do
      RequestAnimDict(ePropTable[index].dict)
      Wait(10)
    end

    boneIndex = ePropTable[index].bone
    local ppos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
    ePropSpawned = CreateObject(GetHashKey(ePropTable[index].prop), ppos.x, ppos.y, ppos.z, true, false, false)
	  SetModelAsNoLongerNeeded(GetHashKey(ePropTable[index].prop))
    AttachEntityToEntity(ePropSpawned, ped, GetPedBoneIndex(ped, boneIndex), ePropTable[index].pos.x, ePropTable[index].pos.y, ePropTable[index].pos.z, ePropTable[index].rot.x, ePropTable[index].rot.y, ePropTable[index].rot.z, 1, 1, 0, 1, 0, 1)

    if (ePropTable[index].prop2) then
      boneIndex = ePropTable[index].bone2
      ePropSpawned2 = CreateObject(GetHashKey(ePropTable[index].prop2), ppos.x, ppos.y, ppos.z, true, false, false)
      AttachEntityToEntity(ePropSpawned2, ped, GetPedBoneIndex(ped, boneIndex), ePropTable[index].pos2.x, ePropTable[index].pos2.y, ePropTable[index].pos2.z, ePropTable[index].rot2.x, ePropTable[index].rot2.y, ePropTable[index].rot2.z, 1, 1, 0, 1, 0, 1)
    end

    TaskPlayAnim(ped, ePropTable[index].dict, ePropTable[index].anim, 2.0, 2.0, -1, ePropTable[index].flag, 0, 0, 0, 0)
    RemoveAnimDict(ePropTable[index].dict)
    holdingEprop = true
    playerHasProp = true
    ePropIndex = index
    toggleEmoteBlock(true)
    
    Citizen.CreateThread(function()  
      while (holdingEprop) do 
        Wait(100)

        local ped = PlayerPedId()
        local pedveh = IsPedInAnyVehicle(ped, false)
        
        if (pedveh) then
          StopAnimTask(ped, ePropTable[ePropIndex].dict, ePropTable[ePropIndex].anim, 1.0)
          DetachEntity(ePropSpawned, 1, 1)
          DetachEntity(ePropSpawned2, 1, 1)
          DeleteEntity(ePropSpawned)
          DeleteEntity(ePropSpawned2)
          holdingEprop = false
          playerHasProp = false
          toggleEmoteBlock(false)
        end
      end
    end)
  else
    StopAnimTask(ped, ePropTable[ePropIndex].dict, ePropTable[ePropIndex].anim, 1.0)
    Wait(400)
    DetachEntity(ePropSpawned, 1, 1)
    DetachEntity(ePropSpawned2, 1, 1)
    DeleteEntity(ePropSpawned)
    DeleteEntity(ePropSpawned2)
    holdingEprop = false
    playerHasProp = false
    toggleEmoteBlock(false)
  end
end)



