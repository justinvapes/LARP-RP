resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

ui_page "html/blackmarket.html"

server_exports{
  "getWeapons",
  "getWeaponByHash"
}

files {
  "html/blackmarket.html",
  "html/blackmarket.css",
  "html/blackmarket.js",
  "html/ammo_sm.png"
}

client_script "blackmarket_cl.lua"
server_scripts {
  "blackmarket_sv.lua",
  "@inventory/storagelimits_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}