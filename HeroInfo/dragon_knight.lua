X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local BreatheFire = bot:GetAbilityByName("dragon_knight_breathe_fire")
local DragonTail = bot:GetAbilityByName("dragon_knight_dragon_tail")
local DragonBlood = bot:GetAbilityByName("dragon_knight_dragon_blood")
local ElderDragonForm = bot:GetAbilityByName("dragon_knight_elder_dragon_form")
local Fireball = bot:GetAbilityByName("dragon_knight_fireball")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, BreatheFire:GetName())
	table.insert(abilities, DragonTail:GetName())
	table.insert(abilities, DragonBlood:GetName())
	table.insert(abilities, ElderDragonForm:GetName())
	
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
	abilities[3], -- Level 3
	abilities[2], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[1], -- Level 8
	abilities[3], -- Level 9
	talents[1],   -- Level 10
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
	talents[2],   -- Level 27
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
		-- "item_power_treads",
		-- "item_soul_ring",
		
		-- "item_boots",
		-- CoreItem,
		-- "item_blink",
		-- "item_travel_boots",
		-- "item_black_king_bar",
		-- "item_ultimate_scepter",
		-- "item_manta",
		-- "item_ultimate_scepter_2",
		-- "item_assault",
		-- "item_overwhelming_blink",
		-- "item_travel_boots_2",


		-- "item_quelling_blade",
		-- "item_blades_of_attack",
		-- "item_blight_stone",
		-- "item_lesser_crit",
		"item_boots",
		"item_dragon_lance",
		"item_ultimate_scepter",
		"item_greater_crit",
		"item_hurricane_pike",
		"item_bloodthorn",
		"item_octarine_core",
		"item_travel_boots",
		"item_ultimate_scepter_2",
		"item_skadi",
		"item_travel_boots_2",
		"item_moon_shard",
		}
	end
	
	return ItemBuild
end

return X