--[[
    @title
        Projectile ESP

    @author
        typedef

    @description
        Projectile ESP for Stickies, Pipes and Rockets
--]]

local projectile_esp =
{
    -- fantasyvars
    vars =
    {
        enabled = 0,
        stickies = 0,
        pipes = 0,
        rockets = 0,
        player = 0,

        colors =
        {
            stickies_color = 0,
            pipes_color = 0,
            rockets_color = 0,
            player_color = 0,
        }
    },

    -- netvars
    m_hThrower = nil,
    m_iType = nil,
    m_iTeamNum = nil,

    -- projectile database
    db = {},

    -- classes
    CTFGrenadePipebombProjectile = 216,
    CTFProjectile_Rocket = 263,
    CTFPlayer = 246,
}

function projectile_esp.Initialize(game_id)

    -- only TF2
    if game_id ~= GAME_TF2 then return false end

    -- add menu items -> loop through all fantasyvars because I don't want to copy+paste constellation.vars.menu 7+ times.
    for key, _ in pairs(projectile_esp.vars) do

        -- format fantasyvar name
        local var_name = string.format("projectile_esp_%s", key)

        -- is part of .colors table?
        if key == "colors" then

            -- loop through .colors table of fantasyvars
            for color_key, _ in pairs(projectile_esp.vars.colors) do

                -- reformat with correct fantasyvar name
                var_name = string.format("projectile_esp_%s", color_key)

                -- create color value.
                projectile_esp.vars.colors[color_key] = constellation.vars.menu(
                    string.format("Projectile ESP [%s]", color_key:gsub("^%l", string.upper)),
                    var_name,
                    "<input name='" .. var_name .. "' type='color' onchange=\"fantasy_cmd(this, 'set')\" />",
                    "FFFFFF"
                )

            end

        else

            -- create checkbox value.
            projectile_esp.vars[key] = constellation.vars.menu(
                string.format("Projectile ESP [%s]", key:gsub("^%l", string.upper)),
                var_name,
                "<input name='" .. var_name .. "' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />",
                true
            )

        end

    end

    -- create overlay.
    constellation.windows.overlay.create("Valve001", "")

    -- notification
    constellation.log("Projectile ESP for TF2 loaded.")
end

function projectile_esp.OnConstellationCalibrated()

    -- netvars
    projectile_esp.m_hThrower = constellation.memory.netvar("DT_TFProjectile_Throwable", "m_hThrower")
    projectile_esp.m_iType = constellation.memory.netvar("DT_TFProjectile_Pipebomb", "m_iType")
    projectile_esp.m_iTeamNum = constellation.memory.netvar("DT_BaseEntity", "m_iTeamNum")
end

function projectile_esp.OnConstellationTick(localplayer, localweapon, viewangles)

    -- reset database always
    projectile_esp.db = {}

    -- are we ingame?
    if not localplayer then return end

    -- are our netvars okay?
    if not projectile_esp.m_hThrower or not projectile_esp.m_iType then return end

    -- is enabled?
    if not constellation.vars.get(projectile_esp.vars.enabled) then return end

    -- get our player information
    local player_information = constellation.game.get_player(localplayer)
    if not player_information then return end

    -- get highest entity index.
    local server_entity_highest_index = constellation.game.get_highest_entity_index()

    -- get vars.
    local stickies_enabled = constellation.vars.get(projectile_esp.vars.stickies)
    local pipes_enabled = constellation.vars.get(projectile_esp.vars.pipes)
    local player_enabled = constellation.vars.get(projectile_esp.vars.player)

    -- loop through all entities
    for i = 1, server_entity_highest_index do

        -- get entity based off of index.
        local entity = constellation.game.get_entity(i)

        -- is valid entity?
        if not entity then goto continue end

        -- no dormants
        if entity["is_dormant"] then goto continue end

        -- is it one of the accepted classes?
        if entity["class"] == projectile_esp.CTFGrenadePipebombProjectile or
            entity["class"] == projectile_esp.CTFProjectile_Rocket then

            -- closet player sticky esp
            if player_enabled then

                for _, player in pairs(constellation.game.get_enemies()) do

                    -- get world space center.
                    local location = constellation.game.get_world_space_center(entity["address"])

                    -- get the delta between the sticky and the enemy.
                    local delta =
                    {
                        x = location["x"] - player["origin"]["x"],
                        y = location["y"] - player["origin"]["y"],
                        z = location["z"] - player["origin"]["z"],
                    }

                    -- calculate the distance using the delta angle.
                    local distance = constellation.math.vector_distance(
                        location["x"], location["y"], location["z"],
                        player["origin"]["x"], player["origin"]["y"], player["origin"]["z"]
                    )

                    -- is within explosion distance.
                    if distance < 75 then


                        -- get their box dimensions
                        local dimensions = constellation.game.get_box_dimensions(player)
                        if not dimensions then goto continue end

                        -- assign player class
                        dimensions["class"] = projectile_esp.CTFPlayer

                        -- insert player to db
                        table.insert(projectile_esp.db, dimensions)
                    end

                end
            end

            -- get box dimensions
            local dimensions = constellation.game.get_box_dimensions(entity)

            -- are dimensions good?
            if not dimensions then goto continue end

            -- assign class to dimensions table.
            dimensions["class"] = entity["class"]

            -- is this a grenade launcher projectile?
            if entity["class"] == projectile_esp.CTFGrenadePipebombProjectile then

                -- get the type
                dimensions["type"] = constellation.memory.read_integer(entity["address"] + projectile_esp.m_iType)

                -- m_iType = 1 (Sticky) but stickies aren't enabled? skip.
                if dimensions["type"] == 1 and not stickies_enabled then goto continue end

                -- must be something other than a sticky, probably a pipe. not enabled? skip.
                if dimensions["type"] ~= 1 and not pipes_enabled then goto continue end

            end

            -- get the entity's team. we don't wanna show our own stuff nor our team's projectiles.
            local entity_team = constellation.memory.read_integer(entity["address"] + projectile_esp.m_iTeamNum)
            if entity_team == player_information["team"] then goto continue end

            -- insert regular projectiles
            table.insert(projectile_esp.db, dimensions)
        end

        ::continue::
    end
end

function projectile_esp.OnOverlayRender(width, height, center_x, center_y)

    -- nothing to show. empty database.
    if #projectile_esp.db == 0 then return end

    -- loop through our database
    for _, dimensions in pairs(projectile_esp.db) do

        -- set default color.
        local color = { r = 255, g = 255, b = 255, a = 255 }

        -- is this a grenade launcher item?
        if dimensions["class"] == projectile_esp.CTFGrenadePipebombProjectile then

            -- set color depending on if stickies or pipe.
            if dimensions["type"] == 1 then
                color.r, color.g, color.b = constellation.vars.get_color(projectile_esp.vars.colors.stickies_color)
            else
                color.r, color.g, color.b = constellation.vars.get_color(projectile_esp.vars.colors.pipes_color)
            end

            -- this is a rocket?
        elseif dimensions["class"] == projectile_esp.CTFProjectile_Rocket then

            -- rockets tend to be bigger, expand the width and height and realign.
            dimensions["left"] = dimensions["left"] - 5
            dimensions["top"] = dimensions["top"] - 5
            dimensions["right"] = dimensions["right"] + 10
            dimensions["bottom"] = dimensions["bottom"] + 10

            -- set color.
            color.r, color.g, color.b = constellation.vars.get_color(projectile_esp.vars.colors.rockets_color)

            -- this is a player?
        elseif dimensions["class"] == projectile_esp.CTFPlayer then

            -- set color.
            color.r, color.g, color.b = constellation.vars.get_color(projectile_esp.vars.colors.player_color)

        end

        -- draw box
        constellation.windows.overlay.box(dimensions["left"] - 3, dimensions["top"], dimensions["right"] + 2,
            dimensions["bottom"] + 2, 1, color)
    end

end

return projectile_esp
