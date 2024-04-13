X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Shrapnel = bot:GetAbilityByName("sniper_shrapnel")
local Headshot = bot:GetAbilityByName("sniper_headshot")
local TakeAim = bot:GetAbilityByName("sniper_take_aim")
local Assassinate = bot:GetAbilityByName("sniper_assassinate")
local ConcussiveGrenade = bot:GetAbilityByName("sniper_concussive_grenade")

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Shrapnel:GetName())
	table.insert(abilities, Headshot:GetName())
	table.insert(abilities, TakeAim:GetName())
	table.insert(abilities, Assassinate:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[2], -- Level 1
	abilities[1], -- Level 2
	abilities[1], -- Level 3
	abilities[3], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[3], -- Level 8
	abilities[3], -- Level 9
	talents[2],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[2], -- Level 14
	talents[3],   -- Level 15
	abilities[2], -- Level 16
	"NoLevel",    -- Level 17
	abilities[4], -- Level 18
	"NoLevel",    -- Level 19
	talents[5],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[4],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		-- "item_wraith_band",
		-- "item_magic_wand",
		-- "item_power_treads",
	
		-- "item_hand_of_midas",
		-- "item_boots",
		-- "item_dragon_lance",
		-- "item_hurricane_pike",
		-- "item_travel_boots",
		-- "item_black_king_bar",
		-- "item_butterfly",
		-- "item_skadi",
		-- "item_satanic",
		-- "item_travel_boots_2",
		-- "item_ultimate_scepter_2",
		
		"item_mjollnir",
		"item_hurricane_pike",
		"item_desolator",
		"item_skadi",
		"item_satanic",
		"item_travel_boots_2",
		"item_ultimate_scepter_2",
		"item_moon_shard",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		-- "item_wraith_band",
		-- "item_magic_wand",
		-- "item_power_treads",
	
		"item_boots",
		"item_dragon_lance",
		"item_travel_boots",
		"item_lesser_crit",
		"item_hurricane_pike",
		"item_black_king_bar",
		"item_greater_crit",
		"item_satanic",
		"item_travel_boots_2",
		"item_ultimate_scepter_2",
		}
	end
	
	return ItemBuild
end

return X