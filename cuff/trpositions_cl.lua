trunkData = { -- For any custom distances for longer vehicles
  --["mySuperCoolCarModel"] = {dist = 4.5}
}

trunkExceptions = { -- Since we added Vans to the class detector to keep out pickups, we will need to manually add the actual vans.
  --[[ Van allows ]]
  ["boxville"] = true,
  ["boxville2"] = true,
  ["boxville2"] = true,
  ["boxville3"] = true,
  ["boxville4"] = true,
  ["boxville5"] = true,
  ["burrito"] = true,
  ["burrito2"] = true,
  ["burrito3"] = true,
  ["burrito4"] = true,
  ["burrito5"] = true,
  ["camper"] = true,
  ["gburrito"] = true,
  ["gburrito2"] = true,
  ["journey"] = true,
  ["minivan"] = true,
  ["minivan2"] = true,
  ["paradise"] = true,
  ["pony"] = true,
  ["pony2"] = true,
  ["rumpo"] = true,
  ["rumpo2"] = true,
  ["rumpo3"] = true,
  ["speedo"] = true,
  ["speedo2"] = true,
  ["surfer"] = true,
  ["surfer2"] = true,
  ["taco"] = true,
  ["youga"] = true,
  ["youga2"] = true,
  --[[ Off-road allows ]]
  ["brawler"] = true,
  ["lguard"] = true,
  ["mesa"] = true,
  ["mesa2"] = true,
  ["mesa3"] = true,
  ["rancherxl"] = true,
  ["rancherxl2"] = true
}

trunkDisallows = { -- Some vehicles are mis-classed, so we will still need this
  ["yosemite"] = true
}

function inverseHashes()
  local new = {}
  
  for model, data in pairs(trunkData) do
    new[GetHashKey(model)] = data
  end

  trunkData = new

  local newEx = {}

  for model, _ in pairs(trunkExceptions) do
    newEx[GetHashKey(model)] = true
  end

  trunkExceptions = newEx

  local newDis = {}

  for model, _ in pairs(trunkDisallows) do
    newDis[GetHashKey(model)] = true
  end

  trunkDisallows = newDis
end

inverseHashes()

--[[
  Since the trunk model number table was a terrible way to store the vehicles, they inevitably changed and got fucked up.
 ]]
--[[trnotrunk = {
  "bison3", "yosemite", "emperor", "emperor2", "romero", "blista3", "brioso", "issi", "issi3", "panto", "prairie", "exemplar", "f620", "felon2", "windsor2", "ninef", "ninef2", "bestiagts",
  "carbonizzare", "comet2", "comet3", "comet5", "coquette", "tampa2", "flashgt", "furoregt", "fuselade", "jester", "jester2", "massacro", "massacro2", "omnis", "pariah", "revolter",
  "ruston", "sentinel3", "specter", "specter2", "tropos", "verlierer", "banshee2", "taipan",

  -- LEO vehicles
  "crownvic", "charger18", "taurus", "camaroV2", "mustang", "explorer", "tahoe", "silverado", "ram", "policeb4", "pdgtr", "pbuffalo", "pgresley", "pinterceptor", "pkuruma", "pyosemite", "pdriot",
  "ert2", "pbus", "smallboat", "hillboaty", "largeboat", "sd350", "lasd", "RIOT5", "chpriot", "spcharger", "spcharger2", "umcharger", "spimpala", "umcapres", "sptaurus", "spvic", "umvic",
  "camaro", "challenger", "ferrari", "gtr", "spsilv", "sptahoe", "spf350", "ramb", "spexplorer", "umtahoeb", "polschafter3", "spcoquette", "spbike", "charger14"
}]]