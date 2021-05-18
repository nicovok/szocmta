_slots = 36
_rowSlots = 9

elementTypes = {
    ['player'] = {
        id_key = 'character.id',
        weight = 30,
        headerText = 'Tárgyaim',
    },
    ['vehicle'] = {
        id_key = 'vehicle.id',
        weight = 100,
        headerText = 'Csomagtartó',
        headerShowID = true,
    },
    ['safe'] = {
        id_key = 'safe.id',
        weight = 100,
        headerText = 'Széf',
        headerShowID = true,
    },
}

customTypes = {
    ['trash.id'] = 'trash',
    ['safe.id'] = 'safe',
    ['keycopier'] = 'keycopier'
}

_getElementType = getElementType
function getElementType(element)
    local _type = _getElementType(element)

    for key, type in pairs(customTypes) do
        if getElementData(element, key) then
            _type = type
            break
        end
    end

    return _type
end

function setElementItems(element, items)
    return setElementData(element, 'inventory', items)
end

function getElementItems(element)
    return getElementData(element, 'inventory')
end

function getElementID(element)
    local type = getElementType(element)

    if elementTypes[type] then
        return getElementData(element, elementTypes[type].id_key)
    end

    return false
end

function getElementHeaderText(element)
    local type = getElementType(element)

    if elementTypes[type] then
        return elementTypes[type].headerText
    end

    return ''
end

function hasItemSpace(element, itemID, count)
    count = count or 1

    local items = getElementItems(element)
    if items then
        local elementType = getElementType(element)
        local maxWeight = elementTypes[elementType].weight

        local weight, targetSlot = 0, false
        for slot=1, _slots do 
            if items[slot] then
                weight = weight + (getItemWeight(items[slot].itemID) * items[slot].count)
            else
                if not targetSlot then 
                    targetSlot = slot
                end
            end
        end

        if weight + (getItemWeight(itemID) * count) <= maxWeight then 
            return targetSlot
        end
    end

    return false
end

function hasItem(element, itemID, value)
    local items = getElementItems(element)
    if items then
        local count = 0
        local slots = {}
        for slot, item in pairs(items) do
            if item.itemID == itemID and item.value == value then
                count = count + 1
                table.insert(slots, slot)
            end
        end

        if count > 0 then
            return true, count, slots
        end
    end

    return false
end