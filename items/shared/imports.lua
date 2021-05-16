imports = {
    exports.core:getFunction('registerEvent'),
    exports.core:getFunction('deepcopy')
}

if localPlayer then
    table.insert(imports, exports.core:getFunction('resp'))
    table.insert(imports, exports.core:getFunction('isInArea'))
    table.insert(imports, exports.core:getFunction('colorInterpolation'))
    table.insert(imports, exports.core:getFunction('drawRoundedRectangle'))
end

pcall(loadstring(table.concat(imports, '\n')))