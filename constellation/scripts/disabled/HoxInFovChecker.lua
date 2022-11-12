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

    -- end
    for _, player in pairs(constellation.game.get_enemies()) do
        local closest_player, angle_x, angle_y, true_fov = constellation.game.get_closest_player_fov(false, 15, 15)
        local dimensions = constellation.game.get_box_dimensions(player)

        local closest_player, angle_x, angle_y, true_fov = constellation.game.get_closest_player_fov(false, 7, 7.5)

        if not closest_player then
            constellation.log('if NOT CLOSEST')

            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 255, g = 0, b = 0, a = 100 })
            end
        else
            constellation.log('if  CLOSEST')
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 255, a = 255 })
            end
        end

        local dimensions = constellation.game.get_box_dimensions(player)

        if constellation.game.is_in_fov(player, 15) then
            constellation.log('if in fov')

            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 255, a = 125 })
            end
        else
            constellation.log('else in fov')
            if dimensions ~= nil then
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 1, { r = 125, g = 125, b = 125, a = 125 })
            end
        end


    end

end

return hoxInFov
