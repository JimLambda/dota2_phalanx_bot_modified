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
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
							 {1,2,3,2,2,6,2,3,1,1,6,1,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_mage'] = {

	"item_mage_outfit",
  	"item_solar_crest",
  	"item_aghanims_shard",
	"item_ancient_janggo",
	"item_glimmer_cape",
	"item_boots_of_bearing",	
	"item_force_staff",
  	"item_ultimate_scepter_2",
	"item_travel_boots_2",

}

tOutFitList['outfit_carry'] = tOutFitList['outfit_mage']

tOutFitList['outfit_mid'] = tOutFitList['outfit_mage']

tOutFitList['outfit_priest'] = tOutFitList['outfit_mage']

tOutFitList['outfit_tank'] = tOutFitList['outfit_mage']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
  
	"item_force_staff",
	"item_magic_wand",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mage' }, {} end

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

npc_dota_hero_crystal_maiden

"Ability1"		"crystal_maiden_crystal_nova"
"Ability2"		"crystal_maiden_frostbite"
"Ability3"		"crystal_maiden_brilliance_aura"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"crystal_maiden_freezing_field"
"Ability10"		"special_bonus_hp_250"
"Ability11"		"special_bonus_cast_range_100"
"Ability12"		"special_bonus_unique_crystal_maiden_4"
"Ability13"		"special_bonus_gold_income_25"
"Ability14"		"special_bonus_attack_speed_250"
"Ability15"		"special_bonus_unique_crystal_maiden_3"
"Ability16"		"special_bonus_unique_crystal_maiden_1"
"Ability17"		"special_bonus_unique_crystal_maiden_2"

modifier_crystal_maiden_crystal_nova
modifier_crystal_maiden_frostbite
modifier_crystal_maiden_brilliance_aura
modifier_crystal_maiden_brilliance_aura_effect
modifier_crystal_maiden_freezing_field
modifier_crystal_maiden_freezing_field_slow
modifier_crystal_maiden_freezing_field_tracker

--]]

local amuletTime = 0
local aetherRange = 0

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local abilityAS = bot:GetAbilityByName( sAbilityList[4] )

local castQDesire, castQLoc = 0
local castWDesire, castWTarget = 0
local castRDesire = 0
local castASDesire = 0

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget

function X.SkillsComplement()

	X.ConsiderCombo()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 220
	aetherRange = 0
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	nLV = bot:GetLevel()
  botTarget = J.GetProperTarget( bot )
  hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )
  hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
  
	local aether = J.IsItemAvailable( "item_aether_lens" )
  local ether = J.IsItemAvailable( "item_ethereal_blade" )
	if aether ~= nil then 
    aetherRange = 225 
  elseif ether ~= nil then
    aetherRange = 250
  end
  
	castQDesire, castQLoc = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLoc )
		return
	end


	castWDesire, castWTarget = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end


	castRDesire = X.ConsiderR()
	if ( castRDesire > 0 )
	then
		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityR )
		return
	end
  
  castASDesire = X.ConsiderAS()
  if (castASDesire > 0)
  then
    J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityAS )
		return
	end

end

function X.ConsiderCombo()
	if bot:IsAlive()
		and bot:IsChanneling()
		and not bot:IsInvisible()
	then
		local nEnemyTowers = bot:GetNearbyTowers( 880, true )

		if nEnemyTowers[1] ~= nil then return end

		local amulet = J.IsItemAvailable( 'item_shadow_amulet' )
		if amulet~=nil and amulet:IsFullyCastable() and amuletTime < DotaTime()- 10
		then
			amuletTime = DotaTime()
			bot:Action_UseAbilityOnEntity( amulet, bot )
			return
		end

		if not bot:HasModifier( 'modifier_teleporting' )
		then
			local glimer = J.IsItemAvailable( 'item_glimmer_cape' )
			if glimer ~= nil and glimer:IsFullyCastable()
			then
				bot:Action_UseAbilityOnEntity( glimer, bot )
				return
			end

			local invissword = J.IsItemAvailable( 'item_invis_sword' )
			if invissword ~= nil and invissword:IsFullyCastable()
			then
				bot:Action_UseAbility( invissword )
				return
			end

			local silveredge = J.IsItemAvailable( 'item_silver_edge' )
			if silveredge ~= nil and silveredge:IsFullyCastable()
			then
				bot:Action_UseAbility( silveredge )
				return
			end
		end
	end
end

function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nRadius = abilityQ:GetSpecialValueInt( 'radius' )
	local nCastRange = abilityQ:GetCastRange() + aetherRange + 32
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( 'nova_damage' )
	local nSkillLV = abilityQ:GetLevel()
	local nAllys =  bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )
	local nEnemysHeroesInRange = bot:GetNearbyHeroes( nCastRange + nRadius, true, BOT_MODE_NONE )
  local nEnemyCreeps = bot:GetNearbyLaneCreeps( nCastRange + nRadius, true )
  local nTargetLocation = nil
	
  for _, npcEnemy in pairs( nEnemysHeroesInRange )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
      and J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
      and J.IsInRange( bot, npcEnemy, nCastRange )
    then
      return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation()
		end
	end
  
  if J.IsGoingOnSomeone( bot ) 
  then
    if J.IsValidHero( botTarget )
      and J.IsAllowedToSpam( bot, nManaCost )
			and J.CanCastOnNonMagicImmune( botTarget )
      and J.IsInRange( bot, botTarget, nCastRange )
      and not J.IsDisabled( botTarget )
      and ( #nAllys >= 2
        or J.GetHP( botTarget ) <= 0.5 )
    then
      return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
    end
    
    local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
	if ( locationAoE.count >= 3 )
	then
		return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc
	end
  end
  
  if J.IsInTeamFight( bot, nCastRange )
  then
    local npcStrongestEnemy = nil
		local nStrongestPower = 0
		local nEnemyCount = 0
		local hCastTarget = nil
    
		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				nEnemyCount = nEnemyCount + 1
				if not J.IsDisabled( npcEnemy )
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
		end

		if npcStrongestEnemy ~= nil 
      and nEnemyCount >= 2
			and J.IsInRange( bot, npcStrongestEnemy, nCastRange + 150 )
      and not J.IsDisabled( npcStrongestEnemy )
      and not npcStrongestEnemy:IsDisarmed()
      and not abilityW:IsFullyCastable()
		then
			hCastTarget = npcStrongestEnemy
			return BOT_ACTION_DESIRE_HIGH, hCastTarget:GetLocation()
		end
	end
  
  if J.IsLaning( bot )
    and J.IsAllowedToSpam( bot, nManaCost )
  then
    local locationAoEKill = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, nDamage )
    if locationAoEKill.count >= 2
      and #hAllyList == 1
    then
      nTargetLocation = locationAoEKill.targetloc
      return BOT_ACTION_DESIRE_HIGH, nTargetLocation
    end
  end
  
  if ( J.IsPushing( bot ) 
    or J.IsDefending( bot ) ) 
    and J.IsAllowedToSpam( bot, nManaCost )
    and #hEnemyList == 0
  then
    local locationAoEKill = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, nDamage )
    if locationAoEKill.count >= 2
      and #hAllyList == 1
    then
      nTargetLocation = locationAoEKill.targetloc
      return BOT_ACTION_DESIRE_HIGH, nTargetLocation
    end
  end
  
  if not J.IsRetreating( bot )
  then
    for _, creep in pairs( nEnemyCreeps )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( 'modifier_fountain_glyph' )
			then
				if J.IsKeyWordUnit( 'ranged', creep )
          and J.WillMagicKillTarget( bot, creep, nDamage, nCastPoint )
					and J.IsAllowedToSpam( bot, nManaCost )
          and J.IsInRange( bot, creep, nCastRange )
				then
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
        --[[elseif creep:HasModifier( "modifier_creep_bonus_xp" )
          and J.WillMagicKillTarget( bot, creep, nDamage, nCastPoint )
					and J.IsAllowedToSpam( bot, nManaCost )
          and J.IsInRange( bot, creep, nCastRange )
        then
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()]]
				end
      end
    end
  end
  
  if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nEnemysHeroesInRange )
		do
			if J.IsValidHero( npcEnemy ) 
        and bot:WasRecentlyDamagedByHero( npcEnemy, 3.0 ) 
        and J.CanCastOnNonMagicImmune( npcEnemy )
        and not J.IsDisabled( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation()
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = abilityW:GetCastRange() + aetherRange
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nSkillLV = abilityW:GetLevel()
  local nDPS = abilityW:GetSpecialValueInt( "damage_per_second" )
  local nDuration = abilityW:GetSpecialValueFloat( "duration" )
	local nDamage = nDPS * nDuration

	local nAllies =  bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )

	local nEnemysHeroesInView = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	local nAttackRange = bot:GetAttackRange()
	local nEnemysHeroesInRange = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
	local nEnemysHeroesInBonus = bot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE )
  
	for _, npcEnemy in pairs( nEnemysHeroesInBonus )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
      and J.CanCastOnTargetAdvanced( npcEnemy )
      and J.IsInRange( bot, npcEnemy, nCastRange )
      and ( J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
        or npcEnemy:IsChanneling() )
    then
      return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	end
  
  if J.IsInTeamFight( bot, nCastRange )
  then
    local npcStrongestEnemy = nil
		local nStrongestPower = 0
		local nEnemyCount = 0
		local hCastTarget = nil
    
		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
        and J.CanCastOnTargetAdvanced( npcEnemy )
        and not J.IsDisabled( npcEnemy )
        and not npcEnemy:IsDisarmed()
        and not npcEnemy:HasModifier( "modifier_crystal_maiden_crystal_nova" )
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
      and not J.IsDisabled( npcStrongestEnemy )
      and not npcStrongestEnemy:IsDisarmed()
      and not npcStrongestEnemy:HasModifier( "modifier_crystal_maiden_crystal_nova" )
		then
			hCastTarget = npcStrongestEnemy
			return BOT_ACTION_DESIRE_HIGH, hCastTarget
		end
	end
  
  if J.IsLaning( bot ) then
    local LowestEnemy = J.GetLeastHpUnit( nEnemysHeroesInRange )
    if J.IsValidHero( LowestEnemy )
			and J.CanCastOnNonMagicImmune( LowestEnemy )
      and J.CanCastOnTargetAdvanced( LowestEnemy )
      and J.IsInRange( bot, LowestEnemy, nCastRange )
      and J.IsAllowedToSpam( bot, nManaCost )
      and not LowestEnemy:HasModifier( "modifier_crystal_maiden_crystal_nova" )
      and nSkillLV >= 2
    then
      return BOT_ACTION_DESIRE_MODERATE, LowestEnemy
    end
  end
  
  if J.IsGoingOnSomeone( bot ) then
    if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
      and J.CanCastOnTargetAdvanced( botTarget )
      and J.IsInRange( bot, botTarget, nCastRange )
    then
      if not J.IsDisabled( botTarget ) 
        and not botTarget:HasModifier( "modifier_crystal_maiden_crystal_nova" )
      then
        return BOT_ACTION_DESIRE_HIGH, botTarget
      end
    end
  end
  
  if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nEnemysHeroesInRange )
		do
			if J.IsValidHero( npcEnemy ) 
        and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
        and J.CanCastOnNonMagicImmune( npcEnemy )
        and J.CanCastOnTargetAdvanced( npcEnemy )
        and J.IsInRange( bot, npcEnemy, nCastRange )
        and not J.IsDisabled( npcEnemy )
        and not npcEnemy:HasModifier( "modifier_crystal_maiden_crystal_nova" )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
  
	return BOT_ACTION_DESIRE_NONE, 0

end

function X.ConsiderR()

	if not abilityR:IsFullyCastable()
		or bot:DistanceFromFountain() < 300
	then
		return BOT_ACTION_DESIRE_NONE
	end


	local nRadius = abilityR:GetAOERadius() * 0.88

	local nAllies =  bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )

	local nEnemysHeroesInRange = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )

	local aoeCanHurtCount = 0
	for _, enemy in pairs ( nEnemysHeroesInRange )
	do
		if J.IsValidHero( enemy )
			and J.CanCastOnNonMagicImmune( enemy )
			and ( J.IsDisabled( enemy )
				  or J.IsInRange( bot, enemy, nRadius * 0.82 - enemy:GetCurrentMovementSpeed() ) )
		then
			aoeCanHurtCount = aoeCanHurtCount + 1
		end
	end
	if bot:GetActiveMode() ~= BOT_MODE_RETREAT
		or ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() <= 0.85 )
	then
		if ( #nEnemysHeroesInRange >= 3 or aoeCanHurtCount >= 2 )
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end


	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and ( J.IsDisabled( npcTarget ) or J.IsInRange( bot, npcTarget, 280 ) )
			and npcTarget:GetHealth() <= npcTarget:GetActualIncomingDamage( bot:GetOffensivePower() * 1.5, DAMAGE_TYPE_MAGICAL )
			and GetUnitToUnitDistance( npcTarget, bot ) <= nRadius
			and npcTarget:GetHealth() > 400
			and #nAllies <= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsRetreating( bot ) and nHP > 0.38
	then
		local nEnemysHeroesNearby = bot:GetNearbyHeroes( 500, true, BOT_MODE_NONE )
		local nEnemysHeroesFurther = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE )
		local npcTarget = nEnemysHeroesNearby[1]
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and not abilityQ:IsFullyCastable()
			and not abilityW:IsFullyCastable()
			and nHP > 0.38 * #nEnemysHeroesFurther
		then
			return BOT_ACTION_DESIRE_HIGH
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
  
  local nRadius = abilityAS:GetSpecialValueInt( "frostbite_radius" )
  local nManaCost = abilityAS:GetManaCost()
	local nAllies =  bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE )
	local nEnemysHeroesInRange = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
	local aoeCanHurtCount = 0
  
  if bot:IsChanneling()
    and #nEnemysHeroesInRange >= 1
  then
    return BOT_ACTION_DESIRE_HIGH
  end
  
	for _, enemy in pairs ( nEnemysHeroesInRange )
	do
		if J.IsValidHero( enemy )
			and J.CanCastOnNonMagicImmune( enemy )
			and J.IsInRange( bot, enemy, nRadius )
		then
			aoeCanHurtCount = aoeCanHurtCount + 1
		end
	end
  
	if bot:GetActiveMode() ~= BOT_MODE_RETREAT
		or ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() <= 0.85 )
	then
		if ( #nEnemysHeroesInRange >= 2 or aoeCanHurtCount >= 2 )
      and J.IsAllowedToSpam( bot, nManaCost )
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
  
  if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) or J.IsLaning( bot) )
	then
		local nLaneCreepsInView = bot:GetNearbyLaneCreeps( 1600, true )
    local NcreepList = bot:GetNearbyNeutralCreeps( nRadius )
		if #nLaneCreepsInView >= 3 and #hEnemyList == 0
		then
			local nLaneCreeps = bot:GetNearbyLaneCreeps( nRadius, true )
			for _, creep in pairs( nLaneCreeps ) do
				if J.IsValid( creep )
					and not creep:HasModifier( "modifier_fountain_glyph" )
				then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
    elseif #NcreepList >= 2 then
      return BOT_ACTION_DESIRE_HIGH
		end
	end
  
  return BOT_ACTION_DESIRE_NONE
end

return X
-- dota2jmz@163.com QQ:2462331592..
