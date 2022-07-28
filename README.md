# jim-jobgarage
Job garage for grabbing job related vehicles

---
# What is this?
- This is a dynamic system for pulling out job and grade locked vehicles
- **It's not for parking and saving your vehicles, that is done in your garage scripts**

![](https://i.imgur.com/JhGaGMS.jpeg)
![](https://i.imgur.com/ycXPTj1.jpeg)


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
	- `rank = { 2, 4 },` This specifes which grades can see it, and only these grades
	- `grade = 4,` This specifies the lowest grade and above that can see the vehicle
	- `colors = { 136, 137 },` This is the colour index id of the vehicle, Primary and Secondary in that order
	- `bulletproof = true,` This determines if the tyres are bullet proof (don't ask me why, I was asked to add this)
	- `livery = 1,` This sets the livery id of the vehicle, (most mod menus would number them or have them in number order) 0 = stock
	- `extras = { 1, 5 },` -- This enables the selected extras on the vehicle
- Example:
```lua
Locations = {
		{
		zoneEnable = true, -- disable if you want to hide this temporarily
		job = "mechanic", -- set this to required job grade
		garage = {
			spawn = vector4(-179.34, -1285.27, 30.83, 89.24),  -- Where the vehicle will spawn
			out = vector4(-177.1, -1282.25, 31.3, 179.01),  -- Where you select the vehicles from
			list = {  -- The list of cars that will spawn
				["cheburek"] = {
					colors = { 136, 137 }, -- Color index numbers { primary, secondary },
					grade = 4, -- Job Grade Required to access this vehicle
				},
				["burrito3"] = { },  -- Don't need to add any modifiers/restrictions
			},
		},
		},
	},
```
