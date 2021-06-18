fx_version "cerulean"
game "gta5"

ui_page "html/gaming.html"

files{
  "html/gaming.html",
  "html/gaming.css",
  "html/gaming.js",
  "html/cards.js",
  "html/cards.css",
  "html/cards/*",
  "html/images/*",
  "html/js/slots/*"
}

client_scripts{
  "gaming_cl.lua",
  "slots_cl.lua",
  "luckywheel_cl.lua"
}

server_scripts{
  "gaming_sv.lua",
  "slots_sv.lua",
  "luckywheel_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}