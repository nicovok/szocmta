imports = {
    exports.core:getFunction('registerEvent'),
    exports.core:getFunction('resp'),
    exports.core:getFunction('drawRoundedRectangle'),
}

pcall(loadstring(table.concat(imports, '\n')))

sx, sy = guiGetScreenSize()
mx, my = sx/2, sy/2

interiorMarkers = {}

currentInterior = false
interiorTextures = {}
local enterTick = 0

registerEvent('interiors.syncInteriors', root,
    function(ints)
        interiorMarkers = {}
        interiors = ints

        for id, interior in pairs(interiors) do
            interiorMarkers[interior.entrance] = {
                id = id,
                type = 'entrance'
            }

            interiorMarkers[interior.exit] = {
                id = id,
                type = 'exit'
            }
        end
    end
)

addEventHandler('onClientResourceStart', root,
    function(res)
        if res == resource or getResourceName(res) == 'core' then
            SFPro20 = exports.core:getFont('SFPro', resp(20))
            SFPro15 = exports.core:getFont('SFPro', resp(15))

            if res == resource then
                triggerServerEvent('interiors.requestInteriors', localPlayer)

                for id, interiorType in pairs(interiorTypes) do
                    interiorTextures[id] = dxCreateTexture('client/icons/' .. interiorType.icon .. '.png', 'argb', true, 'clamp')
                    if fileExists('client/icons/' .. interiorType.icon .. 'forsale.png') then
                        interiorTextures[id .. '-forsale'] = dxCreateTexture('client/icons/' .. interiorType.icon .. 'forsale.png', 'argb', true, 'clamp')
                    end
                end
            end
        end
    end
)

addEventHandler('onClientMarkerHit', resourceRoot,
    function(player, matchingDimension)
        if getTickCount() - enterTick < 500 then
            return
        end

        if player == localPlayer and matchingDimension then
            if interiorMarkers[source] then
                currentInterior = {
                    id = interiorMarkers[source].id,
                    side = interiorMarkers[source].type
                }

                showInteriorInfo(currentInterior.id)
            end
        end
    end
)

addEventHandler('onClientMarkerLeave', resourceRoot,
    function(player, matchingDimension)
        if player == localPlayer and matchingDimension then
            if interiorMarkers[source] and currentInterior then
                if interiorMarkers[source].id == currentInterior.id then
                    currentInterior = false

                    showInteriorInfo(false)
                end
            end
        end
    end
)

addEventHandler('onClientRender', root,
    function()
        for id, interior in pairs(interiors) do
            local color = interiorTypes[interior.type].color
            local icon = interiorTextures[interior.type]

            if interior.type ~= 1 and interior.owner == 0 then
                icon = interiorTextures[interior.type .. '-forsale']
                color = forSaleColor
            end

            if isElementStreamedIn(interior.entrance) then
                drawInteriorIcon3D(
                    interior.entrance_position.x,
                    interior.entrance_position.y,
                    interior.entrance_position.z,
                    color,
                    icon
                )
            end

            if isElementStreamedIn(interior.exit) then
                drawInteriorIcon3D(
                    interior.exit_position.x,
                    interior.exit_position.y,
                    interior.exit_position.z,
                    color,
                    icon
                )
            end 
        end
    end
)

function drawInteriorIcon3D(x, y, z, color, icon)
    local size = 0.7
    local _y = interpolateBetween(0.5, 0, 0, 0.6, 0, 0, getTickCount() / 4000, 'SineCurve')

    dxDrawMaterialLine3D(
        x, y, z + _y + size,
        x, y, z + _y,
        icon,
        size,
        tocolor(color.r, color.g, color.b)
    )
end

bindKey('e', 'down',
    function()
        if currentInterior then
            local current = interiors[currentInterior.id]

            if currentInterior.side == 'entrance' and current.type ~= 1 and current.owner == 0 then
                local id = getElementData(localPlayer, 'character.id')
                triggerServerEvent('interiors.setInteriorOwner', localPlayer, current.id, id)
                current.owner = id
                showInteriorInfo(currentInterior.id)
                return
            end

            local side = currentInterior.side == 'entrance' and 'exit' or 'entrance'
            triggerServerEvent('interiors.playerUseInterior', localPlayer, current.id, side)
            enterTick = getTickCount()
        end
    end
)

addCommandHandler('liberinterior',
    function()
        if currentInterior then
            if interiors[currentInterior.id].owner > 0 then
                triggerServerEvent('interiors.setInteriorOwner', localPlayer, currentInterior.id, 0)
                interiors[currentInterior.id].owner = 0
                showInteriorInfo(currentInterior.id)
                outputChatBox(exports.core:getServerTag('admin') .. 'Sikeresen felszabadítottál egy interiort.', 0, 0, 0, true)
            else
                outputChatBox(exports.core:getServerTag('error') .. 'Ez az interior eladó.', 0, 0, 0, true)
            end
        end
    end
)

addCommandHandler('setinteriorname',
    function(_, ...)
        if currentInterior then
            local name = table.concat({...}, ' ')
            interiors[currentInterior.id].name = name
            showInteriorInfo(currentInterior.id)
            triggerServerEvent('interiors.setInteriorName', localPlayer, currentInterior.id, name)
        end
    end
)