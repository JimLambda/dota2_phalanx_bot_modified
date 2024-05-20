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
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{3,1,2,1,1,6,1,3,3,3,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_sven_outfit",
	"item_blade_mail",
	"item_yasha_and_kaya",
	"item_aghanims_shard",
	"item_ultimate_scepter",
  	"item_octarine_core",
	"item_silver_edge",
	"item_ultimate_scepter_2",
	"item_wind_waker",
  	"item_travel_boots",
	"item_heart",
	"item_moon_shard",
	"item_travel_boots_2",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_yasha_and_kaya",
	"item_quelling_blade",

	"item_ultimate_scepter",
	"item_magic_wand",

	"item_octarine_core",
	"item_bracer",

	"item_travel_boots",
	"item_blade_mail",

}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_str_carry' }, {"item_power_treads", 'item_quelling_blade'} end

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
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityAS = bot:GetAbilityByName( sAbilityList[4] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQTarget
local castWDesire
local castASDesire
local castRDesire, castRTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget
local aetherRange = 0


function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	if bot:HasModifier("modifier_spirit_breaker_charge_of_darkness")
	then
		bot:SetTarget(nil);
		return
	end

	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
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

	castQDesire, castQTarget = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return

	end

	castWDesire = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		bot:ActionQueue_UseAbility( abilityW )
		return

	end

	castASDesire = X.ConsiderAS()
	if ( castASDesire > 0 )
	then

		bot:ActionQueue_UseAbility( abilityAS )
		return

	end

	castRDesire, castRTarget = X.ConsiderR()
	if ( castRDesire > 0 )
	then

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return

	end

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() or bot:HasModifier("modifier_bloodseeker_rupture") or bot:IsRooted() then return 0 end

	local nDamage = 0
	local nMS = bot:GetCurrentMovementSpeed()

	if abilityE:IsTrained() then
		local nPercent = abilityE:GetSpecialValueInt("damage")
		nDamage = nDamage + ( nPercent * nMS * 0.01 )
	end

	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nManaCost = abilityQ:GetManaCost()
	local nLaneCreeps = bot:GetNearbyLaneCreeps( 600, true )
	local nEnemyTowers = bot:GetNearbyTowers( 1600, true )

	for _, npcEnemy in pairs( hEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and ( J.CanCastOnNonMagicImmune( npcEnemy ) or bot:HasScepter() )
			and ( npcEnemy:IsChanneling() or J.WillMagicKillTarget( bot, npcEnemy, nDamage, 0 ) )
		then
			bot:ActionImmediate_Chat("Q cancel channel or kill",true)
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsAllowedToSpam( bot, nManaCost )
			and J.IsInRange( bot, botTarget, 1600 )
			and J.CanCastOnTargetAdvanced( botTarget )
			and ( J.CanCastOnNonMagicImmune( botTarget ) or bot:HasScepter() )
			and ( #hAllyList >= #hEnemyList or J.IsChasingTarget( bot, botTarget ) )
			and ( #nEnemyTowers == 0 or nLV >= 6 )
		then
			bot:ActionImmediate_Chat("Q attack",true)
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	local numPlayer =  GetTeamPlayers( GetTeam() )
	if nLV >= 6 and not J.IsRetreating( bot )
	then
		for i = 1, #numPlayer
		do
			local member =  GetTeamMember( i )
			if J.IsValid( member )
				and J.IsGoingOnSomeone( member )
			then
				local target = J.GetProperTarget( member )
				if J.IsValidHero( target )
					and J.IsInRange( member, target, 1200 )
					and J.CanCastOnTargetAdvanced( target )
					and ( J.CanCastOnNonMagicImmune( target ) or bot:HasScepter() )
				then
					bot:ActionImmediate_Chat("Q long range",true)
					return BOT_ACTION_DESIRE_HIGH, target
				end
			end
		end
	end

	if J.IsInTeamFight( bot, 1600 ) 
	then
		local npcStrongestEnemy = nil
		local nStrongestPower = 0
		local nEnemyCount = 0
		
		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and ( J.CanCastOnNonMagicImmune( npcEnemy ) or bot:HasScepter() )
			then
				nEnemyCount = nEnemyCount + 1
				if J.CanCastOnTargetAdvanced( npcEnemy )
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
		end

		if npcStrongestEnemy ~= nil
		then
			bot:ActionImmediate_Chat("Q teamfight",true)
			return BOT_ACTION_DESIRE_HIGH, npcStrongestEnemy
		end
	end

	if J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot )
	then
		for _, creep in pairs( nLaneCreeps )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( 'modifier_fountain_glyph' )
			then
				if J.IsKeyWordUnit( 'ranged', creep )
					and J.IsAllowedToSpam( bot, nManaCost )
					and #hEnemyList == 0
				then
					bot:ActionImmediate_Chat("Q pd",true)
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end
		end

		local nNeutralCreeps = bot:GetNearbyNeutralCreeps( 600 )
		if #nNeutralCreeps >= 2
		then
			for _, creep in pairs( nNeutralCreeps )
			do
				if J.IsValid( creep )
					and J.IsAllowedToSpam( bot, nManaCost )
					and bot:IsFacingLocation( creep:GetLocation(), 30 )
					and creep:GetHealth() >= 600
					and creep:GetMagicResist() < 0.3
					and #hEnemyList == 0
				then
					bot:ActionImmediate_Chat("Q f",true)
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end

	local nManaCost = abilityW:GetManaCost()
	local nNeabyEnemy = bot:GetNearbyHeroes( 300, true, BOT_MODE_NONE )

	if J.IsItemAvailable("item_octarine_core")
		and J.IsAllowedToSpam( bot, nManaCost )
	then
		bot:ActionImmediate_Chat("W spam",true)
		return BOT_ACTION_DESIRE_HIGH
	end

	if bot:HasModifier("modifier_spirit_breaker_charge_of_darkness")
	then
		if #nNeabyEnemy >= 1
		then
			bot:ActionImmediate_Chat("W charge",true)
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsInTeamFight( bot, 1600 )
		and #nNeabyEnemy >= 1
	then
		bot:ActionImmediate_Chat("W teamfight",true)
		return BOT_ACTION_DESIRE_HIGH
	end

	if J.IsRetreating( bot )
		and nHP <= 0.4
	then
		bot:ActionImmediate_Chat("W retreat",true)
		return BOT_ACTION_DESIRE_HIGH
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderAS()

	if not abilityAS:IsFullyCastable() or not abilityAS:IsTrained() or bot:HasModifier("modifier_spirit_breaker_charge_of_darkness") then return 0 end

	local nCastRange = abilityAS:GetCastRange()
	local nNearbyAlly = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE )

	if J.IsGoingOnSomeone( bot )
	then
		for _, npcAlly in pairs( nNearbyAlly )
		do
			if J.IsValidHero( npcAlly )
				and J.IsInRange( npcAlly )
				and J.IsUnitTargetProjectileIncoming( npcAlly, 303 )
			then
				bot:ActionImmediate_Chat("AS save",true)
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsRetreating( bot )
		and nHP <= 0.4
	then
		bot:ActionImmediate_Chat("AS retreat",true)
		return BOT_ACTION_DESIRE_HIGH
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderR()

	if not abilityR:IsFullyCastable() or bot:HasModifier("modifier_spirit_breaker_charge_of_darkness") or bot:IsRooted() then return 0 end

	local nDamage = abilityR:GetSpecialValueInt("damage")
	local nMS = bot:GetCurrentMovementSpeed()

	if abilityE:IsTrained() then
		local nPercent = abilityE:GetSpecialValueInt("damage")
		nDamage = nDamage + ( nPercent * nMS * 0.01 )
	end

	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nCastRange = abilityR:GetCastRange() + aetherRange
	local nAttackRange = bot:GetAttackRange()
	local nManaCost = abilityR:GetManaCost()
	local nEnemysHerosInRange = bot:GetNearbyHeroes( nCastRange + 150, true, BOT_MODE_NONE )

	for _, npcEnemy in pairs( nEnemysHerosInRange )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
			and J.CanCastOnMagicImmune( npcEnemy )
			and J.IsInRange( bot, npcEnemy, nCastRange + 300 )
			and ( npcEnemy:IsChanneling() or J.WillMagicKillTarget( bot, npcEnemy, nDamage, 0 ) )
		then
			bot:ActionImmediate_Chat("R cancel channel or kill",true)
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and J.IsChasingTarget( bot, botTarget)
			and J.IsInRange( bot, botTarget, nCastRange )
			and not J.IsInRange( bot, botTarget, nAttackRange + 150 )
		then
			bot:ActionImmediate_Chat("R chase",true)
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

	if J.IsInTeamFight( bot, nCastRange + 100 ) 
	then
		local npcStrongestEnemy = nil
		local nStrongestPower = 0
		local nEnemyCount = 0
		
		for _, npcEnemy in pairs( hEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
			then
				nEnemyCount = nEnemyCount + 1
				if J.CanCastOnTargetAdvanced( npcEnemy )
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
		end

		if npcStrongestEnemy ~= nil
		then
			bot:ActionImmediate_Chat("R teamfight",true)
			return BOT_ACTION_DESIRE_HIGH, npcStrongestEnemy
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
-- dota2jmz@163.com QQ:2462331592..
