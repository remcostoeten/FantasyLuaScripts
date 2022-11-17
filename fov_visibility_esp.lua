--[[
    @title
        Fov visiblity
    @author
        Hoxyz
    @description
        Checks if enemy is in FOV, if its in fov and in view draw esp. If its behind an object draw red ESP. Also  show healthn.
--]]
local fov_visibility_esp = {
}

function fov_visibility_esp.OnConstellationCalibrated()
    fov_visibility_esp.m_iHealth = constellation.memory.netvar("DT_BasePlayer", "m_iHealth")
end

function fov_visibility_esp.OnConstellationTick(localplayer)
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
        print("1")
        local closest_player, angle_x, angle_y, true_fov = constellation.game.get_closest_player_fov(false, 15, 15)
        local dimensions = constellation.game.get_box_dimensions(player)
        local result = constellation.game.bsp.trace_ray(
            player_information["eye_position"]["x"], player_information["eye_position"]["y"],
            player_information["eye_position"]["z"],
            player["eye_position"]["x"], player["eye_position"]["y"], player["eye_position"]["z"]
        )

        local health = constellation.memory.read_integer(player["address"] + fov_visibility_esp.m_iHealth)

        if not closest_player then
            -- if dimensions ~= nil then
            --     constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
            --         dimensions["bottom"] + 1, 1, { r = 150, g = 150, b = 150, a = 150 })
            -- end
            print("2")
            -- return
        end

        if health < 50 then
            if result then
                local dimensions = constellation.game.get_box_dimensions(player)
                if constellation.game.is_in_fov(player, 15) then
                    print(string.format("I see you %s!", player["name"]))
                    if dimensions ~= nil then
                        constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                            dimensions["bottom"] + 1, 1, { r = 159, g = 0, b = 0, a = 204 })
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

        if result then
            local dimensions = constellation.game.get_box_dimensions(player)
            if constellation.game.is_in_fov(player, 15) then
                print(string.format("I see you %s!", player["name"]))
                if dimensions ~= nil then
                    if health > 50 then

                        constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                            dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 255, a = 255 })
                        constellation.windows.overlay.box_filled(1720, 720, 25, 25, { r = 0, g = 255, b = 0, a = 100 })

                    end
                    if health < 50 then

                        constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                            dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 255, a = 255 })
                        constellation.windows.overlay.box_filled(1720, 720, 25, 25, { r = 255, g = 0, b = 0, a = 100 })

                    end
                end
            else
                if constellation.game.is_in_fov(player, 15) then
                    if dimensions ~= nil then
                        constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                            dimensions["bottom"] + 1, 1, { r = 0, g = 0, b = 255, a = 174 })
                    end
                end
            end
        end
    end
end

return fov_visibility_esp
