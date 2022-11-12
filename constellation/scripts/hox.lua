--[[
    @title
        scan test

    @author
        typedef

    @description
        showing how the scan function works and how you can use it for many different purposes.    
        GIF: https://i.imgur.com/vDhHgCI.gif
--]]

local hox = {}

function hox.OnConstellationTick(localplayer, localweapon)

    -- we're not ingame.
    if not localplayer or not localweapon then return end

    local players, closest = constellation.game.scan({ 4, 7, 8 }, 40.0, true)
    local player_information = constellation.game.get_player(localplayer)

    if not players or not closest then return end

    print(string.format("\nThe player closest to our crosshair is \"%s\" (%f).", closest["entity"]["name"],
        closest["distance"]))
    local player_information = constellation.game.get_player(localplayer)
    local enemies = constellation.game.get_enemies()

    for _, player in pairs(players) do
        local closest_player, angle_x, angle_y, true_fov = constellation.game.get_closest_player_fov(false, 40, 40)

        local result = constellation.game.bsp.trace_ray(
            player_information["eye_position"]["x"], player_information["eye_position"]["y"],
            player_information["eye_position"]["z"],
            player["eye_position"]["x"], player["eye_position"]["y"], player["eye_position"]["z"]
        )



        if player["address"] == closest["entity"]["address"] then
            if result then

                local dimensions = constellation.game.get_box_dimensions(player)
                if dimensions ~= nil then
                    constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                        dimensions["bottom"] + 1, 1, { r = 0, g = 255, b = 0, a = 150 })
                end
            end

            if not result then

                local dimensions = constellation.game.get_box_dimensions(player)
                if dimensions ~= nil then
                    constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                        dimensions["bottom"] + 1, 1, { r = 255, g = 0, b = 0, a = 255 })
                end
            end
        end
        if closest_player then
            local dimensions = constellation.game.get_box_dimensions(player)

            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 255, a = 150 })
            end

        end
        if not closest_player then
            local dimensions = constellation.game.get_box_dimensions(player)

            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 255, a = 148 })
            end
            print(1)

        end

        -- print other players in the FOV anyway.
        print(string.format("     -> Also in FOV: \"%s\" (%f).", player["name"], player["distance"]))


        ::continue::
    end

    -- if we're holding down right mouse button, activate humanizer with missing modules (see documentation).
    if constellation.windows.key(2) then
        constellation.humanizer(closest["angle_x"], closest["angle_y"])
    end
end

return hox
