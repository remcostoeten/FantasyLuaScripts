--[[
    @Patch Notes:
        - 4 months ago: "Removed player location, added a counter for competitive wins, and made optimizations to help increase performance"
        - 4 months ago: "Added a menu option to toggle the Player Location feature."
        - 4 months ago: "Removed unnecessary menu options, changed overlay from plain text to an ImGUI window, implemented rank icons, and added player location."
--]]

--[[
    @title
        rankrevealer

    @author
        cronchy

    @description
        a rank revealer for CSGO. my first attempt at a script ever. credits to Moyo for giving me guidance along the way
   
--]]
local rankrevealer = {

    enabled = nil,
    font = nil,
    location = nil,

    -- netvars
    m_iCompetitiveWins = nil,
    m_iCompetitiveRanking = nil,

    -- storage for all players
    player_information = {},

    -- local player information
    localplayer_information = {},

    -- client.dll stuff
    client_address = nil,
    client_size = nil,
    dwPlayerResource = nil,

    -- rank stuff
    p_ranks = nil,
    Unranked = nil,
    S1 = nil,
    S2 = nil,
    S3 = nil,
    S4 = nil,
    SE = nil,
    SEM = nil,
    GN1 = nil,
    GN2 = nil,
    GN3 = nil,
    GNM = nil,
    MG1 = nil,
    MG2 = nil,
    MGE = nil,
    DMG = nil,
    LE = nil,
    LEM = nil,
    SMFC = nil,
    GE = nil,

    -- add_player function.
    add_player = function(self, player_resource, player, rank, wins)
        if player["team"] ~= 0 then
            -- Add new entry to player table for last known location.
            local wins = constellation.memory.read_integer(player_resource + wins + (player["index"] * 4))
            player["wins"] = tostring(wins)

            player["rank"] = constellation.memory.read_integer(player_resource + rank + (player["index"] * 4))

            -- Shrink name for GUI
            if string.len(player["name"]) > 8 then
                player["name"] = string.sub(player["name"], 0, -8) .. ".." -- Name too big.
            end

            -- Insert into our table.
            table.insert(self.player_information, player)
        end
    end
}

function rankrevealer.Initialize(game_id)
    if game_id ~= GAME_CSGO then
        constellation.log("rankrevealer is not calibrated with CSGO")
        return false
    else
        if constellation.windows.overlay.create("Valve001", "") == false then
            constellation.log("The overlay could not be created because another script already created one.")
        else
            constellation.log("Created overlay.")
        end
    end

    if not
        constellation.windows.file.exists(constellation.vars.get("directory") ..
            "constellation\\resources\\rankicons.zip") then
        constellation.http.download_file("https://fantasy.cat/constellation/rankicons.zip",
            constellation.vars.get("directory") .. "constellation\\resources\\rankicons.zip")
        if constellation.windows.zip(constellation.vars.get("directory") .. "constellation\\resources\\rankicons.zip",
            "constellation\\resources") then
            constellation.log("Successfully extracted rank pictures.")
        else
            constellation.log("Extraction failed.")
        end
    end

    --  get the client.dll module
    rankrevealer.client_address, rankrevealer.client_size = constellation.driver.module("client.dll")

    -- scan client.dll for dwPlayerResource
    -- https://github.com/frk1/hazedumper/blob/master/config.json#L315
    rankrevealer.dwPlayerResource = constellation.driver.pattern(
        rankrevealer.client_address, -- client.dll
        rankrevealer.client_size, -- client.dll's size
        "8B 3D ? ? ? ? 85 FF 0F 84 ? ? ? ? 81 C7", -- pattern
        2, -- offset
        0, -- extra
        0-- unrelativity
    )

    -- add the rank pictures
    rankrevealer.Unranked = constellation.windows.overlay.add_image("Unranked.png")
    rankrevealer.S1 = constellation.windows.overlay.add_image("S1.png")
    rankrevealer.S2 = constellation.windows.overlay.add_image("S2.png")
    rankrevealer.S3 = constellation.windows.overlay.add_image("S3.png")
    rankrevealer.S4 = constellation.windows.overlay.add_image("S4.png")
    rankrevealer.SE = constellation.windows.overlay.add_image("SE.png")
    rankrevealer.SEM = constellation.windows.overlay.add_image("SEM.png")
    rankrevealer.GN1 = constellation.windows.overlay.add_image("GN1.png")
    rankrevealer.GN2 = constellation.windows.overlay.add_image("GN2.png")
    rankrevealer.GN3 = constellation.windows.overlay.add_image("GN3.png")
    rankrevealer.GNM = constellation.windows.overlay.add_image("GNM.png")
    rankrevealer.MG1 = constellation.windows.overlay.add_image("MG1.png")
    rankrevealer.MG2 = constellation.windows.overlay.add_image("MG2.png")
    rankrevealer.MGE = constellation.windows.overlay.add_image("MGE.png")
    rankrevealer.DMG = constellation.windows.overlay.add_image("DMG.png")
    rankrevealer.LE = constellation.windows.overlay.add_image("LE.png")
    rankrevealer.LEM = constellation.windows.overlay.add_image("LEM.png")
    rankrevealer.SMFC = constellation.windows.overlay.add_image("SMFC.png")
    rankrevealer.GE = constellation.windows.overlay.add_image("GE.png")

    -- menu options
    constellation.vars.menu(
        "Enable Rank Revealer", -- label name
        "rankrevealer_enabled", -- fantasyvar
        "<input name='rankrevealer_enabled' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", -- html content
        true-- value
    )

    constellation.vars.menu(
        "Rank Reveal Key", -- label name
        "rankreveal_key", -- fantasyvar
        "<input name='rankreveal_key' type='number' onchange=\"fantasy_cmd(this, 'set')\"   />", -- html content
        9-- value
    )

    constellation.vars.menu(
        "Rank Revealer X",
        "rankrevealer_x",
        "<input name='rankrevealer_x' type='number' onchange=\"fantasy_cmd(this, 'set')\" />",
        10
    )

    constellation.vars.menu(
        "Rank Revealer Y",
        "rankrevealer_y",
        "<input name='rankrevealer_y' type='number' onchange=\"fantasy_cmd(this, 'set')\" />",
        400
    )

    rankrevealer.font = constellation.windows.overlay.imgui.add_font("OpenSans-SemiBold", 20)
end

function rankrevealer.OnConstellationCalibrated()
    -- Competitive Ranks Table
    rankrevealer.p_ranks = { rankrevealer.Unranked, rankrevealer.S1, rankrevealer.S2, rankrevealer.S3, rankrevealer.S4,
        rankrevealer.SE, rankrevealer.SEM, rankrevealer.GN1, rankrevealer.GN2, rankrevealer.GN3, rankrevealer.GNM,
        rankrevealer.MG1, rankrevealer.MG2, rankrevealer.MGE, rankrevealer.DMG, rankrevealer.LE, rankrevealer.LEM,
        rankrevealer.SMFC, rankrevealer.GE }
    rankrevealer.m_iCompetitiveWins = constellation.memory.netvar("DT_CSPlayerResource", "m_iCompetitiveWins")
    rankrevealer.m_iCompetitiveRanking = constellation.memory.netvar("DT_CSPlayerResource", "m_iCompetitiveRanking")
end

function rankrevealer.OnConstellationTick(localplayer, localweapon, viewangles)
    if localplayer == nil then return end

    -- FantasyVars
    rankrevealer.enabled = constellation.vars.get("rankrevealer_enabled")
    rankrevealer.playerResource = constellation.memory.read_integer(rankrevealer.client_address +
        rankrevealer.dwPlayerResource) -- get playerResource

    rankrevealer.localplayer_information = constellation.game.get_player(localplayer)

    rankrevealer.player_information = {}

    local players = constellation.game.get_players()

    table.sort(players, function(a, b)
        return a.team > b.team
    end)

    for _, player in pairs(players) do
        rankrevealer.add_player(rankrevealer, rankrevealer.playerResource, player, rankrevealer.m_iCompetitiveRanking,
            rankrevealer.m_iCompetitiveWins)
    end
end

function rankrevealer.OnOverlayRender(width, height, center_x, center_y)
    if rankrevealer.enabled == 0 then return end

    -- push the font
    constellation.windows.overlay.imgui.push_font(rankrevealer.font)

    if constellation.windows.key(constellation.vars.get("rankreveal_key")) then
        -- set the starting position for the Window.
        constellation.windows.overlay.imgui.set_next_size(250, 305)
        constellation.windows.overlay.imgui.set_next_position(constellation.vars.get("rankrevealer_x"),
            constellation.vars.get("rankrevealer_y"))

        constellation.windows.overlay.imgui.window("##rankrevealer",
            bit.bor(ImGuiWindowFlags_NoTitleBar, ImGuiWindowFlags_NoNavInputs, ImGuiWindowFlags_NoBringToFrontOnFocus,
                ImGuiWindowFlags_NoNavFocus, ImGuiWindowFlags_NoFocusOnAppearing, ImGuiWindowFlags_AlwaysAutoResize,
                ImGuiWindowFlags_NoSavedSettings, ImGuiWindowFlags_NoCollapse, ImGuiWindowFlags_NoMove))

        for _, player in pairs(rankrevealer.player_information) do
            constellation.windows.overlay.imgui.image(rankrevealer.p_ranks[player["rank"] + 1], 64, 25)
            constellation.windows.overlay.imgui.same_line(80, 5)

            if rankrevealer.localplayer_information["team"] ~= player["team"] then
                constellation.windows.overlay.imgui.text(player["name"], 255, 0, 0, 255)
            else
                constellation.windows.overlay.imgui.text(player["name"], 0, 102, 255, 255)
            end

            constellation.windows.overlay.imgui.same_line(175, 0)
            constellation.windows.overlay.imgui.text("Wins: " .. player["wins"], 255, 255, 255, 255)
        end
    end
    constellation.windows.overlay.imgui.end_window()
end

return rankrevealer
