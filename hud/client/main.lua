imports = {
    exports.core:getFunction('resp'),
    exports.core:getFunction('deepcopy'),
    exports.core:getFunction('isInArea'),
    exports.core:getFunction('loadTexture'),
    exports.core:getFunction('drawShadowedText'),
    exports.core:getFunction('drawRoundedRectangle'),
}

pcall(loadstring(table.concat(imports, '\n')))

sx, sy = guiGetScreenSize()
mx, my = sx/2, sy/2

cursorX, cursorY = 0, 0

editing = false
fade = 0
selected = false
moving = false
hovered = false
hoveredWidget = false
screenSource = false
blackwhiteShader = false

default_widgets = {
    stats = {
        visible = true,
        name = 'Karakter',
        priority = 2,

        x = sx - resp(310),
        y = resp(10),
        w = resp(300),
        h = resp(80),
    },

    radar = {
        visible = true,
        name = 'Radar',
        priority = 1,

        x = resp(10),
        y = sy - resp(210),
        w = resp(350),
        h = resp(200),

        minX = resp(100),
        minY = resp(100),
        maxX = resp(500),
        maxY = resp(500),
    },

    fps = {
        visible = true,
        name = 'FPS',
        priority = 3,

        x = resp(20),
        y = sy - resp(200),
        w = resp(100),
        h = resp(20),
    },
}

renders = {}

function loadFonts()
    SFPro23 = exports.core:getFont('SFPro', resp(23))
        
    RobotoM13 = exports.core:getFont('RobotoMedium', resp(13))
    FontAwesome9 = exports.core:getFont('FontAwesome', resp(9))

    gtaFont20 = exports.core:getFont('gtaFont', resp(20))
end

function handleStart()
    widgets = deepcopy(default_widgets)

    visibleWidgets = {}
    disabledWidgets = {}

    for id, widget in pairs(widgets) do
        if widget.visible then
            table.insert(visibleWidgets, widget.priority, id)
        else
            table.insert(disabledWidgets, id)
        end

        widget.visible = nil
    end

    widgets = loadWidgets() or widgets

    setPlayerHudComponentVisible('all', false)
end

addEventHandler('onClientResourceStart', root,
    function(res)
        if res == resource or getResourceName(res) == 'core' then
            loadFonts()

            if res == resource then
                handleStart()
            end
        end
    end
)


addCommandHandler('edithud',
    function()
        if editing then return end

        editing = true
        fade = getTickCount()

        screenSource = dxCreateScreenSource(sx, sy)
        blackwhiteShader = dxCreateShader('client/shaders/blackwhite.fx')
        dxSetShaderValue(blackwhiteShader, 'screenSource', screenSource)

        addEventHandler('onClientRender', root, renderEditor, _, 'low')
        addEventHandler('onClientKey', root, handleKey, _, 'low')
    end
)

function loadWidgets()
    if fileExists('widgets.szoc') then
        local file = fileOpen('widgets.szoc', true)
        local size = fileGetSize(file)
        local cont = fileRead(file, size)
        fileClose(file)

        return fromJSON(cont)
    end

    return false
end

function saveWidgets()
    if fileExists('widgets.szoc') then
        fileDelete('widgets.szoc')
    end

    local file = fileCreate('widgets.szoc')
    if file then
        fileWrite(file, toJSON(widgets))
        fileClose(file)
    end
end

addEventHandler('onClientResourceStop', resourceRoot, saveWidgets)

function renderEditor()
    hovered = false
    hoveredWidget = false

    local progress = (getTickCount() - fade) / 700
    alphaMul = interpolateBetween(
        editing and 0 or 1, 0, 0,
        editing and 1 or 0, 0, 0,
        progress, 'Linear'
    )

    if not editing and progress > 1 then
        showChat(true)

        if isElement(screenSource) then
            destroyElement(screenSource)
        end
        if isElement(blackwhiteShader) then
            destroyElement(blackwhiteShader)
        end

        removeEventHandler('onClientRender', root, renderEditor)
        return
    end
    
    if isChatVisible() then
        showChat(false)
    end

    if isElement(screenSource) then
        dxUpdateScreenSource(screenSource)
    end

    --> Widget sizing
    if sizing then
        if isCursorShowing() then
            local x = cursorX - widgets[selected].x
            if x >= widgets[selected].minX and x <= widgets[selected].maxX then
                widgets[selected].w = x
            end

            local y = cursorY - widgets[selected].y
            if y >= widgets[selected].minY and y <= widgets[selected].maxY then
                widgets[selected].h = y
            end
        else
            sizing = false
        end
    end

    --> Widget moving
    if moving then
        if isCursorShowing() then
            widgets[selected].x = cursorX - moving.x
            widgets[selected].y = cursorY - moving.y
        else
            moving = false
        end
    end

    --> Center text
    local text = 'HUD Szerkesztő'
    local white = tocolor(255, 255, 255, 255 * alphaMul)

    drawShadowedText(text, mx, my, mx, my, white, 1.2, 'pricedown', 'center', 'center')

    for i, id in pairs(visibleWidgets) do
        local widget = widgets[id]

        if isInArea(widget.x, widget.y, widget.w, widget.h) then
            hoveredWidget = id
        end

        if selected == id then
            local radius = resp(7)
            local color = tocolor(230, 230, 230, 150 * alphaMul)

            drawRoundedRectangle(widget.x, widget.y, widget.w, widget.h, color, radius)
        end
    end
end

function handleKey(key, state)
    if key == 'escape' and state then
        editing = false
        fade = getTickCount()
        cancelEvent()
        removeEventHandler('onClientKey', root, handleKey)
        return
    end

    if key ~= 'mouse1' then return end

    if state then
        if selected then
            local x, y = widgets[selected].x + widgets[selected].w, widgets[selected].y + widgets[selected].h
            if getDistanceBetweenPoints2D(x, y, cursorX, cursorY) < resp(10) then
                sizing = true
                return
            end
        end

        selected = hoveredWidget

        if selected then
            moving = {
                x = cursorX - widgets[selected].x,
                y = cursorY - widgets[selected].y
            }
        end
    else
        moving = false
        sizing = false
    end
end

addEventHandler('onClientCursorMove', root,
    function(_, _, x, y)
        cursorX, cursorY = x, y
    end
)

addEventHandler('onClientRender', root,
    function()
        if not getElementData(localPlayer, 'character.id') then return end

        if isElement(blackwhiteShader) and alphaMul and alphaMul > 0 then
            dxDrawImage(0, 0, sx, sy, blackwhiteShader, 0, 0, 0, tocolor(255, 255, 255, 255 * alphaMul))
            dxDrawRectangle(0, 0, sx, sy, tocolor(50, 50, 50, 150))
        end

        for i, id in pairs(visibleWidgets) do
            if renders[id] then
                renders[id](widgets[id])
            end
        end
    end
, _, 'high')

addCommandHandler('resethud',
    function()
        if widgets == default_widgets then
            outputChatBox(exports.core:getServerTag('error') .. 'Már alaphelyzetben van a hudod.', 0, 0, 0, true)
            return
        end

        widgets = deepcopy(default_widgets)
        outputChatBox(exports.core:getServerTag('info') .. 'Alaphelyzetbe állítottad a hudod.', 0, 0, 0, true)
    end
)

--> Fps
local fps = 60
local fpsTick = 0

addEventHandler('onClientPreRender', root,
    function(deltaTime)
        if getTickCount() - fpsTick > 1000 then
            fps = math.ceil(1000 / deltaTime)
            fpsTick = getTickCount()
        end
    end
)

renders.fps = function(self)
    local color = tocolor(46, 204, 113)
    local shadow = tocolor(0, 0, 0)
    local x, y, w, h = self.x, self.y, self.w, self.h

    if fps < 25 then
        color = tocolor(231, 76, 60)
    elseif fps < 45 then
        color = tocolor(241, 196, 15)
    end

    local text = fps .. ' FPS'

    dxDrawText(text, x - 1, y, x + w - 1, y + h, shadow, 1, gtaFont20, 'center', 'center')
    dxDrawText(text, x + 1, y, x + w + 1, y + h, shadow, 1, gtaFont20, 'center', 'center')
    dxDrawText(text, x, y - 1, x + w, y + h - 1, shadow, 1, gtaFont20, 'center', 'center')
    dxDrawText(text, x, y + 1, x + w, y + h + 1, shadow, 1, gtaFont20, 'center', 'center')

    dxDrawText(text, x, y, x + w, y + h, color, 1, gtaFont20, 'center', 'center')
end