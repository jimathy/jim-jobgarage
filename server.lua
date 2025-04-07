createCallback('jim-jobgarage:server:syncLocations', function(source)
	return Locations
end)

RegisterNetEvent('jim-jobgarage:server:syncAddLocations', function(data)
	local dupe = false
	for _, v in pairs(Locations) do
		for k in pairs(v) do
			if k == "garage" then
				if v.garage.out == data.garage.out then
					dupe = true
				end
			end
		end
	end
	if dupe == true then return
	else
		if type(data.garage.list[1]) == "string" then
			local list = {}
			for k, v in pairs(data.garage.list) do
				list[v] = {}
			end
			data.garage.list = list
		end
		Locations[#Locations+1] = { zoneEnable = true, job = data.job, garage = data.garage, }
		if Config.Debug then
			local coords = { string.format("%.2f", data.garage.out.x), string.format("%.2f", data.garage.out.y), string.format("%.2f", data.garage.out.z), (string.format("%.2f", data.garage.out.w or 0.0)) }
			print("^5Debug^7: ^2Adding new ^3JobGarage^2 location^7: ^5vec4^7(^6"..(coords[1]).."^7, ^6"..(coords[2]).."^7, ^6"..(coords[3]).."^7, ^6"..(coords[4]).."^7)")
		end
		TriggerClientEvent("jim-jobgarage:client:syncLocations", -1, Locations)
	end
end)

RegisterNetEvent("jim-jobgarage:server:syncLocations", function()
	TriggerClientEvent('jim-jobgarage:client:syncLocations', -1, Locations)
end)

RegisterNetEvent("jim-jobgarage:server:addTrunkItems", function(plate, items)
	local src = source
	jsonPrint(items)
	if isStarted(OXInv) then
		for i = 1, #items do
			addItem(items[i].name, items[i].amount, items[i].info, "trunk"..plate)
		end
	end
	if isStarted(QBInv) then
		exports[QBInv]:OpenInventory(src, "trunk-"..plate)
		Wait(100)
		TriggerClientEvent('qb-inventory:client:closeInv', src)
		for i = 1, #items do
			exports[QBInv]:AddItem("trunk-"..plate, items[i].name, items[i].amount, nil, items[i].info)
		end
	end
end)