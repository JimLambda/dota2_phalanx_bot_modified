local PPush = {}

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local PC = require(GetScriptDirectory() ..  "/Library/PhalanxCarries")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

function PPush.GetPushDesire(bot, lane)
	local NetworthMin = 0
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		NetworthMin = 3055
	end
	
	if P.IsInLaningPhase() then -- Before 10 mins might be too early to push for bots, so keep them in laning
		return 0
	end
	
	if bot:GetLevel() < 6 or bot:GetNetWorth() < NetworthMin then
		return 0
	end

	local PushDesire = 0.0
	local DistanceToLaneFrontScore = 0.0
	local LaneFrontAmountScore = 0.0
	local HeroAdvantageScore = 0.0
	
	-- Calculate distance to lane score
	local LaneFrontLocation = GetLaneFrontLocation(bot:GetTeam(), lane, 0)
	local DistanceToLane = GetUnitToLocationDistance(bot, LaneFrontLocation)
	local LaneScoreVal = RemapValClamped(DistanceToLane, 0, 4800, 0.0, 0.25)
	DistanceToLaneFrontScore = (0.5 - LaneScoreVal)
	
	-- Calculate lane front amount score
	local LaneFrontAmount = GetLaneFrontAmount(bot:GetTeam(), lane, false)
	LaneFrontAmountScore = RemapValClamped(LaneFrontAmount, 0.0, 1.0, 0.0, 0.25)
	
	-- Calculate hero advantage score
	local HeroAdvantageMulitplier = 0.1
	
	local AliveAllies = 0
	local AliveEnemies = 0
	
	for v, Ally in pairs(GetTeamPlayers(bot:GetTeam())) do
		if IsHeroAlive(Ally) then
			AliveAllies = (AliveAllies + 1)
		end
	end
	for v, Enemy in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(Enemy) then
			AliveEnemies = (AliveEnemies + 1)
		end
	end
	
	local AliveDifference = (AliveAllies - AliveEnemies)
	if AliveDifference > 0 then
		for x = AliveDifference, 1, -1 do
			HeroAdvantageScore = (HeroAdvantageScore + HeroAdvantageMulitplier)
		end
	elseif AliveDifference < 0 then
		for x = AliveDifference, -1, 1 do
			HeroAdvantageScore = (HeroAdvantageScore - HeroAdvantageMulitplier)
		end
	end
	
	-- Calculate total score
	PushDesire = (PushDesire + DistanceToLaneFrontScore)
	PushDesire = (PushDesire + LaneFrontAmountScore)
	PushDesire = (PushDesire + HeroAdvantageScore)
	
	-- Calculate last known location penalty
	local LastKnownLocationPenalty = 0.25
	
	local EnemiesNearLaneFront = 0
	local NearbyAllies = 0
	
	for v, Enemy in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(Enemy) then
			local LSI = GetHeroLastSeenInfo(Enemy)
			if LSI ~= nil then
				local nLSI = LSI[1]
				if nLSI ~= nil then
					if P.GetDistance(LaneFrontLocation, nLSI.location) <= 3200 then
						EnemiesNearLaneFront = (EnemiesNearLaneFront + 1)
						--PushDesire = (PushDesire - LastKnownLocationPenalty)
					end
				end
			end
		end
	end
	
	for v, Ally in pairs(GetTeamPlayers(bot:GetTeam())) do
		if IsHeroAlive(Ally) then
			local LSI = GetHeroLastSeenInfo(Ally)
			if LSI ~= nil then
				local nLSI = LSI[1]
				if nLSI ~= nil then
					if GetUnitToLocationDistance(bot, nLSI.location) <= 3200
					or P.GetDistance(LaneFrontLocation, nLSI.location) <= 3200 then
						NearbyAllies = (NearbyAllies + 1)
					end
				end
			end
		end
	end
	
	if EnemiesNearLaneFront > NearbyAllies then
		local TotalPenalty = (EnemiesNearLaneFront * LastKnownLocationPenalty)
		PushDesire = (PushDesire - TotalPenalty)
	end
	
	-- Calculate bonus aggression for when a team is leading in kills/levels
	if DotaTime() >= (20 * 60) then
		if lane == LANE_TOP then
			bot.rawptd = (PushDesire - DistanceToLaneFrontScore)
		elseif lane == LANE_MID then
			bot.rawpmd = (PushDesire - DistanceToLaneFrontScore)
		elseif lane == LANE_BOT then
			bot.rawpbd = (PushDesire - DistanceToLaneFrontScore)
		end
		
		local MostDesiredRawLane = LANE_MID
		local HighestRawDesire = 0.0
			
		local RawLaneDesires = {bot.rawptd, bot.rawpmd, bot.rawpbd}
		for v, LaneDesire in pairs(RawLaneDesires) do
			if LaneDesire > HighestRawDesire then
				HighestRawDesire = LaneDesire
					
				if LaneDesire == bot.rawptd then
					MostDesiredRawLane = LANE_TOP
				elseif LaneDesire == bot.rawpmd then
					MostDesiredRawLane = LANE_MID
				elseif LaneDesire == bot.rawpbd then
					MostDesiredRawLane = LANE_BOT
				end
			end
		end
		
		if MostDesiredRawLane == lane then
			local AllyKills = PAF.GetAllyTeamKills()
			local AllyLevels = PAF.GetAllyTeamLevels()
			local EnemyKills = PAF.GetEnemyTeamKills()
			local EnemyLevels = PAF.GetEnemyTeamLevels()
			
			local MaxKillsWeight = (EnemyKills * 2)
			local MaxLevelsWeight = (EnemyLevels * 2)
			local WeightPerFactor = 0.25
			
			if AllyKills > EnemyKills then
				local KillsWeight = RemapValClamped(AllyKills, EnemyKills, MaxKillsWeight, 0.0, WeightPerFactor)
				PushDesire = (PushDesire + KillsWeight)
			end
			
			if AllyLevels > EnemyLevels then
				local LevelsWeight = RemapValClamped(AllyLevels, EnemyLevels, MaxLevelsWeight, 0.0, WeightPerFactor)
				PushDesire = (PushDesire + LevelsWeight)
			end
		end
	end
	
	-- Calculate building multipliers
	if AliveDifference >= 0 then
		local TierOneMultiplier = 1.25
		local TierTwoMultiplier = 1.5
		local TierThreeMultiplier = 1.75
		local MeleeBarracksMultiplier = 2.0
		
		local TierOne, TierTwo, TierThree, MeleeBarracks = GetEnemyLaneBuildings(lane)
		
		if MeleeBarracks == nil then
			PushDesire = (PushDesire * MeleeBarracksMultiplier)
		elseif TierThree == nil then
			PushDesire = (PushDesire * TierThreeMultiplier)
		elseif TierTwo == nil then
			PushDesire = (PushDesire * TierTwoMultiplier)
		elseif TierOne == nil then
			PushDesire = (PushDesire * TierOneMultiplier)
		end
	end
	
	-- Assign each lane push desire to a bot property
	if lane == LANE_TOP then
		bot.ptd = PushDesire
	elseif lane == LANE_MID then
		bot.pmd = PushDesire
	elseif lane == LANE_BOT then
		bot.pbd = PushDesire
	end
	
	-- Fix for when all push lane desires are higher than 0.75, bots default to pushing top
	if bot.ptd >= 0.75
	and bot.pmd >= 0.75
	and bot.pbd >= 0.75 then
		local MostDesiredLane = LANE_MID
		local HighestDesire = 0.0
		
		local LaneDesires = {bot.ptd, bot.pmd, bot.pbd}
		for v, LaneDesire in pairs(LaneDesires) do
			if LaneDesire > HighestDesire then
				HighestDesire = LaneDesire
				
				if LaneDesire == bot.ptd then
					MostDesiredLane = LANE_TOP
				elseif LaneDesire == bot.pmd then
					MostDesiredLane = LANE_MID
				elseif LaneDesire == bot.pbd then
					MostDesiredLane = LANE_BOT
				end
			end
		end
		
		if lane ~= MostDesiredLane then
			return BOT_MODE_DESIRE_MODERATE
		end
	end
	
	-- Return a clamped desire to push lanes
	return RemapValClamped(PushDesire, 0.0, 1.0, 0.0, 0.75)
end

function PPush.PushThink(bot, lane)
	local EnemyFrontVisible = true

	local LaneFrontLoc = GetLaneFrontLocation(bot:GetTeam(), lane, 0)
	
	local DeltaFromFront = 500
	local MoveToPos
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	local AlliesWithinRange = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	local CombinedAllyPower = PAF.CombineOffensivePower(FilteredAllies, false)
	local CombinedEnemyPower = PAF.CombineOffensivePower(FilteredEnemies, true)
	
	local NearbyAllyLaneCreeps = bot:GetNearbyLaneCreeps(1600, false)
	local NearbyEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
	local NearbyEnemyFillers = bot:GetNearbyFillers(1600, true)
	local NearbyEnemyTowers = bot:GetNearbyTowers(1600, true)
	local NearbyEnemyBarracks = bot:GetNearbyBarracks(1600, true)
	local EnemyAncient = GetAncient(GetOpposingTeam())
	
	if CombinedAllyPower <= CombinedEnemyPower or #NearbyAllyLaneCreeps == 0 then
		DeltaFromFront = 1400
	end
	
	MoveToPos = GetLaneFrontLocation(bot:GetTeam(), lane, -DeltaFromFront)
	
	local IsBeingTargetedByTower = false
	for v, Tower in pairs(NearbyEnemyTowers) do
		local TowerAttackTarget = Tower:GetAttackTarget()
		if TowerAttackTarget == bot then
			IsBeingTargetedByTower = true
			break
		end
	end
	
	if IsBeingTargetedByTower then
		if NearbyAllyLaneCreeps[1] ~= nil and NearbyEnemyTowers[1] ~= nil then
			if GetUnitToUnitDistance(NearbyAllyLaneCreeps[1], NearbyEnemyTowers[1]) < 700 then
				bot:Action_AttackUnit(NearbyAllyLaneCreeps[1], false)
				return
			else
				bot:Action_MoveToLocation(MoveToPos)
				return
			end
		end
	end
	
	if #NearbyEnemyLaneCreeps > 0 then
		for v, Creep in pairs(NearbyEnemyLaneCreeps) do
			if Creep ~= nil
			and Creep:CanBeSeen()
			and not Creep:IsInvulnerable()
			and GetUnitToLocationDistance(Creep, MoveToPos) <= 1100 then
				bot:Action_AttackUnit(Creep, false)
				return
			end
		end
	end
	
	if EnemyAncient ~= nil
	and EnemyAncient:CanBeSeen()
	and not EnemyAncient:IsInvulnerable()
	and GetUnitToLocationDistance(EnemyAncient, MoveToPos) <= 1100 then
		bot:Action_AttackUnit(EnemyAncient, false)
		return
	end
	
	if #NearbyEnemyBarracks > 0 then
		for v, Barracks in pairs(NearbyEnemyBarracks) do
			if string.find(Barracks:GetUnitName(), "melee") then
				if Barracks ~= nil
				and Barracks:CanBeSeen()
				and not Barracks:IsInvulnerable()
				and GetUnitToLocationDistance(Barracks, MoveToPos) <= 1100 then
					bot:Action_AttackUnit(Barracks, false)
					return
				end
			end
		end
		
		for v, Barracks in pairs(NearbyEnemyBarracks) do
			if string.find(Barracks:GetUnitName(), "range") then
				if Barracks ~= nil
				and Barracks:CanBeSeen()
				and not Barracks:IsInvulnerable()
				and GetUnitToLocationDistance(Barracks, MoveToPos) <= 1100 then
					bot:Action_AttackUnit(Barracks, false)
					return
				end
			end
		end
	end
	
	if #NearbyEnemyTowers > 0 then
		for v, Tower in pairs(NearbyEnemyTowers) do
			if Tower ~= nil
			and Tower:CanBeSeen()
			and not Tower:IsInvulnerable()
			and GetUnitToLocationDistance(Tower, MoveToPos) <= 1100 then
				bot:Action_AttackUnit(Tower, false)
				return
			end
		end
	end
	
	if #NearbyEnemyFillers > 0 then
		for v, Filler in pairs(NearbyEnemyFillers) do
			if Filler ~= nil
			and Filler:CanBeSeen()
			and not Filler:IsInvulnerable()
			and GetUnitToLocationDistance(Filler, MoveToPos) <= 1100 then
				bot:Action_AttackUnit(Filler, false)
				return
			end
		end
	end
	
	if GetUnitToLocationDistance(bot, MoveToPos) <= 800 then
		bot:Action_MoveToLocation(MoveToPos+RandomVector(500))
		return
	else
		bot:Action_MoveToLocation(MoveToPos)
		return
	end
end

function GetEnemyLaneBuildings(lane)
	if lane == LANE_TOP then
		local TierOne = GetTower(GetOpposingTeam(), TOWER_TOP_1)
		local TierTwo = GetTower(GetOpposingTeam(), TOWER_TOP_2)
		local TierThree = GetTower(GetOpposingTeam(), TOWER_TOP_3)
		local MeleeBarracks = GetBarracks(GetOpposingTeam(), BARRACKS_TOP_MELEE)
		
		return TierOne, TierTwo, TierThree, MeleeBarracks
	end
	if lane == LANE_MID then
		local TierOne = GetTower(GetOpposingTeam(), TOWER_MID_1)
		local TierTwo = GetTower(GetOpposingTeam(), TOWER_MID_2)
		local TierThree = GetTower(GetOpposingTeam(), TOWER_MID_3)
		local MeleeBarracks = GetBarracks(GetOpposingTeam(), BARRACKS_MID_MELEE)
		
		return TierOne, TierTwo, TierThree, MeleeBarracks
	end
	if lane == LANE_BOT then
		local TierOne = GetTower(GetOpposingTeam(), TOWER_BOT_1)
		local TierTwo = GetTower(GetOpposingTeam(), TOWER_BOT_2)
		local TierThree = GetTower(GetOpposingTeam(), TOWER_BOT_3)
		local MeleeBarracks = GetBarracks(GetOpposingTeam(), BARRACKS_BOT_MELEE)
		
		return TierOne, TierTwo, TierThree, MeleeBarracks
	end
end

return PPush