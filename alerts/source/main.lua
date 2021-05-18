imports = {
    exports.core:getFunction('resp'),
    exports.core:getFunction('drawRoundedRectangle'),
    exports.core:getFunction('loadTexture'),
}

pcall(loadstring(table.concat(imports, '\n')))

sx, sy = guiGetScreenSize()
mx, my = sx / 2, sy / 2

alertData = false
font = 'default-bold'

local boxH = resp(35)

function loadFont()
    font = exports.core:getFont('SFPro', boxH / 2.5)
end

function alert(text)
    if not alertData then
        addEventHandler('onClientRender', root, renderAlert)
    end

    alertData = {
        text = text,
        duration = #text * 200,
        textWidth = dxGetTextWidth(text, 1, font),

        tick = getTickCount(),
    }

    playSound('source/sounds/alert.mp3')
end

function renderAlert()
    local fadeIn = (getTickCount() - alertData.tick) / 500
    local fadeOut = (getTickCount() - alertData.tick - alertData.duration) / 500

    local alpha = 0
    local y = resp(10)

    if fadeIn > 0 then
        alpha, y = interpolateBetween(
            0, -y, 0,
            255, y, 0,
            fadeIn, 'Linear'
        )
    end

    if fadeOut > 0 then
        alpha, y = interpolateBetween(
            255, y, 0,
            0, -y, 0,
            fadeOut, 'Linear'
        )
    end

    if fadeOut > 1 then
        alertData = false
        removeEventHandler('onClientRender', root, renderAlert)
        return
    end

    local w = alertData.textWidth + resp(20)
    local x = mx - w/2
    local color = tocolor(220, 220, 220, alpha)
    local radius = resp(10)

    drawRoundedRectangle(x, y, w, boxH, color, radius)
    dxDrawText(alertData.text, x, y, x + w, y + boxH, tocolor(100, 100, 100, alpha), 1, font, 'center', 'center')
end

local root = getResourceRootElement(getResourceFromName('core'))
addEventHandler('onClientResourceStart', resourceRoot, loadFont)
addEventHandler('onClientResourceStart', root, loadFont)