--[[
    @Patch Notes:
        - 4 months ago: "added sanity checks"
--]]

--[[
    @title
        spectator list

    @author
        Moyo

    @description
        draws a list of players who are spectating you
        CSGO only
--]]
local spectatorlist = {
    enabled = nil,
    max_name_length = nil,
    listX = nil,
    listY = nil,
    namestring = nil,

    -- netvars
    --m_iObserverMode = nil,
    m_hObserverTarget = nil
}

function spectatorlist.Initialize(game_id)
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
        "enable overlay spectatorlist",
        "speclist_enabled",
        "<input name='speclist_enabled' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "spectatorlist X",
        "speclist_x",
        "<input name='speclist_x' type='number' onchange=\"fantasy_cmd(this, 'set')\" />",
        300
    )

    constellation.vars.menu(
        "spectatorlist Y",
        "speclist_y",
        "<input name='speclist_y' type='number' onchange=\"fantasy_cmd(this, 'set')\" />",
        20
    )

    constellation.vars.menu(
        "spectatorlist max name length",
        "speclist_maxlength",
        "<input name='speclist_maxlength' type='number' onchange=\"fantasy_cmd(this, 'set')\" step=\"1\" min=\"1\" />",
        15
    )

    constellation.windows.overlay.add_font(
        "Consolas Medium",
        "Consolas",
        16,
        600,
        DWRITE_FONT_STRETCH_NORMAL
    )
end

function spectatorlist.OnConstellationCalibrated()
    -- observerMode could be used to show "thirdperson / firstperson / freecam"
    --spectatorlist.m_iObserverMode = constellation.memory.netvar("DT_BasePlayer", "m_iObserverMode")
    spectatorlist.m_hObserverTarget = constellation.memory.netvar("DT_BasePlayer", "m_hObserverTarget")
end

function spectatorlist.OnConstellationTick(localplayer, localweapon, viewangles)
    if localplayer == nil then return end

    -- FantasyVars
    spectatorlist.enabled = constellation.vars.get("speclist_enabled")
    spectatorlist.listX = constellation.vars.get("speclist_x")
    spectatorlist.listY = constellation.vars.get("speclist_y")
    spectatorlist.max_name_length = constellation.vars.get("speclist_maxlength")

    local names = ""

    for _, player in pairs(constellation.game.get_players()) do
        if player ~= nil and player["is_alive"] == false and player["dormant"] == false then
            local observerTarget = constellation.game.get_entity_from_handle(constellation.memory.read(player["address"]
                + spectatorlist.m_hObserverTarget))
            if observerTarget > 0 and observerTarget == localplayer then
                local playerName = player["name"]
                if string.len(playerName) > spectatorlist.max_name_length then
                    playerName = string.sub(playerName, 0, spectatorlist.max_name_length)
                    playerName = playerName .. "..."
                end
                names = names .. playerName .. "\n"
            end
        end
    end

    spectatorlist.namestring = names
end

function spectatorlist.OnOverlayRender(width, height, center_x, center_y)
    if spectatorlist.enabled == 0 then return end

    if spectatorlist.namestring and spectatorlist.listX and spectatorlist.listY then
        constellation.windows.overlay.text("[spectator list]\n" .. spectatorlist.namestring, "Consolas Medium",
            spectatorlist.listX, spectatorlist.listY, { r = 255, g = 255, b = 255, a = 255 })
    end
end

return spectatorlist
