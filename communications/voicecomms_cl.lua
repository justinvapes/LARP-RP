local showvoiceicon = true
local showownicon = false
local voiceiconcol = {r = 0, g = 125, b = 255, a = 210}
local nearbyPlayers = {}

function setShowVoiceIcon(val)
  showvoiceicon = val
end

function setShowOwnIcon(val)
  showownicon = val
end

function setVoiceIconColor(col)
  voiceiconcol = col
end

function Draw3DVText(x, y, z, text, col)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, 0.55 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    -- SetTextScale(0.0, 0.55)
    SetTextColour(col.r, col.g, col.b, col.a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
  end
end

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local pos = GetEntityCoords(PlayerPedId())

    if (showvoiceicon) then      
      for _,v in pairs(nearbyPlayers) do
        if (NetworkIsPlayerTalking(v.id)) then
          local ped = GetPlayerPed(v.id)
          local npos = GetEntityCoords(ped)
          local dist = #(pos - npos)

          if (dist < 15) then
            Draw3DVText(npos.x, npos.y, npos.z + 1.0, "...", voiceiconcol)
          end
        end
      end
    end

    if (showownicon) then
      if (NetworkIsPlayerTalking(PlayerId())) then
        Draw3DVText(pos.x, pos.y, pos.z + 1.0, "...", voiceiconcol)
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(5000)

    local players = GetActivePlayers()
    local pos = GetEntityCoords(PlayerPedId())
    local nPlayers = {}
    local iter = 0
    local pId = PlayerId()

    for i=1,#players do
      if (players[i] ~= pId) then
        local ppos = GetEntityCoords(GetPlayerPed(players[i]))
        local dist = #(pos - ppos)

        if (dist < 50) then
          iter = iter + 1
          nPlayers[iter] = {dist = dist, id = players[i]}
        end
      end
    end

    nearbyPlayers = nPlayers
  end
end)
