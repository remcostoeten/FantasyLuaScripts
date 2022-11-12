--[[
    @Patch Notes:
        - 4 months ago: "Fixed sanity check for button_capture_id being after constellation.windows.capture.find, causing it literally to not do anything. Thanks @typedef"
        - 4 months ago: "Fixed button_capture_id not having a sanity check causing the script to crash constellation."
        - 4 months ago: "- Fixed an issue in the syntax (and -> or) in the sanity check for button_capture_id."
--]]

--[[
    @title
        Auto-Accept (CS:GO)
    
    @author
        Salt
    
    @notes
    Converted straight from typedef's Dota 2 auto-accept script. Thanks
    --]]

local autoaccept_csgo =
{
    -- download accept button image to compare
    button_url = "https://i.imgur.com/HnaA9BM.png",

    -- the directory of the button we will download and store.
    button_path = constellation.vars.get("directory") .. "\\constellation\\autoaccept_csgo.png",

    -- the button id when we capture it into Constelia's memory.
    button_capture_id = nil
}

function autoaccept_csgo.Initialize(game_id)

    -- cs:go only
    if game_id ~= GAME_CSGO then
        constellation.log("This script is only for CS:GO.")
        return false
    end

    -- download auto accept button.
    constellation.log("Downloading [ACCEPT] button from " .. autoaccept_csgo.button_url)
    constellation.http.download_file(autoaccept_csgo.button_url, autoaccept_csgo.button_path)

    -- check if file exists
    if not constellation.windows.file.exists(autoaccept_csgo.button_path) then
        constellation.log("Failed to download button.")
        return false
    end

    -- load the image as a capture
    if not constellation.windows.capture.image(autoaccept_csgo.button_path) then
        constellation.log("Failed to capture auto accept button.")
        return false
    end

    -- store image into Constelia's memory
    autoaccept_csgo.button_capture_id = constellation.windows.capture.store()
end

function autoaccept_csgo.OnConstellationTick(localplayer)

    -- we can only accept matches when we're NOT ingame.
    if localplayer ~= nil then return end

    -- capture CS:GO window
    if not constellation.windows.capture.window("", "Counter-Strike: Global Offensive - Direct3D 9") then
        constellation.log("Failed to capture CS:GO window.")
        return
    end


    --sanity check for button_capture_id
    if autoaccept_csgo.button_capture_id == nil then return end

    -- find our auto-accept button
    local x, y, x2, y2 = constellation.windows.capture.find(autoaccept_csgo.button_capture_id)

    -- can't find it.
    if x == 0 or y == 0 or x2 == 0 or y2 == 0 then return end

    -- we found our accept button
    constellation.log("Accept button has been found. (" .. x .. ", " .. y .. ", " .. x2 .. "," .. y2 .. ")")

    -- put our mouse over it.
    constellation.driver.move(x + 100, y + 50, MOUSE_MOVE_ABSOLUTE)

    --click now
    constellation.driver.click()
end

return autoaccept_csgo
