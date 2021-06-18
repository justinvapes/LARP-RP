-- /teleport -1359.61267, 149.90988, 56.346
local table_insert = table.insert
local DrawMarker = DrawMarker

--[[
  hole: hole number
  par: par of the hole
  startPos: tee off area for the hole
  holePos: position of the hole
  mapPos: adjustment to view the hole on the minimap
  mapAngle: angle to rotate the minimap to view the course
  mapZoom: zoom on the minimap for the course
]]
local holes = {
  [1] = {hole = 1, par = 5, startPos = vec3(-1371.337, 173.094, 57.013),  holePos = vec3(-1114.127, 220.792, 63.894), mapPos = {x = -1262.5, y = 110.0},  mapAngle = 255, mapZoom = 850},
  [2] = {hole = 2, par = 4, startPos = vec3(-1107.188, 156.581, 62.039),  holePos = vec3(-1322.084, 158.777, 56.800), mapPos = {x = -1192.5, y = 250.0},  mapAngle = 75, mapZoom = 850},
  [3] = {hole = 3, par = 3, startPos = vec3(-1312.102, 125.832, 56.434),  holePos = vec3(-1237.417, 112.983, 56.201), mapPos = {x = -1282.5, y = 75.0},   mapAngle = 255, mapZoom = 200},
  [4] = {hole = 4, par = 4, startPos = vec3(-1216.913, 106.987, 57.039),  holePos = vec3(-1096.547, 7.840, 49.735),   mapPos = {x = -1172.5, y = -10.0},  mapAngle = 255, mapZoom = 600},
  [5] = {hole = 5, par = 4, startPos = vec3(-1097.859, 66.414, 52.925),   holePos = vec3(-957.378, -90.405, 39.275),  mapPos = {x = -1052.5, y = -110.0}, mapAngle = 255, mapZoom = 850},
  [6] = {hole = 6, par = 3, startPos = vec3(-987.741, -105.076, 39.585),  holePos = vec3(-1103.506, -115.166, 40.558), mapPos = {x = -1052.5, y = -50.0}, mapAngle = 75, mapZoom = 600},
  [7] = {hole = 7, par = 4, startPos = vec3(-1117.019, -103.858, 40.840), holePos = vec3(-1290.636, 2.775, 49.340),   mapPos = {x = -1202.5, y = 45.0},   mapAngle = 75, mapZoom = 850},
  [8] = {hole = 8, par = 5, startPos = vec3(-1272.251, 38.042, 48.725),   holePos = vec3(-1034.941, -83.152, 43.035), mapPos = {x = -1182.5, y = -125.0}, mapAngle = 255, mapZoom = 950},
  [9] = {hole = 9, par = 4, startPos = vec3(-1138.319, -0.134, 47.982),   holePos = vec3(-1294.785, 83.526, 53.928),  mapPos = {x = -1182.5, y = 120.0},  mapAngle = 75, mapZoom = 750},
}
local ironSwing = {
  ["ironshufflehigh"] = "iron_shuffle_high",
  ["ironshufflelow"] = "iron_shuffle_low",
  ["ironshuffle"] = "iron_shuffle",
  ["ironswinghigh"] = "iron_swing_action_high",
  ["ironswinglow"] = "iron_swing_action_low",
  ["ironidlehigh"] = "iron_swing_idle_high",
  ["ironidlelow"] = "iron_swing_idle_low",
  ["ironidle"] = "iron_shuffle",
  ["ironswingintro"] = "iron_swing_intro_high"
}
local puttSwing = {
  ["puttshufflelow"] = "iron_shuffle_low",
  ["puttshuffle"] = "iron_shuffle",
  ["puttswinglow"] = "putt_action_low",
  ["puttidle"] = "putt_idle_low",
  ["puttintro"] = "putt_intro_low",
  ["puttintro"] = "putt_outro"
}
local attachPropList = {
  ["golfbag01"] =     {model = "prop_golf_bag_01",      bone = 24816, attPos = vec3(0.12, -0.3, 0.0),   attRot = vec3(-75.0, 190.0, 92.0)},
  ["golfputter01"] =  {model = "prop_golf_putter_01",   bone = 57005, attPos = vec3(0.0, -0.05, 0.0),   attRot = vec3(90.0, -118.0, 44.0)},
  ["golfiron01"] =    {model = "prop_golf_iron_01",     bone = 57005, attPos = vec3(0.125, 0.04, 0.0),  attRot = vec3(90.0, -118.0, 44.0)},
  ["golfiron03"] =    {model = "prop_golf_iron_01",     bone = 57005, attPos = vec3(0.126, 0.041, 0.0), attRot = vec3(90.0, -118.0, 44.0)},
  ["golfiron05"] =    {model = "prop_golf_iron_01",     bone = 57005, attPos = vec3(0.127, 0.042, 0.0), attRot = vec3(90.0, -118.0, 44.0)},
  ["golfiron07"] =    {model = "prop_golf_iron_01",     bone = 57005, attPos = vec3(0.128, 0.043, 0.0), attRot = vec3(90.0, -118.0, 44.0)},
  ["golfwedge01"] =   {model = "prop_golf_pitcher_01",  bone = 57005, attPos = vec3(0.17, 0.04, 0.0),   attRot = vec3(90.0, -118.0, 44.0)},
  ["golfdriver01"] =  {model = "prop_golf_driver",      bone = 57005, attPos = vec3(0.14, 0.00, 0.0),   attRot = vec3(160.0, -60.0, 10.0)}
}
local golfCourseBlips = {}
local courseStart = {
  pos = vec3(-1359.717, 149.866, 56.346), dist = 100
}
-- See here for reference to the boundaries: https://i.imgur.com/6nYGUVp.jpg
local boundary = {
  aPos = vec3(-1298.006, -29.590, 48.0),
  bPos = vec3(-1396.552, 182.469, 58.0),
  cPos = vec3(-1267.378, 200.031, 61.0),
  dPos = vec3(-1111.602, 239.171, 65.0),
  ePos = vec3(-1086.187, 178.338, 61.0),
  fPos = vec3(-914.387, -104.792, 38.0),
  gPos = vec3(-1074.646, -149.726, 38.0),
}
local clubBoundary = {
  pos1 = vec3(-1417.509, 281.564, 150.0),
  pos2 = vec3(-881.061, -174.898, 25.0)
}
local boundaryEqs = {}
local flagProp = nil
local isPlayingGolf = false
local currHole = 0
local startBlip = nil
local endBlip = nil
local golfBall = 0
local ballInHole = false
local holeStrokes = 0
local totalStrokes = 0
local holeBlip = nil
local ballPosition = 0
local currPlayState = 1 -- currPlayState, 2 on ball ready to swing, 1 free roam
local club = 1 -- Club state: 0 for putter, 1 iron, 2 wedge, 3 driver
local clubName = "None"
local power = 0.1
local inLoop = false -- in idle loop
local attachedProp = 0
local Ibuttons = nil
local sbShowing = false -- scoreboardShowing
local scoreboardScores = {}
local getSbScores = false
local sbRetrieving = false
local endScores = {}
local fillChange = 0.5
local vehSpawn = {x = -1351.082, y = 136.152, z = 56.264, heading = 4.5}
local rentMarker = {pos = vec3(-1351.086, 130.958, 56.239), dist = 100}
local rentBlock = false

-- setup instructional buttons
function SetIbuttons(buttons, layout) --Layout: 0 - horizontal, 1 - vertical
  Citizen.CreateThread(function()
    if not HasScaleformMovieLoaded(Ibuttons) then
      Ibuttons = RequestScaleformMovie("INSTRUCTIONAL_BUTTONS")
      while not HasScaleformMovieLoaded(Ibuttons) do
        Wait(1)
      end
    end

    local sf = Ibuttons
    local w,h = GetScreenResolution()
    PushScaleformMovieFunction(sf,"CLEAR_ALL")
    PopScaleformMovieFunction()
    PushScaleformMovieFunction(sf, "INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunction()
    PushScaleformMovieFunction(sf,"SET_DISPLAY_CONFIG")
    PushScaleformMovieFunctionParameterInt(w) -- screen width
    PushScaleformMovieFunctionParameterInt(h) -- screen height
    PushScaleformMovieFunctionParameterFloat(0.02) -- safeTopPercent
    PushScaleformMovieFunctionParameterFloat(0.95) -- safeBottomPercent
    PushScaleformMovieFunctionParameterFloat(0.02) -- safeLeftPercent
    PushScaleformMovieFunctionParameterFloat(0.98) -- safeRightPercent
    PushScaleformMovieFunctionParameterBool(true)  -- isWidescreen
    PushScaleformMovieFunctionParameterBool(false) -- isCircleAccept
    PushScaleformMovieFunctionParameterBool(false) -- ?
    PushScaleformMovieFunctionParameterInt(w) 
    PushScaleformMovieFunctionParameterInt(h)
    PopScaleformMovieFunction()
    PushScaleformMovieFunction(sf,"SET_MAX_WIDTH")
    PushScaleformMovieFunctionParameterFloat(0.35)
    PopScaleformMovieFunction()
    
    for i,btn in pairs(buttons) do
      PushScaleformMovieFunction(sf,"SET_DATA_SLOT")
      PushScaleformMovieFunctionParameterInt(i-1)
      PushScaleformMovieFunctionParameterString(btn[1])
      PushScaleformMovieFunctionParameterString(btn[2])
      PopScaleformMovieFunction()
    end
    
    if (layout ~= 1) then
      PushScaleformMovieFunction(sf,"SET_PADDING")
      PushScaleformMovieFunctionParameterInt(10)
      PopScaleformMovieFunction()
    end
    
    PushScaleformMovieFunction(sf,"DRAW_INSTRUCTIONAL_BUTTONS")
    PushScaleformMovieFunctionParameterInt(layout)
    PopScaleformMovieFunction()
  end)
end

function DrawIbuttons()
  if (HasScaleformMovieLoaded(Ibuttons)) then
    DrawScaleformMovie(Ibuttons, 0.5, 0.5, 1.0, 1.0, 255, 255, 255, 255)
  end
end

-- Setup the minimap
function drawGolfMap(hole, dist)
  local scaleform = RequestScaleformMovie("golf")
  while not HasScaleformMovieLoaded(scaleform) do
    Wait(1)
  end
  BeginScaleformMovieMethod(scaleform,"initScreenLayout")
  PopScaleformMovieFunction()

  local w,h = GetScreenResolution()
  BeginScaleformMovieMethod(scaleform,"SET_DISPLAY_CONFIG")
  PushScaleformMovieFunctionParameterInt(w) -- screen width
  PushScaleformMovieFunctionParameterInt(h) -- screen height
  PushScaleformMovieFunctionParameterFloat(0.02) -- safeTopPercent
  PushScaleformMovieFunctionParameterFloat(0.98) -- safeBottomPercent
  PushScaleformMovieFunctionParameterFloat(0.02) -- safeLeftPercent
  PushScaleformMovieFunctionParameterFloat(0.98) -- safeRightPercent
  PushScaleformMovieFunctionParameterBool(true)  -- isWidescreen
  PushScaleformMovieFunctionParameterBool(false) -- isHD
  PushScaleformMovieFunctionParameterBool(false) -- isAsian
  EndScaleformMovieMethod()

  BeginScaleformMovieMethod(scaleform,"SET_DISPLAY")
  PushScaleformMovieFunctionParameterBool(true) -- state
  EndScaleformMovieMethod()

  BeginScaleformMovieMethod(scaleform,"SET_HOLE_DISPLAY")
  PushScaleformMovieFunctionParameterString("Hole " .. tostring(hole)) --hole
  PushScaleformMovieFunctionParameterString("Par " .. tostring(holes[hole].par)) -- par
  PushScaleformMovieFunctionParameterString(tostring(dist) .. " yds") -- dist
  EndScaleformMovieMethod()

  SetMinimapGolfCourse(hole)
  SetRadarZoom(holes[hole].mapZoom)
  LockMinimapPosition(holes[hole].mapPos.x, holes[hole].mapPos.y)
  LockMinimapAngle(holes[hole].mapAngle)
  ToggleStealthRadar(false)
  SetRadarBigmapEnabled(false, false)

  if (holeBlip ~= nil) then
    RemoveBlip(holeBlip)
    holeBlip = nil
  end

  -- Create the flag blip and set the sprite to the flag sprite.
  holeBlip = AddBlipForCoord(holes[hole].holePos.x, holes[hole].holePos.y)
  SetBlipSprite(holeBlip, 358)
  SetBlipAsShortRange(holeBlip, true)
  SetBlipDisplay(holeBlip, 5)
  
  DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
end

-- setup the swing meter
function drawSwingMeter(fill, target)

  local scaleform = RequestScaleformMovie("golf")
  while not HasScaleformMovieLoaded(scaleform) do
    Wait(1)
  end

  BeginScaleformMovieMethod(scaleform,"SWING_METER_POSITION")
  PushScaleformMovieFunctionParameterFloat(0.25) -- x horizontal % of screen
  PushScaleformMovieFunctionParameterFloat(0.65) -- y vertical % of screen
  EndScaleformMovieMethod()

  -- General cursor
  BeginScaleformMovieMethod(scaleform,"SWING_METER_SET_MARKER")
  PushScaleformMovieFunctionParameterBool(false) -- horizontal visible
  PushScaleformMovieFunctionParameterFloat(1.0) -- y vertical % of screen (0.0, top - 1.0, bottom)
  PushScaleformMovieFunctionParameterBool(false) -- vertical visible
  PushScaleformMovieFunctionParameterFloat(-0.25) -- x horizontal % of screen (-0.25, left - 0.25, right)
  EndScaleformMovieMethod()

  -- Apex Marker - black cursor
  --[[BeginScaleformMovieMethod(scaleform,"SWING_METER_SET_APEX_MARKER")
  PushScaleformMovieFunctionParameterBool(true) -- horizontal visible
  PushScaleformMovieFunctionParameterFloat(0.5) -- y vertical % of screen (0.0, top - 1.0, bottom)
  PushScaleformMovieFunctionParameterBool(true) -- vertical visible
  PushScaleformMovieFunctionParameterFloat(0.0) -- x horizontal % of screen (-0.25, left - 0.25, right)
  EndScaleformMovieMethod()]]

  if (target) then
    BeginScaleformMovieMethod(scaleform,"SWING_METER_SET_TARGET")
    PushScaleformMovieFunctionParameterFloat(0.02) -- span of the target in the swing meter
    PushScaleformMovieFunctionParameterFloat(target) -- position of the target in the swing meter (0 top, 1 bottom)
    EndScaleformMovieMethod()
  end

  BeginScaleformMovieMethod(scaleform,"SWING_METER_SET_FILL")
  PushScaleformMovieFunctionParameterFloat(fill) -- span of the fill in the meter (0.0, empty, 1.0, full)
  PushScaleformMovieFunctionParameterFloat(fill) -- state (color intensity) (0.0, weak - 1.0, strong red)
  PushScaleformMovieFunctionParameterBool(false) -- fromTop, starts at the top of the meter if true
  EndScaleformMovieMethod()

  BeginScaleformMovieMethod(scaleform,"SWING_METER_SET_TARGET_COLOR")
  PushScaleformMovieFunctionParameterInt(0) -- r
  PushScaleformMovieFunctionParameterInt(0) -- g
  PushScaleformMovieFunctionParameterInt(0) -- b
  PushScaleformMovieFunctionParameterInt(255) -- alpha (0, transparent - 255, opaque)
  EndScaleformMovieMethod()

  -- draw the swing meter
  BeginScaleformMovieMethod(scaleform,"SWING_METER_TRANSITION_IN")
  EndScaleformMovieMethod()
end

function undrawSwingMeter()
  -- remove the swing meter
  local scaleform = RequestScaleformMovie("golf")
  while not HasScaleformMovieLoaded(scaleform) do
    Wait(1)
  end

  BeginScaleformMovieMethod(scaleform,"SWING_METER_TRANSITION_OUT")
  EndScaleformMovieMethod()
end

function attachProp(model, boneNumber, x, y, z, xR, yR, zR)
  local ped = PlayerPedId()
  removeAttachedProp()
  modelHash = GetHashKey(model)
  SetCurrentPedWeapon(ped, 0xA2719263)
  local bone = GetPedBoneIndex(ped, boneNumber)
  RequestModel(modelHash)
  while not HasModelLoaded(modelHash) do
    Wait(10)
  end
  attachedProp = CreateObject(modelHash, 1.0, 1.0, 1.0, 1, 1, 0)
  AttachEntityToEntity(attachedProp, ped, bone, x, y, z, xR, yR, zR, 1, 1, 0, 0, 2, 1)
  SetModelAsNoLongerNeeded(modelHash)
end

function removeAttachedProp()
  DeleteEntity(attachedProp)
  attachedProp = 0
end

-- add the blip for the golf course
function addGolfBlip()
  local blip = AddBlipForCoord(courseStart.pos.x, courseStart.pos.y, courseStart.pos.z)
  SetBlipSprite(blip, 109)
  SetBlipScale(blip, 0.8)
  SetBlipColour(blip, 43)
  SetBlipDisplay(blip, 2)
  SetBlipAsShortRange(blip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(tostring("Golf Course"))
  EndTextCommandSetBlipName(blip)
  
  table_insert(golfCourseBlips, blip)
end

-- 3D text markers
function Draw3DEstText(x, y, z, text)
  local onScreen, _x ,_y = World3dToScreen2d(x, y, z)
  local scale = (2 / Vdist(GetGameplayCamCoords(), x, y, z))
  local fov = 100 / GetGameplayCamFov()
  local scale = scale * fov
  
  if (onScreen) then
    SetTextScale(0.0, 0.35 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    -- SetTextScale(0.0, 0.55)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
  end
end

-- Draws text on the screen, used by the scoreboard
function drawGolfTxt(x, y, width, height, scale, text, r, g, b, a)
  SetTextFont(2)
  SetTextProportional(0)
  SetTextScale(scale, scale)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0,255)
  SetTextDropShadow()
  SetTextOutline()
  BeginTextCommandDisplayText("STRING")
  AddTextComponentString(text)
  EndTextCommandDisplayText(x - width/2, y - height/2 + 0.025)
end

function DisplayHelpText(str)
  DrawRect(0.919, 0.892, 0.123, 0.045, 0, 0, 0, 200)
  drawGolfTxt(0.872, 0.89, 0.0275, 0.0775, 0.3, str, 255, 255, 255, 255)
end

-- draw the golf hud
function startGolfHud()
  TriggerServerEvent("bms:golf:sendShot", nil, nil)
  SetIbuttons({{GetControlInstructionalButton(1,37,0),"Scoreboard"}}, 0)
  Citizen.CreateThread(function()
    while (isPlayingGolf) do
      Wait(1)
      drawGolfHud()
    end
  end)
end

function drawGolfHud()
  DisableControlAction(0, 37, true)
  DisableControlAction(0, 44, true)
  if (IsDisabledControlPressed(0, 37)) then
    if (not sbShowing and not sbRetrieving) then
      sbRetrieving = true
      TriggerServerEvent("bms:golf:getScores")
      Citizen.CreateThread(function()
        while (not getSbScores) do
          Wait(10)
        end
        --print(exports.devtools:dump(scoreboardScores))
        SendNUIMessage({
          showScoreboard = true,
          scores = scoreboardScores
        })
        sbShowing = true
        --print(exports.devtools:dump(scoreboardScores))
        getSbScores = false
        sbRetrieving = false
      end)
    end
  end
  if (IsDisabledControlJustReleased(0, 37)) then
    if (sbShowing) then
      SendNUIMessage({
        hideScoreboard = true
      })
      sbShowing = false	
    end
  end
  if (currHole ~= 0) then
    local distance = 2*math.ceil(Vdist(GetEntityCoords(golfBall), holes[currHole].holePos.x, holes[currHole].holePos.y, holes[currHole].holePos.z, true))
    drawGolfMap(currHole, distance)
    DrawRect(0.5, 0.98, 0.13, 0.04, 0, 0, 0, 200)
    drawGolfTxt(0.5, 0.98, 0.13, 0.0775, 0.4, "~g~Strokes - ~s~ ~g~Club - ~s~", 255, 255, 255, 255)
    drawGolfTxt(0.485, 0.98, 0.008, 0.0775, 0.4, tostring(holeStrokes), 255, 255, 255, 255)
    drawGolfTxt(0.55, 0.98, 0.0275, 0.0775, 0.4, tostring(clubName), 255, 255, 255, 255)
  end
  DrawIbuttons()
end

-- reset all stuff changed by the golf hud
function endGolfHud()
  EnableControlAction(0, 37, true)
  undrawSwingMeter()
  if (holeBlip ~= nil) then
    RemoveBlip(holeBlip)
    holeBlip = nil
  end
  if (startBlip ~= nil) then
    RemoveBlip(startBlip)
    startBlip = nil
  end
  if (endBlip ~= nil) then
    RemoveBlip(endBlip)
    endBlip = nil
  end
  if (ballBlip ~= nil) then
    RemoveBlip(ballBlip)
    ballBlip = nil
  end
  
  N_0x35edd5b2e3ff01c0()
  SetRadarZoom(0)
  UnlockMinimapAngle()
  UnlockMinimapPosition()
  SetRadarBigmapEnabled(false, false)
  if (sbShowing) then
    SendNUIMessage({
      hideScoreboard = true
    })
    sbShowing = false	
  end
end

function startGolf(msg)
  isPlayingGolf = true
  ballInHole = false
  currHole = 0
  
  if (msg) then
    exports.pnotify:SendNotification({text = msg})
  end
  SetCurrentPedWeapon(PlayerPedId(), 0xA2719263)

  startGolfHud()
  startHole()
  Citizen.CreateThread(function()
    while (isPlayingGolf) do
      Wait(10)

      if (ballInHole) then
        if (currHole > 9) then
          endgame(string.format("Game complete, final score: <font color=lightgreen>%s</font>", totalStrokes))
        else
          startHole()
        end
      else
        if (currPlayState == 2) then
          SetIbuttons({
            {GetControlInstructionalButton(1,37,0),"Scoreboard"},
            {GetControlInstructionalButton(1,21,0),"Show Club Controls"}
          }, 0)
          idleShot()
        elseif (currPlayState == 1) then
          SetIbuttons({{GetControlInstructionalButton(1,37,0),"Scoreboard"}}, 0)
          moveToBall()
        end
      end
    end
  end)
end

function rotateShot(moveType)
  local curHeading = GetEntityHeading(golfBall)
  if (curHeading >= 360.0) then
    curHeading = 0.0
  end
  if (moveType) then
    SetEntityHeading(golfBall, curHeading-0.7)
  else
    SetEntityHeading(golfBall, curHeading+0.7)
  end
end

function createBall(x, y, z)
  if (golfBall ~= nil) then
    if (ballBlip ~= nil) then
      RemoveBlip(ballBlip)
      ballBlip = nil
    end
    DeleteObject(golfBall)
  end

  golfBall = CreateObject(GetHashKey("prop_golf_ball"), x, y, z, true, true, false)

  SetEntityRecordsCollisions(golfBall,true)
  addBallBlip()
  SetEntityCollision(golfBall, true, true)
  SetEntityHasGravity(golfBall, true)
  FreezeEntityPosition(golfBall, true)
  SetEntityHeading(golfBall, GetEntityHeading(PlayerPedId()))
end

function endgame(endStr)
  if (endStr) then
    exports.pnotify:SendNotification({text = endStr})
  end

  if (currHole > 9) then
    TriggerServerEvent("localChatAction", GetPlayerServerId(PlayerId()), -1, {255, 255, 0}, string.format("^3has finished a game of ^2golf!^3 Score: ^4%s %s %s %s %s %s %s %s %s, ^7Total: %s", endScores[1], endScores[2], endScores[3], endScores[4], endScores[5], endScores[6], endScores[7], endScores[8], endScores[9], totalStrokes))
  end
  removeAttachedProp()
  DeleteObject(golfBall)
  DeleteObject(flagProp)
  currHole = 0
  holeStrokes = 0
  isPlayingGolf = false
  ballInHole = false
  ballPosition = 0
  currPlayState = 1
  club = 1
  inLoop = false
  Wait(100)
  endGolfHud()
  TriggerServerEvent("bms:golf:clearScore")
end

function moveToBall()
  while (currPlayState == 1 and isPlayingGolf) do
    Wait(1)
    local ped = PlayerPedId()
    if (not IsPedInAnyVehicle(ped, false)) then
      local ballPos = GetEntityCoords(golfBall)
      local playerPos = GetEntityCoords(PlayerPedId())
      local distance = Vdist(ballPos.x, ballPos.y, ballPos.z, playerPos.x, playerPos.y, playerPos.z - 1, true)
      local xyDist = Vdist(ballPos.x, ballPos.y, 0, playerPos.x, playerPos.y, 0, true)
      --print(string.format("Ball: x: %s, y: %s, z: %s\nPlayer: x: %s, y: %s, z: %s", ballPos.x,ballPos.y,ballPos.z, playerPos.x,playerPos.y,playerPos.z))

      DrawMarker(27, ballPos.x, ballPos.y, ballPos.z + 0.01, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 10.3, 79, 255, 243, 105, 0, 0, 2, 0, 0, 0, 0)

      if (xyDist < 5.0 and holeStrokes > 0) then
        DisplayHelpText("Press ~g~E~s~ to ball drop if you are stuck\ncosts a stroke")
        if (IsControlJustReleased(1, 38)) then -- E
          local holeDist = Vdist(holes[currHole].holePos.x, holes[currHole].holePos.y, holes[currHole].holePos.z, GetEntityCoords(PlayerPedId()))
          if (holeDist < 2.0) then
            exports.pnotify:SendNotification({text = "Too close to the hole! Move further back and try again."})
          else
            dropShot()
          end
        end
      end

      if (distance < 0.6) then
        currPlayState = 2
        ballInHole = false
      end
    end
    
    if (holeStrokes == 0 and currHole > 0) then
      DrawMarker(3, holes[currHole].startPos.x, holes[currHole].startPos.y, holes[currHole].startPos.z + 1.0, 0, 0, 0, 180.0, 0, 0, 0.8, 0.8, 0.8, 255, 59, 55, 105, 0, 0, 2, true, 0, 0, 0)
    end
  end
end

function endShot()
  local strokes = 0

  removeAttachedProp()
  holeStrokes = holeStrokes + 1
  strokes = holeStrokes
  local ballPos = GetEntityCoords(golfBall)
  local distance = Vdist(ballPos.x, ballPos.y, ballPos.z, holes[currHole].holePos.x, holes[currHole].holePos.y, holes[currHole].holePos.z, true)
  if (distance < 0.75) then
    PlaySoundFrontend(-1, "CHALLENGE_UNLOCKED", "HUD_AWARDS", 1)
    exports.pnotify:SendNotification({text = string.format("Score! It took you <font color='#13E849'>%s strokes</font>.", holeStrokes)})
    totalStrokes = holeStrokes + totalStrokes
    endScores[currHole] = holeStrokes
    holeStrokes = 0
    ballInHole = true
  end
  if (holeStrokes >= 12) then
    PlaySoundFrontend(-1, "LOSER", "HUD_AWARDS", 1)
    exports.pnotify:SendNotification({text = "You exceeded the <font color='#CF3732'>stroke limit</font>."})
    totalStrokes = totalStrokes + 14
    endScores[currHole] = 14
    strokes = 14
    holeStrokes = 0
    ballInHole = true
  end
  TriggerServerEvent("bms:golf:sendShot", currHole, strokes)
end

function dropShot()
  local pedPos = GetEntityCoords(PlayerPedId())
  SetEntityCoords(golfBall, pedPos.x, pedPos.y, pedPos.z - 1)
  SetEntityHeading(golfBall, GetEntityHeading(PlayerPedId()))
  FreezeEntityPosition(golfBall, true)

  RequestScriptAudioBank("GOLF_I", 0)
  PlaySoundFromEntity(-1, "GOLF_BALL_CUP_MISS_MASTER", PlayerPedId(), 0, 0, 0)
  exports.pnotify:SendNotification({text = "Ball dropped."})
  holeStrokes = holeStrokes + 1
end

function attachClub()
  if (club == 3) then
    attachItem("golfdriver01")
    clubName = "Driver"
  elseif (club == 2) then
    attachItem("golfwedge01")
    clubName = "Wedge"
  elseif (club == 1) then
    attachItem("golfiron01")
    clubName = "1 Iron"
  elseif (club == 4) then
    attachItem("golfiron03")
    clubName = "3 Iron"
  elseif (club == 5) then
    attachItem("golfiron05")
    clubName = "5 Iron"
  elseif (club == 6) then
    attachItem("golfiron07")
    clubName = "7 Iron"
  else
    attachItem("golfputter01")
    clubName = "Putter"
  end
end

function addBallBlip()
  if (ballBlip ~= nil) then
    RemoveBlip(ballBlip)
    ballBlip = nil
  end
  ballBlip = AddBlipForEntity(golfBall)
  SetBlipSprite(ballBlip, 161)
  SetBlipScale(ballBlip, 0.5)
  SetBlipColour(ballBlip, 1)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(tostring("Ball"))
  EndTextCommandSetBlipName(ballBlip)
end

function getColor(holeAngle, heading)
  local angDiff = holeAngle - heading
  --print(string.format("angle: %s, heading: %s, diff: %s", holeAngle, heading, angDiff))
  if (angDiff < 0.10472) then -- 6 deg
    return {r = 0, g = 255, b = 0, a = 1.0}
  elseif (angDiff < 0.20944) then -- 12 deg
    return {r = 51, g = 204, b = 0, a = 0.9}
  elseif (angDiff < 0.314159) then -- 18 deg
    return {r = 85, g = 170, b = 0, a = 0.8}
  elseif (angDiff < 0.418879) then -- 24 deg
    return {r = 119, g = 136, b = 0, a = 0.8}
  elseif (angDiff < 0.523599) then -- 30 deg
    return {r = 153, g = 102, b = 0, a = 0.8}
  elseif (angDiff < 0.628319) then -- 36 deg
    return {r = 187, g = 68, b = 0, a = 0.8}
  elseif (angDiff < 0.733038) then -- 42 deg
    return {r = 221, g = 34, b = 0, a = 0.8}
  elseif (angDiff < 0.837758) then -- 48 deg
    return {r = 238, g = 17, b = 0, a = 0.8}
  elseif (angDiff < 0.942478) then -- 54 deg
    return {r = 255, g = 0, b = 0, a = 0.8}
  --[[elseif (angDiff < 1.04720) then -- 60 deg
    return {r = 170, g = 255, b = 0, a = 0.8}
  elseif (angDiff < 1.15192) then -- 66 deg
    return {r = 187, g = 255, b = 0, a = 0.8}
  elseif (angDiff < 1.25664) then -- 72 deg
    return {r = 204, g = 255, b = 0, a = 0.8}
  elseif (angDiff < 1.36136) then -- 78 deg
    return {r = 221, g = 255, b = 0, a = 0.8}
  elseif (angDiff < 1.46608) then -- 84 deg
    return {r = 238, g = 255, b = 0, a = 0.8}
  elseif (angDiff < 1.5708) then -- 90 deg
    return {r = 255, g = 255, b = 0, a = 0.8}
  elseif (angDiff < 1.67552) then -- 96 deg
    return {r = 255, g = 255, b = 34, a = 0.8}
  elseif (angDiff < 1.78024) then -- 102 deg
    return {r = 255, g = 255, b = 51, a = 0.8}
  elseif (angDiff < 1.88496) then -- 108 deg
    return {r = 255, g = 255, b = 68, a = 0.8}
  elseif (angDiff < 1.98968) then -- 114 deg
    return {r = 255, g = 255, b = 85, a = 0.8}
  elseif (angDiff < 2.09440) then -- 120 deg
    return {r = 255, g = 255, b = 102, a = 0.8}
  elseif (angDiff < 2.19911) then -- 126 deg
    return {r = 255, g = 255, b = 119, a = 0.8}
  elseif (angDiff < 2.30383) then -- 132 deg
    return {r = 255, g = 255, b = 136, a = 0.8}
  elseif (angDiff < 2.40855) then -- 138 deg
    return {r = 255, g = 255, b = 153, a = 0.8}
  elseif (angDiff < 2.51327) then -- 144 deg
    return {r = 255, g = 255, b = 170, a = 0.8}
  elseif (angDiff < 2.61799) then -- 150 deg
    return {r = 255, g = 255, b = 187, a = 0.8}
  elseif (angDiff < 2.72271) then -- 156 deg
    return {r = 255, g = 255, b = 204, a = 0.8}
  elseif (angDiff < 2.82743) then -- 162 deg
    return {r = 255, g = 255, b = 221, a = 0.8}
  elseif (angDiff < 2.93215) then -- 168 deg
    return {r = 238, g = 17, b = 238, a = 0.8}]]
  else
    return {r = 255, g = 0, b = 0, a = 0.8}
  end
end

function idleShot()
  power = 0.1
  local target = 0.0
  fillChange = 0.5

  local distance = Vdist(GetEntityCoords(golfBall), holes[currHole].holePos.x,holes[currHole].holePos.y,holes[currHole].holePos.z, true)
  if (distance >= 175.0) then
    club = 3 -- driver 200m-250m
  elseif (distance >= 131.25 and distance < 175.0) then
    club = 1 -- iron 1 140m-180m
  elseif (distance >= 105.0 and distance < 131.25) then
    club = 4 -- iron 3 -- 120m-150m
  elseif (distance >= 78.75 and distance < 105.0) then
    club = 5 -- -- iron 5 -- 70m-120m
  elseif (distance >= 43.75 and distance < 78.75) then
    club = 6 -- iron 7 -- 50m-100m
  elseif (distance >= 20.0 and distance < 43.75) then
    club = 2 --  wedge 50m-80m
  else
    club = 0 -- else putter
  end

  attachClub()
  RequestScriptAudioBank("GOLF_I", 0)
  while (currPlayState == 2) do
    Wait(1)
    if (IsControlPressed(1, 21)) then -- LSHIFT
      SetIbuttons({
        {GetControlInstructionalButton(1,37,0),"Scoreboard"},
        {GetControlInstructionalButton(1,174,0),"Cycle Clubs (Up)"},
        {GetControlInstructionalButton(1,175,0),"Cycle Clubs (Down)"},
        {GetControlInstructionalButton(1,34,0),"Rotate Left"},
        {GetControlInstructionalButton(1,35,0),"Rotate Right"},
        {GetControlInstructionalButton(1,172,0),"Adjust Max Power (Up)"},
        {GetControlInstructionalButton(1,173,0),"Adjust Max Power (Down)"},
        {GetControlInstructionalButton(1,38,0),"Swing"}
      }, 0)
    else
      SetIbuttons({
        {GetControlInstructionalButton(1,37,0),"Scoreboard"},
        {GetControlInstructionalButton(1,21,0),"Show Club Controls"}
      }, 0)
    end

    if (IsControlPressed(1, 38)) then -- E
      if (fillChange > 0) then
        if (power > 25) then
          fillChange = 1.5
        end
        if (power > 50) then
          fillChange = 1.75
        end
        if (power > 75) then
          fillChange = 2.25
        end
      else
        if (power > 25) then
          fillChange = -1.5
        end
        if (power > 50) then
          fillChange = -1.75
        end
        if (power > 75) then
          fillChange = -2.25
        end
      end
      if (power > (1 - target)*100) then
        fillChange = -2.25
      end
      if (power < 0.5) then
        fillChange = 2.25
      end
      power = power + fillChange
    end

    if (IsControlPressed(1, 173)) then
      if (target < 0.85) then
        target = target + 0.005
      else
        target = 0.85
      end
    elseif (IsControlPressed(1, 172)) then
      if (target > 0.0) then
        target = target - 0.005
      else
        target = 0.0
      end
    end

    drawSwingMeter(power/100.0, target)

    local ballPos = GetEntityCoords(golfBall)
    local dist = Vdist(ballPos.x, ballPos.y, ballPos.z, holes[currHole].holePos.x, holes[currHole].holePos.y, holes[currHole].holePos.z)
    local ped = PlayerPedId()
    local heading = math.rad(GetEntityHeading(ped))
    --DrawLine(GetEntityCoords(golfBall), holes[currHole].holePos.x,holes[currHole].holePos.y,holes[currHole].holePos.z, 222, 111, 111, 0.2)
    --local xDist = ballPos.x - holes[currHole].holePos.x
    --local angle = math.acos(xDist/dist)
    --[[if (xDist > 0) then
      angle = math.acos(xDist/dist)
    else
      angle = math.acos(xDist/dist) + math.pi
    end]]
    --local color = getColor(angle, heading)
    --print(string.format("dist: %s, xDist: %s, ballPos.x: %s, ballPos.y: %s, holePos.x: %s, holePos.y: %s, angle (rad): %s, heading (rad): %s, angle: %s, heading: %s", dist, xDist, ballPos.x, ballPos.y, holes[currHole].holePos.x, holes[currHole].holePos.y, angle, heading, math.deg(angle), math.deg(heading)))
    -- Heading of the ball
    --DrawLine(ballPos.x - 2*math.cos(heading), ballPos.y - 2*math.sin(heading), ballPos.z + 0.15, ballPos.x, ballPos.y, ballPos.z, color.r, color.g, color.b, color.a)
    DrawLine(ballPos.x - 2*math.cos(heading), ballPos.y - 2*math.sin(heading), ballPos.z + 0.15, ballPos.x, ballPos.y, ballPos.z, 255, 255, 255, 0.8)
    DrawMarker(27, holes[currHole].holePos.x, holes[currHole].holePos.y, holes[currHole].holePos.z + 0.03, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 10.3, 212, 189, 0, 105, 0, 0, 2, 0, 0, 0, 0)

    if (IsControlJustPressed(1, 174)) then
      local newclub = club + 1
      if (newclub > 6) then
        newclub = 0
      end
      club = newclub
      attachClub()
    elseif (IsControlJustPressed(1, 175)) then
      local newclub = club - 1
      if (newclub < 0) then
        newclub = 6
      end
      club = newclub
      attachClub()
    end
    
    if (IsControlPressed(1, 35)) then -- D
      rotateShot(true)
    end
    if (IsControlPressed(1, 34)) then -- A
      rotateShot(false)
    end

    if (club == 0) then
      AttachEntityToEntity(ped, golfBall, 20, 0.14, -0.62, 0.99, 0.0, 0.0, 0.0, false, false, false, false, 1, true)
    elseif (club == 3) then
      AttachEntityToEntity(ped, golfBall, 20, 0.3, -0.92, 0.99, 0.0, 0.0, 0.0, false, false, false, false, 1, true)
    elseif (club == 2) then
      AttachEntityToEntity(ped, golfBall, 20, 0.38, -0.79, 0.94, 0.0, 0.0, 0.0, false, false, false, false, 1, true)
    else
      AttachEntityToEntity(ped, golfBall, 20, 0.4, -0.83, 0.94, 0.0, 0.0, 0.0, false, false, false, false, 1, true)
    end
    if (IsControlJustReleased(1, 38)) then -- E
      if (club == 0) then
        playAnim = puttSwing["puttswinglow"]
      else
        playAnim = ironSwing["ironswinghigh"]
        playGolfAnim(playAnim)
        playAnim = ironSwing["ironswinglow"]
        playGolfAnim(playAnim)
        playAnim = ironSwing["ironswinglow"]
      end

      currPlayState = 1
      inLoop = false
      DetachEntity(ped, true, false)
    else
      if (not inLoop) then
        Citizen.CreateThread(function()
          inLoop = true
          while (inLoop) do
            Wait(1)
            idleLoop()
          end
        end)
      end
    end
  end

  PlaySoundFromEntity(-1, "GOLF_SWING_FAIRWAY_IRON_LIGHT_MASTER", PlayerPedId(), 0, 0, 0)

  playGolfAnim(playAnim)
  swing()

  Wait(10)
  undrawSwingMeter()
  endShot()
end

function swing()
  local priorPos = GetEntityCoords(golfBall)

  if (club ~= 0) then
    ballCam()
  end
  if (not HasNamedPtfxAssetLoaded("scr_minigamegolf")) then
    RequestNamedPtfxAsset("scr_minigamegolf")
    while (not HasNamedPtfxAssetLoaded("scr_minigamegolf")) do
      Wait(1)
    end
  end
  SetPtfxAssetNextCall("scr_minigamegolf")
  StartParticleFxLoopedOnEntity("scr_golf_ball_trail", golfBall, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)

  local enabledroll = false

  dir = GetEntityHeading(golfBall)
  local x,y = dirMath(dir)
  FreezeEntityPosition(golfBall, false)
  local rollpower = power / 3

  if (club == 0) then -- putter
    power = power / 5.0
    local check = power
    while (check > 0.0) do
      SetEntityVelocity(golfBall, x*check, y*check, -0.1)
      Wait(5)
      check = check - 0.15
    end

    power = 0
  elseif (club == 1) then -- iron 1 140m-180m
    power = power * 1.5725 -- 1.85
    airpower = power / 2.6
    enabledroll = true
    rollpower = rollpower / 4
  elseif (club == 2) then -- wedge -- 50m-80m
    power = power * 1.1475 -- 1.35 (prev 1.5)
    airpower = power / 2.1
    enabledroll = true
    rollpower = rollpower / 4.5
  elseif (club == 3) then -- driver 200m-250m
    power = power * 1.7 -- 2.0
    airpower = power / 2.6
    enabledroll = true
    rollpower = rollpower / 2
  elseif (club == 4) then -- iron 3 -- 110m-150m
    power = power * 1.445 -- 1.7 (previously 1.8)
    airpower = power / 2.55
    enabledroll = true
    rollpower = rollpower / 5
  elseif (club == 5) then -- iron 5 -- 70m-120m
    power = power * 1.3175 -- 1.55 (previously 1.75)
    airpower = power / 2.5
    enabledroll = true
    rollpower = rollpower / 5.5
  elseif (club == 6) then -- iron 7 -- 50m-100m
    power = power * 1.21125 -- 1.425 (prev 1.7)
    airpower = power / 2.45
    enabledroll = true
    rollpower = rollpower / 6.0
  end

  while (power > 0) do
    SetEntityVelocity(golfBall, x*power, y*power, airpower)
    Wait(1)
    power = power - 1
    airpower = airpower - 1
  end

  if (enabledroll) then
    while (rollpower > 0) do
      SetEntityVelocity(golfBall, x*rollpower, y*rollpower, 0.0)
      Wait(5)
      rollpower = rollpower - 1
    end
  end

  Wait(2000)

  SetEntityVelocity(golfBall,0.0,0.0,0.0)
  if (club ~= 0) then
    ballCamOff()
  end
  SetEntityHeading(golfBall, GetEntityHeading(PlayerPedId()))
  FreezeEntityPosition(golfBall, true)
  RemoveParticleFxFromEntity(golfBall)

  if (isOutOfBounds()) then
    SetEntityCoords(golfBall, priorPos.x, priorPos.y, priorPos.z)
    SetEntityHeading(golfBall, GetEntityHeading(PlayerPedId()))
    FreezeEntityPosition(golfBall, true)

    PlaySoundFrontend(-1, "LOSER", "HUD_AWARDS", 1)
    exports.pnotify:SendNotification({text = "Your ball landed out of the play area, it has been <font color='#CF3732'>reset</font> and you have gained a <font color='#CF3732'>stroke!</font>"})
    holeStrokes = holeStrokes + 1
  elseif (IsEntityInWater(golfBall)) then
    
    SetEntityCoords(golfBall, priorPos.x, priorPos.y, priorPos.z)
    SetEntityHeading(golfBall, GetEntityHeading(PlayerPedId()))
    FreezeEntityPosition(golfBall, true)

    PlaySoundFrontend(-1, "LOSER", "HUD_AWARDS", 1)
    RequestScriptAudioBank("GOLF_I", 0)
    PlaySoundFromEntity(-1, "GOLF_BALL_IN_WATER_MASTER", PlayerPedId(), 0, 0, 0)
    exports.pnotify:SendNotification({text = "Your ball landed in water, it has been <font color='#CF3732'>reset</font> and you have gained a <font color='#CF3732'>stroke!</font>"})
    holeStrokes = holeStrokes + 1
  else
    if (startBlip ~= nil) then
      RemoveBlip(startBlip)
      startBlip = nil
    end
  end
end

function dirMath(dir)
  local x = 0.0
  local y = 0.0
  local dir = dir
  if (dir >= 0.0 and dir <= 90.0) then
    local factor = (dir/9.2) / 10
    x = -1.0 + factor
    y = 0.0 - factor
  end

  if (dir > 90.0 and dir <= 180.0) then
    dirp = dir - 90.0
    local factor = (dirp/9.2) / 10
    x = 0.0 + factor
    y = -1.0 + factor
  end

  if (dir > 180.0 and dir <= 270.0) then
    dirp = dir - 180.0
    local factor = (dirp/9.2) / 10
    x = 1.0 - factor
    y = 0.0 + factor
  end

  if (dir > 270.0 and dir <= 360.0) then
    dirp = dir - 270.0
    local factor = (dirp/9.2) / 10
    x = 0.0 - factor
    y = 1.0 - factor
  end
  return x,y
end

function idleLoop()
  if (club == 0) then
    playAnim = puttSwing["puttidle"]
  else
    if (IsControlPressed(1, 38)) then
      playAnim = ironSwing["ironidlehigh"]
    else
      playAnim = ironSwing["ironidle"]
    end
  end
  playGolfAnim(playAnim)
  Wait(1200)
end

function playGolfAnim(anim)
  loadAnimDict("mini@golf")
  if (not IsEntityPlayingAnim(lPed, "mini@golf", anim, 3)) then
    length = GetAnimDuration("mini@golf", anim)
    TaskPlayAnim( PlayerPedId(), "mini@golf", anim, 1.0, -1.0, length, 0, 1, 0, 0, 0)
    Wait(length)
    RemoveAnimDict("mini@golf")
  end
end

function ballCam()
  ballcam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  SetCamFov(ballcam, 90.0)
  RenderScriptCams(true, true, 3, 1, 0)

  Citizen.CreateThread(function()
    local timer = 20000
    while (timer > 0) do
      Wait(2)
      local ballPos = GetEntityCoords(golfBall)
      SetCamCoord(ballcam, ballPos.x, ballPos.y-10, ballPos.z+9)
      PointCamAtEntity(ballcam, golfBall, 0.0, 0.0, 0.0, true)
      timer = timer - 2
    end
  end)
end

function ballCamOff()
  RenderScriptCams(false, false, 0, 1, 0)
  DestroyCam(ballcam, false)
end

function loadAnimDict(dict)
  while (not HasAnimDictLoaded(dict)) do
    RequestAnimDict(dict)
    Wait(5)
  end
end

function startHole()
  ballInHole = false
  currPlayState = 1
  currHole = currHole + 1

  if (currHole < 10) then
    if (flagProp ~= nil) then
      DeleteObject(flagProp)
    end

    local flagHash = GetHashKey("prop_golfflag")
    RequestModel(flagHash)
    while (not HasModelLoaded(flagHash)) do
      Wait(10)
    end
    local flagPos = holes[currHole].holePos
    flagProp = CreateObject(flagHash, flagPos.x, flagPos.y, flagPos.z, false, true, false)
    FreezeEntityPosition(flagProp, true)
    SetEntityRotation(flagProp, 0, 0, 0, 1, true)
    SetModelAsNoLongerNeeded(flagHash)
    blipsStartEnd()
  else
    endgame(string.format("Game complete, final score: <font color=lightgreen>%s</font>", totalStrokes))
  end
end

function blipsStartEnd()
  if (startBlip ~= nil) then
    RemoveBlip(startBlip)
    startBlip = nil
  end
  if (endBlip ~= nil) then
    RemoveBlip(endBlip)
    endBlip = nil
  end
  
  startBlip = AddBlipForCoord(holes[currHole].startPos.x,holes[currHole].startPos.y,holes[currHole].startPos.z)
  SetBlipSprite(startBlip, 161)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(tostring("Hole Start"))
  EndTextCommandSetBlipName(startBlip)
  
  endBlip = AddBlipForCoord(holes[currHole].holePos.x,holes[currHole].holePos.y,holes[currHole].holePos.z)
  SetBlipSprite(endBlip, 358)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(tostring("Hole End"))
  EndTextCommandSetBlipName(endBlip)
  
  createBall(holes[currHole].startPos.x,holes[currHole].startPos.y,holes[currHole].startPos.z)
end

function attachItem(item)
  attachProp(attachPropList[item].model, attachPropList[item].bone, attachPropList[item].attPos.x, attachPropList[item].attPos.y, attachPropList[item].attPos.z, attachPropList[item].attRot.x, attachPropList[item].attRot.y, attachPropList[item].attRot.z)
end

function initialize()
  addGolfBlip()
  addSlopeEq(boundary.aPos, boundary.bPos)
  addSlopeEq(boundary.bPos, boundary.cPos)
  addSlopeEq(boundary.cPos, boundary.dPos)
  addSlopeEq(boundary.dPos, boundary.ePos)
  addSlopeEq(boundary.ePos, boundary.fPos)
  addSlopeEq(boundary.fPos, boundary.gPos)
  addSlopeEq(boundary.gPos, boundary.aPos)
  --print(exports.devtools:dump(boundaryEqs))
end

function isOutOfBounds()
  local isOOB = false
  local ballPos = GetEntityCoords(golfBall)
  for i,v in ipairs(boundaryEqs) do
    if (i == 1 and ballPos.y > boundary.aPos.y) then -- AB, left horizontal bounds
      if (ballPos.x < ((ballPos.y - v.yInt)/v.slope + v.xInt)) then -- X = (Y - yInt)/slope + xInt
        isOOB = true
        break
      end
    elseif (i == 2 and ballPos.x < boundary.cPos.x) then -- BC, top vertical bound
      if (ballPos.y > ((ballPos.x - v.xInt)*v.slope + v.yInt)) then -- Y = (X - xInt)*slope + yInt
        isOOB = true
        break
      end
    elseif (i == 3 and ballPos.x > boundary.cPos.x) then -- CD, top vertical bound
      if (ballPos.y > ((ballPos.x - v.xInt)*v.slope + v.yInt)) then -- Y = (X - xInt)*slope + yInt
        isOOB = true
        break
      end
    elseif (i == 4 and ballPos.y > boundary.ePos.y) then -- DE, right horizontal bound
      if (ballPos.x > ((ballPos.y - v.yInt)/v.slope + v.xInt)) then -- X = (Y - yInt)/slope + xInt
        isOOB = true
        break
      end
    elseif (i == 5 and ballPos.y < boundary.ePos.y) then -- EF, right horizontal bound
      if (ballPos.x > ((ballPos.y - v.yInt)/v.slope + v.xInt)) then -- X = (Y - yInt)/slope + xInt
        isOOB = true
        break
      end
    elseif (i == 6) then -- GF, lower vertical bound
      if (ballPos.y < ((ballPos.x - v.xInt)*v.slope + v.yInt)) then -- Y = (X - xInt)*slope + yInt
        isOOB = true
        break
      end
    elseif (i == 7 and ballPos.y < boundary.aPos.y) then -- GA, left horizontal bounds
      if (ballPos.x < ((ballPos.y - v.yInt)/v.slope + v.xInt)) then -- X = (Y - yInt)/slope + xInt
        isOOB = true
        break
      end
    end
  end

  return isOOB
end

function addSlopeEq(pos1, pos2)
  -- y intercept, x intercept, slope
  local eqVar = {yInt = pos1.y, xInt = pos1.x, slope = (pos2.y - pos1.y)/(pos2.x - pos1.x)}
  table_insert(boundaryEqs, eqVar)
end

function rentGolfCart(msg)
  rentBlock = true
  local vehHash = GetHashKey("caddy")

  RequestModel(vehHash)
  while not HasModelLoaded(vehHash) do
    Wait(10)
  end

  local veh = CreateVehicle(vehHash, vehSpawn.x, vehSpawn.y, vehSpawn.z, vehSpawn.heading, true, false)
    
  while (not DoesEntityExist(veh)) do
    Wait(10)
  end

  exports.vehicles:registerPulledVehicle(veh)

  SetModelAsNoLongerNeeded(vehHash)
  SetVehicleOnGroundProperly(veh)
  SetEntityAsMissionEntity(veh, true, true)
  SetVehicleHasBeenOwnedByPlayer(veh, true)
  SetVehicleDirtLevel(veh, 0.0)

  if (msg) then
    exports.pnotify:SendNotification({text = msg})
  end

  SetTimeout(60000, function()
    rentBlock = false
  end)
end

RegisterNetEvent("bms:golf:startRound")
AddEventHandler("bms:golf:startRound", function(data)
  if (data.success) then
    startGolf(data.msg)
  else
    exports.pnotify:SendNotification({text = data.msg})
  end
end)

AddEventHandler("bms:char:charLoggedIn", function()
  initialize()
end)

AddEventHandler("onResourceStart", function(resname)
  if (resname == GetCurrentResourceName()) then
    initialize()
  end
end)

RegisterNetEvent("bms:golf:getScores")
AddEventHandler("bms:golf:getScores", function(scores)
  if (scores) then
    scoreboardScores = scores
  end
  getSbScores = true
end)

RegisterNetEvent("bms:golf:rentGolfCart")
AddEventHandler("bms:golf:rentGolfCart", function(data)
  print("bms:golf:rentGolfCart: " .. exports.devtools:dump(data))
  if (data.success) then
    rentGolfCart(data.msg)
  else
    exports.pnotify:SendNotification({text = data.msg})
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(1)

    local pos = playerInfo.pos

    if (courseStart.dist < 65) then
      DrawMarker(1, courseStart.pos.x, courseStart.pos.y, courseStart.pos.z - 1.2, 0, 0, 0, 0, 0, 0, 1.7, 1.7, 0.4, 0, 255, 120, 145, 0, 0, 0, 0, 0, 0, 0)

      if (courseStart.dist < 10) then
        local dist = #(pos - courseStart.pos)
      
        if (dist < 1.1) then
          if (isPlayingGolf) then
            Draw3DEstText(courseStart.pos.x, courseStart.pos.y, courseStart.pos.z - 0.5, "Press ~b~E~s~ to end your round of ~g~Golf~s~.")
          else
            Draw3DEstText(courseStart.pos.x, courseStart.pos.y, courseStart.pos.z - 0.5, "Press ~b~E~s~ to start a round of ~g~Golf~s~ for ~g~$500~s~.")
          end

          if (IsControlJustReleased(1, 38) or IsDisabledControlJustReleased(1, 38)) then -- E pressed
            if (isPlayingGolf) then
              endgame("You have returned your clubs.")
            else
              TriggerServerEvent("bms:golf:startRound")
            end
          end
        end
      end
    end

    if (rentMarker.dist < 65) then
      DrawMarker(1, rentMarker.pos.x, rentMarker.pos.y, rentMarker.pos.z - 1.2, 0, 0, 0, 0, 0, 0, 1.7, 1.7, 0.4, 255, 37, 37, 145, 0, 0, 0, 0, 0, 0, 0)

      if (rentMarker.dist < 10) then
        local dist = #(pos - rentMarker.pos)

        if (dist < 1.1) then
          Draw3DEstText(rentMarker.pos.x, rentMarker.pos.y, rentMarker.pos.z - 0.5, "Press ~b~E~s~ to rent a Golf Cart for ~g~$500~s~.")
          if (IsControlJustReleased(1, 38)) then -- E pressed
            if (not rentBlock) then
              TriggerServerEvent("bms:golf:rentGolfCart")
            else
              exports.pnotify:SendNotification({text = "You must wait 1 minute before attempting to rent another golf cart."})
            end
          end
        end
      end
    end

    --[[DrawLine(boundary.aPos.x, boundary.aPos.y, boundary.aPos.z + 2, boundary.bPos.x, boundary.bPos.y, boundary.bPos.z + 2, 0, 0, 255, 255)
    DrawLine(boundary.bPos.x, boundary.bPos.y, boundary.bPos.z + 2, boundary.cPos.x, boundary.cPos.y, boundary.cPos.z + 2, 0, 0, 255, 255)
    DrawLine(boundary.cPos.x, boundary.cPos.y, boundary.cPos.z + 2, boundary.dPos.x, boundary.dPos.y, boundary.dPos.z + 2, 0, 0, 255, 255)
    DrawLine(boundary.dPos.x, boundary.dPos.y, boundary.dPos.z + 2, boundary.ePos.x, boundary.ePos.y, boundary.ePos.z + 2, 0, 0, 255, 255)
    DrawLine(boundary.ePos.x, boundary.ePos.y, boundary.ePos.z + 2, boundary.fPos.x, boundary.fPos.y, boundary.fPos.z + 2, 0, 0, 255, 255)
    DrawLine(boundary.fPos.x, boundary.fPos.y, boundary.fPos.z + 2, boundary.gPos.x, boundary.gPos.y, boundary.gPos.z + 2, 0, 0, 255, 255)
    DrawLine(boundary.gPos.x, boundary.gPos.y, boundary.gPos.z + 2, boundary.aPos.x, boundary.aPos.y, boundary.aPos.z + 2, 0, 0, 255, 255)]]

    --[[DrawLine(clubBoundary.pos1.x, clubBoundary.pos1.y, 80.0, clubBoundary.pos1.x, clubBoundary.pos2.y, 80.0, 0, 0, 255, 255)
    DrawLine(clubBoundary.pos1.x, clubBoundary.pos2.y, 80.0, clubBoundary.pos2.x, clubBoundary.pos2.y, 80.0, 0, 0, 255, 255)
    DrawLine(clubBoundary.pos2.x, clubBoundary.pos1.y, 80.0, clubBoundary.pos2.x, clubBoundary.pos2.y, 80.0, 0, 0, 255, 255)
    DrawLine(clubBoundary.pos1.x, clubBoundary.pos1.y, 80.0, clubBoundary.pos2.x, clubBoundary.pos1.y, 80.0, 0, 0, 255, 255)
    DrawLine(clubBoundary.pos1.x, clubBoundary.pos1.y, 80.0, clubBoundary.pos2.x, clubBoundary.pos2.y, 80.0, 0, 0, 255, 255)]]
  end
end)

Citizen.CreateThread(function()
  while true do
    Wait(2500)

    local ped = playerInfo.playerPedId
    local pos = playerInfo.pos

    courseStart.dist = #(pos - courseStart.pos)
    rentMarker.dist = #(pos - rentMarker.pos)

    -- If ped is not in the golf area, end game
    if (isPlayingGolf and (not IsEntityInArea(ped, clubBoundary.pos1.x, clubBoundary.pos1.y, clubBoundary.pos1.z, clubBoundary.pos2.x, clubBoundary.pos2.y, clubBoundary.pos2.z, 0, 1, 0))) then
      endgame("You have moved too far from the course and the game was <font color='#CF3732'>forfeit.</font>")
    end
  end
end)

--[[function sub_678ed(a_0)
  if (a_0 == 0xe47a3e41 or a_0 == 0x377b4131) then
    return 4
  elseif (a_0 == 0x8653c6cd or a_0 == 0x8dd4ebb9 or a_0 == 0x8f9cd58f or a_0 == 0xed932e53 or a_0 == 0x2114b37d or a_0 == 0x22ad7b72) then
    return 9
  elseif (a_0 == 0x846bc4ff or a_0 == 0x25612338) then
    return 8
  elseif (a_0 == 0xcdeb5023 or a_0 == 0x10dd5498 or a_0 == 0x1e6d775e or a_0 == 0x38bbd00c or a_0 == 0x46ca81e8) then
    return 1
  elseif (a_0 == 0x4f747b87) then
    return 2
  elseif (a_0 == 0xb34e900d) then
    return 3
  elseif (a_0 == 0xa0ebf7e4) then
    return 0
  elseif (a_0 == 0x19f81600) then
    return 7
  else
    return -1
  end
end]]

--[[ Friction for rolling over stuff upon landing
switch (sub_678ed(ENTITY::GET_LAST_MATERIAL_HIT_BY_ENTITY(v_6))) {
  case 1:
      v_1C = 0.89;
      v_1D = 0.75;
      v_1F = 0.2;
      v_1E = 0.3;
      break;
  case 4:
  case 9:
      v_1D = 0.25;
      v_1C = 0.85;
      v_1F = 0.5;
      v_1E = 0.15;
      break;
  case 0:
      v_1C = 0.35;
      v_1D = 0.0;
      v_1F = 0.2;
      v_1E = 0.0;
      break;
  case 7:
      v_1C = 0.5;
      break;
  case 2:
      v_1C = 0.85;
      v_1D = 0.5;
      v_1F = 0.55;
      v_1E = 0.3;
      break;
  case 3:
      v_1C = 0.85;
      v_1D = 0.3;
      v_1F = 0.55;
      v_1E = 1.2;
      break;
  case -1:
      break;
  }
]]
