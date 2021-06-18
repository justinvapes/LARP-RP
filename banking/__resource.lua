resource_manifest_version "77731fab-63ca-442c-a67b-abc70f28dfa5"

ui_page "html/banking.html"

exports {
  "resetRobTimer",
  "addMoneyToAccount",
  "removeMoneyFromAccount"
}

files {
  "html/jqueryui/jquery-ui.theme.min.css",
  "html/jqueryui/jquery-ui.structure.min.css",
  "html/images/*",
  "html/banking.html",
  "html/banking.css",
  "html/banking.js"
}

client_scripts {
  "banking_client.lua"
}
server_scripts {
  "banking_server.lua",
  "bankaccounts_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}
