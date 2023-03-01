RegisterNetEvent('jim-jobgarage:server:syncAddLocations', function(data)
	Config.Locations[#Config.Locations+1] = { zoneEnable = true, job = data.job, garage = data.garage, }
	TriggerClientEvent("jim-jobgarage:client:syncLocations", -1, Config.Locations)
end)

RegisterNetEvent("jim-jobgarage:server:syncLocations", function() TriggerClientEvent("jim-jobgarage:client:syncLocations", -1, Config.Locations) end)

RegisterNetEvent("jim-jobgarage:server:addTrunkItems", function(plate, items) exports["qb-inventory"]:addTrunkItems(plate, items) end)

local function CheckVersion()
	PerformHttpRequest('https://raw.githubusercontent.com/jimathy/jim-jobgarage/master/jim-jobgarage.txt', function(err, newestVersion, headers)
		local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
		if not newestVersion then print("Currently unable to run a version check.") return end
		local advice = "^1You are currently running an outdated version^7, ^1please update^7"
		if newestVersion:gsub("%s+", "") == currentVersion:gsub("%s+", "") then advice = '^6You are running the latest version.^7'
		else print("^3Version Check^7: ^2Current^7: "..currentVersion.." ^2Latest^7: "..newestVersion) end
		print(advice)
	end)
end
CheckVersion()