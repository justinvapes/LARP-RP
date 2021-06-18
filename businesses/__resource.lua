resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

ui_page "html/businesses.html"

exports{
  "getPlayerStationNearCoords"
}

server_exports{
  "isMechEmployee",
  "getStationFuelInfo"
}

files{
  "html/businesses.html",
  "html/businesses.css",
  "html/businesses.js",
  "html/images/hex-background.png",
  "html/images/sizer.png"
}

client_scripts{
  "businesses_cl.lua",
  "pawnshop_cl.lua",
  "fuel_cl.lua",
  --"scrapyard_cl.lua",
  "mechanic_cl.lua",
  "recycle_cl.lua"
}
server_scripts{
  "businesses_sv.lua",
  "pawnshop_sv.lua",
  "fuel_sv.lua",
  --"scrapyard_sv.lua",
  "mechanic_sv.lua",
  "recycle_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}
