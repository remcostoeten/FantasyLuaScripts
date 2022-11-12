local hoxInFov = {

}

function hoxInFov.OnConstellationTick(localplayer)
    -- are we ingame?
    if localplayer == nil then return end

    --[[
        .bsp parse the map we're currently on.
        this is okay to put here in OnConstellationTick, this only calls one memory reading operation.
        if something is parsed already and is the same map, it won't reparse the same map data.
    --]]
    if not constellation.game.bsp.parse() then return end

    -- get localplayer information
    local player_information = constellation.game.get_player(localplayer)
    if not player_information then return end

    -- loop through all enemies.

    -- trace_ray our eye position to their eyes.

    -- if we see each other, let it be known.
    local enemies = constellation.game.get_enemies()


    for _, player in pairs(enemies) do

        local closest_player, angle_x, angle_y, true_fov = constellation.game.get_closest_player_fov(false, 50, 50)
        local dimensions = constellation.game.get_box_dimensions(player)
        local result = constellation.game.bsp.trace_ray(
            player_information["eye_position"]["x"], player_information["eye_position"]["y"],
            player_information["eye_position"]["z"],
            player["eye_position"]["x"], player["eye_position"]["y"], player["eye_position"]["z"]
        )


        if not closest_player then
            -- if dimensions ~= nil then
            --     constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
            --         dimensions["bottom"] + 1, 1, { r = 150, g = 150, b = 150, a = 150 })
            -- end
            -- return
        end



        if result then

            local dimensions = constellation.game.get_box_dimensions(player)

            if constellation.game.is_in_fov(player, 21) then
                print(string.format("I see you %s!", player["name"]))

                if dimensions ~= nil then
                    constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                        dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 255, a = 174 })
                end
            end
        else
            print(string.format("I dont see you %s!", player["name"]))
            if constellation.game.is_in_fov(player, 21) then
                print(string.format("I see you %s!", player["name"]))

                if dimensions ~= nil then
                    constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                        dimensions["bottom"] + 1, 1, { r = 255, g = 0, b = 0, a = 174 })
                end
            end
        end
    end
end

return hoxInFov
