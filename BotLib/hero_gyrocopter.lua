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
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,3,3,1,3,6,3,2,2,2,6,1,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRandomItem_1 = RandomInt( 1, 9 ) > 5 and "item_butterfly" or "item_monkey_king_bar"

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_ranged_carry_outfit",
  	"item_hand_of_midas",
  	"item_diffusal_blade",
	"item_ultimate_scepter",
	"item_black_king_bar",
	"item_greater_crit",
	"item_disperser",
	"item_ultimate_scepter_2",
	"item_satanic",
	sRandomItem_1,
	"item_travel_boots",
	"item_aghanims_shard",
	"item_moon_shard",
	"item_travel_boots_2",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
  
  	"item_ultimate_scepter",
	"item_magic_wand",
  
	"item_black_king_bar",
	"item_wraith_band",

	"item_satanic",
	"item_hand_of_midas",


}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_ranged_carry' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
		and hMinionUnit:GetUnitName() ~= "npc_dota_gyrocopter_homing_missile"
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )

local castQDesire
local castWDesire, castWTarget
local castEDesire
local castRDesire, castRLocation

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


function X.SkillsComplement()


	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 250
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1200 )
	
	castQDesire = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityQ )
		return
	end
	
	castWDesire, castWTarget = X.ConsiderW()
	if ( castWDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end
	
	castEDesire = X.ConsiderE()
	if ( castEDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityE )
		return
	end
	
	castRDesire, castRLocation = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRLocation )
		return
	end
end
  
function X.ConsiderQ()
  
	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nRadius = abilityQ:GetSpecialValueInt( "radius" )
	local nManaCost = abilityQ:GetManaCost()
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nRadius )
	local nEmemysCreepsInRange = bot:GetNearbyCreeps( nRadius, true )
	
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nRadius )
			and J.CanCastOnNonMagicImmune( botTarget )
      and J.IsAllowedToSpam( bot, nManaCost ) 
		then			
			if #nInRangeEnemyList == 1
				and #nEmemysCreepsInRange == 0
      then
				return BOT_ACTION_DESIRE_HIGH
      elseif #nInRangeEnemyList ~= 0
        and #nInRangeEnemyList <= 2
				and #nEmemysCreepsInRange == 0
      then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end
	
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.IsInRange( bot, npcEnemy, nRadius )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 )
						or GetUnitToUnitDistance( bot, npcEnemy ) <= nRadius - 100)
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderW()
  
	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetAbilityDamage()
	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
	local hCastTarget = nil
	
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do 
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage, 0 )
		then
			hCastTarget = npcEnemy
			return BOT_ACTION_DESIRE_HIGH, hCastTarget
		end
	end
	
  if J.IsInTeamFight( bot, 1200 ) 
	then
		local npcStrongestEnemy = nil
		local nStrongestPower = 0
		local nEnemyCount = 0
		
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
        and J.CanCastOnTargetAdvanced( npcEnemy )
        and not J.IsDisabled( npcEnemy )
        and not npcEnemy:IsDisarmed()
      then
        local npcEnemyPower = npcEnemy:GetEstimatedDamageToTarget( true, bot, 6.0, DAMAGE_TYPE_ALL )
        if ( npcEnemyPower > nStrongestPower )
        then
          nStrongestPower = npcEnemyPower
          npcStrongestEnemy = npcEnemy
				end
			end
		end

		if npcStrongestEnemy ~= nil
			and J.IsInRange( bot, npcStrongestEnemy, nCastRange + 150 )
		then
			hCastTarget = npcStrongestEnemy
			return BOT_ACTION_DESIRE_HIGH, hCastTarget
		end
	end
  
	if J.IsLaning( bot ) 
  then
		local LowestEnemy = J.GetLeastHpUnit( nInRangeEnemyList )
    if J.IsValidHero( LowestEnemy )
      and J.CanCastOnNonMagicImmune( LowestEnemy )
      and J.CanCastOnTargetAdvanced( LowestEnemy )
      and J.IsInRange( bot, LowestEnemy, nCastRange )
			and J.IsAllowedToSpam( bot, nManaCost )
    then
			return BOT_ACTION_DESIRE_LOW, LowestEnemy
		end
	end
  
  if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.IsInRange( bot, npcEnemy, nCastRange )
				and ( bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 )
						or GetUnitToUnitDistance( bot, npcEnemy ) <= nCastRange )
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
  
  return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderE()

	if not abilityE:IsFullyCastable() then return 0 end

	local nSkillLV = abilityE:GetLevel()
  local nAttackRange = bot:GetAttackRange()
	local nRadius = abilityE:GetSpecialValueFloat( "radius" )
	local nManaCost = abilityE:GetManaCost()
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nRadius )
	local nEmemysCreepsInRange = bot:GetNearbyLaneCreeps( nRadius, true )  
  
  local aTarget = bot:GetAttackTarget()
  
  if aTarget ~= nil
		and J.IsValidHero( aTarget )
		and J.IsInRange( aTarget, bot, nAttackRange - 50 )
    and not bot:IsDisarmed()
    and ( #nInRangeEnemyList >= 2
      or #nEmemysCreepsInRange >= 3 )
  then
		return BOT_ACTION_DESIRE_HIGH, aTarget
	end
  
  if J.IsDefending( bot )
    or J.IsPushing( bot ) then
    if #nEmemysCreepsInRange >= 3
      and J.IsAllowedToSpam( bot, nManaCost )
      and nSkillLV >= 3
    then
      return BOT_ACTION_DESIRE_HIGH
		end
	end
  
  if J.IsFarming( bot )
	then
    local nNearbyNeutralCreeps = bot:GetNearbyNeutralCreeps( nRadius )
    local aTarget = bot:GetAttackTarget()
    if aTarget ~= nil
      and J.IsValid( aTarget )
      and #nNearbyNeutralCreeps >= 2
    then
      return BOT_ACTION_DESIRE_HIGH
    end

	if botTarget ~= nil
		and J.IsValid( botTarget )
		and botTarget:IsAncientCreep()
	then
		return BOT_ACTION_DESIRE_HIGH
	end
  end
  
  return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
  local nCastRange = 1000
  local nAttackRange = bot:GetAttackRange()
	local nRadius = abilityR:GetSpecialValueFloat( "radius" )
  local nCastPoint = abilityR:GetCastPoint() + 1
  local nDamage = abilityR:GetAbilityDamage()
	local nManaCost = abilityR:GetManaCost()
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( 1600 )
	local nEmemysCreepsInRange = bot:GetNearbyCreeps( 1600, true )
  local nTargetLocation = nil
  
  if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
      and ( J.WillMagicKillTarget( bot, botTarget, nDamage, nCastPoint )
        or J.IsChasingTarget( bot, botTarget ) )
		then
			nTargetLocation = botTarget:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation
		end

		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
		if ( locationAoE.count >= 2 )
		then
			nTargetLocation = locationAoE.targetloc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation
		end
  end
  
  if ( J.IsPushing( bot ) or J.IsDefending( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and nSkillLV >= 3
		and #hEnemyList == 0
    and not abilityE:IsFullyCastable()
    and not bot:HasModifier( "modifier_gyrocopter_flak_cannon" )
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 1400, true )
		if #laneCreepList >= 4
			and J.IsValid( laneCreepList[1] )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
			if locationAoEHurt.count >= 3
			then
				nTargetLocation = locationAoEHurt.targetloc
				return BOT_ACTION_DESIRE_MODERATE, nTargetLocation
			end
		end
	end

	if J.IsFarming( bot )
		and J.IsAllowedToSpam( bot, nManaCost )
    and not abilityE:IsFullyCastable()
    and not bot:HasModifier( "modifier_gyrocopter_flak_cannon" )
	then
		if J.IsValid( botTarget )
			and botTarget:GetTeam() == TEAM_NEUTRAL
			and J.IsInRange( bot, botTarget, 1000 )
		then
			local nShouldHurtCount = 3
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_LOW, nTargetLocation
			end
		end
	end
  
  if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if ( J.IsValid( npcEnemy ) 
        and bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) 
        and J.CanCastOnNonMagicImmune( npcEnemy ) 
        and not J.IsDisabled( npcEnemy ) 
        and not npcEnemy:IsDisarmed() )
			then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
