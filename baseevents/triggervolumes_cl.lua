local volumes = {}
local volcount = 0
local checkdelay = 500

function registerTriggerVolume(pos, radius, cbInEvent, cbOutEvent, exdata)
  volcount = volcount + 1
  volumes[volcount] = {pos = pos, radius = radius, cbInEvent = cbInEvent, cbOutEvent = cbOutEvent, exdata = exdata}

  return volcount
end

function unregisterTriggerVolume(volid)
  if (volumes[volid]) then
    volumes[volid] = nil
  end
end

function findPlayerNearVolume(pos)
  local players = GetPlayers()

  for i, player in ipairs(players) do
    local ped = GetPlayerPed(player)
    local plpos = GetEntityCoords(ped)

    for _,v in pairs(volumes) do
      local vpos = v.pos
      local dist = #(plpos - vpos)

      if (dist < v.radius) then
        return player
      end
    end
  end
end

Citizen.CreateThread(function()
  while true do
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if (DoesEntityExist(ped)) then
      for k,v in pairs(volumes) do
        local dist = #(pos - v.pos)

        if (dist < v.radius and not v.triggered) then
          v.triggered = true
          
          if (type(v.cbInEvent) == "string") then
            TriggerEvent(v.cbInEvent, {pos = v.pos, radius = v.radius, volid = k, exdata = v.exdata})
          else
            v.cbInEvent({pos = v.pos, radius = v.radius, volid = k, exdata = v.exdata})
          end
        elseif (dist >= v.radius and v.triggered) then
          v.triggered = false

          if (type(v.cbOutEvent) == "string") then
            TriggerEvent(v.cbOutEvent, {pos = v.pos, radius = v.radius, volid = k, exdata = v.exdata})
          else
            v.cbOutEvent({pos = v.pos, radius = v.radius, volid = k, exdata = v.exdata})
          end
        end
      end
    end

    Wait(checkdelay)
  end
end)