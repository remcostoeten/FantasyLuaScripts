--[[
    @Patch Notes:
        - 3 months ago: "nade locations now get imported from a local json file
which gets downloaded on first launch"
        - 5 months ago: "added mouse assist which helps lining up the crosshair"
--]]

--[[
    @title
        grenade helper
    @author
        Moyo
    @description
        drawing visual indicators for grenade lineups
        CSGO only
--]]
local nade_helper = {
    enabled = nil,
    maxDistance = nil,
    drawWithNadeOnly = nil,
    mouseAssist = nil,
    indicatorHeight = 40,
    grenadeArray = nil,
    currentMap = nil,
    currentMapNades = {},

    -- offsets
    dwClientState = nil, -- this isn't actually the offset but what is read with the offset
    dwClientState_Map = nil
}

-- import the json library to read custom nade files
if constellation.scripts.is_loaded("nade_helper.lua") then
    -- https://github.com/rxi/json.lua
    constellation.scripts.install_module("json.lua", "https://raw.githubusercontent.com/rxi/json.lua/master/json.lua")
else
    return nade_helper
end

local json = require("json")

function nade_helper.Initialize(game_id)
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
        "enable grenade helper",
        "nadehelper_enabled",
        "<input name='nadehelper_enabled' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "only draw nade help with nade in hand",
        "nadehelper_nadeInHand",
        "<input name='nadehelper_nadeInHand' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        false
    )

    constellation.vars.menu(
        "nade lineup mouse assist (experimental)",
        "nadehelper_assist",
        "<input name='nadehelper_assist' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        false
    )

    constellation.vars.menu(
        "indicator draw distance",
        "nadehelper_distance",
        "<input name='nadehelper_distance' type='number' onchange=\"fantasy_cmd(this, 'set')\" />",
        350
    )

    constellation.windows.overlay.add_font(
        "Consolas Medium",
        "Consolas",
        16,
        600,
        DWRITE_FONT_STRETCH_NORMAL
    )

    local engine_address, engine_size = constellation.driver.module("engine.dll")

    local dwClientState = constellation.memory.pattern(
        engine_address,
        engine_size,
        "A1 ? ? ? ? 33 D2 6A 00 6A 00 33 C9 89 B0",
        1,
        0,
        0
    )

    nade_helper.dwClientState_Map = constellation.memory.pattern(
        engine_address,
        engine_size,
        "05 ? ? ? ? C3 CC CC CC CC CC CC CC A1",
        1,
        0,
        1
    )

    nade_helper.dwClientState = constellation.memory.read(engine_address + dwClientState)

    -- check if json with nade file with locations exits and downloads the default one if it doesn't
    if not
        constellation.windows.file.exists(constellation.vars.get("directory") .. "constellation\\nade_helper\\nades.json") then

        -- create nade_helper directory
        constellation.windows.file.create_directory("constellation\\nade_helper")

        constellation.http.download_file("https://moyomo.xyz/nades.json",
            constellation.vars.get("directory") .. "constellation\\nade_helper\\nades.json")
    end
end

function nade_helper.OnConstellationTick(localplayer, localweapon, viewangles)
    if localplayer == nil then return end

    nade_helper.enabled = constellation.vars.get("nadehelper_enabled")
    if nade_helper.enabled == 0 then return end
    nade_helper.maxDistance = constellation.vars.get("nadehelper_distance")
    nade_helper.drawWithNadeOnly = constellation.vars.get("nadehelper_nadeInHand")
    nade_helper.mouseAssist = constellation.vars.get("nadehelper_assist")
    local locPlayer = constellation.game.get_player(localplayer)
    local locWeap = nil
    local mapName = constellation.memory.read_string(nade_helper.dwClientState + nade_helper.dwClientState_Map)

    -- check current map
    if mapName ~= nil and nade_helper.currentMap ~= mapName then
        nade_helper.currentMap = mapName

        -- load nade locations from json file
        local nade_jsonString = constellation.windows.file.read(constellation.vars.get("directory") ..
            "constellation\\nade_helper\\nades.json")
        if nade_jsonString ~= "" then
            local json_nades = json.decode(nade_jsonString)
            for map, _ in pairs(json_nades.nade_locations) do
                if map == mapName then
                    for _, nade in pairs(json_nades.nade_locations[mapName]) do
                        table.insert(nade_helper.currentMapNades,
                            { name = nade.name, nadeType = nade.nadeType, throwingType = nade.throwingType,
                                playerX = nade.playerX, playerY = nade.playerY, playerZ = nade.playerZ,
                                viewangleX = nade.viewangleX, viewangleY = nade.viewangleY })
                    end
                end
            end
        else
            constellation.log("your nades.json file is empty!")
            return
        end

        if nade_helper.currentMapNades ~= nil then
            for _, value in pairs(nade_helper.currentMapNades) do
                -- calculate a 3D point from player position & viewangles
                value.viewX = value.playerX +
                    (
                    -2000 * math.sin((value.viewangleX + 90) * math.pi / 180) *
                        math.sin((value.viewangleY - 90) * math.pi / 180))
                value.viewY = value.playerY +
                    (
                    2000 * math.sin((value.viewangleX + 90) * math.pi / 180) *
                        math.cos((value.viewangleY - 90) * math.pi / 180))
                value.viewZ = value.playerZ + (2000 * math.cos((value.viewangleX + 90) * math.pi / 180))
            end
        end
        constellation.log("finished loading grenade lineups after mapchange")
    end

    if nade_helper.drawWithNadeOnly == 1 then
        locWeap = constellation.game.get_weapon(localweapon)
    end

    local nearbyNades = {}

    if nade_helper.currentMapNades ~= nil and
        (nade_helper.drawWithNadeOnly == 0 or (nade_helper.drawWithNadeOnly == 1 and locWeap["is_nade"] == true)) then
        for _, nade in pairs(nade_helper.currentMapNades) do
            local distance = constellation.math.vector_distance(locPlayer["origin"]["x"], locPlayer["origin"]["y"],
                locPlayer["origin"]["z"], nade.playerX, nade.playerY, nade.playerZ)
            if distance < nade_helper.maxDistance then
                local playerScreenX, playerScreenY = constellation.game.world_to_screen(nade.playerX, nade.playerY,
                    nade.playerZ - 64)
                local indicatorScreenX, indicatorScreenY = nil, nil
                local lineupScreenX, lineupScreenY = nil, nil
                local crosshair = false

                if locPlayer["origin"]["x"] > nade.playerX - 10 and locPlayer["origin"]["x"] < nade.playerX + 10 and
                    locPlayer["origin"]["y"] > nade.playerY - 10 and locPlayer["origin"]["y"] < nade.playerY + 10 then
                    lineupScreenX, lineupScreenY = constellation.game.world_to_screen(nade.viewX, nade.viewY, nade.viewZ)
                    local dif = nade.viewangleY - viewangles["y"]
                    crosshair = ((dif >= 0 and dif < 5) or dif > 355 or (dif <= 0 and dif > -5)) and
                        viewangles["x"] + 5 > nade.viewangleX and viewangles["x"] - 5 < nade.viewangleX
                    if crosshair == true and nade_helper.mouseAssist == 1 and constellation.windows.key(1) then
                        constellation.humanizer(nade.viewangleX, nade.viewangleY)
                    end
                else
                    indicatorScreenX, indicatorScreenY = constellation.game.world_to_screen(nade.playerX, nade.playerY,
                        nade.playerZ - 64 + nade_helper.indicatorHeight)
                end
                local opacity = distance / nade_helper.maxDistance * 255
                table.insert(nearbyNades, { posX = playerScreenX,
                    posY = playerScreenY,
                    indicatorX = indicatorScreenX,
                    indicatorY = indicatorScreenY,
                    viewX = lineupScreenX,
                    viewY = lineupScreenY,
                    name = nade.name,
                    nadeType = nade.nadeType,
                    throwingType = nade.throwingType,
                    alpha = 255 - opacity,
                    drawCrosshair = crosshair
                })
            end
        end
    end

    nade_helper.grenadeArray = nearbyNades
end

function nade_helper.OnOverlayRender(width, height, center_x, center_y)
    if nade_helper.enabled == 0 or nade_helper.grenadeArray == nil then return end

    if nade_helper.currentMapNades ~= nil then
        for _, nade in pairs(nade_helper.grenadeArray) do
            if nade.posX ~= nil and nade.posY ~= nil then
                constellation.windows.overlay.circle(nade.posX, nade.posY, 9, 10,
                    { r = 255, g = 255, b = 255, a = nade.alpha })
            end
            if nade.indicatorX ~= nil and nade.indicatorY ~= nil and nade.posX ~= nil and nade.posY ~= nil then
                constellation.windows.overlay.line(nade.posX, nade.posY, nade.indicatorX, nade.indicatorY,
                    { r = 255, g = 255, b = 255, a = nade.alpha / 255 * 1 })
                constellation.windows.overlay.text(nade.name, "Consolas Medium", nade.indicatorX, nade.indicatorY - 30,
                    { r = 255, g = 255, b = 255, a = nade.alpha })
                constellation.windows.overlay.text(nade.nadeType, "Consolas Medium", nade.indicatorX,
                    nade.indicatorY - 15, { r = 255, g = 255, b = 255, a = nade.alpha })
            elseif nade.viewX ~= nil and nade.viewY ~= nil then
                -- crosshair position indicator
                constellation.windows.overlay.circle(nade.viewX, nade.viewY, 9, 10, { r = 255, g = 0, b = 0, a = 255 })
                constellation.windows.overlay.line(nade.viewX - 9, nade.viewY, nade.viewX + 9, nade.viewY,
                    { r = 255, g = 0, b = 0, a = 255 })
                constellation.windows.overlay.line(nade.viewX, nade.viewY - 9, nade.viewX, nade.viewY + 9,
                    { r = 255, g = 0, b = 0, a = 255 })

                constellation.windows.overlay.text(nade.name, "Consolas Medium", nade.viewX, nade.viewY - 25,
                    { r = 255, g = 255, b = 255, a = 255 })
                constellation.windows.overlay.text(nade.nadeType, "Consolas Medium", nade.viewX, nade.viewY + 10,
                    { r = 255, g = 255, b = 255, a = 255 })
                constellation.windows.overlay.text(nade.throwingType, "Consolas Medium", nade.viewX, nade.viewY + 25,
                    { r = 255, g = 255, b = 255, a = 255 })
            end

            if nade.drawCrosshair ~= nil and nade.drawCrosshair == true then
                constellation.windows.overlay.line(center_x - 20, center_y, center_x + 20, center_y,
                    { r = 0, g = 255, b = 100, a = 255 })
                constellation.windows.overlay.line(center_x, center_y - 20, center_x, center_y + 20,
                    { r = 0, g = 255, b = 100, a = 255 })
            end
        end
    end
end

return nade_helper
