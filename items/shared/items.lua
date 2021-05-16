_items = {
--  [itemID] = {
--      name = 'Item Neve',
--      weight = Item Súlya,
--      stackable = Stackelhető akkor true ha nem akkor false,
--      weapon = MTA fegyver ID,
--      ammo = lőszer, csak akkor kell megadni ha lőszeres fegyver, a megadott itemid kell majd a fegyver használatához.
--      eatable = true csak akkor kell megadni ha ehető item
--  },
    [1] = {
        name = 'Jármű kulcs',
        weight = 0.05,
    },
    [2] = {
        name = 'Ásványvíz',
        weight = 0.3,
        stackable = true,
        eatable = true,
    },
    [3] = {
        name = 'Süti',
        weight = 0.025,
        stackable = true,
        eatable = true,
    },
    [4] = {
        name = 'Személyi igazolvány',
        weight = 0.025,
        stackable = false,
    },
}

function getItemName(itemID)
    return _items[itemID] and _items[itemID].name or "Ismeretlen"
end

function getItemImage(itemID)
    return ':items/client/items/' .. itemID .. '.png'
end

function getItemWeight(itemID)
    return _items[itemID] and _items[itemID].weight or 1
end

function isItemWeapon(itemID)
    return _items[itemID] and _items[itemID].weapon or false
end

function getItemAmmo(itemID)
    return _items[itemID] and _items[itemID].ammo or false
end

function isItemStackable(itemID)
    return _items[itemID] and _items[itemID].stackable or false
end

function isItemEatable(itemID)
    return _items[itemID] and _items[itemID].eatable or false
end