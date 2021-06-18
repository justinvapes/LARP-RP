fx_version "cerulean"
games {"gta5"}

ui_page "html/inventory2.html"

client_scripts{
  "inventory2_cl.lua"
}

server_scripts{
  "handlers_sv.lua",
  "inventory2_sv.lua",
  "@mysql-async/lib/MySQL.lua",
  "@inventory/storagelimits_sv.lua"
}

files{
  "html/*"
}