local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end) end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo) PlayerJob = JobInfo end) 

AddEventHandler('onResourceStart', function(resource) if GetCurrentResourceName() ~= resource then return end
	QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end)
end)

local Targets = {}
local parking = {}
--Garage Locations
CreateThread(function()
	for k, v in pairs(Config.Locations) do job = v.job
		if v.garage then
			local out = v.garage.out
			Targets[#Targets] = 
			exports['qb-target']:AddBoxZone("JobGarage: "..k, vector3(out.x, out.y, out.z-1.03), 0.8, 0.5, { name="JobGarage: "..k, heading = out[4]+180.0, debugPoly=Config.Debug, minZ=(out.z-1.03)-0.1, maxZ=out.z-1.03+1.3 }, 
				{ options = { { event = "jim-jobgarage:client:Garage:Menu", icon = "fas fa-clipboard", label = "Job Vehicles", job = job, coords = v.garage.spawn, list = v.garage.list }, },
				distance = 2.0 })
			RequestModel(`prop_parkingpay`) while not HasModelLoaded(`prop_parkingpay`) do Citizen.Wait(1) end
			parking[#parking+1] = CreateObject(`prop_parkingpay`, out.x, out.y, out.z-1.03,false,false,false)
			SetEntityHeading(parking[#parking], out[4]+180.0)
			FreezeEntityPosition(parking[#parking], true)
		end
	end
end)

local currentVeh = { out = false, current = nil }
RegisterNetEvent('jim-jobgarage:client:Garage:Menu', function(data)
	RequestAnimDict('amb@prop_human_atm@male@enter') while not HasAnimDictLoaded('amb@prop_human_atm@male@enter') do Wait(1) end
	if HasAnimDictLoaded('amb@prop_human_atm@male@enter') then TaskPlayAnim(PlayerPedId(), 'amb@prop_human_atm@male@enter', "enter", 1.0,-1.0, 1500, 1, 1, true, true, true) end
	
	local vehicleMenu = { { icon = "fas fa-car-tunnel", header = PlayerJob.label.." ".."Job Garage", isMenuHeader = true } }	
	vehicleMenu[#vehicleMenu + 1] = { icon = "fas fa-circle-xmark", header = "", txt = "Close", params = { event = "jim-jobgarage:client:Menu:Close" } }
	if currentVeh.out and DoesEntityExist(currentVeh.current) then
		vehicleMenu[#vehicleMenu+1] = { icon = "fas fa-clipboard-list", header = "Vehicle out of Garage", 
										txt = "Vehicle: "..GetDisplayNameFromVehicleModel(GetEntityModel(currentVeh.current)).."<br> Plate: ["..GetVehicleNumberPlateText(currentVeh.current).."]",
										params = { event = "jim-jobgarage:client:Garage:Blip", }, }
		vehicleMenu[#vehicleMenu+1] = { icon = "fas fa-car-burst", header = "Remove Vehicle", params = { event = "jim-jobgarage:client:RemSpawn" } }
	else
		currentVeh = { out = false, current = nil }
		table.sort(data.list, function(a, b) return a:lower() < b:lower() end)
		for k,v in pairs(data.list) do
			if not v.grade or PlayerJob.grade.level >= v.grade then
				local spawnName = k
				if QBCore.Shared.Vehicles[spawnName] then k = QBCore.Shared.Vehicles[spawnName].name.." "..QBCore.Shared.Vehicles[spawnName].brand
				else k = string.lower(GetDisplayNameFromVehicleModel(GetHashKey(spawnName))) k = k:sub(1,1):upper()..k:sub(2).." "..GetMakeNameFromVehicleModel(GetHashKey(tostring(spawnName))) end
				local seticon = "fas fa-car"
				local class = GetVehicleClassFromName(GetHashKey(spawnName))
				if class == 8 then seticon = "fas fa-motorcycle" end -- Motorcycle icon
				if class == 9 then seticon = "fas fa-truck-monster" end -- Off Road icon
				if class == 10 or class == 11 or class == 12 then seticon = "fas fa-truck-front" end -- Van / Truck icon
				if class == 13 then seticon = "fas fa-bicycle" end -- Bike
				if class == 14 then seticon = "fas fa-ship" end -- Boats
				if class == 15 then seticon = "fas fa-helicopter" end -- Helicopter
				if class == 16 then seticon = "fas fa-plane" end -- Planes
				if class == 18 then seticon = "fas fa-kit-medical" end -- Emergency
				vehicleMenu[#vehicleMenu+1] = { icon = seticon, header = k, params = { event = "jim-jobgarage:client:SpawnList", args = { spawnName = spawnName, coords = data.coords, list = v } } }
			end
		end
	end
	if #vehicleMenu <= 2 then TriggerEvent("QBCore:Notify", "No vehicles available") return end
    exports['qb-menu']:openMenu(vehicleMenu)
end)

RegisterNetEvent("jim-jobgarage:client:SpawnList", function(data)
	local oldveh = GetClosestVehicle(data.coords.x, data.coords.y, data.coords.z, 2.5, 0, 71)
	if oldveh ~= 0 then
		local name = GetDisplayNameFromVehicleModel(GetEntityModel(oldveh)):lower()
		for k, v in pairs(QBCore.Shared.Vehicles) do
			if tonumber(v.hash) == GetEntityModel(vehicle) then
			if Config.Debug then print("Vehicle: "..v.hash.." ("..QBCore.Shared.Vehicles[k].name..")") end
			name = QBCore.Shared.Vehicles[k].name
			end
		end
		TriggerEvent("QBCore:Notify", name.." in the way", "error")
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
			TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
			SetVehicleEngineOn(veh, true, true)
			Wait(250)
			SetVehicleDirtLevel(veh, 0.0)
			TriggerEvent("QBCore:Notify", "Retrieved "..GetDisplayNameFromVehicleModel(data.spawnName).." ["..GetVehicleNumberPlateText(currentVeh.current).."]", "success")
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
	TriggerEvent("QBCore:Notify", "Job Vehicle Marked on Map")
	if markerOn then markerOn = not markerOn end
	markerOn = true
	local carBlip = GetEntityCoords(currentVeh.current)
	if not DoesBlipExist(garageBlip) then 
		garageBlip = AddBlipForCoord(carBlip.x, carBlip.y, carBlip.z)
		SetBlipColour(garageBlip, 8)
		SetBlipRoute(garageBlip, true)
		SetBlipSprite(garageBlip, 85)
		SetBlipRouteColour(garageBlip, 3)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString("Job Vehicle")
		EndTextCommandSetBlipName(garageBlip)
	end
	while markerOn do
		local time = 5000
		local carLoc = GetEntityCoords(currentVeh.current)
		local playerLoc = GetEntityCoords(PlayerPedId())
		if DoesEntityExist(currentVeh.current) then
			if #(carLoc - playerLoc) <= 30.0 then time = 100
			elseif #(carLoc - playerLoc) <= 1.5 then
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
	for k, v in pairs(Config.Locations) do if v.garage then exports['qb-target']:RemoveZone("JobGarage: "..k) end end
	for i = 1, #parking do DeleteEntity(parking[i]) end
end)
