print("Jim-JobGarage v1.0 - Job Garage Script by Jimathy")

Config = {
	Debug = false,  -- Enable to use debug features
	CarDespawn = true, -- Disable to remove 
	Locations = {
		[1] = {
			zoneEnable = true,
			job = "mechanic",
			garage = { 
				spawn = vector4(-179.34, -1285.27, 30.83, 89.24),  -- Where the car will spawn
				out = vector4(-177.1, -1282.25, 31.3, 179.01),	-- Where the parking stand is
				list = {
					["cheburek"] = {
						--colors = { 136, 137 }, -- Color index numbers { primary, secondary },
						grade = 4, -- Job Grade Required to access this vehicle
					},
					["burrito3"] = { }, -- You don't need to put any modifiers in
					--["seasparrow"] = { },
					--["dinghy2"] = { },
					--["tribike"] = { },
					--["avarus"] = { },
					--["ambulance"] = { },
					--["police"] = { },
				},
			},
		},
		--[[[2] = {
			zoneEnable = true,
			job = "mechanic",
			garage = { 
				spawn = vector4(-179.34, -1285.27, 30.83, 89.24),
				out = vector4(-177.1, -1282.25, 31.3, 179.01),
				list = {
					["cheburek"] = { },
					["burrito3"] = { },
				},
			},
		},]]
	},
}
