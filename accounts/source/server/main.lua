imports = {
    exports.core:getFunction('registerEvent'),
}

pcall(loadstring(table.concat(imports, '\n')))

ENCODER = '^ˇ~˘SzocMTA2021->$Łäđ&Đ'

function encode(text)
    return teaEncode(text, ENCODER)
end

function decode(text)
    return teaDecode(text, ENCODER)
end

registerEvent('accounts.clientLoaded', root,
    function()
        triggerClientEvent(client, 'accounts.openLogin', client)
    end
)

registerEvent('accounts.loginIntoCharacter', root,
    function(account)
        dbQuery(
            function(handler, user)
                local result = dbPoll(handler, 0)

                if #result < 1 then return end

                local character = result[1]

                local name = fromJSON(character.name)
                local details = fromJSON(character.details)
                local position = fromJSON(character.position)

                setElementData(user, 'character.id', character.id)
                setElementData(user, 'character.name', name)
                setElementData(user, 'character.fullname', name.firstname .. ' ' .. name.lastname)

                setElementHealth(user, details.health)
                setElementData(user, 'character.hunger', details.hunger)
                setElementData(user, 'character.thirst', details.thirst)
                setElementData(user, 'character.job', details.job)
                setElementData(user, 'character.money', character.money)

                spawnPlayer(user, position.x, position.y, position.z, position.rot, details.skin, position.int, position.dim)
                setCameraTarget(user, user)
            end
        , {source}, exports.core:getDatabaseConnection(), 'SELECT * FROM `characters` WHERE `account` = ?', account)
    end
)

addEventHandler('onPlayerQuit', root,
    function()
        local charID = getElementData(source, 'character.id')

        if charID then
            local x, y, z = getElementPosition(source)
            local _, _, rot = getElementRotation(source)

            local position = toJSON({
                x = x,
                y = y,
                z = z,
                rot = rot,
                int = getElementInterior(source),
                dim = getElementDimension(source)
            })

            dbExec(exports.core:getDatabaseConnection(), 'UPDATE `characters` SET `position` = ? WHERE `id` = ?', position, charID)
        end
    end
)