resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

exports {
  "doEmoteById",
  "getProp",
  "setCanEmote",
  "doStanceById",
  "doExpressionById",
  "objectScannerToggle",
  "blockHandsUp",
  "getCurrentProp",
  "getCurrentForcedProp",
  "blockPointing",
  "blockCrouch"
}

client_scripts{
  "client.lua",
  "chairs_cl.lua",
  "props_cl.lua",
  "propslist_cl.lua",
  "handsup_cl.lua",
  "propemote_c.lua",
  "crouch_cl.lua"
}
server_scripts{
  "server.lua",
  "emotes.lua",
  "propemote_s.lua",
  "props_sv.lua"
}