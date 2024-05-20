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
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,3,2,1,3,6,3,3,2,2,6,1,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_tank'] = {

	"item_tank_outfit",
  	"item_phylactery",
	"item_blink",
	"item_aghanims_shard",
	"item_blade_mail",
	"item_black_king_bar",
  	"item_angels_demise",
	"item_heart",
	"item_travel_boots",
  	"item_overwhelming_blink",
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_travel_boots_2",

}

tOutFitList['outfit_carry'] = tOutFitList['outfit_tank']

--[[{

	"item_sven_outfit",
	"item_blade_mail",
	"item_black_king_bar",
	"item_aghanims_shard",
	"item_blink",
	"item_ultimate_scepter",
	"item_travel_boots",
	"item_overwhelming_blink",	
	"item_abyssal_blade",
	"item_ultimate_scepter_2",
	"item_heart",
	"item_moon_shard",
	"item_travel_boots_2",

}]]

tOutFitList['outfit_mid'] = tOutFitList['outfit_tank']

tOutFitList['outfit_priest'] = tOutFitList['outfit_tank']

tOutFitList['outfit_mage'] = tOutFitList['outfit_tank']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {


	"item_blink",
	"item_quelling_blade",

	"item_blade_mail",
	"item_magic_wand",

	"item_angels_demise",
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

--[[

npc_dota_hero_axe

"Ability1"		"axe_berserkers_call"
"Ability2"		"axe_battle_hunger"
"Ability3"		"axe_counter_helix"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"axe_culling_blade"
"Ability10"		"special_bonus_strength_8"
"Ability11"		"special_bonus_movement_speed_20"
"Ability12"		"special_bonus_mp_regen_2"
"Ability13"		"special_bonus_attack_speed_35"
"Ability14"		"special_bonus_hp_regen_20"
"Ability15"		"special_bonus_unique_axe_3"
"Ability16"		"special_bonus_unique_axe_2"
"Ability17"		"special_bonus_unique_axe"

modifier_axe_berserkers_call
modifier_axe_berserkers_call_armor
modifier_axe_battle_hunger
modifier_axe_battle_hunger_self
modifier_axe_counter_helix
modifier_axe_culling_blade_boost


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )

local castQDesire
local castWDesire, castWTarget
local castRDesire, castRTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 150
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
	
	castRDesire, castRTarget, sMotive = X.ConsiderR()
	if castRDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return
	end
	

	castQDesire, sMotive = X.ConsiderQ()
	if castQDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		--J.SetQueuePtToINT( bot, true )

		bot:Action_UseAbility( abilityQ )
		return
	end

	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if castWDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end

	

end

function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	
	local nRadius = abilityQ:GetSpecialValueInt( "radius" )
	local nCastRange = nRadius
	
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nRadius )
  local nInRangeCreepList = bot:GetNearbyCreeps( nRadius, true )
	local hCastTarget = nil
	local sCastMotive = nil
	
  if #nInRangeEnemyList >= 2 
    or (#nInRangeEnemyList >= 1
    and #nInRangeCreepList >= 3 ) 
  then
    return BOT_ACTION_DESIRE_HIGH
  end
  
	--打断敌人施法
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do 
		if npcEnemy:IsChanneling()
		then
			hCastTarget = npcEnemy
			sCastMotive = 'Q-打断'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, sCastMotive		
		end
	end
	
	
	--攻击敌人时
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nRadius - 90 )
			and J.CanCastOnMagicImmune( botTarget )			
			and not J.IsDisabled( botTarget )
		then			
			hCastTarget = botTarget
			sCastMotive = 'Q-先手'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	end
	


	--带线时嘲讽小兵攻击自己
	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and bot:GetAttackTarget() ~= nil
		and DotaTime() > 6 * 60
		and #hAllyList <= 2 
		and #hEnemyList == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps( nRadius - 50, true )
		if #laneCreepList >= 4
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			hCastTarget = creep
			sCastMotive = 'Q-带线'..(#laneCreepList)
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
		end
	end
	
	
	--打肉时吸引火力
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
	then
		if J.IsRoshan( botTarget )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
			and J.IsInRange( botTarget, bot, nRadius )
		then
			hCastTarget = botTarget
			sCastMotive = 'Q-肉山'
			return BOT_ACTION_DESIRE_HIGH, sCastMotive
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
  local nAttackRange = bot:GetAttackRange() + 40
  
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil
	
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
      and J.CanCastOnTargetAdvanced( botTarget )
      and J.IsAllowedToSpam( bot, nManaCost )
    then
      if GetUnitToUnitDistance( bot, botTarget ) >= nAttackRange + 200
        and J.CanSlowWithPhylacteryOrKhanda()
      then
        hCastTarget = botTarget
        return BOT_ACTION_DESIRE_HIGH, hCastTarget
      elseif not botTarget:HasModifier( "modifier_axe_battle_hunger" ) then
        hCastTarget = botTarget
        return BOT_ACTION_DESIRE_HIGH, hCastTarget
      end
		end
	end
	
	
	--团战中对血量最低的敌人使用
	if J.IsInTeamFight( bot, 1200 )
	then
		local npcWeakestEnemy = nil
		local npcWeakestEnemyHealth = 100000

		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
        and not npcEnemy:HasModifier( "modifier_axe_battle_hunger" )
			then
				local npcEnemyHealth = npcEnemy:GetHealth()
				if ( npcEnemyHealth < npcWeakestEnemyHealth )
				then
					npcWeakestEnemyHealth = npcEnemyHealth
					npcWeakestEnemy = npcEnemy
				end
			end
		end

		if npcWeakestEnemy ~= nil
		then
			hCastTarget = npcWeakestEnemy
			sCastMotive = 'W-团战'..J.Chat.GetNormName( hCastTarget )
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end
	
	
	--对线期间消耗
	if J.IsLaning( bot ) and J.IsAllowedToSpam( bot, nManaCost ) and nSkillLV >= 2
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do 
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and npcEnemy:GetAttackTarget() == nil
				and not npcEnemy:HasModifier( "modifier_axe_battle_hunger" )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'W-对线消耗:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		
		end	
	end
	
	
	
	--撤退时保护自己
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not npcEnemy:HasModifier( "modifier_axe_battle_hunger" )
			then
				hCastTarget = npcEnemy
				sCastMotive = 'W-撤退:'..J.Chat.GetNormName( hCastTarget )
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end
	
	
	--打肉 
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
	then
		if J.IsRoshan( botTarget )
			and not J.IsDisabled( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
			and not botTarget:HasModifier( "modifier_axe_battle_hunger" )
		then
			hCastTarget = botTarget
			sCastMotive = 'W-肉山'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end



	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nCastRange = abilityR:GetCastRange()
	local nDamage = abilityR:GetSpecialValueInt( "damage" )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	
	
	for _, npcEnemy in pairs( nInBonusEnemyList )
	do 
		if J.IsValidHero( npcEnemy )
			and npcEnemy:GetHealth() <= nDamage
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy	
		end
	end


	return BOT_ACTION_DESIRE_NONE


end


function X.HasSpecialModifier( npcEnemy )

	if npcEnemy:HasModifier( 'modifier_winter_wyvern_winters_curse' )
		or npcEnemy:HasModifier( 'modifier_winter_wyvern_winters_curse_aura' )
		or npcEnemy:HasModifier( 'modifier_antimage_spell_shield' )
		or npcEnemy:HasModifier( 'modifier_item_lotus_orb_active' )
		or npcEnemy:HasModifier( 'modifier_item_aeon_disk_buff' )
		or npcEnemy:HasModifier( 'modifier_item_sphere_target' )
		or npcEnemy:HasModifier( 'modifier_illusion' )
	then
		return true
	else
		return false	
	end

end


function X.IsKillBotAntiMage( npcEnemy )

	if not npcEnemy:IsBot() 
		or npcEnemy:GetUnitName() ~= 'npc_dota_hero_antimage'
		or npcEnemy:IsStunned()
		or npcEnemy:IsHexed()
		or npcEnemy:IsNightmared()
		or npcEnemy:IsChanneling()
		or J.IsTaunted( npcEnemy )
	then
		return false
	end
	
	return true

end


return X
-- dota2jmz@163.com QQ:2462331592..
