local DrawMarker = DrawMarker
local table_insert = table.insert
local baseSpots = {
  {pos = vec3(501.617, 5604.761, 797.910)},
  {pos = vec3(-1623.312, -3154.565, 13.992), hideBlip = true},
  {pos = vec3(-707.629, -1460.774, 5.001), hideBlip = true}
}
local baseMarkers = {}
local blockPress = false
local baseBlips = {}

local function drawBaseJumpText(x, y, z, text, sc)
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

RegisterNetEvent("bms:basejumping:rentparachute")
AddEventHandler("bms:basejumping:rentparachute", function(data)
  if (data) then
    local success = data.success

    if (success) then
      local ped = PlayerPedId()

      GiveWeaponToPed(ped, GetHashKey("GADGET_PARACHUTE"), 1, 0, false)
      exports.pnotify:SendNotification({text = "You have rented a parachute.  Press <font color='skyblue'>Primary-Attack</font> to deploy it once you have jumped."})
    else
      local msg = data.msg

      exports.pnotify:SendNotification({text = msg})
    end
  end

  blockPress = false
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    for _, marker in pairs(baseMarkers) do
      DrawMarker(1, marker.pos.x, marker.pos.y, marker.pos.z - 1.2, 0, 0, 0, 0, 0, 0, 1.2, 1.2, 0.4, 137, 207, 240, 50, 0, 0, 0, 0, 0, 0, 0)

      if (marker.dist < 10) then
        local dist = #(playerInfo.pos - marker.pos)

        if (dist < 0.6) then
          --drawScreenText("Press [~b~E~w~] to rent a parachute.  This will cost ~g~$1000~s~")
          drawBaseJumpText(marker.pos.x, marker.pos.y, marker.pos.z + 0.25, "Press [~b~E~w~] to rent a parachute.  This will cost ~g~$1000~s~", 0.31)

          if (not blockPress) then
            if (IsControlJustReleased(1, 38)) then
              blockPress = true
              TriggerServerEvent("bms:basejumping:rentparachute")
            end
          end
        end
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(3000)

    local pos = playerInfo.pos

    if (#baseBlips == 0) then
      for _,v in pairs(baseSpots) do
        if (not v.hideBlip) then
          local blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)

          SetBlipSprite(blip, 94)
          SetBlipScale(blip, 0.85)
          SetBlipColour(blip, 3)
          SetBlipAsShortRange(blip, true)
          BeginTextCommandSetBlipName("STRING")
          AddTextComponentString("Base Jumping")
          EndTextCommandSetBlipName(blip)
          table_insert(baseBlips, blip)
        end
      end
    end

    local iter = 0
    local bMarkers = {}

    for i=1,#baseSpots do
      local dist = #(pos - baseSpots[i].pos)

      if (dist < 65) then
        bMarkers[i] = baseSpots[i]
        bMarkers[i].dist = dist
      end
    end

    baseMarkers = bMarkers
  end
end)
