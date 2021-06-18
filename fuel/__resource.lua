resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

exports {
  "getVehicleFuelLevel",
  "vehicleFuelLevel",
  "setVehicleFuelLevel",
  "isModelElectric"
}

client_scripts {
  "larpfuel_cl.lua",
  "gasstations.lua"
}

server_scripts {
  "larpfuel_sv.lua",
  "gasstations_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}

server_export "getGasStations"
