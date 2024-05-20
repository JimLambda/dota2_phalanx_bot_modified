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
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{3,1,3,2,3,6,3,1,1,1,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_bristleback_outfit",
	"item_echo_sabre",
	"item_aghanims_shard",
	"item_phylactery",
  	"item_invis_sword",
  	"item_harpoon",
	"item_silver_edge",
  	"item_angels_demise",
	"item_black_king_bar",
  	"item_assault",
  	"item_travel_boots",
  	"item_moon_shard",
	"item_ultimate_scepter_2",
	"item_travel_boots_2",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_invis_sword",
	"item_quelling_blade",

	"item_angels_demise",
	"item_magic_wand",

	"item_black_king_bar",
	"item_bracer",

}


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_tank' }, {"item_heavens_halberd", 'item_quelling_blade'} end

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
local abilityE = bot:GetAbilityByName( "tiny_tree_grab" )
local abilityE1 = bot:GetAbilityByName( "tiny_toss_tree" )
local abilityUS = bot:GetAbilityByName( sAbilityList[4] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )

local castQDesire, castQLocation
local castWDesire, castWTarget
local castEDesire, castETarget
local castE1Desire, castE1Target
local castUSDesire, castUSLocation

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )

	local aether = J.IsItemAvailable( "item_aether_lens" )
  	local ether = J.IsItemAvailable( "item_ethereal_blade" )
		if aether ~= nil then 
    	aetherRange = 225 
  	elseif ether ~= nil then
   		aetherRange = 250
  	end

	castQDesire, castQLocation = X.ConsiderQ()
	if castQDesire > 0
	then

		J.SetQueuePtToINT( bot, true )
		
		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )

		return
	end

	castWDesire, castWTarget = X.ConsiderW()
	if castWDesire > 0
	then

		J.SetQueuePtToINT( bot, true )
		
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )

		return
	end

	castEDesire, castETarget = X.ConsiderE()
	if castEDesire > 0
	then
		
		bot:Action_UseAbilityOnTree( abilityE, castETarget )

		return
	end

	castE1Desire, castE1Target = X.ConsiderE1()
	if castE1Desire > 0
	then
		bot:Action_UseAbilityOnEntity( abilityE1, castE1Target )

		return
	end
  
	castUSDesire, castUSLocation = X.ConsiderUS()
	if castUSDesire > 0
	then
		
		bot:Action_UseAbilityOnLocation( abilityUS, castUSLocation )

		return
	end
  
end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nAttackRange = bot:GetAttackRange()
	local nRadius = abilityQ:GetSpecialValueInt("radius")
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt("avalanche_damage")
	local nDamageType = DAMAGE_TYPE_MAGICAL 
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange + nRadius/2 )
	local nTargetLocation = nil

	for _, npcEnemy in pairs( nInRangeEnemyList )
	do 
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and ( npcEnemy:IsChanneling() or J.WillMagicKillTarget( bot, npcEnemy, nDamage , nCastPoint ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation()
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
		then
			if J.IsChasingTarget( bot, botTarget )
				and not J.IsInRange( bot, botTarget, nAttackRange + 100 )
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
			elseif J.IsAllowedToSpam( bot, nManaCost )
				or #hAllyList >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
			end
		end

		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
		if ( locationAoE.count >= 2 and J.IsAllowedToSpam( bot, nManaCost ) )
			or locationAoE.count >= 3
		then
			nTargetLocation = locationAoE.targetloc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation
		end
	end

	if J.IsInTeamFight( bot, 1600 )
    then
        local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
		if ( locationAoE.count >= 2 )
		then
			nTargetLocation = locationAoE.targetloc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation
		end
    end

	if bot:GetActiveMode() == BOT_MODE_ROSHAN
	then
		if J.IsRoshan( botTarget )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
		then
			hCastTarget = botTarget
			return BOT_ACTION_DESIRE_HIGH, hCastTarget:GetLocation()
		end
	end

	if J.IsRetreating( bot )
        and (J.ShouldEscape( bot ) or J.GetHP( bot ) <= 0.3)
        and #hEnemyList >= 1
    then
        for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.IsInRange( bot, npcEnemy, nCastRange )
                and not J.IsDisabled( npcEnemy )
			    and not npcEnemy:IsDisarmed()
            then
                return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation()
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
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
			if ( locationAoE.count >= 2 )
			then
				nTargetLocation = locationAoE.targetloc
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end

	local nSkillLV = abilityW:GetLevel()
	local nAttackRange = bot:GetAttackRange()
	local nRadius = abilityW:GetSpecialValueInt( "grab_radius" )
	local nCastRange = abilityW:GetCastRange()	
	local nCastPoint = abilityW:GetCastPoint()
	local nManaCost = abilityW:GetManaCost()
	local nDamage = abilityW:GetSpecialValueInt( "toss_damage" )
	local nAttackDamage = bot:GetAttackDamage()

	if J.CanSlowWithPhylacteryOrKhanda() then
		local Phylactery = J.IsItemAvailable( "item_phylactery" )
  		local Khanda = J.IsItemAvailable( "item_angels_demise" )
		if Khanda ~= nil
		then
			nDamage = nDamage + Khanda:GetSpecialValueInt("spell_crit_flat") + ( Khanda:GetSpecialValueInt("spell_crit_multiplier") * nAttackDamage * 0.01 )
		elseif Phylactery ~= nil
		then
			nDamage = nDamage + Phylactery:GetSpecialValueInt("bonus_spell_damage")
		end
	end

	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nNearbyEnemyList = J.GetAroundEnemyHeroList( nRadius )
	local nNearbyEnemyCreepList = bot:GetNearbyCreeps( nRadius, true )
	local nNearbyAllyCreepList = bot:GetNearbyCreeps( nRadius, false )
	local hCastTarget = nil
	local sCastMotive = nil

	for _, npcEnemy in pairs(nNearbyEnemyList)
	do
		if J.IsValidHero(npcEnemy)
			and J.CanCastOnNonMagicImmune(npcEnemy)
			and J.CanCastOnTargetAdvanced(npcEnemy)
			and npcEnemy:IsChanneling()
			and X.CanTossEnemy( bot )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end

		if J.IsValidHero(npcEnemy)
			and J.CanCastOnNonMagicImmune(npcEnemy)
			and J.CanCastOnTargetAdvanced(npcEnemy)
			and J.WillMagicKillTarget( bot, npcEnemy, nDamage , nCastPoint )
			and X.CanTossAny( bot )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end

	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nRadius )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
			and X.CanTossEnemy( bot )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end

		if J.IsValidHero( botTarget )
			and J.IsChasingTarget( bot, botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and not J.IsInRange( bot, botTarget, nAttackRange + 200 )
			and X.CanTossAlly( bot )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end

		if J.IsValidHero( botTarget )
			and J.IsChasingTarget( bot, botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and not J.IsInRange( bot, botTarget, nAttackRange + 200 )
			and X.CanTossAny( bot )
			and J.CanSlowWithPhylacteryOrKhanda()
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end

	end


	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderE()


	if not abilityE:IsFullyCastable() or abilityE:IsHidden() then return 0 end
	
	if J.IsWithoutTarget( bot )
	then
		local trees = bot:GetNearbyTrees( 800 )
		if #trees ~= nil
		then
			local targetTree = trees[1]
			if targetTree ~= nil
			then
				local targetTreeLoc = GetTreeLocation( targetTree )
				if IsLocationVisible( targetTreeLoc )
					and IsLocationPassable( targetTreeLoc )
				then
					return BOT_ACTION_DESIRE_HIGH, targetTree
				end
			end
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		local trees = bot:GetNearbyTrees( 200 )
		if #trees ~= nil
		then
			local targetTree = trees[1]
			if targetTree ~= nil
			then
				local targetTreeLoc = GetTreeLocation( targetTree )
				if IsLocationVisible( targetTreeLoc )
					and IsLocationPassable( targetTreeLoc )
				then
					return BOT_ACTION_DESIRE_HIGH, targetTree
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderE1()

	if not abilityE1:IsFullyCastable() or abilityE1:IsHidden() then return 0 end

	local nAttackRange = bot:GetAttackRange()
	local nDamage = bot:GetAttackDamage()
	
	if J.CanSlowWithPhylacteryOrKhanda() then
		local Phylactery = J.IsItemAvailable( "item_phylactery" )
  		local Khanda = J.IsItemAvailable( "item_angels_demise" )
		if Khanda ~= nil
		then
			nDamage = nDamage + Khanda:GetSpecialValueInt("spell_crit_flat") + ( Khanda:GetSpecialValueInt("spell_crit_multiplier") * nDamage * 0.01 )
		elseif Phylactery ~= nil
		then
			nDamage = nDamage + Phylactery:GetSpecialValueInt("bonus_spell_damage")
		end
	end

	local dmgType = DAMAGE_TYPE_PHYSICAL
	local nCastRange = 1200

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsChasingTarget( bot, botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and not J.IsInRange( bot, botTarget, nAttackRange + 300 )
			and ( J.CanSlowWithPhylacteryOrKhanda() or J.CanKillTarget( botTarget, nDamage, dmgType ) )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderUS()

	if not abilityUS:IsFullyCastable() or not bot:HasScepter() then return 0 end

	local nCastRange = abilityUS:GetCastRange()
	local nCastPoint = abilityUS:GetCastPoint() + 2.4
	local nManaCost = abilityUS:GetManaCost()
	local nAttackRange = bot:GetAttackRange()
	local nRadius = abilityUS:GetSpecialValueInt("splash_radius")
	local nTreeCheckRadius = abilityUS:GetSpecialValueInt("tree_grab_radius")
	local trees = bot:GetNearbyTrees( nTreeCheckRadius )
	local nTargetLocation = nil

	if #trees == 0 then return 0 end

	if J.IsGoingOnSomeone( bot )
		and #trees >= 6
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange)
			and not J.IsInRange( bot, botTarget, nAttackRange + 300 )
		then
			nTargetLocation = J.GetCastLocation( bot, botTarget, nCastRange, nRadius )
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation
		end

		if J.IsValidHero( botTarget )
			and J.IsChasingTarget( bot, botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and not J.IsInRange( bot, botTarget, nAttackRange + 300 )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation( nCastPoint )
		end

		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
		if ( locationAoE.count >= 2 )
		then
			nTargetLocation = locationAoE.targetloc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation
		end
	end

	if J.IsInTeamFight( bot, 1600 )
    then
        local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
		if ( locationAoE.count >= 2 )
		then
			nTargetLocation = locationAoE.targetloc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation
		end
    end

	if ( J.IsPushing( bot ) or J.IsDefending( bot ) ) and J.IsAllowedToSpam( bot, nManaCost )
		and #hAllyList == 0
		and #hEnemyList == 0
	then
		local lanecreeps = bot:GetNearbyLaneCreeps( nCastRange, true )
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 1000, nRadius/2, nCastPoint, nDamage )
		if ( locationAoE.count >= 4 and #lanecreeps >= 4 )
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.CanTossEnemy( bot )

	if not abilityW:IsFullyCastable() then return 0 end

	local nRadius = abilityW:GetSpecialValueInt( "grab_radius" )
	local nNearbyCreepList1 = bot:GetNearbyCreeps( nRadius, true )
	local nNearbyCreepList2 = bot:GetNearbyCreeps( nRadius, false )
	local nNearbyAllyList = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE )
	local nNearbyEnemyList = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
	if #nNearbyCreepList1 == 0
		and #nNearbyCreepList2 == 0
		and #nNearbyAllyList <= 1
		and #nNearbyEnemyList == 1
	then
		return true
	end

	return false

end

function X.CanTossAlly( bot )

	if not abilityW:IsFullyCastable() then return 0 end

	local nRadius = abilityW:GetSpecialValueInt( "grab_radius" )
	local nNearbyCreepList1 = bot:GetNearbyCreeps( nRadius, true )
	local nNearbyCreepList2 = bot:GetNearbyCreeps( nRadius, false )
	local nNearbyTargetAllyList = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE )
	local nNearbyRetreatingAllyList = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_RETREAT )
	local nNearbyTargetEnemyList = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
	if #nNearbyTargetAllyList >= 2
		and #nNearbyCreepList1 == 0
		and #nNearbyCreepList2 == 0
		and #nNearbyRetreatingAllyList == 0
		and #nNearbyTargetEnemyList == 0
	then
		return true
	end

	return false

end


function X.CanTossAny( bot )

	if not abilityW:IsFullyCastable() then return 0 end

	local nRadius = abilityW:GetSpecialValueInt( "grab_radius" )
	local nNearbyCreepList1 = bot:GetNearbyCreeps( nRadius, true )
	local nNearbyCreepList2 = bot:GetNearbyCreeps( nRadius, false )
	local nNearbyAllyList = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE )
	local nNearbyRetreatingAllyList = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_RETREAT )
	local nNearbyEnemyList = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
	if	#nNearbyRetreatingAllyList == 0
		and ( #nNearbyAllyList >= 2
		or #nNearbyCreepList1 >= 1
		or #nNearbyCreepList2 >= 1
		or #nNearbyEnemyList >= 1 )
	then
		return true
	end

	return false

end

return X
-- dota2jmz@163.com QQ:2462331592..

