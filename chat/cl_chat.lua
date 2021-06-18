local chatInputActive = false
local chatInputActivating = false
local chatMute = false
local showOoc = true
local isStringOoc = false
local showOnChatMessage = true
local blockChatKeyOpen = false

function toggleBlockChatKeyOpen(toggle)
  blockChatKeyOpen = toggle
end

function toggleShowChatOnMessage(val)
  if (val == nil) then
    val = false
  end

  showOnChatMessage = val
  SendNUIMessage({type = "ON_TOGGLE_CHAT_OPEN_ON_MSG", cval = val})
end

function showChatOnMessageValue()
  return showOnChatMessage
end

RegisterNetEvent("chatMessage")
RegisterNetEvent("chat:addTemplate")
RegisterNetEvent("chat:addMessage")
RegisterNetEvent("chat:addSuggestion")
RegisterNetEvent("chat:removeSuggestion")
RegisterNetEvent("chat:clear")

-- internal events
RegisterNetEvent("__cfx_internal:serverPrint")

--deprecated, use chat:addMessage
AddEventHandler("chatMessage", function(author, color, text)
  isStringOoc = string.match(author, "^%^7%[OOC]")
  if (not showOoc and isStringOoc) then
    return
  else
    local args = { text }
    
    if author ~= "" then
      table.insert(args, 1, author)
    end
    
    SendNUIMessage({type = "ON_MESSAGE", message = {color = color, multiline = true, args = args}})
  end
end)

AddEventHandler("__cfx_internal:serverPrint", function(msg)
  -- disables the client redirecting server prints to the client console, hopefully this won't break anything important
  --[[print(msg)
  SendNUIMessage({
    type = "ON_MESSAGE",
    message = {
      color = { 0, 0, 0 },
      multiline = true,
      args = { msg }
    }
  })]]
end)

AddEventHandler("chat:addMessage", function(message)
  SendNUIMessage({type = "ON_MESSAGE", message = message})
end)

RegisterNetEvent("chat:hideChat")
AddEventHandler("chat:hideChat", function(message)
  SendNUIMessage({type = "ON_CLOSE"})
end)

AddEventHandler("chat:addSuggestion", function(name, help, params)
  SendNUIMessage({type = "ON_SUGGESTION_ADD", suggestion = {name = name, help = help, params = params or nil}})
end)

AddEventHandler("chat:removeSuggestion", function(name)
  SendNUIMessage({type = "ON_SUGGESTION_REMOVE", name = name})
end)

AddEventHandler("chat:addTemplate", function(id, html)
  SendNUIMessage({type = "ON_TEMPLATE_ADD", template = {id = id, html = html}})
end)

AddEventHandler("chat:clear", function(name)
  SendNUIMessage({type = "ON_CLEAR"})
end)

RegisterNetEvent("bms:chat:messageEntered")

RegisterNUICallback("chatResult", function(data, cb)
  chatInputActive = false
  SetNuiFocus(false, false)

  if not data.canceled then
    local id = PlayerId()
    local r, g, b = 170, 170, 170

    if data.message:sub(1, 1) == "/" then
      if (chatMute and (data.message:sub(1, 3) == "/hc" or data.message:sub(1, 3) == "/ic" or data.message:sub(1, 2) == "/r" or data.message:sub(1, 5) == "/rtow")) then
        exports.pnotify:SendNotification({text = "Your chat has been muted by an administrator."})
        TriggerEvent("chatMessage", "SERVER", {255, 0, 0}, "Your chat has been muted by an administrator.")
      else
        ExecuteCommand(data.message:sub(2))
      end
    else
      if (chatMute) then
        exports.pnotify:SendNotification({text = "Your chat has been muted by an administrator."})
        TriggerEvent("chatMessage", "SERVER", {255, 0, 0}, "Your chat has been muted by an administrator.")
      else
        if (showOoc) then
          TriggerServerEvent("bms:chat:messageEntered", "^7[OOC]", { r, g, b }, data.message)
        else
          exports.pnotify:SendNotification({text = "You have OOC chat disabled.  Type <font color='skyblue'>'/ooc on'</font> to enable it."})
        end
      end
    end
  end
end)

RegisterNUICallback("loaded", function(data, cb)
  TriggerServerEvent("chat:init")
end)

RegisterNetEvent("bms:chat:setChatMute")
AddEventHandler("bms:chat:setChatMute", function(mute)
  chatMute = (mute == 1)
end)

RegisterNetEvent("bms:chat:toggleOoc")
AddEventHandler("bms:chat:toggleOoc", function(toggle)
  showOoc = toggle
end)

RegisterNetEvent("bms:chat:addSuggestions")
AddEventHandler("bms:chat:addSuggestions", function(suggestions)
  for _,v in pairs(suggestions) do
    TriggerEvent("chat:addSuggestion", v.command, v.helpText, v.params or {})
  end
end)

RegisterNetEvent("bms:chat:remSuggestions")
AddEventHandler("bms:chat:remSuggestions", function(suggestions)
  for _,v in pairs(suggestions) do
    TriggerEvent("chat:removeSuggestion", v.command)
  end
end)

Citizen.CreateThread(function()
  SetTextChatEnabled(false)
  SetNuiFocus(false, false)
end)

RegisterCommand("+chat", function()
  if (blockChatKeyOpen) then return end
  
  if (not chatInputActive) then
    chatInputActive = true
    chatInputActivating = true
    SendNUIMessage({type = "ON_OPEN"})
  end
end, false)

RegisterCommand("-chat", function()
  if (blockChatKeyOpen) then return end

  if (chatInputActivating) then
    chatInputActivating = false

    SetNuiFocus(true, false)
    SetNuiFocusKeepInput(false)
  end
end, false)

RegisterKeyMapping("+chat", "Chat Key", "keyboard", "T")