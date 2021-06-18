resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"
data_file "DLC_ITYP_REQUEST" "stream/props.ytyp"

files {
  "html/jobs.html",
  "html/jobs.css",
  "html/jobs.js",
  "html/jqueryui/jquery-ui.theme.min.css",
  "html/jqueryui/jquery-ui.structure.min.css",
  "html/jqueryui/bootstrap-input-spinner.js",
  "html/images/hex-background.png",
  "html/images/fishicon.png",
  "html/images/cp_background.png",
  "html/images/auto_on.png",
  "html/images/auto_off.png",
  "html/images/grass.png",
  --"html/images/harvestweed.png",
  "html/images/biohazard.png"
}

ui_page "html/jobs.html"

server_scripts {
  --"taxi/taxi_sv.lua",
  "drugdealer/dealer_sv.lua",
  "drugdealer/cocaine_sv.lua",
  "delivery/delivery_sv.lua",
  "delivery/delivery_jobs.lua",
  "streetdealing/sd_server.lua",
  "hunting/hunting_server.lua",
  "hunting/animals_sv.lua",
  "fishing/fishing_sv.lua",
  "robberies/robbery_sv.lua",
  "trucking/trucking_sv.lua",
  "mecanic/mecanic_sv.lua",
  "publicworks/publicworks_server.lua",
  "prisonwork/prisonwork_sv.lua",
  "transit/transit_sv.lua",
  "mining/mining_sv.lua",
  "meth/meth_sv.lua",
  "factions/lawyer_sv.lua",
  "factions/psych_sv.lua",
  --"counterfeiting/counterfeit_sv.lua",
  "woodcutting/woodcutting_sv.lua",
  "tacotruck/tacotruck_sv.lua",
  "publicworks/sanitation_sv.lua",
  "news/news_sv.lua",
  "diving/diving_sv.lua",
  "shipwreck/shipwreck_sv.lua",
  "weedfarms/weedfarms_sv.lua",
  "mushroomfarms/mushrooms_sv.lua",
  "weedfarms/seedinventory_sv.lua",
  "robberies/jewelry_sv.lua",
  "lawncare/lawncare_sv.lua",
  "globals_sv.lua",
  "@inventory/storagelimits_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}

client_scripts {
  --"taxi/taxi_cl.lua",
  "drugdealer/dealer_cl.lua",
  "drugdealer/cocaine_cl.lua",
  "delivery/delivery_cl.lua",
  "streetdealing/sd_client.lua",
  "streetdealing/dealerassault_cl.lua",
  "hunting/hunting_client.lua",
  "hunting/animals.lua",
  "fishing/fishing_cl.lua",
  "robberies/robbery_cl.lua",
  "trucking/trucking_cl.lua",
  "mecanic/mecanic_cl.lua",
  "publicworks/publicworks_client.lua",
  "prisonwork/prisonwork_cl.lua",
  "transit/transit_cl.lua",
  "realestate/realestate_cl.lua",
  "mining/mining_cl.lua",
  "meth/meth_cl.lua",
  "factions/lawyer_cl.lua",
  "factions/psych_cl.lua",
  --"counterfeiting/counterfeit_cl.lua",
  "woodcutting/woodcutting_cl.lua",
  "tacotruck/tacotruck_cl.lua",
  "publicworks/sanitation_cl.lua",
  "news/news_cl.lua",
  "diving/diving_cl.lua",
  "shipwreck/shipwreck_cl.lua",
  "weedfarms/weedfarms_cl.lua",
  "weedfarms/seedinventory_cl.lua",
  "weedfarms/growregions.lua",
  "mushroomfarms/mushrooms_cl.lua",
  "robberies/jewelry_cl.lua",
  "lawncare/lawncare_cl.lua",
  "globals_cl.lua"
}

server_exports {
  "resetRobberyTimer",
  "sendCounterfeitLocation",
  "getMethDealerInfo",
  "checkMiningMaxCap",
  "getCokeBrickPrice",
  "getWeedBulkDealerInfo",
  "remAddInventoryCatItem",
  "addInventoryCatItem",
  "checkFaction",
  "checkFactionUser",
  "registerRepairSpot",
  "broadcastRepSpots"
}

exports {
  "isNearWeedFarm",
  "getAlcoholLevel",
  "draw3DTextGlobal",
  "drawTextGlobal",
  "isGameControlPressed",
  "applyTunerChanges",
  "showProgressBar",
  "hideProgressBar",
  "spawnVehicleGlobal",
  "spawnObjectGlobal",
  "spawnPedGlobal"
}
