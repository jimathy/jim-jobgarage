# jim-jobgarage
Job garage for grabbing job related vehicles

# What is this?

This is a dynamic system for pulling out job and grade locked vehicles 

It's not for parking your vehicles, that is done in your garage scripts

![](https://i.imgur.com/JhGaGMS.jpeg)
![](https://i.imgur.com/ycXPTj1.jpeg)
# Installation

Couldn't be simpler.
- Put in your resources
- Add it to the server.cfg
- Add your required locations
- Done
```lua
Locations = {
		[1] = {
			zoneEnable = true, -- disable if you want to hide this temporarily 
			job = "mechanic", -- set this to required job grade
			garage = { 
				spawn = vector4(-179.34, -1285.27, 30.83, 89.24),  -- Where the vehicle will spawn
				out = vector4(-177.1, -1282.25, 31.3, 179.01),  -- Where you select the vehicles from
				list = {
					["cheburek"] = {
						--colors = { 136, 137 }, -- Color index numbers { primary, secondary },
						grade = 4, -- Job Grade Required to access this vehicle
					},
					["burrito3"] = { },  -- Don't need to add any modifiers/restrictions
				},
			},
		},
	},
```
