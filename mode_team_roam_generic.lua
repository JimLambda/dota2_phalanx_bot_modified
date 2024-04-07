local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local bot = GetBot()
local RoamTarget = nil
local LaneTarget = nil
local LastMessageTime = DotaTime()

local SuitableToEngageLaneTarget = false
local SuitableToAttackHero = false
local SuitableToAttackSpecialUnit = false
local SuitableToRoam = false

local SuitableToEngageHero = false
local EngageDesire = 0
local Engaged = false
local EngageTime = 0

local IsWinterWyvernArcticBurn = false
local IsBatRiderLasso = false

local ArrivedToLKL = false
local ArrivedTime = 0

local GankTarget = nil

function GetDesire()
	PAF.AcquireTarget()

	if bot.harass == true then
		bot.harass = false
	end
	
	if Engaged then
		if (DotaTime() - EngageTime) > 2 then
			Engaged = false
		end
	end
	
	if IsRuptured() then
		return (BOT_MODE_DESIRE_ABSOLUTE * 1.1)
	end
	
	if P.IsRetreating(bot) then return 0 end
	
	if ArrivedToLKL and (DotaTime() - ArrivedTime) > 30 then
		ArrivedToLKL = false
	end

	if bot:GetTeam() == TEAM_RADIANT then
		EnemyBase = DireSpawn
	elseif bot:GetTeam() == TEAM_DIRE then
		EnemyBase = RadiantSpawn
	end
	
	IsWinterWyvernArcticBurn = IsWinterWyvernAndCastingArcticBurn()
	if IsWinterWyvernArcticBurn then
		return 0.98
	end
	
	IsBatRiderLasso = IsBatRiderCastingLasso()
	if IsBatRiderLasso then
		return BOT_MODE_DESIRE_ABSOLUTE
	end
	
	SuitableToAttackSpecialUnit = CanAttackSpecialUnit()
	if SuitableToAttackSpecialUnit then
		return 0.98
	end
	
	if bot:GetActiveMode() == BOT_MODE_ATTACK
	or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY then return 0 end
	
	SuitableToEngageHero = CanEngageHero()
	if SuitableToEngageHero then
		return Clamp(EngageDesire, 0.0, 0.9)
	end
	
	if P.IsInLaningPhase() then
		SuitableToAttackHero = CanAttackHero()
		if SuitableToAttackHero then
			bot.harass = true
			return 0.56
		else
			bot.harass = false
		end
	end
end

function Think()
	if IsRuptured() then
		local AttackRange = bot:GetAttackRange()
		local EnemiesWithinRange = bot:GetNearbyHeroes(AttackRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestEnemy ~= nil then
			bot:Action_AttackUnit(WeakestEnemy, true)
		else
			bot:Action_ClearActions(true)
		end
	end

	if IsWinterWyvernArcticBurn then
		local NonBurnedEnemies = GetEnemiesWithoutArcticBurn()
		local WeakestUnit = PAF.GetWeakestUnit(NonBurnedEnemies)
		
		if WeakestUnit ~= nil then
			bot:Action_AttackUnit(WeakestUnit, false)
			return
		elseif bot:GetTarget() ~= nil then
			bot:Action_AttackUnit(bot:GetTarget(), false)
			return
		end
	end
	
	if IsBatRiderLasso then
		bot:Action_MoveToLocation(PAF.GetFountainLocation(bot))
		return
	end

	if SuitableToAttackSpecialUnit
	and RoamTarget ~= nil
	and RoamTarget:CanBeSeen() then
		bot:Action_AttackUnit(RoamTarget, false)
		return
	end
	
	if SuitableToAttackHero
	and RoamTarget ~= nil
	and RoamTarget:CanBeSeen() then
		bot:Action_AttackUnit(RoamTarget, false)
		return
	end
	
	if SuitableToEngageHero then
		if LaneTarget ~= nil then
			bot:Action_AttackUnit(LaneTarget, false)
			return
		end
	end

	if SuitableToRoam
	and RoamTarget ~= nil 
	and RoamTarget:CanBeSeen() then
		if (DotaTime() - LastMessageTime) > 30 then
			LastMessageTime = DotaTime()
			local RoamLoc = RoamTarget:GetLocation()
			bot:ActionImmediate_Ping(RoamLoc.x, RoamLoc.y, true)
		end
	
		if GetUnitToUnitDistance(bot, RoamTarget) > 1000 then
			bot:Action_MoveToLocation(RoamTarget:GetLocation())
		else
			bot:Action_AttackUnit(RoamTarget, false)
		end
	end
end

function OnEnd()
	SuitableToEngageLaneTarget = false
	SuitableToRoam = false

	RoamTarget = nil
	
	if bot.teamroaming == true then
		bot.teamroaming = false
	end
end

function CanAttackSpecialUnit()
	local SearchRange = (bot:GetAttackRange() + 150)
	
	--[[if SearchRange < 1000 then
		SearchRange = 1000
	end]]--

	local EnemyUnits = GetUnitList(UNIT_LIST_ENEMIES)
	
	for v, Unit in pairs(EnemyUnits) do
		if Unit ~= nil
		and Unit:IsAlive() 
		and Unit:CanBeSeen() then
			if string.find(Unit:GetUnitName(), "courier") then
				if GetUnitToUnitDistance(bot, Unit) <= SearchRange
				and not PAF.IsPhysicalImmune(Unit) then
					if PAF.IsChasing(bot, Unit)
					and GetUnitToUnitDistance(bot, Unit) > (bot:GetAttackRange() + 300)
					and Unit:GetCurrentMovementSpeed() >= bot:GetCurrentMovementSpeed() then
						-- Do nothing
					else
						RoamTarget = Unit
						return true
					end
				end
			end
		
			if string.find(Unit:GetUnitName(), "tombstone")
			or string.find(Unit:GetUnitName(), "phoenix_sun")
			or string.find(Unit:GetUnitName(), "warlock_golem")
			or string.find(Unit:GetUnitName(), "ignis_fatuus")
			or string.find(Unit:GetUnitName(), "visage_familiar")
			or string.find(Unit:GetUnitName(), "grimstroke_ink_creature")
			or string.find(Unit:GetUnitName(), "observer_ward")
			or string.find(Unit:GetUnitName(), "sentry_ward")
			or string.find(Unit:GetUnitName(), "healing_ward") then
				if GetUnitToUnitDistance(bot, Unit) <= SearchRange
				and not PAF.IsPhysicalImmune(Unit) then
					RoamTarget = Unit
					return true
				end
			end
		end
	end
end

function CanAttackHero()
	if bot:GetHealth() <= (bot:GetMaxHealth() * 0.45) then return false end
	
	if P.IsInLaningPhase() then
		local LaneCreeps = bot:GetNearbyLaneCreeps(600, true)
		
		if #LaneCreeps > 0 then
			return false
		else
			RoamTarget = nil
			
			local SearchRange = 350
			
			if (bot:GetAttackRange() - 150) > SearchRange then
				SearchRange = (bot:GetAttackRange() + 150)
			end
			
			local EnemiesWithinRange = bot:GetNearbyHeroes(SearchRange, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
			RoamTarget = PAF.GetWeakestUnit(FilteredEnemies)
			
			if RoamTarget ~= nil then
				return true
			end
		end
	end
	
	return false
end

function CanEngageHero()
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	local hTarget = PAF.GetWeakestUnit(FilteredEnemies)
	if #FilteredEnemies <= 0 then return false end
	
	if hTarget ~= nil
	and GetUnitToUnitDistance(bot, hTarget) <= 1600 then
		local NearbyTowers = bot:GetNearbyTowers(1600, true)
		if P.IsInLaningPhase()
		and #NearbyTowers > 0
		and GetUnitToUnitDistance(hTarget, NearbyTowers[1]) <= 850 then
			EngageDesire = 0
			return false
		end
		
		local EnemyFountain = PAF.GetFountainLocation(hTarget)
		if GetUnitToLocationDistance(bot, EnemyFountain) <= 1200 then
			EngageDesire = 0
			return false
		end
	
		local NearbyAllies = hTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
		local FilteredAllies = {}
		
		if NearbyAllies ~= nil then
			FilteredAllies = PAF.FilterTrueUnits(NearbyAllies)
		end
		
		local KillDuration = 5.0
		if P.IsInLaningPhase() then
			KillDuration = 2.5
		end
		
		for v, Ally in pairs(FilteredAllies) do
			KillDuration = (KillDuration + Ally:GetStunDuration(true))
			KillDuration = (KillDuration + (Ally:GetSlowDuration(true) / 2))
		end
		
		local EstimatedDamage = 0
		for v, Ally in pairs(FilteredAllies) do
			local UnitDistance = GetUnitToUnitDistance(Ally, hTarget)
			local RemapKD = RemapValClamped(UnitDistance, 0, 1600, 0.0, KillDuration)
			local KDVar = (KillDuration - RemapKD)
			
			local AllyDmg = Ally:GetEstimatedDamageToTarget(true, hTarget, KDVar, DAMAGE_TYPE_ALL)
			EstimatedDamage = (EstimatedDamage + AllyDmg)
		end
		
		local TargetHP = hTarget:GetHealth()
		EngageDesire = RemapValClamped(EstimatedDamage, 0, TargetHP, 0.0, 1.0)
		
		LaneTarget = hTarget
		return true
	end
	
	EngageDesire = 0
	return false
end

function CanGankTarget()
	local InitEnemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	local Enemies = PAF.FilterTrueUnits(InitEnemies)
	local InitAllies = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
	local Allies = PAF.FilterTrueUnits(InitAllies)
	
	local GankRange = 3200
	if P.IsInLaningPhase() then
		GankRange = 1600
	end
	
	local NearbyEnemies = {}
	if #Enemies > 0 then
		for v, Enemy in pairs(Enemies) do
			if PAF.IsValidHeroTarget(Enemy) then
				if GetUnitToUnitDistance(bot, Enemy) <= GankRange then
					table.insert(NearbyEnemies, Enemy)
				end
			end
		end
	end
	
	if #NearbyEnemies > 0 then
		if #Allies >= #NearbyEnemies then
			local AllyOffensivePower = 0
			
			for v, Ally in pairs(Allies) do
				AllyOffensivePower = (AllyOffensivePower + Ally:GetOffensivePower())
			end
			
			local WeakestEnemy = PAF.GetWeakestUnit(NearbyEnemies)
			
			if GetUnitToLocationDistance(WeakestEnemy, PAF.GetFountainLocation(WeakestEnemy)) <= 4000 then return false end
			
			--local IncDamage = WeakestEnemy:GetActualIncomingDamage(AllyOffensivePower, DAMAGE_TYPE_PHYSICAL)
			local NearbyTowers = WeakestEnemy:GetNearbyTowers(1200, false)

			if WeakestEnemy:GetHealth() < AllyOffensivePower and #NearbyTowers <= 0 then
				GankTarget = WeakestEnemy
				return true
			end
		end
	end
	
	return false
end

function GetEnemiesWithoutArcticBurn()
	local EnemiesWithinRange = bot:GetNearbyHeroes((bot:GetAttackRange()), true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
	local NonBurnedEnemies = {}
	if #FilteredEnemies > 0 then
		for v, Enemy in pairs(FilteredEnemies) do
			if not Enemy:HasModifier("modifier_winter_wyvern_arctic_burn_slow") then
				table.insert(NonBurnedEnemies, Enemy)
			end
		end
	end
	
	return NonBurnedEnemies
end

function IsWinterWyvernAndCastingArcticBurn()
	if bot:GetUnitName() == "npc_dota_hero_winter_wyvern"
	and bot:HasModifier("modifier_winter_wyvern_arctic_burn_flight") then
		local NonBurnedEnemies = GetEnemiesWithoutArcticBurn()
		
		if #NonBurnedEnemies > 0 then
			return true
		end
	end
	
	return false
end

function IsBatRiderCastingLasso()
	if bot:GetUnitName() == "npc_dota_hero_batrider" then
		if bot:HasModifier("modifier_batrider_flaming_lasso_self") then
			return true
		end	
		
		if PAF.IsEngaging(bot) then
			local BotTarget = bot:GetTarget()
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if BotTarget:HasModifier("modifier_batrider_flaming_lasso") then
					return true
				end
			end
		end
	end
	
	return false
end

function IsTimbersawCastingChakram()
	if bot:GetUnitName() == "npc_dota_hero_shredder" then
		if bot:HasModifier("modifier_shredder_chakram_disarm") then
			return true
		end
	end
end

function GetClosestLastKnownLocation()
	local ClosestLocation = nil
	local ClosestDistance = 99999

	local EnemyIDs = GetTeamPlayers(GetOpposingTeam())
	for v, EID in pairs(EnemyIDs) do
		local LSI = GetHeroLastSeenInfo(EID)
		if LSI ~= nil then
			local nLSI = LSI[1]
				
			if nLSI ~= nil then
				if GetUnitToLocationDistance(bot, nLSI.location) <= ClosestDistance then
					ClosestLocation = nLSI.location
					ClosestDistance = GetUnitToLocationDistance(bot, nLSI.location)
				end
			end
		end
	end
	
	return ClosestLocation
end

function IsRuptured()
	if bot:HasModifier("modifier_bloodseeker_rupture") then
		return true
	end
	
	return false
end