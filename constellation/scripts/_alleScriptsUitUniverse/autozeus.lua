-- --[[
--     @title
--         autozeus

--     @author
--         typedef

--     @description
--         automatically zeus an enemy who is in close range.
-- --]]


-- local autozeus =
-- {
--     -- fov. increase for bigger range. decrease for smaller range.
--     fov = 15,

--     -- how far away are we allowed to be before triggering the autozeus?
--     distance = 150
-- }

-- function autozeus.OnConstellationTick(localplayer, localweapon, viewangles)

--     -- are we ingame?
--     if localplayer == nil then return end

--     -- do we even have a weapon?
--     if localweapon == nil or localweapon == 0 then return end

--     -- get our player information
--     local player_information = constellation.game.get_player(localplayer)
--     if player_information == nil then return end

--     -- get our weapon information
--     local weapon_information = constellation.game.get_weapon(localweapon)
--     if weapon_information == nil then return end

--     -- weapon_taser only.
--     if weapon_information["id"] ~= 31 then return end

--     -- get database of enemies
--     local enemies = constellation.game.get_enemies()

--     -- loop through all enemies
--     for _, player in pairs(enemies) do

--         --[[
--             check if enemy is in our fov. `direction` unused, but only for documentation purposes

--             direction = 1 -> Right of player
--             direction = 2 -> Left of player
--             direction = 3 -> Right in the middle

--             "10" is the FOV range we're looking for. Increase for bigger range. Decrease for smaller range.
--         --]]

--         local in_fov, direction = constellation.game.is_in_fov(player, autozeus.fov)

--         if in_fov then

--             --[[
--                 get the distance between two 2D vectors. "origin" is the player positions.

--                 distance formula = d = ?[(x2 ? x1)2 + (y2 ? y1)2]
--                 https://www.cuemath.com/geometry/distance-between-two-points/
--             --]]
--             local distance = math.sqrt(
--                 math.pow(
--                     (player.origin.x - player_information.origin.x),
--                     2
--                 )

--                 +

--                 math.pow(
--                     (player.origin.y - player_information.origin.y),
--                     2
--                 )
--             )

--             -- check if we're close enough.
--             if distance <= autozeus.distance then

--                 -- shoot using kernel mouse simulation
--                 constellation.driver.click()

--             end

--         end

--     end

-- end

-- return autozeus
