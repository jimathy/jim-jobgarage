print("Jim-JobGarage v1.1 - Job Garage Script by Jimathy")

--[[	LIST OF POSSIBLE VEHICLE MODIFIERS   ]]--
-- Using these will change how each vehicle spawns
-- This can be used for making sure the vehicles comes out exactly how you want it to

-- rank = { 2, 4 }, -- This specifes which grades can see it, and only these grades
-- grade = 4, -- This specifies the lowest grade and above that can see the vehicle
-- colors = { 136, 137 }, -- This is the colour index id of the vehicle, Primary and Secondary in that order
-- bulletproof = true, -- This determines if the tyres are bullet proof (don't ask me why, I was asked to add this)
-- livery = 1, -- This sets the livery id of the vehicle, (most mod menus would number them or have them in number order) 0 = stock
-- extras = { 1, 5 }, -- This enables the selected extras on the vehicle

-- ANY VEHICLE, BOATS, POLICE CARS, EMS VEHICLES OR EVEN PLANES CAN BE ADDED.

Config = {
	Debug = false,  -- Enable to use debug features
	CarDespawn = true, -- Sends the vehicle to hell
	Locations = {
		{
			zoneEnable = true,
			job = "mechanic",
			garage = {
				spawn = vector4(-179.34, -1285.27, 30.83, 89.24),  -- Where the car will spawn
				out = vector4(-177.1, -1282.25, 31.3, 179.01),	-- Where the parking stand is
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
		{
			zoneEnable = true,
			job = "police",
			garage = {
				spawn = vector4(435.41, -975.93, 25.31, 90.86),
				out = vector4(441.39, -974.78, 25.7, 178.49),
				list = {
					["police"] = {
						livery = 5,
						extras = { 1, 2 },
					},
					["fbi"] = {
						rank = { 4 },
					},
				},
			},
		},
	},
}
