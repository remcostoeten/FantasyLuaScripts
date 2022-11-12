--[[
    @Patch Notes:
        - 4 months ago: "Fixed an issue where on/off setting would not work due to FantasyVar return value."
--]]

--[[
    @title
        constant aim

    @author
        typedef

    @description
        removed feature from astrogalaxy and moonlight in where the humanizer
        will constantly aim for you depending on your weapon.

        constellation's humanizer is way different than both solutions and this
        seemingly appears to be more reliable with the minimum testing i've done.
--]]

local constant_aim = {}

function constant_aim.Initialize(game_id)

    if game_id ~= GAME_CSGO then return end

    -- add fantasyvars
    constellation.vars.menu(
        "Humanizer Constant Aim (Pistols)",
        "constant_aim_pistols",
        "<input name='constant_aim_pistols' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "Humanizer Constant Aim (Snipers)",
        "constant_aim_snipers",
        "<input name='constant_aim_snipers' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "Humanizer Constant Aim (FF)",
        "constant_aim_ff",
        "<input name='constant_aim_ff' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "Humanizer Constant Aim (FOV)",
        "constant_aim_fov",
        "<input name='constant_aim_fov' type='number' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

    constellation.vars.menu(
        "Humanizer Constant Aim (Bone)",
        "constant_aim_bone",
        "<input name='constant_aim_bone' type='number' onchange=\"fantasy_cmd(this, 'set')\" />",
        true
    )

end

function constant_aim.OnConstellationTick(localplayer, localweapon)

    -- we're not ingame.
    if not localplayer then return end

    -- we don't have a weapon
    if not localweapon then return end

    -- get our fantasyvars
    local constant_aim_pistols = constellation.vars.get("constant_aim_pistols")
    local constant_aim_snipers = constellation.vars.get("constant_aim_snipers")
    local constant_aim_ff = constellation.vars.get("constant_aim_ff")
    local constant_aim_fov = constellation.vars.get("constant_aim_fov")
    local constant_aim_bone = constellation.vars.get("constant_aim_bone")

    -- this script does not support -1 (all bones)
    if constant_aim_bone < 0 then return end

    -- fov cant be less than or equal to zero.
    if constant_aim_fov <= 0 then return end

    -- both settings aren't enabled.
    if not constant_aim_pistols and not constant_aim_snipers then return end

    -- get our weapon information
    local weapon_information = constellation.game.get_weapon(localweapon)
    if not weapon_information then return end

    -- do we have the required weapons. could have just used an if statement and lambda.
    local weapon_check = false

    if weapon_information.is_pistol and constant_aim_pistols == 1 then
        weapon_check = true
    end

    if weapon_information.is_sniper and constant_aim_snipers == 1 then
        weapon_check = true
    end

    -- don't continue, none of our conditions match.
    if not weapon_check then return end

    -- get the closest player in our FOV.
    local nearest, x, y, true_fov = constellation.game.get_closest_player_fov(constant_aim_ff, constant_aim_bone,
        constant_aim_fov)
    if not nearest then return end -- nobody is in our FOV.

    -- execute humanizer.
    constellation.humanizer(x, y)

end

return constant_aim
