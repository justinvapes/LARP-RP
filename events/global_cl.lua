playerInfo = {}

Citizen.CreateThread(function()
  while true do
    Wait(1)

    playerInfo.playerPedId = PlayerPedId()
    playerInfo.pos = GetEntityCoords(playerInfo.playerPedId)
    playerInfo.curVeh = GetVehiclePedIsIn(playerInfo.playerPedId, false)
  end
end)
