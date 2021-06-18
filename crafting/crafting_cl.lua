local wasBigMap = false
local menuShowing = true
local skillsShowing = false

RegisterNetEvent("bms:crafting:initMenu")
AddEventHandler("bms:crafting:initMenu", function()
  exports.actionmenu:addCategory("Statistics", 7)
  --exports.actionmenu:addAction("statistics", "skills", "none", "Skills", 7, -1)

  TriggerEvent("bms:jobs:fishing:initMenu")
end)

RegisterNetEvent("bms:crafting:skillChanged", function(data)
  if (data) then
    SendNUIMessage({skillChanged = true, skid = data.skid, skval = skval})
  end
end)

function toggleSkills()
  if (skillsShowing) then
    SendNUIMessage({showSkills = true})
  else
    SendNUIMessage({hideSkills = true})
  end
end

Citizen.CreateThread(function()
  while true do
    Wait(10)

    local act = GetCurrentFrontendMenu()

    if (act == -1171018317) then
      if (not wasBigMap) then
        wasBigMap = true
        exports.management:TriggerServerCallback("bms:crafting:getPlayerSkills", function(ret)
          if (ret) then
            menuShowing = true
            SendNUIMessage({renderSkills = true, skills = ret, open = true})
          end
        end)
      end

      if (IsControlJustReleased(1, 74) or IsDisabledControlJustReleased(1, 74)) then
        skillsShowing = not skillsShowing
        toggleSkills()
      end
    elseif (wasBigMap) then
      wasBigMap = false
      menuShowing = false
      SendNUIMessage({hideSkills = true})
    end
  end
end)