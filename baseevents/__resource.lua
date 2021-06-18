resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

client_scripts{
  "deathevents_cl.lua",
  "vehiclechecker.lua",
  "triggervolumes_cl.lua"
}
exports{
  "registerTriggerVolume",
  "unregisterTriggerVolume"
}
server_scripts{
  "deathevents_sv.lua",
  "server.lua"
}