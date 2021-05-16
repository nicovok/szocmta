local visible = false
local interiorInfo = false
local tick = 0

function showInteriorInfo(interior)
    tick = getTickCount()

    if not interior then
        visible = false
        return
    end

    visible = true
    interiorInfo = {
        name = interiors[interior].name,
        type = interiors[interior].type,
        owner = interiors[interior].owner,
        price = interiors[interior].price,

        x = interiors[interior][currentInterior.side .. '_position'].x,
        y = interiors[interior][currentInterior.side .. '_position'].y,
        z = interiors[interior][currentInterior.side .. '_position'].z
    }

    removeEventHandler('onClientRender', root, renderInteriorInfo)
    addEventHandler('onClientRender', root, renderInteriorInfo)
end

function renderInteriorInfo()
    local progress = (getTickCount() - tick) / 250
    local alphaMul = interpolateBetween(
        visible and 0 or 1, 0, 0,
        visible and 1 or 0, 0, 0,
        progress, 'Linear'
    )

    if not visible and progress >= 1 then
        interiorInfo = false
        removeEventHandler('onClientRender', root, renderInteriorInfo)
        return
    end

    local wx, wy = getScreenFromWorldPosition(interiorInfo.x, interiorInfo.y, interiorInfo.z + 0.7)

    if not wy or not wy then return end

    local description = getInteriorInfoDescription(interiorInfo)

    local _h = resp(80)
    local _w = math.max(
        resp(300),
        _h + resp(20) + dxGetTextWidth(interiorInfo.name, 1, SFPro20),
        _h + resp(20) + dxGetTextWidth(description, 1, SFPro15)
    ) * alphaMul
    local _x, _y = wx - _w/2, wy - _h/2

    --> Shadow
    local size_x = resp(45)
    local size_y = resp(15)
    local color = tocolor(0, 0, 0, 100 * alphaMul)

    dxDrawImage(_x - size_x, _y - size_y, _w + size_x*2, _h + size_y*2, ':core/assets/shadow.png', 0, 0, 0, color)

    --> BackG
    local radius = resp(10)
    local color = tocolor(230, 230, 230, 255 * alphaMul)

    drawRoundedRectangle(_x, _y, _w, _h, color, radius)

    --> Icon
    local color = tocolor(205, 115, 95, 255 * alphaMul)--tocolor(150, 150, 150, 255 * alphaMul)

    dxDrawImage(_x, _y, _h, _h, 'client/icons/' .. interiorTypes[interiorInfo.type].icon .. '.png', 0, 0, 0, color)

    --> Interior name
    local color = tocolor(205, 115, 95, 255 * alphaMul)--tocolor(150, 150, 150, 255 * alphaMul)

    dxDrawText(interiorInfo.name, _x + _h, _y, _x + _w, _y + _h/2, color, 1, SFPro20, 'center', 'center', true)

    --> Description
    local color = tocolor(150, 150, 150, 255 * alphaMul)

    dxDrawText(description, _x + _h, _y + _h/2, _x + _w, _y + _h, color, 1, SFPro15, 'center', 'top', true)
end

function getInteriorInfoDescription(interior)
    local description = 'Tulajdonos: Edward Reyes'

    if interior.type == 1 then
        description = 'Önkormányzati'
    elseif interior.owner == 0 then
        description = 'Eladó! Ár: ' .. interior.price .. 'Ft'
    end

    return description
end