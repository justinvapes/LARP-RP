-- No teleports until the meadows building is opened

--[[local pblipSpots = {
  {x = 315.851, y = -1623.469, z = 32.532, desc = "Psychiatrist"}
}
local psychBlips = {}

function setupPsychBlips()
  for _,v in pairs(pblipSpots) do
    local blip = AddBlipForCoord(v.x, v.y, v.z)

    SetBlipSprite(blip, 351)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 45)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(v.desc)
    EndTextCommandSetBlipName(blip)
    
    table.insert(psychBlips, blip)
  end
end

RegisterNetEvent("bms:jobs:psych:setupteleports")
AddEventHandler("bms:jobs:psych:setupteleports", function()
  --exports.teleporter:addTeleporter("Rehab Center", {x = 241.211, y = -415.321, z = -118.199}, {x = 240.188, y = -306.967, z = -118.801}, false, {r = 255, g = 255, b = 0})
end)

Citizen.CreateThread(function()
  while true do
    Wait(1000)

    if (#psychBlips == 0) then
      setupPsychBlips()
    end
  end
end)]]