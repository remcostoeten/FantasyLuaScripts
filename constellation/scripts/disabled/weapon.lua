--[[
    @Patch Notes:
        - 4 months ago: "fixed dormant check and added overlay creation feedback messages"
--]]

--[[
    @title
        weapon ESP

    @author
        Moyo

    @description
        drawing dropped weapon icons and ammo info on an overlay
        CSGO only
--]]
local weapon_esp = {
    enabled = nil,
    distanceLimit = nil,
    drawAmmoText = nil,
    drawAmmoBar = nil,

    showGrenades = nil,
    showDangerzoneItems = nil,
    showBomb = nil,

    weaponArray = {},

    -- ESP colors
    colorR = 255,
    colorG = 255,
    colorB = 255,

    -- netvar
    m_iItemDefinitionIndex = nil,
    m_iClip1 = nil,
    m_iPrimaryReserveAmmoCount = nil
}

-- map for all weapons with font letter and maxAmmo
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

function weapon_esp.Initialize(game_id)
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
        "enable weaponESP",
        "weaponesp_enabled",
        "<input name='weaponesp_enabled' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        true
    )

    constellation.vars.menu(
        "show weponESP ammo text",
        "weaponesp_ammotext",
        "<input name='weaponesp_ammotext' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        true
    )

    constellation.vars.menu(
        "show weponESP ammo bar",
        "weaponesp_ammobar",
        "<input name='weaponesp_ammobar' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        true
    )

    constellation.vars.menu(
        "max weaponESP render distance",
        "weaponesp_distance",
        "<input name='weaponesp_distance' type='number' onchange=\"fantasy_cmd(this, 'set')\"   />",
        700
    )

    constellation.vars.menu(
        "weaponESP color",
        "weaponesp_color",
        "<input name='weaponesp_color' type='color' onchange=\"fantasy_cmd(this, 'set')\" />",
        "FFFFFF"
    )

    constellation.vars.menu(
        "show grenades",
        "weaponesp_grenades",
        "<input name='weaponesp_grenades' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        false
    )

    constellation.vars.menu(
        "show danger zone items",
        "weaponesp_dangerzone",
        "<input name='weaponesp_dangerzone' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        false
    )

    constellation.vars.menu(
        "show bomb",
        "weaponesp_bomb",
        "<input name='weaponesp_bomb' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
        false
    )

    local fontInstalled = constellation.windows.overlay.add_font(
        "csgo_icons",
        "csgo_icons",
        20,
        DWRITE_FONT_WEIGHT_NORMAL,
        DWRITE_FONT_STRETCH_NORMAL
    )

    if fontInstalled == false then
        constellation.log("CSGO icon font not installed! Downloading font file to \"" ..
            constellation.vars.get("directory") .. "constellation\\csgo_icons.ttf\"")
        constellation.http.download_file("https://fantasy.cat/constellation/csgo_icons.ttf",
            constellation.vars.get("directory") .. "constellation\\csgo_icons.ttf")
        return false
    end

    constellation.windows.overlay.add_font(
        "Consolas Medium",
        "Consolas",
        16,
        600,
        DWRITE_FONT_STRETCH_NORMAL
    )
end

function weapon_esp.OnConstellationCalibrated()
    weapon_esp.m_iItemDefinitionIndex = constellation.memory.netvar("DT_BaseCombatWeapon", "m_iItemDefinitionIndex")
    weapon_esp.m_iClip1 = constellation.memory.netvar("DT_BaseCombatWeapon", "m_iClip1")
    weapon_esp.m_iPrimaryReserveAmmoCount = constellation.memory.netvar("DT_BaseCombatWeapon",
        "m_iPrimaryReserveAmmoCount")
end

function weapon_esp.OnConstellationTick(localplayer, localweapon, viewangles)
    if localplayer == nil then return end

    local localplayerEnt = constellation.game.get_player(localplayer)
    local weapArray = {}

    -- FantasyVars
    weapon_esp.enabled = constellation.vars.get("weaponesp_enabled")
    weapon_esp.distanceLimit = constellation.vars.get("weaponesp_distance")
    weapon_esp.drawAmmoText = constellation.vars.get("weaponesp_ammotext")
    weapon_esp.drawAmmoBar = constellation.vars.get("weaponesp_ammobar")
    weapon_esp.showGrenades = constellation.vars.get("weaponesp_grenades")
    weapon_esp.showDangerzoneItems = constellation.vars.get("weaponesp_dangerzone")
    weapon_esp.showBomb = constellation.vars.get("weaponesp_bomb")
    weapon_esp.colorR, weapon_esp.colorG, weapon_esp.colorB = constellation.vars.get_color("weaponesp_color")

    for _, ent in pairs(constellation.game.get_all_entities()) do
        if ent ~= nil and ent["is_dormant"] == true and ent["origin"]["x"] ~= 0 and ent["origin"]["y"] ~= 0 and
            ent["origin"]["z"] ~= 0 then
            -- maybe add a check here if the entity type = weapon // check if ClassID matches?

            -- check if entity is in max render distance
            if constellation.math.vector_distance(localplayerEnt["origin"]["x"], localplayerEnt["origin"]["y"],
                localplayerEnt["origin"]["z"], ent["origin"]["x"], ent["origin"]["y"], ent["origin"]["z"]) <
                weapon_esp.distanceLimit then
                local weapID = constellation.memory.read_short(ent["address"] + weapon_esp.m_iItemDefinitionIndex)
                if weaponInfo[weapID] ~= nil then
                    -- check for items to exclude
                    if weapon_esp.showDangerzoneItems == 0 and
                        (weapID == 37 or weapID == 70 or weapID == 75 or weapID == 76 or weapID == 78) then goto continue end
                    if weapon_esp.showGrenades == 0 and weapID >= 43 and weapID <= 48 then goto continue end
                    if weapon_esp.showBomb == 0 and weapID == 49 then goto continue end
                    local iClip1 = constellation.memory.read_integer(ent["address"] + weapon_esp.m_iClip1)
                    local iPrimaryReserveAmmoCount = constellation.memory.read_integer(ent["address"] +
                        weapon_esp.m_iPrimaryReserveAmmoCount)
                    local weapX, weapY = constellation.game.world_to_screen(ent["origin"]["x"], ent["origin"]["y"],
                        ent["origin"]["z"])
                    table.insert(weapArray,
                        { letter = weaponInfo[weapID][1], x = weapX, y = weapY, maxAmmo = weaponInfo[weapID][2],
                            curAmmo = iClip1, reserve = iPrimaryReserveAmmoCount })
                end
            end
        end
        ::continue::
    end

    weapon_esp.weaponArray = weapArray
end

function weapon_esp.OnOverlayRender(width, height, center_x, center_y)
    if weapon_esp.enabled == 0 then return end

    local textoffset = 0
    if weapon_esp.drawAmmoText == 1 and weapon_esp.drawAmmoBar == 1 then
        textoffset = 12
    end

    for key, value in pairs(weapon_esp.weaponArray) do
        if value.x ~= nil and value.y ~= nil then
            constellation.windows.overlay.text(value.letter, "csgo_icons", value.x, value.y,
                { r = weapon_esp.colorR, g = weapon_esp.colorG, b = weapon_esp.colorB, a = 255 })
            if value.maxAmmo > 0 and value.curAmmo >= 0 and value.reserve >= 0 and value.maxAmmo <= 200 and
                value.curAmmo <= 200 then -- ghetto fix
                if weapon_esp.drawAmmoText == 1 then
                    constellation.windows.overlay.text(value.curAmmo .. "/" .. value.reserve, "Consolas Medium", value.x
                        , value.y + 15 + textoffset,
                        { r = weapon_esp.colorR, g = weapon_esp.colorG, b = weapon_esp.colorB, a = 255 })
                end

                -- drawing a bar that shows how much the mag is filled
                if weapon_esp.drawAmmoBar == 1 then
                    constellation.windows.overlay.box(value.x, value.y + 20, 40, 4, 1,
                        { r = 255, g = 255, b = 255, a = 255 })
                    constellation.windows.overlay.box_filled(value.x + 1, value.y + 21,
                        value.curAmmo / value.maxAmmo * 38, 2, { r = 255, g = 0, b = 0, a = 255 })
                end
            end
        end
    end
end

return weapon_esp
