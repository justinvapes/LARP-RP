local MumbleSetVolumeOverride = MumbleSetVolumeOverride
local MumbleSetVolumeOverrideByServerId = MumbleSetVolumeOverrideByServerId

local forumUrl = "https://discourse.larp-servers.org/"
local propLoads = {
  {intid = 166657, propid = "V_Michael_bed_tidy"}, -- michaels house
  {intid = 258561, propid = "bunker_style_b"}, -- bunker 1 -- entrance 2107.249, 3324.453, 45.377 interior 887.65 -3245.10 -98.27
  {intid = 258561, propid = "upgrade_bunker_set"},
  {intid = 258561, propid = "upgrade_bunker_set_more"},
  {intid = 258561, propid = "security_upgrade"},
  {intid = 258561, propid = "Office_Upgrade_set"},
  {intid = 258561, propid = "gun_range_lights"},
  {intid = 258561, propid = "gun_schematic_set"},
  {intid = 258561, propid = "weed_production"}, -- weed warehouse entrance 1312.101 4362.241 40.855 interior 1063.445 -3183.618 -39.164
  {intid = 247297, propid = "weed_production"},
  {intid = 247297, propid = "weed_chairs"},
  {intid = 247297, propid = "weed_growtha_stage3"},
  {intid = 247297, propid = "weed_growthb_stage3"},
  {intid = 247297, propid = "weed_growthc_stage3"},
  {intid = 247297, propid = "weed_growthd_stage3"},
  {intid = 247297, propid = "weed_growthe_stage3"},
  {intid = 247297, propid = "weed_growthf_stage3"},
  {intid = 247297, propid = "weed_growthg_stage3"},
  {intid = 247297, propid = "weed_growthh_stage3"},
  {intid = 247297, propid = "weed_growthi_stage3"},
  {intid = 247297, propid = "weed_hosea"},
  {intid = 247297, propid = "weed_hoseb"},
  {intid = 247297, propid = "weed_hosec"},
  {intid = 247297, propid = "weed_hosed"},
  {intid = 247297, propid = "weed_hosee"},
  {intid = 247297, propid = "weed_hosef"},
  {intid = 247297, propid = "weed_hoseg"},
  {intid = 247297, propid = "weed_hoseh"},
  {intid = 247297, propid = "weed_hosei"},
  {intid = 247297, propid = "light_growtha_stage23_upgrade"},
  {intid = 247297, propid = "light_growthb_stage23_upgrade"},
  {intid = 247297, propid = "light_growthc_stage23_upgrade"},
  {intid = 247297, propid = "light_growthd_stage23_upgrade"},
  {intid = 247297, propid = "light_growthe_stage23_upgrade"},
  {intid = 247297, propid = "light_growthf_stage23_upgrade"},
  {intid = 247297, propid = "light_growthg_stage23_upgrade"},
  {intid = 247297, propid = "light_growthh_stage23_upgrade"},
  {intid = 247297, propid = "light_growthi_stage23_upgrade"},
  {intid = 247553, propid = "coke_cut_01"}, -- coke warehouse entrance 387.636 3585.846 33.292 interior 1088.472 -3191.326 -38.993
  {intid = 247553, propid = "coke_cut_02"},
  {intid = 247553, propid = "coke_cut_03"},
  {intid = 247553, propid = "security_high"},
  {intid = 247553, propid = "production_upgrade"},
  {intid = 247553, propid = "equipment_upgrade"},
  {intid = 247553, propid = "coke_cut_04"},
  {intid = 247553, propid = "coke_cut_05"},
  {intid = 247553, propid = "set_up"},
  {intid = 247553, propid = "table_equipment_upgrade"}, -- meth lab warehouse entrance 1181.720 -3114.252 6.028 interior 998.629 -3199.545 -36.394
  {intid = 247553, propid = "coke_press_upgrade"},
  {intid = 247041, propid = "meth_lab_upgrade"},
  {intid = 247041, propid = "meth_lab_production"},
  {intid = 247041, propid = "meth_lab_security_high"},
  {intid = 247041, propid = "meth_lab_setup"},
  -- Lost's Clubhouse -- /teleport 1107.04 -3157.399 -37.51859
  {intid = 246273, propid = "walls_01"},
  {intid = 246273, propid = "decorative_01"},
  {intid = 246273, propid = "furnishings_01"},
  {intid = 246273, propid = "mural_03"},
  {intid = 246273, propid = "gun_locker"},
  {intid = 246273, propid = "mod_booth"},
  --[[
  {intid = 246273, propid = "cash_stash1"},
  {intid = 246273, propid = "cash_stash2"},
  {intid = 246273, propid = "cash_stash3"},
  {intid = 246273, propid = "coke_stash1"},
  {intid = 246273, propid = "coke_stash2"},
  {intid = 246273, propid = "coke_stash3"},
  {intid = 246273, propid = "counterfeit_stash1"},
  {intid = 246273, propid = "counterfeit_stash2"},
  {intid = 246273, propid = "counterfeit_stash3"},
  {intid = 246273, propid = "weed_stash1"},
  {intid = 246273, propid = "weed_stash2"},
  {intid = 246273, propid = "weed_stash3"},
  {intid = 246273, propid = "id_stash1"},
  {intid = 246273, propid = "id_stash1"},
  {intid = 246273, propid = "id_stash1"},
  {intid = 246273, propid = "meth_stash1"},
  {intid = 246273, propid = "meth_stash2"},
  {intid = 246273, propid = "meth_stash3"}]]

  -- King's Clubhouse -- /teleport 998.4809 -3164.711 -38.90733
  {intid = 246529, propid = "walls_02"},
  {intid = 246529, propid = "mural_09"},
  {intid = 246529, propid = "decorative_01"},
  {intid = 246529, propid = "furnishings_02"},
  {intid = 246529, propid = "cash_small"},
  {intid = 246529, propid = "cash_large"},
  {intid = 246529, propid = "coke_small"},
  {intid = 246529, propid = "coke_medium"},
  {intid = 246529, propid = "counterfeit_large"},
  {intid = 246529, propid = "id_small"},
  {intid = 246529, propid = "id_medium"},
  {intid = 246529, propid = "id_large"},
  {intid = 246529, propid = "weed_small"},
  {intid = 246529, propid = "lower_walls_default"},
  {intid = 246529, propid = "gun_locker"},
  {intid = 246529, propid = "mod_booth"},

  {intid = 247809, propid = "counterfeit_cashpile10a"},
  {intid = 247809, propid = "counterfeit_cashpile100d"},
  {intid = 247809, propid = "counterfeit_security"},
  {intid = 247809, propid = "counterfeit_setup"},
  {intid = 247809, propid = "counterfeit_upgrade_equip"},
  {intid = 247809, propid = "money_cutter"},
  {intid = 247809, propid = "special_chairs"},
  {intid = 247809, propid = "dryera_on"},
  {intid = 247809, propid = "dryerb_on"},
  {intid = 247809, propid = "dryerc_open"},
  -- forgery office 246785 -- /teleport 1163.842 -3195.7 -39.008 
  {intid = 246785, propid = "chair01"},
  {intid = 246785, propid = "chair02"},
  {intid = 246785, propid = "chair03"},
  {intid = 246785, propid = "chair04"},
  {intid = 246785, propid = "chair05"},
  {intid = 246785, propid = "chair06"},
  {intid = 246785, propid = "chair07"},
  {intid = 246785, propid = "clutter"},
  {intid = 246785, propid = "equipment_upgrade"},
  {intid = 246785, propid = "interior_upgrade"},
  {intid = 246785, propid = "production"},
  {intid = 246785, propid = "security_high"},
  {intid = 246785, propid = "set_up"},
  -- import export garage upper -- /teleport 994.593 -3002.594 -39.647
  {intid = 252673, propid = "urban_style_set"},
  {intid = 252673, propid = "car_floor_hatch"},
  -- import export garage lower -- /teleport 969.538, -3000.411, -48.647
  {intid = 253185, propid = "pump_01"},
  {intid = 253185, propid = "pump_02"},
  {intid = 253185, propid = "pump_03"},
  {intid = 253185, propid = "pump_04"},
  {intid = 253185, propid = "pump_05"},
  {intid = 253185, propid = "pump_06"},
  {intid = 253185, propid = "pump_07"},
  {intid = 253185, propid = "pump_08"},
  -- CEO Garage 1 -- /teleport -191.0133, -579.1428, 135.0000
  {intid = 253441, propid = "numbering_style01_n2"},
  {intid = 253441, propid = "lighting_option02"},
  {intid = 253441, propid = "garage_decor_03"},
   --[[
  {intid = 252673, propid = "garage_decor_01"},
  {intid = 252673, propid = "garage_decor_02"},
  {intid = 252673, propid = "garage_decor_03"},
  {intid = 252673, propid = "garage_decor_04"},
  {intid = 252673, propid = "lighting_option01"},
  {intid = 252673, propid = "lighting_option02"},
  {intid = 252673, propid = "lighting_option03"},
  {intid = 252673, propid = "lighting_option04"},
  {intid = 252673, propid = "lighting_option05"},
  {intid = 252673, propid = "lighting_option06"},
  {intid = 252673, propid = "lighting_option07"},
  {intid = 252673, propid = "lighting_option08"},
  {intid = 252673, propid = "lighting_option09"},
  {intid = 252673, propid = "numbering_style01_n3"},
  {intid = 252673, propid = "numbering_style02_n3"},
  {intid = 252673, propid = "numbering_style03_n3"},
  {intid = 252673, propid = "numbering_style04_n3"},
  {intid = 252673, propid = "numbering_style05_n3"},
  {intid = 252673, propid = "numbering_style06_n3"},
  {intid = 252673, propid = "numbering_style07_n3"},
  {intid = 252673, propid = "numbering_style08_n3"},
  {intid = 252673, propid = "numbering_style09_n3"},
  {intid = 252673, propid = "floor_vinyl_01"},
  {intid = 252673, propid = "floor_vinyl_02"},
  {intid = 252673, propid = "floor_vinyl_03"},
  {intid = 252673, propid = "floor_vinyl_04"},
  {intid = 252673, propid = "floor_vinyl_05"},
  {intid = 252673, propid = "floor_vinyl_06"},
  {intid = 252673, propid = "floor_vinyl_07"},
  {intid = 252673, propid = "floor_vinyl_08"},
  {intid = 252673, propid = "floor_vinyl_09"},
  {intid = 252673, propid = "floor_vinyl_10"},
  {intid = 252673, propid = "floor_vinyl_11"},
  {intid = 252673, propid = "floor_vinyl_12"},
  {intid = 252673, propid = "floor_vinyl_13"},
  {intid = 252673, propid = "floor_vinyl_14"},
  {intid = 252673, propid = "floor_vinyl_15"},
  {intid = 252673, propid = "floor_vinyl_16"},
  {intid = 252673, propid = "floor_vinyl_17"},
  {intid = 252673, propid = "floor_vinyl_18"},
  {intid = 252673, propid = "floor_vinyl_19"},]]
  -- "Floyd's" Apartment -- /teleport -1150.703 -1520.713 10.633
  {intid = 171777, propid = "swap_clean_apt"}, 
  {intid = 171777, propid = "layer_whiskey"},
  {intid = 171777, propid = "swap_sofa_A"},
  {intid = 171777, propid = "swap_mrJam_A"},
  -- After Hours Nightclub -- /teleport -1604.664, -3012.583, -78.000
  {intid = 271617, propid = "Int01_ba_clubname_08"},
  {intid = 271617, propid = "Int01_ba_Style03"},
  {intid = 271617, propid = "Int01_ba_style03_podium"},
  {intid = 271617, propid = "Int01_ba_equipment_setup"},
  {intid = 271617, propid = "Int01_ba_equipment_upgrade"},
  {intid = 271617, propid = "Int01_ba_security_upgrade"},
  {intid = 271617, propid = "Int01_ba_dj03"},
  --{intid = 271617, propid = "DJ_04_Lights_01"}, -- Icicle drop lights hanging from the ceiling
  --{intid = 271617, propid = "DJ_04_Lights_02"}, -- random neon lights hanging from girders
  {intid = 271617, propid = "DJ_01_Lights_03"}, -- bands of light draping through the ceiling
  {intid = 271617, propid = "DJ_01_Lights_04"}, -- third color in lasers that isn't white or purple
  {intid = 271617, propid = "Int01_ba_bar_content"},
  {intid = 271617, propid = "Int01_ba_booze_03"},
  {intid = 271617, propid = "Int01_ba_trophy03"},
  {intid = 271617, propid = "Int01_ba_trophy04"},
  {intid = 271617, propid = "Int01_ba_dry_ice"},
  {intid = 271617, propid = "Int01_ba_lightgrid_01"},
  --{intid = 271617, propid = "Int01_ba_trad_lights"}
}
-- trick to get id of interior: /crun GetInteriorAtCoords(GetEntityCoords(PlayerPedId()))

-- load IPLs
function loadInteriors()
  Citizen.CreateThread(function()
    RequestIpl("Carwash_with_spinners")
    RequestIpl("shr_int")    -- Coords: -47.16170 -1115.3327 26.5
    RequestIpl("post_hiest_unload")  -- jewelry store
    RemoveIpl("jewel2fake")
    --RequestIpl("bh1_16_refurb")-- refurb signs
    --RequestIpl("smboat")
    RequestIpl("hei_yacht_heist") -- /teleport -2043.974-1031.582 11.981
    RequestIpl("hei_yacht_heist_enginrm")
    RequestIpl("hei_yacht_heist_Lounge")
    RequestIpl("hei_yacht_heist_Bridge")
    RequestIpl("hei_yacht_heist_Bar")
    RequestIpl("hei_yacht_heist_Bedrm")
    RequestIpl("hei_yacht_heist_DistantLights")
    RequestIpl("hei_yacht_heist_LODLights")
    RequestIpl("gr_heist_yacht2")
    RequestIpl("gr_heist_yacht2_slod")
    RequestIpl("gr_heist_yacht2_bar")
    RequestIpl("gr_heist_yacht2_bar_lod")
    RequestIpl("gr_heist_yacht2_bedrm")
    RequestIpl("gr_heist_yacht2_bedrm_lod")
    RequestIpl("gr_heist_yacht2_bridge")
    RequestIpl("gr_heist_yacht2_bridge_lod")
    RequestIpl("gr_heist_yacht2_enginrm")
    RequestIpl("gr_heist_yacht2_enginrm_lod")
    RequestIpl("gr_heist_yacht2_lounge")
    RequestIpl("gr_heist_yacht2_lounge_lod")
    --RequestIpl("rc12b_default")
    --RequestIpl("rc12b_hospitalinterior")
    --RequestIpl("rc12b_destroyed")
    RequestIpl("refit_unload") -- beside jewelry
    RequestIpl("bkr_bi_hw1_13_int") -- Lost clubhouse
    RequestIpl("CS1_02_cf_onmission1") -- cluckin bells
    RequestIpl("CS1_02_cf_onmission2") --
    RequestIpl("CS1_02_cf_onmission3") -- 
    RequestIpl("CS1_02_cf_onmission4") -- 
    RequestIpl("farm") -- grapeseed farm
    RequestIpl("farmint") --
    RequestIpl("farm_lod") --
    RequestIpl("farm_props") --
    RequestIpl("des_farmhouse") --
    RequestIpl("Coroner_Int_on") -- coroner
    RequestIpl("coronertrash")
    RequestIpl("trevorstrailertidy") -- trevs trailer
    RequestIpl("FruitBB") -- ifruit billboard
    RequestIpl("sc1_01_newbill")
    RequestIpl("hw1_02_newbill")
    RequestIpl("hw1_emissive_newbill")
    RequestIpl("sc1_14_newbill")
    RequestIpl("dt1_17_newbill")
    RequestIpl("id2_14_during_door") -- lesters factory
    RequestIpl("id2_14_during1") --
    RequestIpl("v_tunnel_hole")
    RequestIpl("sp1_10_real_interior") -- fame or shame stadius
    RequestIpl("sp1_10_real_interior_lod")
    RequestIpl("ch1_02_open") -- house in banham canyon
    RequestIpl("bkr_bi_id1_23_door") -- garage in la mesa
    RequestIpl("methtrailer_grp1") -- lost trailer park
    RequestIpl("CanyonRvrShallow") -- canyon river
    RequestIpl("CS3_07_MPGates") -- zancudo gates
    RequestIpl("bh1_47_joshhse_unburnt") -- josh house
    RequestIpl("bh1_47_joshhse_unburnt_lod")
    RequestIpl("gr_case0_bunkerclosed")
    RequestIpl("gr_case1_bunkerclosed")
    RequestIpl("gr_case2_bunkerclosed")
    RequestIpl("gr_case3_bunkerclosed")
    RequestIpl("gr_case4_bunkerclosed")
    RequestIpl("gr_case5_bunkerclosed")
    RequestIpl("gr_case6_bunkerclosed")
    RequestIpl("gr_case7_bunkerclosed")
    RequestIpl("gr_case9_bunkerclosed")
    RequestIpl("gr_case10_bunkerclosed")
    RequestIpl("gr_case11_bunkerclosed")
    RequestIpl("redCarpet")
    RequestIpl("facelobby")
    RequestIpl("gr_entrance_placement")
    RequestIpl("gr_grdlc_interior_placement") -- Smoketree Bunker: 887.65, -3245.10, -98.27
    RequestIpl("gr_grdlc_interior_placement_interior_0_grdlc_int_01_milo_")
    RequestIpl("gr_grdlc_interior_placement_interior_1_grdlc_int_02_milo_")
    RequestIpl("FIBlobby") -- just the lower level of FIB building lobby
    RequestIpl("lr_cs6_08_grave_closed") -- close the grave that lets you drop into the void
    RequestIpl("FINBANK") -- heist union depository (basically just a hallway, when disabled its a door into the void which you die on the sewer tunnels from falling)
    RequestIpl("imp_impexp_interior_placement_interior_1_impexp_intwaremed_milo_")
    RequestIpl("sm_smugdlc_interior_placement_interior_0_smugdlc_int_01_milo_") -- smugglers run hangar
    RequestIpl("ex_dt1_11_office_02b") -- /teleport -75 -826 243
    RequestIpl("canyonriver01") -- Water under mountain train tracks between Paleto and Sandy /teleport -532.1309 4526.187 88.7955
    RequestIpl("CS3_05_water_grp1") -- Water leading into the Alamo Sea from Zancudo River /teleport -24.685 3032.92 40.331
    RequestIpl("cs5_roads_ronoilgraffiti") -- Mo"Ron"ic graffiti billboard /teleport 2094.604 3073.252 53.147
    RequestIpl("ferris_finale_Anim") -- ferris wheel at the pier
    RequestIpl("imp_sm_13_modgarage") -- Lom Bank Garage: -1578.0230 -576.4251 104.2000
    RequestIpl("imp_dt1_11_modgarage") -- Maze Bank Garage: -73.9039, -821.6204, 284.0000
    RequestIpl("imp_dt1_02_modgarage") -- Arcadius Business Garage: -146.6166, -596.6301, 166.0000
    RequestIpl("imp_sm_13_modgarage") -- Maze Bank West Garage: -1578.0230, -576.4251, 104.2000
    RequestIpl("imp_dt1_02_cargarage_a") -- CEO Garage 1: -191.0133, -579.1428, 135.0000
    RequestIpl("ba_int_placement_ba_interior_0_dlc_int_01_ba_milo_") -- After Hours Nightclub: -1604.664, -3012.583, -78.000
    RequestIpl("ba_barriers_case6")
    RequestIpl("ba_case6_forsale")
    RequestIpl("ba_case6_taleofus")
    RequestIpl("ba_case6_solomun")
    RequestIpl("ba_case6_madonna")
    RequestIpl("ba_case6_dixon")
    -- impgaragev2 in mapenhance
    --RequestIpl("gabz_import_milo_")

    for _,v in pairs(propLoads) do
      if (not IsInteriorPropEnabled(v.intid, v.propid)) then
        EnableInteriorProp(v.intid, v.propid)
        RefreshInterior(v.intid) 
      end
    end

    local intprops = {
      {pos = vec3(-38.62, -1099.01, 27.31), itype = "v_carshowroom", ptype = "csr_beforeMission"},
      {pos = vec3(-38.62, -1099.01, 27.31), itype = "v_carshowroom", ptype = "shutter_open"}
    }

    for _,v in pairs(intprops) do
      local ict = GetInteriorAtCoordsWithType(v.pos.x, v.pos.y, v.pos.z, v.itype)

      if (ict and ict ~= 0) then
        EnableInteriorProp(ict, v.ptype)
      end
    end

    -- King's Clubhouse Colorset
    SetInteriorPropColor(246529, "walls_02", 3)
    SetInteriorPropColor(246529, "furnishings_02", 0)
    SetInteriorPropColor(246529, "lower_walls_default", 3)
    -- Lost's Clubhouse Colorset
    SetInteriorPropColor(246273, "walls_01", 7)
    SetInteriorPropColor(246273, "furnishings_01", 9)
    -- Invisible wall preventing you from walking between upper and lower import export garages
    DisableInteriorProp(252673, "door_blocker")

    -- impgaragev2 in mapenhance
    local importGarageIntId = GetInteriorAtCoords(941.00840000, -972.66450000, 39.14678000)
    
    if (IsValidInterior(importGarageIntId)) then
      --EnableInteriorProp(importGarageIntId, "basic_style_set")
      EnableInteriorProp(importGarageIntId, "urban_style_set")		
      --EnableInteriorProp(importGarageIntId, "branded_style_set")
      EnableInteriorProp(importGarageIntId, "car_floor_hatch")
      RefreshInterior(importGarageIntId)
    end
  end)
end

local scenarios = {
  "WORLD_VEHICLE_AMBULANCE",
  "WORLD_VEHICLE_POLICE_BIKE",
  "WORLD_VEHICLE_POLICE_CAR",
  "WORLD_VEHICLE_POLICE",
  "WORLD_VEHICLE_POLICE_NEXT_TO_CAR",
  "WORLD_VEHICLE_FIRE_TRUCK",
  "WORLD_VEHICLE_HELI_LIFEGUARD",
  "WORLD_VEHICLE_MILITARY_PLANES_BIG",
  "WORLD_VEHICLE_MILITARY_PLANES_SMALL",
}
local respawnTimer = 300000 --300000
local diedAt
local canRespawn = false
local stoptimer = false
local playerDispMode = 1 -- 1 = show all players including self, 2 = hide all players except self, 3 = hide all players except self and selective
local playerDispModeChanged = false
local tickDispMode = 1 -- 1 = all including self, 2 = all excluding self, 3 = selective including self, 4 = self only
local tickDispSelective = {} -- list of ids to display for in tickDispMode 3 and playerDispMode 3
local ispointing = false
local voicemode = 0
local whisperRange = 2.25
local defaultRange = 13.0
local shoutRange = 32.0
local instanceWarned = false
local firedWeapon = false
local gsrTimeout = 900000 -- 10min
local gsrElapsed = 0
local respawnCost = 350
local icstrike = 0
local lastWeapon = 0
local showWepSwitch = true
local carSwapPress = 0
local carSwap = false
local canFire = true
local weaponNames = {
  "WEAPON_KNIFE", "WEAPON_NIGHTSTICK", "WEAPON_HAMMER", "WEAPON_BAT", "WEAPON_GOLFCLUB", "WEAPON_CROWBAR", "WEAPON_MOLOTOV",
  "WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_PISTOL50", "WEAPON_MICROSMG", "WEAPON_SMG", "WEAPON_ASSAULTSMG",
  "WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE", "WEAPON_ADVANCEDRIFLE", "WEAPON_MG", "WEAPON_COMBATMG", "WEAPON_PUMPSHOTGUN",
  "WEAPON_SAWNOFFSHOTGUN", "WEAPON_ASSAULTSHOTGUN", "WEAPON_BULLPUPSHOTGUN", "WEAPON_STUNGUN", "WEAPON_SNIPERRIFLE", 
  "WEAPON_HEAVYSNIPER", "WEAPON_GRENADELAUNCHER", "WEAPON_RPG", "WEAPON_MINIGUN", "WEAPON_GRENADE", "WEAPON_STICKYBOMB",
  "WEAPON_REVOLVER", "WEAPON_SWITCHBLADE", "WEAPON_STONE_HATCHET", "WEAPON_BOTTLE", "WEAPON_SNSPISTOL", "WEAPON_AUTOSHOTGUN", 
  "WEAPON_BATTLEAXE", "WEAPON_COMPACTLAUNCHER", "WEAPON_MINISMG", "WEAPON_PIPEBOMB", "WEAPON_POOLCUE", "WEAPON_WRENCH", 
  "WEAPON_HEAVYPISTOL", "WEAPON_SPECIALCARBINE", "WEAPON_BULLPUPRIFLE", "WEAPON_HOMINGLAUNCHER", "WEAPON_PROXMINE",
  "WEAPON_SNOWBALL", "WEAPON_BULLPUPRIFLE_MK2", "WEAPON_DOUBLEACTION", "WEAPON_MARKSMANRIFLE_MK2", "WEAPON_PUMPSHOTGUN_MK2",
  "WEAPON_REVOLVER_MK2", "WEAPON_SNSPISTOL_MK2", "WEAPON_SPECIALCARBINE_MK2", "WEAPON_RAYPISTOL", "WEAPON_RAYCARBINE",
  "WEAPON_RAYMINIGUN", "WEAPON_ASSAULTRIFLE_MK2", "WEAPON_CARBINERIFLE_MK2", "WEAPON_COMBATMG_MK2", "WEAPON_HEAVYSNIPER_MK2",
  "WEAPON_PISTOL_MK2", "WEAPON_SMG_MK2", "WEAPON_FLAREGUN", "WEAPON_DAGGER", "WEAPON_VINTAGEPISTOL",
  "WEAPON_FIREWORK", "WEAPON_MUSKET", "WEAPON_MACHETE", "WEAPON_MACHINEPISTOL", "WEAPON_COMPACTRIFLE", "WEAPON_DBSHOTGUN",
  "WEAPON_HEAVYSHOTGUN", "WEAPON_MARKSMANRIFLE", "WEAPON_COMBATPDW", "WEAPON_KNUCKLE", "WEAPON_MARKSMANPISTOL", "WEAPON_GUSENBERG",
  "WEAPON_HATCHET", "WEAPON_RAILGUN"
}
local weaponGuns = {
  "WEAPON_PISTOL", "WEAPON_COMBATPISTOL", "WEAPON_APPISTOL", "WEAPON_PISTOL50", "WEAPON_MICROSMG", "WEAPON_SMG", "WEAPON_ASSAULTSMG",
  "WEAPON_ASSAULTRIFLE", "WEAPON_CARBINERIFLE", "WEAPON_ADVANCEDRIFLE", "WEAPON_MG", "WEAPON_COMBATMG", "WEAPON_PUMPSHOTGUN",
  "WEAPON_SAWNOFFSHOTGUN", "WEAPON_ASSAULTSHOTGUN", "WEAPON_BULLPUPSHOTGUN", "WEAPON_SNIPERRIFLE", "WEAPON_AUTOSHOTGUN",
  "WEAPON_HEAVYSNIPER", "WEAPON_GRENADELAUNCHER", "WEAPON_RPG", "WEAPON_MINIGUN", "WEAPON_REVOLVER", "WEAPON_SNSPISTOL", 
  "WEAPON_COMPACTLAUNCHER", "WEAPON_MINISMG", "WEAPON_RAILGUN",
  "WEAPON_HEAVYPISTOL", "WEAPON_SPECIALCARBINE", "WEAPON_BULLPUPRIFLE", "WEAPON_HOMINGLAUNCHER",
  "WEAPON_BULLPUPRIFLE_MK2", "WEAPON_DOUBLEACTION", "WEAPON_MARKSMANRIFLE_MK2", "WEAPON_PUMPSHOTGUN_MK2",
  "WEAPON_REVOLVER_MK2", "WEAPON_SNSPISTOL_MK2", "WEAPON_SPECIALCARBINE_MK2", "WEAPON_RAYPISTOL", "WEAPON_RAYCARBINE",
  "WEAPON_RAYMINIGUN", "WEAPON_ASSAULTRIFLE_MK2", "WEAPON_CARBINERIFLE_MK2", "WEAPON_COMBATMG_MK2", "WEAPON_HEAVYSNIPER_MK2",
  "WEAPON_PISTOL_MK2", "WEAPON_SMG_MK2", "WEAPON_FLAREGUN", "WEAPON_VINTAGEPISTOL",
  "WEAPON_FIREWORK", "WEAPON_MUSKET", "WEAPON_MACHINEPISTOL", "WEAPON_COMPACTRIFLE", "WEAPON_DBSHOTGUN",
  "WEAPON_HEAVYSHOTGUN", "WEAPON_MARKSMANRIFLE", "WEAPON_COMBATPDW", "WEAPON_MARKSMANPISTOL", "WEAPON_GUSENBERG"
  
}
local weaponGunsHash = {}
local notWeapons = {
  "WEAPON_UNARMED", "WEAPON_PETROLCAN", "WEAPON_FLASHLIGHT", "WEAPON_BALL", "WEAPON_FIREEXTINGUISHER", "WEAPON_FLARE", "WEAPON_BZGAS"
}
local unarmedHash = GetHashKey("WEAPON_UNARMED")
local emoteWep = GetHashKey("OBJECT")
local showids = false
local wastalking = false
local healthstage = 3 -- 1 = 125hp, 2 = 175hp, 3 = 200hp
local anims = {ain = {onehand = {dict = "reaction@intimidation@1h", anim = "intro"}}, aout = {onehand = {dict = "reaction@intimidation@1h", anim = "outro"}}}
local copanims = {onehand = {dict = "reaction@intimidation@cop@unarmed", anim = "intro"}}
local blockpointing = false
local hideHud = false
local respawns = {
  {pos = vec3(295.847, -1447.291, 29.966), heading = 23.0},
  {pos = vec3(311.194, -579.280, 43.283), heading = 0.0},
  {pos = vec3(-680.834, 313.350, 83.084), heading = 249.0},
  {pos = vec3(1819.303, 3681.959, 34.277), heading = 108.0},
  {pos = vec3(-246.321, 6328.829, 32.426), heading = 230.0}
}
local hideret = true
local jumpRagdollDelay = 5000
local lastJumpTime = 0
local hasJumped = false
local blockjumping = false
local callerId = -1
local voiceInfo = {}
local voiceIds = {}
local spawned = false
local isKeyboard = true -- Used for keyboard exclusive key presses
local use3dAudio = false
local isSpectate = false
local isCop = false
local movementRate = {rate = 1.0, blockSprint = false}
local robbingPlayer = false
local playerInfo = {}

function isArmed(ped)
  -- use weaponNames.name loop
  if (weaponNames) then
    local selwep = GetSelectedPedWeapon(ped)

    for _,v in pairs(notWeapons) do
      if (selwep == GetHashKey(v)) then
        return false
      end
    end

    for _,v in pairs(weaponNames) do
      if (selwep == GetHashKey(v)) then
        return true
      end
    end
    
    return false
  end
end

function isArmedGun(ped)
  if (#weaponGunsHash > 0) then
    local selwep = GetSelectedPedWeapon(ped)

    for i=1,#weaponGunsHash do
      if (selwep == weaponGunsHash[i]) then
        return true
      end
    end
  else
    local iter = 0

    for _,v in pairs(weaponGuns) do
      iter = iter + 1
      weaponGunsHash[iter] = GetHashKey(v)
    end

    return isArmedGun(ped)
  end

  return false
end

function getGsrResult(callback)
  if (callback) then
    callback(firedWeapon)
  end
end

function spinPed()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)

  SetEntityCollision(ped, false)
  FreezeEntityPosition(ped, true)
  ClearPedTasksImmediately(ped)
  SetEntityCoords(ped, pos)

  Wait(100)

  if (not IsEntityVisible(ped)) then
    SetEntityVisible(ped, true)
  end
  SetEntityCollision(ped, true)
  FreezeEntityPosition(ped, false)

  Wait(50)

  SetEntityHealth(ped, 1)
end

function startRespawnTimer()
  diedAt = GetGameTimer()
  stoptimer = false
  
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)

  Citizen.CreateThread(function() -- Fixes camera from damage, shows injury selection
    Wait(3500)
    SetEntityHealth(ped, 1)
    --TriggerEvent("bms:ems:showInjurySelector")
  end)
  
  print(string.format("startRespawnTimer:459, canRespawn: %s, stoptimer: %s, diedAt:%s, gameTime:%s\n", canRespawn, stoptimer, diedAt, GetGameTimer()))

  Citizen.CreateThread(function()
    while (not canRespawn and not stoptimer) do
      Wait(1000)
      
      local curtime = GetGameTimer()
      local diff = GetTimeDifference(curtime, diedAt)

      if (diff >= respawnTimer) then
        canRespawn = true
        print(string.format("startRespawnTimer:472, canRespawn: %s\n", canRespawn))
        TriggerServerEvent("csrp_gamemode:setCanRespawn", true)
        TriggerEvent("chatMessage", "CHAR", {255, 50, 50}, "You can now force respawn by typing \'/respawn\' or wait for EMS.  If you are on an active RP scene, do not respawn.")
        exports.pnotify:SendNotification({text = "Respawn is available."})
      end
    end
    print(string.format("startRespawnTimer:478, canRespawn: %s, stoptimer: %s\n", canRespawn, stoptimer))
  end)

  Citizen.CreateThread(function()
    Wait(10000)

    local isDead = IsEntityDead(ped)

    while (isDead) do
      local ped = PlayerPedId()
      local veh = GetVehiclePedIsIn(ped, false)
      local pos = GetEntityCoords(ped)
      local clp, cld = getClosestAlivePlayer()

      --print(string.format("clp: %s, ped: %s, cld: %s", clp, ped, cld))

      if (IsEntityDead(ped) and GetEntityHealth(ped) <= 1) then
        if (cld < 80 and cld > 5 and clp ~= -1) then -- Check distance is greater than 5 to prevent issues while escorting/doing medical
          if (veh ~= 0) then 
            if (GetEntityHealth(veh) <= 0) then -- if in exploded car
              spinPed()
            end
          else
            spinPed()
          end
        end
      end

      Wait(10000)
      isDead = IsEntityDead(ped)
    end
  end)
end

function selectiveExists(id)
  for _,v in pairs(tickDispSelective) do
    if (v == id) then
      return true
    end
  end
  
  return false
end

function drawText(text) -- centered
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.27, 0.27)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(0.5, 0.9)
end

function drawVoiceText(text, talkcheck) -- right non centered
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.29, 0.29)
  
  if (talkcheck and NetworkIsPlayerTalking(PlayerId())) then
    SetTextColour(240, 20, 20, 205)
  else
    SetTextColour(200, 200, 200, 195)
  end
  
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(0)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(0.9, 0.955)
end

function DrawText3D(x, y, z, color, text) -- some useful function, use it if you want!
  local onScreen,_x,_y = World3dToScreen2d(x, y, z)
  local scale = (0.7 / Vdist(GetGameplayCamCoords(), x, y, z)) * 2
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
   
  if (onScreen) then
    SetTextScale(0.0, 0.55 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(color[1], color[2], color[3], color[4])
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
  end
end

function blockPointing(toggle)
  blockpointing = toggle
end

function startPointing()
  Citizen.CreateThread(function()
    local ped = PlayerPedId()
    ispointing = true
    exports.emotes:blockHandsUp(true)
      
    RequestAnimDict("anim@mp_point")
    
    while not HasAnimDictLoaded("anim@mp_point") do
      Wait(10)
    end
    
    SetPedCurrentWeaponVisible(ped, 0, 1, 1, 1)
    SetPedConfigFlag(ped, 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
  end)
end

function stopPointing()
  local ped = PlayerPedId()
  ispointing = false
  exports.emotes:blockHandsUp(false)
  
  Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
  
  if not IsPedInAnyVehicle(ped, 1) then
    SetPedCurrentWeaponVisible(ped, 1, 1, 1, 1)
  end
  
  SetPedConfigFlag(ped, 36, 0)
  ClearPedSecondaryTask(ped)
end

function blockJumping(toggle)
  blockjumping = toggle
end

function getClosestPlayer()
  local players = GetActivePlayers()
  local closestDistance = -1
  local closestPlayer = -1
  local ped = PlayerPedId()
  local ppos = GetEntityCoords(ped)

  for i=1,#players do
    local target = GetPlayerPed(players[i])

    if (target ~= ped) then
      local tpos = GetEntityCoords(target)
      local dist = #(tpos - ppos)
      
      if (closestDistance == -1 or closestDistance > dist) then
        closestPlayer = players[i]
        closestDistance = dist
      end
    end
  end

  return closestPlayer, closestDistance
end

function getClosestAlivePlayer()
  local players = GetActivePlayers()
  local closestDistance = -1
  local closestPlayer = -1
  local ped = PlayerPedId()
  local ppos = GetEntityCoords(ped)

  for i=1,#players do
    local target = GetPlayerPed(players[i])

    if (target ~= ped) then
      if (GetEntityHealth(target) >= 100) then -- Check that the ped is alive
        local tpos = GetEntityCoords(target)
        local dist = #(tpos - ppos)
        
        if (closestDistance == -1 or closestDistance > dist) then
          closestPlayer = players[i]
          closestDistance = dist
        end
      end
    end
  end

  return closestPlayer, closestDistance
end

function robPlayer()
  local clp, cld = getClosestPlayer()
  
  if (clp and cld < 2.1) then
    local sid = GetPlayerServerId(clp)
    
    if (sid > 0) then
      --TriggerEvent("bms:csrp_gamemode:robPlayer", sid)
      local _, targ = GetEntityPlayerIsFreeAimingAt(PlayerId(), Citizen.ReturnResultAnyway())
            
      if (targ and targ == GetPlayerPed(clp)) then
        local ped = PlayerPedId()

       
        Citizen.CreateThread(function()
          while (not HasAnimDictLoaded("anim@mugging@mugger@catch_1h_gun@")) do
            RequestAnimDict("anim@mugging@mugger@catch_1h_gun@")
            Wait(10)
          end
          
          Wait(500)
          TaskPlayAnim(ped, "anim@mugging@mugger@catch_1h_gun@", "catch_object_pistol_female", 2.0, 2.0, -1, 48, 0, 0, 0, 0)
          robbingPlayer = true 
          Wait(2000)
          robbingPlayer = false
          RemoveAnimDict("anim@mugging@mugger@catch_1h_gun@")
          TriggerServerEvent("bms:csrp_gamemode:checkRobPlayer", sid)
        end)
      else
        exports.pnotify:SendNotification({text = "You must be aiming at someone to rob them."})
      end
    else
      exports.pnotify:SendNotification({text = "No players nearby."})
    end
  end
end

function round(num, numDecimalPlaces) -- returns string
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function toggleShowIds(tog)
  showids = tog
end

function getHealthStage(cb)
  if (cb) then
    cb(healthstage)
  end
end

function setHealthStage(auto, val)
  if (not auto) then
    healthstage = val
  end

  local ped = PlayerPedId()

  if (healthstage == 1) then
    SetEntityMaxHealth(ped, 125)
    SetEntityHealth(ped, 125)
    movementRate.rate = 0.85
  elseif (healthstage == 2) then
    SetEntityMaxHealth(ped, 175)
    SetEntityHealth(ped, 175)
  elseif (healthstage == 3) then
    SetEntityMaxHealth(ped, 200)
    SetEntityHealth(ped, 200)
    movementRate.rate = 1.0
  end
end

function getClosestRespawn()
  local ppos = GetEntityCoords(PlayerPedId())
  local closestSpawnIdx = 1
  local min = math.huge

  for i=1, #respawns do
    local dist = #(ppos.xy - respawns[i].pos.xy) -- only comparing x and y values

    if (dist < min) then
      min = dist
      closestSpawnIdx = i
    end
  end

  return respawns[closestSpawnIdx]
end

function toggleReticule(toggle)
  hideret = not toggle
end

function getVoiceRange()
  return voicemode
end

function normalize(val, min, max)
  return (val - min) / (max - min)
end

function toggle3dAudio(toggle)
  --[[use3dAudio = toggle

  if (use3dAudio) then
    TriggerServerEvent("bms:csrp_gamemode:resetOverrides")
  end]]
end

function toggleSpectate(toggle)
  isSpectate = toggle
end

function setDefaultMovementRate(rate)
  movementRate.rate = rate
end

function blockSprint(toggle)
  movementRate.blockSprint = toggle
end

RegisterNetEvent("bms:csrp_gamemode:resetOverrides")
AddEventHandler("bms:csrp_gamemode:resetOverrides", function(serverIds)
  Wait(1500) -- Wait for the manual voice setting to halt

  for _,v in pairs(serverIds) do
    MumbleSetVolumeOverrideByServerId(v, -1.0)
  end
end)

-- Spawn override
AddEventHandler("onClientMapStart", function()
  Citizen.Trace("called onClientMapStart")
  exports.spawnmanager:setAutoSpawn(true)
  exports.spawnmanager:forceRespawn()

  exports.spawnmanager:setAutoSpawnCallback(function()
    TriggerServerEvent("playerSpawn")
    TriggerEvent("playerSpawn")
  end)
  
  NetworkSetTalkerProximity(defaultRange)
  loadInteriors()
end)

AddEventHandler("bms:csrp_gamemode:setVoice", function(mode)
  local ped = PlayerPedId()

  if (DecorExistOn(ped, "voiceRange")) then
    DecorSetInt(ped, "voiceRange", mode)
  else
    DecorRegister("voiceRange", 3)
    DecorSetInt(ped, "voiceRange", mode)
  end

  if (mode == 0) then
    voicemode = 0
    NetworkSetTalkerProximity(defaultRange)
  elseif (mode == 1) then
    voicemode = 1
    NetworkSetTalkerProximity(whisperRange)
  elseif (mode == 2) then
    voicemode = 2
    NetworkSetTalkerProximity(shoutRange)
  end
end)

RegisterNetEvent("bms:csrp_gamemode:refinteriors")
AddEventHandler("bms:csrp_gamemode:refinteriors", function()
  loadInteriors()
end)

RegisterNetEvent("bms:csrp_gamemode:respawnPlayer")
AddEventHandler("bms:csrp_gamemode:respawnPlayer", function(tats, inPrison)
  --Citizen.Trace("CALLED csrp_gamemode:respawnPlayer")
  if (IsPlayerDead(PlayerId())) then
    local ped = PlayerPedId()
    local respawn = {}

    if (inPrison) then
      local prisonPos = exports.cuff:getPrisonCoords()
      respawn = {x = prisonPos.x, y = prisonPos.y, z = prisonPos.z, h = 0.0}
    else
      local resPos = getClosestRespawn()
      respawn = {x = resPos.pos.x, y = resPos.pos.y, z = resPos.pos.z, h = resPos.heading}
    end

    canRespawn = false
    
    TriggerServerEvent("bms:teleporter:teleportToPoint", ped, respawn)
    NetworkResurrectLocalPlayer(respawn.x, respawn.y, respawn.z, respawn.h, true, true, false)
    ClearPedTasks(ped)
    RemoveAllPedWeapons(ped, true)
    ClearPlayerWantedLevel(PlayerId())
    SetPoliceIgnorePlayer(ped, true)
    SetDispatchCopsForPlayer(ped, false)
    exports.ems:showInjured()
    healthstage = 1
    
    Wait(100)

    if (inPrison) then
      exports.cuff:setPrisonClothes()
    else
      TriggerServerEvent("bms:char:setNormalSkin")
    end
    Wait(100)
    SetPedCanRagdoll(ped, true)

    exports.inventory:blockInventoryOpen(false)
  end
end)

RegisterNetEvent("bms:csrp_gamemode:fixRespawn")
AddEventHandler("bms:csrp_gamemode:fixRespawn", function()
  stoptimer = true
  canRespawn = true
  TriggerServerEvent("csrp_gamemode:setCanRespawn", true)
  TriggerEvent("chatMessage", "CHAR", {255, 50, 50}, "You can now force respawn by typing \'/respawn\' or wait for EMS.  If you are on an active RP scene, do not respawn.")
  exports.pnotify:SendNotification({text = "Respawn is available."})
end)

RegisterNetEvent("bms:csrp_gamemode:setCanRespawn")
AddEventHandler("bms:csrp_gamemode:setCanRespawn", function(val)
  canRespawn = val
  TriggerServerEvent("csrp_gamemode:setCanRespawn", val)
end)

-- Allows the server to spawn the player
RegisterNetEvent("csrp_gamemode:spawnPlayer")
AddEventHandler("csrp_gamemode:spawnPlayer", function(spawnAreas)
  local sarea = spawnAreas[1]

  exports.spawnmanager:spawnPlayer({x = sarea.x, y = sarea.y, z = sarea.z})
  exports.spawnmanager:setAutoSpawn(false)
end)

RegisterNetEvent("bms:playerLoaded")
AddEventHandler("bms:playerLoaded", function()
  local player = PlayerId()
  
  SetPoliceIgnorePlayer(player, true)
  SetDispatchCopsForPlayer(player, false)
  SetPlayerHealthRechargeMultiplier(player, -1.0)
end)

RegisterNetEvent("bms:fixcar")
AddEventHandler("bms:fixcar", function()
  local ped = PlayerPedId()
  
  if (IsPedInAnyVehicle(ped, false) and GetPedInVehicleSeat(GetVehiclePedIsIn(ped, true), -1) == ped) then
    local veh = GetVehiclePedIsIn(ped, true)
    
    SetVehicleFixed(veh)
    SetVehicleDeformationFixed(veh)
    SetVehicleUndriveable(veh, false)
  end
end)

RegisterNetEvent("csrp_gamemode:setPlayerUnconscious")
AddEventHandler("csrp_gamemode:setPlayerUnconscious", function(skinName, numems, bankbalance) 
  local cost = respawnCost
  local ped = PlayerPedId()

  TriggerEvent("bms:playerIncapacitated")
  TriggerEvent("chatMessage", "", {255, 0, 0}, string.format("^1^*You have been incapacitated.  You can force respawn in %s minute(s) or wait for EMS.  You can contact EMS or Police using 911 on your phone (F2).", round(respawnTimer / 60000)))
  
  if (--[[numems > 0 and]] bankbalance > 0) then
    TriggerEvent("chatMessage", "", {255, 0, 0}, string.format("^1^*It will cost you approximately ^2^*$%s^1^* if you choose to respawn.", cost))
  end
  
  -- fix for camera spin
  TriggerServerEvent("bms:ems:addMarkerForDownedPlayer")
  local pos = GetEntityCoords(ped)

  SetPedArmour(ped, 0)
  local inWater, floatUpPosition = GetWaterHeightNoWaves(pos.x, pos.y, pos.z)
  local standingInWater = IsEntityInWater(ped)
  FreezeEntityPosition(ped, true)
  if (floatUpPosition ~= nil and inWater == 1)  then
    TriggerServerEvent("bms:teleporter:teleportToPoint", ped, {x = pos.x, y = pos.y, z = floatUpPosition - 1.2001})
  elseif (standingInWater == 1) then
    TriggerServerEvent("bms:teleporter:teleportToPoint", ped, {x = pos.x, y = pos.y, z = pos.z - 0.5})
  else
    FreezeEntityPosition(ped, false)
  end
  startRespawnTimer()
  exports.inventory:blockInventoryOpen(true)
end)

RegisterNetEvent("bms:csrp_gamemode:stopRespawnTimer")
AddEventHandler("bms:csrp_gamemode:stopRespawnTimer", function()
  stoptimer = true
end)

RegisterNetEvent("bms:csrp_gamemode:setTickDispMode")
AddEventHandler("bms:csrp_gamemode:setTickDispMode", function(mode)
  if (mode and type(mode) == "number") then
    tickDispMode = mode
  end
end)

RegisterNetEvent("bms:csrp_gamemode:setPlayerVisibility")
AddEventHandler("bms:csrp_gamemode:setPlayerVisibility", function(mode)
  if (mode and type(mode) == "number") then
    playerDispMode = mode
    playerDispModeChanged = true
  end
end)

RegisterNetEvent("bms:csrp_gamemode:setTickSelectives")
AddEventHandler("bms:csrp_gamemode:setTickSelectives", function(sellist)
  if (sellist) then
    tickDispSelective = sellist
  end
end)

RegisterNetEvent("bms:csrp_gamemode:checkRobPlayer")
AddEventHandler("bms:csrp_gamemode:checkRobPlayer", function(retid)
  if (retid) then
    local ped = PlayerPedId()
    local cond = IsEntityPlayingAnim(ped, "random@mugging3", "handsup_standing_base", 3) or IsPedFatallyInjured(ped)
    
    TriggerServerEvent("bms:csrp_gamemode:checkRobPlayerResponse", cond, retid)
  end
end)

RegisterNetEvent("bms:csrp_gamemode:robPlayer")
AddEventHandler("bms:csrp_gamemode:robPlayer", function(cond, rid)
  if (cond) then
    if (rid and rid > -1) then
      TriggerServerEvent("bms:csrp_gamemode:robPlayer", rid)
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)
      local hasWeapon, currentPedWeaponHash = GetCurrentPedWeapon(ped)
      local weaponDescription = exports.devtools:getWeaponCrappyDescriptionFromHash(currentPedWeaponHash)
      local accurateDetails
      if (weaponDescription) then
        accurateDetails = string.format("Person was aiming what seemed like a %s", weaponDescription)
      else
        accurateDetails = "Person had a weapon in their hands"
      end
      exports.characters:startReportingCrime({ id = 2, data = {pos = {x = pos.x, y = pos.y, z = pos.z}, accurateDetails = accurateDetails}})
    end
  else
    exports.pnotify:SendNotification({text = "The person you want to rob must have their hands up or be incapacitated in order to be robbed.  Make sure you have a gun on them as well.", timeout = 6000})
  end
end)

RegisterNetEvent("bms:csrp_gamemode:SetWantedLevel")
AddEventHandler("bms:csrp_gamemode:SetWantedLevel", function(level)
  SetPlayerWantedLevel(PlayerId(), level, false)
end)

--TriggerClientEvent("bms:csrp_gamemode:setInstanceCheck", v.source, count, v.activeChar ~= nil)
RegisterNetEvent("bms:csrp_gamemode:setInstanceCheck")
AddEventHandler("bms:csrp_gamemode:setInstanceCheck", function(count, loggedIntoChar)
  --[[if (loggedIntoChar) then
    local playersInInstance = #GetActivePlayers()
    
    if (playersInInstance < count) then
      if (icstrike >= 2) then
        if (not instanceWarned) then
          TriggerEvent("chatMessage", "SERVER", {255, 0, 0}, "^1YOU ARE INSTANCED!!!  You have become instanced and need to relog.  You will be auto kicked in 1 minute.")
          TriggerEvent("chatMessage", "SERVER", {255, 0, 0}, "^1YOU ARE INSTANCED!!!  You have become instanced and need to relog.  You will be auto kicked in 1 minute.")
          TriggerEvent("chatMessage", "SERVER", {255, 0, 0}, "^1YOU ARE INSTANCED!!!  You have become instanced and need to relog.  You will be auto kicked in 1 minute.")
          exports.pnotify:SendNotification({text = "<font color='red'>YOU ARE INSTANCED!!!</font><br><br>You have become instanced and need to relog.  You will be auto kicked in 1 minute.", timeout = 10000})
          instanceWarned = true
        else
          TriggerServerEvent("bms:csrp_gamemode:instanceKickMe")
        end
      else
        icstrike = icstrike + 1
        TriggerServerEvent("bms:serverprint", string.format("%s has %s instance strike(s).", PlayerId(), icstrike))
      end
    end
  end]]
end)

RegisterNetEvent("bms:csrp_gamemode:getrespawntime")
AddEventHandler("bms:csrp_gamemode:getrespawntime", function(rsrc)
  local ped = PlayerPedId()
  local dead = IsEntityDead(ped)

  TriggerServerEvent("bms:csrp_gamemode:showrespawntime", dead, canRespawn, rsrc, GetTimeDifference(GetGameTimer(), diedAt) / 60000, respawnTimer)
end)

-- WELCOME TEXT
AddEventHandler("playerSpawned", function(spawn)
  TriggerEvent("chatMessage", "", { 71, 255, 95 }, "^4Welcome to Los Angeles Public Roleplay")  
  TriggerEvent("chatMessage", "", { 71, 25, 95 }, "^0Type ^1/larphelp ^0if you need help or a guide. For detailed rules, type ^1/rules ^0or visit our ^1forums ^0at ^1" .. forumUrl)
end)

RegisterNetEvent("bms:csrp_gamemode:toggleids")
AddEventHandler("bms:csrp_gamemode:toggleids", function()
  showids = not showids
end)

RegisterNetEvent("bms:csrp_gamemode:cwindowSync")
AddEventHandler("bms:csrp_gamemode:cwindowSync", function(pid, window, dir)
  if (pid) then
    local rpid = GetPlayerFromServerId(pid)

    if (rpid == -1) then return end

    local veh = GetVehiclePedIsIn(GetPlayerPed(rpid))

    if (veh) then
      if (dir == 0) then
        RollDownWindow(veh, window + 1)
      elseif (dir == 1) then
        RollUpWindow(veh, window + 1)
      end
    else
      print("veh was nil ub csrp_gamemode client > 859")
    end
  end
end)

RegisterNetEvent("bms:csrp_gamemode:setMovementRate")
AddEventHandler("bms:csrp_gamemode:setMovementRate", function(rate)
  movementRate.rate = rate
end)

RegisterNetEvent("bms:csrp_gamemode:hideVoiceHud")
AddEventHandler("bms:csrp_gamemode:hideVoiceHud", function(toggle)
  hideHud = toggle
end)

RegisterNetEvent("bms:char:charLoggedIn")
AddEventHandler("bms:char:charLoggedIn", function(user)
  TriggerEvent("bms:csrp_gamemode:setVoice", 0)
  NetworkClearVoiceChannel()
  NetworkSetTalkerProximity(defaultRange)
  spawned = true
end)

RegisterNetEvent("bms:csrp_gamemode:init")
AddEventHandler("bms:csrp_gamemode:init", function(serverIds)
  TriggerEvent("bms:csrp_gamemode:setVoice", 0)
  NetworkClearVoiceChannel()
  NetworkSetTalkerProximity(defaultRange)
  spawned = true

  Wait(250)

  for _,v in pairs(serverIds) do -- Attempt to stop from hearing everyone upon login
    MumbleSetVolumeOverrideByServerId(v, 0.0)
  end

  Wait(250)

  for _,v in pairs(serverIds) do -- Attempt to stop from hearing everyone upon login
    MumbleSetVolumeOverrideByServerId(v, -1.0)
  end
end)

RegisterNetEvent("bms:csrp_gamemode:setincall")
AddEventHandler("bms:csrp_gamemode:setincall", function(serverId)
  if (serverId > 0) then
    callerId = serverId
  end
end)

RegisterNetEvent("bms:csrp_gamemode:endcall")
AddEventHandler("bms:csrp_gamemode:endcall", function()
  MumbleSetVolumeOverrideByServerId(callerId, -1.0)
  callerId = -1
end)

-- GSR
Citizen.CreateThread(function()
  local waitTime = 10000
  local ped = 0

  while true do
    Wait(waitTime) -- 10000
    local ped = playerInfo.ped

    if (firedWeapon) then
      gsrElapsed = gsrElapsed + 10000
      
      if (gsrElapsed >= gsrTimeout or IsPedSwimmingUnderWater(ped)) then
        gsrElapsed = 0
        firedWeapon = false
      end
    end
  end
end)

-- thread to decrement the timer initiated when you try to swap weapons in a vehicle
Citizen.CreateThread(function()
  local waitTime = 100

  while true do
    Wait(waitTime) -- 100

    -- Car weapon swapping timer
    if (carSwapPress > 0) then
      carSwapPress = carSwapPress - 100
    end

    -- Talking icon
    if (NetworkIsPlayerTalking(PlayerId())) then
      if (not wastalking) then
        SendNUIMessage({task = "talkchange", talking = true})
        wastalking = true
      end
    else
      if (wastalking) then
        SendNUIMessage({task = "talkchange", talking = false})
        wastalking = false
      end
    end
  end
end)

Citizen.CreateThread(function()
  local waitTime = 1
  --StartAudioScene('CHARACTER_CHANGE_IN_SKY_SCENE') --Disable Ambient Noises
  while true do
    Wait(waitTime) -- 1
    HideHudComponentThisFrame(3) -- hide native cash/bank
    HideHudComponentThisFrame(4) -- hide native cash/bank
    HideHudComponentThisFrame(13) -- hide native cash/bank
    HideHudComponentThisFrame(1) -- hide wanted stars
	  HideHudComponentThisFrame(9) -- hides native street name text
    HideHudComponentThisFrame(7) -- hides native area name text
    
    if (hideret) then
      HideHudComponentThisFrame(14) -- hide reticule
    end

    if (not hideHud) then
      if (voicemode == 0) then
        drawVoiceText("Voice: Default", false)
      elseif (voicemode == 1) then
        drawVoiceText("Voice: Whisper", true)
      elseif (voicemode == 2) then
        drawVoiceText("Voice: Shout", false)
      end
    end

    if (robbingPlayer) then
      --DisableAimCamThisUpdate()
      DisableControlAction(0, 25, true)
    end
  end
end)



Citizen.CreateThread(function()
  local waitTime = 1

  while true do
    Wait(waitTime) -- 1
    
    if (movementRate.rate < 1.0 and movementRate.blockSprint) then
      SetPedMoveRateOverride(playerInfo.ped, movementRate.rate)
      DisableControlAction(0, 21, true)
    else
      SetPedMoveRateOverride(playerInfo.ped, movementRate.rate)
    end
  end
end)

-- Run in a separate thread to see if it fixes issues with blocking main thread
Citizen.CreateThread(function()
  Wait(5000)

  for _,v in pairs(scenarios) do
    SetScenarioTypeEnabled(v, false)
  end

  local waitTime = 1
  local pos = vec3(0, 0, 0)

  while true do
    Wait(waitTime) -- 1
    
    pos = playerInfo.pos

    ClearAreaOfCops(pos.x, pos.y, pos.z, 1500.0, 0)
  end
end)

Citizen.CreateThread(function()
  local waitTime = 1
  local ped = 0
  local pos = vec3(0, 0, 0)
  local playerId = 0

  while true do
    Wait(waitTime) -- 1
        
    ped = PlayerPedId()
    pos = GetEntityCoords(ped)
    playerId = PlayerId()
    playerInfo.ped = ped
    playerInfo.pos = pos
    playerInfo.playerId = playerId

    SetPlayerHealthRechargeMultiplier(playerId, -1.0)
    
    if (IsPedShooting(ped) and isArmedGun(ped)) then
      gsrElapsed = 0
      firedWeapon = true
    end
    
    if (IsPedDeadOrDying(ped)) then
      local ttr = respawnTimer - (GetTimeDifference(GetGameTimer(), diedAt))

      --print(string.format("TimeToRes: %s", ttr))

      if (ttr > 0) then
        if (ttr < 60000) then
          drawText("Less than a minute remaining until respawn.")
        else
          drawText(string.format("%s minutes remaining until respawn.", round(math.ceil(ttr / 60000))))
        end
      else
        drawText("You can now respawn by typing /respawn or wait for EMS.")
      end
      
      SetPedCanRagdoll(ped, false)
      
      while (not HasAnimDictLoaded("dead")) do
        RequestAnimDict("dead")
        Wait(5)
      end
      
      if (IsEntityPlayingAnim(ped, "dead", "dead_e", 3)) then
        ClearPedSecondaryTask(ped)
      else
        TaskPlayAnim(ped, "dead", "dead_e", 1.0, 0.0, -1, 9, 9, 1, 1, 1)
      end      

      GivePlayerRagdollControl(playerId, false)
    end

    if (showids) then
      local players = GetActivePlayers()

      if (tickDispMode == 1) then
        for i=1,#players do
          local nped = GetPlayerPed(players[i])
          local npos = GetEntityCoords(nped)          
          local dist = #(pos - npos)
        
          if (dist < 15) then
            local sid = GetPlayerServerId(players[i])

            if (NetworkIsPlayerTalking(players[i])) then
              DrawText3D(npos.x, npos.y, npos.z + 1.1, {0, 127, 255, 255}, tostring(sid))
            else
              DrawText3D(npos.x, npos.y, npos.z + 1.1, {200, 200, 200, 255}, tostring(sid))
            end
          end
        end
      elseif (tickDispMode == 2) then
        for i=1,#players do
          local nped = GetPlayerPed(players[i])
          local npos = GetEntityCoords(nped)          
          local dist = #(pos - npos)
          
          if (dist < 15) then
            local sid = GetPlayerServerId(players[i])
            
            if (ped ~= nped) then
              if (NetworkIsPlayerTalking(players[i])) then
                DrawText3D(npos.x, npos.y, npos.z + 1.1, {0, 127, 255, 255}, tostring(sid))
              else
                DrawText3D(npos.x, npos.y, npos.z + 1.1, {200, 200, 200, 255}, tostring(sid))
              end
            end
          end
        end
      elseif (tickDispMode == 3) then
        for i=1,#players do
          local nped = GetPlayerPed(players[i])
          local npos = GetEntityCoords(nped)          
          local dist = #(pos - npos)

          if (tickDispSelective and #tickDispSelective > 0) then
            local sid = GetPlayerServerId(players[i])
            
            if (selectiveExists(sid)) then
              if (NetworkIsPlayerTalking(players[i])) then
                DrawText3D(npos.x, npos.y, npos.z + 1.1, {0, 127, 255, 255}, tostring(sid))
              else
                DrawText3D(npos.x, npos.y, npos.z + 1.1, {200, 200, 200, 255}, tostring(sid))
              end
            end
          else -- failsafe for an empty selectives list
            tickDispMode = 1
          end
        end
      elseif (tickDispMode == 4) then
        local sid = GetPlayerServerId(playerId)
        
        if (NetworkIsPlayerTalking(playerId)) then
          DrawText3D(pos.x, pos.y, pos.z + 1.1, {0, 127, 255, 255}, tostring(sid))
        else
          DrawText3D(pos.x, pos.y, pos.z + 1.1, {200, 200, 200, 255}, tostring(sid))
        end
      end
    end
    
    if (ispointing) then
      local camPitch = GetGameplayCamRelativePitch()
      
      if (camPitch < -70.0) then
        camPitch = -70.0
      elseif (camPitch > 42.0) then
        camPitch = 42.0
      end
      
      camPitch = (camPitch + 70.0) / 112.0

      local camHeading = GetGameplayCamRelativeHeading()
      local cosCamHeading = Cos(camHeading)
      local sinCamHeading = Sin(camHeading)
      
      if (camHeading < -180.0) then
        camHeading = -180.0
      elseif (camHeading > 180.0) then
        camHeading = 180.0
      end
      
      camHeading = (camHeading + 180.0) / 360.0

      local blocked = 0
      local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
      local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2, 0.4, 95, ped, 7);
      
      _,blocked,_,_ = GetRaycastResult(ray)

      Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
      Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
      Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
      Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)
    end

    -- Ragdoll for spacebar spamming
    if (IsPedJumping(ped)) then
      if (not hasJumped and not IsPedClimbing(ped)) then
        local currentTime = GetGameTimer()
        local difference = currentTime - lastJumpTime
        hasJumped = true

        if (difference < jumpRagdollDelay) then
          SetPedToRagdoll(ped, 1500, 1500, 0, 0, 0, 0)
        end

        lastJumpTime = currentTime
      end
    else
      if (hasJumped) then
        hasJumped = false
      end
    end

    if (blockjumping == true) then
      DisableControlAction(0, 22, true)
    else
      EnableControlAction(0, 22, true)
    end

    if (not canFire) then
      DisablePlayerFiring(ped, false)
    end
  end
end)

Citizen.CreateThread(function()
  local animTimeout = 0
  local waitTime = 1
  local ped = 0
  local pedInVeh = false

  while true do
    Wait(waitTime) -- 1

    ped = playerInfo.ped
    pedInVeh = IsPedInAnyVehicle(ped, false)

    if (IsPedUsingActionMode(ped)) then -- Disables twitchy movements after shooting weapons
      SetPedUsingActionMode(ped, false, -1, 0)
    end

    if (showWepSwitch) then
      local curwephash = GetSelectedPedWeapon(ped)
      
      if (not pedInVeh) then
        if (lastWeapon ~= curwephash) then
          local isArmed = isArmed(ped)

          if (isArmed and lastWeapon == 0) then
            lastWeapon = curwephash
          elseif (isArmed and curwephash ~= lastWeapon) then
            TriggerEvent("bms:csrp_gamemode:weaponSwitching", curwephash)
            SetCurrentPedWeapon(ped, lastWeapon, true)

            if (isCop) then
              animTimeout = 0

              RequestAnimDict(copanims.onehand.dict)
              while (not HasAnimDictLoaded(copanims.onehand.dict) and animTimeout < 20) do
                Wait(50)
                animTimeout = animTimeout + 1
              end

              TaskPlayAnim(ped, copanims.onehand.dict, copanims.onehand.anim, 0.5, -8, -1, 50, 0, 0, 0, 0)
            else
              animTimeout = 0

              RequestAnimDict(anims.ain.onehand.dict)
              while (not HasAnimDictLoaded(anims.ain.onehand.dict) and animTimeout < 20) do
                Wait(50)
                animTimeout = animTimeout + 1
              end

              TaskPlayAnim(ped, anims.ain.onehand.dict, anims.ain.onehand.anim, 0.5, -8, -1, 50, 0, 0, 0, 0)
            end
            
            canFire = false

            SetTimeout(3000, function()
              ClearPedSecondaryTask(ped)
              SetCurrentPedWeapon(ped, curwephash, true)
              lastWeapon = curwephash
              canFire = true
            end)
          -- checks that the ped is not armed, the last weapon is not unarmed, and the current weapon is not the emote prop
          elseif (not isArmed and lastWeapon ~= unarmedHash and curwephash ~= emoteWep) then
            lastWeapon = curwephash
          end
        end
      else
        -- check to see if weapon wheeel is pressed inside the car
        if (IsControlJustPressed(0, 261) or IsControlJustPressed(0, 37)) then
          carSwapPress = 1500
          carSwap = true
        end
        if (lastWeapon ~= curwephash) then
          local isArmed = isArmed(ped)

          if (isArmed and lastWeapon == 0) then
            lastWeapon = curwephash
          elseif (isArmed and curwephash ~= lastWeapon) then
            -- check if carSwap timer has expired and carSwap was pressed
            if (carSwapPress == 0 and carSwap) then
              TriggerEvent("bms:csrp_gamemode:weaponSwitching", curwephash)
              carSwap = false

              if (isCop) then
                animTimeout = 0
  
                RequestAnimDict(copanims.onehand.dict)
                while (not HasAnimDictLoaded(copanims.onehand.dict) and animTimeout < 20) do
                  Wait(50)
                  animTimeout = animTimeout + 1
                end
  
                TaskPlayAnim(ped, copanims.onehand.dict, copanims.onehand.anim, 0.5, -8, -1, 50, 0, 0, 0, 0)
              else
                animTimeout = 0
  
                RequestAnimDict(anims.ain.onehand.dict)
                while (not HasAnimDictLoaded(anims.ain.onehand.dict) and animTimeout < 20) do
                  Wait(50)
                  animTimeout = animTimeout + 1
                end
  
                TaskPlayAnim(ped, anims.ain.onehand.dict, anims.ain.onehand.anim, 0.5, -8, -1, 50, 0, 0, 0, 0)
              end

              canFire = false

              SetTimeout(3000, function()
                ClearPedSecondaryTask(ped)
                SetCurrentPedWeapon(ped, curwephash, true)
                lastWeapon = curwephash
                canFire = true
              end)
            end
          -- checks that the ped is not armed, the last weapon is not unarmed, and the current weapon is not the emote prop
          elseif (not isArmed and lastWeapon ~= unarmedHash and curwephash ~= emoteWep) then
            -- check if carSwap timer has expired and carSwap was pressed
            if (carSwapPress == 0 and carSwap) then
              carSwap = false
              lastWeapon = curwephash
              SetCurrentPedWeapon(ped, curwephash, true)
            end
          end
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  local waitTime = 75
  local pos = vec3(0, 0, 0)

  while true do
    Wait(waitTime)

    if (not use3dAudio) then
      pos = playerInfo.pos

      for i=1,#voiceInfo do
        local dist

        if (isSpectate) then
          dist = #(pos.xy - GetEntityCoords(voiceInfo[i].ped).xy)
        else
          dist = #(pos - GetEntityCoords(voiceInfo[i].ped))
        end
              
        if (dist <= voiceInfo[i].range) then
          local norm = normalize(dist, voiceInfo[i].range, 0.0)
          norm = norm * norm

          if (voicemode == 1) then -- whisper
            if (dist < whisperRange) then -- whisper
              MumbleSetVolumeOverride(voiceInfo[i].player, norm)
            elseif (dist < defaultRange) then -- default
              MumbleSetVolumeOverride(voiceInfo[i].player, norm / 3)
            elseif (dist < shoutRange) then -- shout
              MumbleSetVolumeOverride(voiceInfo[i].player, norm / 8)
            end
          elseif (voicemode == 0) then -- default
            if (dist < defaultRange) then -- default
              MumbleSetVolumeOverride(voiceInfo[i].player, norm)
            elseif (dist < shoutRange) then -- shout
              MumbleSetVolumeOverride(voiceInfo[i].player, norm / 3)
            end
          else
            MumbleSetVolumeOverride(voiceInfo[i].player, norm)
          end
        else
          MumbleSetVolumeOverride(voiceInfo[i].player, 0.0)
        end
      end
    end

    if (callerId and callerId > 0) then
      MumbleSetVolumeOverrideByServerId(callerId, 1.0)
    end

    local armed, curWep = GetCurrentPedWeapon(playerInfo.ped)

    if (armed) then
      local wepDmgType = GetWeaponDamageType(curWep)
      
      if (curWep ~= unarmedHash and wepDmgType ~= 2) then
        SetPlayerLockon(playerInfo.playerId, false)
      else
        SetPlayerLockon(playerInfo.playerId, true)
      end
    end
  end
end)

Citizen.CreateThread(function()
  local waitTime = 1500
  local pos = vec3(0, 0, 0)
  local playerId = 0

  while true do
    Wait(waitTime)

    pos = playerInfo.pos
    playerId = playerInfo.playerId
    local players = GetActivePlayers()
    local vInfo = {}
    local vIds = {}
    local oldVoiceIds = {}
    local iter = 0
    
    EnableDispatchService(3, false) -- Fire Trucks
    EnableDispatchService(5, false) -- Ambulances
    InvalidateIdleCam() -- Supposed to disable cinematic "afk" camera effect.
    InvalidateVehicleIdleCam()

    if (not spawned) then
      voiceInfo = {}
      NetworkSetTalkerProximity(0.0000001)
    else
      if (not use3dAudio) then
        for player,serverid in pairs(voiceIds) do
          oldVoiceIds[player] = serverid
        end

        for i=1,#players do
          if (players[i] ~= playerId) then
            local pped = GetPlayerPed(players[i])
            local dist
            
            if (isSpectate) then
              dist = #(pos.xy - GetEntityCoords(pped).xy)
            else
              dist = #(pos - GetEntityCoords(pped))
            end
    
            if (dist < 80) then
              local voicerange = DecorGetInt(pped, "voiceRange")
              local range = whisperRange
    
              if (voicerange == 0) then
                range = defaultRange
              elseif (voicerange == 1) then
                range = whisperRange
              elseif (voicerange == 2) then
                range = shoutRange
              end
    
              iter = iter + 1
              vInfo[iter] = {range = range, ped = pped, player = players[i]}
              vIds[players[i]] = GetPlayerServerId(players[i])
            else
              MumbleSetVolumeOverride(players[i], 0.0)
            end
          end
        end
        
        voiceIds = vIds
        voiceInfo = vInfo

        for player,serverid in pairs(oldVoiceIds) do
          if (not vIds[player]) then
            MumbleSetVolumeOverrideByServerId(serverid, 0.0)
          end
        end
      end

      isCop = exports.lawenforcement:isPlayerOnDutyCop()
    end
  end
end)

-- Voice Range
RegisterCommand("-toggleVoiceRange", function()
  voicemode = voicemode + 1

  if (voicemode > 2) then
    voicemode = 0
  end

  TriggerEvent("bms:csrp_gamemode:setVoice", voicemode)
end)
RegisterKeyMapping("-toggleVoiceRange", "Toggle Voice Range", "keyboard", "F1")

-- Pointing
RegisterCommand("+point", function()
  if (not blockpointing) then
    startPointing()
  end
end)

RegisterCommand("-point", function()
  if (not blockpointing) then
    stopPointing()
  end
end)
RegisterKeyMapping("+point", "Point", "keyboard", "Y")

-- Roll Windows Up
RegisterCommand("-windowsUp", function()
  local ped = PlayerPedId()
  local pedInVeh = IsPedInAnyVehicle(ped, false)

  -- window up/down sync
  if (pedInVeh) then
    local veh = GetVehiclePedIsIn(ped)
    local seat = -1
    
    for i = -1, GetVehicleMaxNumberOfPassengers(veh) do
      if (GetPedInVehicleSeat(veh, i) == ped) then
        seat = i
        break
      end
    end

    if (seat >= -1) then
      TriggerServerEvent("bms:csrp_gamemode:windowSync", seat, 1)
    end
  end
end)
RegisterKeyMapping("-windowsUp", "Roll Windows Up", "keyboard", "UP")

-- Roll Windows Down
RegisterCommand("-windowsDown", function()
  local ped = PlayerPedId()
  local pedInVeh = IsPedInAnyVehicle(ped, false)

  -- window up/down sync
  if (pedInVeh) then
    local veh = GetVehiclePedIsIn(ped)
    local seat = -1
    
    for i = -1, GetVehicleMaxNumberOfPassengers(veh) do
      if (GetPedInVehicleSeat(veh, i) == ped) then
        seat = i
        break
      end
    end

    if (seat >= -1) then
      TriggerServerEvent("bms:csrp_gamemode:windowSync", seat, 0)
    end
  end
end)
RegisterKeyMapping("-windowsDown", "Roll Windows Down", "keyboard", "DOWN")

-- Rob Player
RegisterCommand("-robPlayer", function()
  local ped = PlayerPedId()
  local pedInVeh = IsPedInAnyVehicle(ped, false)

  if (not pedInVeh) then
    robPlayer()
  end
end)
RegisterKeyMapping("-robPlayer", "Rob Player", "keyboard", "F10")
