resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

ui_page "html/boats.html"

files {
  "html/boats.html",
  "html/boats.css",
  "html/boats.js",
  "data/vehicles.meta",
  "data/carvariations.meta",
  "data/carcols.meta",
  "data/handling.meta"
}

client_scripts {
  "boats_cl.lua"
}

server_scripts {
  "boats_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}

data_file "HANDLING_FILE" "data/handling.meta"
data_file "VEHICLE_METADATA_FILE" "data/vehicles.meta"
data_file "CARCOLS_FILE" "data/carcols.meta"
data_file "VEHICLE_VARIATION_FILE" "data/carvariations.meta"