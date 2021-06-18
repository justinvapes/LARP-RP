resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

client_scripts {
	"hud.lua"
}

ui_page "html/hud.html"

files { 
  "html/hud.html",
  "html/hud.css",
  "html/hud.js",
  "html/images/seatbelt.png",
  "html/images/checkengine.png",
  "html/images/lowfuel.png",
}

exports {
  "toggleVitals",
  "updateVitals"
}
