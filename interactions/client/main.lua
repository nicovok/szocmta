imports = {
    exports.core:getFunction('resp'),
    exports.core:getFunction('isInArea'),
    exports.core:getFunction('drawRoundedRectangle'),
    exports.core:getFunction('colorInterpolation')
}

pcall(loadstring(table.concat(imports, '\n')))

currentElement = false
currentElementType = false
_interactions = {}
_title = ''

element_types = {
    player = true,
    ped = true,
    vehicle = true,
    object = true,
}

header = resp(50)
box_h = resp(40)
hovered = false

function loadFonts()
    SFPro15 = exports.core:getFont('SFPro', resp(15))
    SFPro13 = exports.core:getFont('SFPro', resp(13))
    FontA11 = exports.core:getFont('FontAwesome', resp(11))
end

addEventHandler('onClientClick', root,
    function(button, state, _, _, _, _, _, element)
        if state ~= 'down' then return end

        if currentElement then
            if hovered then
                _interactions[hovered].use(currentElement, hovered)
            end

            return
        end

        if button ~= 'right' then return end
        if not isElement(element) then return end
        if not element_types[getElementType(element)] then return end

        interactWith(element)
    end
)

function interactWith(element)
    if currentElement then
        stopInteraction()
    end

    currentElement = element
    currentElementType = getElementType(element)

    _title = getTitle(currentElement, currentElementType)
    _interactions = getInteractions(currentElement, currentElementType)

    addEventHandler('onClientRender', root, renderInteractionElement)

    if #_interactions <= 1 then
        stopInteraction()
    end
end

function stopInteraction()
    currentElement = false

    removeEventHandler('onClientRender', root, renderInteractionElement)
end

function renderInteractionElement()
    hovered = false

    local x, y, z = getElementPosition(currentElement)
    local _x, _y, dist = getScreenFromWorldPosition(x, y, z)

    if not (_x and _y) then return end

    if dist > 10 then
        stopInteraction()
    end

    local _w = math.max(
        resp(200),
        dxGetTextWidth(_title, 1, SFPro15) + resp(20)
    )
    local _h = header + box_h * #_interactions
    _x, _y = _x - _w/2, _y - _h/2

    --dxDrawRectangle(_x, _y, _w, _h)

    local shadow_size = resp(35)
    local shadow_color = tocolor(0, 0, 0, 50)

    dxDrawImage(_x - shadow_size, _y - shadow_size, _w + shadow_size*2, _h + shadow_size*2, ':core/assets/shadow.png', 0, 0, 0, shadow_color)

    --> Header
    local color = tocolor(210, 118, 97)
    local radius = resp(10)

    dxDrawImage(_x, _y, radius, radius, corner, 0, 0, 0, color)
    dxDrawImage(_x + _w - radius, _y, radius, radius, corner, 90, 0, 0, color)
    dxDrawRectangle(_x + radius, _y, _w - radius*2, radius, color)

    dxDrawRectangle(_x, _y + radius, _w, header - radius, color)

    --> Title
    local color = tocolor(230, 230, 230)

    dxDrawText(_title, _x, _y, _x + _w, _y + header, color, 1, SFPro15, 'center', 'center')

    --> Interaction buttons
    for i, data in pairs(_interactions) do
        local y = _y + header + box_h * (i - 1)

        local margin_l = resp(40)

        local r, g, b
        local r2, g2, b2
        if isInArea(_x, y, _w, box_h) then
            hovered = i

            r, g, b = colorInterpolation('bg-' .. i, 255, 255, 255, 0, 300)
            r2, g2, b2 = colorInterpolation('text-' .. i, 235, 130, 160, 0, 300)
        else
            r, g, b = colorInterpolation('bg-' .. i, 240, 240, 240, 0, 300)
            r2, g2, b2 = colorInterpolation('text-' .. i, 190, 190, 190, 0, 300)
        end

        local color = tocolor(r, g, b)
        local text_color = tocolor(r2, g2, b2)

        if i == #_interactions then
            dxDrawRectangle(_x, y, _w, box_h - radius, color)

            dxDrawImage(_x, y + box_h - radius, radius, radius, corner, 270, 0, 0, color)
            dxDrawImage(_x + _w - radius, y + box_h - radius, radius, radius, corner, 180, 0, 0, color)

            dxDrawRectangle(_x + radius, y + box_h - radius, _w - radius*2, radius, color)
        else
            dxDrawRectangle(_x, y, _w, box_h, color)
        end

        dxDrawText(data.icon, _x, y, _x + margin_l, y + box_h, text_color, 1, FontA11, 'center', 'center')

        dxDrawText(data.name, _x + margin_l, y, _x + _w, y + box_h, text_color, 1, SFPro13, 'left', 'center')
    end
end

addEventHandler('onClientResourceStart', resourceRoot, loadFonts)
addEventHandler('onClientResourceStart', getResourceRootElement(getResourceFromName('core')), loadFonts)