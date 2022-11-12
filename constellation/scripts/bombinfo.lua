--[[
    @title
        bombinfo

    @author
        Moyo

    @description
        drawing bomb infos on an overlay
        CSGO only
--]]
local bombinfo = {
    -- netvars
    m_flC4Blow = nil,
    m_flDefuseCountDown = nil,
    m_nBombSite = nil,
    m_bBombDefused = nil,
    m_hBombDefuser = nil,
    m_bHasDefuser = nil,
    m_flTimerLength = nil,

    -- FantasyVars
    bi_bombesp = nil,
    bi_infobox = nil,
    bi_bombbar = nil,
    bi_infobox_relative = nil,
    bi_bombbar_relative = nil,

    -- bomb values
    detonationTime = nil,
    defuseTime = nil,
    defusing = nil,
    localplayerDefusing = nil,
    hasDefuser = nil,
    bombDefused = nil,
    bombTotalTime = nil,
    bombsiteLetter = nil,

    -- world to screen values
    droppedBombX = nil,
    droppedBombY = nil,
    defuserX = nil,
    defuserY = nil,
    plantedBombX = nil,
    plantedBombY = nil
}

function bombinfo.Initialize(game_id)

    if game_id ~= GAME_CSGO then
        constellation.log("not calibrated with CSGO")
        return false
    else
        constellation.windows.overlay.create("Valve001", "")
    end

    -- menu options
    constellation.vars.menu(
        "Bomb ESP",
        "bombinfo_bombesp",
        "<input name='bombinfo_bombesp' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "Bomb bar",
        "bombinfo_bombbar",
        "<input name='bombinfo_bombbar' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "Bomb infobox",
        "bombinfo_infobox",
        "<input name='bombinfo_infobox' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "Bomb infobox defuse time relative to bomb time",
        "bombinfo_infobox_relative",
        "<input name='bombinfo_infobox_relative' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "Bomb bar defuse time relative to bomb time",
        "bombinfo_bombbar_relative",
        "<input name='bombinfo_bombbar_relative' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.windows.overlay.add_font(
        "Consolas Medium",
        "Consolas",
        16,
        DWRITE_FONT_WEIGHT_NORMAL,
        DWRITE_FONT_STRETCH_NORMAL
    )

    constellation.windows.overlay.add_font(
        "Consolas Large",
        "Consolas",
        35,
        DWRITE_FONT_WEIGHT_NORMAL,
        DWRITE_FONT_STRETCH_NORMAL
    )

    constellation.windows.overlay.add_font(
        "Consolas ESP",
        "Consolas",
        16,
        600,
        DWRITE_FONT_STRETCH_NORMAL
    )
end

function bombinfo.OnConstellationCalibrated()
    bombinfo.m_flC4Blow = constellation.memory.netvar("DT_PlantedC4", "m_flC4Blow")
    bombinfo.m_flDefuseCountDown = constellation.memory.netvar("DT_PlantedC4", "m_flDefuseCountDown")
    bombinfo.m_nBombSite = constellation.memory.netvar("DT_PlantedC4", "m_nBombSite")
    bombinfo.m_bBombDefused = constellation.memory.netvar("DT_PlantedC4", "m_bBombDefused")
    bombinfo.m_hBombDefuser = constellation.memory.netvar("DT_PlantedC4", "m_hBombDefuser")
    bombinfo.m_bHasDefuser = constellation.memory.netvar("DT_CSPlayer", "m_bHasDefuser")
    bombinfo.m_flTimerLength = constellation.memory.netvar("DT_PlantedC4", "m_flTimerLength")
end

function bombinfo.OnConstellationTick(localplayer, localweapon, viewangles)
    if localplayer == nil then return end

    local globals = constellation.game.get_globals()

    -- FantasyVars
    bombinfo.bi_bombesp = constellation.vars.get("bombinfo_bombesp")
    bombinfo.bi_bombbar = constellation.vars.get("bombinfo_bombbar")
    bombinfo.bi_infobox = constellation.vars.get("bombinfo_infobox")
    bombinfo.bi_infobox_relative = constellation.vars.get("bombinfo_infobox_relative")
    bombinfo.bi_bombbar_relative = constellation.vars.get("bombinfo_bombbar_relative")

    -- check if bomb is dropped
    local droppedBomb = constellation.game.get_entity_from_class(34)
    if droppedBomb ~= nil and bombinfo.bi_bombesp == 1 and droppedBomb[1]["origin"]["x"] ~= 0 and
        droppedBomb[1]["origin"]["y"] ~= 0 and droppedBomb[1]["origin"]["z"] ~= 0 then
        bombinfo.droppedBombX, bombinfo.droppedBombY = constellation.game.world_to_screen(droppedBomb[1]["origin"]["x"],
            droppedBomb[1]["origin"]["y"], droppedBomb[1]["origin"]["z"])
    else
        bombinfo.droppedBombX, bombinfo.droppedBombY = nil, nil
    end

    local plantedBomb = constellation.game.get_entity_from_class(129)
    if plantedBomb ~= nil and plantedBomb[1]["is_dormant"] == false then
        bombinfo.detonationTime = constellation.memory.read_float(plantedBomb[1]["address"] + bombinfo.m_flC4Blow) -
            globals["curtime"]
        bombinfo.bombDefused = constellation.memory.read_integer(plantedBomb[1]["address"] + bombinfo.m_bBombDefused)
        bombinfo.defuseTime = constellation.memory.read_float(plantedBomb[1]["address"] + bombinfo.m_flDefuseCountDown) -
            globals["curtime"]
        bombinfo.bombTotalTime = constellation.memory.read_float(plantedBomb[1]["address"] + bombinfo.m_flTimerLength)
        local bombDefuserHandle = constellation.memory.read_integer(plantedBomb[1]["address"] + bombinfo.m_hBombDefuser)
        if bombDefuserHandle ~= -1 then
            bombinfo.defusing = 1
        else
            bombinfo.defusing = 0
        end

        local bombsite = constellation.memory.read_integer(plantedBomb[1]["address"] + bombinfo.m_nBombSite)
        if bombsite == 0 then
            bombinfo.bombsiteLetter = "A"
        elseif bombsite == 1 then
            bombinfo.bombsiteLetter = "B"
        end

        if bombinfo.bi_bombesp == 1 then
            -- w2s bomb coordinates
            bombinfo.plantedBombX, bombinfo.plantedBombY = constellation.game.world_to_screen(plantedBomb[1]["origin"][
                "x"], plantedBomb[1]["origin"]["y"], plantedBomb[1]["origin"]["z"])

            -- w2s defuser message
            if bombinfo.defusing == 1 then
                local defuser = constellation.game.get_player(constellation.game.get_entity_from_handle(bombDefuserHandle))
                bombinfo.localplayerDefusing = defuser["address"] == localplayer
                bombinfo.hasDefuser = constellation.memory.read_integer(defuser["address"] + bombinfo.m_bHasDefuser)
                bombinfo.defuserX, bombinfo.defuserY = constellation.game.world_to_screen(defuser["origin"]["x"],
                    defuser["origin"]["y"], defuser["origin"]["z"] + 40)
            else
                bombinfo.defuserX, bombinfo.defuserY = nil, nil -- don't draw defusing message after stopping defusing
            end
        end
    else
        bombinfo.detonationTime = nil
        bombinfo.plantedBombX = nil
        bombinfo.plantedBombY = nil
    end
end

function bombinfo.OnOverlayRender(width, height, center_x, center_y)
    -- bomb ESP
    if bombinfo.bi_bombesp == 1 then
        if bombinfo.droppedBombX ~= nil and bombinfo.droppedBombY ~= nil then
            constellation.windows.overlay.text("dropped bomb", "Consolas ESP", bombinfo.droppedBombX,
                bombinfo.droppedBombY, { r = 255, g = 50, b = 50, a = 255 })
        end

        if bombinfo.detonationTime ~= nil and bombinfo.bombDefused ~= nil and bombinfo.bombDefused ~= 1 and
            bombinfo.plantedBombX ~= nil and bombinfo.plantedBombY ~= nil then
            constellation.windows.overlay.text(string.format("C4 | %.1fs", bombinfo.detonationTime), "Consolas ESP",
                bombinfo.plantedBombX, bombinfo.plantedBombY, { r = 255, g = 0, b = 0, a = 255 })
        end
        if bombinfo.detonationTime ~= nil and bombinfo.defuserX ~= nil and bombinfo.defuserY ~= nil and
            bombinfo.localplayerDefusing == false then
            constellation.windows.overlay.text(string.format("defusing | %.1fs", bombinfo.defuseTime), "Consolas ESP",
                bombinfo.defuserX, bombinfo.defuserY, { r = 255, g = 0, b = 255, a = 255 })
            if bombinfo.hasDefuser == 1 then
                constellation.windows.overlay.text("with defuse kit", "Consolas ESP", bombinfo.defuserX,
                    bombinfo.defuserY + 15, { r = 255, g = 0, b = 180, a = 255 })
            end
        end
    end

    -- bomb timer bar
    if bombinfo.bi_bombbar == 1 and bombinfo.detonationTime ~= nil then
        local barWidth = height / 64
        if bombinfo.detonationTime > 0 and bombinfo.bombDefused ~= 1 then
            constellation.windows.overlay.box_filled(0, 0, bombinfo.detonationTime / bombinfo.bombTotalTime * width,
                barWidth, { r = 100, g = 200, b = 0, a = 120 })
        end
        if bombinfo.defusing == 1 then
            if bombinfo.bi_bombbar_relative == 1 then
                constellation.windows.overlay.box_filled(0, barWidth,
                    bombinfo.defuseTime / bombinfo.bombTotalTime * width, barWidth, { r = 50, g = 150, b = 255, a = 120 })
            elseif bombinfo.hasDefuser == 1 then
                constellation.windows.overlay.box_filled(0, barWidth, bombinfo.defuseTime / 5 * width, barWidth,
                    { r = 50, g = 150, b = 255, a = 120 })
            else
                constellation.windows.overlay.box_filled(0, barWidth, bombinfo.defuseTime / 10 * width, barWidth,
                    { r = 50, g = 150, b = 255, a = 120 })
            end
        end
    end

    -- bomb infobox
    if bombinfo.bi_infobox == 1 and bombinfo.detonationTime ~= nil and bombinfo.detonationTime > 0 and
        bombinfo.bombDefused ~= 1 then
        constellation.windows.overlay.box_filled(10, center_y, 120, 45, { r = 50, g = 50, b = 50, a = 255 })
        constellation.windows.overlay.box_filled(10, center_y + 40,
            bombinfo.detonationTime / bombinfo.bombTotalTime * 120, 5, { r = 100, g = 200, b = 0, a = 255 })
        constellation.windows.overlay.text(string.format("%.1fs", bombinfo.detonationTime), "Consolas Medium", 45,
            center_y + 2, { r = 255, g = 255, b = 255, a = 255 })

        if bombinfo.defusing == 1 then
            -- defuse bar
            if bombinfo.bi_infobox_relative == 1 then
                constellation.windows.overlay.box_filled(10, center_y + 35,
                    bombinfo.defuseTime / bombinfo.bombTotalTime * 120, 5, { r = 50, g = 150, b = 255, a = 255 })
            elseif bombinfo.hasDefuser == 1 then
                constellation.windows.overlay.box_filled(10, center_y + 35, bombinfo.defuseTime / 5 * 120, 5,
                    { r = 50, g = 150, b = 255, a = 255 })
            else
                constellation.windows.overlay.box_filled(10, center_y + 35, bombinfo.defuseTime / 10 * 120, 5,
                    { r = 50, g = 150, b = 255, a = 255 })
            end

            -- defuse text
            if bombinfo.detonationTime > bombinfo.defuseTime then
                constellation.windows.overlay.text("can defuse", "Consolas Medium", 45, center_y + 16,
                    { r = 100, g = 200, b = 0, a = 255 })
            else
                constellation.windows.overlay.text("no time!", "Consolas Medium", 45, center_y + 16,
                    { r = 255, g = 0, b = 0, a = 255 })
            end
        end

        if bombinfo.bombsiteLetter ~= nil then
            constellation.windows.overlay.text(bombinfo.bombsiteLetter, "Consolas Large", 18, center_y,
                { r = 255, g = 255, b = 255, a = 255 })
        end
    end
end

return bombinfo
