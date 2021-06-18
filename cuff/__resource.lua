resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

ui_page "html/cuff.html"

files {
  "html/cuff.html",
  "html/cuff.css",
  "html/cuff.js",
  "html/jqueryui/jquery-ui.structure.min.css",
  "html/jqueryui/jquery-ui.theme.min.css",
  "html/images/hex-background.png"
}

client_scripts {
  "cl_cuff.lua",
  "zipties_cl.lua",
  "trpositions_cl.lua"
}
server_scripts {
  "sv_cuff.lua",
  "zipties_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}

exports {
  "toggleCuffedBlockers",
  "isCuffed",
  "getCuffState",
  "isPlayerInPrison",
  "setIsOnDutyCop",
  "setIsDocOnDuty",
  "getPrisonCoords",
  "setPrisonClothes"
}
