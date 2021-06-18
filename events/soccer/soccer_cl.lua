local DrawMarker = DrawMarker

local objects = {
  -- Goals
  {pos = vec3(-1755.444, 179.020, 63.371), prop = "prop_goal_posts_01", heading = 35.25},
  {pos = vec3(-1725.998, 137.559, 63.371), prop = "prop_goal_posts_01", heading = 35.25},
  -- Walls
  {pos = vec3(-1747.654, 184.478, 62.750), prop = "prop_const_fence01b", heading = 35.25},
  {pos = vec3(-1757.129, 177.796, 62.750), prop = "prop_const_fence01b", heading = 35.25},
  {pos = vec3(-1759.621, 174.845, 62.750), prop = "prop_const_fence01b", heading = 65.25},
  {pos = vec3(-1760.274, 170.977, 62.750), prop = "prop_const_fence01b", heading = 95.25},
  {pos = vec3(-1744.043, 185.825, 62.750), prop = "prop_const_fence01b", heading = 5.25},
  {pos = vec3(-1740.189, 185.170, 62.750), prop = "prop_const_fence01b", heading = 335.25},
  {pos = vec3(-1718.284, 142.967, 62.750), prop = "prop_const_fence01b", heading = 215.25},
  {pos = vec3(-1727.688, 136.363, 62.750), prop = "prop_const_fence01b", heading = 215.25},
  {pos = vec3(-1731.368, 135.003, 62.750), prop = "prop_const_fence01b", heading = 185.25},
  {pos = vec3(-1735.264, 135.709, 62.750), prop = "prop_const_fence01b", heading = 155.25},
  {pos = vec3(-1740.656, 141.610, 62.750), prop = "prop_const_fence03b", heading = 125.25},
  {pos = vec3(-1747.444, 151.251, 62.750), prop = "prop_const_fence03b", heading = 125.25},
  {pos = vec3(-1756.599, 164.052, 62.750), prop = "prop_const_fence03b", heading = 125.25},
  {pos = vec3(-1751.979, 157.621, 62.750), prop = "prop_const_fence01b", heading = 126.0},
  {pos = vec3(-1715.773, 145.922, 62.750), prop = "prop_const_fence01b", heading = 245.25},
  {pos = vec3(-1715.152, 149.734, 62.750), prop = "prop_const_fence01b", heading = 275.25},
  {pos = vec3(-1718.755, 156.649, 62.750), prop = "prop_const_fence03b", heading = 305.25},
  {pos = vec3(-1725.689, 166.470, 62.750), prop = "prop_const_fence03b", heading = 305.25},
  {pos = vec3(-1732.652, 176.255, 62.750), prop = "prop_const_fence03b", heading = 305.25},
  {pos = vec3(-1737.218, 182.681, 62.750), prop = "prop_const_fence01b", heading = 305.25},
  -- Lighting
  {pos = vec3(-1760.800, 173.053, 63.371), prop = "prop_streetlight_01b", heading = 80.0},
  {pos = vec3(-1733.431, 134.316, 63.371), prop = "prop_streetlight_01b", heading = 170.0},
  {pos = vec3(-1741.997, 186.433, 63.371), prop = "prop_streetlight_01b", heading = 350.0},
  {pos = vec3(-1714.455, 147.671, 63.371), prop = "prop_streetlight_01b", heading = 260.0},
  -- Stands
  {pos = vec3(-1757.700, 163.149, 63.371), prop = "prop_portasteps_02", heading = 125.25},
  {pos = vec3(-1740.364, 138.896, 63.371), prop = "prop_portasteps_02", heading = 125.25},
  -- Center Light
  {pos = vec3(-1737.686, 160.351, 63.325), prop = "prop_air_lights_03a", heading = 0.0},
  {pos = vec3(-1732.561, 163.523, 63.330), prop = "prop_start_finish_line_01", rot = vec3(5.0, 0.0, 35.25)},
  {pos = vec3(-1742.138, 156.775, 63.329), prop = "prop_start_finish_line_01", rot = vec3(5.0, 0.0, 35.25)},
  --stt_prop_stunt_soccer_sball
}
local goals = { -- Shared between client and server
  [1] = {
    marker = vec3(-1722.728, 139.350, 63.371),
    color = {r = 255, g = 92, b = 68},
    goal = {pos1 = vec3(-1725.998, 137.559, 63.371), pos2 = vec3(-1719.894, 141.794, 63.371)}
  },
  [2] = {
    marker = vec3(-1752.674, 181.541, 63.371),
    color = {r = 152, g = 200, b = 255},
    goal = {pos1 = vec3(-1755.444, 179.020, 63.371), pos2 = vec3(-1749.375, 183.269, 63.371)}
  }
}
local goalMarkers = {}
local centerPos = {
  {pos = vec3(-1737.686, 160.351, 64.325)},
}
local centerMarkers = {}
local blips = {}
local bounds = {
  {
    pos1 = vec3(-1738.628, 193.564, 64.371), 
    pos2 = vec3(-1705.058, 145.412, 64.390), 
    pos3 = vec3(-1735.945, 123.418, 64.402), 
    pos4 = vec3(-1770.016, 171.642, 64.401)
  }
}
local games = {
  {
    playing = false,
    score = {[1] = 0, [2] = 0}
  }
}
local blockInput = false
local superKick = false
local inField = 0
local ballHash = GetHashKey("stt_prop_stunt_soccer_sball")
local maxGameTime = 7 * 60 * 1000 -- msecs
local superKickTime = 10000

--TriggerEvent("bms:devtools:areaDrawDebug", goals[2].goal.pos1, goals[2].goal.pos2)
--TriggerEvent("bms:devtools:areaDrawDebug", goals[1].goal.pos1, goals[1].goal.pos2)

local function checkSlopeBounds(pos1, pos2)
  -- slope = (Y2 - Y1) / (X2 - X1)
  return ((pos2.y - pos1.y) / (pos2.x - pos1.x))
end

--[[ 
  These points should be properly sent to be in order, otherwise, this will return garbage 
  +: Most positive value, -: Most negative value
  pos1: -x, +y
  pos2: +x, +y
  pos3: +x, -y
  pos4: -x, -y
]]
local function isPosInRectangularArea(pos, pos1, pos2, pos3, pos4, debugDraw)
  if (debugDraw) then
    TriggerEvent("bms:devtools:areaDrawDebug", pos1, pos2)
    TriggerEvent("bms:devtools:areaDrawDebug", pos2, pos3)
    TriggerEvent("bms:devtools:areaDrawDebug", pos3, pos4)
    TriggerEvent("bms:devtools:areaDrawDebug", pos4, pos1)
  end

  local slope1 = checkSlopeBounds(pos1, pos2) -- pos1 -> pos2
  local slope2 = checkSlopeBounds(pos2, pos3) -- pos2 -> pos3
  local slope3 = checkSlopeBounds(pos3, pos4) -- pos3 -> pos4
  local slope4 = checkSlopeBounds(pos4, pos1) -- pos4 -> pos1

  if (pos.y < ((pos.x - pos1.x) * slope1) + pos1.y) then -- Y = (X - xInt)*slope + yInt
    if (pos.x < ((pos.y - pos2.y) / slope2 + pos2.x)) then -- X = (Y - yInt)/slope + xInt
      if (pos.y > ((pos.x - pos3.x) * slope3) + pos3.y) then -- Y = (X - xInt)*slope + yInt
        if (pos.x > ((pos.y - pos4.y) / slope4 + pos4.x)) then -- X = (Y - yInt)/slope + xInt
          return true
        end
      end
    end
  end

  return false
end

function drawScoreText(text, x, y)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.45, 0.45)
  SetTextColour(255, 255, 255, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y)
end

AddEventHandler("onResourceStop", function(res)
  if (res == GetCurrentResourceName()) then
    for _,v in pairs(objects) do
      if (v.spawnedProp) then
        DeleteEntity(v.spawnedProp)
      end
    end
  end
end)

RegisterNetEvent("bms:events:soccer:toggleGame")
AddEventHandler("bms:events:soccer:toggleGame", function(idx, playing)
  if (playing) then
    games[idx].score = {[1] = 0, [2] = 0}
    games[idx].startTime = GetGameTimer()
  end

  games[idx].playing = playing
end)

RegisterNetEvent("bms:events:soccer:spawnBall")
AddEventHandler("bms:events:soccer:spawnBall", function(idx)
  local ball = CreateObject(ballHash, centerPos[idx].pos, true, true, true)
  local netId = NetworkGetNetworkIdFromEntity(ball)

  PlaceObjectOnGroundProperly(ball)
  blockInput = false

  TriggerServerEvent("bms:events:soccer:sendBall", idx, netId)
end)

RegisterNetEvent("bms:events:soccer:updateScore")
AddEventHandler("bms:events:soccer:updateScore", function(idx, score)
  games[idx].score = score

  if (inField == idx) then
    --PlaySoundFrontend(-1, "Goal", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
    PlaySoundFrontend(-1, "Countdown_GO", "DLC_AW_Frontend_Sounds", true)
    --PlaySoundFrontend(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", 1)
  end
end)

RegisterNetEvent("bms:events:soccer:notifyGameEnd")
AddEventHandler("bms:events:soccer:notifyGameEnd", function(idx, score, timeout)
  if (inField == idx) then
    local msg = string.format("Game over! Final score: <font color='red'>Team 1:</font> %s | <font color='skyblue'>Team 2:</font> %s", score[1], score[2])

    if (timeout) then
      msg = msg .. "\nTime limit reached!"
    end

    exports.pnotify:SendNotification({text = msg})
  end
end)

RegisterNetEvent("bms:events:soccer:superKick")
AddEventHandler("bms:events:soccer:superKick", function(netId, fVec)
  local ball = NetworkGetEntityFromNetworkId(netId)
  local ballPos = GetEntityCoords(ball)

  TriggerServerEvent("bms:soundmgr:playSoundWithinDist", 50.0, "DLCSTUNT_SOCCER_BALL_LARGE_IMPACT_02", -1, ballPos)
  --[[RequestScriptAudioBank("DLC_STUNT/STUNT_RACE_01", false, -1)
  PlaySoundFromEntity(GetSoundId(), "SOCCER_BALL_LARGE_IMPACT_02", ball, "DLC_Stunt_Race_Alarms_Soundset", 0, 0)]]
  ApplyForceToEntity(ball, 2, fVec.x * 1750, fVec.y * 1750, 0.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local ped = playerInfo.playerPedId
    local pos = playerInfo.pos

    for _,v in pairs(goalMarkers) do
      DrawMarker(4, v.marker.x, v.marker.y, v.marker.z + 1.5, 0, 0, 0, 0.0, 0.0, 35.25, 7.25, 7.25, 5.0, v.color.r, v.color.g, v.color.b, 100, 0, 0, 0, 0, 0, 0, 0)
    end

    for _,v in pairs(centerMarkers) do
      if (not games[v.idx].playing) then
        DrawMarker(1, v.pos.x, v.pos.y, v.pos.z - 1.2, 0, 0, 0, 0, 0, 0, 2.5, 2.5, 0.4, 120, 255, 70, 150, 0, 0, 0, 0, 0, 0, 0)

        if (v.dist < 20) then
          local dist = #(pos - v.pos)

          if (dist < 2.5) then
            drawScreenText("Press ~b~[E]~s~ to start a game of soccer for ~g~$1000~s~.")

            if (not blockInput) then
              if (IsControlJustReleased(1, 38)) then
                blockInput = true
                TriggerServerEvent("bms:events:soccer:startGame", v.idx)
              end
            end
          end
        end
      end
    end

    if (inField > 0 and games[inField].playing) then
      SetCurrentPedWeapon(ped, 0xA2719263, true)
      DisableControlAction(0, 24, true) -- INPUT_ATTACK
      DisablePlayerFiring(ped, true) -- Disable weapon firing
      DisableControlAction(0, 140, true) -- INPUT_MELEE_ATTACK_LIGHT
      DisableControlAction(0, 141, true) -- INPUT_MELEE_ATTACK_HEAVY
      DisableControlAction(0, 142, true) -- INPUT_MELEE_ATTACK_ALTERNATE

      drawScoreText("~r~Team 1~s~: " .. games[inField].score[1] .. " | ~b~Team 2~s~: " .. games[inField].score[2], 0.4995, 0.035)
      local time = (games[inField].startTime + maxGameTime - GetGameTimer()) / 1000
      local mins = string.format("%02.f", math.floor(time / 60));
      local secs = string.format("%02.f", math.floor(time - mins * 60));
      drawScoreText(mins .. ":" .. secs, 0.4995, 0.075)

      if (not superKick and IsDisabledControlJustReleased(0, 24)) then
        for _,obj in pairs(GetGamePool("CObject")) do
          if (GetEntityModel(obj) == ballHash) then
            local ballPos = GetEntityCoords(obj)
            local dist = #(pos - ballPos)

            if (dist < 2.25) then
              superKick = true
              local fVec = GetEntityForwardVector(ped)
              local netId = NetworkGetNetworkIdFromEntity(obj)

              TriggerServerEvent("bms:events:soccer:superKick", inField, netId, fVec)
              break
            end
          end
        end

        SetTimeout(superKickTime, function()
          superKick = false
        end)
      end
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1500)

    local pos = playerInfo.pos

    --PlaySoundFrontend(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", false)
    --PlaySoundFrontend(-1, "Countdown_GO", "DLC_AW_Frontend_Sounds", true)
    
    for i=1,#objects do
      local dist = #(pos - objects[i].pos)

      if (dist < 100) then
        if (not objects[i].spawnedProp) then
          local hash = GetHashKey(objects[i].prop)
          RequestModel(hash)
          while (not HasModelLoaded(hash)) do
            Wait(10)
          end
          
          local obj = CreateObject(hash, objects[i].pos, false, true, false)
          while (not DoesEntityExist(obj)) do
            Wait(10)
          end
          FreezeEntityPosition(obj, true)

          if (objects[i].heading) then
            SetEntityHeading(obj, objects[i].heading)
          elseif (objects[i].rot) then
            SetEntityRotation(obj, objects[i].rot, 1, true)
          end
          SetModelAsNoLongerNeeded(hash)
    
          objects[i].spawnedProp = obj
        end
      elseif (objects[i].spawnedProp) then
        DeleteObject(objects[i].spawnedProp)
        objects[i].spawnedProp = nil
      end
    end

    local iter = 0
    local gMarkers = {}

    for i=1,#goals do
      local dist = #(pos - goals[i].marker)

      if (dist < 100) then
        iter = iter + 1
        gMarkers[iter] = goals[i]
      end
    end

    goalMarkers = gMarkers

    iter = 0
    local cMarkers = {}

    for i=1,#centerPos do
      local dist = #(pos - centerPos[i].pos)

      if (dist < 100) then
        iter = iter + 1
        cMarkers[iter] = centerPos[i]
        cMarkers[iter].idx = i
        cMarkers[iter].dist = dist
      end
    end

    centerMarkers = cMarkers

    if (#blips == 0) then
      for _,v in pairs(centerPos) do
        local blip = AddBlipForCoord(v.pos)

        SetBlipSprite(blip, 590)
        SetBlipScale(blip, 0.85)
        SetBlipColour(blip, 4)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Soccer Field")
        EndTextCommandSetBlipName(blip)

        table.insert(blips, blip)
      end
    end

    local inBounds = false

    for i=1,#bounds do
      if (isPosInRectangularArea(pos, bounds[i].pos1, bounds[i].pos2, bounds[i].pos3, bounds[i].pos4)) then
        inField = i
        inBounds = true
        break
      end
    end

    if (not inBounds) then
      inField = 0
    end
  end
end)
