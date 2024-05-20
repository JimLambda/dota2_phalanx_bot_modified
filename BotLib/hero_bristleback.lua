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
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,3,1,2,2,6,2,3,3,3,6,1,1,1,6},
						{2,3,2,3,2,6,2,1,3,3,6,1,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

--local sRandomItem_1 = RandomInt( 1, 9 ) > 6 and "item_black_king_bar" or "item_heavens_halberd"

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_bristleback_outfit",
	"item_blade_mail",
  	"item_eternal_shroud",
  	"item_aghanims_shard",
  	"item_ultimate_scepter",
  	"item_heart",
	"item_bloodstone",
	"item_ultimate_scepter_2",
	"item_lotus_orb",
	"item_travel_boots",
	--sRandomItem_1,
	"item_moon_shard",
	"item_travel_boots_2",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_eternal_shroud",
	"item_quelling_blade",

	"item_ultimate_scepter",
	"item_magic_wand",

	"item_heart",
	"item_bracer",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_power_treads", 'item_quelling_blade'} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_bristleback

"Ability1"		"bristleback_viscous_nasal_goo"
"Ability2"		"bristleback_quill_spray"
"Ability3"		"bristleback_bristleback"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"bristleback_warpath"
"Ability10"		"special_bonus_movement_speed_20"
"Ability11"		"special_bonus_mp_regen_3"
"Ability12"		"special_bonus_hp_250"
"Ability13"		"special_bonus_unique_bristleback"
"Ability14"		"special_bonus_hp_regen_25"
"Ability15"		"special_bonus_unique_bristleback_2"
"Ability16"		"special_bonus_spell_lifesteal_15"
"Ability17"		"special_bonus_unique_bristleback_3"

modifier_bristleback_viscous_nasal_goo
modifier_bristleback_quillspray_thinker
modifier_bristleback_quill_spray
modifier_bristleback_quill_spray_stack
modifier_bristleback_bristleback
modifier_bristleback_warpath
modifier_bristleback_warpath_stack

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityAS = bot:GetAbilityByName( sAbilityList[4] )


local castQDesire, castQTarget
local castWDesire
local castEDesire, castELocation
local castASDesire, castASTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, botTarget


function X.SkillsComplement()


	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end


	nKeepMana = 100
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	nLV = bot:GetLevel()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )


	castASDesire, castASTarget = X.ConsiderAS()
	if ( castASDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )
	
		bot:ActionQueue_UseAbilityOnLocation( abilityAS, castASTarget )

		return
	end
	
	
	castQDesire, castQTarget = X.ConsiderQ()
	if ( castQDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

			bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end

	castWDesire = X.ConsiderW()
	if ( castWDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityW )
		return
	end
  
  castEDesire, castELocation = X.ConsiderE()
	if ( castEDesire > 0 )
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityE, castELocation )
		return
	end


end


function X.ConsiderQ()

	if ( not abilityQ:IsFullyCastable() ) then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = abilityQ:GetCastRange()
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()

	local nEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 300, true, BOT_MODE_NONE )


	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN )
	then
		local npcTarget = bot:GetAttackTarget()
		if ( J.IsRoshan( npcTarget ) 
      and J.CanCastOnMagicImmune( npcTarget ) 
      and J.IsInRange( npcTarget, bot, nCastRange )
      and J.IsAllowedToSpam( bot, nManaCost ))
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.IsInRange( npcTarget, bot, nCastRange )
			and J.CanCastOnTargetAdvanced( npcTarget )
      and J.IsAllowedToSpam( bot, nManaCost )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end


function X.ConsiderW()

	if not abilityW:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE
	end

	local nRadius = abilityW:GetSpecialValueInt( "radius" )
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()

	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )

	if J.IsRetreating( bot ) and #tableNearbyEnemyHeroes > 0
	then
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 )
				or npcEnemy:HasModifier( "modifier_bristleback_quill_spray" )
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if nLV >= 6
    and (J.IsPushing( bot )
		or J.IsDefending( bot ))
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( nRadius, true )
		if ( tableNearbyEnemyCreeps ~= nil 
      and #tableNearbyEnemyCreeps >= 1 
      and J.IsAllowedToSpam( bot, nManaCost ) ) 
    then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if J.IsFarming( bot ) and nLV > 5
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValid( npcTarget )
			and npcTarget:GetTeam() == TEAM_NEUTRAL
		then
			if npcTarget:GetHealth() > bot:GetAttackDamage() * 2.28
			then
				return BOT_ACTION_DESIRE_HIGH
			end

			local nCreeps = bot:GetNearbyCreeps( nRadius, true )
			if ( #nCreeps >= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsInTeamFight( bot, 1200 )
	then
		if #tableNearbyEnemyHeroes >= 1
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnMagicImmune( npcTarget )
			and J.IsInRange( npcTarget, bot, nRadius - 100 )
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		if J.IsValidHero( npcTarget )
			and J.IsAllowedToSpam( bot, nManaCost )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.IsInRange( npcTarget, bot, nRadius )
		then
			local nCreeps = bot:GetNearbyCreeps( 800, true )
			if #nCreeps >= 1
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN )
	then
		local npcTarget = bot:GetAttackTarget()
		if J.IsRoshan( npcTarget ) 
      and J.CanCastOnMagicImmune( npcTarget ) 
      and J.IsInRange( bot, npcTarget, nRadius ) 
      and J.IsAllowedToSpam( bot, nManaCost )
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if nMP > 0.95
		and nLV >= 6
		and bot:DistanceFromFountain() > 2400
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		return BOT_ACTION_DESIRE_LOW
	end

	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderE()
  
  if not bot:HasScepter()
		or not abilityE:IsFullyCastable() 
	then
		return 0
	end
  
  local nRadius = 250
  local nDelay = abilityE:GetSpecialValueFloat( "activation_delay" )
  local nInRangeEnemyList = J.GetAroundEnemyHeroList( nRadius + 100 )
  
  if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nRadius)
		then
      if J.IsDisabled( botTarget )
        or botTarget:HasModifier( "modifier_bristleback_viscous_nasal_goo" )
      then
        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
      end
		end
  end
  
  if J.IsRetreating( bot )
    and ( bot:WasRecentlyDamagedByAnyHero( 3.0 ) or bot:GetActiveModeDesire() > 0.7 )
    and #nInRangeEnemyList >= 1
    and nInRangeEnemyList[1] ~= nil
  then
    local hCastTraget = nInRangeEnemyList[1]
    if J.IsValidHero( hCastTraget )
      and J.IsInRange( bot, hCastTraget, nRadius )
      and J.CanCastAbilityOnTarget( hCastTraget, true )
    then
      return BOT_ACTION_DESIRE_HIGH, hCastTraget:GetLocation()
    end
  end
  
  if J.IsPushing( bot )
		or J.IsDefending( bot )
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 1, 274, 0, 0 )
		if ( locationAoE.count >= 2 )
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
		end
	end

	if J.IsFarming( bot )
	then
    local nCreeps = bot:GetNearbyCreeps( nRadius, true )
    if ( #nCreeps >= 2 )
    then
      local hCastTarget = nCreeps[1]
      return BOT_ACTION_DESIRE_HIGH, hCastTarget:GetLocation()
    end
  end

  return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderAS()

	if not abilityAS:IsTrained()
		or not abilityAS:IsFullyCastable() 
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = 700
	local nCastRange = abilityAS:GetCastRange()
	local nCastPoint = abilityAS:GetCastPoint()
	local nManaCost = abilityAS:GetManaCost()

	if J.IsRetreating( bot )
	then
		local enemyHeroList = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
		local targetHero = enemyHeroList[1]
		if J.IsValidHero( targetHero )
			and J.CanCastOnNonMagicImmune( targetHero )
		then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end		
	end
	

	if J.IsInTeamFight( bot, 1400 )
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLoc ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nAoeLoc
		end		
	end
	

	if J.IsGoingOnSomeone( bot )
	then
		local targetHero = J.GetProperTarget( bot )
		if J.IsValidHero( targetHero )
			and J.IsInRange( bot, targetHero, nCastRange )
			and J.CanCastOnNonMagicImmune( targetHero )
		then
			return BOT_ACTION_DESIRE_HIGH, targetHero:GetLocation()
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end

return X
-- dota2jmz@163.com QQ:2462331592..
