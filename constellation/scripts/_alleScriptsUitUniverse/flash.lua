--[[
    @title
        flash check
    @author
        typedef
    @notes 
        flash check for Constellation
--]]

local flash =
{
    -- menu options
    menu =
    {
        triggerbot =
        {
            enabled = nil,
            time = nil,
        },

        humanizer =
        {
            enabled = nil,
            time = nil,
        }
    },

    -- netvar
    m_flFlashDuration = nil,

    -- original flash time
    flash_time = nil,

    -- functions
    get_flash = function(self, player)
        return constellation.memory.read_float(player + self.m_flFlashDuration)
    end,

    check = function(self, localplayer, enabled, time)
        -- enabled?
        if not constellation.vars.get(enabled) then return true end

        -- get globals
        local globals = constellation.game.get_globals()

        -- flash check
        local flash_duration = self.get_flash(self, localplayer)

        -- we're not flashed.
        if flash_duration == 0 then
            self.flash_time = nil -- reset because we're not flashed.
            return true
        end

        -- set our ending flash time
        if not self.flash_time then
            self.flash_time = globals["curtime"] + flash_duration
        end

        --[[
            local time_left = self.flash_time - globals["curtime"]
            local percentage = (time_left / flash_duration) * 100
        --]]
        return (((self.flash_time - globals["curtime"]) / flash_duration) * 100) < constellation.vars.get(time)
    end,
}

function flash.Initialize(game_id)

    -- CS:GO/CSS only.
    if game_id == GAME_DOTA2 or game_id == GAME_TF2 then return false end

    -- add menu items
    flash.menu.triggerbot.enabled = constellation.vars.menu("Flash Check [Triggerbot]", "flash_check_triggerbot",
        "<input name='flash_check_triggerbot' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    flash.menu.humanizer.enabled = constellation.vars.menu("Flash Check [Humanizer]", "flash_check_humanizer",
        "<input name='flash_check_humanizer' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    flash.menu.triggerbot.time = constellation.vars.menu("Flash Check [Triggerbot Time Percent]",
        "flash_check_triggerbot_time",
        "<input name='flash_check_triggerbot_time' type='number' step='0.1' onchange=\"fantasy_cmd(this, 'set')\"   />",
        50)
    flash.menu.humanizer.time = constellation.vars.menu("Flash Check [Humanizer Time Percent]",
        "flash_check_humanizer_time",
        "<input name='flash_check_humanizer_time' type='number' step='0.1' onchange=\"fantasy_cmd(this, 'set')\"   />",
        50)

end

function flash.OnConstellationCalibrated()
    flash.m_flFlashDuration = constellation.memory.netvar("DT_CSPlayer", "m_flFlashDuration")
end

function flash.OnHumanizerTarget(localplayer)
    return flash.check(flash, localplayer, flash.menu.humanizer.enabled, flash.menu.humanizer.time)
end

function flash.OnStandardTriggerbotActivated(localplayer)
    return flash.check(flash, localplayer, flash.menu.triggerbot.enabled, flash.menu.triggerbot.time)
end

return flash
