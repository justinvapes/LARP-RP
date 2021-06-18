resource_manifest_version "77731fab-63ca-442c-a67b-abc70f28dfa5"

ui_page "html/inventory.html"

server_exports {
  "checkCategoryQty",
  "getInvLimits",
  "getInventoryLock",
  "awaitInventoryLock",
  "releaseInventoryLock",
  "remAddItems",
  "remAddItemsLock",
  "itemExistsInInv",
  "checkInvItemLimits",
  "invItemExists",
  "invItemExistsInInv",
  "updateItemMetadata"
}

files {
  "html/inventory.html",
  "html/inventory.js",
  "html/inventory.css",
  "html/giveitem.png",
  "html/trans_right.png",
  "html/trans_left.png",
  "html/trans_left_disabled.png",
  "html/trans_right_disabled.png",
  "html/hex-background.png",
  "html/jquery/jquery-ui.min.css",
  "html/jquery/jquery-ui.structure.min.css",
  "html/jquery/jquery-ui.theme.min.css",
  "html/jquery/ui-bg_glass_95_fef1ec_1x400.png",
  "html/jquery/bootstrap-input-spinner.js",
  --[[ inventory icons ]]
  "html/images/trans-up.png",
  "html/images/trans-down.png",
  "html/images/resizer.png",
  "html/dinvicons/*"
}

exports {
  "itemExistsInInv",
  "getInventoryItem",
  "getInventory",
  "setCharMoney",
  "getCharMoney",
  "setCanTrade",
  "getCanTrade",
  "blockInventoryUse", -- blocks/unblocks clicking an item for breakdown
  "showTransfer",
  "blockInventoryOpen",
  "unblockTransfer",
  "blockTrade", -- blocks trading, dropping, moving to trunk
  "isTradeBlocked",
  "getFishCount",
  "addInventorySorter",
  "getClosedTime",
  "setClosedTime"
}

client_scripts{
  "inventory_cl.lua"
}
server_scripts {
  "inventory_sv.lua",
  "storagelimits_sv.lua",
  "@mysql-async/lib/MySQL.lua"
}
