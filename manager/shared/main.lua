imports = {
    exports.core:getFunction('registerEvent')
}

if localPlayer then
    table.insert(imports, exports.core:getFunction('resp'))
    table.insert(imports, exports.core:getFunction('isInArea'))
    table.insert(imports, exports.core:getFunction('colorInterpolation'))
end

pcall(loadstring(table.concat(imports, '\n')))

function canOpenManager(player)
    return getElementData(player, 'account.adminlevel') >= 5 or exports.core:isPlayerDeveloper(player)
end