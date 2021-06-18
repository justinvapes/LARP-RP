resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

client_scripts{
  "client.lua"
}
server_scripts {
  "connectqueue/connectqueue.lua",
  "connectqueue/server/sv_queue_config.lua",
  "connectqueue/server/sv_queue.lua",
  "connect_utils.lua",
  "@mysql-async/lib/MySQL.lua"
}
server_exports{
  "getQueueSize",
  "getQueueData"
}