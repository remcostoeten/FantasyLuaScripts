--[[
    @title
        hitsound

    @author
        typedef

    @description
        see notes about m_totalHitsOnServer
--]]

local hitsound =
{
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
    file = ""
}

function hitsound.Initialize(game_id)

    -- csgo only.
    if game_id ~= GAME_CSGO then return false end

    -- menu options
    constellation.vars.menu(
        "Hitsound",
        "esp_hitsound",
        "<input name='esp_hitsound' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        true
    )

    -- set the location of the hitsound we're going to play later on.
    hitsound.file = constellation.vars.get("directory") .. "constellation\\hitsound.wav"

    -- check if the file exists first. we don't want to replace a hitsound someone may have customized.
    if constellation.windows.file.exists(hitsound.file) == false then

        -- actually download the file now.
        constellation.http.download_file("https://fantasy.cat/constellation/hitsound.wav", hitsound.file)

    end
end

function hitsound.OnConstellationCalibrated()

    -- get netvar
    hitsound.m_totalHitsOnServer = constellation.memory.netvar("DT_CSPlayer", "m_totalHitsOnServer")

end

function hitsound.OnConstellationTick(localplayer)

    -- is enabled
    if constellation.vars.get("esp_hitsound") == 0 then return end

    -- get m_totalHitsOnServer from localplayer
    local total_hits = constellation.memory.read(localplayer + hitsound.m_totalHitsOnServer)

    -- does our total hits match our counter? if not, that means we hit someone new since the last time we checked.
    if total_hits ~= hitsound.counter then

        -- play sound
        constellation.windows.play_sound(hitsound.file, true)

        -- update counter
        hitsound.counter = total_hits

    end
end

return hitsound
