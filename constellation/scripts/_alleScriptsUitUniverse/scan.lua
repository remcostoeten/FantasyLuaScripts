--[[
    @Patch Notes:
        - 4 months ago: "Fixed an issue where the injured health stick figure man will appear even when health is toggled off."
        - 4 months ago: "Fixed "Scan ESP started" notification not appearing due to a missing argument."
        - 4 months ago: "Fixed an issue where BSP Parsing will delay if you lose visibility. Weapon ESP added. Bone Focus Added. Notification now appears once loaded."
        - 4 months ago: "Fixed an issue where trace_ray was used incorrectly. FOV scanning now available for CS:GO (not only TF2). FOV scanning can now be changed."
        - 4 months ago: "Adding TF2 Building Support. Fixed m_iHealth error if OnConstellationTick called before calibration."
        - 4 months ago: "Added Visibility Check (BSP TraceRay) to Prevent Scanning Through Certain Objects."
--]]

--[[
    @title
        Scan ESP
    @author
        typedef
    @notes
        this was originally supposed be a Cyberpunk 2077 style ESP. it turned out
        to be a in crosshair ESP. 

--]]
local scan_esp =
{
    -- resources directory
    directory = constellation.vars.get("directory") .. "constellation\\resources\\scan_esp\\",

    -- https://github.com/frk1/hazedumper/blob/1bd37ca0a1f79042ca83dda8a3301019b3421e5c/config.json#L737
    m_iCrosshairID = nil,

    -- https://github.com/frk1/hazedumper/blob/1bd37ca0a1f79042ca83dda8a3301019b3421e5c/config.json#L759
    m_iHealth = nil,

    -- DT_BaseEntity -> m_iTeamNum
    m_iTeamNum = nil,

    -- the entity we will show scan results.
    entity = nil,

    -- flag for if the csgo font is installed.
    weapon_font_installed = false,

    -- calibrated game
    game = GAME_NONE,

    -- image data
    images =
    {
        healthy = nil,
        hurt = nil,
        sentry = nil,
        dispenser = nil,
        teleporter = nil,

        healthy_url = "https://i.imgur.com/HaKcQps.png",
        hurt_url = "https://i.imgur.com/9ZoZ96a.png",
        sentry_url = "https://wiki.teamfortress.com/w/images/thumb/7/78/RED_Level_3_Sentry_Gun.png/529px-RED_Level_3_Sentry_Gun.png",
        dispenser_url = "https://wiki.teamfortress.com/w/images/1/1a/Lvl3dispenser.png",
        teleporter_url = "https://developer.valvesoftware.com/w/images/3/3e/TF2_Teleporter.PNG",
    },

    -- menu options
    menu =
    {
        enabled = nil,
        ff = nil,
        head = nil,
        tracer = nil,
        snapline = nil,
        health = nil,
        buildings = nil,
        fov_csgo = nil,
        fov = nil,
        bone = nil,
        weapon = nil,

        color_box = nil,
        color_tracer = nil,
        color_snapline = nil,
        color_alpha = nil,

        image_size = nil,
    },

    -- entity classes
    classes =
    {
        dispenser = 86,
        sentry = 88,
        teleporter = 89,
    },
}

-- from weapon_esp.lua by Moyo.
local weapon_to_key_ammo = {
    [1] = { "!", 7 }, -- WEAPON_DEAGLE = 1
    [2] = { "\"", 30 }, -- WEAPON_ELITE = 2
    [3] = { "#", 20 }, -- WEAPON_FIVESEVEN = 3
    [4] = { "$", 20 }, -- WEAPON_GLOCK = 4
    [7] = { "%", 30 }, -- WEAPON_AK47 = 7
    [8] = { "&", 30 }, -- WEAPON_AUG = 8
    [9] = { "'", 10 }, -- WEAPON_AWP = 9
    [10] = { "(", 25 }, -- WEAPON_FAMAS = 10
    [11] = { ")", 20 }, -- WEAPON_G3SG1 = 11
    [13] = { "*", 35 }, -- WEAPON_GALILAR = 13
    [14] = { "H", 100 }, -- WEAPON_M249 = 14
    [16] = { "+", 30 }, -- WEAPON_M4A1 = 16
    [17] = { "-", 30 }, -- WEAPON_MAC10 = 17
    [19] = { ";", 50 }, -- WEAPON_P90 = 19
    [23] = { "\\", 30 }, -- WEAPON_MP5SD = 23
    [24] = { "/", 25 }, -- WEAPON_UMP45 = 24
    [25] = { "0", 7 }, -- WEAPON_XM1014 = 25
    [26] = { "1", 64 }, -- WEAPON_BIZON = 26
    [27] = { "2", 5 }, -- WEAPON_MAG7 = 27
    [28] = { "3", 150 }, -- WEAPON_NEGEV = 28
    [29] = { "4", 7 }, -- WEAPON_SAWEDOFF = 29
    [30] = { "5", 18 }, -- WEAPON_TEC9 = 30
    [31] = { "6", 1 }, -- WEAPON_TASER = 31
    [32] = { "7", 13 }, -- WEAPON_HKP2000 = 32
    [33] = { "8", 30 }, -- WEAPON_MP7 = 33
    [34] = { "9", 30 }, -- WEAPON_MP9 = 34
    [35] = { ":", 8 }, -- WEAPON_NOVA = 35
    [36] = { ".", 13 }, -- WEAPON_P250 = 36
    [37] = { "shield", 0 }, -- WEAPON_SHIELD = 37 -> there's no icon for the shield
    [38] = { "<", 20 }, -- WEAPON_SCAR20 = 38
    [39] = { "=", 30 }, -- WEAPON_SG556 = 39
    [40] = { ">", 10 }, -- WEAPON_SSG08 = 40
    [43] = { "@", 1 }, -- WEAPON_FLASHBANG = 43
    [44] = { "A", 1 }, -- WEAPON_HEGRENADE = 44
    [45] = { "B", 1 }, -- WEAPON_SMOKEGRENADE = 45
    [46] = { "C", 1 }, -- WEAPON_MOLOTOV = 46
    [47] = { "D", 1 }, -- WEAPON_DECOY = 47
    [48] = { "E", 1 }, -- WEAPON_INCGRENADE = 48
    [49] = { "F", 0 }, -- WEAPON_C4 = 49
    [60] = { ",", 25 }, -- WEAPON_M4A1_SILENCER = 60
    [61] = { "I", 12 }, -- WEAPON_USP_SILENCER = 61
    [63] = { "J", 12 }, -- WEAPON_CZ75A = 63
    [64] = { "K", 8 }, -- WEAPON_REVOLVER = 64
    [70] = { "F", 0 }, -- WEAPON_BREACHCHARGE = 70
    [75] = { "[", 0 }, -- WEAPON_AXE = 75
    [76] = { "Y", 0 }, -- WEAPON_HAMMER = 76
    [78] = { "Z", 0 } -- WEAPON_SPANNER = 78
}

function scan_esp.Initialize(game_id)

    -- no dota.
    if game_id == GAME_DOTA2 then return false end

    -- set game id so we can access this later without calling constellation.get_game
    scan_esp.game = game_id

    -- menu options
    scan_esp.menu.enabled = constellation.vars.menu("Scan ESP [Enabled]", "scan_esp",
        "<input name='scan_esp' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    scan_esp.menu.ff = constellation.vars.menu("Scan ESP [FF]", "scan_esp_ff",
        "<input name='scan_esp_ff' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", false)
    scan_esp.menu.head = constellation.vars.menu("Scan ESP [Head Box]", "scan_esp_head",
        "<input name='scan_esp_head' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    scan_esp.menu.tracer = constellation.vars.menu("Scan ESP [Box Tracer]", "scan_esp_box_tracer",
        "<input name='scan_esp_box_tracer' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    scan_esp.menu.snapline = constellation.vars.menu("Scan ESP [Snapline]", "scan_esp_snapline",
        "<input name='scan_esp_snapline' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", false)
    scan_esp.menu.health = constellation.vars.menu("Scan ESP [Health]", "scan_esp_health",
        "<input name='scan_esp_health' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    scan_esp.menu.weapon = constellation.vars.menu("Scan ESP [Weapon (CS:GO Only)]", "scan_esp_weapon",
        "<input name='scan_esp_weapon' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    scan_esp.menu.fov_csgo = constellation.vars.menu("Scan ESP [FOV Scanning for CS:GO]", "scan_esp_fov_csgo",
        "<input name='scan_esp_fov_csgo' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", false)
    scan_esp.menu.buildings = constellation.vars.menu("Scan ESP [Buildings (TF2 Only)]", "scan_esp_buildings",
        "<input name='scan_esp_buildings' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    scan_esp.menu.color_box = constellation.vars.menu("Scan ESP [Color Head Box]", "scan_esp_color_box",
        "<input name='scan_esp_color_box' type='color' onchange=\"fantasy_cmd(this, 'set')\"   />", "FF0000")
    scan_esp.menu.color_tracer = constellation.vars.menu("Scan ESP [Color Box Tracer]", "scan_esp_color_box_tracer",
        "<input name='scan_esp_color_box_tracer' type='color' onchange=\"fantasy_cmd(this, 'set')\"   />", "0000FF")
    scan_esp.menu.color_snapline = constellation.vars.menu("Scan ESP [Color Snapline]", "scan_esp_color_snapline",
        "<input name='scan_esp_color_snapline' type='color' onchange=\"fantasy_cmd(this, 'set')\"   />", "FF0000")
    scan_esp.menu.color_alpha = constellation.vars.menu("Scan ESP [Color Alpha]", "scan_esp_color_alpha",
        "<input name='scan_esp_color_alpha' type='number' onchange=\"fantasy_cmd(this, 'set')\"   />", 100)
    scan_esp.menu.image_size = constellation.vars.menu("Scan ESP [Health Image Size]", "scan_esp_image_size",
        "<input name='scan_esp_image_size' type='number' onchange=\"fantasy_cmd(this, 'set')\"   />", 20)
    scan_esp.menu.fov = constellation.vars.menu("Scan ESP [FOV Scanning Range]", "scan_esp_fov",
        "<input name='scan_esp_fov' type='number' onchange=\"fantasy_cmd(this, 'set')\"   />", 5.5)
    scan_esp.menu.bone = constellation.vars.menu("Scan ESP [Bone (Not Eyes)]", "scan_esp_bone",
        "<input name='scan_esp_bone' type='number' onchange=\"fantasy_cmd(this, 'set')\"   />", -1)

    -- create overlay.
    constellation.windows.overlay.create("Valve001", "")
    scan_esp.weapon_font_installed = constellation.windows.overlay.add_font("csgo_icons_scan", "csgo_icons", 16,
        DWRITE_FONT_WEIGHT_NORMAL, DWRITE_FONT_STRETCH_NORMAL)

    if not scan_esp.weapon_font_installed then
        constellation.log("CSGO icon font not installed! Downloading font file to \"" ..
            constellation.vars.get("directory") .. "constellation\\csgo_icons.ttf\"")
        constellation.log("Scanner ESP will not work until the font is installed.")
        constellation.http.download_file("https://fantasy.cat/constellation/csgo_icons.ttf",
            constellation.vars.get("directory") .. "constellation\\csgo_icons.ttf")
    end

    -- create directory
    constellation.windows.file.create_directory(scan_esp.directory)

    -- download images
    constellation.http.download_file(scan_esp.images.healthy_url, scan_esp.directory .. "healthy.png")
    constellation.http.download_file(scan_esp.images.hurt_url, scan_esp.directory .. "hurt.png")
    constellation.http.download_file(scan_esp.images.sentry_url, scan_esp.directory .. "sentry.png")
    constellation.http.download_file(scan_esp.images.dispenser_url, scan_esp.directory .. "dispenser.png")
    constellation.http.download_file(scan_esp.images.teleporter_url, scan_esp.directory .. "teleporter.png")

    -- check if images downloaded correctly.
    if not constellation.windows.file.exists(scan_esp.directory .. "healthy.png") or
        not constellation.windows.file.exists(scan_esp.directory .. "hurt.png")
        or not constellation.windows.file.exists(scan_esp.directory .. "sentry.png") or
        not constellation.windows.file.exists(scan_esp.directory .. "dispenser.png")
        or not constellation.windows.file.exists(scan_esp.directory .. "teleporter.png") then
        constellation.log("Images failed to download.")
        return false
    end

    -- load images to Constellation memory.
    scan_esp.images.healthy = constellation.windows.overlay.add_image("scan_esp\\healthy.png")
    scan_esp.images.hurt = constellation.windows.overlay.add_image("scan_esp\\hurt.png")
    scan_esp.images.sentry = constellation.windows.overlay.add_image("scan_esp\\sentry.png")
    scan_esp.images.dispenser = constellation.windows.overlay.add_image("scan_esp\\dispenser.png")
    scan_esp.images.teleporter = constellation.windows.overlay.add_image("scan_esp\\teleporter.png")

    -- check if images loaded correctly.
    if not scan_esp.images.healthy or not scan_esp.images.hurt or not scan_esp.images.sentry or
        not scan_esp.images.dispenser or not scan_esp.images.teleporter then
        constellation.log("Images failed to load.")
        return false
    end

    -- notification
    constellation.windows.overlay.notification("Scan ESP started.")
end

function scan_esp.OnConstellationCalibrated(game_id)

    -- CS:GO has m_iCrosshairID to help check if our crosshair is on an enemy. (doesn't work long distances)
    if game_id == GAME_CSGO then
        scan_esp.m_iCrosshairID = constellation.memory.netvar("DT_CSPlayer", "m_bHasDefuser") + 92
    end

    scan_esp.m_iHealth = constellation.memory.netvar("DT_BasePlayer", "m_iHealth")
    scan_esp.m_iTeamNum = constellation.memory.netvar("DT_BasePlayer", "m_iTeamNum")
end

function scan_esp.OnConstellationTick(localplayer)

    -- netvars aren't ready yet.
    if not scan_esp.m_iHealth or not scan_esp.m_iTeamNum then return end

    -- is this script for CS:GO?
    if scan_esp.game == GAME_CSGO then

        -- netvar isn't set yet.
        if not scan_esp.m_iCrosshairID then return end
    end

    -- reset always
    scan_esp.entity = nil

    -- not ingame.
    if not localplayer then return end

    -- not enabled.
    if not constellation.vars.get(scan_esp.menu.enabled) then return end

    -- our found entity
    local entity_information = nil

    -- friendly fire var
    local ff = constellation.vars.get(scan_esp.menu.ff)

    -- get player information
    local player_information = constellation.game.get_player(localplayer)
    if not player_information then return end

    -- CS:GO version.
    if scan_esp.game == GAME_CSGO then

        if not constellation.vars.get(scan_esp.menu.fov_csgo) then
            -- entity in our crosshair index.
            local entity_index = constellation.memory.read(localplayer + scan_esp.m_iCrosshairID)

            -- we found somebody.
            if entity_index > 0 and entity_index < 32 then
                -- get the entity
                entity_information = constellation.game.get_player(entity_index)
            end
        else
            entity_information = constellation.game.get_closest_player_fov(ff, 7,
                constellation.vars.get(scan_esp.menu.fov))
        end
        -- TF2 version.
    elseif scan_esp.game == GAME_TF2 then

        local fov = constellation.vars.get(scan_esp.menu.fov)

        entity_information = constellation.game.get_closest_player_fov(ff, 7, fov)

        if constellation.vars.get(scan_esp.menu.buildings) == 1 then

            local all_buildings = {}
            table.insert(all_buildings, constellation.game.get_entity_from_class(scan_esp.classes.dispenser))
            table.insert(all_buildings, constellation.game.get_entity_from_class(scan_esp.classes.sentry))
            table.insert(all_buildings, constellation.game.get_entity_from_class(scan_esp.classes.teleporter))

            -- loop through all sentries
            for _, table_entity in pairs(all_buildings) do

                for _, entity in pairs(table_entity) do

                    -- is in fov?
                    if constellation.game.is_in_fov(entity, fov) then

                        -- set our entity
                        entity_information = entity

                        -- set table values as if it was a player.
                        entity_information["eye_position"] = entity_information["origin"]
                        entity_information["team"] = constellation.memory.read(entity["address"] + scan_esp.m_iTeamNum)
                        entity_information["building"] = true
                    end

                end

            end
        end
    end

    -- we didn't find anyone.
    if entity_information == nil then
        -- nil our entity because our crosshair isn't on anyone.
        scan_esp.entity = nil
        return
    end

    -- visibility check
    constellation.game.bsp.parse()

    if not constellation.game.bsp.trace_ray(
        player_information["origin"]["x"], player_information["origin"]["y"], player_information["origin"]["z"],
        entity_information["origin"]["x"], entity_information["origin"]["y"], entity_information["origin"]["z"]
    ) then return false end

    -- team check
    if (ff == 0 and entity_information["team"] ~= player_information["team"]) or (ff == 1) then

        -- bone var
        local bone = constellation.vars.get(scan_esp.menu.bone)

        -- w2s
        local position = entity_information["eye_position"]

        if bone ~= -1 then -- if bone setting is -1, then stick with eye position.
            local x, y, z = entity_information:get_bone_position(bone)
            position["x"] = x
            position["y"] = y
            position["z"] = z
        end

        local x, y = constellation.game.world_to_screen(
            position["x"],
            position["y"],
            position["z"]
        )

        -- invalid w2s
        if not x or not y then return end

        -- set w2s
        entity_information["x"] = x
        entity_information["y"] = y

        -- get health
        if not entity_information["building"] then
            entity_information["health"] = constellation.memory.read(entity_information["address"] + scan_esp.m_iHealth)
        end

        -- get weapon
        if scan_esp.weapon_font_installed and constellation.vars.get(scan_esp.menu.weapon) then

            -- csgo only
            if scan_esp.game == GAME_CSGO then
                local weapon_information = constellation.game.get_weapon(entity_information["weapon"])
                if weapon_information ~= nil then
                    entity_information["weapon_id"] = weapon_information["id"]
                end
            end

        end

        -- set scanned entity.
        scan_esp.entity = entity_information
    end
end

function scan_esp.OnOverlayRender(w, h, cx, cy)

    -- not enabled.
    if not constellation.vars.get(scan_esp.menu.enabled) then return end

    -- we don't have an entity.
    if scan_esp.entity == nil then return end

    -- is it a building? check if enabled.
    if not constellation.vars.get(scan_esp.menu.buildings) and scan_esp.entity["building"] then return end

    -- create color t able.
    local color = { a = constellation.vars.get(scan_esp.menu.color_alpha) }

    -- draw boxes
    if constellation.vars.get(scan_esp.menu.head) == 1 then
        color.r, color.g, color.b = constellation.vars.get_color(scan_esp.menu.color_box)
        constellation.windows.overlay.box_filled(scan_esp.entity["x"] - 5, scan_esp.entity["y"] - 5, 10, 10, color)
    end

    if constellation.vars.get(scan_esp.menu.tracer) == 1 then
        color.r, color.g, color.b = constellation.vars.get_color(scan_esp.menu.color_tracer)
        constellation.windows.overlay.box_filled(cx - 5, cy - 5, 10, 10, color)
    end

    -- snaplines
    if constellation.vars.get(scan_esp.menu.snapline) == 1 then
        color.r, color.g, color.b = constellation.vars.get_color(scan_esp.menu.color_snapline)
        constellation.windows.overlay.line(cx, h, scan_esp.entity["x"], scan_esp.entity["y"], color, 1)
    end

    -- images
    local x = scan_esp.entity["x"] + 20
    local y = scan_esp.entity["y"] - 3
    local size = constellation.vars.get(scan_esp.menu.image_size)

    if not scan_esp.entity["building"] then

        if constellation.vars.get(scan_esp.menu.health) == 1 then
            if scan_esp.entity["health"] > 50 then
                constellation.windows.overlay.image(scan_esp.images.healthy, x, y, x + size - 5, y + size)
            else
                constellation.windows.overlay.image(scan_esp.images.hurt, x, y, x + size - 5, y + size)
            end

        end
    else
        if scan_esp.entity["class"] == scan_esp.classes.sentry then
            constellation.windows.overlay.image(scan_esp.images.sentry, x, y, x + size - 5, y + size)
        elseif scan_esp.entity["class"] == scan_esp.classes.dispenser then
            constellation.windows.overlay.image(scan_esp.images.dispenser, x, y, x + size - 5, y + size)
        elseif scan_esp.entity["class"] == scan_esp.classes.teleporter then
            constellation.windows.overlay.image(scan_esp.images.teleporter, x, y, x + size - 5, y + size)
        end
    end

    -- weapon font
    if scan_esp.entity["weapon_id"] ~= nil then

        -- weapon doesn't have an icon (knife probably).
        if not weapon_to_key_ammo[scan_esp.entity["weapon_id"]] then return end

        local x = scan_esp.entity["x"] + 20
        local y = scan_esp.entity["y"] + 55

        constellation.windows.overlay.text(weapon_to_key_ammo[scan_esp.entity["weapon_id"]][1], "csgo_icons_scan", x, y,
            { r = 255, g = 255, b = 255, a = color.a })
    end
end

return scan_esp
