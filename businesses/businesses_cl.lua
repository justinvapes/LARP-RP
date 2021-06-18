function drawBusinessText(text)
  SetTextFont(0)
  SetTextProportional(0)
  SetTextScale(0.32, 0.32)
  SetTextColour(173, 216, 230, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(0.475, 0.88)
end

--[[ Tattoo shop related ]]

RegisterNUICallback("bms:businesses:tsaddfunds", function(data)
  TriggerEvent("bms:tattooshop:getLastShopIndex", function(index)
    data.tatid = index
    exports.management:TriggerServerCallback("bms:tattooshop:tsaddfunds", function(cash)
      if (cash) then
        SendNUIMessage({setTsFunds = true, amount = cash})
      end
    end, data)
  end)
end)

RegisterNUICallback("bms:businesses:tsremfunds", function(data)
  TriggerEvent("bms:tattooshop:getLastShopIndex", function(index)
    data.tatid = index
    exports.management:TriggerServerCallback("bms:tattooshop:tsremfunds", function(cash)
      if (cash) then
        SendNUIMessage({setTsFunds = true, amount = cash})
      end
    end, data)
  end)
end)

RegisterNUICallback("bms:businesses:tsChangeSettings", function(data)
  TriggerEvent("bms:tattooshop:getLastShopIndex", function(index)
    data.tatid = index
    exports.management:TriggerServerCallback("bms:tattooshop:tsChangeSettings", function(data)
      if (data) then
        TriggerEvent("bms:tattooshop:tsChangeSettings", data)
        SetNuiFocus(false, false)
      end
    end, data)
  end)
end)

AddEventHandler("bms:businesses:tattooshop:getManagement", function(index)
  exports.management:TriggerServerCallback("bms:tattooshop:getManagement", function(data)
    if (data) then
      SendNUIMessage({showTsManage = true, cash = data.cash, markup = data.markup, shopname = data.shopname, thanksmessage = data.thanksmessage})
      SetNuiFocus(true, true)
    end
  end, index)
end)

--[[ End Tattoo Shop stuff ]]
