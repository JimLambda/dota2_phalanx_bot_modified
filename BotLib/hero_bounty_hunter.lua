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
						{1,2,3,1,1,6,1,2,2,2,6,3,3,3,6},
						{1,2,1,3,1,6,1,2,2,2,6,3,3,3,6},
						{2,1,1,3,1,6,1,2,2,2,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_carry'] = {

	"item_phantom_assassin_outfit",
	"item_phylactery",
	"item_desolator",
	"item_black_king_bar",
	"item_ultimate_scepter",
  	"item_angels_demise",
	"item_butterfly",
	"item_travel_boots",
  	"item_ultimate_scepter_2",
	"item_nullifier",
	"item_aghanims_shard",
	"item_moon_shard",
	"item_travel_boots_2",


}

tOutFitList['outfit_mid'] = tOutFitList['outfit_carry']

tOutFitList['outfit_priest'] = tOutFitList['outfit_carry']

tOutFitList['outfit_mage'] = tOutFitList['outfit_carry']

tOutFitList['outfit_tank'] = tOutFitList['outfit_carry']
--[[{

	"item_dragon_knight_outfit",
	"item_crimson_guard",
	"item_heavens_halberd",
	"item_ultimate_scepter",
	"item_travel_boots",
	"item_black_king_bar",
	"item_assault",
	"item_moon_shard",
	"item_travel_boots_2",
	"item_reaver",
	"item_ultimate_scepter_2",
	"item_heart",


}]]


X['sBuyList'] = tOutFitList[sOutfitType]


X['sSellList'] = {

	"item_phylactery",
	"item_quelling_blade",

	"item_desolator",
	"item_magic_wand",

	"item_black_king_bar",
	"item_wraith_band",

	"item_angels_demise",
	"item_orb_of_corrosion",

}

if J.Role.IsPvNMode() then X['sBuyList'], X['sSellList'] = { 'PvN_BH' }, {"item_power_treads", 'item_quelling_blade'} end

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

npc_dota_hero_bounty_hunter

"Ability1"		"bounty_hunter_shuriken_toss"
"Ability2"		"bounty_hunter_jinada"
"Ability3"		"bounty_hunter_wind_walk"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"bounty_hunter_track"
"Ability10"		"special_bonus_movement_speed_15"
"Ability11"		"special_bonus_attack_damage_20"
"Ability12"		"special_bonus_unique_bounty_hunter_2"
"Ability13"		"special_bonus_hp_275"
"Ability14"		"special_bonus_attack_speed_50"
"Ability15"		"special_bonus_unique_bounty_hunter"
"Ability16"		"special_bonus_evasion_40"
"Ability17"		"special_bonus_unique_bounty_hunter_3"

modifier_bounty_hunter_jinada
modifier_bounty_hunter_wind_walk
modifier_bounty_hunter_wind_walk_slow
modifier_bounty_hunter_track

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local abilityAS = bot:GetAbilityByName( sAbilityList[4] )

local castQDesire, castQTarget
local castEDesire
local castRDesire, castRTarget
local castASDesire, castASTarget

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0

function X.SkillsComplement()
  
	if J.CanNotUseAbility( bot ) then return end

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

	
	castEDesire, sMotive = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, false )

		bot:ActionQueue_UseAbility( abilityE )
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


	castQDesire, castQTarget, sMotive = X.ConsiderQ()
	if ( castQDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return
	end
  
  castASDesire, castASTarget, sMotive = X.ConsiderAS()
	if ( castASDesire > 0 )
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityAS, castASTarget )
		return
	end

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end
  
	local nSkillLV = abilityQ:GetLevel()
	local nCastRange = abilityQ:GetCastRange() + aetherRange
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
	local nDamage = abilityQ:GetSpecialValueInt( "bonus_damage" )
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
	local nCastTarget = nil
  
	local nRadius = abilityQ:GetSpecialValueInt( "bounce_aoe" )
	local nEnemyUnitList = J.GetAroundBotUnitList( bot, nCastRange + 100, true )
	local nTrackEnemy = 0
  
	for _, npcEnemy in pairs( hEnemyList )
	do
		if J.IsValidHero( npcEnemy )
      and npcEnemy:HasModifier( "modifier_bounty_hunter_track" )
		then
      nTrackEnemy = nTrackEnemy + 1
    end
  end
  
  if nTrackEnemy >= 2
    and not J.IsRetreating( bot )
  then
    local botTarget = J.GetProperTarget( bot )
    if J.IsValidHero( botTarget )
      and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
      and J.IsInRange( bot, botTarget, nCastRange )
      and not bot:HasModifier( "modifier_bounty_hunter_wind_walk")
      and ( not botTarget:HasModifier( "modifier_bounty_hunter_track" )
        or nTrackEnemy >= 3 )
    then
      return BOT_ACTION_DESIRE_HIGH, botTarget
    end
  end
  
  if J.IsGoingOnSomeone( bot )
  then
    if J.IsValidHero( botTarget )
      and J.CanCastOnNonMagicImmune( botTarget )
      and J.CanCastOnTargetAdvanced( botTarget )
      and J.IsInRange( bot, botTarget, nCastRange )
    then
      if J.WillMagicKillTarget( bot, botTarget, nDamage, nCastPoint )
      then
        return BOT_ACTION_DESIRE_HIGH, botTarget
      elseif J.CanSlowWithPhylacteryOrKhanda()
        and not bot:HasModifier( "modifier_bounty_hunter_wind_walk")
      then
        return BOT_ACTION_DESIRE_HIGH, botTarget
      elseif nSkillLV >= 3
        and not bot:HasModifier( "modifier_bounty_hunter_wind_walk")
      then
        return BOT_ACTION_DESIRE_HIGH, botTarget
      end
    end
  end
  
  if J.IsLaning( bot ) and nSkillLV >= 2
  then
    local LowestEnemy = J.GetLeastHpUnit( nEnemyUnitList )
    if LowestEnemy ~= nil
      and J.IsValidHero( LowestEnemy )
      and J.CanCastOnNonMagicImmune( LowestEnemy )
      and J.CanCastOnTargetAdvanced( LowestEnemy )
      and J.IsInRange( bot, LowestEnemy, nCastRange )
      and J.IsAllowedToSpam( bot, nManaCost )
      and not bot:HasModifier( "modifier_bounty_hunter_wind_walk")
    then
      return BOT_ACTION_DESIRE_HIGH, LowestEnemy
    end
  end
  
	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end


	local nSkillLV = abilityE:GetLevel()
  
  if not J.IsRetreating( bot ) then
    local enemyHeroes = bot:GetNearbyHeroes( 400 , true, BOT_MODE_NONE)
    for _, CEnemy in pairs( enemyHeroes )do
      if ((CEnemy:IsChanneling() or CEnemy:HasModifier( "modifier_teleporting" )) 
        and J.IsValid( CEnemy ) 
        and not CEnemy:IsMagicImmune()) then
        --[[bot:ActionQueue_UseAbility(abilityE)
        bot:ActionQueue_AttackUnit(CEnemy, true)]]
        return BOT_ACTION_DESIRE_HIGH
      end
    end
  end

	--进攻
	if J.IsGoingOnSomeone( bot )
		and ( nLV >= 7 or DotaTime() > 6 * 60 or nSkillLV >= 2 )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, 2500 )
			and ( not J.IsInRange( bot, botTarget, 1000 )
					or J.IsChasingTarget( bot, botTarget )
          )
		then
			return BOT_ACTION_DESIRE_HIGH, "E-隐身进攻:"..J.Chat.GetNormName( botTarget )
		end
	end


	--撤退
	if J.IsRetreating( bot )
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and ( #hEnemyList >= 1 or nHP < 0.2 )
		and bot:DistanceFromFountain() > 800
	then
		return BOT_ACTION_DESIRE_HIGH, "E-隐身逃跑"
	end


	--潜行
	if J.IsInEnemyArea( bot ) and nLV >= 7 and nMP >= 280
	then
		local nEnemies = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
		local nEnemyTowers = bot:GetNearbyTowers( 1600, true )
		if #nEnemies == 0 and nEnemyTowers == 0
		then
			return BOT_ACTION_DESIRE_HIGH, "E-潜行"
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
  
  local nCastRange = abilityAS:GetCastRange() + aetherRange
  local BAllyList = bot:GetNearbyHeroes( nCastRange + 300, false, BOT_MODE_NONE )
  for _, ally in pairs( BAllyList )
	do
		if (J.IsValid( ally )
			and ally ~= bot
			and not ally:IsIllusion()
      and not ally:HasModifier( "modifier_item_shadow_amulet_fade" )
      and not ally:HasModifier( "modifier_item_glimmer_cape_fade" )
      and not ally:HasModifier( "modifier_item_invisibility_edge_windwalk" )
      and not ally:HasModifier( "modifier_item_silver_edge_windwalk" ) 
      and not ally:HasModifier( "modifier_arc_warden_tempest_double" ))
    then
        local hpPercent = ally:GetHealth() / ally:GetMaxHealth()
        if hpPercent <= 0.2 then
            return BOT_ACTION_DESIRE_HIGH, ally
        elseif ally:IsChanneling() then
            return BOT_ACTION_DESIRE_HIGH, ally
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
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange + 300 )
  local nCastTarget = nil
  
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do
		if J.IsValidHero( npcEnemy )
      and not npcEnemy:HasModifier( "modifier_bounty_hunter_track" )
			and not npcEnemy:HasModifier( "modifier_arc_warden_tempest_double" )
			and J.CanCastAbilityOnTarget( npcEnemy, true )
			and J.CanCastOnTargetAdvanced( npcEnemy )
      and (X.TargetInviHeroFirst( npcEnemy )
          or J.IsAllyCanKill( npcEnemy )
          or J.CanSlowWithPhylacteryOrKhanda()
          or #nInRangeEnemyList >= 1)
		then
			nCastTarget = npcEnemy
		end
	end
	if nCastTarget ~= nil
	then
		return BOT_ACTION_DESIRE_HIGH, nCastTarget, "R-标记:"..J.Chat.GetNormName( nCastTarget )
	end

	return BOT_ACTION_DESIRE_NONE


end

local InvisHero = {
  
  "npc_dota_hero_clinkz",
  "npc_dota_hero_invoker",
  "npc_dota_hero_mirana",
  "npc_dota_hero_nyx_assassin",
  "npc_dota_hero_riki",
  "npc_dota_hero_sand_king",
  "npc_dota_hero_templar_assassin",
  "npc_dota_hero_treant",
  "npc_dota_hero_weaver",
  "npc_dota_hero_windrunner",
  
}

function X.TargetInviHeroFirst( botTarget )
  
  for _, IsInvi in ipairs(InvisHero) do
    if botTarget:GetUnitName() == IsInvi then
      return true
    end
  end
  
  if J.IsValidHero( botTarget )
    and (J.HasItem( botTarget, "item_shadow_amulet" )
      or J.HasItem( botTarget, "item_silver_edge" )
      or J.HasItem( botTarget, "item_invis_sword" )
      or J.HasItem( botTarget, "item_glimmer_cape" ))
  then
    return true
  end
      
  return false
end

return X
-- dota2jmz@163.com QQ:2462331592..