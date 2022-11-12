--[[
    @Patch Notes:
        - 5 months ago: "Renamed script, changed to only show ESP during Humanizer usage. Name changed to focus_box_advanced.lua"
        - 5 months ago: "added boneESP and headdot"
--]]

--[[
    @title
        focus_box_advanced

    @author
        Moyo
        typedef (humanizer edit)

    @description
        On-Key ESP
        CSGO only
--]]
local focus_box_advanced = {
    enabled = nil,
    drawHeadDot = nil,
    drawBones = nil,
    drawBox = nil,
    drawCornersOnly = nil,
    drawSnaplines = nil,

    playerArray = {},
    boneIDs = {
        {
            ["bones"] = { 0, 6, 7, 8, 11, 12, 13, 40, 41, 42, 73, 74, 82, 83 },
            ["pairs"] = {
                { 83, 82 },
                { 82, 0 },
                { 0, 73 },
                { 73, 74 },

                { 0, 6 },
                { 6, 7 },
                { 7, 8 },

                { 7, 11 },
                { 11, 12 },
                { 12, 13 },

                { 7, 40 },
                { 40, 41 },
                { 41, 42 }
            }
        },
        {
            ["bones"] = { 0, 6, 7, 8, 10, 11, 12, 38, 39, 40, 66, 67, 73, 74 },
            ["pairs"] = {
                { 67, 66 },
                { 66, 0 },
                { 0, 73 },
                { 73, 74 },

                { 0, 6 },
                { 6, 7 },
                { 7, 8 },

                { 7, 10 },
                { 10, 11 },
                { 11, 12 },

                { 7, 38 },
                { 38, 39 },
                { 39, 40 }
            }
        },
        {
            ["bones"] = { 0, 6, 7, 8, 12, 13, 14, 40, 41, 42, 68, 69, 75, 76 },
            ["pairs"] = {
                { 69, 68 },
                { 68, 0 },
                { 0, 75 },
                { 75, 76 },

                { 0, 6 },
                { 6, 7 },
                { 7, 8 },

                { 7, 12 },
                { 12, 13 },
                { 13, 14 },

                { 7, 40 },
                { 40, 41 },
                { 41, 42 }
            }
        },
        {
            ["bones"] = { 0, 6, 7, 8, 11, 12, 13, 40, 41, 42, 70, 71, 77, 78 },
            ["pairs"] = {
                { 71, 70 },
                { 70, 0 },
                { 0, 77 },
                { 77, 78 },

                { 0, 6 },
                { 6, 7 },
                { 7, 8 },

                { 7, 11 },
                { 11, 12 },
                { 12, 13 },

                { 7, 40 },
                { 40, 41 },
                { 41, 42 }
            }
        },
        {
            ["bones"] = { 0, 6, 7, 8, 11, 12, 13, 41, 42, 43, 71, 72, 78, 79 },
            ["pairs"] = {
                { 72, 71 },
                { 71, 0 },
                { 0, 78 },
                { 78, 79 },

                { 0, 6 },
                { 6, 7 },
                { 7, 8 },

                { 7, 11 },
                { 11, 12 },
                { 12, 13 },

                { 7, 41 },
                { 41, 42 },
                { 42, 43 }
            }
        },
        {
            ["bones"] = { 0, 6, 7, 8, 11, 12, 13, 39, 40, 41, 67, 68, 74, 75 },
            ["pairs"] = {
                { 75, 74 },
                { 74, 0 },
                { 0, 67 },
                { 67, 68 },

                { 0, 6 },
                { 6, 7 },
                { 7, 8 },

                { 7, 11 },
                { 11, 12 },
                { 12, 13 },

                { 7, 39 },
                { 39, 40 },
                { 40, 41 }
            }
        },
        {
            ["bones"] = { 0, 6, 7, 8, 11, 12, 13, 39, 40, 41, 72, 73, 81, 82 },
            ["pairs"] = {
                { 73, 72 },
                { 72, 0 },
                { 0, 81 },
                { 81, 82 },

                { 0, 6 },
                { 6, 7 },
                { 7, 8 },

                { 7, 11 },
                { 11, 12 },
                { 12, 13 },

                { 7, 39 },
                { 39, 40 },
                { 40, 41 }
            }
        },
        {
            ["bones"] = { 0, 6, 7, 8, 11, 12, 13, 39, 40, 41, 71, 72, 78, 79 },
            ["pairs"] = {
                { 72, 71 },
                { 71, 0 },
                { 0, 78 },
                { 78, 79 },

                { 0, 6 },
                { 6, 7 },
                { 7, 8 },

                { 7, 11 },
                { 11, 12 },
                { 12, 13 },

                { 7, 39 },
                { 39, 40 },
                { 40, 41 }
            }
        },
        {
            ["bones"] = { 0, 6, 7, 8, 12, 13, 14, 40, 41, 42, 67, 68, 74, 75 },
            ["pairs"] = {
                { 68, 67 },
                { 67, 0 },
                { 0, 74 },
                { 74, 75 },

                { 0, 6 },
                { 6, 7 },
                { 7, 8 },

                { 7, 12 },
                { 12, 13 },
                { 13, 14 },

                { 7, 40 },
                { 40, 41 },
                { 41, 42 }
            }
        },
        {
            ["bones"] = { 0, 6, 7, 8, 11, 12, 13, 39, 40, 41, 72, 73, 80, 81 },
            ["pairs"] = {
                { 73, 72 },
                { 72, 0 },
                { 0, 80 },
                { 80, 81 },

                { 0, 6 },
                { 6, 7 },
                { 7, 8 },

                { 7, 11 },
                { 11, 12 },
                { 12, 13 },

                { 7, 39 },
                { 39, 40 },
                { 40, 41 }
            }
        },
    },

    -- ESP colors
    esp_colorR = 0,
    esp_colorG = 0,
    esp_colorB = 0,

    -- bone ESP colors
    bone_colorR = 0,
    bone_colorG = 0,
    bone_colorB = 0,

    -- netvars
    m_iHealth = nil,
    m_dwBoneMatrix = nil,
    m_iItemDefinitionIndex = nil
}

local weaponInfo = {
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

function focus_box_advanced.Initialize(game_id)
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

    constellation.vars.menu(
        "enable ESP",
        "esp_enabled",
        "<input name='esp_enabled' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        true
    )

    constellation.vars.menu(
        "draw headdot",
        "esp_drawHeadDot",
        "<input name='esp_drawHeadDot' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        false
    )

    constellation.vars.menu(
        "draw Bone ESP",
        "esp_boneESP",
        "<input name='esp_boneESP' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        true
    )

    constellation.vars.menu(
        "draw ESP Box",
        "esp_drawBox",
        "<input name='esp_drawBox' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        true
    )

    constellation.vars.menu(
        "draw ESP Box Corners Only",
        "esp_drawBoxCorners",
        "<input name='esp_drawBoxCorners' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        false
    )

    constellation.vars.menu(
        "draw snaplines",
        "esp_drawSnaplines",
        "<input name='esp_drawSnaplines' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        false
    )

    constellation.vars.menu(
        "ESP color",
        "esp_color",
        "<input name='esp_color' type='color' onchange=\"fantasy_cmd(this, 'set')\" />",
        "FFFFFF"
    )

    constellation.vars.menu(
        "Bone ESP color",
        "esp_boneColor",
        "<input name='esp_boneColor' type='color' onchange=\"fantasy_cmd(this, 'set')\" />",
        "FFFFFF"
    )

    constellation.windows.overlay.add_font(
        "Consolas Medium",
        "Consolas",
        14,
        600,
        DWRITE_FONT_STRETCH_NORMAL
    )

    local fontInstalled = constellation.windows.overlay.add_font(
        "csgo_icons",
        "csgo_icons",
        20,
        DWRITE_FONT_WEIGHT_NORMAL,
        DWRITE_FONT_STRETCH_NORMAL
    )

    if fontInstalled == false then
        constellation.log("CSGO weapon icon font not installed! Downloading font file to \"" ..
            constellation.vars.get("directory") .. "constellation\\csgo_icons.ttf\"")
        constellation.http.download_file("https://fantasy.cat/constellation/csgo_icons.ttf",
            constellation.vars.get("directory") .. "constellation\\csgo_icons.ttf")
        return false
    end
end

function focus_box_advanced.OnConstellationCalibrated()
    focus_box_advanced.m_iHealth = constellation.memory.netvar("DT_BasePlayer", "m_iHealth")
    focus_box_advanced.m_dwBoneMatrix = constellation.memory.netvar("DT_BaseAnimating", "m_nForceBone") + 28
    focus_box_advanced.m_iItemDefinitionIndex = constellation.memory.netvar("DT_BaseCombatWeapon",
        "m_iItemDefinitionIndex")
end

function focus_box_advanced.OnHumanizerTarget(localplayer, localweapon, enemy)

    local player = constellation.game.get_player(enemy)
    if not player then return end

    if player["dormant"] == false and player["is_alive"] == true and player["address"] ~= localplayer then
        local dimensions = constellation.game.get_box_dimensions(player)

        local dwBoneMatrix = constellation.memory.read_integer(player["address"] + focus_box_advanced.m_dwBoneMatrix)
        local health = constellation.memory.read_integer(player["address"] + focus_box_advanced.m_iHealth)

        local weapID = constellation.memory.read_short(player["weapon"] + focus_box_advanced.m_iItemDefinitionIndex)
        local weaponText = ""
        if weaponInfo[weapID] ~= nil then
            weaponText = weaponInfo[weapID][1]
        end

        local boneList = {}
        local boneIDs = {}
        local bonePairs = {}
        local bones = {}

        -- get player model name
        local modelName = constellation.memory.read_string(constellation.memory.read(player["address"] + 0x6C) + 4) -- string starts after 4 bytes
        local index = nil
        if string.find(modelName, "ctm_sas") then
            index = 1
        elseif string.find(modelName, "tm_separ") or string.find(modelName, "tm_phoenix") or
            string.find(modelName, "ctm_st6") or string.find(modelName, "ctm_gsg9") then
            index = 2
        elseif string.find(modelName, "tm_anar") or
            string.find(modelName, "ctm_swat") and not string.find(modelName, "swat_variantB") then
            index = 3
        elseif string.find(modelName, "ctm_gign") then
            index = 4
        elseif string.find(modelName, "ctm_idf") then
            index = 5
        elseif string.find(modelName, "tm_leet") then
            index = 6
        elseif string.find(modelName, "ctm_fbi") and not string.find(modelName, "fbi_variantE") then
            index = 7
        elseif string.find(modelName, "tm_professional") then
            index = 8
        elseif string.find(modelName, "ctm_swat_variantB") then
            index = 9
        elseif string.find(modelName, "ctm_fbi_variantE") then
            index = 10
        else
            return
        end
        boneIDs = focus_box_advanced.boneIDs[index]["bones"]
        bonePairs = focus_box_advanced.boneIDs[index]["pairs"]

        -- get bone positions
        for _, boneID in pairs(boneIDs) do
            local boneX = constellation.memory.read_float(dwBoneMatrix + 0x0C + (boneID * 0x30))
            local boneY = constellation.memory.read_float(dwBoneMatrix + 0x1C + (boneID * 0x30))
            local boneZ = constellation.memory.read_float(dwBoneMatrix + 0x2C + (boneID * 0x30))
            local screenX, screenY = constellation.game.world_to_screen(boneX, boneY, boneZ)
            if screenX == nil or screenY == nil then
                return
            end
            bones[boneID] = { x = screenX, y = screenY }
        end

        -- save bone connections
        for _, bonePair in pairs(bonePairs) do
            table.insert(boneList,
                { x1 = bones[bonePair[1]].x, y1 = bones[bonePair[1]].y, x2 = bones[bonePair[2]].x,
                    y2 = bones[bonePair[2]].y })
        end

        -- inserting player information into array
        if boneList[1] ~= nil and dimensions ~= nil then
            focus_box_advanced.playerArray = {
                bones = boneList,
                box = { left = dimensions["left"], top = dimensions["top"], right = dimensions["right"],
                    bottom = dimensions["bottom"] },
                head = { x = bones[8].x, y = bones[8].y, rx = bones[7].x, ry = bones[7].y },
                name = player["name"],
                health = health,
                weaponText = weaponText
            }
        end
    end
    if boneList[1] ~= nil and dimensions ~= nil then
        focus_box_advanced.playerArray = {
            bones = boneList,
            box = { left = dimensions["left"], top = dimensions["top"], right = dimensions["right"],
                bottom = dimensions["bottom"] },
            head = { x = bones[8].x, y = bones[8].y, rx = bones[7].x, ry = bones[7].y },
            name = player["name"],
            health = health,
            weaponText = weaponText
        }
    end

end

function focus_box_advanced.OnConstellationTick(localplayer, localweapon, viewangles)
    if localplayer == nil then return end

    -- get FantasyVars
    focus_box_advanced.enabled = constellation.vars.get("esp_enabled")
    if focus_box_advanced.enabled == 0 then return end
    focus_box_advanced.drawAll = constellation.vars.get("esp_drawAll")
    focus_box_advanced.drawBones = constellation.vars.get("esp_boneESP")
    focus_box_advanced.drawHeadDot = constellation.vars.get("esp_drawHeadDot")
    focus_box_advanced.drawBox = constellation.vars.get("esp_drawBox")
    focus_box_advanced.drawCornersOnly = constellation.vars.get("esp_drawBoxCorners")
    focus_box_advanced.drawSnaplines = constellation.vars.get("esp_drawSnaplines")
    focus_box_advanced.espKey = constellation.vars.get("esp_key")
    if focus_box_advanced.drawBox == 1 then
        focus_box_advanced.esp_colorR, focus_box_advanced.esp_colorG, focus_box_advanced.esp_colorB = constellation.vars
            .get_color("esp_color")
        focus_box_advanced.esp_colorR = focus_box_advanced.esp_colorR / 255
        focus_box_advanced.esp_colorG = focus_box_advanced.esp_colorG / 255
        focus_box_advanced.esp_colorB = focus_box_advanced.esp_colorB / 255
    end
    if focus_box_advanced.drawBones == 1 then
        focus_box_advanced.bone_colorR, focus_box_advanced.bone_colorG, focus_box_advanced.bone_colorB = constellation.vars
            .get_color("esp_boneColor")
        focus_box_advanced.bone_colorR = focus_box_advanced.bone_colorR / 255
        focus_box_advanced.bone_colorG = focus_box_advanced.bone_colorG / 255
        focus_box_advanced.bone_colorB = focus_box_advanced.bone_colorB / 255
    end

    -- reset target
    focus_box_advanced.playerArray = nil
end

function focus_box_advanced.OnOverlayRender(width, height, center_x, center_y)
    if focus_box_advanced.enabled == 0 then return end

    local player = focus_box_advanced.playerArray
    if not player then return end

    -- ESP Box
    if focus_box_advanced.drawBox == 1 then
        if focus_box_advanced.drawCornersOnly == 1 then
            local lineHeight = player.box["bottom"] / 4
            local lineWidth = player.box["right"] / 4
            constellation.windows.overlay.line(player.box["left"], player.box["top"], player.box["left"] + lineWidth,
                player.box["top"],
                { r = focus_box_advanced.esp_colorR, g = focus_box_advanced.esp_colorG, b = focus_box_advanced.esp_colorB,
                    a = 255 }, 2)
            constellation.windows.overlay.line(player.box["left"] + 3 * lineWidth, player.box["top"],
                player.box["left"] + player.box["right"], player.box["top"],
                { r = focus_box_advanced.esp_colorR, g = focus_box_advanced.esp_colorG, b = focus_box_advanced.esp_colorB,
                    a = 255 }, 2)
            constellation.windows.overlay.line(player.box["left"], player.box["top"], player.box["left"],
                player.box["top"] + lineHeight,
                { r = focus_box_advanced.esp_colorR, g = focus_box_advanced.esp_colorG, b = focus_box_advanced.esp_colorB,
                    a = 255 }, 2)
            constellation.windows.overlay.line(player.box["left"], player.box["top"] + 3 * lineHeight,
                player.box["left"
                ], player.box["top"] + player.box["bottom"],
                { r = focus_box_advanced.esp_colorR, g = focus_box_advanced.esp_colorG, b = focus_box_advanced.esp_colorB,
                    a = 255 }, 2)
            constellation.windows.overlay.line(player.box["left"] + player.box["right"], player.box["top"],
                player.box["left"] + player.box["right"], player.box["top"] + lineHeight,
                { r = focus_box_advanced.esp_colorR, g = focus_box_advanced.esp_colorG, b = focus_box_advanced.esp_colorB,
                    a = 255 }, 2)
            constellation.windows.overlay.line(player.box["left"] + player.box["right"],
                player.box["top"] + 3 * lineHeight, player.box["left"] + player.box["right"],
                player.box["top"] + player.box["bottom"],
                { r = focus_box_advanced.esp_colorR, g = focus_box_advanced.esp_colorG, b = focus_box_advanced.esp_colorB,
                    a = 255 }, 2)
            constellation.windows.overlay.line(player.box["left"], player.box["top"] + player.box["bottom"],
                player.box["left"] + lineWidth, player.box["top"] + player.box["bottom"],
                { r = focus_box_advanced.esp_colorR, g = focus_box_advanced.esp_colorG, b = focus_box_advanced.esp_colorB,
                    a = 255 }, 2)
            constellation.windows.overlay.line(player.box["left"] + 3 * lineWidth,
                player.box["top"] + player.box["bottom"], player.box["left"] + player.box["right"],
                player.box["top"] + player.box["bottom"],
                { r = focus_box_advanced.esp_colorR, g = focus_box_advanced.esp_colorG, b = focus_box_advanced.esp_colorB,
                    a = 255 }, 2)
        else
            constellation.windows.overlay.box(player.box["left"], player.box["top"], player.box["right"],
                player.box["bottom"], 1,
                { r = focus_box_advanced.esp_colorR * 255, g = focus_box_advanced.esp_colorG * 255,
                    b = focus_box_advanced.esp_colorB * 255, a = 255 })
        end
    end

    -- Snaplines
    if focus_box_advanced.drawSnaplines == 1 then
        constellation.windows.overlay.line(center_x, height, player.box["left"] + player.box["right"] / 2,
            player.box["top"] + player.box["bottom"],
            { r = focus_box_advanced.esp_colorR, g = focus_box_advanced.esp_colorG, b = focus_box_advanced.esp_colorB,
                a = 1 }, 2)
    end

    -- Player Name
    constellation.windows.overlay.text(player.name, "Consolas Medium", player.box["left"], player.box["top"] - 15,
        { r = 255, g = 255, b = 255, a = 255 })

    -- Health Bar
    local hp_height = player.health / 100 * player.box["bottom"]
    constellation.windows.overlay.box_filled(player.box["left"] - 6, player.box["top"], 4, player.box["bottom"],
        { r = 0, g = 0, b = 0, a = 140 })
    constellation.windows.overlay.box_filled(player.box["left"] - 5, player.box["top"] + player.box["bottom"] - hp_height
        , 2, hp_height, { r = 0, g = 170, b = 0, a = 255 })
    if player.health < 100 then
        constellation.windows.overlay.text(player.health, "Consolas Medium", player.box["left"] - 10,
            player.box["top"] + player.box["bottom"] - hp_height - 10, { r = 255, g = 255, b = 255, a = 255 })
    end

    -- Weapon Icon
    if player.weaponText ~= "" then
        constellation.windows.overlay.text(player.weaponText, "csgo_icons", player.box["left"],
            player.box["top"] + player.box["bottom"] + 5, { r = 255, g = 255, b = 255, a = 255 })
    end

    -- Headdot
    if focus_box_advanced.drawHeadDot == 1 then
        constellation.windows.overlay.box(player.head.x - 1, player.head.y - 1, 2, 2, 1,
            { r = 255, g = 0, b = 0, a = 255 })
    end

    -- Bone ESP
    if focus_box_advanced.drawBones == 1 then
        for _, bone in pairs(player.bones) do
            constellation.windows.overlay.line(bone.x1, bone.y1, bone.x2, bone.y2,
                { r = focus_box_advanced.bone_colorR, g = focus_box_advanced.bone_colorG,
                    b = focus_box_advanced.bone_colorB, a = 255 }, 2)
        end

        -- draw head circle
        -- local rad = math.sqrt((player.head.x - player.head.rx) * (player.head.x - player.head.rx) + (player.head.y - player.head.ry) * (player.head.y - player.head.ry))
        -- constellation.windows.overlay.circle( player.head.x, player.head.y, rad, 20, {r = focus_box_advanced.bone_colorR * 255, g = focus_box_advanced.bone_colorG * 255, b = focus_box_advanced.bone_colorB * 255, a = 255})
    end
end

return focus_box_advanced
