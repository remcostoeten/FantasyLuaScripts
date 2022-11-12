local hox =
{
    IsVisible = function(you, entity)
        local m_bSpottedByMask = constellation.memory.netvar("DT_BaseEntity", "m_bSpottedByMask")
        local mask = constellation.memory.read_integer(entity["address"] + m_bSpottedByMask)
        local PBASE = constellation.memory.read_integer(you + 0x64) - 1
        if (mask > 0 and 2 ^ (PBASE - 1) ~= 0) then
            return true
        else return false end
    end
}


function hox.Initialize()
    constellation.windows.overlay.create("Valve001", "")

end

function hox.OnConstellationTick(localplayer)
    if localplayer == nil then return end

    if not constellation.game.bsp.parse() then return end

    local player_information = constellation.game.get_player(localplayer)
    if not player_information then return end

    for _, enemy in pairs(constellation.game.get_enemies()) do

        local result = constellation.game.bsp.trace_ray(
            player_information["eye_position"]["x"], player_information["eye_position"]["y"],
            player_information["eye_position"]["z"],
            enemy["eye_position"]["x"], enemy["eye_position"]["y"], enemy["eye_position"]["z"]
        )

        if result then
            print(string.format("I see you %s!", enemy["name"]))

            if hox.IsVisible(localplayer, enemy) == true then
                constellation.log("aaaa")
            elseif hox.IsVisible(localplayer, enemy) == false then
                constellation.log("bbbb")
            end

        end


    end
end

return hox
