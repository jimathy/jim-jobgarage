local QBCore = exports[Config.Core]:GetCoreObject()

local Targets, Parking, PlayerJob, Locations = {}, {}, {}, {}

local function removeTargets() for k in pairs(Targets) do exports['qb-target']:RemoveZone(k) end Targets = {} for i = 1, #Parking do DeleteEntity(Parking[i]) Wait(10) end Parking = {}  end
local function makeTargets()
	removeTargets()
	for i = 1, #Locations do
		if Locations[i].garage then
			if Locations[i].trunkItems then
				local items = {}
				for _, item in pairs(Locations[i].trunkItems) do
					local itemInfo = QBCore.Shared.Items[item.name:lower()]
					items[item.slot] = {
						name = itemInfo["name"],
						amount = tonumber(item.amount),
						info = item.info,
						label = itemInfo["label"],
						description = itemInfo["description"] and itemInfo["description"] or "",
						weight = itemInfo["weight"],
						type = itemInfo["type"],
						unique = itemInfo["unique"],
						useable = itemInfo["useable"],
						image = itemInfo["image"],
						slot = item.slot,
					}
				end
				Locations[i].garage.list[k].trunkItems = items
			end

			local out = Locations[i].garage.out
			if Locations[i].garage.ped then Parking[#Parking+1] = makePed(Locations[i].garage.ped.model, out, 1, 1, Locations[i].garage.ped.scenario)
			else Parking[#Parking+1] = makeProp({prop = "prop_parkingpay", coords = vec4(out.x, out.y, out.z, out.w-180.0)}, true, false) end
			Targets["JobGarage: "..i] =
				exports['qb-target']:AddBoxZone("JobGarage: "..i, vec3(out.x, out.y, out.z-1.03), 0.8, 0.5, { name="JobGarage: "..i, heading = out.w+180.0, debugPoly=Config.Debug, minZ=out.z-1.05, maxZ=out.z+0.80 },
					{ options = { { event = "jim-jobgarage:client:Garage:Menu", icon = "fas fa-clipboard", label = Loc[Config.Lan].target["label"], job = Locations[i].job, spawncoords = Locations[i].garage.spawn, list = Locations[i].garage.list, prop = Parking[#Parking] }, },
					distance = 2.0 })
		end
	end
end

local function syncLocations() local p = promise.new() QBCore.Functions.TriggerCallback('jim-jobgarage:server:syncLocations', function(cb) p:resolve(cb) end) Locations = Citizen.Await(p) makeTargets() end

RegisterNetEvent("jim-jobgarage:client:syncLocations", function(newLocations) Locations = newLocations makeTargets() end)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()	QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end)	Wait(10000) syncLocations() end)
RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo) PlayerJob = JobInfo end)
AddEventHandler('onResourceStart', function(r) if GetCurrentResourceName() ~= r then return end	QBCore.Functions.GetPlayerData(function(PlayerData) PlayerJob = PlayerData.job end) Wait(10000) syncLocations() end)

local currentVeh = { out = false, current = nil }
RegisterNetEvent('jim-jobgarage:client:Garage:Menu', function(data)
	if not IsPedInAnyVehicle(PlayerPedId()) then
		lookEnt(data.prop)
		loadAnimDict("amb@prop_human_atm@male@enter")
		TaskPlayAnim(PlayerPedId(), 'amb@prop_human_atm@male@enter', "enter", 1.0,-1.0, 1500, 1, 1, true, true, true)
	end
	local vehicleMenu = {}
	if Config.Menu == "qb" then
		vehicleMenu[#vehicleMenu+1] = { icon = "fas fa-car-tunnel", header = PlayerJob.label.." "..Loc[Config.Lan].menu["jobtitle"], isMenuHeader = true }
		vehicleMenu[#vehicleMenu+1] = { icon = "fas fa-circle-xmark", header = "", txt = Loc[Config.Lan].menu["close"], params = { event = "jim-jobgarage:client:Menu:Close" } }
	end
	if currentVeh.out and DoesEntityExist(currentVeh.current) then
		vehicleMenu[#vehicleMenu+1] = {
			icon = "fas fa-clipboard-list",
			header = "Vehicle out of Garage", txt = Loc[Config.Lan].menu["vehicle"].." ["..currentVeh.name.."<br> "..Loc[Config.Lan].menu["plate"].." ["..GetVehicleNumberPlateText(currentVeh.current).."]",
			title = "Vehicle out of Garage", description = Loc[Config.Lan].menu["vehicle"].." ["..currentVeh.name.."\n "..Loc[Config.Lan].menu["plate"].." ["..GetVehicleNumberPlateText(currentVeh.current).."]",
			event = "jim-jobgarage:client:Garage:Blip",
			params = { event = "jim-jobgarage:client:Garage:Blip", },
		}
		local carLoc, playerLoc = GetEntityCoords(currentVeh.current), GetEntityCoords(PlayerPedId())
		local dist = #(carLoc - playerLoc)
		if (Config.distCheck and dist <= 30.0) or not Config.distCheck then
			vehicleMenu[#vehicleMenu+1] = {
				icon = "fas fa-car-burst",
				header = Loc[Config.Lan].menu["remvehicle"],
				title = Loc[Config.Lan].menu["remvehicle"],
				event = "jim-jobgarage:client:RemSpawn",
				params = { event = "jim-jobgarage:client:RemSpawn" }
			}
		end
	else
		currentVeh = { out = false, current = nil }
		table.sort(data.list, function(a, b) return a:lower() < b:lower() end)
		for k, v in pairsByKeys(data.list) do
			local showButton = false
			if v.grade then if v.grade <= PlayerJob.grade.level then showButton = true end end
			if v.rank then for _, b in pairs(v.rank) do if b == PlayerJob.grade.level then showButton = true end end end
			if not v.grade and not v.rank then showButton = true end
			if showButton == true then
				local spawnName = k local spawnHash = GetHashKey(spawnName)
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
				vehicleMenu[#vehicleMenu+1] = {
					icon = seticon,
					header = (data.list[k].CustomName or searchCar(k)),
					title = (data.list[k].CustomName or searchCar(k)),
					event = "jim-jobgarage:client:SpawnList", args = { spawnName = spawnName, spawncoords = data.spawncoords, list = v },
					params = { event = "jim-jobgarage:client:SpawnList", args = { spawnName = spawnName, spawncoords = data.spawncoords, list = v } }
				}
			end
		end
	end
	showButton = nil
	if Config.Menu == "ox" then
		exports.ox_lib:registerContext({id = 'vehicleMenu', title = PlayerJob.label.." "..Loc[Config.Lan].menu["jobtitle"], position = 'top-right', options = vehicleMenu })
		exports.ox_lib:showContext("vehicleMenu")
	elseif Config.Menu == "qb" then
		exports['qb-menu']:openMenu(vehicleMenu)
	end
	unloadAnimDict("amb@prop_human_atm@male@enter")
end)

RegisterNetEvent("jim-jobgarage:client:SpawnList", function(data)
	local oldveh = GetClosestVehicle(data.spawncoords.x, data.spawncoords.y, data.spawncoords.z, 2.5, 0, 71)
	local name = ""
	if oldveh ~= 0 then
		name = searchCar(GetEntityModel(oldveh))
		triggerNotify(nil, name.." "..Loc[Config.Lan].error["vehclose"], "error")
	else
		QBCore.Functions.SpawnVehicle(data.spawnName, function(veh)
			local name = data.list.CustomName or searchCar(data.spawnName)
			currentVeh = { out = true, current = veh, name = name }
			SetVehicleModKit(veh, 0)
			NetworkRequestControlOfEntity(veh)
			SetVehicleNumberPlateText(veh, string.sub(PlayerJob.label, 1, 5)..tostring(math.random(100, 999)))
			--SetVehicleNumberPlateText(veh, "PD-"..QBCore.Functions.GetPlayerData().metadata.callsign)
			SetEntityHeading(veh, data.spawncoords.w)
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
			if data.list.performance then
				if type(data.list.performance) ~= "table" then
					SetVehicleMod(veh, 11, GetNumVehicleMods(veh, 11)-1) -- Engine
					SetVehicleMod(veh, 12, GetNumVehicleMods(veh, 12)-1) -- Brakes
					SetVehicleMod(veh, 15, GetNumVehicleMods(veh, 15)-1) -- Suspension
					SetVehicleMod(veh, 13, GetNumVehicleMods(veh, 13)-1) -- Transmission
					SetVehicleMod(veh, 16, GetNumVehicleMods(veh, 16)-1) -- Armour
					ToggleVehicleMod(veh, 18, true) -- Turbo
				else
					SetVehicleMod(veh, 11, data.list.performance[1]-1) -- Engine
					SetVehicleMod(veh, 12, data.list.performance[2]-1) -- Brakes
					SetVehicleMod(veh, 15, data.list.performance[3]-1) -- Suspension
					SetVehicleMod(veh, 13, data.list.performance[4]-1) -- Transmission
					SetVehicleMod(veh, 16, data.list.performance[5]-1) -- Armour
					ToggleVehicleMod(veh, 18, data.list.performance[6]) -- Turbo
				end
			end
			if data.list.trunkItems then TriggerServerEvent("jim-jobgarage:server:addTrunkItems", QBCore.Functions.GetPlate(veh), data.list.trunkItems) end
			TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
			exports[Config.Fuel]:SetFuel(veh, 100.0)
			SetVehicleEngineOn(veh, true, true)
			Wait(250)
			SetVehicleDirtLevel(veh, 0.0)
			triggerNotify(nil, Loc[Config.Lan].success["spawned"].." "..name.." ["..GetVehicleNumberPlateText(currentVeh.current).."]", "success")
		end, data.spawncoords, true)
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
	triggerNotify(nil, Loc[Config.Lan].success["blipcreate"], "success")
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
	if GetResourceState("qb-target") == "started" or GetResourceState("ox_target") == "started" then
		for k in pairs(Targets) do exports['qb-target']:RemoveZone(k) end
		for i = 1, #Parking do unloadModel(GetEntityModel(Parking[i])) DeleteEntity(Parking[i]) end
	end
end)