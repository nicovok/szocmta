imports = {
    exports.core:getFunction('registerEvent'),
}

pcall(loadstring(table.concat(imports, '\n')))

hospitalPosition = {
    -2665, 638.5, 14.5, 180, 0, 0
}

registerEvent('damage.spawnPlayer', root,
    function(hospital)
        iprint(client)
        local skin = getElementModel(client)

        if hospital then
            local x, y, z = unpack(hospitalPosition)
        else
            local x, y, z = getElementPosition(client)
        end

        spawnPlayer(client, x, y, z, hospitalPosition[4], skin, hospitalPosition[5], hospitalPosition[6])

        if hospital then
            outputChatBox(exports.core:getServerTag('info') .. 'Újraéledtél.', client, 0, 0, 0, true)
        end
    end
)

function healPlayer(player)
    if not isElement(player) then return end

    setElementHealth(player, 100)
end