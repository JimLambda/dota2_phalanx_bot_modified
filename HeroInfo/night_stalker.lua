X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Void = bot:GetAbilityByName("night_stalker_void")
local CripplingFear = bot:GetAbilityByName("night_stalker_crippling_fear")
local HunterInTheNight = bot:GetAbilityByName("night_stalker_hunter_in_the_night")
local Darkness = bot:GetAbilityByName("night_stalker_darkness")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Void:GetName())
	table.insert(abilities, CripplingFear:GetName())
	table.insert(abilities, HunterInTheNight:GetName())
	table.insert(abilities, Darkness:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[1], -- Level 1
	abilities[3], -- Level 2
	abilities[1], -- Level 3
	abilities[3], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
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
	talents[6],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[4],   -- Level 28
	talents[5],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		local CoreItem = PRoles.GetAOEItem()
		
		ItemBuild = { 
		-- "item_quelling_blade",
	
		-- "item_bracer",
		-- "item_magic_wand",
		-- "item_phase_boots",
		
		-- "item_echo_sabre",
		-- CoreItem,
		-- "item_blink",
		-- "item_harpoon",
		-- "item_heavens_halberd",
		-- "item_assault",
		-- "item_overwhelming_blink",


		"item_boots",
		"item_lotus_orb",
		"item_heavens_halberd",
		"item_assault",
		"item_shivas_guard",
		"item_heart",
		"item_travel_boots",
		"item_ultimate_scepter_2",
		"item_travel_boots_2",
		"item_moon_shard",
		}
	end
	
	return ItemBuild
end

return X