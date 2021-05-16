function loadElementItems(element)
    removeElementData(element, 'inventory')
    
    local id = getElementID(element)
    if id then
        local function callback(qh)
            local result = dbPoll(qh, 0)

            local currentItems = {}

            if result then
                for _, item in pairs(result) do
                    currentItems[item.slot] = {
                        dbID = item.id,
                        itemID = item.itemID,
                        count = item.count,
                        value = item.value,
                        duty = item.duty,
                        data = fromJSON(item.data or '[[]]')
                    }
                end

                setElementItems(element, currentItems)
            end
        end

        local db = exports.core:getDatabaseConnection()
        local query = 'SELECT * FROM items WHERE owner = ? AND ownerType = ?'
        local type = getElementType(element)
        dbQuery(callback, db, query, id, type)
    end
end
registerEvent('items.loadElementItems', root, loadElementItems)

function saveElementItems(element)
    local items = getElementItems(element)
    if items then
        local db = exports.core:getDatabaseConnection()
        local id = getElementID(element)
        local type = getElementType(element)

        for slot, item in pairs(items) do
            dbExec(db, 'UPDATE items SET slot = ?, itemID = ?, count = ?, value = ?, duty = ?, data = ? WHERE id = ?', slot, item.itemID, item.count, item.value, item.duty, toJSON(item.data or {}), item.dbID)
        end
    end
end
registerEvent('items.saveElementItems', root, saveElementItems)

addEventHandler('onResourceStart', resourceRoot,
    function()
        local function delayedStart()
            local players = getElementsByType('player')
            local vehicles = getElementsByType('vehicle')

            for _, player in pairs(players) do
                loadElementItems(player)
            end

            for _, vehicle in pairs(vehicles) do
                loadElementItems(vehicle)
            end

            loadTrashes()
        end

        setTimer(delayedStart, 500, 1)
    end
)

addEventHandler('onResourceStop', resourceRoot,
    function()
        local players = getElementsByType('player')

        for _, player in pairs(players) do
            saveElementItems(player)
        end
    end
)

addEventHandler('onPlayerQuit', root,
    function()
        saveElementItems(source)
    end
)

function giveItem(element, slot, itemID, count, value, data, duty)
    count = count or 1
    value = value or 1
    data = data or {}
    duty = duty or 0

    local id = getElementID(element)
    if not id then 
        return false
    end

    local items = getElementItems(element)
    if not items then 
        loadElementItems(element)
        return false
    end

    if not slot then 
        slot = hasItemSpace(element, itemID, count)
    end

    if slot then
        local elementType = getElementType(element)
        local currentItems = getElementItems(element)
        
        currentItems[slot] = {
            dbID = -1,
            itemID = itemID,
            count = count,
            value = value,
            data = data,
            duty = duty,
        }

        setElementItems(element, currentItems)

        local function callback(qh, element, slot)
            local result, lines, itemDBID = dbPoll(qh, 0)

            if result then 
                local currentItems = getElementItems(element)
                if currentItems[slot] then 
                    currentItems[slot].dbID = itemDBID
                    setElementItems(element, currentItems)
                end
            end
        end

        local db = exports.core:getDatabaseConnection()

        dbQuery(callback, {element, slot}, db, 'INSERT INTO items SET slot = ?, itemID = ?, count = ?, value = ?, data = ?, duty = ?, owner = ?, ownerType=?', slot, itemID, count, value, toJSON(data), duty, id, elementType)
        
        return true
    end
    
    cancelEvent()
    return false
end
registerEvent('items.giveItem', root, giveItem)

function deleteItem(element, item)
    local db = exports.core:getDatabaseConnection()
    dbExec(db, "DELETE FROM items WHERE id=?", item.dbID)
end
registerEvent('items.deleteItem', root, deleteItem)

function updateItemOwner(element, slot, item)
    local db = exports.core:getDatabaseConnection()
    dbExec(db, "UPDATE items SET slot=?, owner=?, ownerType=? WHERE id=?", slot, getElementID(element), getElementType(element), item.dbID)
end
registerEvent('items.updateItemOwner', root, updateItemOwner)

--> Commands
addCommandHandler('giveitem',
    function(player, cmd, target, itemID, count, value, data, duty)
        if not itemID or not count then 
            outputChatBox(exports.core:getServerTag('usage') .. '/'..cmd..' [ID] [itemID] [db] [érték] [data (JSON)] [duty (0-1)]', player, 255, 255, 255, true)
            return
        end

        itemID = math.floor(tonumber(itemID))
        count = count and math.floor(tonumber(count)) or 1
        value = value and math.floor(tonumber(value)) or 1
        data = data or '[ [ ] ]'
        duty = duty and math.floor(tonumber(duty)) or 0

        local targetPlayer = exports.core:findPlayer(player, target)
        if isElement(targetPlayer) then 
            local result = giveItem(targetPlayer, nil, itemID, count, value, fromJSON(data), duty) 
            if result then
                outputChatBox(exports.core:getServerTag('admin') .. 'Sikeresen adtál egy tárgyat ' .. getElementData(targetPlayer, 'character.fullname') .. '.', player, 255, 255, 255, true)
            else 
                outputChatBox(exports.core:getServerTag('error') .. 'Játékosnál nem fér el a tárgy.', player, 255, 255, 255, true)
            end
        end
    end
)