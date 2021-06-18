resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

ui_page "html/crafting.html"

files {
    "html/crafting.html",
    "html/crafting.css",
    "html/crafting.js",
    "html/images/cm_content.png"
}

server_exports {
    "registerSkill",
    "getSkill",
    "getSkillIdCb",
    "getSkillFromId",
    "getSkillFromIdCb",
    "getSkills",
    "increaseSkill",
    "increaseSkillPerAmount",
    "getSkillValForSrc",
    "decreaseSkillForPlayer",
    "decreaseSkillMulti",
    "getAttachmentNameFromHash"
}

client_scripts{
    "crafting_cl.lua",
    "weaponsmith_cl.lua"
}

server_scripts {
    "crafting_sv.lua",
    "weaponsmith_sv.lua",
    "@mysql-async/lib/MySQL.lua"
}