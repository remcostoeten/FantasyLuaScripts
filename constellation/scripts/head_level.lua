--[[
    @Patch Notes:
        - 1 month ago: "Removed useless debug message."
        - 1 month ago: "Added on key functionality."
--]]

--[[
    @title
        head_level.lua

    @author
        Moyo und luci <3 (we are gay)

    @description
        Helps the user keep their crosshair at head level.
--]]

local head_level = {

    debug = false,
    s_height = nil,
    offset = nil,
    key = 0,

    colour = {
        r = 0,
        g = 0,
        b = 0
    }

}

function head_level.Initialize(game_id)
    if constellation.scripts.is_loaded("console.lua") then
        head_level.debug = true
    end

    if game_id ~= GAME_CSGO then
        if head_level.debug then
            constellation.log("not calibrated with CSGO")
        end
        return false
    else
        if constellation.windows.overlay.create("Valve001", "") == false then
            if head_level.debug then
                constellation.log("The overlay could not be created because another script already created one.")
            end
        else
            if head_level.debug then
                constellation.log("Created overlay.")
            end
        end
    end

    constellation.vars.menu(
        "Head level key (0 = always on)",
        "hl_key",
        "<input name='hl_key' type='number' onchange=\"fantasy_cmd(this, 'set')\" />",
        0
    )

    constellation.vars.menu(
        "Head level colour",
        "hl_colour",
        "<input name='hl_colour' type='color' onchange=\"fantasy_cmd(this, 'set')\" />",
        "FFFFFF"
    )
end

function head_level.OnConstellationTick(localplayer, localweapon, viewangles)
    if not localplayer or not head_level.s_height then
        return
    end

    -- get FantasyVar
    head_level.colour.r, head_level.colour.g, head_level.colour.b = constellation.vars.get_color("hl_colour")
    head_level.colour.r = head_level.colour.r / 255
    head_level.colour.g = head_level.colour.g / 255
    head_level.colour.b = head_level.colour.b / 255

    head_level.key = constellation.vars.get("hl_key")

    head_level.offset = head_level.s_height / 2 - (viewangles.x / 37 * (head_level.s_height / 2))

end

function head_level.OnOverlayRender(width, height, center_x, center_y)
    if not head_level.s_height then
        head_level.s_height = height
    end

    if not head_level.offset or head_level.offset < 0 or head_level.offset > height then
        return
    end

    if head_level.key == 0 or constellation.windows.key(head_level.key) then
        --Left
        constellation.windows.overlay.line(center_x - 20, head_level.offset, center_x - 20 + 10, head_level.offset,
            { r = head_level.colour.r, g = head_level.colour.g, b = head_level.colour.b, a = 255 }, 1)
        --Right
        constellation.windows.overlay.line(center_x + 20, head_level.offset, center_x + 20 - 10, head_level.offset,
            { r = head_level.colour.r, g = head_level.colour.g, b = head_level.colour.b, a = 255 }, 1)
    end

end

return head_level
