editor = {
    visible = false,

    fade = 0,
}

hoveredHud = false
selectedHud = false
moving = {}

addCommandHandler('edithud',
    function()
        if editor.visible then return end

        editor.visible = true
        editor.fade = getTickCount()

        addEventHandler('onClientRender', root, editor.render)
        addEventHandler('onClientKey', root, editor.key)
    end
)

function editor.stopEditing()
    editor.visible = false
    editor.fade = getTickCount()

    removeEventHandler('onClientKey', root, editor.key)
end

function editor.render()
    local tick = getTickCount()
    local progress = (tick - editor.fade) / animTime

    local alphaMul = interpolateBetween(editor.visible and 0 or 1, 0, 0, editor.visible and 1 or 0, 0, 0, progress, 'Linear')
    editor.alphaMul = alphaMul

    if not editor.visible and progress > 1 then
        removeEventHandler('onClientRender', root, editor.render)
    end

    local x, y, w, h
    local color

    --> Background
    color = tocolor(0, 0, 0, 200 * alphaMul)

    dxDrawRectangle(0, 0, sx, sy, color)

    --> Lights
    local alpha = interpolateBetween(0, 0, 0, 255, 0, 0, tick / 3000, 'SineCurve')
    color = tocolor(255, 255, 255, alpha * alphaMul)

    dxDrawImage(0, 0, sx, sy, 'assets/lights.png', 0, 0, 0, color)

    hoveredHud = false
    --> Render huds
    for id, hud in pairs(huds) do
        if selectedHud == id then
            color = tocolor(50, 50, 50, 200 * alphaMul)
            drawRoundedRectangle(hud.x, hud.y, hud.w, hud.h, color, resp(5))
        end

        editor.drawHudTitle(hud)

        if isInArea(hud.x, hud.y, hud.w, hud.h) then
            hoveredHud = id
        end
    end

    if moving and selectedHud then
        local cx, cy = editor.getCursor()

        huds[selectedHud].x = cx - moving[1]
        huds[selectedHud].y = cy - moving[2]
    end
end

function editor.key(key, state)
    if key == 'backspace' and state then editor.stopEditing() end

    if key ~= 'mouse1' then return end

    if state then
        selectedHud = hoveredHud

        if selectedHud then
            local cx, cy = editor.getCursor()

            moving = {
                cx - huds[selectedHud].x,
                cy - huds[selectedHud].y
            }
        end
    else
        moving = false
    end
end

function editor.drawHudTitle(hud)
    local text = hud.name
    local x, y, w, h = hud.x, hud.y, hud.x + hud.w, hud.y + hud.h

    local blackText = tocolor(0, 0, 0, 255 * editor.alphaMul)
    dxDrawText(text, x, y + 1, w, h + 1, blackText, 1, SFPro16, 'center', 'center')
    dxDrawText(text, x + 1, y, w + 1, h, blackText, 1, SFPro16, 'center', 'center')
    dxDrawText(text, x, y - 1, w, h - 1, blackText, 1, SFPro16, 'center', 'center')
    dxDrawText(text, x - 1, y, w - 1, h, blackText, 1, SFPro16, 'center', 'center')

    local color = tocolor(255, 255, 255, 255 * editor.alphaMul)
    dxDrawText(text, x, y, w, h, color, 1, SFPro16, 'center', 'center')
end

function editor.getCursor()
    local cx, cy = getCursorPosition()
    return cx * sx, cy * sy
end