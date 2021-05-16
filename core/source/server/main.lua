disallowedIdNumbers = {}
playerIds = {}

function sync()
    for id, player in pairs(disallowedIdNumbers) do
        playerIds[player] = id
    end

    setElementData(resourceRoot, 'disallowedIdNumbers', disallowedIdNumbers)
    setElementData(resourceRoot, 'playerIds', playerIds)
end

addEventHandler('onResourceStart', resourceRoot,
    function()
        setMapName(MAP_NAME)
        setGameType(GAME_TYPE)

        setMaxPlayers(MAX_PLAYERS)
        setElementData(resourceRoot, 'maxPlayers', MAX_PLAYERS)

        local players = getElementsByType('player')

        for i, player in pairs(players) do
            disallowedIdNumbers[i] = player
            setElementData(player, 'player.id', i)

            local logged = getElementData(player, 'account.logged')

            setPlayerName(player, 'Játékos ' .. i)
        end

        setPlayerNametagShowing(source, false)

        sync()
    end
)

addEventHandler('onPlayerJoin', root,
    function()
        if not isElement(source) then return end

        local freeID = false

        for i = 1, MAX_PLAYERS do
            if not disallowedIdNumbers[i] then
                freeID = i
                break
            end
        end

        if freeID then
            disallowedIdNumbers[freeID] = source
            setElementData(source, 'player.id', freeID)

            setPlayerName(source, 'Player ' .. freeID)
        else
            kickPlayer(source)
        end

        if isPlayerDeveloper(source) then
            local tag = getServerTag('admin')
            local _, nick = isPlayerDeveloper(source)

            local content = ('%s Fejlesztői serial érzékelve! Üdv, %s!'):format(tag, nick)

            outputChatBox(content, source, 0, 0, 0, true)
        end

        setPlayerNametagShowing(source, false)

        sync()
    end
)

addEventHandler('onPlayerQuit', root,
    function()
        local id = getElementData(source, 'player.id')

        if id then
            disallowedIdNumbers[id] = nil
        end

        sync()
    end
)

addCommandHandler(ID_COMMAND,
    function(player)
        local id = getElementData(player, 'player.id')

        if not id then return end

        local content = getServerTag('info') .. ID_CONTENT:gsub('con_id', id)

        outputChatBox(content, player, 0, 0, 0, true);
    end
)

addCommandHandler('spawnme',
    function(player)
        if isPlayerDeveloper(player) then
            spawnPlayer(player, 0, 0, 3)
            fadeCamera(player, true)
            setCameraTarget(player)
        end
    end
)