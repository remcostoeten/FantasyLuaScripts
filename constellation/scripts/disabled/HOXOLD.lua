local hoxInFov = {

}

function hoxInFov.OnConstellationTick(localplayer)
    if localplayer == nil then return end

    if not constellation.game.bsp.parse() then return end

    local player_information = constellation.game.get_player(localplayer)
    if not player_information then return end



    for _, player in pairs(constellation.game.get_enemies()) do
        local closest_player, angle_x, angle_y, true_fov = constellation.game.get_closest_player_fov(false, 50, 50)
        local dimensions = constellation.game.get_box_dimensions(player)
        local result = constellation.game.bsp.trace_ray(
            player_information["eye_position"]["x"], player_information["eye_position"]["y"],
            player_information["eye_position"]["z"],
            player["eye_position"]["x"], player["eye_position"]["y"], player["eye_position"]["z"]
        )

        if result then
            local dimensions = constellation.game.get_box_dimensions(player)

            if constellation.game.is_in_fov(player, 15) then

                if hox.IsVisible(localplayer, player) == true then
                    if dimensions ~= nil then
                        constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"]
                            ,
                            dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 255, a = 174 })
                    end
                end
            end
        end
    end

    if not result then
        if constellation.game.is_in_fov(player, 15) then
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"]
                    ,
                    dimensions["bottom"] + 1, 1, { r = 255, g = 0, b = 0, a = 174 })
            end
        end
    end
end

return hoxInFov
