local npcTypes = {
    ['keycopier'] = 'Kulcsmásoló',
}

function loadNpcs()
    local function callback(qh)
        local result = dbPoll(qh, 0)

        if result and #result > 0 then
            for _, data in pairs(result) do
                local ped = createPed(data.skin, data.x, data.y, data.z, data.rotation)

                setElementInterior(ped, data.interior)
                setElementDimension(ped, data.dimension)

                setElementFrozen(ped, true)

                setElementData(ped, 'npc.id', data.id)
                setElementData(ped, 'npc.type', data.type)
                setElementData(ped, 'npc.name', data.name)
                setElementData(ped, data.type, true)
            end
        end
    end

    local db = exports.core:getDatabaseConnection()
    dbQuery(callback, db, 'SELECT * FROM npcs')
end

addEventHandler('onResourceStart', resourceRoot,
    function()
        setTimer(loadNpcs, 1000, 1)
    end
)

addEventHandler('onClientPedDamage', root,
    function()
        if getElementData(source, 'npc.id') then
            cancelEvent()
        end
    end
)