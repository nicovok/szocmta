local eatUse = {
    show = false,
    hover = false,
    last = 0,
}

addEvent('onClientPlayerUseItem', true)

function useItem(item, slot)
    if isItemEatable(item.itemID) then 
        eatUse.show = not eatUse.show
        if eatUse.show then 
            eatUse.item = item
            eatUse.itemSlot = slot
            eatUse.progress = 1
            addEventHandler('onClientRender', root, eatRender)
            addEventHandler('onClientClick', root, eatClick)
        else 
            eatClose()
        end
    end

    triggerServerEvent('onPlayerUseItem', localPlayer, item, slot)
end

function eatRender()
    eatUse.hover = false

    --> Line
    local lineW, lineH = resp(270), resp(25)
    local lineX, lineY = mx - lineW/2, sy - lineH*2

    local borderRadius = resp(10)
    local progressRadius = resp(7)

    local bgColor = tocolor(235, 225, 205)
    local progressColor = tocolor(210, 120, 95)

    drawRoundedRectangle(lineX, lineY, lineW, lineH, bgColor, borderRadius)
    drawRoundedRectangle(lineX + 3, lineY + 3, (lineW - 6) * eatUse.progress, lineH - 6, progressColor, progressRadius)

    local size = resp(50)
    local x, y = mx - size/2, lineY - resp(20) - size

    eatUse.hover = isInArea(x, y, size, size)

    drawRoundedRectangle(x, y, size, size, bgColor, borderRadius)
    drawItem(x, y, size, hover, eatUse.item, eatUse.item.count, 1)
end

function eatClick(button, state)
    if eatUse.hover then 
        if state == 'down' then
            if button == 'right' then 
                if eatUse.last + 2000 > getTickCount() then 
                    outputChatBox(exports.core:getServerTag('error') .. 'Ilyen gyorsan nem tudsz enni', 255, 255, 255, true)
                    return
                end

                eatUse.last = getTickCount()
                eatUse.progress = eatUse.progress - 0.1
                triggerServerEvent('items.eatUseServer', localPlayer, localPlayer, eatUse.item)

                if eatUse.progress <= 0 then 
                    eatClose()
                end

                --setElementData(localPlayer, 'character -> hunger', math.min(100, (getElementData(localPlayer, 'character -> hunger') or 0) + math.random(5, 10)))
            elseif button == 'left' then 
                eatClose()
            end
        end
    end
end

function eatClose()
    if eatUse.item then 
        outputChatBox(getPlayerName(localPlayer) .. ' eldob egy tárgyat. ('..getItemName(eatUse.item.itemID)..')')
        modifyItemCount(eatUse.itemSlot)
    end

    removeEventHandler('onClientRender', root, eatRender)
    removeEventHandler('onClientClick', root, eatClick)

    eatUse.item = nil
    eatUse.hover = false
    eatUse.progress = false
    eatUse.show = false
end

function modifyItemCount(slot)
    local currentItems = getElementItems(localPlayer)
    if currentItems then 
        if currentItems[slot] then 
            currentItems[slot].count = currentItems[slot].count - 1

            if currentItems[slot].count <= 0 then 
                triggerServerEvent('items.deleteItem', localPlayer, localPlayer, currentItems[slot])
                currentItems[slot] = nil
            end

            setElementItems(localPlayer, currentItems)
        end
    end
end