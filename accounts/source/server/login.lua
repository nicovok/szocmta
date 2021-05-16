local error = exports.core:getServerTag('error')

registerEvent('accounts.executeLogin', root,
    function(username, password)
        if not username or not password then return end

        local connection = exports.core:getDatabaseConnection()

        dbQuery(
            function(query, client)
                local accounts = dbPoll(query, 0)

                if not accounts then print('sql error'); return end

                if #accounts < 1 then
                    outputChatBox(error .. 'Hibás felhasználónév, vagy jelszó.', client, 0, 0, 0, true)
                    return
                end

                local account = accounts[1]

                if account.serial ~= getPlayerSerial(client) then
                    outputChatBox(error .. 'Ez a fiók egy másik számítógéphez van kötve.', client, 0, 0, 0, true)
                    return
                end

                setElementData(client, 'account.id', account.id)
                setElementData(client, 'account.username', account.username)
                setElementData(client, 'account.adminlevel', account.admin)

                setElementData(client, 'adminDuty', false)

                triggerClientEvent(client, 'accounts.closeLogin', client, account)
                triggerClientEvent(client, 'accounts.successfulLogin', client, account)

                triggerEvent('accounts.loginIntoCharacter', client, account.id)
            end
        , {client}, connection, 'SELECT * FROM `accounts` WHERE `username` = ? AND `password` = ?', username, password)
    end
)