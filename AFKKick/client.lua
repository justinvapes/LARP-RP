local secondsUntilKick = 1200
local actSecondsUntilKick = 800 -- change to 600
local kickWarning = true
local prevPos
local time
local atime
local afkPoints = {
  {name = "Mining Quarry", x = 2953.855, y = 2788.362, z = 51.523, range = 85.2}
}
local actChecker = false

function toggleAfkActionCheck(val)
  actChecker = val
  atime = actSecondsUntilKick
end

function isPlayerDead()
  local ped = PlayerPedId()
  return IsPlayerDead(ped)
end

function isPlayerCuffed()
  local ped = PlayerPedId()
  return IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)
end

--[[ Position checker ]]
Citizen.CreateThread(function()
  while true do
    Wait(1000)

    local ped = PlayerPedId()
    local dead = IsEntityDead(ped)
    local handcuffed = IsEntityPlayingAnim(ped, "mp_arresting", "idle", 3)
    local pos = GetEntityCoords(ped)

    --Citizen.Trace(type(pos) .. " " .. type(prevPos))

    if (pos and prevPos) then
      --Citizen.Trace(tostring(pos) .. " " .. tostring(prevPos))
      
      if (math.ceil(pos) == math.ceil(prevPos)) then
        for _,v in pairs(afkPoints) do
          local dist = Vdist(pos.x, pos.y, pos.z, v.x, v.y, v.z)

          if (dist < v.range) then
            if (time > 0) then
              if (kickWarning and time == math.ceil(secondsUntilKick / 4)) then
                TriggerEvent("chatMessage", "WARNING", {255, 50, 50}, "^1You will be kicked in " .. time .. " seconds for being AFK!")
                kickWarning = false
              end
              
              if (not dead and not handcuffed) then
                time = time - 1
              else
                time = secondsUntilKick
                kickWarning = true
              end
            else
              TriggerServerEvent("bms:afkkick:kickself", v.name)
            end
          else
            time = secondsUntilKick
            kickwarning = true
          end
        end
      else
        time = secondsUntilKick
        kickWarning = true
      end
    end

    prevPos = pos
  end
end)

--[[ Action checker, activated by export ]]
Citizen.CreateThread(function()
  while true do
    Wait(1000)

    if (actChecker) then
      local player = PlayerId()

      if (atime > 0) then
        if (NetworkIsPlayerTalking(player)) then
          atime = actSecondsUntilKick
          kickWarning = true
        else
          atime = atime - 1
        end

        if (kickWarning and atime <= math.ceil(actSecondsUntilKick / 4)) then
          kickWarning = false
          TriggerEvent("chatMessage", "WARNING", {255, 50, 50}, string.format("^1You will be kicked in %s seconds for being AFK!", atime))
        end
      else
        TriggerServerEvent("bms:afkkick:kickself", "Workout Area")
      end
    end
  end
end)