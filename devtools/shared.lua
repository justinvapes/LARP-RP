local eventPrefix = GetCurrentResourceName() .. ":"

if IsDuplicityVersion() then
	local registerServerEvent, addEventHandler = RegisterServerEvent, AddEventHandler

	local events = {}

	function RegisterServerEvent(event)
		events[event] = math.random(0xBAFF1ED)
		return registerServerEvent(event)
	end

	function AddEventHandler(event, func)
		if events[event] then
			return addEventHandler(event, function(code, ...)
				if code ~= events[event] then
					DropPlayer(source, "Invalid server call.")
					return CancelEvent()
				end

				return func(...)
			end)
		end

		return addEventHandler(event, func)
	end

	registerServerEvent(eventPrefix .. "getEvents")
	addEventHandler(eventPrefix .. "getEvents", function()
		TriggerClientEvent(eventPrefix .. "recieveEvents", source, events)
	end)
else
	local triggerServerEvent = TriggerServerEvent

	local events

	RegisterNetEvent(eventPrefix .. "recieveEvents")
	AddEventHandler(eventPrefix .. "recieveEvents", function(_events)
		events = _events
	end)

	function TriggerServerEvent(event, ...)
		while not events do Citizen.Wait(25) end
		return triggerServerEvent(event, events[event], ...)
	end

	triggerServerEvent(eventPrefix .. "getEvents")
end