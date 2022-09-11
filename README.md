# jim-jobgarage
Job garage for grabbing job related vehicles

---
# What is this?
- This is a dynamic system for pulling out job and grade locked vehicles
- **It's not for parking and saving your vehicles, that is done in your garage scripts**

![](https://i.imgur.com/JhGaGMS.jpeg)
![](https://i.imgur.com/ycXPTj1.jpeg)

### If you need support I have a discord server available, it helps me keep track of issues and give better support.
https://discord.gg/xKgQZ6wZvS

### If you think I did a good job here, consider donating as it keeps by lights on and my cat fat/floofy:
https://ko-fi.com/jixelpatterns

---
# Installation

- I always recommend starting my scripts **AFTER** `[qb]` not inside it as it can mess with any dependancies on server load
- I have a separate folder called `[jim]` (that is also in the resources folder) that starts WAY after everything else.
- This ensure's it has everything it requires before trying to load
- Example of my load order:
```CSS
# QBCore & Extra stuff
ensure qb-core
ensure [qb]
ensure [standalone]
ensure [voice]
ensure [defaultmaps]
ensure [vehicles]

# Extra Jim Stuff
ensure [jim]
```

---
## Location Setup

- Vehicle Modifiers - These can be used for making sure the vehicles comes out exactly how you want it to
	- `CustomName = "Police Car",` this will show a custom override name for your vehicles so you don't need to add them to your vehicles.lua
	- `rank = { 2, 4 },` This specifes which grades can see it, and only these grades
	- `grade = 4,` This specifies the lowest grade and above that can see the vehicle
	- `colors = { 136, 137 },` This is the colour index id of the vehicle, Primary and Secondary in that order
	- `bulletproof = true,` This determines if the tyres are bullet proof (don't ask me why, I was asked to add this)
	- `livery = 1,` This sets the livery id of the vehicle, (most mod menus would number them or have them in number order) 0 = stock
	- `extras = { 1, 5 },` -- This enables the selected extras on the vehicle
	- `performance = "max",` -- This sets the car upgrades all to MAX levels
	- `performance = { 2, 3, 3, 2, 4, true },` -- This allows more specific settings for each upgrade level, in order: engine, brakes, suspension, transmission, armour, turbo
	- `trunkItems = { },` -- Use this to add items to the trunk of the vehicle when it is spawned

- Example:
```lua
Locations = {
	{	zoneEnable = true, -- disable if you want to hide this temporarily
		job = "mechanic", -- set this to required job grade
		garage = {
			spawn = vector4(-179.34, -1285.27, 30.83, 89.24),  -- Where the vehicle will spawn
			out = vector4(-177.1, -1282.25, 31.3, 179.01),  -- Where you select the vehicles from
			ped = { -- Add a "ped" table to make a ped spawn instead of the parking meter
				model = `G_M_M_ChemWork_01`, -- set ped model here
				scenario = "WORLD_HUMAN_CLIPBOARD" -- set scenario here
			},
			list = {  -- The list of cars that will spawn
				["cheburek"] = {
					CustomName = "Police Car",
					colors = { 136, 137 }, -- Color index numbers { primary, secondary },
					grade = 4, -- Job Grade Required to access this vehicle
					performance = { 2, 3, 3, 2, 4, true },
					trunkItems = {
						{ name = "heavyarmor", amount = 2, info = {}, type = "item", slot = 1, },
						{ name = "empty_evidence_bag", amount = 10, info = {}, type = "item", slot = 2, },
						{ name = "police_stormram", amount = 1, info = {}, type = "item", slot = 3, },
					},
				},
				["burrito3"] = { },  -- Don't need to add any modifiers/restrictions
			},
		},
	},
},
```
