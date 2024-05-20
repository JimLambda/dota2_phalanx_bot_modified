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
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,3,2,3,6,3,1,1,1,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_crystal_maiden_outfit",
  	"item_phylactery",
  	"item_kaya_and_sange",
  	"item_force_staff",
  	"item_angels_demise",
  	"item_ultimate_scepter",
	"item_aghanims_shard",
	"item_octarine_core",
  	"item_travel_boots",
	"item_ultimate_scepter_2",
	"item_sheepstick",
	"item_moon_shard",
  	"item_travel_boots_2",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = {

	"item_priest_outfit",
 	"item_solar_crest",
  	"item_spirit_vessel",
	"item_aghanims_shard",
	"item_mekansm",
	"item_holy_locket",
	"item_glimmer_cape",
	"item_guardian_greaves",
	"item_ultimate_scepter",
	"item_travel_boots",
  	"item_ultimate_scepter_2",
	"item_travel_boots_2",


}

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {
  
  	"item_angels_demise",
  	"item_magic_wand",
  
	"item_ultimate_scepter",
	"item_null_talisman",

	"item_travel_boots",
	"item_arcane_boots",

	"item_ultimate_scepter",
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

--[[

npc_dota_hero_oracle

"Ability1"		"oracle_fortunes_end"
"Ability2"		"oracle_fates_edict"
"Ability3"		"oracle_purifying_flames"
"Ability4"		"oracle_rain_of_destiny"
"Ability5"		"generic_hidden"
"Ability6"		"oracle_false_promise"
"Ability10"		"special_bonus_unique_oracle_2"
"Ability11"		"special_bonus_intelligence_12"
"Ability12"		"special_bonus_unique_oracle_9"
"Ability13"		"special_bonus_unique_oracle_5"
"Ability14"		"special_bonus_unique_oracle_6"
"Ability15"		"special_bonus_unique_oracle_8"
"Ability16"		"special_bonus_unique_oracle_7"
"Ability17"		"special_bonus_unique_oracle"

modifier_oracle_fortunes_end_channel_target
modifier_oracle_fortunes_end_purge
modifier_oracle_fates_edict
modifier_oracle_purifying_flames
modifier_oracle_false_promise_timer
modifier_oracle_false_promise_invis
modifier_oracle_false_promise

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityQ1 = bot:GetAbilityByName( sAbilityList[1] )
local abilityQ2 = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent3 = bot:GetAbilityByName( sTalentList[3] )
local abilityD = bot:GetAbilityByName( sAbilityList[4] )

local castQDesire, castQTarget
local castQ1Desire, castQ1Target
local castQ2Desire, castQ2Target
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget
local castDDesire, castDTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0

function X.SkillsComplement()

	if X.ConsiderStopChannel() > 0
	then
		bot:Action_ClearActions( true )
		return
	end

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 250
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
--	if talent3:IsTrained() then aetherRange = aetherRange + talent3:GetSpecialValueInt( "value" ) end

	castRDesire, castRTarget, sMotive = X.ConsiderR()
	if ( castRDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return

	end

	castEDesire, castETarget, sMotive = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return
	end

	castWDesire, castWTarget, sMotive = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end

	--for self dispel
	castQ1Desire, castQ1Target, sMotive = X.ConsiderQ1()
	if ( castQ1Desire > 0 )
	then

		bot:Action_UseAbilityOnEntity( abilityQ1, castQ1Target )

		return
	end

	--to cancel enemy healing from ability E earlier
	castQ2Desire, castQ2Target, sMotive = X.ConsiderQ2()
	if ( castQ2Desire > 0 )
	then

		bot:Action_UseAbilityOnEntity( abilityQ2, castQ2Target )
		return
	end

	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )

		if abilityE:IsFullyCastable()
		then
			bot:ActionQueue_UseAbilityOnEntity( abilityE, castQTarget )
		end

		return
	end
	
	castDDesire, castDTarget, sMotive = X.ConsiderD()
	if ( castDDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityD, castDTarget )
		return
	end

end

function X.ConsiderStopChannel()

	if bot:HasModifier("modifier_teleporting") then return 0 end

	if bot:IsChanneling() then
		if castQDesire > 0 then
			return BOT_ACTION_DESIRE_NONE
		else
			local nCoolDown = abilityQ:GetSpecialValueInt("AbilityCooldown")
			local nCoolDownRemain = abilityQ:GetCooldownTimeRemaining()
    		if nCoolDownRemain <= nCoolDown - 0.1 then
      			return BOT_ACTION_DESIRE_HIGH
			end
    	end
  	end
	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderQ1()

	if not abilityQ1:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ1:GetLevel()
	local nCastRange = abilityQ1:GetCastRange() + aetherRange
	local nCastPoint = abilityQ1:GetCastPoint()
	local nManaCost = abilityQ1:GetManaCost()
	local nDamage = abilityQ1:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nRadius = 300
	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
	local nInRangeAllyList = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE )

	if ( J.IsRetreating( bot ) or J.ShouldEscape( bot ) or nHP <= 0.3 )
		and X.CanDispell( bot )
	then
		
		return BOT_ACTION_DESIRE_HIGH, bot
	end

	for _, npcAlly in pairs( nInRangeAllyList )
	do
		if J.IsValidHero( npcAlly )
			and J.IsRetreating( npcAlly )
		then
			if X.CanDispell( npcAlly )
			then
				return BOT_ACTION_DESIRE_HIGH, npcAlly
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderQ2()

	if not abilityQ2:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ2:GetLevel()
	local nCastRange = abilityQ2:GetCastRange() + aetherRange
	local nCastPoint = abilityQ2:GetCastPoint()
	local nManaCost = abilityQ2:GetManaCost()
	local nDamage = abilityQ2:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nRadius = 300
	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )
	local nInRangeAllyList = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_NONE )

	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			if npcEnemy:HasModifier( "modifier_oracle_purifying_flames" )
				or npcEnemy:IsChanneling()
				or X.EnemyCanBeDispell( npcEnemy )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderD()


	if not abilityD:IsTrained()	or not abilityD:IsFullyCastable() then return 0 end

	local nSkillLV = abilityD:GetLevel()
	local nCastRange = 650 + aetherRange
	local nCastPoint = abilityD:GetCastPoint()
	local nManaCost = abilityD:GetManaCost()
	local nDamage = abilityD:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nRadius = 650


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			--and ( botTarget:GetAttackTarget() ~= nil or bot:GetAttackTarget() ~= nil )
      and #hEnemyList >= 2
		then			
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), "D-Attack"..J.Chat.GetNormName( botTarget )
		end
	end
  
	for _, npcAlly in pairs( hAllyList )
	do
		if J.IsValidHero( npcAlly )
			and J.IsInRange( bot, npcAlly, nCastRange )
			and J.CanCastOnNonMagicImmune( npcAlly )
      and npcAlly:HasModifier( "modifier_oracle_false_promise_timer" )
		then
      return BOT_ACTION_DESIRE_HIGH, npcAlly:GetLocation()
    end
  end

	return BOT_ACTION_DESIRE_NONE


end



function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nRadius = 300
	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and not X.EnemyCanBeDispell( botTarget )
			and J.IsChasingTarget( bot, botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "Q-Attack"..J.Chat.GetNormName( botTarget )
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
	local nDamage = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )

	if J.IsInTeamFight( bot, 900 ) and #hEnemyList >= 3
	then
		local npcMostDangerousEnemy = nil
		local nMostDangerousDamage = 0

		for _, npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
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

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy, "W-Battle"..J.Chat.GetNormName( npcMostDangerousEnemy )
		end

	end

	--撤退时缴械攻击自己的( 远程 )敌人


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsAttacking( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, "W-Attack"..J.Chat.GetNormName( botTarget )
		end
	end

	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end

	local nSkillLV = abilityE:GetLevel()
	local nCastRange = abilityE:GetCastRange() + aetherRange
	
	if nCastRange >= 1500 then nCastRange = 1500 end
	
	local nCastPoint = abilityE:GetCastPoint()
	local nManaCost = abilityE:GetManaCost()
	local nDamage = abilityE:GetSpecialValueInt( 'damage' )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange + 50, true, BOT_MODE_NONE )

	--击杀
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and ( J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint ) or J.CanSlowWithPhylacteryOrKhanda() )
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy, "E-击杀"..J.Chat.GetNormName( npcEnemy )
		end
	end

	--治疗队友
	for _, npcAlly in pairs( hAllyList )
	do
		if J.IsValidHero( npcAlly )
			and J.IsInRange( bot, npcAlly, nCastRange )
			and J.CanCastOnNonMagicImmune( npcAlly )
		then
			if npcAlly:GetMagicResist() > 0.42
				and J.GetHP( npcAlly ) < 0.8
				and ( #hEnemyList == 0 or npcAlly:GetHealth() > 999 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcAlly, "E-治疗"..J.Chat.GetNormName( npcAlly )
			end
		end

		if npcAlly:HasModifier( 'modifier_oracle_false_promise_timer' )
			--and J.GetModifierTime( npcAlly, 'modifier_oracle_false_promise_timer' ) > 3.8
			and J.IsInRange( bot, npcAlly, nCastRange )
		then
			return BOT_ACTION_DESIRE_HIGH, npcAlly, "E-支援抢救"..J.Chat.GetNormName( npcAlly )
		end


	end


	--攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange + 50 )
			and J.CanCastOnNonMagicImmune( botTarget )
			--and botTarget:GetMagicResist() < 0.6
		then
			if nSkillLV >= 2
				and abilityQ:IsFullyCastable()
				and abilityE:IsFullyCastable()
				and bot:GetMana() > abilityQ:GetManaCost() + abilityE:GetManaCost()
				and J.IsAllowedToSpam( bot, abilityQ:GetManaCost() + abilityE:GetManaCost())
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget
			end

			local nProjectList = botTarget:GetIncomingTrackingProjectiles()
			for _, p in pairs( nProjectList )
			do
				if not p.is_attack
					and p.ability ~= nil
					and p.ability:GetName() == "oracle_fortunes_end"
					and GetUnitToLocationDistance( botTarget, p.location ) > 330
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget, "E-弹道前进攻"..J.Chat.GetNormName( botTarget )
				end
			end

			if J.WillMagicKillTarget( bot, botTarget, nDamage * 1.6, nCastPoint )
			then
				local nNearTargetAllyList = J.GetAlliesNearLoc( botTarget:GetLocation(), 550 )
				if #nNearTargetAllyList >= 3
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget, "E-击杀前进攻"..J.Chat.GetNormName( botTarget )
				end
			end

		end
	end


	--对线补刀


	--推进
	if not J.IsRetreating( bot ) 
    and J.IsAllowedToSpam( bot, nManaCost )
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps( nCastRange + 350, true )
		for _, creep in pairs( nLaneCreeps )
		do
			if J.IsValid( creep )
				and not creep:HasModifier( 'modifier_fountain_glyph' )
				and creep:GetHealth() > nDamage * 0.6
			then
				if J.IsKeyWordUnit( 'ranged', creep )
					and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "E-补刀远程兵"
				end

				if bot:GetMana() > abilityR:GetManaCost() * 2 and nSkillLV >= 4
					and J.IsKeyWordUnit( 'melee', creep )
					and creep:GetHealth() > nDamage * 0.7
					and J.WillKillTarget( creep, nDamage, nDamageType, nCastPoint )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "E-补刀近战兵"
				end

			end

		end

		if #hAllyList <= 1
		then
			local nCreeps = bot:GetNearbyNeutralCreeps( nCastRange + 150 )
			for _, creep in pairs( nCreeps )
			do
				if J.IsValid( creep )
					and creep:GetHealth() > nDamage * 0.45
					and J.WillKillTarget( creep, nDamage, nDamageType, nCastRange )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "E-补刀野怪"
				end
			end
		end

	end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

	local nSkillLV = abilityR:GetLevel()
	local nCastRange = abilityR:GetCastRange() + aetherRange
	local nCastPoint = abilityR:GetCastPoint()
	local nManaCost = abilityR:GetManaCost()
	local nDamage = abilityR:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE )


	for _, ally in pairs( hAllyList )
	do
		if J.IsInRange( bot, ally, nCastRange + 50 )
			and ally:WasRecentlyDamagedByAnyHero( 2.0 )
			and J.GetHP( ally ) < 0.55
		then
			if J.IsRetreating( ally )
				and ( ally ~= bot or nHP < 0.25 )
			then
				return BOT_ACTION_DESIRE_HIGH, ally, "R-protect"..J.Chat.GetNormName( ally )
			end

			if J.IsGoingOnSomeone( ally ) and J.GetHP( ally ) < 0.3
			then
				local allyTarget = J.GetProperTarget( ally )
				if J.IsValidHero( allyTarget )
					and J.IsInRange( ally, allyTarget, 600 )
				then
					return BOT_ACTION_DESIRE_HIGH, ally, "R-support"..J.Chat.GetNormName( ally )
				end
			end
			
			if not ally:IsBot()
				and J.GetHP( ally ) <= 0.6
				and J.IsValidHero( ally:GetAttackTarget() )
				and ally:WasRecentlyDamagedByAnyHero( 2.0 )
				and #hEnemyList >= 2
				and ( J.IsGoingOnSomeone( bot ) or J.IsGoingOnSomeone( ally ) )
			then			
				return BOT_ACTION_DESIRE_HIGH, ally, "R-ally"..J.Chat.GetNormName( ally )
			end
				
			
		end
	end


	return BOT_ACTION_DESIRE_NONE


end

local Dispellable = {
  
	"modifier_item_spirit_vessel_damage",
	"modifier_arc_warden_flux",
	"modifier_axe_battle_hunger",
	"modifier_bane_enfeeble_effect",
	"modifier_cold_feet",
	"modifier_crystal_maiden_crystal_nova",
	"modifier_crystal_maiden_frostbite",
	"modifier_dazzle_poison_touch",
	"modifier_enchantress_enchant_slow",
	"modifier_enigma_malefice",
	"modifier_huskar_life_break_slow",
	"modifier_lich_chainfrost_slow",
	"modifier_jakiro_dual_breath_slow",
	"modifier_keeper_of_the_light_radiant_bind",
	"modifier_ogre_magi_ignite",
	"modifier_pugna_decrepify",
	"modifier_queenofpain_shadow_strike",
	"modifier_silencer_curse_of_the_silent",
	"modifier_silencer_last_word",
	"modifier_slardar_amplify_damage",
	"modifier_templar_assassin_trap_slow",
	"modifier_treant_leech_seed",
	"modifier_treant_overgrowth",
	"modifier_troll_warlord_whirling_axes_slow",
	"modifier_venomancer_venomous_gale",
	"modifier_warlock_fatal_bonds",
	"modifier_warlock_shadow_word",
	"modifier_warlock_upheaval",
}
  
function X.CanDispell( bot )
	
	for _, modifierName in ipairs(Dispellable) do
		if bot:HasModifier(modifierName) then
			return true
	  	end
	end
	return false
end

local EnemyDispellable = {
	"modifier_item_aeon_disk_buff",
	"modifier_item_crimson_guard_extra",
	"modifier_item_pavise_shield",
	"modifier_item_solar_crest_armor_addition",
	"modifier_abaddon_aphotic_shield",
	"modifier_ember_spirit_flame_guard",
	"modifier_grimstroke_spirit_walk_buff",
	"modifier_legion_commander_press_the_attack",
	"modifier_lich_frost_shield",
	"modifier_aboreal_might_attack_damage",
	"modifier_aboreal_might_armor",
	"modifier_necrolyte_sadist_active",
	"modifier_ogre_magi_bloodlust",
	"modifier_ogre_magi_smash_buff",
	"modifier_omninight_guardian_angel",
	"modifier_pangolier_shield_crash_buff",
	"modifier_pugna_decrepify",
	"modifier_spirit_breaker_bulldoze",
	"modifier_void_spirit_resonant_pulse_physical_buff",
	"modifier_windrunner_windrun",
}
  
function X.EnemyCanBeDispell( Target )
	
	for _, modifierName in ipairs( EnemyDispellable ) do
		if Target:HasModifier(modifierName) then
			return true
	  	end
	end
	return false
end

return X
-- dota2jmz@163.com QQ:2462331592..




