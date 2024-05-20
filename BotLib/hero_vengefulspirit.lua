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
						{1,2,1,2,1,6,1,2,2,3,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_mage'] = {

	"item_mage_outfit",
  	"item_pavise",
  	"item_aether_lens",
  	"item_solar_crest",
  	"item_aghanims_shard",
	"item_boots_of_bearing",
	"item_force_staff",
  	"item_glimmer_cape",
	"item_heart",
  	"item_hurricane_pike",
  	"item_ethereal_blade",
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

	"item_glimmer_cape",
	"item_null_talisman",

	"item_ethereal_blade",
	"item_solar_crest",

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

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent2 = bot:GetAbilityByName( sTalentList[2] )

local castQDesire, castQTarget
local castWDesire, castWLocation
local castRDesire, castRTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0

function X.SkillsComplement()


	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end


	nKeepMana = 330
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1200 )


	local aether = J.IsItemAvailable( "item_aether_lens" )
  local ether = J.IsItemAvailable( "item_ethereal_blade" )
	if aether ~= nil then 
    aetherRange = 225 
  elseif ether ~= nil then
    aetherRange = 250
  end
  
  castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end
  
  castWDesire, castWLocation, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return
	end
  
  castRDesire, castRTarget, sMotive = X.ConsiderR()
	if ( castRDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return
  end
  
end

function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
  local nDamage = abilityQ:GetSpecialValueInt( "magic_missile_damage" )
  local nCastPoint = abilityQ:GetCastPoint()
	local nDamageType = DAMAGE_TYPE_MAGICAL
  local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
	local nInBonusEnemyList = bot:GetNearbyHeroes( nCastRange + 300, true, BOT_MODE_NONE )
  local hCastTarget = nil
  local nAttackRange = bot:GetAttackRange()
  
  for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
      and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			if J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
        or npcEnemy:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
  
  if J.IsInTeamFight( bot, 1200 ) 
	then
		local npcStrongestEnemy = nil
		local nStrongestPower = 0
		
		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValidHero( npcEnemy )
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
  
  if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
      and J.CanCastOnTargetAdvanced( botTarget )
      and not J.IsDisabled( botTarget )
      and ( J.IsChasingTarget( bot, botTarget )
        or not J.IsInRange( bot, botTarget, nAttackRange + 150 ) )
		then
			hCastTarget = botTarget
			return BOT_ACTION_DESIRE_HIGH, hCastTarget
		end
	end
  
  if J.IsRetreating( bot )
  then
    for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
        and J.CanCastOnNonMagicImmune( npcEnemy )
        and J.CanCastOnTargetAdvanced( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				and GetUnitToUnitDistance( bot, npcEnemy ) <= 400
        and not J.IsDisabled( npcEnemy )
        and not npcEnemy:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
  end
  
return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderW()
  
  if not abilityW:IsFullyCastable() then return 0 end
  
  local nSkillLV = abilityW:GetLevel()
	local nCastRange = abilityW:GetCastRange() + aetherRange
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetSpecialValueInt( "damage" )
	local nRadius = abilityW:GetSpecialValueInt( "wave_width" )
	local nDamageType = DAMAGE_TYPE_MAGICAL

	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange -80, true, BOT_MODE_NONE )
	local nTargetLocation = nil
  
  for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
		then
			nTargetLocation = npcEnemy:GetLocation()
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation
		end
	end
  
  if J.IsInTeamFight( bot, 1200 )
	then
		if #nInRangeEnemyList >= 2 or #hAllyList >= 3
		then
			local npcMostDangerousEnemy = nil
			local nMostDangerousDamage = 0

			for _, npcEnemy in pairs( nInRangeEnemyList )
			do
				if J.IsValid( npcEnemy )
					and J.CanCastOnNonMagicImmune( npcEnemy )
					and not J.IsDisabled( npcEnemy )
					and not npcEnemy:IsDisarmed()
				then
					local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL )
					if ( npcEnemyDamage > nMostDangerousDamage )
					then
						nMostDangerousDamage = npcEnemyDamage
						npcMostDangerousEnemy = npcEnemy
					end
				end
			end

      if npcMostDangerousEnemy ~= nil
        and J.IsInRange( bot, npcMostDangerousEnemy, nCastRange + 50 )
      then
        return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy:GetLocation()
      end
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange -80 )
		then
			if nSkillLV >= 2 or nMP > 0.68 or J.GetHP( botTarget ) < 0.5
			then
				nTargetLocation = botTarget:GetExtrapolatedLocation( nCastPoint )
				if J.IsInLocRange( bot, nTargetLocation, nCastRange )
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation
				end
			end
		end
	end
  
  if J.IsFarming( bot )
		and nSkillLV >= 3
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		if J.IsValid( botTarget )
			and J.IsInRange( bot, botTarget, 1000 )
		then
			local nShouldHurtCount = nMP > 0.6 and 2 or 3
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
			if ( locationAoE.count >= nShouldHurtCount )
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation
			end
		end
	end

	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and nSkillLV >= 3 and DotaTime() > 8 * 60
		and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( 1400, true )
		if #laneCreepList >= 3
			and J.IsValid( laneCreepList[1] )
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			local locationAoEKill = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, nDamage )
			if locationAoEKill.count >= 2
	 			and #hAllyList == 1
			then
				nTargetLocation = locationAoEKill.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation
			end

			local locationAoEHurt = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius + 50, 0, 0 )
			if ( locationAoEHurt.count >= 3 and #laneCreepList >= 4 )
			then
				nTargetLocation = locationAoEHurt.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation
			end
		end
	end
  
  return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() or bot:IsRooted() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange() + aetherRange
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetSpecialValueInt( "damage" )
	local nDamageType = DAMAGE_TYPE_MAGICAL
  local nAttackRange = bot:GetAttackRange()


	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange + 80, true, BOT_MODE_NONE )
	local nInBonusEnemyList = bot:GetNearbyHeroes( nCastRange + 240, true, BOT_MODE_NONE )
  local nInRangeAllyList = J.GetAlliesNearLoc( bot:GetLocation(), nCastRange + 240 )
  local nNearbyAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 600 )
  
  for _, npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and not J.IsHaveAegis( npcEnemy )
			and J.CanCastOnMagicImmune( npcEnemy )
      and J.CanCastOnTargetAdvanced( npcEnemy )
      and J.IsInRange( npcEnemy, bot, nCastRange + 100 )
		then
			if npcEnemy:IsChanneling()
        or J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
      end
    end
  end
  
  
  for _, npcAlly in pairs( nInRangeAllyList )
	do
		if J.IsValidHero( npcAlly )
      and J.IsRetreating( npcAlly )
      and J.GetHP( npcAlly ) <= 0.35
      and #nInBonusEnemyList >= 1
      and not npcAlly:HasModifier( "modifier_bloodseeker_rupture" )
      and not bot:HasModifier( "modifier_bloodseeker_rupture" )
		then
      return BOT_ACTION_DESIRE_HIGH, npcAlly
    end
  end
  
  if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
      and J.CanCastOnTargetAdvanced( botTarget )
      and J.IsInRange( botTarget, bot, nCastRange + 300 )
			and not J.IsInRange( botTarget, bot, nAttackRange + 300 ) 
		then
			if #nNearbyAllyList >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget
			end
		end
	end
  
  return BOT_ACTION_DESIRE_NONE

end

return X