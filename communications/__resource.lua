--resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"
resource_manifest_version "05cfa83c-a124-4cfa-a768-c24a5811d8f9"

exports {
  "sendDiscordAlert",
  "setShowVoiceIcon",
  "setShowOwnIcon",
  "setVoiceIconColor",
  "notifyPhone",
  "clear911Calls",
  "getVchan",
  "setPaypalBalance",
  "gpsTrackEntity",
  "gpsUntrack",
  "removeCamAccessBlips",
  "canUsePhone",
  "canToggleTilde"
}

server_exports{
  "addToLeoTextRadio",
  "sendDiscordGamestreamAlert",
  "sendDiscordAdminAlert",
  "sendDiscordCheatAlert",
  "sendDiscordAdminAlertElevated",
  "sendDiscordSstAlert",
  "sendDiscordAdminChat",
  "sendDiscordMoneyAlert",
  "sendDiscordExchangeAlert",
  "sendDiscordHarvestLogAlert",
  "sendDiscordAviationAlert",
  "sendDiscordLeoDutyAlert",
  "sendExplosionsLog",
  "sendDevTestLog",
  "sendRconResponse",
  "getMdcChallenge",
  "removeSubscribedBlips",
  "addSubscribedBlips",
  "removeAnkleMonitorBlip",
  "addAnkleMonitorBlip",
  "getSsDest",
  "sendEmailFromServer"
}

ui_page "html/comms.html"

files {
  "html/backgrounds/*",
  "html/selfieimages/*",
  "html/apps/hs-icons/*",
  "html/apps/weather-icons/*",
  "html/dispatch/*",
  "html/comms.html",
  "html/comms.css",
  "html/comms.js",
  "html/comms_e911.js",
  "html/cellphone.png",
  "html/cp_addcon.png",
  "html/cp_cancelcon.png",
  "html/cp_back_hl.png",
  "html/callphone.png",
  "html/delcontact.png",
  "html/addcontact.png",
  "html/iocall.png",
  "html/answer.png",
  "html/cancel.png",
  "html/notepad_bg.png",
  "html/texticon.png",
  "html/backbutton.png",
  "html/backbutton2.png",
  "html/homebutton.png",
  "html/textperson.png",
  "html/blockperson.png",
  "html/blockperson_active.png",
  "html/weatherscreen1.png",
  "html/text_notify.png",
  "html/textperson_alert.png",
  "html/lapdlogo.png",
  "html/expand.png",
  "html/expandbar.png",
  "html/paypals.png",
  "html/twitter-logo.png",
  "html/gta-map-med.png",
  "html/gps-pin-red.png",
  "html/mechanic_header.png",
  "html/carmax.png",
  "html/contact_in.png",
  "html/contact_out.png",
  "html/selfieReturnPhone.png",
  "html/ucam.png"
}

client_scripts {
  "comms_client.lua",
  "voicecomms_cl.lua",
  "camerasystem_cl.lua",
  --"signaljammer_cl.lua", disabled for now, there are some security implications
  "phoneshop_cl.lua",
  "phone_cl.lua",
  "phonecamera_cl.lua"
}
server_scripts {
   "comms_server.lua",
   "voicecomms_sv.lua",
   "phone_sv.lua",
   "webmdc_comms_sv.lua",
   "blipmanager_sv.lua",
   --"signaljammer_sv.lua",
   "phoneshop_sv.lua",
   "js/e911handler.js",
   "@mysql-async/lib/MySQL.lua"
}

data_file "DLC_ITYP_REQUEST" "stream/cellprops.ytyp"