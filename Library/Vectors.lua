X = {}

------------------------------
-- Other Constants/Enums etc.
------------------------------

------------------------------
-- Lane Info
------------------------------
LANE_HEAD_RAD = Vector(-6455, -5717, 0)
LANE_HEAD_DIRE = Vector(6450, 5869, 0)
LANE_MID_RAD = Vector(12995, 11286, 0)
LANE_MID_DIRE = Vector(-12995, -11286, 0)

------------------------------
-- Neutral Camp Locations/Info
------------------------------

--actual camp
RAD_MID_MEDIUM = Vector(-38.0, -4987.0, 1278.0)
RAD_MID_HARD = Vector(897.0, -3205.0, 1216.0)
RAD_MID_HARDTWO = Vector(-1834.0, -4807.0, 1187.0)
RAD_SAFE_MEDIUM = Vector(4527.0, -4133.0, 1142.0)
RAD_SAFE_EASY = Vector(3479.0, -4962.0, 1189.0)
RAD_SAFE_HARD = Vector(2464.0, -4675.0, 1222.0)
RAD_OFF_ANCIENT = Vector(-4823.0, -694.0, 1260.0)
RAD_OFF_EASY = Vector(-2499.0, -1164.0, 1199.0)
RAD_OFF_HARD = Vector(-3800.0, 800.0, 256.0)
DIRE_MID_MEDIUM = Vector(1300.0, 3300.0, 384.0)
DIRE_MID_HARD = Vector(-200.0, 3400.0, 256.0)
DIRE_MID_ANCIENT = Vector(-850.0, 2275.0, 384.0)
DIRE_SAFE_MEDIUM = Vector(-1850.0, 4075.0, 256.0)
DIRE_SAFE_EASY = Vector(-2619.000000, 4764.000000, 0.000000)
DIRE_SAFE_HARD = Vector(-4500.0, 3550.0, 256.0)
DIRE_OFF_ANCIENT = Vector(2650.0, 75.0, 384.0)
DIRE_OFF_EASY = Vector(3850.0, -650.0, 256.0)
DIRE_OFF_HARD = Vector(4300.0, 800.0, 384.0)

--time to pull for a stack
RAD_MID_MEDIUM_STACKTIME = 56
RAD_MID_HARD_STACKTIME = 54 -- Too early
RAD_MID_HARDTWO_STACKTIME = 54
RAD_SAFE_MEDIUM_STACKTIME = 55 --seen misses
RAD_SAFE_EASY_STACKTIME = 54
RAD_SAFE_HARD_STACKTIME = 54
RAD_OFF_ANCIENT_STACKTIME = 53
RAD_OFF_EASY_STACKTIME = 55
RAD_OFF_HARD_STACKTIME = 56
DIRE_MID_MEDIUM_STACKTIME = 53
DIRE_MID_HARD_STACKTIME = 54
DIRE_MID_ANCIENT_STACKTIME = 53
DIRE_SAFE_MEDIUM_STACKTIME = 55
DIRE_SAFE_EASY_STACKTIME = 55
DIRE_SAFE_HARD_STACKTIME = 55
DIRE_OFF_ANCIENT_STACKTIME = 54
DIRE_OFF_EASY_STACKTIME = 53
DIRE_OFF_HARD_STACKTIME = 55

--vector to wait for pull at
RAD_MID_MEDIUM_PRESTACK = Vector(-1800.0, -4050.0, 128.0)
RAD_MID_HARD_PRESTACK = Vector(-700.0, -3240.0, 256.0) 
RAD_MID_HARDTWO_PRESTACK = Vector(340.0, -2070.0, 384.0)
RAD_SAFE_MEDIUM_PRESTACK = Vector(700.0, -4500.0, 384.0) --too close
RAD_SAFE_EASY_PRESTACK = Vector(3250.0, -4550.0, 256.0)
RAD_SAFE_HARD_PRESTACK = Vector(4600.0, -4200.0, 256.0)
RAD_OFF_ANCIENT_PRESTACK = Vector(-2775.0, -75.0, 384.0)
RAD_OFF_EASY_PRESTACK = Vector(-3900.0, 700.0, 256.0)
RAD_OFF_HARD_PRESTACK = Vector(-4600.0, -200.0, 256.0) -- too close
DIRE_MID_MEDIUM_PRESTACK = Vector(1100.0, 3500.0, 384.0)
DIRE_MID_HARD_PRESTACK = Vector(-425.0, 3525.0, 256.0)
DIRE_MID_ANCIENT_PRESTACK = Vector(-550.0, 2400.0, 384.0)
DIRE_SAFE_MEDIUM_PRESTACK = Vector(-1600.0, 4025.0, 256.0)
DIRE_SAFE_EASY_PRESTACK = Vector(-3018.000000, 4654.000000, 0.000000)
DIRE_SAFE_HARD_PRESTACK = Vector(-4300.0, 3800.0, 256.0)
DIRE_OFF_ANCIENT_PRESTACK = Vector(2900.0, 100.0, 384.0)
DIRE_OFF_EASY_PRESTACK = Vector(3575.0, -750.0, 256.0)
DIRE_OFF_HARD_PRESTACK = Vector(4100.0, 725.0, 384.0)

--vector to run to when stacking
RAD_MID_MEDIUM_STACK = Vector(-1825.0, -3200.0, 256.0)
RAD_MID_HARD_STACK = Vector(-425.0, -2425.0, 256.0)
RAD_MID_HARDTWO_STACK = Vector(1120.0, -2940.0, 384.0)
RAD_SAFE_MEDIUM_STACK = Vector(885.0, -3285.0, 384.0)
RAD_SAFE_EASY_STACK = Vector(4245.0, -5275.0, 384.0)
RAD_SAFE_HARD_STACK = Vector(3425.0, -3355.0, 256.0)
RAD_OFF_ANCIENT_STACK = Vector(-3980.0, -815.0, 384.0)
RAD_OFF_EASY_STACK = Vector(-5200.0, 285.0, 256.0)
RAD_OFF_HARD_STACK = Vector(-3900.0, -730.0, 256.0)
DIRE_MID_MEDIUM_STACK = Vector(1261.0, 2717.0, 1229.0)
DIRE_MID_HARD_STACK = Vector(36.0, 2823.0, 1266.0)
DIRE_MID_HARDTWO_STACK = Vector(-1367.0, 2704.0, 1268.0)
DIRE_SAFE_MEDIUM_STACK = Vector(-1947.0, 3909.0, 1226.0)
DIRE_SAFE_EASY_STACK = Vector(-3090.0, 4158.0, 1176.0)
DIRE_SAFE_HARD_STACK = Vector(-2790.0, 3500.0, 256.0)
DIRE_OFF_ANCIENT_STACK = Vector(4221.0, -516.0, 1262.0)
DIRE_OFF_EASY_STACK = Vector(1998.0, -917.0, 1242.0)
DIRE_OFF_HARD_STACK = Vector(3409.0, -1935.0, 1219.0)

------------------------------
-- Shrine and Rune locations
------------------------------

DIRE_BOUNTY_RUNE_OFF = Vector(3485.0, 295.0, 384.0)
DIRE_BOUNTY_RUNE_SAFE = Vector(-2825.0, 4150.0, 384.0)
RAD_BOUNTY_RUNE_SAFE = Vector(1295.0, -4120.0, 384.0)
RAD_BOUNTY_RUNE_OFF = Vector(-4350.0, 200.0, 256.0)
POWERUP_RUNE_TOP = Vector(-1755.0, 1205.0, 128.0)
POWERUP_RUNE_BOT = Vector(2620.0, -2000.0, 128.0)
DIRE_SHRINE_OFF =  Vector(4200.0, -1575.0, 384.0)
DIRE_SHRINE_SAFE = Vector(-125.0, 2550.0, 384.0)
RAD_SHRINE_SAFE = Vector(635.0, -2550.0, 384.0)
RAD_SHRINE_OFF =  Vector(-4225.0, 1275.0, 384.0)

------------------------------
-- Ward locations
------------------------------

RAD_POWER_TOP = Vector(-2949.435, 815.183, 535.997)
DIRE_POWER_TOP = Vector(-1246.0, 2860.9, 535.997)
RAD_POWER_BOT = Vector(1850.83, -2876.455, 512.0)
--[[DIRE_POWER_TOP = Vector(-1305.5, 2505.0, 512.0)
DIRE_POWER_TOP = Vector(-1305.5, 2505.0, 512.0)
DIRE_POWER_TOP = Vector(-1305.5, 2505.0, 512.0)
DIRE_POWER_TOP = Vector(-1305.5, 2505.0, 512.0)
DIRE_POWER_TOP = Vector(-1305.5, 2505.0, 512.0)
DIRE_POWER_TOP = Vector(-1305.5, 2505.0, 512.0)
]]
-----------------------------
-- Others
-----------------------------

ROSHAN = Vector(-2451.685303, 1884.514893, 159.998047)

----------------------------------------------------------------------------------------------------
TEAM_RADIANT = 2
TEAM_DIRE = 3

CAMP_EASY = 1
CAMP_MEDIUM = 2
CAMP_HARD = 3
CAMP_ANCIENT = 4

VECTOR = "vector"
STACK_TIME = "time"
PRE_STACK_VECTOR = "prestack"
STACK_VECTOR = "stack"
DIFFICULTY = "difficulty"

X["tableNeutralCamps"] = {
	[TEAM_RADIANT] = {
		[1] = {
			[DIFFICULTY] = CAMP_EASY,
			[VECTOR] = RAD_SAFE_EASY,
			[STACK_TIME] = RAD_SAFE_EASY_STACKTIME,
			[PRE_STACK_VECTOR] = RAD_SAFE_EASY_PRESTACK,
			[STACK_VECTOR] = RAD_SAFE_EASY_STACK
		},
		[2] = {
			[DIFFICULTY] = CAMP_MEDIUM,
			[VECTOR] = RAD_SAFE_MEDIUM,
			[STACK_TIME] = RAD_SAFE_MEDIUM_STACKTIME,
			[PRE_STACK_VECTOR] = RAD_SAFE_MEDIUM_PRESTACK,
			[STACK_VECTOR] = RAD_SAFE_MEDIUM_STACK
		},
		[3] = {
			[DIFFICULTY] = CAMP_MEDIUM,
			[VECTOR] = RAD_MID_MEDIUM,
			[STACK_TIME] = RAD_MID_MEDIUM_STACKTIME,
			[PRE_STACK_VECTOR] = RAD_MID_MEDIUM_PRESTACK,
			[STACK_VECTOR] = RAD_MID_MEDIUM_STACK
		},
		[4] = {
			[DIFFICULTY] = CAMP_EASY,
			[VECTOR] = RAD_OFF_EASY,
			[STACK_TIME] = RAD_OFF_EASY_STACKTIME,
			[PRE_STACK_VECTOR] = RAD_OFF_EASY_PRESTACK,
			[STACK_VECTOR] = RAD_OFF_EASY_STACK
		},
		[5] = {
			[DIFFICULTY] = CAMP_HARD,
			[VECTOR] = RAD_OFF_HARD,
			[STACK_TIME] = RAD_OFF_HARD_STACKTIME,
			[PRE_STACK_VECTOR] = RAD_OFF_HARD_PRESTACK,
			[STACK_VECTOR] = RAD_OFF_HARD_STACK
		},
		[6] = {
			[DIFFICULTY] = CAMP_HARD,
			[VECTOR] = RAD_MID_HARD,
			[STACK_TIME] = RAD_MID_HARD_STACKTIME,
			[PRE_STACK_VECTOR] = RAD_MID_HARD_PRESTACK,
			[STACK_VECTOR] = RAD_MID_HARD_STACK
		},
		[7] = {
			[DIFFICULTY] = CAMP_HARD,
			[VECTOR] = RAD_SAFE_HARD,
			[STACK_TIME] = RAD_SAFE_HARD_STACKTIME,
			[PRE_STACK_VECTOR] = RAD_SAFE_HARD_PRESTACK,
			[STACK_VECTOR] = RAD_SAFE_HARD_STACK
		},
		[8] = {
			[DIFFICULTY] = CAMP_HARD,
			[VECTOR] = RAD_MID_HARDTWO,
			[STACK_TIME] = RAD_MID_HARDTWO_STACKTIME,
			[PRE_STACK_VECTOR] = RAD_MID_HARDTWO_PRESTACK,
			[STACK_VECTOR] = RAD_MID_HARDTWO_STACK
		},
		[9] = {
			[DIFFICULTY] = CAMP_ANCIENT,
			[VECTOR] = RAD_OFF_ANCIENT,
			[STACK_TIME] = RAD_OFF_ANCIENT_STACKTIME,
			[PRE_STACK_VECTOR] = RAD_OFF_ANCIENT_PRESTACK,
			[STACK_VECTOR] = RAD_OFF_ANCIENT_STACK
		}
	},
	[TEAM_DIRE] = {
		[1] = {
			[DIFFICULTY] = CAMP_EASY,
			[VECTOR] = DIRE_SAFE_EASY,
			[STACK_TIME] = DIRE_SAFE_EASY_STACKTIME,
			[PRE_STACK_VECTOR] = DIRE_SAFE_EASY_PRESTACK,
			[STACK_VECTOR] = DIRE_SAFE_EASY_STACK
		},
		[2] = {
			[DIFFICULTY] = CAMP_MEDIUM,
			[VECTOR] = DIRE_SAFE_MEDIUM,
			[STACK_TIME] = DIRE_SAFE_MEDIUM_STACKTIME,
			[PRE_STACK_VECTOR] = DIRE_SAFE_MEDIUM_PRESTACK,
			[STACK_VECTOR] = DIRE_SAFE_MEDIUM_STACK
		},
		[3] = {
			[DIFFICULTY] = CAMP_MEDIUM,
			[VECTOR] = DIRE_MID_MEDIUM,
			[STACK_TIME] = DIRE_MID_MEDIUM_STACKTIME,
			[PRE_STACK_VECTOR] = DIRE_MID_MEDIUM_PRESTACK,
			[STACK_VECTOR] = DIRE_MID_MEDIUM_STACK
		},
		[4] = {
			[DIFFICULTY] = CAMP_EASY,
			[VECTOR] = DIRE_OFF_EASY,
			[STACK_TIME] = DIRE_OFF_EASY_STACKTIME,
			[PRE_STACK_VECTOR] = DIRE_OFF_EASY_PRESTACK,
			[STACK_VECTOR] = DIRE_OFF_EASY_STACK
		},
		[5] = {
			[DIFFICULTY] = CAMP_HARD,
			[VECTOR] = DIRE_OFF_HARD,
			[STACK_TIME] = DIRE_OFF_HARD_STACKTIME,
			[PRE_STACK_VECTOR] = DIRE_OFF_HARD_PRESTACK,
			[STACK_VECTOR] = DIRE_OFF_HARD_STACK
		},
		[6] = {
			[DIFFICULTY] = CAMP_HARD,
			[VECTOR] = DIRE_MID_HARD,
			[STACK_TIME] = DIRE_MID_HARD_STACKTIME,
			[PRE_STACK_VECTOR] = DIRE_MID_HARD_PRESTACK,
			[STACK_VECTOR] = DIRE_MID_HARD_STACK
		},
		[7] = {
			[DIFFICULTY] = CAMP_HARD,
			[VECTOR] = DIRE_SAFE_HARD,
			[STACK_TIME] = DIRE_SAFE_HARD_STACKTIME,
			[PRE_STACK_VECTOR] = DIRE_SAFE_HARD_PRESTACK,
			[STACK_VECTOR] = DIRE_SAFE_HARD_STACK
		},
		[8] = {
			[DIFFICULTY] = CAMP_HARD,
			[VECTOR] = DIRE_MID_HARDTWO,
			[STACK_TIME] = DIRE_MID_HARDTWO_STACKTIME,
			[PRE_STACK_VECTOR] = DIRE_MID_HARDTWO_PRESTACK,
			[STACK_VECTOR] = DIRE_MID_HARDTWO_STACK
		},
		[9] = {
			[DIFFICULTY] = CAMP_ANCIENT,
			[VECTOR] = DIRE_OFF_ANCIENT,
			[STACK_TIME] = DIRE_OFF_ANCIENT_STACKTIME,
			[PRE_STACK_VECTOR] = DIRE_OFF_ANCIENT_PRESTACK,
			[STACK_VECTOR] = DIRE_OFF_ANCIENT_STACK
		}
	}
}

----------------------------------------------------------------------------------------------------

POWERUP_RUNES = 1

X["tableRuneSpawns"] = {
	[TEAM_RADIANT] = {
		RAD_BOUNTY_RUNE_SAFE;
		RAD_BOUNTY_RUNE_OFF;
	};
	[TEAM_DIRE] = {
		DIRE_BOUNTY_RUNE_SAFE;
		DIRE_BOUNTY_RUNE_OFF;
	};
	[POWERUP_RUNES] = {
		POWERUP_RUNE_BOT;
		POWERUP_RUNE_TOP;
	};
}

----------------------------------------------------------------------------------------------------

X["tableWardSpots"] = {
	[TEAM_RADIANT] = {
		RAD_POWER_TOP;
		RAD_POWER_BOT;
	};
	[TEAM_DIRE] = {
		DIRE_POWER_TOP;
		RAD_POWER_BOT;
	};
}

----------------------------------------------------------------------------------------------------

return X