sx, sy = guiGetScreenSize()
mx, my = sx/2, sy/2

visible = false
resources = false

panelData = {
    hover = false,
    move = false,
    resize = false,
    scroll = 0,

    size = {
        x = resp(800),
        y = resp(450),
    }
}

panelData.position = {
    x = mx - panelData.size.x/2,
    y = my - panelData.size.y/2
}

function loadFonts()
    Roboto12 = exports.core:getFont('Roboto', resp(12))
    RobotoBold14 = exports.core:getFont('RobotoMedium', resp(14))
    FontAwesome13 = exports.core:getFont('FontAwesome', resp(13))
end

addEventHandler('onClientResourceStart', root,
    function(res)
        if res == resource or res == getResourceFromName('core') then

            loadFonts()

            if res ~= resource then return end
        end
    end
)

registerEvent('manager.returnResources', root,
    function(response)
        resources = response
    end
)

addCommandHandler('manager',
    function()
        if not canOpenManager(localPlayer) then return end

        openManager()
    end
)

function openManager()
    visible = true

    resources = false
    triggerServerEvent('manager.requestResources', root)

    removeEventHandler('onClientRender', root, renderManager)
    addEventHandler('onClientRender', root, renderManager)

    removeEventHandler('onClientClick', root, clickManager)
    addEventHandler('onClientClick', root, clickManager)
end

function closeManager()
    visible = false
    resources = false

    removeEventHandler('onClientRender', root, renderManager)
    removeEventHandler('onClientClick', root, clickManager)
end

function renderManager()
    panelData.hover = false

    local cursorX, cursorY = getCursorPosition()

    --> Movement
    if panelData.move then
        if isCursorShowing() then
            panelData.position = {
                x = cursorX*sx - panelData.move.x,
                y = cursorY*sy - panelData.move.y
            }
        else
            panelData.move = false
        end
    end

    --> Sizing
    if panelData.resize then
        if isCursorShowing() then
            local x = cursorX*sx - panelData.position.x
            if x >= resp(150) and x <= resp(1300) then
                panelData.size.x = x
            else
                setCursorPosition(panelData.position.x + panelData.size.x, cursorY*sy)
            end

            local y = cursorY*sy - panelData.position.y
            if y >= resp(150) and y <= resp(800) then
                panelData.size.y = y
            else
                setCursorPosition(cursorX*sx, panelData.position.y + panelData.size.y)
            end
        else
            panelData.resize = false
        end
    end

    local area = resp(20)
    local x, y, w, h = panelData.position.x + panelData.size.x - area/2, panelData.position.y + panelData.size.y - area/2, area, area

    if isInArea(x, y, w, h) then
        panelData.hover = 'resize'

        local color = tocolor(255, 255, 255)
        local x, y = cursorX*sx, cursorY*sy

        dxDrawText('', x, y, x, y, color, 1, FontAwesome13, 'center', 'center', false, false, true)
    end

    --> Background
    local color = tocolor(30, 30, 30, 250)

    dxDrawRectangle(panelData.position.x, panelData.position.y, panelData.size.x, panelData.size.y, color)

    --> Header
    local headerH = resp(35)
    local x, y, w, h = panelData.position.x, panelData.position.y, panelData.size.x, headerH
    local color = tocolor(50, 50, 50, 255)

    dxDrawRectangle(x, y, w, h, color)

    local padding = resp(10)
    local color = tocolor(255, 255, 255)

    dxDrawText('Resource Kezelő', x + padding, y, 0, y + h, color, 1, RobotoBold14, 'left', 'center')

    if isInArea(x, y, w, h) then
        panelData.hover = 'header'
    end

    --> Close
    local x, y, w, h = panelData.position.x + panelData.size.x - headerH, panelData.position.y, headerH, headerH
    
    local color
    if isInArea(x, y, w, h) then
        panelData.hover = 'close'

        color = tocolor(colorInterpolation('close', 236, 112, 99, 255, 500))
    else
        color = tocolor(colorInterpolation('close', 255, 255, 255, 255, 1500))
    end

    dxDrawText('', x, y, x + w, y + h, color, 1, FontAwesome13, 'center', 'center')

    --> Display resources
    if not resources then
        local x, y, w, h = panelData.position.x, panelData.position.y + headerH, panelData.size.x, panelData.size.y - headerH
        local color = tocolor(255, 255, 255)

        dxDrawText('Betöltés...', x, y, x + w, y + h, color, 1, RobotoBold14, 'center', 'center')
        return
    end

    panelData.boxes = math.floor(panelData.size.y / 35)
    --panelData.boxes = colorInterpolation('boxes', panelData.boxes, 0, 0, 0, 100)
    local boxH = (panelData.size.y - headerH) / panelData.boxes

    for i = 1, panelData.boxes do
        local heightMul = i - 1
        local x, y, w, h = panelData.position.x, panelData.position.y + headerH + boxH * heightMul, panelData.size.x, boxH

        local color = isInArea(x, y, w, h) and tocolor(colorInterpolation('listHover:' .. i, 90, 90, 90, 255, 500)) or tocolor(colorInterpolation('listHover:' .. i, 50, 50, 50, i % 2 == 0 and 100 or 0, 1500))

        dxDrawRectangle(x, y, w, h, color)

        if resources[panelData.scroll + i] then
            local resource = resources[panelData.scroll + i]

            local color = resource.state == 'running' and tocolor(46, 204, 113) or tocolor(231, 76, 60)

            local size = resp(3)

            dxDrawRectangle(x, y, size, h, color)

            local padding = resp(10)

            dxDrawText(resource.name, x + padding, y, x + w, y + h, tocolor(255, 255, 255), 1, Roboto12, 'left', 'center')
        end
    end
end

function clickManager(button, state, clickX, clickY)
    if button == 'left' then
        if state == 'down' then
            if panelData.hover == 'close' then
                closeManager()
            elseif panelData.hover == 'header' then
                panelData.move = {
                    x = clickX - panelData.position.x,
                    y = clickY - panelData.position.y
                }
            elseif panelData.hover == 'resize' then
                panelData.resize = true
            end
        else
            panelData.move = false
            panelData.resize = false
        end
    end
end

bindKey('mouse_wheel_down', 'down',
    function()
        if not visible then return end
        if not isInArea(panelData.position.x, panelData.position.y, panelData.size.x, panelData.size.y) then return end

        if panelData.scroll < #resources - panelData.boxes then
            panelData.scroll = panelData.scroll + 1
        end
    end
)

bindKey('mouse_wheel_up', 'down',
    function()
        if not visible then return end
        if not isInArea(panelData.position.x, panelData.position.y, panelData.size.x, panelData.size.y) then return end

        if panelData.scroll > 0 then
            panelData.scroll = panelData.scroll - 1
        end
    end
)

openManager()