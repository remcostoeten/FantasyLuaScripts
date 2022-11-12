--[[
    @title
        Visibillity alert ESP
    @author
        hoxyz
    @notes
        ESP with small FOV which shows a certain color when the enemy is behind an object or in sight.
--]]

local fov_visibility_esp = {
    -- image data
    images =
    {
        healthy_url = "https://e7.pngegg.com/pngimages/1015/497/png-clipart-counter-strike-1-6-counter-strike-global-offensive-game-block-wallhack-others-silhouette-internet-thumbnail.png",
        hurt_url = "https://i.imgur.com/9ZoZ96a.png",
    },
}

function fov_visibility_esp.OnConstellationTick(localplayer)
    local player_information = constellation.game.get_player(localplayer)
    local enemies = constellation.game.get_enemies()

    if localplayer == nil then return end
    if not constellation.game.bsp.parse() then return end
    if not player_information then return end

    for _, player in pairs(enemies) do

        local dimensions = constellation.game.get_box_dimensions(player)
        local closest_player, angle_x, angle_y, true_fov = constellation.game.get_closest_player_fov(false, 15, 15)
        local dimensions = constellation.game.get_box_dimensions(player)
        local result = constellation.game.bsp.trace_ray(
            player_information["eye_position"]["x"], player_information["eye_position"]["y"],
            player_information["eye_position"]["z"],
            player["eye_position"]["x"], player["eye_position"]["y"], player["eye_position"]["z"]
        )

        if result then
            if constellation.game.is_in_fov(player, 15) then
                if dimensions ~= nil then
                    constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                        dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 255, a = 174 })
                end
            end
        else
            if constellation.game.is_in_fov(player, 15) then
                if dimensions ~= nil then
                    constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                        dimensions["bottom"] + 1, 1, { r = 255, g = 0, b = 0, a = 174 })
                end
            end
        end
    end
end

return fov_visibility_esp
