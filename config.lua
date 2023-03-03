print("^2Jim^7-^2JobGarage ^7v^41^7.^44^7.^43 ^7- ^2Job Garage Script by ^1Jimathy^7")

Loc = {}

--[[	LIST OF POSSIBLE VEHICLE MODIFIERS   ]]--
-- Using these will change how each vehicle spawns
-- This can be used for making sure the vehicles comes out exactly how you want it to

-- CustomName = "Police Car", this will show a custom override name for your vehicles so you don't need to add them to your vehicles.lua
-- rank = { 2, 4 }, -- This specifes which grades can see it, and only these grades
-- grade = 4, -- This specifies the lowest grade and above that can see the vehicle
-- colors = { 136, 137 }, -- This is the colour index id of the vehicle, Primary and Secondary in that order
-- bulletproof = true, -- This determines if the tyres are bullet proof (don't ask me why, I was asked to add this)
-- livery = 1, -- This sets the livery id of the vehicle, (most mod menus would number them or have them in number order) 0 = stock
-- extras = { 1, 5 }, -- This enables the selected extras on the vehicle
-- performance = "max", this sets the stats to max if available
-- performance = { 2, 3, 3, 2, 4, true }, -- This allows more specific settings for each upgrade level, in order: engine, brakes, suspension, transmission, armour, turbo
-- trunkItems = { }, -- Use this to add items to the trunk of the vehicle when it is spawned

-- ANY VEHICLE, BOATS, POLICE CARS, EMS VEHICLES OR EVEN PLANES CAN BE ADDED.

Config = {
	Debug = false,  -- Enable to use debug features
	Lan = "en",

	Core = "qb-core",
	Menu = "qb",
	Notify = "qb",

	Fuel = "LegacyFuel", -- Set this to your fuel script folder

	CarDespawn = true, -- Sends the vehicle to hell (removal animation)

	DistCheck = false, -- Require the vehicle to be near by to remove it

	Locations = {
		{ 	zoneEnable = true,
			job = "mechanic",
			garage = {
				spawn = vec4(-179.34, -1285.27, 30.83, 89.24),  -- Where the car will spawn
				out = vec4(-177.1, -1282.25, 31.3, 179.01),	-- Where the parking stand is
				list = {
					["cheburek"] = {
						colors = { 136, 137 },
						grade = 4,
						livery = 5,
						bulletproof = true,
						extras = { 1, 4 },
					},
					["burrito3"] = { },
				},
			},
		},
		{ 	zoneEnable = true,
			job = "police",
			garage = {
				spawn = vec4(435.41, -975.93, 25.31, 90.86),
				out = vec4(441.39, -974.78, 25.7, 178.49),
				list = {
					["police"] = {
						CustomName = "Police Car",
						livery = 5,
						extras = { 1, 2 },
						performance = "max",
						trunkItems = {
							{ name = "heavyarmor", amount = 2, info = {}, type = "item", slot = 1, },
							{ name = "empty_evidence_bag", amount = 10, info = {}, type = "item", slot = 2, },
							{ name = "police_stormram", amount = 1, info = {}, type = "item", slot = 3, },
						},
					},
					["fbi"] = {
						rank = { 4 },
						performance = { 2, 3, 3, 2, 4, true },
					},
				},
			},
		},
		{ 	zoneEnable = true,
			job = "ambulance",
			garage = {
				spawn = vec4(294.95, -606.92, 43.24, 64.84),
				out = vec4(294.54, -599.52, 43.28, 159.68),
				list = {
					["ambulance"] = {
						CustomName = "Ambulance"
					},
				},
			},
		},
	},
}
