local QBCore = exports[Config.Core]:GetCoreObject()

local Locations = Config.Locations

QBCore.Functions.CreateCallback('jim-jobgarage:server:syncLocations', function(source, cb) cb(Locations) end)

RegisterNetEvent('jim-jobgarage:server:syncAddLocations', function(data)
	local dupe = false
	for _, v in pairs(Locations) do	for k in pairs(v) do if k == "garage" then if v.garage.out == data.garage.out then dupe = true end end end end
	if dupe == true then return
	else
		if type(data.garage.list[1]) == "string" then local list = {} for k, v in pairs(data.garage.list) do list[v] = {} end data.garage.list = list end
		Locations[#Locations+1] = { zoneEnable = true, job = data.job, garage = data.garage, }
		if Config.Debug then
			local coords = { string.format("%.2f", data.garage.out.x), string.format("%.2f", data.garage.out.y), string.format("%.2f", data.garage.out.z), (string.format("%.2f", data.garage.out.w or 0.0)) }
			print("^5Debug^7: ^2Adding new ^3JobGarage^2 location^7: ^5vec4^7(^6"..(coords[1]).."^7, ^6"..(coords[2]).."^7, ^6"..(coords[3]).."^7, ^6"..(coords[4]).."^7)")
		end
		TriggerClientEvent("jim-jobgarage:client:syncLocations", -1, Locations)
	end
end)

RegisterNetEvent("jim-jobgarage:server:syncLocations", function() TriggerClientEvent('jim-jobgarage:client:syncLocations', -1, Locations) end)

RegisterNetEvent("jim-jobgarage:server:addTrunkItems", function(plate, items) exports["qb-inventory"]:addTrunkItems(plate, items) end)

local function CheckVersion()
	PerformHttpRequest('https://raw.githubusercontent.com/jimathy/jim-jobgarage/master/version.txt', function(err, newestVersion, headers)
		local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
		if not newestVersion then print("Currently unable to run a version check.") return end
		local advice = "^1You are currently running an outdated version^7, ^1please update^7"
		if newestVersion:gsub("%s+", "") == currentVersion:gsub("%s+", "") then advice = '^6You are running the latest version.^7'
		else print("^3Version Check^7: ^2Current^7: "..currentVersion.." ^2Latest^7: "..newestVersion) end
		print(advice)
	end)
end
CheckVersion()