addCommandHandler('getpos',
    function()
        local x, y, z = getElementPosition(localPlayer)
        local int = getElementInterior(localPlayer)
        local dim = getElementDimension(localPlayer)

        local content = exports.core:getServerTag('admin') .. 'A jelenlegi pozíciód: \n~ ' .. table.concat({x, y, z}, ', ') .. '\n~ Interior: ' .. int .. '\n~ Dimenzió: ' .. dim
        outputChatBox(content, 0, 0, 0, true)

        -- Kocsi dolgai
    end
)