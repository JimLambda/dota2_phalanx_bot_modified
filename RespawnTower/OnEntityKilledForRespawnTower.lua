local RADIANT = 2
local DIRE = 3
local isEntityKilledForRespawnTowerRegistered = false

-- Instantiate ourself
if EntityKilledForRespawnTower == nil then
	EntityKilledForRespawnTower = {}
end

-- Event Listener
function EntityKilledForRespawnTower:OnEntityKilled(event)
	-- Get Event Data
	local isHero, victim, killer = EntityKilledForRespawnTower:GetEntityKilledEventData(event)
	-- Log Tower/Building kills to track game state
	if victim == nil then
		return
	end
	if victim:IsTower() or victim:IsBuilding() then
		if
			-- victim:GetName() == "dota_goodguys_tower4_top" or victim:GetName() == "dota_goodguys_tower4_bot" or
			-- 	victim:GetName() == "dota_badguys_tower4_top" or
			-- 	victim:GetName() == "dota_badguys_tower4_bot"
			true
		 then
			-- Respawn earlier when killed.
			EntityKilledForRespawnTower:AdjustDeathRespawnTimeForBuilding(victim)
		end
	end
end

-- returns useful data about the kill event
function EntityKilledForRespawnTower:GetEntityKilledEventData(event)
	-- Victim
	local victim = EntIndexToHScript(event.entindex_killed)
	-- Killer
	local killer = nil
	if event.entindex_attacker ~= nil then
		killer = EntIndexToHScript(event.entindex_attacker)
	end
	-- IsHero
	local isHero = false
	if victim:IsHero() and victim:IsRealHero() and not victim:IsIllusion() and not victim:IsClone() then
		isHero = true
	end

	return isHero, victim, killer
end

-- Registers Event Listener
function EntityKilledForRespawnTower:RegisterEvents()
	if not isEntityKilledForRespawnTowerRegistered then
		ListenToGameEvent(
			"entity_killed",
			Dynamic_Wrap(EntityKilledForRespawnTower, "OnEntityKilled"),
			EntityKilledForRespawnTower
		)
		isEntityKilledForRespawnTowerRegistered = true
		print("EntityKilledForRespawnTower Event Listener Registered.")
	end
end

-- Adjust the respawn time of the killed building.
function EntityKilledForRespawnTower:AdjustDeathRespawnTimeForBuilding(building)
	local respawnTime = 0 -- Set custom respawn time here
	-- Set the respawn time of the killed bot.
	building:SetInvulnCount(50)
	-- building:RespawnUnit()
	-- building:SetTimeUntilRespawn(respawnTime)
end
