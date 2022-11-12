--[[
    @title
        Movement Trail

    @author
        Moyo

    @description
        draws a trail behind you
--]]
local movement_trail = {
    enabled = nil,
    rainbow = nil,

    colorR = 0,
    colorG = 0,
    colorB = 0,

    lastPos = 0,
    points = {},
    collection = {},
}

function movement_trail.Initialize(game_id)
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
        "enable movement trail",
        "movementTrail_enabled",
        "<input name='movementTrail_enabled' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "movement trail length",
        "movementTrail_length",
        "<input name='movementTrail_length' type='number' onchange=\"fantasy_cmd(this, 'set')\" />",
        100
    )

    constellation.vars.menu(
        "movement trail color",
        "movementTrail_color",
        "<input name='movementTrail_color' type='color' onchange=\"fantasy_cmd(this, 'set')\" />",
        "5EDDC8"
    )

    constellation.vars.menu(
        "movement trail rainbow color",
        "movementTrail_rainbow",
        "<input name='movementTrail_rainbow' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )
end

function movement_trail.OnConstellationTick(localplayer, localweapon, viewangles)
    if localplayer == nil then return end

    local locPlayer = constellation.game.get_player(localplayer)
    local globals = constellation.game.get_globals()

    -- get FantasyVars and check if script is enabled
    movement_trail.enabled = constellation.vars.get("movementTrail_enabled")
    if movement_trail.enabled == 0 then return end
    movement_trail.length = constellation.vars.get("movementTrail_length")
    movement_trail.rainbow = constellation.vars.get("movementTrail_rainbow")
    if movement_trail.rainbow == 0 then movement_trail.colorR, movement_trail.colorG, movement_trail.colorB = constellation
        .vars.get_color("movementTrail_color") end

    if globals["curtime"] > movement_trail.lastPos + 0.015625 then

        local r = 0
        local g = 0
        local b = 0

        if movement_trail.rainbow == 1 then
            local mod = globals["curtime"] % 1

            if mod < 0.16 then
                r = 1
                g = 0
                b = mod / 0.16
            elseif mod < 0.33 then
                r = 1 - (mod - 0.16) / 0.17
                g = 0
                b = 1
            elseif mod < 0.5 then
                r = 0
                g = (mod - 0.33) / 0.16
                b = 1
            elseif mod < 0.66 then
                r = 0
                g = 1
                b = 1 - (mod - 0.5) / 0.16
            elseif mod < 0.83 then
                r = (mod - 0.66) / 0.17
                g = 1
                b = 0
            else
                r = 1
                g = 1 - (mod - 0.83) / 0.17
                b = 0
            end
        else
            r = movement_trail.colorR / 255
            g = movement_trail.colorG / 255
            b = movement_trail.colorB / 255
        end

        if #movement_trail.points == 0 then
            table.insert(movement_trail.points,
                { x = locPlayer["origin"]["x"], y = locPlayer["origin"]["y"], z = locPlayer["origin"]["z"], r = r, g = g,
                    b = b })
        elseif movement_trail.points[#movement_trail.points].x ~= locPlayer["origin"]["x"] or
            movement_trail.points[#movement_trail.points].y ~= locPlayer["origin"]["y"] or
            movement_trail.points[#movement_trail.points].z ~= locPlayer["origin"]["z"] then
            table.insert(movement_trail.points,
                { x = locPlayer["origin"]["x"], y = locPlayer["origin"]["y"], z = locPlayer["origin"]["z"], r = r, g = g,
                    b = b })
            if #movement_trail.points == movement_trail.length then -- max saved positions
                table.remove(movement_trail.points, 1)
            end
        elseif #movement_trail.points > 1 then
            table.remove(movement_trail.points, 1)
        end

        movement_trail.lastPos = globals["curtime"]
    end

    local points = {}
    for _, point in pairs(movement_trail.points) do

        local x, y = constellation.game.world_to_screen(point.x, point.y, point.z)
        table.insert(points, { x = x, y = y, r = point.r, g = point.g, b = point.b })
    end

    movement_trail.collection = points
end

function movement_trail.OnOverlayRender(width, height, center_x, center_y)
    if movement_trail.enabled == 0 then return end

    for k, trailPoint in pairs(movement_trail.collection) do
        if movement_trail.collection[k + 1] and movement_trail.collection[k + 1].x and movement_trail.collection[k + 1].y
            and trailPoint.x and trailPoint.y then
            constellation.windows.overlay.line(trailPoint.x, trailPoint.y, movement_trail.collection[k + 1].x,
                movement_trail.collection[k + 1].y, { r = trailPoint.r, g = trailPoint.g, b = trailPoint.b, a = 0.7 }, 4)
        end
    end
end

return movement_trail
