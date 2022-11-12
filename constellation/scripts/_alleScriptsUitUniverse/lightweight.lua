--[[
    @title
        lightweight constellation

    @author
        typedef

    @description
        Start and calibrate Constellation without the semantics of Constelia and so forth.
--]]


local lightweight =
{
    supported =
    {
        { "CS:GO/TF2/CSS", "Valve001", "" },
        { "Dota 2", "", "Dota 2" },
    },

    found_game = nil,
}

function lightweight.Initialize(game_id)

    -- if you don't have constelia.dat, then this script won't run because then Constellation won't work.
    if not
        constellation.windows.file.exists(string.format("%sconstellation\\constelia.dat",
            constellation.vars.get("directory"))) then
        constellation.windows.popup("Please run Constellation normally without this script (lightweight.lua). You do not have any saved memory for Constelia. You must run the calibration test with her before using this script."
            , "fantasy.constellation - fantasy.cat", MB_OK)
        constellation.exit()
    end

    -- cursor off
    constellation.cursor(false)

    -- console
    constellation.console(true)

    -- dialogues only.
    constellation.vars.add("constelia_windows_dialogue", true)

    -- infinite loop
    while (true) do

        -- check if any of the supported games are running. loop through table.
        for _, window_information in pairs(lightweight.supported) do

            -- is the window of the supported game open?
            if constellation.windows.find_window(window_information[2], window_information[3]) then

                -- found the game, log
                constellation.log(string.format("Found %s open.", window_information[1]))

                -- set our variable
                lightweight.found_game = window_information

                -- assign our window so we can flash it later.
                constellation.set_window(window_information[2], window_information[3])
            end
        end

        -- we found a game, stop the infinite loop
        if lightweight.found_game ~= nil then
            break
        end

        -- sleep the infinite loop for 1 second since we haven't found a game.
        constellation.sleep(1000)
    end

    -- if console.lua is NOT loaded, close the console we opened.
    if not constellation.scripts.is_loaded("console.lua") then
        constellation.console(false)
    end

    -- flash window.
    constellation.windows.flash_window(true)

    -- simply let Constellation continue because the calibration prompt will appear automatically.
    return true
end

function lightweight.OnConsteliaSpeak()
    -- mute constelia
    return false
end

function lightweight.OnConsteliaNotification()
    -- no toast notifications
    return false
end

function lightweight.OnConstellationLoseGame()
    -- cursor off
    constellation.cursor(false)
    constellation.exit()
end

return lightweight
