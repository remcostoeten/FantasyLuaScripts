local hoxHealth = {

}

-- function hoxHealth.OnConstellationTick(localplayer)

--     hoxHealth.m_iHealth = constellation.memory.netvar("DT_BasePlayer", "m_iHealth")

--     local health = constellation.memory.read_integer(localplayer + hoxHealth.m_iHealth)






-- end

function hoxHealth.OnOverlayRender(width, height, center_x, center_y)
    hoxHealth.m_iHealth = constellation.memory.netvar("DT_BasePlayer", "m_iHealth")

    local health = constellation.memory.read_integer(localplayer + hoxHealth.m_iHealth)


    -- loop through all enemies
    for _, player in pairs(constellation.game.get_enemies()) do

        -- get box dimensions
        local dimensions = constellation.game.get_box_dimensions(player)
        s
        if health < 50 then
            -- valid?
            if dimensions ~= nil then

                -- draw box
                constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                    dimensions["bottom"] + 1, 2, { r = 255, g = 255, b = 255, a = 255 })
            end
        end


    end

end

return hoxHealth
