local Defend = require( GetScriptDirectory()..'/FunLib/aba_defend')

function GetDesire()
    -- -- Try to consume moon shard while defending.
    -- TrySwapInvItemForMoonshard()

    return Defend.GetDefendDesire(GetBot(), LANE_TOP)
end

-- function Think()
--     Defend.DefendThink(GetBot(), LANE_TOP)
-- end