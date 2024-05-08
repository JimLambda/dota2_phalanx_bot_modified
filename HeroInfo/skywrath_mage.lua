X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local ArcaneBolt = bot:GetAbilityByName("skywrath_mage_arcane_bolt")
local ConcussiveShot = bot:GetAbilityByName("skywrath_mage_concussive_shot")
local AncientSeal = bot:GetAbilityByName("skywrath_mage_ancient_seal")
local MysticFlare = bot:GetAbilityByName("skywrath_mage_mystic_flare")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, ArcaneBolt:GetName())
	table.insert(abilities, ConcussiveShot:GetName())
	table.insert(abilities, AncientSeal:GetName())
	table.insert(abilities, MysticFlare:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[1], -- Level 1
	abilities[2], -- Level 2
	abilities[3], -- Level 3
	abilities[2], -- Level 4
	abilities[2], -- Level 5
	abilities[3], -- Level 6
	abilities[2], -- Level 7
	abilities[4], -- Level 8
	abilities[3], -- Level 9
	talents[2],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[4],   -- Level 15
	abilities[1], -- Level 16
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
	talents[3],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		ItemBuild = { 
		--"item_null_talisman",
		-- "item_magic_wand",
		-- "item_tranquil_boots",
		
		-- "item_solar_crest",
		-- "item_rod_of_atos",
		-- "item_force_staff",
		-- "item_ultimate_scepter",
		-- "item_aeon_disk",
		-- "item_ultimate_scepter_2",
		-- "item_sheepstick",
		-- "item_boots_of_bearing",


		"item_boots",
		"item_rod_of_atos",
		"item_ultimate_scepter",
		"item_aether_lens",
		"item_octarine_core",
		"item_kaya_and_sange",
		"item_travel_boots",
		"item_ethereal_blade",
		"item_gungir",
		"item_ultimate_scepter_2",
		"item_wind_waker",
		"item_travel_boots_2",
		"item_moon_shard",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		ItemBuild = { 
		--"item_null_talisman",
		"item_magic_wand",
		"item_arcane_boots",
		
		"item_urn_of_shadows",
		"item_rod_of_atos",
		"item_glimmer_cape",
		"item_spirit_vessel",
		"item_ultimate_scepter",
		"item_aeon_disk",
		"item_ultimate_scepter_2",
		"item_sheepstick",
		"item_guardian_greaves",
		}
	end
	
	return ItemBuild
end

return X