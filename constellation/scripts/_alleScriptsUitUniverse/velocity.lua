--[[
    @Patch Notes:
        - 1 month ago: "Replaced old entity members by classes. (https://fantasy.cat/forums/index.php?threads/parallatic.6260/post-50884)"
        - 5 months ago: "- Removed unnecessary function call "parallatic.game.get_motion".
- Changed how the script recognized when the localplayer was hit (health -> hurt_time). Now the velocity modifier should apply even if your health does not decrease when you get hit.
- Added on ground check to prevent vertical velocity being reduced when mid air (prevents getting stuck mid air hence flagging glide/flyhack)"
--]]

--[[
    @title
        Velocity Graph

    @author
        Moyo

    @description
        a graph that shows your player velocity
--]]
local velocity = {
    totalVel = nil,
    savedValues = {},
    savedStamina = {},
    lastTimestamp = 0,
    alive = false,

    -- settings
    enabled = nil,
    rainbowMode = nil,
    showAverage = nil,
    showStamina = nil,
    fillGraph = nil,
    colorR = nil,
    colorG = nil,
    colorB = nil,
    posX = nil,
    posY = nil,

    -- ingame check variables
    clientState = nil,
    dwClientState_State = nil, -- offset

    -- netvars
    m_vecVelocity = nil,
    m_flStamina = nil
}

function velocity.Initialize(game_id)
    if game_id ~= GAME_CSGO then
        constellation.log("not calibrated with CSGO")
        return false
    else
        if constellation.windows.overlay.create("Valve001", "") == false then
            constellation.log("The overlay could not be created because another script already created one.")
        else
            constellation.log("Created overlay.")
        end
    end

    -- menu options
    constellation.vars.menu(
        "enable velocity graph",
        "velocity_enabled",
        "<input name='velocity_enabled' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "velocity rainbow mode",
        "velocity_rainbow",
        "<input name='velocity_rainbow' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "show average velocity",
        "velocity_average",
        "<input name='velocity_average' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "show stamina",
        "velocity_stamina",
        "<input name='velocity_stamina' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        false
    )

    constellation.vars.menu(
        "fill under graph",
        "velocity_fill",
        "<input name='velocity_fill' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        false
    )

    constellation.vars.menu(
        "velocity graph color",
        "velocity_color",
        "<input name='velocity_color' type='color' onchange=\"fantasy_cmd(this, 'set')\" />",
        "FF00FF"
    )

    constellation.vars.menu(
        "velocity graph X (in %)",
        "velocity_x",
        "<input name='velocity_x' type='number' onchange=\"fantasy_cmd(this, 'set')\" min=\"1\" max=\"100\" />",
        50
    )

    constellation.vars.menu(
        "velocity graph Y (in %)",
        "velocity_y",
        "<input name='velocity_y' type='number' onchange=\"fantasy_cmd(this, 'set')\" min=\"1\" max=\"100\" />",
        80
    )

    constellation.windows.overlay.add_font(
        "Consolas",
        "Consolas",
        16,
        600,
        DWRITE_FONT_STRETCH_NORMAL
    )

    constellation.windows.overlay.add_font(
        "Verdana",
        "Verdana",
        30,
        800,
        DWRITE_FONT_STRETCH_NORMAL
    )

    for i = 1, 230, 1 do
        velocity.savedValues[i] = 0
    end
end

function velocity.OnConstellationCalibrated()
    velocity.m_vecVelocity = constellation.memory.netvar("DT_CSPlayer", "m_vecVelocity[0]")
    velocity.m_flStamina = constellation.memory.netvar("DT_CSPlayer", "m_flStamina")

    local engine_address, engine_size = constellation.driver.module("engine.dll")

    local dwClientState = constellation.memory.pattern(
        engine_address,
        engine_size,
        "A1 ? ? ? ? 33 D2 6A 00 6A 00 33 C9 89 B0",
        1,
        0,
        0
    )

    velocity.dwClientState_State = constellation.memory.pattern(
        engine_address,
        engine_size,
        "83 B8 ? ? ? ? ? 0F 94 C0 C3",
        2,
        0,
        1
    )

    velocity.clientState = constellation.memory.read(engine_address + dwClientState)
end

function velocity.OnConstellationTick(localplayer, localweapon, viewangles)

    -- get FantasyVars and check if script is enabled
    velocity.enabled = constellation.vars.get("velocity_enabled")
    if velocity.enabled == 0 then return end
    if velocity.clientState == nil or velocity.dwClientState_State == nil then
        constellation.log("the clientState variables are nil during/after calibration")
        return
    end
    if constellation.memory.read_integer(velocity.clientState + velocity.dwClientState_State) ~= 6 then
        velocity.enabled = 0
        velocity.lastTimestamp = 0
        for i = 1, 230, 1 do
            velocity.savedValues[i] = 0
            velocity.savedStamina[i] = 0
        end
        return
    end
    velocity.rainbowMode = constellation.vars.get("velocity_rainbow")
    velocity.showAverage = constellation.vars.get("velocity_average")
    velocity.showStamina = constellation.vars.get("velocity_stamina")
    velocity.fillGraph = constellation.vars.get("velocity_fill")
    velocity.posX = constellation.vars.get("velocity_x")
    velocity.posY = constellation.vars.get("velocity_y")
    if velocity.rainbowMode == 0 then velocity.colorR, velocity.colorG, velocity.colorB = constellation.vars.get_color("velocity_color") end

    -- check and save if localplayer is alive
    local player = constellation.game.get_player(localplayer)
    if player["is_alive"] ~= velocity.alive then
        if player["is_alive"] then
            velocity.alive = true
            for i = 1, 230, 1 do
                velocity.savedValues[i] = 0
                velocity.savedStamina[i] = 0
            end
        else
            velocity.alive = false
            velocity.enabled = 0
            return
        end
    elseif not player["is_alive"] then
        velocity.enabled = 0
        return
    end

    -- get player velocity vector
    local vel = constellation.memory.read_vector(localplayer + velocity.m_vecVelocity)
    velocity.totalVel = math.sqrt(vel.x * vel.x + vel.y * vel.y)

    -- get player stamina
    local stamina = constellation.memory.read_float(localplayer + velocity.m_flStamina)

    local globals = constellation.game.get_globals()

    if velocity.lastTimestamp + 0.015625 < globals["curtime"] then
        table.insert(velocity.savedValues, velocity.totalVel)
        if velocity.showStamina == 1 then
            table.insert(velocity.savedStamina, stamina)
            if #velocity.savedStamina > 230 then table.remove(velocity.savedStamina, 1) end
        end
        if #velocity.savedValues > 230 then table.remove(velocity.savedValues, 1) end
        velocity.lastTimestamp = globals["curtime"]
    end
end

function velocity.OnOverlayRender(width, height, center_x, center_y)
    if velocity.enabled == 0 or not velocity.totalVel then return end

    local velWidth = width * 0.22
    local velHeight = height * 0.105
    local x = (velocity.posX / 100 * width) - (velWidth / 2)
    local y = height * (velocity.posY / 100)
    local sum = 0

    -- draw current velocity as text
    local textR, textG, textB = 255, 255, 255
    if velocity.rainbowMode == 0 then
        textR = velocity.colorR
        textG = velocity.colorG
        textB = velocity.colorB
    end
    constellation.windows.overlay.text(string.format("%.0f", velocity.totalVel), "Verdana", (x + velWidth / 2) - 15 + 2,
        y + (velHeight / 1.5) + 2, { r = 0, g = 0, b = 0, a = 255 })
    constellation.windows.overlay.text(string.format("%.0f", velocity.totalVel), "Verdana", (x + velWidth / 2) - 15,
        y + (velHeight / 1.5), { r = textR, g = textG, b = textB, a = 255 })

    if velocity.showStamina == 1 then
        local currentStamina = velocity.savedStamina[#velocity.savedStamina]
        -- color depending on stamina value
        velGB = (1 - (currentStamina / 80)) * 255
        constellation.windows.overlay.text(string.format("%.0f", currentStamina), "Verdana", (x + velWidth / 2) - 8 + 2,
            y + velHeight + 2, { r = 0, g = 0, b = 0, a = 255 })
        constellation.windows.overlay.text(string.format("%.0f", currentStamina), "Verdana", (x + velWidth / 2) - 8,
            y + velHeight, { r = 255, g = velGB, b = velGB, a = 255 })
    end

    for i = 1, 230, 1 do
        if velocity.savedValues[i] ~= nil then
            sum = sum + velocity.savedValues[i]

            local thisVelX = x + (i / 230) * velWidth
            local velRatio = velocity.savedValues[i] / 350
            if velRatio > 1 then velRatio = 1 end
            local thisVelY = y + ((1 - velRatio) * velHeight)

            if velocity.savedValues[i + 1] ~= nil then
                local nextVelX = x + ((i + 1) / 230) * velWidth
                local nextVelRatio = velocity.savedValues[i + 1] / 350
                if nextVelRatio > 1 then nextVelRatio = 1 end
                local nextVelY = y + ((1 - nextVelRatio) * velHeight)

                local opacity = 1
                if i <= 25 then
                    opacity = (i - 1) / 25
                elseif i >= 205 then
                    opacity = (230 - i) / 25
                end

                local r, g, b

                if velocity.rainbowMode == 1 then
                    if i < 38 then
                        r = 1
                        g = 0
                        b = i / 38
                    elseif i < 76 then
                        r = 1 - (i - 38) / 38
                        g = 0
                        b = 1
                    elseif i < 114 then
                        r = 0
                        g = (i - 76) / 38
                        b = 1
                    elseif i < 152 then
                        r = 0
                        g = 1
                        b = 1 - (i - 114) / 38
                    elseif i < 192 then
                        r = (i - 152) / 39
                        g = 1
                        b = 0
                    else
                        r = 1
                        g = 1 - (i - 192) / 39
                        b = 0
                    end
                else
                    r = velocity.colorR / 255
                    g = velocity.colorG / 255
                    b = velocity.colorB / 255
                end

                constellation.windows.overlay.line(thisVelX, thisVelY, nextVelX, nextVelY,
                    { r = r, g = g, b = b, a = opacity }, 2)
                if velocity.fillGraph == 1 and i % 2 == 0 then
                    constellation.windows.overlay.line(thisVelX, thisVelY, thisVelX, y + velHeight,
                        { r = r, g = g, b = b, a = opacity })
                end
            end
        end
        if velocity.showStamina == 1 and velocity.savedStamina ~= nil then
            local stamX = x + (i / 230) * velWidth
            local stamRatio = velocity.savedStamina[i] / 50
            local stamY = y + ((1 - stamRatio) * velHeight)

            if velocity.savedStamina[i + 1] ~= nil then
                local nextStamX = x + ((i + 1) / 230) * velWidth
                local nextStamRatio = velocity.savedStamina[i + 1] / 50
                local nextStamY = y + ((1 - nextStamRatio) * velHeight)

                local opacity = 1
                if i <= 25 then
                    opacity = (i - 1) / 25
                elseif i >= 205 then
                    opacity = (230 - i) / 25
                end

                local stamGB = (1 - stamRatio)

                constellation.windows.overlay.line(stamX, stamY, nextStamX, nextStamY,
                    { r = 1, g = stamGB, b = stamGB, a = opacity })
            end
        end
    end

    -- draw average velocity
    if velocity.showAverage == 1 then
        local average = sum / 230
        local avgRatio = average / 350
        if avgRatio > 1 then avgRatio = 1 end
        local avgX, avgY, nextAvgX, opacity
        for i = 1, 52, 1 do
            if i <= 25 then
                opacity = 1 - (25 - i) / 25
                avgX = x + (i / 230) * velWidth
                nextAvgX = x + ((i + 1) / 230) * velWidth
            elseif i == 26 then
                opacity = 1
                avgX = x + (i / 230) * velWidth
                nextAvgX = x + ((i + 179) / 230) * velWidth
            else
                opacity = 1 - (i - 25) / 25
                avgX = x + ((i + 178) / 230) * velWidth
                nextAvgX = x + ((i + 179) / 230) * velWidth
            end
            avgY = y + (1 - avgRatio) * velHeight
            constellation.windows.overlay.line(avgX, avgY, nextAvgX, avgY, { r = 1, g = 1, b = 1, a = opacity * 0.8 })
        end
        constellation.windows.overlay.text(string.format("%.0f", average), "Consolas", x - 22,
            y + (1 - avgRatio) * velHeight - 7, { r = 255, g = 255, b = 255, a = 150 })
    end
end

return velocity
