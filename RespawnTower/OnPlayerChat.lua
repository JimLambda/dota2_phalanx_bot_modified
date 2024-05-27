require("bots.RespawnTower.OnEntityHurtForRespawnTower")

local isOnPlayerChatRegistered = false

-- Instantiate ourself
if OnPlayerChat == nil then
    OnPlayerChat = {}
end

-- Event Listener
function OnPlayerChat:OnPlayerChat(event)
    -- Get event data
    local playerID, rawText = OnPlayerChat:GetChatEventData(event)

    -- Set configs according to chat content.
    if rawText == "--invulnerable buildings" or rawText == "-ib" then
        EntityHurtForRespawnTower.shouldBeInvulnerableFlag = true
    end
    if rawText == "--vulnerable buildings" or rawText == "-vb" then
        EntityHurtForRespawnTower.shouldBeInvulnerableFlag = false
        EntityHurtForRespawnTower:SetBuildingVulnerable()
    end
end

function OnPlayerChat:GetChatEventData(event)
    local playerID = event.playerid
    local text = event.text
    return playerID, text
end

-- returns useful data about the kill event
function OnPlayerChat:GetEntityKilledEventData(event)
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
function OnPlayerChat:RegisterEvents()
    if not isOnPlayerChatRegistered then
        ListenToGameEvent("player_chat", Dynamic_Wrap(OnPlayerChat, "OnPlayerChat"), OnPlayerChat)
        isOnPlayerChatRegistered = true
        print("OnPlayerChat Event Listener Registered.")
    end
end

-- Adjust the respawn time of the killed building.
function OnPlayerChat:AdjustDeathRespawnTimeForBuilding(building)
    local respawnTime = 0 -- Set custom respawn time here
    -- Set the respawn time of the killed bot.
    building:SetInvulnCount(50)
    -- building:RespawnUnit()
    -- building:SetTimeUntilRespawn(respawnTime)
end
