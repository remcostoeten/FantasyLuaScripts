--[[
    @Patch Notes:
        - 4 months ago: "Added Counter Strike: Source support."
--]]

--[[
    @title
        BSP Visibility Check.

    @author
        typedef

    @notes
        Constellation TF2 does not have a visibility check. This will use the BSP features to improve it.
        This only really works for walls. Displacements and static props are ignored. This works for CS:GO and TF2 only.
        
        Read this:
        https://fantasy.cat/forums/index.php?threads/valves-latest-marathon.6388/#post-47204
]]
local bsp = {}

function bsp.Initialize(game_id)
    return game_id ~= GAME_DOTA2
end

function bsp.OnVisibilityCheck(localplayer, target, original_result)

    -- constellation is saying the enemy isn't visible, trust the base solution before 2nd judgements.
    if not original_result then return false end

    --[[
        .bsp parse the map we're currently on.

        this is okay to put here in OnVisibilityCheck, this only calls one memory reading operation.
        if something is parsed already and is the same map, it won't reparse the same map data.
    --]]
    constellation.game.bsp.parse()

    -- get both players
    local player_information = constellation.game.get_player(localplayer)
    local target_information = constellation.game.get_player(target)
    if not player_information or not target_information then return false end

    -- trace ray eye positions
    local result = constellation.game.bsp.trace_ray(
        player_information["eye_position"]["x"], player_information["eye_position"]["y"],
        player_information["eye_position"]["z"],
        target_information["eye_position"]["x"], target_information["eye_position"]["y"],
        target_information["eye_position"]["z"]
    )

    return result
end

return bsp
