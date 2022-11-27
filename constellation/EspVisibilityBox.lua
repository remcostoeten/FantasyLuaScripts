local EspVisibilityBox = {
}

function EspVisibilityBox.Initialize()
    constellation.windows.overlay.create("Valve001", "")
end

function EspVisibilityBox.OnConstellationTick(localplayer, localweapon, viewangles)
    if localplayer == nil then return end
    if not constellation.game.bsp.parse() then return end
    local player_information = constellation.game.get_player(localplayer)
    if not player_information then return end

    for _, player in pairs(constellation.game.get_enemies()) do
        local dimensions = constellation.game.get_box_dimensions(player)
        local enemy = constellation.game.get_enemies()
        local result = constellation.game.bsp.trace_ray(
            player_information["eye_position"]["x"], player_information["eye_position"]["y"],
            player_information["eye_position"]["z"],
            player["eye_position"]["x"], player["eye_position"]["y"], player["eye_position"]["z"]
        )

        if constellation.game.is_in_fov(player, 8) and result then
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 2, { r = 255, g = 255, b = 255, a = 150 })
            end
        end

        if constellation.game.is_in_fov(player, 15) and not result then
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 2, { r = 255, g = 0, b = 0, a = 50 })
            end
        end
    end
end

return EspVisibilityBox
