local healthScanner = {
    m_iHealth = nil,
}

function healthScanner.Initialize(game_id)
    if game_id ~= GAME_CSGO then return false
    else
        constellation.windows.overlay.create("Valve001", "")
    end
end

function healthScanner.OnConstellationCalibrated()
    healthScanner.m_iHealth = constellation.memory.netvar("DT_BasePlayer", "m_iHealth")
end

function healthScanner.OnConstellationTick(localplayer)
    if localplayer == nil then return end
    if not constellation.game.bsp.parse() then return end
    local player_information = constellation.game.get_player(localplayer)
    if not player_information then return end
    local enemies = constellation.game.get_enemies()

    for _, player in pairs(enemies) do
        local health = constellation.memory.read_integer(player["address"] + healthScanner.m_iHealth)
        local dimensions = constellation.game.get_box_dimensions(player)
        local result = constellation.game.bsp.trace_ray(
            player_information["eye_position"]["x"], player_information["eye_position"]["y"],
            player_information["eye_position"]["z"],
            player["eye_position"]["x"], player["eye_position"]["y"], player["eye_position"]["z"]
        )

        if result then



            if constellation.game.is_in_fov(player, 5) then
                local currentHealth = 1500 + health
                local healthMultiplier = health * 34 --screensize (screen = 3440px. 3440 / 100 + 34.)
                if health >= 50 then
                    constellation.windows.overlay.box_filled(0, 0, healthMultiplier, 20,
                        { r = 0, g = 255, b = 0, a = 125 })
                end

                if health < 50 then
                    constellation.windows.overlay.box_filled(0, 0, healthMultiplier, 20,
                        { r = 255, g = 0, b = 0, a = 125 })
                end
            end
        end
    end
end

return healthScanner
