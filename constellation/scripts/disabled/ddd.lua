local hoxInFov = {

}

function hoxInFov.Initialize()
    -- Create an overlay ontop of the "Valve001" process, which in this case will be CS:GO.
    constellation.windows.overlay.create("Valve001", "")

end

function hoxInFov.OnOverlayRender()
    -- for _, enemy in pairs(constellation.game.get_enemies()) do


    --     local dimensions = constellation.game.get_box_dimensions(enemy)
    --     if enemy["is_alive"] == true then

    --         if dimensions ~= nil then

    --             constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
    --                 dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 255, a = 0 })

    --         end

    --     else
    --         constellation.log("dood")
    --     end

    -- endalocal hoxInFov = {

}

function hoxInFov.Initialize()
    -- Create an overlay ontop of the "Valve001" process, which in this case will be CS:GO.
    constellation.windows.overlay.create("Valve001", "")

end

function hoxInFov.OnOverlayRender()
    -- for _, enemy in pairs(constellation.game.get_enemies()) do


    --     local dimensions = constellation.game.get_box_dimensions(enemy)
    --     if enemy["is_alive"] == true then

    --         if dimensions ~= nil then

    --             constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
    --                 dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 255, a = 0 })

    --         end

    --     else
    --         constellation.log("dood")
    --     end

    -- end
    for _, player in pairs(constellation.game.get_enemies()) do
        local closest_player, angle_x, angle_y, true_fov = constellation.game.get_closest_player_fov(false, 15, 15)
        local dimensions = constellation.game.get_box_dimensions(player)

        -- if closest_player then
        --     if dimensions ~= nil then
        --         constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
        --             dimensions["bottom"] + 1, 1, { r = 160, g = 251, b = 160, a = 100 })
        --     end
        --     constellation.log(closest_player["name"] ..
        --         " closest to you (" .. angle_x .. ", " .. angle_y .. ": " .. true_fov .. ")")
        --     constellation.humanizer(angle_x, angle_y)
        -- end

        local closest_player, angle_x, angle_y, true_fov = constellation.game.get_closest_player_fov(false, 7, 7.5)

        if not closest_player then
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 0, g = 255, b = 0, a = 255 })
            end
        end

        local dimensions = constellation.game.get_box_dimensions(player)

        if constellation.game.is_in_fov(player, 5) then
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 100, g = 255, b = 100, a = 200 })
            end
        end

        -- if constellation.game.is_in_fov(player, 25) then
        --     if dimensions ~= nil then
        --         constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
        --             dimensions["bottom"] + 1, 1, { r = 0, g = 255, b = 0, a = 255 })
        --     end
        -- end

        -- if constellation.game.is_in_fov(player, 100) then
        --     if dimensions ~= nil then
        --         constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
        --             dimensions["bottom"] + 1, 1, { r = 0, g = 255, b = 0, a = 255 })
        --     end
        -- end

        -- if constellation.game.is_in_fov(player, 150) then
        --     if dimensions ~= nil then
        --         constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
        --             dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 225, a = 50 })
        --     end
        -- end
    end

end

return hoxInFov

    for _, player in pairs(constellation.game.get_enemies()) do
        local closest_player, angle_x, angle_y, true_fov = constellation.game.get_closest_player_fov(5, 5, 5)
        local dimensions = constellation.game.get_box_dimensions(player)

        if closest_player then
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 172, g = 255, b = 147, a = 225 })
            end

        end

        local closest_player, angle_x, angle_y, true_fov = constellation.game.get_closest_player_fov(false, 7, 7.5)

        if not closest_player then
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 0, g = 0, b = 0, a = 0 })
            end
        end



        -- Start loop which logs when your mouse is near the FOV (number in the for).

        local dimensions = constellation.game.get_box_dimensions(player)

        if constellation.game.is_in_fov(player, 5) then
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 0, g = 255, b = 0, a = 255 })
            end
        end

        if constellation.game.is_in_fov(player, 25) then
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 0, g = 255, b = 0, a = 255 })
            end
        end

        if constellation.game.is_in_fov(player, 100) then
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 0, g = 255, b = 0, a = 255 })
            end
        end

        if constellation.game.is_in_fov(player, 150) then
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 225, a = 50 })
            end
        end
    end

end

return hoxInFov
