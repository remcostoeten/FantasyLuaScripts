--[[
    @Patch Notes:
        - 4 months ago: "added check for mouse status to prevent the script from accidentally typing in chat"
--]]

--[[
    @title
        autostop
    @author
        Moyo
    @description
        moves in the opposite direction when you let go of the walking keys so you stop faster and have better accuracy
--]]
local autostop =
{
    --modules
    client_address = nil,
    client_size = nil,

    -- offsets
    dwMouseEnable = nil,

    -- netvars
    m_vecVelocity = nil,
    m_fFlags = nil
}

function autostop.Initialize(game_id)
    if game_id ~= GAME_CSGO then
        constellation.log("not calibrated with CSGO")
        return false
    end

    constellation.vars.menu(
        "enable autostop",
        "autostop_enabled",
        "<input name='autostop_enabled' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "autostop forward key (W)",
        "autostop_forward",
        "<input name='autostop_forward' type='number' onchange=\"fantasy_cmd(this, 'set')\" step='1' />",
        104
    )

    constellation.vars.menu(
        "autostop left key (A)",
        "autostop_left",
        "<input name='autostop_left' type='number' onchange=\"fantasy_cmd(this, 'set')\" step='1' />",
        100
    )

    constellation.vars.menu(
        "autostop back key (S)",
        "autostop_back",
        "<input name='autostop_back' type='number' onchange=\"fantasy_cmd(this, 'set')\" step='1' />",
        101
    )

    constellation.vars.menu(
        "autostop right key (D)",
        "autostop_right",
        "<input name='autostop_right' type='number' onchange=\"fantasy_cmd(this, 'set')\" step='1' />",
        102
    )

    autostop.client_address, autostop.client_size = constellation.driver.module("client.dll")

    autostop.dwMouseEnable = constellation.driver.pattern(
        autostop.client_address,
        autostop.client_size,
        "B9 ? ? ? ? FF 50 34 85 C0 75 10",
        1,
        48,
        0
    )
end

function autostop.OnConstellationCalibrated()
    autostop.m_vecVelocity = constellation.memory.netvar("DT_CSPlayer", "m_vecVelocity[0]")
    autostop.m_fFlags = constellation.memory.netvar("DT_CSPlayer", "m_fFlags")
end

function autostop.OnConstellationTick(localplayer, localweapon, viewangles)
    if localplayer == nil then return end

    -- FantasyVars
    local forward = constellation.vars.get("autostop_forward")
    local back = constellation.vars.get("autostop_back")
    local left = constellation.vars.get("autostop_left")
    local right = constellation.vars.get("autostop_right")

    -- get player velocity
    local velocity = constellation.memory.read_vector(localplayer + autostop.m_vecVelocity)

    -- rotate X and Y velocity using viewangles
    local viewRad = viewangles.y * math.pi / 180
    local rotatedX = (math.cos(viewRad) * velocity.x) - (math.sin(viewRad) * -velocity.y)
    local rotatedY = (math.sin(viewRad) * velocity.x) + (math.cos(viewRad) * -velocity.y)

    -- get player flags (onGround, inAir, ducking)
    local flags = constellation.memory.read_integer(localplayer + autostop.m_fFlags)

    -- check if mouse is enabled
    local mouseEnable = constellation.memory.read(autostop.client_address + autostop.dwMouseEnable)

    if not constellation.windows.key(87) and not constellation.windows.key(65) and not constellation.windows.key(83) and
        not constellation.windows.key(68) and flags == 257 and bit.band(mouseEnable, 1) == 1 then
        if rotatedX > 20 then
            constellation.windows.keyboard.press(back, 1) -- back (S) - numpad 5
        elseif rotatedX < -20 then
            constellation.windows.keyboard.press(forward, 1) -- forward (W) - numpad 8
        end

        if rotatedY > 20 then
            constellation.windows.keyboard.press(left, 1) -- left (A) - numpad 4
        elseif rotatedY < -20 then
            constellation.windows.keyboard.press(right, 1) -- right (D) - numpad 6
        end
    end
end

return autostop
