--[[
    @title
        Visibillity alert ESP
    @author
      hoxyz
    @notes
        ESP with small FOV which shows a certain color when the enemy is behind an object or in sight.
--]]

local fov_visibility_esp = {
    m_iHealth = nil,
}


function fov_visibility_esp.Iitialize()
    constellation.windows.overlay.create("Valve001", "")
end

function fov_visibility_esp.OnConstellationCalibrated()
    fov_visibility_esp.m_iHealth = constellation.memory.netvar("DT_BasePlayer", "m_iHealth")
end

function fov_visibility_esp.OnConstellationTick(localplayer)
    local c = constellation
    local cg = constellation.game
    --    Syntax shorthands
    local dim = dimensions ~= nil
    local fieldOfView = 25
    -- Five steps where the ESP gets progressivly less visible based on how far awway you are from the enemy.
    local minmimumDistance = 250
    local secondDistance = 500
    local thirdDistance = 750
    local ThreeAndHalfDistance = 1000
    local fourthDistance = 1250
    local maximunDistance = 1500

    -- Colors for the ESP
    local colorNotVisible = 75
    local notVisibleInsideRGB = "r = 255, g = 0, b = 0, a = 100"
    local colorVisible = 150
    local visibleRGB = "r = 255, g = 255, b = 255,- a = colorVisible"
    local noColor = "r = 0, g = 0, b- = 0, a = 0"
    -- Three steps in the health bar.
    local healtStepOne = 75
    local healtStepTwo = 50
    local healtStepthree = 30

    local player_information = cg.get_player(localplayer)
    local enemies = cg.get_enemies()
    for _, player in pairs(enemies) do
        local dimensions = cg.get_box_dimensions(player)
        local result = cg.bsp.trace_ray(
            player_information["eye_position"]["x"], player_information["eye_position"]["y"],
            player_information["eye_position"]["z"],
            player["eye_position"]["x"], player["eye_position"]["y"], player["eye_position"]["z"]
        )
        local health = c.memory.read_integer(player["address"] + fov_visibility_esp.m_iHealth)
        local ScreenSize = health * 38.4 --monitor has 3840 pixels. Ideally want to fdo 100% or 100viwwidth
        local healthBarHeight = 20
        local distance = math.sqrt(
            math.pow((player.origin.x - player_information.origin.x), 2) +
            math.pow((player.origin.y - player_information.origin.y), 2))

        if cg.is_in_fov(player, fieldOfView) then
            if result then
                if distance <= minmimumDistance then
                    c.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                        dimensions["bottom"] + 1, 2, { r = 255, g = 255, b = 255, a = 100 })
                end
                if distance > minmimumDistance and distance < secondDistance then
                    c.windows.overlay.box_filled_outlined(dimensions["left"], dimensions["top"],
                        dimensions["right"],
                        dimensions["bottom"] + 1, 2, { r = 255, g = 0, b = 0, a = 0 },
                        { r = 255, g = 255, b = 255, a = 86 })
                end
                if distance > secondDistance and distance < ThreeAndHalfDistance then
                    c.windows.overlay.box_filled_outlined(dimensions["left"], dimensions["top"],
                        dimensions["right"],
                        dimensions["bottom"] + 1, 2, { r = 255, g = 0, b = 0, a = 0 },
                        { r = 255, g = 255, b = 255, a = 76 })
                end
                if distance > thirdDistance and distance < fourthDistance then
                    c.windows.overlay.box_filled_outlined(dimensions["left"], dimensions["top"],
                        dimensions["right"],
                        dimensions["bottom"] + 1, 2, { r = 255, g = 0, b = 0, a = 0 },
                        { r = 255, g = 255, b = 255, a = 55 })
                end
                if distance > fourthDistance and distance < maximunDistance then
                    c.windows.overlay.box_filled_outlined(dimensions["left"], dimensions["top"],
                        dimensions["right"],
                        dimensions["bottom"] + 1, 2, { r = 255, g = 0, b = 0, a = 0 },
                        { r = 255, g = 255, b = 255, a = 33 })
                end
                if distance < maximunDistance then
                    if health > healtStepOne then
                        c.windows.overlay.box_filled(0, 0, ScreenSize, healthBarHeight,
                            { r = 0, g = 255, b = 0, a = colorVisible })
                    end
                    if health >= 40 and health <= healtStepOne then
                        c.windows.overlay.box_filled(0, 0, ScreenSize, healthBarHeight,
                            { r = 255, g = 100, b = 0, a = colorVisible - healtStepTwo })
                    end
                    if health < 40 then
                        c.windows.overlay.box_filled(0, 0, ScreenSize, healthBarHeight,
                            { r = 255, g = 0, b = 0, a = colorVisible - healtStepthree })
                    end
                end
            else
                if distance <= minmimumDistance then
                    c.windows.overlay.box_filled_outlined(dimensions["left"], dimensions["top"],
                        dimensions["right"],
                        dimensions["bottom"] + 1, 2, { r = 255, g = 0, b = 0, a = 100 },
                        { r = 255, g = 255, b = 255, a = 0 })
                end
                if distance > minmimumDistance and distance < secondDistance then
                    c.windows.overlay.box_filled_outlined(dimensions["left"], dimensions["top"],
                        dimensions["right"],
                        dimensions["bottom"] + 1, 2, { r = 255, g = 0, b = 0, a = 100 },
                        { r = 255, g = 255, b = 255, a = 0 })
                end

                if distance > secondDistance and distance < thirdDistance then
                    c.windows.overlay.box_filled_outlined(dimensions["left"], dimensions["top"],
                        dimensions["right"],
                        dimensions["bottom"] + 1, 2, { r = 255, g = 0, b = 0, a = 100 },
                        { noColor })
                end
                if distance > thirdDistance and distance < fourthDistance then
                    c.windows.overlay.box_filled_outlined(dimensions["left"], dimensions["top"],
                        dimensions["right"],
                        dimensions["bottom"] + 1, 2, { r = 255, g = 0, b = 0, a = 100 },
                        { noColor })
                end

                if distance > fourthDistance and distance < maximunDistance then
                    c.windows.overlay.box_filled_outlined(dimensions["left"], dimensions["top"],
                        dimensions["right"],
                        dimensions["bottom"] + 1, 2, { r = 255, g = 0, b = 0, a = 100 },
                        { noColor })
                end
            end
        end
    end
end

return fov_visibility_esp
