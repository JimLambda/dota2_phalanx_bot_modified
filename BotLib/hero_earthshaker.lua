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
                        {1,3,1,2,3,6,3,3,2,2,6,2,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local tOutFitList = {}

tOutFitList['outfit_mage'] = {

    "item_ogre_outfit",
    "item_blink",
    "item_aghanims_shard",
    "item_force_staff",
    "item_black_king_bar",
    "item_ultimate_scepter",
    "item_octarine_core",
    "item_overwhelming_blink",
    "item_ultimate_scepter_2",
    "item_refresher",
    "item_travel_boots_2",

}

tOutFitList['outfit_tank'] = tOutFitList['outfit_mage']

tOutFitList['outfit_carry'] = tOutFitList['outfit_mage']

tOutFitList['outfit_mid'] = tOutFitList['outfit_mage']

tOutFitList['outfit_priest'] = tOutFitList['outfit_mage']

X['sBuyList'] = tOutFitList[sOutfitType]

X['sSellList'] = {

    "item_force_staff",
    "item_magic_wand",

    "item_ultimate_scepter",
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
local abilityW1 = bot:GetAbilityByName( sAbilityList[2] )
local abilityW2 = bot:GetAbilityByName( sAbilityList[2] )
local abilityW3 = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent2 = bot:GetAbilityByName( sTalentList[2] )

local castQDesire, castQLocation
local castW1Desire
local castW2Desire, castW2Location
local castW3Desire, castW3Target
local castRDesire
local castRFRDesire

local nKeepMana, nMP, nHP, nLV, hEnemyList, hAllyList, botTarget, sMotive
local aetherRange = 0
local abilityRef = nil


function X.SkillsComplement()

	if J.CanNotUseAbility( bot ) then return end

	aetherRange = 0
	nLV = bot:GetLevel()
    nKeepMana = nLV < 6 and 150 or abilityR:GetManaCost()
	nMP = bot:GetMana() / bot:GetMaxMana()
	nHP = bot:GetHealth() / bot:GetMaxHealth()
	botTarget = J.GetProperTarget( bot )
	hEnemyList = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE )
	hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 1600 )
    abilityRef = J.IsItemAvailable( "item_refresher" )

	local aether = J.IsItemAvailable( "item_aether_lens" )
    local ether = J.IsItemAvailable( "item_ethereal_blade" )
	if aether ~= nil then 
    aetherRange = 225 
  elseif ether ~= nil then
    aetherRange = 250
  end

    castRFRDesire = X.ConsiderRFR()
    if ( castRFRDesire > 0 )
    then

        J.SetQueuePtToINT( bot, true )

        bot:ActionQueue_UseAbility( abilityR )
        bot:ActionQueue_UseAbility( abilityRef )
        bot:Action_UseAbility( abilityR )
        return
    end
	
	castRDesire, sMotive = X.ConsiderR()
	if castRDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:Action_UseAbility( abilityR )
		return
	end
	

	castQDesire, castQLocation, sMotive = X.ConsiderQ()
	if castQDesire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		return
	end

	castW1Desire, sMotive = X.ConsiderW1()
	if castW1Desire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

        bot:ActionQueue_UseAbility( abilityW1 )
		return
	end

    castW2Desire, castW2Location, sMotive = X.ConsiderW2()
	if castW2Desire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

        bot:ActionQueue_UseAbilityOnLocation( abilityW1, castW2Location )
		return
	end

    castW3Desire, castW3Target, sMotive = X.ConsiderW3()
	if castW3Desire > 0
	then
		J.SetReportMotive( bDebugMode, sMotive )

        bot:ActionQueue_UseAbilityOnEntity( abilityW3, castW3Target )
		return
	end

	

end

function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() or bot:IsInvisible() then return 0 end

	local nSkillLV = abilityQ:GetLevel()
	
	local nRadius = abilityQ:GetSpecialValueInt( "fissure_radius" )
	local nCastRange = 1600
    local nFarmCastRange = 350
	
	local nCastPoint = abilityQ:GetCastPoint()
	local nManaCost = abilityQ:GetManaCost()
    local nDamage = abilityQ:GetSpecialValueInt( "fissure_damage" )
    local nAfterShockDamage = 0
    local nAfterShockRadius = 0
    if abilityE:IsTrained() then 
        nAfterShockDamage = abilityE:GetSpecialValueInt( "aftershock_damage" )
        nAfterShockRadius = abilityE:GetSpecialValueInt( "aftershock_range" )
    end
    local nNearDamage = nDamage + nAfterShockDamage
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange + nRadius )
    local nInRangeCreepList = bot:GetNearbyCreeps( nCastRange, true )
    local nNearbyCreepList = bot:GetNearbyCreeps( nAfterShockRadius, true )
	local hCastTarget = nil
	local sCastMotive = nil
    local nTargetLocation = nil
  
	for _, npcEnemy in pairs( nInRangeEnemyList )
	do 
		if J.IsValidHero( npcEnemy )
            and J.CanCastOnNonMagicImmune( npcEnemy )
            and not J.IsDisabled( npcEnemy )
		then
            if npcEnemy:IsChanneling()
            then
			    hCastTarget = npcEnemy
			    return BOT_ACTION_DESIRE_HIGH, hCastTarget:GetLocation()

            elseif J.WillMagicKillTarget( bot, npcEnemy, nDamage, 0 )
            then
                nTargetLocation = npcEnemy:GetExtrapolatedLocation( nCastPoint )
                return BOT_ACTION_DESIRE_HIGH, nTargetLocation
            end		
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


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )			
			and not J.IsDisabled( botTarget )
            and ( J.IsChasingTarget( bot, botTarget ) 
            or J.IsAllowedToSpam( bot, nManaCost ) )
		then			
			nTargetLocation = botTarget:GetExtrapolatedLocation( nCastPoint )
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation
        end
        local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
		if ( locationAoE.count >= 2 )
		then
			nTargetLocation = locationAoE.targetloc
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation
		end
	end
	
    if not J.IsRetreating( bot )
    then
        for _, creep in pairs( nInRangeCreepList )
        do
            if J.IsValid( creep )
                and not creep:HasModifier( 'modifier_fountain_glyph' )
            then
                if J.IsKeyWordUnit( 'ranged', creep )
                    and J.WillMagicKillTarget( bot, creep, nDamage, 0 )
                    and J.IsAllowedToSpam( bot, nManaCost )
                then
                    return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
                end
            end
        end
    end


	if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and #hEnemyList == 0
        and not bot:HasScepter()
	then
		local nCreepCount = 0
        local TargetCreep = nil
        for _, NearCreep in pairs( nNearbyCreepList )
        do
            if J.IsValid( NearCreep )
                and not NearCreep:HasModifier( 'modifier_fountain_glyph' )
                and J.WillMagicKillTarget( bot, NearCreep, nNearDamage, 0 )
            then
                nCreepCount = nCreepCount + 1
                TargetCreep = NearCreep
                if nCreepCount >= 2
                    and J.IsValid( TargetCreep )
                then
                    return BOT_ACTION_DESIRE_HIGH, TargetCreep:GetLocation()
                end
            end
        end
	end
	
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN
	then
		if J.IsRoshan( botTarget )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
			and J.IsInRange( botTarget, bot, nFarmCastRange )
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
				and J.IsInRange( bot, npcEnemy, 800 )
                and not J.IsDisabled( npcEnemy )
			    and not npcEnemy:IsDisarmed()
            then
                return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation()
            end
        end
    end

	return BOT_ACTION_DESIRE_NONE


end


function X.ConsiderW1()


	if not abilityW1:IsFullyCastable() or bot:IsInvisible() or bot:HasScepter() then return 0 end

	local nSkillLV = abilityW1:GetLevel()
	local nCastRange = abilityW1:GetCastRange() + aetherRange
	local nCastPoint = abilityW1:GetCastPoint()
    local nRadius = 0
    if abilityE:IsTrained() then nRadius = abilityE:GetSpecialValueInt( "aftershock_range" ) end

	local nManaCost = abilityW1:GetManaCost()
    local nNearbyEnemy = J.GetAroundEnemyHeroList( nRadius )
	local hCastTarget = nil
	local sCastMotive = nil
    local nTargetLocation = nil

    for _, npcEnemy in pairs( nNearbyEnemy )
	do
		if J.IsValidHero( npcEnemy )
            and J.CanCastOnNonMagicImmune( npcEnemy )
            and ( npcEnemy:IsChanneling() or not J.IsDisabled( npcEnemy ) )
            and J.IsInRange( bot, npcEnemy, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsGoingOnSomeone( bot ) or J.IsInTeamFight( bot, 1600 )
	then
		if J.IsValidHero( botTarget )
		    and J.IsInRange( botTarget, bot, nRadius )
		    and J.CanCastOnNonMagicImmune( botTarget )			
		    and not J.IsDisabled( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH
        end

		if ( #nNearbyEnemy >= 2 )
		then
			return BOT_ACTION_DESIRE_HIGH
        end
    end

    if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and #hEnemyList == 0
        and not bot:HasModifier( "modifier_earthshaker_enchant_totem" )
	then
        local laneCreepList = bot:GetNearbyLaneCreeps( nRadius, true )
		if #laneCreepList >= 2
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			return BOT_ACTION_DESIRE_HIGH
		end

        local aTarget = bot:GetAttackTarget()
        if aTarget ~= nil
		    and aTarget:IsBuilding()
            and #laneCreepList == 0
            and #hEnemyList == 0
	    then
		    return BOT_ACTION_DESIRE_HIGH
        elseif J.IsValid( aTarget )
            and aTarget:GetTeam() == TEAM_NEUTRAL
            and J.IsInRange( bot, aTarget, nRadius )
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsRetreating( bot )
        and J.ShouldEscape( bot )
    then
        local EnemyNearby = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
        if #EnemyNearby >= 1
            and J.CanCastOnNonMagicImmune( EnemyNearby[1] )
        then
		    return BOT_ACTION_DESIRE_HIGH
        end
	end

	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderW2()

    if not abilityW2:IsFullyCastable() or bot:IsInvisible() or not bot:HasScepter() then return 0 end
    if bot:HasScepter() and (bot:IsRooted() or bot:IsInvisible()) then return 0 end
    
    local nSkillLV = abilityW2:GetLevel()
	local nCastRange = abilityW2:GetSpecialValueInt( "distance_scepter" ) + aetherRange
	local nCastPoint = abilityW2:GetSpecialValueInt( "scepter_leap_duration" )
    local nRadius = 0
    if abilityE:IsTrained() then nRadius = abilityE:GetSpecialValueInt( "aftershock_range" ) end
	local nManaCost = abilityW2:GetManaCost()
	local nInRangeEnemyList = J.GetAroundEnemyHeroList( nCastRange )
    local nNearbyEnemy = J.GetAroundEnemyHeroList( nRadius )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )
	local hCastTarget = nil
	local sCastMotive = nil
    local nTargetLocation = nil

    for _, npcEnemy in pairs( nInBonusEnemyList )
    do 
        if J.IsValidHero( npcEnemy )
            and J.CanCastOnNonMagicImmune( npcEnemy )
            and not J.IsDisabled( npcEnemy )
            and npcEnemy:IsChanneling()
            and J.IsInRange( bot, npcEnemy, nCastRange)
            and not J.IsInRange( bot, npcEnemy, nRadius)
        then
            return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation()
        end
    end

    if J.IsGoingOnSomeone( bot ) or J.IsInTeamFight( bot, 1600 )
	then
		if J.IsValidHero( botTarget )
		    and ( J.IsInRange( botTarget, bot, nCastRange ) or J.IsChasingTarget( bot, botTarget ) )
            and not J.IsInRange( bot, botTarget, nRadius - 100)
		    and J.CanCastOnNonMagicImmune( botTarget )
		    and not J.IsDisabled( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation( nCastPoint )
        end

        local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 )
        if ( locationAoE.count >= 2 )
        then
            nTargetLocation = locationAoE.targetloc
            if GetUnitToLocationDistance( bot, nTargetLocation ) >= nRadius + 100
            then
                return BOT_ACTION_DESIRE_HIGH, nTargetLocation
            end
        end
    end

    if J.IsRetreating( bot )
        and #hEnemyList >= 1
        and J.ShouldEscape( bot )
        and not bot:HasModifier( "modifier_bloodseeker_rupture" )
    then
        local loc = J.GetEscapeLoc()
        local location = J.Site.GetXUnitsTowardsLocation( bot, loc, nCastRange )
        return BOT_ACTION_DESIRE_HIGH, location
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderW3()

    if not abilityW3:IsFullyCastable() or bot:IsInvisible() or not bot:HasScepter() then return 0 end

    local nSkillLV = abilityW3:GetLevel()
	local nCastRange = abilityW3:GetCastRange() + aetherRange
	local nCastPoint = abilityW3:GetCastPoint()
    local nRadius = 0
    if abilityE:IsTrained() then nRadius = abilityE:GetSpecialValueInt( "aftershock_range" ) end

	local nManaCost = abilityW3:GetManaCost()
    local nNearbyEnemy = J.GetAroundEnemyHeroList( nRadius )
	local hCastTarget = nil
	local sCastMotive = nil
    local nTargetLocation = nil

    for _, npcEnemy in pairs( nNearbyEnemy )
	do
		if J.IsValidHero( npcEnemy )
            and J.CanCastOnNonMagicImmune( npcEnemy )
            and ( npcEnemy:IsChanneling() or not J.IsDisabled( npcEnemy ) )
            and J.IsInRange( bot, npcEnemy, nRadius)
		then
			return BOT_ACTION_DESIRE_HIGH, bot
        end
    end

    if J.IsGoingOnSomeone( bot ) or J.IsInTeamFight( bot, 1600 )
	then
		if J.IsValidHero( botTarget )
		    and J.IsInRange( botTarget, bot, nRadius )
		    and J.CanCastOnNonMagicImmune( botTarget )			
		    and not J.IsDisabled( botTarget )
            and J.IsInRange( bot, botTarget, nRadius - 100)
		then					
			return BOT_ACTION_DESIRE_HIGH, bot
        end

		if ( #nNearbyEnemy >= 2 )
		then
			return BOT_ACTION_DESIRE_HIGH, bot
        end
    end

    if ( J.IsPushing( bot ) or J.IsDefending( bot ) or J.IsFarming( bot ) )
		and J.IsAllowedToSpam( bot, nManaCost )
		and #hEnemyList == 0
        and not bot:HasModifier( "modifier_earthshaker_enchant_totem" )
	then
        local laneCreepList = bot:GetNearbyLaneCreeps( nRadius, true )
		if #laneCreepList >= 2
			and not laneCreepList[1]:HasModifier( "modifier_fountain_glyph" )
		then
			return BOT_ACTION_DESIRE_HIGH, bot
		end

        local nTowerList = bot:GetNearbyTowers( nRadius, true )
        if J.IsValidBuilding( nTowerList[1] )
            and #laneCreepList == 0
            and #hEnemyList == 0
            and bot:IsFacingLocation( nTowerList[1]:GetLocation(), 30 )
	    then
		    return BOT_ACTION_DESIRE_HIGH, bot
        elseif J.IsValid( aTarget )
            and aTarget:GetTeam() == TEAM_NEUTRAL
            and J.IsInRange( bot, aTarget, nRadius )
        then
            return BOT_ACTION_DESIRE_HIGH, bot
        end
    end

    if J.IsRetreating( bot )
        and J.ShouldEscape( bot )
        and ( bot:HasModifier( "modifier_bloodseeker_rupture" ) or bot:IsRooted() )
    then
        local EnemyNearby = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE )
        if #EnemyNearby >= 1
            and J.CanCastOnNonMagicImmune( EnemyNearby[1] )
        then
		    return BOT_ACTION_DESIRE_HIGH
        end
	end


    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end

    --to use combo
    if abilityRef ~= nil 
        and abilityRef:IsFullyCastable()
        and bot:GetMana() > abilityR:GetManaCost() * 2 + abilityRef:GetManaCost() + 100
	then
		return 0
	end

	local nEchoRange = abilityR:GetSpecialValueInt( "echo_slam_damage_range" )
    local nExtraEchoSearchRange = nEchoRange + abilityR:GetSpecialValueInt( "echo_slam_echo_search_range" )
    local nAfterShockRange = 0
    if abilityE:IsTrained() then nAfterShockRange = abilityE:GetSpecialValueInt( "aftershock_range" ) end
    local nManaCost = abilityR:GetManaCost()
	local nBaseDamage = abilityR:GetSpecialValueInt( "echo_slam_initial_damage" )
    local nEchoDamage = abilityR:GetSpecialValueInt( "echo_slam_echo_damage" )
    local nInRangeEnemyList = J.GetAroundEnemyHeroList( nAfterShockRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nEchoRange )
    local nInRangeCreepList = bot:GetNearbyCreeps( nEchoRange, true )
	
    for _, npcEnemy in pairs(nInRangeEnemyList)
    do
        if abilityE:IsTrained()
            and not abilityQ:IsFullyCastable()
            and not abilityW1:IsFullyCastable()
            and not abilityW2:IsFullyCastable()
            and not abilityW3:IsFullyCastable()
            and J.IsValidHero( npcEnemy )
            and J.CanCastOnNonMagicImmune( npcEnemy )
            and not J.IsDisabled( npcEnemy )
            and J.IsInRange( bot, npcEnemy, nAfterShockRange )
            and npcEnemy:IsChanneling()
            and #hAllyList == 0
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end


    if J.IsInTeamFight( bot, nExtraEchoSearchRange )
    then
        if #nInRangeEnemyList >= 3
        then
            if not J.IsDisabled( nInRangeEnemyList[1] )
            then
                return BOT_ACTION_DESIRE_HIGH
            end

        elseif #nInRangeEnemyList == 2
            and ( #nInRangeCreepList >= 4 or #nInBonusEnemyList >= 3 )
        then
            if not J.IsDisabled( nInRangeEnemyList[1] )
            then
                return BOT_ACTION_DESIRE_HIGH
            end

        elseif #nInRangeEnemyList == 1
            and ( #nInRangeCreepList >= 6 or #nInBonusEnemyList >= 4 )
        then
            if not J.IsDisabled( nInRangeEnemyList[1] )
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end


	return BOT_ACTION_DESIRE_NONE


end

function X.ConsiderRFR()

	if not abilityR:IsFullyCastable()
		or abilityRef == nil
		or not abilityRef:IsFullyCastable()
	then return 0 end

	if bot:GetMana() < abilityR:GetManaCost() * 2 + abilityRef:GetManaCost()
	then
		return 0
	end

	local nRadius = abilityR:GetSpecialValueInt( "echo_slam_damage_range" )
	local nEchoRange = abilityR:GetSpecialValueInt( "echo_slam_damage_range" )
    local nExtraEchoSearchRange = nEchoRange + abilityR:GetSpecialValueInt( "echo_slam_echo_search_range" )
    local nAfterShockRange = 0
    if abilityE:IsTrained() then nAfterShockRange = abilityE:GetSpecialValueInt( "aftershock_range" ) end
    local nManaCost = abilityR:GetManaCost()
	local nBaseDamage = abilityR:GetSpecialValueInt( "echo_slam_initial_damage" )
    local nEchoDamage = abilityR:GetSpecialValueInt( "echo_slam_echo_damage" )
    local nInRangeEnemyList = J.GetAroundEnemyHeroList( nAfterShockRange )
	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nEchoRange )
    local nInRangeCreepList = bot:GetNearbyCreeps( nEchoRange, true )


    if J.IsInTeamFight( bot, nExtraEchoSearchRange )
    then
        if #nInRangeEnemyList >= 3
        then
            if not J.IsDisabled( nInRangeEnemyList[1] )
            then
                return BOT_ACTION_DESIRE_HIGH
            end

        elseif #nInRangeEnemyList == 2
            and ( #nInRangeCreepList >= 4 or #nInBonusEnemyList >= 3 )
        then
            if not J.IsDisabled( nInRangeEnemyList[1] )
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end


	return BOT_ACTION_DESIRE_NONE


end


return X
-- dota2jmz@163.com QQ:2462331592..
