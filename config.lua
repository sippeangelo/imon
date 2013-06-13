local cf = {}

--PowerBarColor["MANA"] = { 68/255, 138/255, 231/255 }

-- CONFIG
cf["actionbars"] = {
	["enabled"] = false,
	["fading"] = {
		["combatalpha"] = 0.3, 		-- Alpha of actionbars while in combat
		["nocombatalpha"] = 0,		-- Alpha of actionbars while out of combat
		["cooldownalpha"] = 1,		-- Alpha of spells on cooldown
		["mouseoveralhpa"] = 1,		-- Alpha of actionbars when mouseovered
	},
	["showname"] = false,			-- Show spell names on icons
}

cf["unitframes"] = {
	["enabled"] = true,
	["width"] = 340,
	
	["health"] = {
		["enabled"] = true,
		["height"] = 47,
		
		-- Override unit names!
		["name_overrides"] = {
			["Al'Akir"] = "Al Fakir",
		},
		
		-- Minimum HP indicator
		["minhp"] = true,
	},
	
	["power"] = {
		["enabled"] = true,
		["height"] = 24,
	},
	
	["castbar"] = {
		["enabled"] = true,
		["height"] = 20,
	},
}

cf["scripts"] = {
	-- Automatic buff cancelling when not moving
	["buffcancel"] = {
		["enabled"] = true,
		["cancel"] = {			-- List of buffs to cancel (doesn't work for shapeshifts)
			"Aspect of the Cheetah",
			"Aspect of the Pack",
		},
		["delay"] = 3,			-- Global delay in seconds
	},
	
	-- Allows reloading the UI with the /rl chat command
	["reload"] = {
		["enabled"] = true,
	},
	
	-- Readycheck
	["readycheck"] = {
		["enabled"] = true,
		
		["randompos"] = true, 				-- Readycheck appears in a random position on the screen every time
		["combatautodecline"] = true,		-- Decline readychecks issued in combat
		["autoaccept"] = false,				-- Autoaccept all readychecks
	},
	
	-- Rolecheck
	["rolecheck"] = {
		["enabled"] = true,
		
		["nodoublettes"] = false,	-- Ignore role checks when you already have assigned a role
		["dpsauto"] = true, 		-- Auto choose DPS if it's the only option
	},	
	
	-- Play sounds when wiped or killed a boss (Requires DBM)
	["victorysounds"] = {
		["enabled"] = true,
		
		["victory"] = {
			["enabled"] = true,
			["sounds"] = {
				"always.mp3",
				"AnywayYou.mp3",
				"blarsa_you-make-me.mp3",
				"boomboom.mp3",
				"china.mp3",
				"coburn.mp3",
				"hardwarestore.mp3",
				"hubbahubba.mp3",
				"japanbreakindustries.mp3",
				"jeanlucpicard.mp3",
				"livin_on_a_prayer.mp3",
				"moskau.mp3",
				"move.mp3",
				"nevergonnagiveyouup.mp3",
				"ohyeah.mp3",
				"popcorn.mp3",
				"promise.mp3",
				"runninginthe90s.mp3",
				"stampontheground.mp3",
				"surfinbird.mp3",
				"tagswhistle4.mp3",
				"thebeginningoftime.mp3",
				"tingalin.mp3",
				"whatislove.mp3",
				"woohoo.mp3",
				"chariotsoffire.mp3",
				"eyeofthetiger.mp3",
				"champions.mp3",
				"wherethehoodat.mp3",				
				"stillalive.mp3",				
				"nyan.mp3",				
				"chickenman1.mp3",				
				"chickenman2.mp3",		
				"goldenageofvideo.mp3",	
				"numanuma.mp3",
				"caramelldansen.mp3",
				"captainkirk.mp3",
				"barrelroll.mp3",
				"nightofknights.mp3",
				"yeahyeahwowwow.mp3",
			},
		},
		
		["wipe"] = {
			["enabled"] = true,
			["sounds"] = {
				"keyboardcat.mp3",
				"priceisright.mp3",
				"trombone.mp3",
			},
		},		
	},
}

imon.cf = cf