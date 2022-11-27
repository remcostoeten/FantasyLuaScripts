local HealthBarOnFov = {
    m_iHealth = nil
}

function HealthBarOnFov.Initialize()
    constellation.windows.overlay.create("Valve001", "")

end

function HealthBarOnFov.OnConstellationCalibrated()
    HealthBarOnFov.m_iHealth = constellation.memory.netvar("DT_BasePlayer", "m_iHealth")
end

function HealthBarOnFov.OnConstellationTick(localplayer, localweapon, viewangles)
    if localplayer == nil then return end
    if not constellation.game.bsp.parse() then return end
    local player_information = constellation.game.get_player(localplayer)
    if not player_information then return end

    for _, player in pairs(constellation.game.get_enemies()) do
        local health = constellation.memory.read_integer(player["address"] + HealthBarOnFov.m_iHealth)
        local ScreenSize = health * 34
        local enemy = constellation.game.get_enemies()
        local result = constellation.game.bsp.trace_ray(
            player_information["eye_position"]["x"], player_information["eye_position"]["y"],
            player_information["eye_position"]["z"],
            player["eye_position"]["x"], player["eye_position"]["y"], player["eye_position"]["z"]
        )

        if constellation.game.is_in_fov(player, 8) and result then
            if health > 75 then
                constellation.windows.overlay.box_filled(0, 0, ScreenSize, 20,
                    { r = 0, g = 255, b = 0, a = 150 })
            end
            if health >= 40 and health <= 75 then
                constellation.windows.overlay.box_filled(0, 0, ScreenSize, 20,
                    { r = 255, g = 100, b = 100, a = 150 })
            end
            if health < 40 then
                constellation.windows.overlay.box_filled(0, 0, ScreenSize, 20,
                    { r = 255, g = 0, b = 0, a = 150 })
            end
        end

        if constellation.game.is_in_fov(player, 15) and not result then
            if health > 75 then
                constellation.windows.overlay.box_filled(0, 0, ScreenSize, 20,
                    { r = 0, g = 255, b = 0, a = 255 })
            end
            if health >= 40 and health <= 75 then
                constellation.windows.overlay.box_filled(0, 0, ScreenSize, 20,
                    { r = 255, g = 100, b = 100, a = 255 })
            end
            if health < 40 then
                constellation.windows.overlay.box_filled(0, 0, ScreenSize, 20,
                    { r = 255, g = 0, b = 0, a = 255 })
            end
        end
    end
end

return HealthBarOnFov
