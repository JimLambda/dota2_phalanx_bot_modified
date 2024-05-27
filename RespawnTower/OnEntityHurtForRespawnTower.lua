local RADIANT = 2
local DIRE = 3
local isEntityHurtForRespawnTowerRegistered = false

-- Instantiate ourself
if EntityHurtForRespawnTower == nil then
	EntityHurtForRespawnTower = {}
end

EntityHurtForRespawnTower.shouldBeInvulnerableFlag = false
EntityHurtForRespawnTower.effectedBuildings = {}


-- A stackoverflow found debug function.
local function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end



-- Event Listener
function EntityHurtForRespawnTower:OnEntityHurt(event)
	-- Get other event data
	local victim, attacker, damage, damageType = EntityHurtForRespawnTower:GetEntityHurtEventData(event)
	-- Log Tower/Building kills to track game state
	if victim == nil then
		return
	end
	if victim:IsTower() or victim:IsBuilding() then
		table.insert(EntityHurtForRespawnTower.effectedBuildings, victim)
		-- print("EntityHurtForRespawnTower.effectedBuildings:", dump(EntityHurtForRespawnTower.effectedBuildings))

		if -- victim:GetName() == "dota_goodguys_tower4_top" or victim:GetName() == "dota_goodguys_tower4_bot" or
			-- 	victim:GetName() == "dota_badguys_tower4_top" or
			-- 	victim:GetName() == "dota_badguys_tower4_bot"
			true then
			if EntityHurtForRespawnTower.shouldBeInvulnerableFlag == true then
				-- Respawn earlier when killed.
				EntityHurtForRespawnTower:SetBuildingInvulnerable(victim)
			elseif EntityHurtForRespawnTower.shouldBeInvulnerableFlag == false then
				EntityHurtForRespawnTower:SetBuildingVulnerable(victim)
			end
		end
	end
end

-- returns useful data about the kill event
function EntityHurtForRespawnTower:GetEntityHurtEventData(event)
	local attacker = nil
	local victim = nil
	if event.entindex_attacker ~= nil and event.entindex_killed ~= nil then
		attacker = EntIndexToHScript(event.entindex_attacker)
		victim = EntIndexToHScript(event.entindex_killed)
	end
	-- Lifted from Anarchy. Props!
	-- Damage Type
	local damageType = nil
	if event.entindex_inflictor ~= nil then
		local inflictor_table = EntIndexToHScript(event.entindex_inflictor):GetAbilityKeyValues()
		if inflictor_table["AbilityUnitDamageType"] == nil then -- assume item damage is magical
			damageType = "DAMAGE_TYPE_MAGICAL"
		else
			damageType = tostring(inflictor_table["AbilityUnitDamageType"])
		end
	else
		damageType = tostring("DAMAGE_TYPE_PHYSICAL")
	end
	-- get damage value
	local damage = event.damage
	return victim, attacker, damage, damageType
end

-- Registers Event Listener
function EntityHurtForRespawnTower:RegisterEvents()
	if not isEntityHurtForRespawnTowerRegistered then
		ListenToGameEvent("entity_hurt", Dynamic_Wrap(EntityHurtForRespawnTower, "OnEntityHurt"), EntityHurtForRespawnTower)
		isEntityHurtForRespawnTowerRegistered = true
		print("EntityHurtForRespawnTower Event Listener Registered.")
	end
end

-- Adjust the respawn time of the killed building.
function EntityHurtForRespawnTower:SetBuildingInvulnerable(building)
	local respawnTime = 0 -- Set custom respawn time here
	-- Set the respawn time of the killed bot.
	building:SetInvulnCount(1)
	print(building:GetName(), " has ", building:GetInvulnCount(), " invulnerability counts.")
	-- building:RespawnUnit()
	-- building:SetTimeUntilRespawn(respawnTime)
end


function EntityHurtForRespawnTower:SetBuildingVulnerable(building)
	building:SetInvulnCount(0)
	-- print(building:GetName(), " has ", building:GetInvulnCount(), " invulnerability counts.")
end


