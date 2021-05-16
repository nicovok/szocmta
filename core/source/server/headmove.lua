addEvent('headmove.syncPlayersHead', true)
addEventHandler('headmove.syncPlayersHead', root,
    function(targetX, targetY, targetZ)
        triggerClientEvent('headmove.syncPlayersHead', source, targetX, targetY, targetZ)
    end
)