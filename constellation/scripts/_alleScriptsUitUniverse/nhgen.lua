--[[
    @title
        Nade Help Generator
    @author
        typedef
    @notes
        Allows you to generate custom nades for Moyo's nade_helper.lua script.
--]]

local nhgen =
{
    -- directory
    directory = constellation.vars.get("directory") .. "constellation\\nhgen\\",

    -- input var for constellation.windows.overlay.imgui.inputtext
    var_input = "nade_helper_gen_input",

    -- capture data
    capture =
    {
        -- game/world
        viewangles = nil,
        position = nil,

        -- throwing option
        throw_type = "normal throw",

        -- name editor
        name = "",
        name_editor = false,
    },

    -- memory address
    addresses =
    {
        engine = nil,
        engine_size = nil,

        dwClientState = nil,
        dwClientState_Map = nil
    },

    -- menu options
    menu =
    {
        enabled = nil,
        save = nil,
    },

    -- functions
    get_map_name = function(self)

        local client_state = constellation.memory.read(self.addresses.engine + self.addresses.dwClientState)
        if not client_state then return end

        return constellation.memory.read_string(client_state + self.addresses.dwClientState_Map)
    end,
}

--[[
    it is always a bad practice in fantasy.cat to write lua script code
    outside of callbacks. however this script requires a library for it to even
    work.

    therefore, we need to execute code immediately as Constellation reads the script and before
    it calls Initialize.

    The function constellation.scripts.install_module will download a lua module/library from the web
    and place it inside of your constellation\scripts\lib folder (will create it if it doesn't exist)

    we only want to do this if the script is enabled. constellation.scripts.is_loaded will determine that.
--]]
if constellation.scripts.is_loaded("nhgen.lua") then
    -- https://github.com/rxi/json.lua
    constellation.scripts.install_module("json.lua", "https://raw.githubusercontent.com/rxi/json.lua/master/json.lua")
else

    --[[
        we are going to stop the script from executing anything further if it's NOT enabled.
        without this check, this script will try to load the "json" library even if it doesn't exist and thereby
        potentially crashing constellation.

        we are returning 'scripts' because when constellation loads a script, it collects all the callbacks
        and other related members to the global table (in this case "scripts") and then reads off of it as
        constellation runs.

        if we returned 'false' or anything else, constellation will crash because it couldn't collect the global table.
    --]]

    return nhgen
end

-- include library
local json = require("json")

function nhgen.Initialize(game_id)

    -- CS:GO only.
    if game_id ~= GAME_CSGO then return false end

    -- get engine.dll
    nhgen.addresses.engine, nhgen.addresses.engine_size = constellation.driver.module("engine.dll")
    if not nhgen.addresses.engine or not nhgen.addresses.engine_size then return false end

    -- pattern scan (https://github.com/frk1/hazedumper/blob/1bd37ca0a1f79042ca83dda8a3301019b3421e5c/config.json#L13)
    nhgen.addresses.dwClientState = constellation.memory.pattern(nhgen.addresses.engine, nhgen.addresses.engine_size,
        "A1 ? ? ? ? 33 D2 6A 00 6A 00 33 C9 89 B0", 1, 0, 0)
    nhgen.addresses.dwClientState_Map = constellation.memory.pattern(nhgen.addresses.engine, nhgen.addresses.engine_size
        , "05 ? ? ? ? C3 CC CC CC CC CC CC CC A1", 1, 0, 1)
    if not nhgen.addresses.dwClientState or not nhgen.addresses.dwClientState_Map then return false end

    -- create directory
    constellation.windows.file.create_directory(nhgen.directory)

    -- create overlay.
    constellation.windows.overlay.create("Valve001", "")

    -- create cosntellation.windows.overlay.imgui.inputtext var
    constellation.vars.add(nhgen.var_input, "")

    -- menu options
    nhgen.menu.enabled = constellation.vars.menu("Nade Helper Generator [Enabled]", "nade_helper_gen",
        "<input name='nade_helper_gen' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    nhgen.menu.save = constellation.vars.menu("Nade Helper Generator [Key]", "nade_helper_gen_key",
        "<input name='nade_helper_gen_key' type='number' onchange=\"fantasy_cmd(this, 'set')\"   />", 117)

    -- just in case you reload the script, reset the pie so it doesn't automatically open options
    constellation.windows.overlay.reset_pie()

    -- notification to show everything is ready
    constellation.windows.overlay.notification("Nade Helper Generator ready!", 5000)
end

function nhgen.OnConstellationTick(localplayer, _, viewangles)

    -- Initalize hasn't finished yet.
    if not nhgen.menu.enabled or not nhgen.menu.save then return end

    -- not game.
    if not localplayer then return end

    -- is enabled?
    if not constellation.vars.get(nhgen.menu.enabled) then return end

    -- is key pressed?
    if not constellation.windows.key(constellation.vars.get(nhgen.menu.save)) then return end

    -- is a capture active right now?
    if nhgen.capture.viewangles ~= nil and nhgen.capture.position ~= nil then return end

    -- get player information
    local player_information = constellation.game.get_player(localplayer)
    if not player_information then return end

    -- set our capture information
    nhgen.capture.viewangles = viewangles
    nhgen.capture.position = player_information["eye_position"]

    -- set this var back to a blank text so previous configurations don't load old values.
    constellation.vars.add(nhgen.var_input, "")
end

function nhgen.OnOverlayRender(_, _, cx, cy)

    -- no captures
    if not nhgen.capture.viewangles or not nhgen.capture.position then return end

    -- name editor enabled?
    if nhgen.capture.name_editor then

        -- window size
        constellation.windows.overlay.imgui.set_next_size(186, 90)

        -- create window
        constellation.windows.overlay.imgui.window("Name of Nade Location",
            bit.bor(ImGuiWindowFlags_NoSavedSettings, ImGuiWindowFlags_NoResize, ImGuiWindowFlags_NoCollapse))

        -- inputtext
        constellation.windows.overlay.imgui.push_width(169)
        constellation.windows.overlay.imgui.inputtext("##nade_name", nhgen.var_input, 0)
        constellation.windows.overlay.imgui.pop_width()

        -- submit button
        if constellation.windows.overlay.imgui.button("Submit", 80, 30) then

            -- reset pie
            constellation.windows.overlay.reset_pie()

            -- toggle editor off
            nhgen.capture.name_editor = false

            -- disable hook
            constellation.windows.overlay.toggle_keyboard_hook(false)
        end

        -- button on same line as other button
        constellation.windows.overlay.imgui.same_line(97, 0)

        -- cancel button
        if constellation.windows.overlay.imgui.button("Cancel", 80, 30) then

            -- reset pie
            constellation.windows.overlay.reset_pie()

            -- toggle editor off
            nhgen.capture.name_editor = false

            -- disable hook
            constellation.windows.overlay.toggle_keyboard_hook(false)
        end

        -- close window
        constellation.windows.overlay.imgui.end_window()

        -- returning because we don't want the pie menu to show when we're doing this.
        return
    end

    -- show pie menu
    local name_of_capture = constellation.vars.get(nhgen.var_input)
    if name_of_capture == "" then
        name_of_capture = "No Name"
    end

    local selected_option = constellation.windows.overlay.pie("Exit|" ..
        nhgen.capture.throw_type .. "|Save|" .. name_of_capture .. "")

    -- option response
    if selected_option == 0 then -- Exit

        -- nullify game/world data.
        nhgen.capture.viewangles = nil
        nhgen.capture.position = nil
        nhgen.capture.name_editor = false

        -- log & reset
        constellation.log("Menu closed.")
        constellation.windows.overlay.reset_pie()

    elseif selected_option == 1 then -- Nade Throw Type

        -- cycle options
        if nhgen.capture.throw_type == "normal throw" then
            nhgen.capture.throw_type = "throwJump"
        elseif nhgen.capture.throw_type == "throwJump" then
            nhgen.capture.throw_type = "normal throw"
        end

        -- log & reset
        constellation.log("Throw type changed to " .. nhgen.capture.throw_type)
        constellation.windows.overlay.reset_pie()

    elseif selected_option == 2 then -- Save

        -- get map name
        local map_name = nhgen.get_map_name(nhgen)
        if not map_name then return end

        -- map directory
        local map_directory = nhgen.directory .. map_name .. "\\"

        -- json path
        local json_path = map_directory .. map_name .. ".json"

        -- nade name we created
        local nade_name = constellation.vars.get(nhgen.var_input)

        -- create directory of the map name
        constellation.windows.file.create_directory(map_directory)

        -- output raw
        local raw_text = string.format(
            "{name = \"%s\", nadeType = \"smoke\", throwingType = \"%s\", playerX = %f, playerY = %f, playerZ = %f, viewangleX = %f, viewangleY = %f},"
            ,
            nade_name,
            nhgen.capture.throw_type,
            nhgen.capture.position["x"],
            nhgen.capture.position["y"],
            nhgen.capture.position["z"],
            nhgen.capture.viewangles["x"],
            nhgen.capture.viewangles["y"]
        )

        -- create file
        constellation.windows.file.append(map_directory .. nade_name .. ".txt", raw_text .. "\r\n")

        -- create notification
        constellation.windows.overlay.notification("Nade saved to " .. map_directory .. nade_name .. ".txt", 5000)
        constellation.log("Nade saved to " .. map_directory .. nade_name .. ".txt")

        -- default JSON table.
        local json_information = {}

        -- read from file
        local json_string = constellation.windows.file.read(json_path)
        if json_string == "" then

            -- file doesn't exist or was empty
            constellation.log("Map database does not exist. Creating one now...")
            constellation.windows.file.write(json_path)

            json_information["nade_locations"] = {}
            json_information["nade_locations"][map_name] = {}
        else

            -- file existed and had content, decode it.
            json_information = json.decode(json_string)

        end

        -- create new table entry
        json_information["nade_locations"][map_name][nade_name] = {}

        -- insert into map table
        table.insert(json_information["nade_locations"][map_name][nade_name], {
            nadeType = "smoke",
            throwingType = nhgen.capture.throw_type,
            playerX = nhgen.capture.position["x"],
            playerY = nhgen.capture.position["y"],
            playerZ = nhgen.capture.position["z"],
            viewangleX = nhgen.capture.viewangles["x"],
            viewangleY = nhgen.capture.viewangles["y"],
        })

        constellation.windows.file.write(json_path, json.encode(json_information))

        -- create notification
        constellation.windows.overlay.notification("JSON Nade saved to " .. json_path, 5000)
        constellation.log("JSON Nade saved to " .. json_path)

        -- nullify game/world data.
        nhgen.capture.viewangles = nil
        nhgen.capture.position = nil
        nhgen.capture.name_editor = false

        -- reset
        constellation.windows.overlay.reset_pie()


    elseif selected_option == 3 then -- Name

        -- enable the menu
        nhgen.capture.name_editor = true

        -- toggle the keyboard hook, so we can do input
        constellation.windows.overlay.toggle_keyboard_hook(true)

    end
end

return nhgen
