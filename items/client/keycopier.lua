local promptData = false

function copyKey(itemID, value, count)
    if promptData then
        return
    end

    if not isItemKey(itemID) then
        outputChatBox(exports.core:getServerTag('error') .. 'Csak kulcsokat másolhatsz le.', 0, 0, 0, true)
        return
    end

    if count > 1 then
        outputChatBox(exports.core:getServerTag('error') .. 'Egyszerre csak egy kulcsot másolhatsz le.', 0, 0, 0, true)
        return
    end

    promptData = {
        itemID = itemID,
        id = value
    }

    addEventHandler('onClientRender', root, renderPrompt, _, 'normal-1')
end

function renderPrompt()
    local w, h = resp(150), resp(200)
    local x, y = mx - w/2, my - h/2

    --> Shadow
    local shadowSize = resp(40)
    dxDrawImage(x - shadowSize/2, y - shadowSize/2, w + shadowSize, h + shadowSize, ':core/assets/shadow.png', 0, 0, 0, tocolor(0, 0, 0, 100))

    --> Background
    local radius = resp(10)
    local color = tocolor(220, 220, 220)

    drawRoundedRectangle(x, y, w, h, color, radius)

    --> Title
    local textY = y + resp(10)
    local color = tocolor(150, 150, 150)

    dxDrawText('Biztosan lemásolod?', x, textY, x + w, 0, color, 1, _fonts[14], 'center', 'top', false, true)

    --> Icon    
    local image = getItemImage(promptData.itemID)
    local size = resp(50)
    local _y = y + resp(70)
    local _x = x + w/2 - size/2

    local shadowSize = resp(15)
    dxDrawImage(_x - shadowSize/2, _y - shadowSize/2, size + shadowSize, size + shadowSize, ':core/assets/shadow.png', 0, 0, 0, tocolor(0, 0, 0, 100))

    local hover = drawItemSlot(_x, _y, size, 1)
    drawItem(_x, _y, size, hover, { itemID = promptData.itemID, value = promptData.id }, 1, 1)

    --> Button
    local color = tocolor(205, 115, 95)
    local x, y, w, h = x + resp(5), y + h - resp(45), w - resp(10), resp(40)

    drawRoundedRectangle(x, y, w, h, color, radius)

    if isInArea(x, y, w, h) then
        local shadow_x, shadow_y = resp(25), resp(10)
        dxDrawImage(x - shadow_x/2, y - shadow_y/2, w + shadow_x, h + shadow_y, ':core/assets/shadow.png', 0, 0, 0, color)

        if getKeyState('mouse1') then
            triggerServerEvent('items.giveItem', localPlayer, localPlayer, nil, promptData.itemID, 1, promptData.id)
            outputChatBox(exports.core:getServerTag('info') .. 'Lemásoltál egy kulcsot.', 0, 0, 0, true)

            promptData = false
            removeEventHandler('onClientRender', root, renderPrompt)
        end
    end
end