--[[
    @title
        crosshair

    @author
        Moyo
        (original Moonlight script made by Tsukino)

    @description
        drawing a recoil crosshair and sniper noscope dot on the Constellation overlay
        CSGO only
--]]
local crosshair = {
    enabled = nil,
    crosshairX = nil,
    crosshairY = nil,
    screenWidth = nil,
    screenHeight = nil,

    -- crosshair color
    r = 255,
    g = 0,
    b = 0,
    a = 255,

    -- netvars
    m_bIsScoped = nil,
    m_iShotsFired = nil,
    m_aimPunchAngle = nil,
}

function crosshair.Initialize(game_id)
    if game_id ~= GAME_CSGO then
        constellation.log("not calibrated with CSGO")
        return false
    else
        constellation.windows.overlay.create("Valve001", "")
    end

    constellation.vars.menu(
        "enable recoil crosshair",
        "crosshair_enabled",
        "<input name='crosshair_enabled' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        true
    )
end

function crosshair.OnConstellationCalibrated()
    crosshair.m_bIsScoped = constellation.memory.netvar("DT_CSPlayer", "m_bIsScoped")
    crosshair.m_iShotsFired = constellation.memory.netvar("DT_CSPlayer", "m_iShotsFired")
    crosshair.m_aimPunchAngle = constellation.memory.netvar("DT_CSPlayer", "m_aimPunchAngle")
end

function crosshair.OnConstellationTick(localplayer, localweapon, viewangles)
    if localplayer == nil or localweapon == nil or crosshair.screenWidth == nil or crosshair.screenHeight == nil then return end

    crosshair.enabled = constellation.vars.get("crosshair_enabled")
    if crosshair.enabled == 0 then return end

    crosshair.crosshairX, crosshair.crosshairY = nil, nil
    if bit.band(constellation.memory.read_integer(localplayer + crosshair.m_bIsScoped), 1) == 1 then return end

    local weapon = constellation.game.get_weapon(localweapon)
    if weapon["is_sniper"] == false then
        if constellation.memory.read_integer(localplayer + crosshair.m_iShotsFired) > 1 then
            -- get aimpunch angles
            local aimpunch = constellation.memory.read_vector(localplayer + crosshair.m_aimPunchAngle)
            crosshair.crosshairX = crosshair.screenWidth / 2 - (crosshair.screenWidth / 90 * aimpunch["y"])
            crosshair.crosshairY = crosshair.screenHeight / 2 + (crosshair.screenHeight / 90 * aimpunch["x"])
        end
    else
        crosshair.crosshairX = crosshair.screenWidth / 2
        crosshair.crosshairY = crosshair.screenHeight / 2
    end
end

function crosshair.OnOverlayRender(width, height, center_x, center_y)
    if crosshair.enabled == 0 then return end

    if crosshair.screenWidth == nil or crosshair.screenHeight == nil then
        crosshair.screenWidth = width
        crosshair.screenHeight = height
    end

    if crosshair.crosshairX ~= nil and crosshair.crosshairY ~= nil then
        constellation.windows.overlay.box(crosshair.crosshairX - 1, crosshair.crosshairY - 1, 2, 2, 1,
            { r = crosshair.r, g = crosshair.g, b = crosshair.b, a = crosshair.a })
    end

end

return crosshair
