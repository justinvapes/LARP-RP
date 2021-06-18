if not IsDuplicityVersion() then
	Citizen.CreateThread(function()
		while true do
				Wait(0)

				if NetworkIsSessionStarted() then
					TriggerServerEvent("Queue:playerActivated")
					TriggerServerEvent('hardcap:playerActivated')
					return
				end
		end
	end)
	
	return
end