--[[
    @title
        Utility Timer ESP
    @author
        kyorex
    @description
        Utility helpers like Smoke timer ESP, Molotov timer ESP and Flash ESP.
--]]
local utility_esp =
{
    -- Classes
    csgo_classes = {
        CBaseCSGrenadeProjectile = 9,
        CSmokeGrenadeProjectile = 157,
        CInferno = 100,
    },
    -- Dbs
    dbs = {
        smoke_db = {},
        molotov_db = {},
        flash_db = {},
    },
    -- Netvars
    netvars = {
        m_nSmokeEffectTickBegin = nil,
        m_nFireEffectTickBegin = nil,
    },
    -- Constants
    constants = {
        tick_time = 0.015625,
        molotov_duration = 7.017578125,
        smoke_duration = 18.0432128906,
        flash_distance_esp = 900,
    },
    -- Menu Options
    menu = {
        show_molotov_progress = nil,
        show_smoke_progress = nil,
        show_progress_bar = nil,
        show_progress_number = nil,
        show_flash_esp = nil,
        flash_esp_distance = nil,
    },
    colors = {
        red = { r = 255, g = 0, b = 0, a = 255 },
        blue = { r = 0, g = 0, b = 255, a = 255 },
        white = { r = 255, g = 255, b = 255, a = 255 }
    }
}
function utility_esp.Initialize(game_id)
    if game_id ~= GAME_CSGO then return false end
    constellation.windows.overlay.create("Valve001", "")
    -- Menu
    utility_esp.menu.show_molotov_progress = constellation.vars.menu("Utility Helper [Molotov Progress]",
        "show_molotov_progress",
        "<input name='show_molotov_progress' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    utility_esp.menu.show_smoke_progress = constellation.vars.menu("Utility Helper [Smoke Progress]",
        "show_smoke_progress",
        "<input name='show_smoke_progress' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    utility_esp.menu.show_progress_bar = constellation.vars.menu("Utility Helper [Progress Bar]", "show_progress_bar",
        "<input name='show_progress_bar' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    utility_esp.menu.show_progress_number = constellation.vars.menu("Utility Helper [Progress Number]",
        "show_progress_number",
        "<input name='show_progress_number' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", true)
    utility_esp.menu.show_flash_esp = constellation.vars.menu("Utility Helper [Flash ESP]", "show_flash_esp",
        "<input name='show_flash_esp' type='checkbox' onchange=\"fantasy_cmd(this, 'set')\"   />", false)
    utility_esp.menu.flash_esp_distance = constellation.vars.menu("Utility Helper [Flash ESP Distance]",
        "flash_esp_distance", "<input name='flash_esp_distance' type='number' onchange=\"fantasy_cmd(this, 'set')\"   />"
        , 900)
end

function utility_esp.OnConstellationCalibrated(game_id)
    if game_id == GAME_CSGO then
        utility_esp.netvars.m_nSmokeEffectTickBegin = constellation.memory.netvar("DT_SmokeGrenadeProjectile",
            "m_nSmokeEffectTickBegin")
        utility_esp.netvars.m_nFireEffectTickBegin = constellation.memory.netvar("DT_Inferno", "m_nFireEffectTickBegin")
    end
end

function utility_esp.OnConstellationTick(localplayer, localweapon, viewangles)
    if localplayer == nil then return end
    utility_esp.dbs.molotov_db = {}
    utility_esp.dbs.smoke_db = {}
    utility_esp.dbs.flash_db = {}
    -- Search for molotovs
    if constellation.vars.get(utility_esp.menu.show_molotov_progress) == 1 then
        utility_esp.utility_timer(utility_esp.csgo_classes.CInferno, utility_esp.netvars.m_nFireEffectTickBegin,
            utility_esp.constants.tick_time, utility_esp.constants.molotov_duration, utility_esp.dbs.molotov_db)
    end
    -- Search for smokes
    if constellation.vars.get(utility_esp.menu.show_smoke_progress) == 1 then
        utility_esp.utility_timer(utility_esp.csgo_classes.CSmokeGrenadeProjectile,
            utility_esp.netvars.m_nSmokeEffectTickBegin, utility_esp.constants.tick_time,
            utility_esp.constants.smoke_duration, utility_esp.dbs.smoke_db)
    end
    -- Flash ESP
    if constellation.vars.get(utility_esp.menu.show_flash_esp) == 1 then
        utility_esp.flash_esp(localplayer, utility_esp.constants.flash_distance_esp)
    end
end

function utility_esp.OnOverlayRender(width, height, center_x, center_y)
    if #utility_esp.dbs.smoke_db ~= 0 then
        for _, db in pairs(utility_esp.dbs.smoke_db) do
            if (db.ticks > 0 and db.location ~= nil) then
                if constellation.vars.get(utility_esp.menu.show_progress_number) == 1 then
                    constellation.windows.overlay.text(string.format("%.2f", db.ticks), "Consolas Medium",
                        db.location.x + 2, db.location.y + 6, utility_esp.colors.red)
                end
                if constellation.vars.get(utility_esp.menu.show_progress_bar) == 1 then
                    constellation.windows.overlay.box(db.location.x, db.location.y, 40, 4, 1, utility_esp.colors.white)
                    constellation.windows.overlay.box_filled(db.location.x + 1, db.location.y + 1,
                        (db.ticks * 38) / db.utility_duration, 2, utility_esp.colors.red)
                end
            end
        end
    end
    if #utility_esp.dbs.molotov_db ~= 0 then
        for _, db in pairs(utility_esp.dbs.molotov_db) do
            if (db.ticks > 0 and db.location ~= nil) then
                if constellation.vars.get(utility_esp.menu.show_progress_number) == 1 then
                    constellation.windows.overlay.text(string.format("%.2f", db.ticks), "Consolas Medium",
                        db.location.x + 2, db.location.y + 6, utility_esp.colors.blue)
                end
                if constellation.vars.get(utility_esp.menu.show_progress_bar) == 1 then
                    constellation.windows.overlay.box(db.location.x, db.location.y, 40, 4, 1, utility_esp.colors.white)
                    constellation.windows.overlay.box_filled(db.location.x + 1, db.location.y + 1,
                        (db.ticks * 38) / db.utility_duration, 2, utility_esp.colors.blue)
                end
            end
        end
    end
    if #utility_esp.dbs.flash_db ~= 0 then
        for _, db in pairs(utility_esp.dbs.flash_db) do
            if (db.dimensions ~= nil) then
                constellation.windows.overlay.box(db.dimensions.left - 3, db.dimensions.top, db.dimensions.right + 2,
                    db.dimensions.bottom + 2, 1, db.color)
            end
        end
    end
end

function utility_esp.utility_timer(entity_class, initial_tick_netvar, tick_time, utility_duration, db)
    -- Get all the entities from a specific class
    local entities = constellation.game.get_entity_from_class(entity_class)
    if entities ~= nil then
        for _, entity in pairs(entities) do
            local globals = constellation.game.get_globals()
            -- Time until utility disappear
            local ticksLeft = (
                constellation.memory.read_integer(entity.address + initial_tick_netvar) * tick_time + utility_duration) -
                globals.curtime;
            -- Get location in screen
            local x, y = constellation.game.world_to_screen(entity.origin.x, entity.origin.y, entity.origin.z)
            -- If the coordinates are not in the screen, return.
            if (x == nil and y == nil) then return end
            -- Insert in the database
            table.insert(db, { ticks = ticksLeft, location = { x = x, y = y }, utility_duration = utility_duration })
        end
    end
end

function utility_esp.flash_esp(localplayer, esp_distance)
    utility_esp.dbs.flash_db = {}
    -- If can't get the current player early return
    local player = constellation.game.get_player(localplayer)
    if not player then return end
    -- Get all flashes
    local flashEntities = constellation.game.get_entity_from_class(utility_esp.csgo_classes.CBaseCSGrenadeProjectile)
    if flashEntities ~= nil then
        for _, flashEntity in pairs(flashEntities) do
            local flashDimensions = constellation.game.get_box_dimensions(flashEntity)
            local flashLocation = constellation.game.get_world_space_center(flashEntity.address)
            -- Use the BSP to verify if the flash is visible or not
            constellation.game.bsp.parse()
            local result, _, _, _ = constellation.game.bsp.trace_ray(
                player.eye_position.x, player.eye_position.y, player.eye_position.z,
                flashLocation.x, flashLocation.y, flashLocation.z
            )
            -- If the flash is not visible then return
            if not result then
                return
            end
            -- Get the distance between player and flash
            local distance = constellation.math.vector_distance(
                flashLocation.x, flashLocation.y, flashLocation.z,
                player.origin.x, player.origin.y, player.origin.z
            )
            -- Render with a different color depending on the distance
            if distance <= constellation.vars.get(utility_esp.menu.flash_esp_distance) then
                table.insert(utility_esp.dbs.flash_db, { dimensions = flashDimensions, color = utility_esp.colors.red })
            else
                table.insert(utility_esp.dbs.flash_db, { dimensions = flashDimensions, color = utility_esp.colors.blue })
            end
        end
    end
end

return utility_esp
