local table_insert = table.insert

function drawTextGlobal(text, x, y, sx, sy, center)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(sx or 0.32, sy or 0.32)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(center or 1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
end

function draw3DTextGlobal(x, y, z, text, sc)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, sc or 0.55 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
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

function isGameControlPressed(cgroup, ckey) -- This is also worthless
  return IsControlJustReleased(cgroup, ckey)
end

function getClosestPlayer()
  local players = GetActivePlayers()
  local closestDistance = -1
  local closestPlayer = -1
  local ped = PlayerPedId()
  local ppos = GetEntityCoords(ped)

  for i=1,#players do
    local target = GetPlayerPed(players[i])

    if (target ~= ped) then
      local tpos = GetEntityCoords(target)
      local dist = #(tpos - ppos)
      
      if (closestDistance == -1 or closestDistance > dist) then
        closestPlayer = players[i]
        closestDistance = dist
      end
    end
  end

  return closestPlayer, closestDistance
end

function showProgressBar(title, maxval, progval)
  SendNUIMessage({updateJobProgress = true, title = title, maxvalue = maxval, progvalue = progval})
end

function hideProgressBar()
  SendNUIMessage({hideJobProgress = true})
end

function spawnVehicleGlobal(pos, model, networked)
  local hash = GetHashKey(model)
  
  while (not HasModelLoaded(hash)) do
    RequestModel(hash)
    Wait(10)
  end

  local v = CreateVehicle(hash, pos.x, pos.y, pos.z, pos.heading, networked, false)

  SetModelAsNoLongerNeeded(hash)

  if (networked) then
    return v, VehToNet(v)
  else
    return v
  end
end

function spawnObjectGlobal(pos, model, networked)
  local hash = GetHashKey(model)
  
  while (not HasModelLoaded(hash)) do
    RequestModel(hash)
    Wait(10)
  end

  local o = CreateObject(hash, pos.x, pos.y, pos.z, networked, false)
  SetModelAsNoLongerNeeded(hash)

  return o
end

function spawnPedGlobal(pos, heading, hash, networked)
  while (not HasModelLoaded(hash)) do
    RequestModel(hash)
    Wait(10)
  end

  local p = CreatePed(4, hash, pos.x, pos.y, pos.z, heading, networked)
  
  SetModelAsNoLongerNeeded(hash)

  if (networked) then
    return p, PedToNet(p)
  else
    return p
  end
end
