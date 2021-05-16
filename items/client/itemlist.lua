local boxes = 6
local panelData = {
    visible = false,
    hover = false,
    move = false,
    scroll = 0,
    tick = 0,

    w = resp(300),
    h = resp(400),
    x = mx - resp(150),
    y = my - resp(200)
}

function openItemList()
    panelData.visible = true
    panelData.tick = getTickCount()

    removeEventHandler('onClientRender', root, renderItemList)
    addEventHandler('onClientRender', root, renderItemList)

    removeEventHandler('onClientClick', root, clickItemList)
    addEventHandler('onClientClick', root, clickItemList)
end

function closeItemList()
    panelData.visible = false
    panelData.tick = getTickCount()

    removeEventHandler('onClientClick', root, clickItemList)
end

function renderItemList()
    panelData.hover = false

    if panelData.move then
        if isCursorShowing() then
            local cursorX, cursorY = getCursorPosition()

            panelData.x = cursorX*sx - panelData.move.x
            panelData.y = cursorY*sy - panelData.move.y
        else
            panelData.move = false
        end
    end

    --> Fade in
    local progress = (getTickCount() - panelData.tick) / 200
    local alphaMul = interpolateBetween(
        panelData.visible and 0 or 1, 0, 0,
        panelData.visible and 1 or 0, 0, 0,
        progress, 'Linear'
    )

    if not panelData.visible and progress > 1 then
        removeEventHandler('onClientRender', root, renderItemList)
    end

    --> Header
    local headerH = resp(40)
    local headerY = panelData.y - headerH

    local radius = resp(10)
    local color = tocolor(205, 115, 95, 255 * alphaMul)

    dxDrawImage(panelData.x, headerY, radius, radius, corner, 0, 0, 0, color)
    dxDrawImage(panelData.x + panelData.w - radius, headerY, radius, radius, corner, 90, 0, 0, color)
    dxDrawRectangle(panelData.x + radius, headerY, panelData.w - radius*2, headerH, color)

    dxDrawRectangle(panelData.x, headerY + radius, panelData.w, headerH - radius, color)

    if isInArea(panelData.x, headerY, panelData.w, headerH) then
        panelData.hover = 'panelMove'
    end

    --> Header text
    local headerText = 'Itemlista'
    local color = tocolor(255, 255, 255, 255 * alphaMul)

    dxDrawText(headerText, panelData.x, headerY, panelData.x + panelData.w, headerY + headerH, color, 1, _fonts[16], 'center', 'center')

    --> Close button
    local x, y, x2, y2 = panelData.x + panelData.w - headerH, headerY, panelData.x + panelData.w, headerY + headerH

    local r, g, b
    if isInArea(x, y, headerH, headerH) then
        panelData.hover = 'close'
        r, g, b = colorInterpolation('list:close', 170, 170, 170, 0, 200)
    else
        r, g, b = colorInterpolation('list:close', 255, 255, 255, 0, 200)
    end
    local close = tocolor(r, g, b, 255 * alphaMul)

    dxDrawText('', x, y, x2, y2, close, 1, _fonts.icon16, 'center', 'center')

    --> Items
    local boxH = panelData.h / boxes
    for i = 1, boxes do
        local y = panelData.y + boxH * (i - 1)

        local color = isInArea(panelData.x, y, panelData.w, boxH)
            and tocolor(colorInterpolation('list:' .. panelData.scroll + i, 255, 255, 255, 255 * alphaMul, 200))
            or  tocolor(colorInterpolation('list:' .. panelData.scroll + i, 230, 230, 230, 255 * alphaMul, 200))

        if i ~= boxes then
            dxDrawRectangle(panelData.x, y, panelData.w, boxH, color)

            local color = tocolor(170, 170, 170, 255 * alphaMul)
            dxDrawRectangle(panelData.x, y + boxH - 0.5, panelData.w, 0.5, color)
        else
            dxDrawImage(panelData.x, y + boxH - radius, radius, radius, corner, 270, 0, 0, color)
            dxDrawImage(panelData.x + panelData.w - radius, y + boxH - radius, radius, radius, corner, 180, 0, 0, color)
            dxDrawRectangle(panelData.x + radius, y + boxH - radius, panelData.w - radius*2, radius, color)

            dxDrawRectangle(panelData.x, y, panelData.w, boxH - radius, color)
        end

        if _items[panelData.scroll + i] then
            local size = boxH - _padding*2

            drawItemSlot(panelData.x + _padding, y + _padding, size, alphaMul)
            drawItem(panelData.x + _padding, y + _padding, size, false, {itemID = panelData.scroll + i, value = 0}, 1, alphaMul)

            local id = tostring(panelData.scroll + i)
            local itemName = getItemName(panelData.scroll + i)

            local color = isInArea(panelData.x, y, panelData.w, boxH)
                and tocolor(colorInterpolation('list_text:' .. panelData.scroll + i, 235, 130, 160, 255 * alphaMul, 200))
                or  tocolor(colorInterpolation('list_text:' .. panelData.scroll + i, 170, 170, 170, 255 * alphaMul, 200))

            dxDrawText(id, 0, y, panelData.x + panelData.w - _padding, y + boxH, color, 1, _fonts[20], 'right', 'center')
            dxDrawText(itemName, panelData.x + size + _padding*2, y, 0, y + boxH/2, color, 1, _fonts[14], 'left', 'bottom')

            if isInArea(panelData.x, y, panelData.w, boxH) then
                panelData.hover = panelData.scroll + i
            end
        end
    end
end

function clickItemList(button, state, clickX, clickY)
    if button == 'left' then
        if state == 'down' then
            if panelData.hover == 'close' then
                closeItemList()
                return
            end

            if panelData.hover == 'panelMove' then
                panelData.move = {
                    x = clickX - panelData.x,
                    y = clickY - panelData.y
                }
                return
            end

            if tonumber(panelData.hover) then
                local result = triggerServerEvent('items.giveItem', localPlayer, localPlayer, nil, tonumber(panelData.hover))
                if result then
                    outputChatBox(exports.core:getServerTag('info') .. 'Lekértél egy itemet.', 0, 0, 0, true)
                else
                    outputChatBox(exports.core:getServerTag('error') .. 'Nincsen nálad elég hely!', 0, 0, 0, true)
                end
            end
        else
            panelData.move = false
        end
    end
end

bindKey('mouse_wheel_down', 'down',
    function()
        if panelData.visible then
            if panelData.scroll + boxes < #_items then
                panelData.scroll = panelData.scroll + 1
            end
        end
    end
)

bindKey('mouse_wheel_up', 'down',
    function()
        if panelData.visible then
            if panelData.scroll > 0 then
                panelData.scroll = panelData.scroll - 1
            end
        end
    end
)

addCommandHandler('itemlist', openItemList)