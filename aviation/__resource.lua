resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

client_scripts{
  "cropduster/cropduster_cl.lua",
  "delivery/planedelivery_cl.lua",
  "vip/planevip_cl.lua",
  "aviation_global.lua"
}
server_scripts{
  "cropduster/cropduster_sv.lua",
  "delivery/planedelivery_sv.lua",
  "vip/planevip_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}