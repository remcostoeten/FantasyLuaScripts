--[[
    @title
        hitmarker

    @author
        Moyo
        typedef

    @description
        plays a hitsound and draws a hitmarker on screen
        modified version of typedef's hitsound.lua
--]]

local hitmarker =
{
    enabled = nil,

    --[[
        this netvar is does not go higher than 255.
        however it does reset at the end of each round.

        therefore, if you end up landing more than 255 shots in a single round, the hitsound
        will no longer work.
    --]]
    m_totalHitsOnServer = nil,

    --[[
        this is the counter for the hitsound.

        the reason why we need a counter for this is to see if the value changed.
        if the value is changed then we can perform the hitsound.
    --]]
    counter = 0,

    -- sound file download location
    file = "",

    -- current ingame time
    curtime = nil,

    -- timestamp of last hit
    hitTime = 0,

    -- hitmarker size
    size = nil,

    -- hitmarker color
    colorR = 255,
    colorG = 255,
    colorB = 255
}

function hitmarker.Initialize(game_id)

    -- csgo only.
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
        "Enable Hitmarker",
        "hitmarker_enabled",
        "<input name='hitmarker_enabled' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        true
    )

    constellation.vars.menu(
        "hitmarker size",
        "hitmarker_size",
        "<input name='hitmarker_size' type='number' onchange=\"fantasy_cmd(this, 'set')\" />",
        8
    )

    constellation.vars.menu(
        "hitmarker color",
        "hitmarker_color",
        "<input name='hitmarker_color' type='color' onchange=\"fantasy_cmd(this, 'set')\" />",
        "FFFFFF"
    )

    -- set the location of the hitsound we're going to play later on.
    hitmarker.file = constellation.vars.get("directory") .. "constellation\\hitsound.wav"

    -- check if the file exists first. we don't want to replace a hitsound someone may have customized.
    if constellation.windows.file.exists(hitmarker.file) == false then

        -- actually download the file now.
        constellation.http.download_file("https://fantasy.cat/constellation/hitsound.wav", hitmarker.file)

    end
end

function hitmarker.OnConstellationCalibrated()
    -- get netvar
    hitmarker.m_totalHitsOnServer = constellation.memory.netvar("DT_CSPlayer", "m_totalHitsOnServer")
end

function hitmarker.OnConstellationTick(localplayer)
    if not localplayer then return end

    -- get FantasyVars and check if script is enabled
    hitmarker.enabled = constellation.vars.get("hitmarker_enabled")
    hitmarker.size = constellation.vars.get("hitmarker_size")
    hitmarker.colorR, hitmarker.colorG, hitmarker.colorB = constellation.vars.get_color("hitmarker_color")
    if hitmarker.enabled == 0 then return end

    -- get curtime
    local globals = constellation.game.get_globals()
    hitmarker.curtime = globals["curtime"]

    -- get m_totalHitsOnServer from localplayer
    local total_hits = constellation.memory.read(localplayer + hitmarker.m_totalHitsOnServer)

    -- does our total hits match our counter? if not, that means we hit someone new since the last time we checked.
    if total_hits ~= hitmarker.counter then

        -- check if total hits got reset after a new round started
        if total_hits ~= 0 then
            -- play sound
            constellation.windows.play_sound(hitmarker.file, true)
            hitmarker.hitTime = globals["curtime"]
        end

        -- update counter
        hitmarker.counter = total_hits
    end
end

function hitmarker.OnOverlayRender(width, height, center_x, center_y)
    if not hitmarker.curtime then return end
    if hitmarker.enabled == 0 then return end

    -- if we hit an enemy in the last 0.25 seconds draw the hitmarker
    if hitmarker.hitTime + 0.25 >= hitmarker.curtime then
        constellation.windows.overlay.line(center_x - hitmarker.size, center_y - hitmarker.size,
            center_x - (hitmarker.size / 4), center_y - (hitmarker.size / 4),
            { r = hitmarker.colorR, g = hitmarker.colorG, b = hitmarker.colorB, a = 255 })
        constellation.windows.overlay.line(center_x - hitmarker.size, center_y + hitmarker.size,
            center_x - (hitmarker.size / 4), center_y + (hitmarker.size / 4),
            { r = hitmarker.colorR, g = hitmarker.colorG, b = hitmarker.colorB, a = 255 })
        constellation.windows.overlay.line(center_x + hitmarker.size, center_y + hitmarker.size,
            center_x + (hitmarker.size / 4), center_y + (hitmarker.size / 4),
            { r = hitmarker.colorR, g = hitmarker.colorG, b = hitmarker.colorB, a = 255 })
        constellation.windows.overlay.line(center_x + hitmarker.size, center_y - hitmarker.size,
            center_x + (hitmarker.size / 4), center_y - (hitmarker.size / 4),
            { r = hitmarker.colorR, g = hitmarker.colorG, b = hitmarker.colorB, a = 255 })
    end
end

return hitmarker
