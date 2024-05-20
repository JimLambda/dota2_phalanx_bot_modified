----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sOutfitType = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,3,2,1,2,6,2,3,3,3,6,1,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {
  
  	"item_ranged_carry_outfit",
  	"item_falcon_blade",
  	"item_maelstrom",
  	"item_aghanims_shard",
  	"item_desolator",
  	"item_mjollnir",
  	"item_greater_crit",
  	"item_monkey_king_bar",
  	"item_nullifier",
  	"item_travel_boots",
  	"item_moon_shard",
	"item_travel_boots_2",
  
}

tOutFitList['outfit_mid'] = {

	"item_ranged_carry_outfit",
  	"item_phylactery",
	"item_orchid",
	"item_aghanims_shard",
	"item_angels_demise",
	"item_bloodthorn",
	"item_disperser",
	"item_nullifier",
	"item_sheepstick",
	"item_travel_boots",
	"item_moon_shard",
	"item_travel_boots_2",

}

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
  
  	"item_mjollnir",
  	"item_magic_wand",
  
	"item_greater_crit",
	"item_wraith_band",

  	"item_monkey_king_bar",
  	"item_falcon_blade",

  	"item_disperser",
  	"item_magic_wand",

  	"item_nullifier",
  	"item_wraith_band",
  
}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_ranged_carry' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false


function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
    and hMinionUnit:GetUnitName() ~= "npc_dota_clinkz_skeleton_archer"
	then
			Minion.IllusionThink( hMinionUnit )
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityAS = bot:GetAbilityByName( sAbilityList[5] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )

local castQDesire
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire
local castASDesire, castASLocation


local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


function X.SkillsComplement()
  
	if J.CanNotUseAbility( bot ) then return end

	nKeepMana = 150
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )
  
  
	castQDesire, sMotive = X.ConsiderQ()
	if castQDesire > 0
	then
    
    --bot:Action_ClearActions( false )
    J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

			bot:ActionQueue_UseAbility( abilityQ )
		return
	end

	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if castWDesire > 0
	then
		
    --bot:Action_ClearActions( false )
    J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )
    
			bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end
  
  castEDesire, castETarget, sMotive = X.ConsiderE()
	if castEDesire > 0
	then
		
    --bot:Action_ClearActions( false )
    J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )
    
			bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return
	end

	castRDesire, sMotive = X.ConsiderR()
	if castRDesire > 0
	then
    
    --bot:Action_ClearActions( false )
    J.SetReportMotive( bDebugMode, sMotive )

		--J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityR )
		return
	end
  
  castASDesire, castASLocation = X.ConsiderAS()
	if castASDesire > 0
	then
    --bot:Action_ClearActions( true )
		--J.SetQueuePtToINT( bot, true )
    
		bot:ActionQueue_UseAbilityOnLocation( abilityAS , castASLocation )
		return
	end
  
end

function X.ConsiderAS()
  
  if not abilityAS:IsTrained() 
    or not abilityAS:IsFullyCastable() 
  then 
      return 0 
  end
  
  local nCastRange = 600 --abilityAS:GetSpecialValueInt( "range" )
	local nRadius = 200
	local nCastPoint = abilityAS:GetCastPoint()
	local nSkillLV = abilityAS:GetLevel()
	local nManaCost = abilityAS:GetManaCost()
	local nTargetLocation = nil
  local AllyCreepList = bot:GetNearbyLaneCreeps( nCastRange, false )
  
  if J.IsGoingOnSomeone( bot )
	then
		if J.IsValid( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
		then
			local nShouldHurtCount = 1
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation
			end
		end
	end
  
  if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and #hEnemyList == 0
    and #AllyCreepList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 1400, true )
		if #laneCreepList >= 2
			and J.IsValid( laneCreepList[1] )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
			if locationAoEHurt.count >= 3
			then
				nTargetLocation = locationAoEHurt.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation
			end
		end
	end
	
	if J.IsFarming( bot )
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		if J.IsValid( botTarget )
			and botTarget:GetTeam() == TEAM_NEUTRAL
			and J.IsInRange( bot, botTarget, nCastRange )
		then
			local nShouldHurtCount = 2
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation, "E-打钱"..locationAoE.count
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end
  
  local nAttackRange = bot:GetAttackRange()
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( 1600 )
	local nInRangeAllyList = J.GetAllyList( bot, nAttackRange)
  local nlaneCreepList = bot:GetNearbyLaneCreeps( 1600, true )
  
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nAttackRange - 200 )
      and (J.IsDisabled( botTarget )
      or J.GetHP( botTarget ) <= 0.5
      or botTarget:HasModifier( "modifier_clinkz_tar_bomb_slow"))
		then
			return BOT_ACTION_DESIRE_HIGH
    end
  end
  
  local TowerTarget = nil
  local towers = bot:GetNearbyTowers( nAttackRange + 300, true )
  
  if towers[1] ~= nil then
    TowerTarget = towers[1]
    if J.IsValidBuilding( TowerTarget )
      and TowerTarget:HasModifier( "modifier_clinkz_tar_bomb_slow" )
      and not TowerTarget:HasModifier( "modifier_fountain_glyph" )
      and #nInRangeEnemyList == 0
      and #nlaneCreepList == 0
    then
      return BOT_ACTION_DESIRE_HIGH
    end
  end
 
	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nCastRange = abilityW:GetCastRange()
  local nSkillLV = abilityW:GetLevel()
  local nManaCost = abilityW:GetManaCost()
  local nAttackRange = bot:GetAttackRange()
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nAttackRange + 300 )
	local nInRangeAllyList = J.GetAllyList( bot, nAttackRange )
  
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
      and not bot:HasModifier( "modifier_clinkz_wind_walk" )
      and J.CanSlowWithPhylacteryOrKhanda()
    then
			return BOT_ACTION_DESIRE_HIGH, botTarget
    elseif J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nAttackRange + 100 )
      and not bot:HasModifier( "modifier_clinkz_wind_walk" )
      and J.IsAllowedToSpam( bot, nManaCost )
    then
      return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	local aTarget = bot:GetAttackTarget()
  local nCreeps = bot:GetNearbyLaneCreeps( nCastRange, true )
  
  if aTarget ~= nil
		and aTarget:IsBuilding()
    and #nCreeps == 0
    and #nInRangeEnemyList == 0
		and J.IsInRange( aTarget, bot, nCastRange )
	then
		return BOT_ACTION_DESIRE_HIGH, aTarget
  elseif aTarget ~= nil
		and aTarget:IsHero()
		and J.IsInRange( aTarget, bot, nAttackRange )
    and J.IsAllowedToSpam( bot, nManaCost )
  then
		return BOT_ACTION_DESIRE_HIGH, aTarget
	end
  
  if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and nSkillLV >= 3
		and #hEnemyList == 0
	then
    local nEnemyCreeps = bot:GetNearbyLaneCreeps( nCastRange, true )
    for _, creep in pairs( nEnemyCreeps )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( 'modifier_fountain_glyph' )
        and #nEnemyCreeps >= 2
			then
				if J.IsKeyWordUnit( 'melee', creep )
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
      end
    end
  end
  
  if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		if J.IsValid( botTarget )
			and botTarget:GetTeam() == TEAM_NEUTRAL
			and J.IsInRange( bot, botTarget, nAttackRange )
		then
      return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end
  
return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end

	local nCastRange = abilityE:GetCastRange()
  local nManaCost = abilityE:GetManaCost()
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
  local nSkillLV = abilityE:GetLevel()
  local hCastTarget = nil
  
  local nEnemyCreeps = bot:GetNearbyLaneCreeps( nCastRange, true )
  local targetCreep = nEnemyCreeps[1]
  
  if nHP <= 0.3 then
    for _, creep in pairs( nEnemyCreeps )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( 'modifier_fountain_glyph' )
        and J.IsInRange( bot, creep, nCastRange + 100 )
        and not bot:HasModifier( "modifier_ice_blast" ) 
			then
        return BOT_ACTION_DESIRE_HIGH, creep
      end
    end
  end
  
  if nSkillLV == 1 
    and J.IsValid( targetCreep )
    and not bot:HasModifier( "modifier_clinkz_death_pact" )
    and J.IsAllowedToSpam( bot, nManaCost )
    and not targetCreep:HasModifier( 'modifier_fountain_glyph' )
  then
    return BOT_ACTION_DESIRE_HIGH, targetCreep
  elseif nSkillLV >= 2
    and not bot:HasModifier( "modifier_clinkz_death_pact" )
    and J.IsAllowedToSpam( bot, nManaCost )
  then
    for _, creep in pairs( nEnemyCreeps )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( 'modifier_fountain_glyph' )
			then
				if J.IsKeyWordUnit( 'ranged', creep )
					
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
      end
    end
  end
  
  if J.IsFarming( bot )
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		if J.IsValid( botTarget )
			and botTarget:GetTeam() == TEAM_NEUTRAL
      and not botTarget:IsAncientCreep()
			and J.IsInRange( bot, botTarget, 1000 )
		then
      return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end
  
  return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() 
  then 
      return 0 
  end
  
  local nManaCost = abilityR:GetManaCost()
  local nSkillLV = abilityR:GetLevel()
  local nAttackRange = bot:GetAttackRange()
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( 1600 )
  local nlaneCreepList = bot:GetNearbyLaneCreeps( 1600, true )
  local nInRangeAllyList = J.GetAllyList( bot, 600 )
  
  if J.IsRetreating( bot )
    and J.ShouldEscape( bot )
	then
    return BOT_ACTION_DESIRE_HIGH
	end
  
  if J.IsGoingOnSomeone( bot ) then
    if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nAttackRange - 200 )
			and J.CanCastOnMagicImmune( botTarget )
    then
      local Wcd = abilityW:GetCooldownTimeRemaining()
      if Wcd ~= 0 then
        return BOT_ACTION_DESIRE_HIGH
      end
    end
  end
  
  if bot:IsChanneling()
  then
    return BOT_ACTION_DESIRE_HIGH
  end
  
  if #nlaneCreepList == 0
    and #nInRangeEnemyList == 0
    and J.IsAllowedToSpam( bot, nManaCost )
    and nSkillLV >= 2
    and not bot:HasModifier( "modifier_clinkz_wind_walk" )
  then
    return BOT_ACTION_DESIRE_HIGH
  end
  
	return BOT_ACTION_DESIRE_NONE


end

return X
-- dota2jmz@163.com QQ:2462331592..
