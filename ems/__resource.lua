resource_manifest_version "05cfa83c-a124-4cfa-a768-c24a5811d8f9"

ui_page "html/ems.html"

files{
  "html/ems.html",
  "html/ems.css",
  "html/ems.js",
  "html/images/injured.png",
  "html/jquery.pulsate.js",
  "html/jqueryui/jquery-ui.min.js",
  "html/jqueryui/jquery-ui.theme.min.css",
  "html/jqueryui/jquery-ui.structure.min.css",
  "html/images/xrayhuman.png",
  "html/images/xrayselregion.png",
  "data/vehicles.meta",
  "data/carcols.meta",
  "data/carvariations.meta",
  "data/handling.meta",
  "html/images/injurysys/*.gif"
}

server_scripts {
  "server.lua",
  "firedept_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}
client_scripts {
  "client.lua",
  "vehicles.lua",
  "damagedetector.lua",
  "firedept_cl.lua"
}

exports {
  "addEmsBlip",
  "clearEmsBlips",
  "isPlayerOnDutyEms",
  "showInjured"
}

server_exports{
  "getEmsIds"
}

data_file "DLC_ITYP_REQUEST" "stream/emsprops.ytyp"
data_file "HANDLING_FILE" "data/handling.meta"
data_file "VEHICLE_METADATA_FILE" "data/vehicles.meta"
data_file "CARCOLS_FILE" "data/carcols.meta"
data_file "VEHICLE_VARIATION_FILE" "data/carvariations.meta"