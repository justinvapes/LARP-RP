resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

ui_page "html/charcreator.html"

client_script "cc_client.lua"
server_scripts{
  "cc_server.lua",
  "@mysql-async/lib/MySQL.lua"
}

files { 
  "html/charcreator.html",
  "html/charcreator.js",
  "html/charcreator.css",
  "html/images/arrow_left.png",
  "html/images/arrow_right.png",
  "html/images/cc_body.png",
  "html/images/cc_clothing.png",
  "html/images/cc_hairmakeup.png",
  "html/images/cycle_cameras.png",
  "html/images/female.png",
  "html/images/male.png",
  "html/images/load_slot.png",
  "html/images/save_slot.png",
  "html/images/revert_alldef.png",
  "html/images/revert_part.png",
  "html/images/hide_component.png",
  "html/images/select_slot.png",
  "html/pdown.ttf"
}

exports{
  "getLastComps",
  "setIsDoc",
  "registerCloset",
  "clearRegisteredClosets"
}
