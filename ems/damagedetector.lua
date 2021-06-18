local wepdescriptors = {
  {hash = "WEAPON_HEAVYPISTOL", desc = "small caliber gun shot wounds"},
  {hash = "WEAPON_STUNGUN", desc = "electrical burn wounds"},
  {hash = "WEAPON_NIGHTSTICK", desc = "long bruises with blunt force trauma"},
  {hash = "WEAPON_PUMPSHOTGUN", desc = "scattered small caliber gun shot wounds"},
  {hash = "WEAPON_CARBINERIFLE", desc = "large caliber automatic gun shot wounds"},
  {hash = "WEAPON_MICROSMG", desc = "small caliber automatic gun shot wounds"},
  {hash = "WEAPON_COMBATPDW", desc = "small caliber automatic gun shot wounds"},
  {hash = "WEAPON_FLASHLIGHT", desc = "medium bruising with blunt force trauma"},
  {hash = "WEAPON_FIREEXTINGUISHER", desc = "blunt force trauma"},
  {hash = "WEAPON_PETROLCAN", desc = "blunt force trauma with a strong gasoline smell"},
  {hash = "WEAPON_BZGAS", desc = "mild chemical burns"},
  {hash = "WEAPON_FLARE", desc = "moderate burn wounds"},
  {hash = "WEAPON_ASSAULTSMG", desc = "small caliber automatic gun shot wounds"},
  {hash = "WEAPON_SPECIALCARBINE", desc = "small caliber automatic gun shot wounds"},
  {hash = "WEAPON_ASSAULTSHOTGUN", desc = "scattered small caliber gun shot wounds"},
  {hash = "WEAPON_KNIFE", desc = "serrated stab and cut wounds"},
  {hash = "WEAPON_BAT", desc = "long cylindrical bruising with blunt force trauma"},
  {hash = "WEAPON_CROWBAR", desc = "blunt force trauma and long bruising with stab wounds at the end"},
  {hash = "WEAPON_GOLFCLUB", desc = "long thin bruises with blunt force trauma at the end"},
  {hash = "WEAPON_DAGGER", desc = "deep stab wounds"},
  {hash = "WEAPON_KNUCKLE", desc = "knuckle shaped bruising"},
  {hash = "WEAPON_MACHETE", desc = "large stab wound with long slashing wounds"},
  {hash = "WEAPON_WRENCH", desc = "large bruises with blunt force trauma"},
  {hash = "WEAPON_PISTOL", desc = "small caliber gun shot wounds"},
  {hash = "WEAPON_SNSPISTOL", desc = "small caliber gun shot wounds"},
  {hash = "WEAPON_COMBATPISTOL", desc = "small caliber gun shot wounds"},
  {hash = "WEAPON_HEAVYPISTOL", desc = "small caliber gun shot wounds"},
  {hash = "WEAPON_PISTOL50", desc = "small caliber gun shot wounds"},
  {hash = "WEAPON_SWITCHBLADE", desc = "moderately deep stab wounds with slashing wounds"},
  {hash = "WEAPON_REVOLVER", desc = "large caliber gun shot wounds"},
  {hash = "WEAPON_MARKSMANPISTOL", desc = "large caliber gun shot wounds"},
  {hash = "WEAPON_SAWNOFFSHOTGUN", desc = "scattered small caliber gun shot wounds"},
  {hash = "WEAPON_COMPACTRIFLE", desc = "large caliber gun shot wounds"},
  {hash = "WEAPON_SMG", desc = "small caliber automatic gun shot wounds"},
  {hash = "WEAPON_BULLPUPRIFLE", desc = "small caliber automatic gun shot wounds"},
  {hash = "WEAPON_CARBINERIFLE", desc = "large caliber automatic gun shot wounds"},
  {hash = "WEAPON_ASSAULTSMG", desc = "small caliber automatic gun shot wounds"},
  {hash = "WEAPON_MACHINEPISTOL", desc = "small caliber automatic gun shot wounds"},
  {hash = "WEAPON_MINISMG", desc = "small caliber automatic gun shot wounds"},
  {hash = "WEAPON_BATTLEAXE", desc = "long slashing and cutting wounds"},
  {hash = "WEAPON_POOLCUE", desc = "long bruises with traces of a blue chalky substance"},
  {hash = "WEAPON_BALL", desc = "large round bruise"},
  {hash = "WEAPON_DBSHOTGUN", desc = "scattered small caliber gun shot wounds"},
  {hash = "WEAPON_GUSENBERG", desc = "small caliber automatic gun shot wounds"},
  {hash = "WEAPON_ASSAULTRIFLE_MK2", desc = "large caliber automatic gun shot wounds"},
  {hash = "WEAPON_CARBINERIFLE_MK2", desc = "large caliber automatic gun shot wounds"},
  {hash = "WEAPON_COMBATMG_MK2", desc = "large caliber automatic gun shot wounds"},
  {hash = "WEAPON_PISTOL_MK2", desc = "small caliber gun shot wounds"},
  {hash = "WEAPON_SMG_MK2", desc = "small caliber automatic gun shot wounds"},
  {hash = "WEAPON_ASSAULTSHOTGUN", desc = "scattered small caliber gun shot wounds"},
}

function getWeaponDamageString()
  local ped = PlayerPedId()
  local dmgstr = ""
  
  for i,v in ipairs(wepdescriptors) do
    if (HasPedBeenDamagedByWeapon(ped, GetHashKey(v.hash), 0)) then
      if (not dmgstr:match(v.desc)) then
        dmgstr = string.format("%s %s, ", dmgstr, v.desc)
      end
    end
  end

  dmgstr = dmgstr:sub(1, -3)

  if (dmgstr == "") then
    dmgstr = "no visible melee or gun shot wounds"
  end

  return dmgstr
end

RegisterNetEvent("bms:ems:getDamageTypes")
AddEventHandler("bms:ems:getDamageTypes", function(event)
  local dmgstr = getWeaponDamageString()
  
  if (event) then
    TriggerEvent(event, dmgstr)
  else  
    TriggerEvent("chatMessage", "EMS", {0, 0, 255}, string.format("You notice %s.", dmgstr))
  end
end)