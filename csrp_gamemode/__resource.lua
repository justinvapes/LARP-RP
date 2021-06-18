resource_type "gametype" { name = "CSRP_Map" }

-- Manifest
resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

-- Requiring essentialmode
dependency "essentialmode"

ui_page "html/csrpgamemode.html"

files {
  "html/csrpgamemode.html",
  "html/csrpgamemode.js",
  "html/csrpgamemode.css",
  "html/voiceover.png",
  "data/handling.meta"
}

exports {
  "getGsrResult",
  "toggleShowIds",
  "getHealthStage",
  "setHealthStage",
  "blockPointing",
  "blockJumping",
  "revivePlayer",
  "toggleReticule",
  "getVoiceRange",
  "isArmedGun",
  "toggle3dAudio",
  "toggleSpectate",
  "setDefaultMovementRate",
  "blockSprint"
}

-- General
client_scripts {
  "client.lua",
  "addobjects_cl.lua",
  --"pdamage_cl.lua",
}

server_scripts {
  "skinsmaster.lua",
  "server.lua",
  --"pdamage_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}

data_file "VEHICLE_METADATA_FILE" "data/handling.meta"
