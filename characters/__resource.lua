fx_version "cerulean"
games {"gta5"}

server_scripts{
  "characters_sv.lua",
  "carryped_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}
client_scripts {
  "characters_cl.lua",
  "knockout_c.lua",
  "carryped_cl.lua"
}

ui_page "chardialog.html"

files {
  "chardialog.html",
  "chardialog.css",
  "chardialog.js",
  "pdown.ttf"
}

exports {
  "getSpawnArea",
  "addWitnessPed",
  "startReportingCrime",
  "doBandageSelf"
}

server_exports {
  "updateInventory",
  "findUserSourceByChar",
  "giveMoneyToChar",
  "giveDirtyMoneyToChar",
  "takeMoneyFromChar",
  "takeDirtyMoneyFromChar",
  "giveMoneyToCharBank",
  "takeMoneyFromCharBank",
  "getAutoIncomeAmount",
  "payCharacterFine",
  "removeItemFromInventory",
  "getCrimeReportFromId",
  "getPlayerListSinceStart",
  "addLoginMessageByName",
  "addUserToGroup",
  "getClosestPlayerServer",
  "getAdminIds",
  "getModIds",
  "getPlayerCarriedByPlayer",
  "cancelCarryForCarryingPlayer"
}
