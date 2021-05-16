maxDist = 15

addEventHandler('onPlayerChat', root,
    function(message, type)
        cancelEvent()
        if type ~= 0 then return end

        if getElementData(source, 'adminDuty') then
            sendAdminMessage(source, message)
            return
        end

        local players = getElementsByType('player')
        local authorX, authorY, authorZ = getElementPosition(source)
        local authorName = getElementData(source, 'character.fullname')
        for _, player in pairs(players) do
            local playerX, playerY, playerZ = getElementPosition(player)
            local dist = getDistanceBetweenPoints3D(authorX, authorY, authorZ, playerX, playerY, playerZ)

            if dist <= 30 then
                triggerClientEvent(player, 'addBubble', source, message)
            end

            if dist <= maxDist then
                local r, g, b = interpolateBetween(255, 255, 255, 50, 50, 50, dist / maxDist, 'InQuad')
                local content = authorName .. ' mondja: ' .. message

                outputChatBox(content, player, r, g, b, true)
            end
        end
    end
)

addCommandHandler('/me',
    function(player, _, message)
        local players = getElementsByType('player')
        local playerX, playerY, playerZ = getElementPosition(source)
        local playerName = getElementData(source, 'character.fullname')
        for _, player in pairs(players) do
            local playerX, playerY, playerZ = getElementPosition(player)
            local dist = getDistanceBetweenPoints3D(playerX, playerY, playerZ, playerX, playerY, playerZ)

            if dist <= 30 then
                triggerClientEvent(player, 'addBubble', source, message)
            end

            if dist <= maxDist then
                local r, g, b = interpolateBetween(255, 255, 255, 50, 50, 50, dist / maxDist, 'InQuad')
                local content = playerName .. ' mondja: ' .. message

                outputChatBox(content, player, r, g, b, true)
            end
        end
    end
)

function sendAdminMessage(author, message)
    local players = getElementsByType('player')
    for _, player in pairs(players) do
        if getElementData(player, 'account.adminlevel') > 0 then
            local content = '#ddac71' .. 'AdminChat >> #ffffff' .. getElementData(author, 'account.username') .. ': ' .. message

            outputChatBox(content, player, 0, 0, 0, true)
        end
    end
end

addCommandHandler('a',
    function(player, _, ...)
        local message = table.concat({...}, ' ')
        sendAdminMessage(player, message)
    end
)