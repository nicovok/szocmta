imports = {
    exports.core:getFunction('registerEvent'),
    exports.core:getFunction('resp'),
    exports.core:getFunction('drawRoundedRectangle'),
}

pcall(loadstring(table.concat(imports, '\n')))

function loadInteriors()
    local function callback(qh)
        local result = dbPoll(qh, 0)

        if result then
            for _, interior in pairs(result) do
                loadInterior(interior)
            end

            triggerClientEvent('interiors.syncInteriors', root, interiors)
        end
    end

    dbQuery(callback, exports.core:getDatabaseConnection(), 'SELECT * FROM interiors')
end

function loadInterior(data)
    local entrance_position = fromJSON(data.enter_position)
    local exit_position = fromJSON(data.exit_position)

    local color = data.owner == 0 and forSaleColor or interiorTypes[data.type].color

    interiors[data.id] = {
        id = data.id,

        entrance_position = entrance_position,
        exit_position = exit_position,

        entrance_interior = data.enter_interior,
        entrance_dimension = data.enter_dimension,
        exit_interior = data.exit_interior,
        exit_dimension = data.exit_dimension,

        name = data.name,
        type = data.type,
        owner = data.owner,
        price = data.price,

        entrance = createMarker(
            entrance_position.x,
            entrance_position.y,
            entrance_position.z,
            'cylinder',
            0.9,
            color.r, color.g, color.b, color.a
        ),
        exit = createMarker(
            exit_position.x,
            exit_position.y,
            exit_position.z,
            'cylinder',
            0.9,
            color.r, color.g, color.b, color.a
        ),
    }

    setElementInterior(interiors[data.id].entrance, data.enter_interior)
    setElementDimension(interiors[data.id].entrance, data.enter_dimension)

    setElementInterior(interiors[data.id].exit, data.exit_interior)
    setElementDimension(interiors[data.id].exit, data.exit_dimension)

    setElementData(interiors[data.id].entrance, 'interior.id', data.id)
    setElementData(interiors[data.id].exit, 'interior.id', data.id)
end

addEventHandler('onResourceStart', resourceRoot,
    function()
        setTimer(loadInteriors, 1000, 1)
    end
)

registerEvent('interiors.requestInteriors', root,
    function()
        triggerClientEvent(client, 'interiors.syncInteriors', root, interiors)
    end
)

registerEvent('interiors.setInteriorOwner', root,
    function(id, owner)
        if interiors[id] then
            dbExec(exports.core:getDatabaseConnection(), 'UPDATE interiors SET owner = ? WHERE id = ?', owner, id)

            interiors[id].owner = owner
            triggerClientEvent('interiors.syncInteriors', root, interiors)

            local color = owner == 0 and forSaleColor or interiorTypes[interiors[id].type].color
            triggerEvent('interiors.setInteriorColor', root, id, color)
        end
    end
)

registerEvent('interiors.setInteriorColor', root,
    function(id, color)
        if interiors[id] then
            setMarkerColor(interiors[id].entrance, color.r, color.g, color.b, color.a)
            setMarkerColor(interiors[id].exit, color.r, color.g, color.b, color.a)
        end
    end
)

registerEvent('interiors.playerUseInterior', root,
    function(id, side)
        if interiors[id] then
            local position = interiors[id][side .. '_position']
            setElementPosition(source, position.x, position.y, position.z + 1)
            setElementInterior(source, interiors[id][side .. '_interior'])
            setElementDimension(source, interiors[id][side .. '_dimension'])
        end
    end
)

registerEvent('interiors.setInteriorName', root,
    function(id, name)
        if interiors[id] then
            interiors[id].name = name
            dbExec(exports.core:getDatabaseConnection(), 'UPDATE interiors SET name = ? WHERE id = ?', name, id)

            triggerClientEvent('interiors.syncInteriors', root, interiors)
        end
    end
)

addCommandHandler('createinterior',
    function(player, cmd, interiorID, type, price, ...)
        local interiorID = tonumber(interiorID)
        local type = tonumber(type)
        local price = tonumber(price)
        local name = table.concat({...}, ' ')

        if not interiorID or not type or not price then
            outputChatBox(exports.core:getServerTag('usage') .. '/' .. cmd .. ' [interiorID] [típus] [ár] [név]', player, 0, 0, 0, true)

            outputChatBox(exports.core:getServerTag('admin') .. 'Típusok:', player, 0, 0, 0, true)
            for id, interiorType in pairs(interiorTypes) do
                outputChatBox(exports.core:getServerTag('admin') .. '[' .. id .. '] ' .. interiorType.name, player, 0, 0, 0, true)
            end
            return
        end

        if not defaultInteriors[interiorID] then
            outputChatBox(exports.core:getServerTag('admin') .. 'Hibás interior ID.', player, 0, 0, 0, true)
            return
        end

        if not interiorTypes[type] then
            outputChatBox(exports.core:getServerTag('admin') .. 'Hibás típus.', player, 0, 0, 0, true)
            return
        end

        local x, y, z = getElementPosition(player)
        local entrance_position = toJSON({
            x = x,
            y = y,
            z = z - 1
        })
        local entrance_interior = getElementInterior(player)
        local entrance_dimension = getElementDimension(player)

        local exit_position = toJSON({
            x = defaultInteriors[interiorID].x,
            y = defaultInteriors[interiorID].y,
            z = defaultInteriors[interiorID].z
        })
        local exit_interior = defaultInteriors[interiorID].interior

        local owner = type == 1 and -1 or 0

        local db = exports.core:getDatabaseConnection()
        dbExec(db, 'INSERT INTO interiors SET owner = ?, name = ?, type = ?, price = ?, enter_position = ?, enter_interior = ?, enter_dimension = ?, exit_position = ?, exit_interior = ?, exit_dimension = LAST_INSERT_ID() + 1', owner, name, type, price, entrance_position, entrance_interior, entrance_dimension, exit_position, exit_interior)
        
        local function callback(qh)
            local result = dbPoll(qh, 0)

            if result then
                loadInterior(result[1])
                triggerClientEvent('interiors.syncInteriors', root, interiors)
            end
        end

        dbQuery(callback, db, 'SELECT * FROM interiors WHERE id = LAST_INSERT_ID()')
    end
)