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
if hox.IsVisible(localplayer, enemy) == true then
    if constellation.game.is_in_fov(enemy, 35) then

        if dimensions ~= nil then
            constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                dimensions["bottom"] + 1, 1, { r = 255, g = 255, b = 255, a = 174 })
        end
    elseif hox.IsVisible(localplayer, enemy) == false then

        if dimensions ~= nil then
            constellation.windows.overlay.box(dimensions["left"], dimensions["top"], dimensions["right"],
                dimensions["bottom"] + 1, 1, { r = 255, g = 0, b = 0, a = 125 })
        end
    end
end
