function loadTrashes()
    local function callback(qh)
        local result = dbPoll(qh, 0)
        print('Load')

        if result then

            for _, trash in pairs(result) do
                local trashElement = createObject(1300, trash.x, trash.y, trash.z)

                setElementInterior(trashElement, trash.interior)
                setElementDimension(trashElement, trash.dimension)

                setElementData(trashElement, 'trash.id', true)
            end
        end
    end

    local db = exports.core:getDatabaseConnection()
    dbQuery(callback, db, 'SELECT * FROM trashes')
end