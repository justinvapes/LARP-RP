resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

client_scripts{
  "global_cl.lua",
  "parachuting/parachuting_cl.lua",
  "basejumping/basejumping_cl.lua",
  --"halloween/zombieevent_cl.lua",
  "fireworks/fireworks_cl.lua",
  "golf/golf_cl.lua",
  "soccer/soccer_cl.lua"
}

server_scripts{
  "parachuting/parachuting_sv.lua",
  "basejumping/basejumping_sv.lua",
  --"halloween/zombieevent_sv.lua",
  "fireworks/fireworks_sv.lua",
  "golf/golf_sv.lua",
  "soccer/soccer_sv.lua"
}

ui_page "html/golf.html"

files { 
  "html/golf.html",
  "html/golf.css",
  "html/golf.js",
  --"data/peds.meta",
}

data_file "PED_METADATA_FILE" "data/peds.meta"