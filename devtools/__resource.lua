resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

--ui_page "devtools.html" disabled temporarily

--[[files{
  "html/*"
}]]

exports {
  "isPlayerK9",
  "dump",
  "getWeaponCrappyDescriptionFromHash",
  "getWeaponNameFromHash",
  "tableRemove",
  "getObjectDetected"
}
server_exports {
  "addToDisciplinary",
  "permban",
  "dump"
} 

shared_script "shared.lua"
client_scripts {
  "client.lua",
  "acam_cl.lua",
  "reverse_weapon_hashes.lua",
  --"animtester_cl.lua",
  --"animations.lua",
  --"scenarios_cl.lua",
  --"overlays.lua",
  --"timecycles.lua",
  --"pfxtester_cl.lua",
  --"pfx.lua",
  --"trackmaker_cl.lua"
}
server_scripts {
  "server.lua",
  "acam_sv.lua",
  "@mysql-async/lib/MySQL.lua",
  --"animtester_sv.lua",
  --"wrcon_notifier.lua",
  --"pfxtester_sv.lua",
  --"pfx.lua",
  --"trackmaker_sv.lua",
}