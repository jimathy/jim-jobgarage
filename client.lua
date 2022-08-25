local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end) end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo) PlayerJob = JobInfo end)

AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end
	QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end)
end)

local Targets = {}
local Parking = {}

--Garage Locations
CreateThread(function()
	for k, v in pairs(Config.Locations) do
		if v.garage then
			local out = v.garage.out
			Parking[#Parking+1] = makeProp({prop = `prop_parkingpay`, coords = vector4(out.x, out.y, out.z, out.w-180.0)}, 1, false)
			Targets["JobGarage: "..k] =
			exports['qb-target']:AddBoxZone("JobGarage: "..k, vector3(out.x, out.y, out.z-1.03), 0.8, 0.5, { name="JobGarage: "..k, heading = out[4]+180.0, debugPoly=Config.Debug, minZ=(out.z-1.03)-0.1, maxZ=(out.z-1.03)+1.3 },
				{ options = { { event = "jim-jobgarage:client:Garage:Menu", icon = "fas fa-clipboard", label = "Job Vehicles", job = v.job, coords = v.garage.spawn, list = v.garage.list, prop = Parking[#Parking] }, },
				distance = 2.0 })
		end
	end
end)

local currentVeh = { out = false, current = nil }
RegisterNetEvent('jim-jobgarage:client:Garage:Menu', function(data)
	lookEnt(data.prop)
	loadAnimDict("amb@prop_human_atm@male@enter")
	TaskPlayAnim(PlayerPedId(), 'amb@prop_human_atm@male@enter', "enter", 1.0,-1.0, 1500, 1, 1, true, true, true)
	local vehicleMenu = { { icon = "fas fa-car-tunnel", header = PlayerJob.label.." ".."Job Garage", isMenuHeader = true } }
	vehicleMenu[#vehicleMenu+1] = { icon = "fas fa-circle-xmark", header = "", txt = "Close", params = { event = "jim-jobgarage:client:Menu:Close" } }
	if currentVeh.out and DoesEntityExist(currentVeh.current) then
		vehicleMenu[#vehicleMenu+1] = { icon = "fas fa-clipboard-list", header = "Vehicle out of Garage",
										txt = "Vehicle: "..GetDisplayNameFromVehicleModel(GetEntityModel(currentVeh.current)).."<br> Plate: ["..GetVehicleNumberPlateText(currentVeh.current).."]",
										params = { event = "jim-jobgarage:client:Garage:Blip", }, }
		vehicleMenu[#vehicleMenu+1] = { icon = "fas fa-car-burst", header = "Remove Vehicle", params = { event = "jim-jobgarage:client:RemSpawn" } }
	else
		currentVeh = { out = false, current = nil }
		table.sort(data.list, function(a, b) return a:lower() < b:lower() end)
		for k, v in pairs(data.list) do
			local showButton = false
			if v.grade then if v.grade <= PlayerJob.grade.level then showButton = true end end
			if v.rank then for _, b in pairs(v.rank) do if b == PlayerJob.grade.level then showButton = true end end end
			if not v.grade and not v.rank then showButton = true end
			if showButton == true then
				local spawnName = k local spawnHash = GetHashKey(spawnName)
				if QBCore.Shared.Vehicles[spawnName] then k = QBCore.Shared.Vehicles[spawnName].name.." "..QBCore.Shared.Vehicles[spawnName].brand
				else k = string.lower(GetDisplayNameFromVehicleModel(spawnHash)) k = k:sub(1,1):upper()..k:sub(2).." "..GetMakeNameFromVehicleModel(GetHashKey(spawnHash)) end
				local classtable = {
					[8] = "fas fa-motorcycle", -- Motorcycle icon
					[9] = "fas fa-truck-monster", -- Off Road icon
					[10] = "fas fa-truck-front", -- Van / Truck icon
					[11] = "fas fa-truck-front", -- Van / Truck icon
					[12] = "fas fa-truck-front", -- Van / Truck icon
					[13] = "fas fa-bicycle", -- Bike
					[14] = "fas fa-ship", -- Boats
					[15] = "fas fa-helicopter",-- Helicopter
					[16] = "fas fa-plane", -- Planes
					[18] = "fas fa-kit-medical", -- Emergency
				}
				local seticon = classtable[GetVehicleClassFromName(spawnHash)] or "fas fa-car"
				vehicleMenu[#vehicleMenu+1] = { icon = seticon, header = k, params = { event = "jim-jobgarage:client:SpawnList", args = { spawnName = spawnName, coords = data.coords, list = v } } }
			end
		end
	end
	showButton = nil
	if #vehicleMenu <= 2 then triggerNotify(nil, "No vehicles available") return end
    exports['qb-menu']:openMenu(vehicleMenu)
	unloadAnimDict("amb@prop_human_atm@male@enter")
end)

RegisterNetEvent("jim-jobgarage:client:SpawnList", function(data)
	local oldveh = GetClosestVehicle(data.coords.x, data.coords.y, data.coords.z, 2.5, 0, 71)
	if oldveh ~= 0 then
		local name = GetDisplayNameFromVehicleModel(GetEntityModel(oldveh)):lower()
		for k, v in pairs(QBCore.Shared.Vehicles) do
			if tonumber(v.hash) == GetEntityModel(vehicle) then
				if Config.Debug then print("^5Debug^7: ^2Vehicle^7: ^6"..v.hash.." ^7(^6"..QBCore.Shared.Vehicles[k].name.."^7)") end
				name = QBCore.Shared.Vehicles[k].name
			end
		end
		triggerNotify(nil, name.." in the way", "error")
	else
		QBCore.Functions.SpawnVehicle(data.spawnName, function(veh)
			currentVeh = { out = true, current = veh }
			SetVehicleModKit(veh, 0)
			NetworkRequestControlOfEntity(veh)
			SetVehicleNumberPlateText(veh, string.sub(PlayerJob.label, 1, 5)..tostring(math.random(100, 999)))
			SetEntityHeading(veh, data.coords.w)
			TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
			if data.list.colors then SetVehicleColours(veh, data.list.colors[1], data.list.colors[2]) end
			if data.list.bulletproof then SetVehicleTyresCanBurst(veh, false) end
			if data.list.extras then
				for _, v in pairs(data.list.extras) do SetVehicleExtra(veh, v, 0) end
			end
			if data.list.livery then
				if GetNumVehicleMods(veh, 48) == 0 and GetVehicleLiveryCount(veh) ~= 0 then
					SetVehicleLivery(veh, data.list.livery)
					SetVehicleMod(veh, 48, -1, false)
				else
					SetVehicleMod(veh, 48, (data.list.livery - 1), false)
					SetVehicleLivery(veh, -1)
				end
			end
			TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
			SetVehicleEngineOn(veh, true, true)
			Wait(250)
			SetVehicleDirtLevel(veh, 0.0)
			triggerNotify(nil, "Retrieved "..GetDisplayNameFromVehicleModel(data.spawnName).." ["..GetVehicleNumberPlateText(currentVeh.current).."]", "success")
		end, data.coords, true)
	end
end)

RegisterNetEvent("jim-jobgarage:client:RemSpawn", function(data)
	if Config.CarDespawn then
		SetVehicleEngineHealth(currentVeh.current, 200.0)
		SetVehicleBodyHealth(currentVeh.current, 200.0)
		for i = 0, 7 do SmashVehicleWindow(currentVeh.current, i) Wait(150) end PopOutVehicleWindscreen(currentVeh.current)
		for i = 0, 5 do	SetVehicleTyreBurst(currentVeh.current, i, true, 0) Wait(150) end
		for i = 0, 5 do SetVehicleDoorBroken(currentVeh.current, i, false) Wait(150) end
		Wait(800)
	end
	QBCore.Functions.DeleteVehicle(currentVeh.current) currentVeh = { out = false, current = nil }
end)

local markerOn = false
RegisterNetEvent("jim-jobgarage:client:Garage:Blip", function(data)
	triggerNotify(nil, "Job Vehicle Marked on Map")
	if markerOn then markerOn = not markerOn end
	markerOn = true
	if not DoesBlipExist(garageBlip) then
		garageBlip = makeBlip({ coords = GetEntityCoords(currentVeh.current), sprite = 85, col = 8, name = "Job Vehicle" })
		SetBlipRoute(garageBlip, true)
		SetBlipRouteColour(garageBlip, 3)
	end
	while markerOn do
		local time = 5000
		local carLoc = GetEntityCoords(currentVeh.current)
		local playerLoc = GetEntityCoords(PlayerPedId())
		if DoesEntityExist(currentVeh.current) then
			local dist = #(carLoc - playerLoc)
			if dist <= 30.0 and dist > 1.5 then time = 1000
			elseif dist <= 1.5 then
				RemoveBlip(garageBlip)
				garageBlip = nil
				markerOn = not markerOn
			else time = 5000 end
		else
			RemoveBlip(garageBlip)
			garageBlip = nil
			markerOn = not markerOn
		end
		Wait(time)
	end
end)

AddEventHandler('onResourceStop', function(r) if r ~= GetCurrentResourceName() then return end
	for k in pairs(Targets) do exports['qb-target']:RemoveZone(k) end
	for i = 1, #Parking do unloadModel(GetEntityModel(Parking[i])) DeleteEntity(Parking[i]) end
end)