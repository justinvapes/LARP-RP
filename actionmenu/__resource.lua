resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

exports {
  "addAction",
  "removeAction",
  "changeAction",
  "addCategory",
  "removeCategory",
  "hideCategory",
  "showCategory",
  "toggleZActionMenu",
  "toggleBlockMenu"
}

server_scripts {
  "am_server.lua"
}
client_scripts {
  "am_client.lua"
}

ui_page "html/actionmenu.html"

files {
  "html/actionmenu.html",
  "html/actionmenu.css",
  "html/actionmenu.js",
  "html/amlogo.png",
  "html/images/*"
}