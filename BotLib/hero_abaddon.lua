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
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,3,1,1,1,6,1,2,2,2,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRandomItem_1 = RandomInt( 1, 9 ) > 5 and "item_assault" or "item_butterfly"

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_sven_outfit",
  "item_phylactery",
	"item_echo_sabre",
	"item_basher",
  "item_angels_demise",
	"item_harpoon",
	"item_skadi",
	"item_abyssal_blade",
	"item_aghanims_shard",
  "item_ultimate_scepter",
	"item_travel_boots",
  "item_ultimate_scepter_2",
	sRandomItem_1,
	"item_moon_shard",
	"item_travel_boots_2",

}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

	"item_echo_sabre",
	"item_quelling_blade",

	"item_harpoon",
	"item_magic_wand",

  "item_abyssal_blade",
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
local abilityR = bot:GetAbilityByName( sAbilityList[6] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castRDesire

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0


function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 200
	aetherRange = 0
	nLV = bot:GetLevel()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )
  
  
	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if castQDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )
    
			bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
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

	castRDesire, sMotive = X.ConsiderR()
	if castRDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		--J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityR )
		return
	end

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end
  
	local nCastRange = abilityQ:GetCastRange()
	local nDamage = abilityQ:GetSpecialValueInt( "target_damage" )
  local nManaCost = abilityQ:GetManaCost()
	local nCastPoint = abilityQ:GetCastPoint()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange + 300 )
	local nInRangeAllyList = J.GetAllyList( bot, nCastRange + 300 )
  local hCastTarget = nil
  
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
      and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			if J.WillMagicKillTarget( bot, npcEnemy, nDamage, nCastPoint )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
  
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange)
			and J.CanCastOnNonMagicImmune( botTarget )
      and J.CanCastOnTargetAdvanced( botTarget )
      and J.IsAllowedToSpam( bot, nManaCost )
      and (botTarget:GetHealth() / botTarget:GetMaxHealth() <= 0.5 
          or J.CanSlowWithPhylacteryOrKhanda())
		then
			hCastTarget = botTarget
			return BOT_ACTION_DESIRE_HIGH, hCastTarget
		end
	end
	
  if not J.IsRetreating( bot ) and nHP > 0.7 then
    for _, ally in pairs( nInRangeAllyList )
    do
      if J.IsValidHero(ally) 
        and ally:GetHealth()/ally:GetMaxHealth() <= 0.5
        and not ally:HasModifier( "modifier_ice_blast" ) 
        and not ally:HasModifier( "modifier_doom_bringer_doom" ) then
        return BOT_ACTION_DESIRE_HIGH, ally
      end
    end
	end

  local EnemyNearby = J.GetAroundEnemyHeroList( nCastRange )
  local LowestHealth = 99999
  local LowestEnemy = nil

  if bot:HasModifier("modifier_abaddon_borrowed_time") then
    for _, npcEnemy in pairs(EnemyNearby) do
      if J.IsValidHero(npcEnemy) 
        and J.CanCastOnNonMagicImmune(npcEnemy) then
        local enemyHealth = npcEnemy:GetHealth()
        if enemyHealth < LowestHealth then
          LowestHealth = enemyHealth
          LowestEnemy = npcEnemy
        end
      end
    end
  end

  if LowestEnemy ~= nil then
    return BOT_ACTION_DESIRE_HIGH, LowestEnemy
  end


	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end

	local nCastRange = abilityW:GetCastRange()
  local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 300 )
	local nInRangeAllyList = bot:GetNearbyHeroes( nCastRange + 100, false, BOT_MODE_NONE)
  
	if X.CanDispell( bot ) then
    return BOT_ACTION_DESIRE_HIGH, bot
  end
  
	if J.IsGoingOnSomeone( bot )
	then
		if #nInRangeAllyList <= #nInBonusEnemyList 
      and nHP <= 0.7
		then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end
	
  
	if J.IsRetreating( bot ) then 
		if #nInRangeEnemyList >= 3
			or nHP <= 0.5 then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end
	
  local SaveAlly = nil
  if not J.IsRetreating(bot) 
  then
    for _, ally in pairs(nInRangeAllyList) do
      if J.IsValidHero(ally) 
        and J.IsInRange( bot, ally, nCastRange + 300) 
      then
        if ( ally:IsRooted() 
          or ally:IsStunned() 
          or ally:IsNightmared() 
          or ally:HasModifier("modifier_legion_commander_duel")
          or J.GetHP(ally) <= 0.2 ) 
        then
          SaveAlly = ally
        end
      end
    end
  end
  
  if SaveAlly ~= nil then
    return BOT_ACTION_DESIRE_HIGH, SaveAlly
  end

return BOT_ACTION_DESIRE_NONE



end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() 
    and not bot:HasScepter() then 
      return 0 
  end
  
	local nRadius = abilityR:GetSpecialValueInt( "redirect_range_scepter" )
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nRadius )
  local nInRangeAllyList = J.GetAllyList( bot, nRadius )
  local AllyCount = 0
  
  for _, ally in pairs(nInRangeAllyList) do
    if J.IsValidHero(ally) then
      if ally:GetHealth() / ally:GetMaxHealth() <= 0.5 then
        AllyCount = AllyCount + 1
      end
    end
  end
  
  if AllyCount >= 3 then
    return BOT_ACTION_DESIRE_HIGH
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
  "modifier_disruptor_thunder_strike",
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
  "modifier_vengefulspirit_wave_of_terror",
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

return X
-- dota2jmz@163.com QQ:2462331592..
