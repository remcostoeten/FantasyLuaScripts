--[[
    @Patch Notes:
        - 4 months ago: "Fixed a logic error within Initialize in where the script wouldn't load."
--]]

--[[
    @title
        diffuser notification

    @author
        typedef

    @description
        plays a sound when another player is diffusing the bomb.
--]]

local diffusers =
{
    -- "DT_CSPlayer", "m_bIsDefusing"
    m_bIsDefusing = nil,

    -- sound to play
    sound = ""
}

function diffusers.Initialize(game_id)

    -- TF2 & Dota 2 obviously do not have bomb diffusal related content.
    if game_id ~= GAME_CSGO then
        constellation.log("Script unloaded because this is not CS:GO/CSS.")
        return false
    end

    -- get netvars and store them in a local variable so we don't raise CPU usage by repeatedly calling constellation.memory.netvar.
    diffusers.m_bIsDefusing = constellation.memory.netvar("DT_CSPlayer", "m_bIsDefusing")

    -- if m_bIsDefusing is 0, then somehow Constellation couldn't get the Netvar (CS:GO/CSS update).
    if diffusers.m_bIsDefusing == 0 then

        constellation.log("Script unloaded because m_bIsDefusing was invalid.")
        return false

    end

    -- Constelia saying "Diffusing".
    diffusers.sound = constellation.vars.get("directory") .. "constellation\\diffusing.wav"

    -- check if the file exists first. we don't want to replace the sound someone may have customized.
    if constellation.windows.file.exists(diffusers.sound) == false then

        -- actually download the file now.
        constellation.http.download_file("https://fantasy.cat/constellation/diffusing.wav", sound.sound)

    end
end

function diffusers.OnConstellationTick(localplayer, localweapon, viewangles)

    -- if there is no localplayer, we are not connected to a server.
    if localplayer == nil then return end

    --[[
        get all players OR a specific group of players

        constellation.game.get_enemies()
        constellation.game.get_teammates()
    --]]
    local player_database = constellation.game.get_players()

    -- loop through our player database.
    for _, player in pairs(player_database) do

        -- get m_bIsDefusing value of player.
        local is_diffusing = constellation.memory.read(player["address"] + diffusers.m_bIsDefusing)

        -- check if the returned value is true (1)
        if is_diffusing == 1 then

            -- play sound. do not play it asynchronously (false)
            constellation.windows.play_sound(diffusers.sound, false)

        end
    end
end

return diffusers
