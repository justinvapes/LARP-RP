local active = false
local lastpos
local dbias = 10
local ondutycop = false

RegisterNetEvent("bms:lawenf:dispatcher:setactive")
AddEventHandler("bms:lawenf:dispatcher:setactive", function(val)
  active = val
end)

AddEventHandler("bms:lawenf:activedutyswitch", function(onduty)
  ondutycop = onduty
end)

--[[Citizen.CreateThread(function()
  while true do
    Wait(2000)

    if (ondutycop and active) then
      local ped = PlayerPedId()
      local pos = GetEntityCoords(ped)

      if (not lastpos) then
        lastpos = pos
      else
        local dist = Vdist(pos.x, pos.y, pos.z, lastpos.x, lastpos.y, lastpos.z)
        
        if (dist > dbias) then
          local street = table.pack(GetStreetNameAtCoord(pos.x, pos.y, pos.z))
          local streetname
          
          if street[2] ~= 0 and street[2] ~= nil then
            streetname = string.format("%s and %s", GetStreetNameFromHashKey(street[1]), GetStreetNameFromHashKey(street[2]))
          else
            streetname = string.format("%s", GetStreetNameFromHashKey(street[1]))
          end

          --TriggerServerEvent("bms:lawenf:dispatcher:dispatch", {type = "pupdate", data = {pos = {x = pos.x, y = pos.y, z = pos.z}, street = streetname}}) -- Needs changed to a server call to reduce bandwidth
          lastpos = pos
        end
      end
    end
  end
end)]]