function setAdminLevel(player, cmd, target, level)
    if not hasPermissionTo(player, 'admin.setalevel') then return end

    local level = tonumber(level)

    if not target or not level then
        outputChatBox(exports.core:getServerTag('usage') .. '/' .. cmd .. ' [ID] [Szint]', player, 0, 0, 0, true)
        return
    end

    local target = exports.core:findPlayer(player, target)
    if target then
        local accountID = getElementData(target, 'account.id')
        local levelBfr = getElementData(player, 'account.adminlevel')

        setElementData(target, 'account.adminlevel', level)
        dbExec(exports.core:getDatabaseConnection(), 'UPDATE `accounts` SET `admin` = ? WHERE `id` = ?', level, accountID)

        local color = '#d17560'
        local white = '#ffffff'

        local playerName = getElementData(player, 'account.username')
        local targetName = getElementData(target, 'account.username')

        local content = ('%s%s%s beállította %s%s%s adminisztrátori szintét. (%s -> %s)'):format(color, playerName, white, color, targetName, white, levelBfr, level)

        outputChatBox(content, root, 0, 0, 0, true)

        if level > 0 then return end

        if getElementData(target, 'adminDuty') then
            setElementData(target, 'adminDuty', false)
        end
    end
end

addCommandHandler('setalevel', setAdminLevel)
addCommandHandler('setadminlevel', setAdminLevel)

--function setPlayerDimension(player, cmd, target, dim)
--    if not hasPermissionTo(player, 'admin.setdimension') then return end
--
--    local dim = tonumber(dim)
--
--    if not target or not dim then
--        outputChatBox(exports.core:getServerTag('usage') .. '/' .. cmd .. ' [ID] [Dimenzió]', player, 0, 0, 0, true)
--        return
--    end
--
--    local target = exports.core:findPlayer(player, target)
--    if target then
--        setElementDimension(target, dim)
--
--        outputChatBox(exports.core:getServerTag('admin'))
--    end
--end

---------------
-- Vehicle commands
---------------

function createVehicleForPlayer(player, cmd, target, model)
    if not hasPermissionTo(player, 'vehicles.createvehicle') then return end

    local model = tonumber(model)

    if not target or not model then
        outputChatBox(exports.core:getServerTag('usage') .. '/' .. cmd .. ' [ID] [Modell]', player, 0, 0, 0, true)
        return
    end

--  if not exports.vehicles:isValidModel(model) then
--      outputChatBox(exports.core:getServerTag('error') .. 'Helytelen autó azonosító.', player, 0, 0, 0, true)
--      return
--  end

    local target = exports.core:findPlayer(player, target)
    if target then
        local id = getElementData(target, 'account.id')

        local x, y, z = getElementPosition(target)
        local position = toJSON({
            x = x,
            y = y,
            z = z,
            int = getElementInterior(target),
            dim = getElementDimension(target)
        })

        local _, _, z = getElementRotation(target)
        local rotation = toJSON({
            x = 0,
            y = 0,
            z = z
        })

        dbExec(exports.core:getDatabaseConnection(), 'INSERT INTO `vehicles` SET `owner` = ?, `model` = ?, `position` = ?, `rotation` = ?', id, model, position, rotation)

        dbQuery(
            function(qh, player)
                local res = dbPoll(qh, 0)

                outputChatBox(exports.core:getServerTag('admin') .. 'Létrehoztál egy járművet. ID: ' .. res[1].id, player, 0, 0, 0, true)

                exports.vehicles:loadVehicle(res[1])
            end
        , {player}, exports.core:getDatabaseConnection(), 'SELECT * FROM `vehicles` WHERE `id` = LAST_INSERT_ID()')
    end
end

addCommandHandler('createveh', createVehicleForPlayer)
addCommandHandler('createvehicle', createVehicleForPlayer)
addCommandHandler('makeveh', createVehicleForPlayer)

--function outputNearbyVehicles(player, cmd, )
--end
--
--addCommandHandler('nearbyveh', outputNearbyVehicles)
--addCommandHandler('nearbyvehs', outputNearbyVehicles)
--addCommandHandler('nearbyvehicles', outputNearbyVehicles)