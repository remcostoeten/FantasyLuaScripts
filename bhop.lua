local bhop = {
    flags = nil,
    in_air = nil,
    key = nil,
    hitchance = 100,
    rand = 0,
    force = false,
    jumps = 0,
    timer = 0,
    debug = false
}
function bhop.Initialize()
    constellation.vars.menu(
        "Bhop key",
        "bhop_key",
        "<input name='bhop_key' type='number' onchange=\"fantasy_cmd(this, 'set')\"   />",
        4
    )
    constellation.vars.menu(
        "Bhop hitchance (%)",
        "bhop_hitchance",
        "<input name='bhop_hitchance' type='number' onchange=\"fantasy_cmd(this, 'set')\"   />",
        75
    )
end

function bhop.OnConstellationCalibrated(game_id)
    bhop.flags = constellation.memory.netvar("DT_CSPlayer", "m_fFlags")
    if constellation.scripts.is_loaded("console.lua") then
        bhop.debug = true
        print("[Bhop.lua] Debugging enabled.")
    else
        bhop.debug = false
    end
end

function bhop.OnConstellationTick(localplayer)
    bhop.in_air = constellation.memory.read_integer(localplayer + bhop.flags)
    bhop.key = constellation.vars.get("bhop_key")
    bhop.hitchance = constellation.vars.get("bhop_hitchance")
    if bit.band(bhop.in_air, 1) == 1 and constellation.windows.key(bhop.key) then
        bhop.rand = math.random(0, 100)
    end
    if bhop.jumps == 0 then
        bhop.force = true
    else
        bhop.force = false
        bhop.timer = bhop.timer + 1
    end
    if bhop.in_air == 257 and bhop.jumps ~= 0 and bhop.timer > 150 then
        bhop.jumps = 0
        bhop.timer = 0
    end

    if bit.band(bhop.in_air, 1) == 1 and constellation.windows.key(bhop.key) and bhop.rand <= bhop.hitchance and
        not bhop.force then
        constellation.windows.keyboard.press(32, 20)
        bhop.jumps = bhop.jumps + 1
        if bhop.debug then
            print("J: " .. bhop.jumps)
            print("F: " .. tostring(bhop.force))
            print("HC: " .. bhop.hitchance)
            print("R: " .. bhop.rand)
            print("T: " .. bhop.timer)
            print("IA: " .. bit.band(bhop.in_air, 1))
            print("-------------------------------------------")
        end
    elseif bit.band(bhop.in_air, 1) == 1 and constellation.windows.key(bhop.key) and bhop.force then
        constellation.windows.keyboard.press(32, 20)
        bhop.jumps = bhop.jumps + 1
        if bhop.debug then
            print("J: " .. bhop.jumps)
            print("F: " .. tostring(bhop.force))
            print("HC: " .. bhop.hitchance)
            print("R: " .. bhop.rand)
            print("T: " .. bhop.timer)
            print("IA: " .. bit.band(bhop.in_air, 1))
            print("------------------ -------------------------")
        end
    end
end

return bhop
