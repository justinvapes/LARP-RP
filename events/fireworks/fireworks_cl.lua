local table_insert = table.insert
local fwAnim = {dict = "anim@mp_fireworks", anim = "place_firework_3_box"}
local fwPfx = {
  --[[cat = "scr_indep_fireworks",
  pfxs = {
    "scr_indep_firework_trailburst",
    "scr_indep_firework_fountain"
  }]]
  ["scr_indep_fireworks"] = {
    "scr_indep_firework_trailburst",
    "scr_indep_firework_fountain"
  },
  ["proj_indep_firework_v2"] = {
    "scr_xmas_firework_burst_fizzle"
  }
}
local fwSettings = {}
local prop = {}
local fireworks = {}

function doFireworks()
  local rndCats = {}

  for pfxCat, pfxData in pairs(fwPfx) do
    table_insert(rndCats, pfxCat)
  end

  Citizen.CreateThread(function()
    local fireTimes = 0

    while (not HasAnimDictLoaded(fwAnim.dict)) do
      RequestAnimDict(fwAnim.dict)
      Wait(10)
    end

    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    TaskPlayAnim(ped, fwAnim.dict, fwAnim.anim, 4.0, 4.0, 3000)
    Wait(4000)
    StopAnimTask(ped, fwAnim.dict, fwAnim.anim, 2.0)

    prop.entity = CreateObject(GetHashKey(fwSettings.fwProp), pos, true)
    PlaceObjectOnGroundProperly(prop.entity)
    FreezeEntityPosition(prop.entity, true)

    local fwPos = GetEntityCoords(prop.entity)

    Wait(10000)

    repeat
      local rndCat = rndCats[math.random(1, #rndCats)]
      local rndName = fwPfx[rndCat][math.random(1, #fwPfx[rndCat])] --math.random(1, #fwPfx[rndCat])

      while (not HasNamedPtfxAssetLoaded(rndCat)) do
        RequestNamedPtfxAsset(rndCat)
        Wait(10)
      end

      fireTimes = fireTimes + 1
      UseParticleFxAssetNextCall(rndCat)
      prop.npfx = StartNetworkedParticleFxNonLoopedAtCoord(rndName, fwPos, 0.0, 0.0, 0.0, 1.0)
      Wait(2000)
    until (fireTimes == fwSettings.fireTimes)
    
    DeleteEntity(prop.entity)    
  end)
end

function doFireworksAuto(count)
  if (not count) then return end
  
  local ped = PlayerPedId()
  local positions = {}
  local curOffset = 0.0
  local iter = 0

  fireworks = {}

  for i = 1, count do
    curOffset = curOffset + 5.0    
    pedOffset = GetOffsetFromEntityInWorldCoords(ped, 0.0, curOffset, 1.0)
    table_insert(positions, pedOffset)
  end

  local rndCats = {}

  for pfxCat, pfxData in pairs(fwPfx) do
    table_insert(rndCats, pfxCat)
  end

  Citizen.CreateThread(function()
    print(json.encode(positions, {indent = true}))
    for _, fwPos in ipairs(positions) do
      iter = iter + 1
      fireworks[iter] = {
        entity = CreateObject(GetHashKey(fwSettings.fwProp), fwPos, true),
        fireTimes = 0,
        handleAutoFirework = function(iter)
          Citizen.CreateThread(function()
            PlaceObjectOnGroundProperly(fireworks[iter].entity)
            FreezeEntityPosition(fireworks[iter].entity, true)

            local fwStartPos = GetEntityCoords(fireworks[iter].entity)

            Wait(5000)
            
            repeat
              local rndCat = rndCats[math.random(1, #rndCats)]
              local rndName = fwPfx[rndCat][math.random(1, #fwPfx[rndCat])]
        
              while (not HasNamedPtfxAssetLoaded(rndCat)) do
                RequestNamedPtfxAsset(rndCat)
                print("requesting dict " .. rndCat)
                Wait(10)
              end
        
              fireworks[iter].fireTimes = fireworks[iter].fireTimes + 1
              UseParticleFxAssetNextCall(rndCat)
              StartNetworkedParticleFxNonLoopedAtCoord(rndName, fwStartPos, 0.0, 0.0, 0.0, 1.0)
              Wait(2000)
            until (fireworks[iter].fireTimes == fwSettings.fireTimes)

            DeleteEntity(fireworks[iter].entity)
            fireworks[iter] = nil
          end)
        end
      }
      fireworks[iter].handleAutoFirework(iter)
    end
  end)
end

RegisterNetEvent("bms:events:fw:init")
AddEventHandler("bms:events:fw:init", function(data)
  fwSettings = data.fwSettings or {}

  if (data.doFire) then
    doFireworks()
  elseif (data.autoFire and data.autoFireCount) then
    doFireworksAuto(data.autoFireCount)
  end
end)

AddEventHandler("onResourceStop", function(res)
  if (res == GetCurrentResourceName()) then
    for _,v in pairs(fireworks) do
      if (v.entity) then
        DeleteEntity(v.entity)
      end
    end
  end
end)