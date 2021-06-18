local blipSpots = {
  {x = 315.851, y = -1623.469, z = 32.532, desc = "Court House"}
}
local lawyerBlips = {}

function setupLawyerBlips()
  for _,v in pairs(blipSpots) do
    local blip = AddBlipForCoord(v.x, v.y, v.z)

    SetBlipSprite(blip, 351)
    SetBlipScale(blip, 1.0)
    SetBlipAsShortRange(blip, true)
    SetBlipColour(blip, 45)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(v.desc)
    EndTextCommandSetBlipName(blip)
    
    table.insert(lawyerBlips, blip)
  end
end

Citizen.CreateThread(function()
  while true do
    Wait(1000)

    if (#lawyerBlips == 0) then
      setupLawyerBlips()
    end
  end
end)
