sx, sy = guiGetScreenSize()
mx, my = sx/2, sy/2

--> Config
_itemSize = resp(45)
_padding = resp(5)

panelData = {
    move = false,
    hover = false,

    fade = 0,
    fadeState = true,

    size = {
        x = (_rowSlots * (_itemSize + _padding)) + _padding,
        y = ((_slots / _rowSlots) * (_itemSize + _padding)) + _padding,
    },
}

local currentElement = false
local currentItems = false
local currentMoney = 0

local slotHover = false
local itemMove = false
local stack = {
    gui = false,
    value = false,
}
local tooltipData = false

addEventHandler('onClientElementDataChange', root,
    function(key, _, value)
        if key == 'inventoryElement' then
            if source == localPlayer then
                currentElement = value
            end
        elseif key == 'inventory' then
            if source == currentElement and currentItems ~= value then
                currentItems = value or {}
            end
        elseif key == 'character.money' then
            if source == currentElement then
                currentMoney = value
            end
        end
    end
)

addEventHandler('onClientResourceStart', resourceRoot,
    function()
        setElementData(localPlayer, 'inventory', false)

        panelData.position = {
            x = mx - panelData.size.x/2,
            y = my - panelData.size.y/2,
        }

        --openInventory(localPlayer)
    end
)

function drawItemSlot(x, y, size, alpha)
    local color = tocolor(190, 185, 170, 255 * alpha)
    local radius = resp(5)

    dxDrawRectangle(x, y, size, size, color)

    return isInArea(x, y, size, size)
end

function drawItem(x, y, size, hover, item, count, alpha, postGUI)
    local image = getItemImage(item.itemID)
    local color = tocolor(255, 255, 255, 255 * alpha)

    dxDrawImage(x, y, size, size, image, 0, 0, 0, color, postGUI)

    if count > 1 then
        dxDrawText(count, x, y, x + size, y + size, color, 1, 'default-bold', 'right', 'bottom', false, false, postGUI)
    end

    if hover and not itemMove then
        tooltipData = {
            getItemName(item.itemID)
        }

        if item.itemID == 1 then
            table.insert(tooltipData, 'ID: ' .. item.value)
        end
    end
end

function openInventory(element)
    currentElement = element
    currentItems = getElementItems(element)
    
    if getElementType(element) == 'player' then
        currentMoney = getElementData(element, 'character.money')
    end

    if not currentItems then
        currentItems = {}
        triggerServerEvent('items.loadElementItems', currentElement, currentElement)
    end

    setElementData(localPlayer, 'inventoryElement', currentElement)

    panelData.move = false
    panelData.fade = getTickCount()
    panelData.fadeState = true
    slotHover = false
    itemMove = false

    if isElement(panelData.stack) then
        destroyElement(panelData.stack)
    end

    stack.active = false
	stack.value = '0'
	stack.gui = guiCreateEdit(9999, 9999, 0, 0, '0', false)
	guiEditSetMaxLength(stack.gui, 4)
	addEventHandler('onClientGUIChanged', stack.gui,
        function()
            local currentText = guiGetText(stack.gui)
            if (currentText == '') then 
                stack.value = '0'
                guiSetText(source, stack.value)
            end
            
            if (tonumber(currentText)) then 
                stack.value = tostring(math.abs(tonumber(currentText)))
                guiSetText(source, tostring(stack.value))
            else
                guiSetText(source, stack.value)
            end
	    end
    )

    removeEventHandler('onClientRender', root, renderInventory)
    addEventHandler('onClientRender', root, renderInventory)

    removeEventHandler('onClientClick', root, clickInventory)
    addEventHandler('onClientClick', root, clickInventory)
end

function closeInventory()
    panelData.fade = getTickCount()
    panelData.fadeState = false

    removeEventHandler('onClientClick', root, clickInventory)
end

function renderInventory()
    if not areFontsLoaded() then return end
    if not currentItems then return end

    panelData.hovered = false
    slotHover = false

    local _x, _y, _w, _h = panelData.position.x, panelData.position.y, panelData.size.x, panelData.size.y

    --> Animation
    local progress = (getTickCount() - panelData.fade) / 150
    local alphaMul = interpolateBetween(
        panelData.fadeState and 0 or 1, 0, 0,
        panelData.fadeState and 1 or 0, 0, 0,
        progress, 'Linear'
    )

    if not panelData.fadeState and progress >= 1 then
        setElementData(localPlayer, 'inventoryElement', false)
        currentItems = {}

        if isElement(panelData.stack) then
            destroyElement(panelData.stack)
        end    

        removeEventHandler('onClientRender', root, renderInventory)
        return
    end

    local cursorX, cursorY = getCursorPosition()

    --> Panel movement
    if panelData.move then
        if isCursorShowing() then
            panelData.position = {
                x = (cursorX * sx) - panelData.move.x,
                y = (cursorY * sy) - panelData.move.y
            }
        else
            panelData.move = nil
        end
    end

    local headerH = resp(40)
    local headerY = _y - headerH
    
    --> Shadow
    local color = tocolor(0, 0, 0, 120 * alphaMul)
    local size_x = resp(90)
    local size_y = resp(50)

    dxDrawImage(_x - size_x, _y - size_y - headerH, _w + size_x*2, _h + size_y*2 + headerH, ':core/assets/shadow.png', 0, 0, 0, color)

    --> Background
    local color = tocolor(240, 240, 240, 255 * alphaMul)

    dxDrawRectangle(_x, _y, _w, _h, color)

    --> Header
    local radius = resp(10)
    local color = tocolor(205, 115, 95, 255 * alphaMul)

    dxDrawImage(_x, headerY, radius, radius, corner, 0, 0, 0, color)
    dxDrawImage(_x + _w - radius, headerY, radius, radius, corner, 90, 0, 0, color)
    dxDrawRectangle(_x + radius, headerY, _w - radius*2, radius, color)

    dxDrawRectangle(_x, headerY + radius, _w, headerH - radius, color)

    if isInArea(_x, headerY, _w, headerH) then
        panelData.hovered = 'panelMove'
    end

    --> Header text
    local headerText = getElementHeaderText(currentElement)
    local color = tocolor(255, 255, 255, 255 * alphaMul)

    dxDrawText(headerText, _x, headerY, _x + _w, headerY + headerH, color, 1, _fonts[16], 'center', 'center')

    --> Money
    if getElementType(currentElement) == 'player' then
        local text = 'Pénztárca: ' .. (currentMoney or 0) .. 'Ft'
        local color = tocolor(255, 255, 255, 255 * alphaMul)

        dxDrawText(text, _x + _padding, headerY, _x + _w, headerY + headerH, color, 1, _fonts[13], 'left', 'center')
    end

    --> Stack
    local w, h = resp(50), headerH - (3 * _padding)
	local x, y = _x + _w - w - _padding, headerY + (1.5 * _padding)

    if isInArea(x, y, w, h) then 
		panelData.hovered = 'stack'
	end

    local stackColor = tocolor(255, 255, 255, 255 * alphaMul)
    local textColor = tocolor(0, 0, 0, 255 * alphaMul)

    drawRoundedRectangle(x, y, w, h, stackColor)
    dxDrawText(stack.value, x + _padding, y, w, y + h, textColor, 1, _fonts[12], 'left', 'center')

	guiEditSetCaretIndex(stack.gui, string.len(guiGetText(stack.gui)))

    --> Slots
    local row, column = 0, 0
    for slot = 1, _slots do
        local itemX = _x + _padding + ((_itemSize + _padding) * column)
        local itemY = _y + _padding + ((_itemSize + _padding) * row)
        local postGUI = false

        local hover = drawItemSlot(itemX, itemY, _itemSize, alphaMul)
        if hover then
            slotHover = {
                x = itemX,
                y = itemY,
                slot = slot
            }
        end

        if itemMove and itemMove.slot == slot then
            if itemMove.count and (currentItems[slot].count - itemMove.count) > 0 then
                local count = currentItems[slot].count - itemMove.count
                drawItem(itemX, itemY, _itemSize, hover, currentItems[slot], count, alphaMul, false)
            end

            if isCursorShowing() then
                itemX = (cursorX * sx) - itemMove.x
                itemY = (cursorY * sy) - itemMove.y
                postGUI  = true

            else
                itemMove = false
            end
        end

        if currentItems[slot] then
            local count = currentItems[slot].count

            if itemMove and itemMove.slot == slot then
                if itemMove.count then
                    count = itemMove.count
                end
            end

            drawItem(itemX, itemY, _itemSize, hover, currentItems[slot], count, alphaMul, postGUI)
        end

        column = column + 1
		if (column >= _rowSlots) then 
			row = row + 1
			column = 0
		end
    end
end

function clickInventory(button, state, clickX, clickY, wx, wy, wz, clickedElement)
    if button == 'left' then
        if state == 'down' then
            if panelData.hovered == 'stack' then
                guiBringToFront(stack.gui)
                return
            elseif panelData.hovered == 'panelMove' then
                panelData.move = {
                    x = clickX - panelData.position.x,
                    y = clickY - panelData.position.y
                }

                removeEventHandler('onClientRender', root, renderInventory)
                addEventHandler('onClientRender', root, renderInventory)

                return
            end

            if slotHover then
                if currentItems[slotHover.slot] then
                    local hoverItem = currentItems[slotHover.slot]
                    if hoverItem.dbID < 0 then
                        return
                    end

                    local stackValue = tonumber(stack.value)

                    local count = false
                    if stackValue > 0 and stackValue <= hoverItem.count then
                        count = stackValue
                    end

                    itemMove = {
                        x = clickX - slotHover.x,
                        y = clickY - slotHover.y,
                        slot = slotHover.slot,
                        count = count,
                    }
                end
            end
        else
            panelData.move = false

            if not slotHover and itemMove and clickedElement and isElement(clickedElement) then --Átadás
				if clickedElement == currentElement then 
					itemMove = false
					return
				end

				if getDistanceBetweenPoints3D(wx, wy, wz, getElementPosition(currentElement)) > 4 then 
					itemMove = false
					outputChatBox(exports.core:getServerTag('error') .. 'Túl messze vagy a kiválszott elemtől.', 255, 255, 255, true)
					return
				end
 
				local sourceItem = currentItems[itemMove.slot]

				if getElementType(clickedElement) == 'trash' then 
					if currentElement == localPlayer then 
                        if itemMove.count and (sourceItem.count - itemMove.count) > 0 then
                            currentItems[itemMove.slot].count = sourceItem.count - itemMove.count
                        else
                            currentItems[itemMove.slot] = nil
                            triggerServerEvent('items.deleteItem', localPlayer, currentElement, sourceItem)
                        end

                        setElementItems(currentElement, currentItems)
					end

					itemMove = false
					return
				end

                if getElementType(clickedElement) == 'keycopier' then
                    if currentElement == localPlayer then
                        copyKey(sourceItem.itemID, sourceItem.count, sourceItem.value)
                    end

                    itemMove = false
                    return
                end

				if sourceItem.duty == 1 then 
					outputChatBox(exports.core:getServerTag('error') .. 'Duty itemet nem tudsz átadni', 255, 255, 255, true)
					return
				end

				local targetItems = getElementItems(clickedElement)
				if getElementID(clickedElement) and getElementID(clickedElement) <= 0 or not targetItems then 
					itemMove = false
					outputChatBox(exports.core:getServerTag('error') .. 'Kiválaszottt elem nem rendelkezik tárterülettel.', 255, 255, 255, true)
					return
				end

				local targetSlot = hasItemSpace(clickedElement, sourceItem.itemID, sourceItem.count)
				if targetSlot then 
					if currentElement ~= localPlayer and clickedElement ~= localPlayer then 
						itemMove = false
						return
					end

					targetItems[targetSlot] = deepcopy(sourceItem)
                    targetItems[targetSlot].count = itemMove.count or sourceItem.count
					triggerServerEvent('items.updateItemOwner', localPlayer, clickedElement, targetSlot, sourceItem)
					setElementItems(clickedElement, targetItems)

                    if targetItems[targetSlot].count < sourceItem.count then
                        currentItems[itemMove.slot].count = sourceItem.count - itemMove.count
                    else
					    currentItems[itemMove.slot] = nil
                    end
					setElementItems(currentElement, currentItems)

					local targetType = getElementType(clickedElement)
					local sourceType = getElementType(currentElement)
					if sourceType == 'player' then  --Berakás/átadás
						local texts = {
							['vehicle'] = 'csomagtartóba',
							['safe'] = 'széfbe'
						}

						if texts[targetType] then 
							outputChatBox(getPlayerName(currentElement) .. ' berak egy tárgyat a '..texts[targetType]..'. ('..getItemName(sourceItem.itemID)..')')
						else 
							if targetType == 'player' then 
								outputChatBox(getPlayerName(currentElement) .. ' átad egy tárgyat '..getPlayerName(clickedElement)..'-nak/nek. ('..getItemName(sourceItem.itemID)..')')
							end
						end
					else
						local texts = {
							['vehicle'] = 'csomagtartóból',
							['safe'] = 'széfből'
						}

						if texts[sourceType] then 
							outputChatBox(getPlayerName(localPlayer) .. ' kivesz egy tárgyat a '..texts[sourceType]..'. ('..getItemName(sourceItem.itemID)..')')
						end
					end
				else 
					outputChatBox(exports.core:getServerTag('error') .. 'Kiválaszott elemnél nincs elegendő hely!', 255, 255, 255, true)
				end
			end
            
            if itemMove and slotHover and itemMove.slot ~= slotHover.slot and currentItems[itemMove.slot] then
                local sourceItem = currentItems[itemMove.slot]
                if currentItems[slotHover.slot] then
                    local hoverItem = currentItems[slotHover.slot]

                    if isItemStackable(hoverItem.itemID) and hoverItem.itemID == sourceItem.itemID then
                        if itemMove.count then 
							currentItems[slotHover.slot].count = hoverItem.count + itemMove.count

							if (sourceItem.count - itemMove.count) <= 0 then 
								currentItems[itemMove.slot] = nil
								triggerServerEvent('items.deleteItem', localPlayer, currentElement, sourceItem)
							else
								currentItems[itemMove.slot].count = sourceItem.count - itemMove.count
							end
						else
							currentItems[slotHover.slot].count = hoverItem.count + sourceItem.count
							currentItems[itemMove.slot] = nil
							triggerServerEvent('items.deleteItem', localPlayer, currentElement, sourceItem)
						end
						setElementItems(currentElement, currentItems)
                    end
                else
                    if isItemStackable(sourceItem.itemID) and itemMove.count then
                        if (sourceItem.count - itemMove.count) <= 0 then
                            currentItems[itemMove.slot] = nil
                            triggerServerEvent('items.deleteItem', localPlayer, currentElement, sourceItem)
                        else
                            currentItems[itemMove.slot].count = sourceItem.count - itemMove.count
                        end

                        setElementItems(currentElement, currentItems)
						triggerServerEvent('items.giveItem', localPlayer, currentElement, slotHover.slot, sourceItem.itemID, itemMove.count, sourceItem.value, sourceItem.data, sourceItem.duty)
                    else
                        currentItems[slotHover.slot] = currentItems[itemMove.slot]
						currentItems[itemMove.slot] = nil
						setElementItems(currentElement, currentItems)
                    end
                end
            end

            itemMove = false
        end
    elseif button == 'right' then
        if state == 'down' then
            if currentElement == localPlayer then
                if not itemMove and slotHover then
                    if currentItems[slotHover.slot] then
                        useItem(currentItems[slotHover.slot], slotHover.slot)
                    end
                end
            end
        end
    end
end

addEventHandler('onClientRender', root,
    function()
        local data = tooltipData
        if data and isCursorShowing() then 
            local text = table.concat(data, '\n')
            local width, height = 0, dxGetFontHeight(1, _fonts[13]) * #data + resp(15)
            for _, _text in pairs(data) do
                width = math.max(
                    width,
                    dxGetTextWidth(_text, 1, _fonts[13])
                )
            end
            width = width + resp(20)

            local cursorX, cursorY = getCursorPosition()
            cursorX, cursorY = cursorX*sx, cursorY*sy + resp(10)

            local x = cursorX - width/2

            local shadow = tocolor(0, 0, 0, 70)
            local size_x = resp(15)
            local size_y = resp(13)

            dxDrawImage(x - size_x, cursorY - size_y, width + size_x*2, height + size_y*2, ':core/assets/shadow.png', 0, 0, 0, shadow)

            local radius = resp(7)
            local color = tocolor(230, 230, 230)

            drawRoundedRectangle(x, cursorY, width, height, color, radius)
            dxDrawText(text, x, cursorY, x + width, cursorY + height, tocolor(100, 100, 100), 1, _fonts[13], 'center', 'center')
        end

        tooltipData = false
    end
, _, 'low')

function toggleInventory()
    if not getElementData(localPlayer, 'character.id') then return end

    if not currentElement then
        openInventory(localPlayer)
    else
        closeInventory()
    end
end

bindKey('i', 'down', toggleInventory)