imports = {
    exports.core:getFunction('resp'),
    exports.core:getFunction('drawRoundedRectangle'),
    exports.core:getFunction('loadTexture'),
    exports.core:getFunction('isInArea'),
}

pcall(loadstring(table.concat(imports, '\n')))

sx, sy = guiGetScreenSize()
mx, my = sx / 2, sy / 2

currentJob = getElementData(localPlayer, 'character.job')
hoveredJob = false
spamTick = 0
peds = {}

addEventHandler('onClientResourceStart', root,
    function(res)
        local core = getResourceFromName('core')
        if not (res == resource or res == core) then return end

        SFPro14 = exports.core:getFont('SFPro', resp(14))
        SFPro12 = exports.core:getFont('SFPro', resp(12))

        if res ~= resource then return end

        for i, ped in pairs(_peds) do
            local element = createPed(
                ped.skin,
                ped.position[1],
                ped.position[2],
                ped.position[3],
                ped.rot
            )

            setElementInterior(element, ped.int)
            setElementDimension(element, ped.dim)

            setElementData(element, 'ped.name', ped.name)
            setElementData(element, 'ped.type', 'job')
            setElementData(element, 'ped.visibleType', 'Munkaügy')

            peds[element] = true
        end
    end
)

addEventHandler('onClientElementDataChange', localPlayer,
    function(key, old, new)
        if key == 'character.job' then
            currentJob = new
        end
    end
)

addEventHandler('onClientClick', root,
    function(button, state, _, _, _, _, _, element)
        if button ~= 'left' or  state ~= 'down' then return end

        if panelData.visible then
            local tick = getTickCount()
            if (tick - spamTick) < 500 then return end
            spamTick = tick

            if isInArea(panelData.x + panelData.w - panelData.header, panelData.y, panelData.x + panelData.w, panelData.y + panelData.header) then
                panelData.visible = false
                panelData.fade = getTickCount()
            elseif hoveredJob then
                if currentJob == hoveredJob then
                    setElementData(localPlayer, 'character.job', 0)
                    exports.alerts:alert('Sikeresen felmondtál!')
                    return
                end

                if currentJob ~= 0 then
                    exports.alerts:alert('Már van munkád. Mondj fel.')
                    return
                end

                setElementData(localPlayer, 'character.job', hoveredJob)
                exports.alerts:alert('Felvetted a ' .. _jobs[hoveredJob].name .. ' munkát.')
            end

            return
        end
    end
)

function openPanel()
    if panelData.visible then return end

    panelData.visible = true
    panelData.fade = getTickCount()

    addEventHandler('onClientRender', root, renderPanel)
end

panelData = {
    visible = false,

    w = resp(300),
    h = resp(500),

    header = resp(45),

    boxes = 9,

    fade = 0,
}

panelData.x = mx - panelData.w / 2
panelData.y = my - panelData.h / 2

function renderPanel()
    hoveredJob = false

    local progress = (getTickCount() - panelData.fade) / 300
    local alpha = interpolateBetween(
        panelData.visible and 0 or 255, 0, 0,
        panelData.visible and 255 or 0, 0, 0,
        progress, 'Linear'
    )

    if not panelData.visible and progress > 1 then
        removeEventHandler('onClientRender', root, renderPanel)
        return
    end

    local backgroundColor = tocolor(244, 244, 244, alpha)
    local borderRadius = resp(10)

    drawRoundedRectangle(panelData.x, panelData.y, panelData.w, panelData.h, backgroundColor, borderRadius)

    local headerColor = tocolor(210, 115, 93, alpha)

    dxDrawImage(panelData.x, panelData.y, borderRadius, borderRadius, corner, 0, 0, 0, headerColor)
    dxDrawImage(panelData.x + panelData.w - borderRadius, panelData.y, borderRadius, borderRadius, corner, 90, 0, 0, headerColor)

    dxDrawRectangle(panelData.x + borderRadius, panelData.y, panelData.w - borderRadius*2, borderRadius, headerColor)
    dxDrawRectangle(panelData.x, panelData.y + borderRadius, panelData.w, panelData.header - borderRadius, headerColor)

    local title = 'Munkafelvétel'
    local titleColor = tocolor(255, 255, 255, alpha)

    dxDrawText(title, panelData.x, panelData.y, panelData.x + panelData.w, panelData.y + panelData.header, titleColor, 1, SFPro14, 'center', 'center')

    local closeColor = tocolor(255, 255, 255, alpha)

    dxDrawText('X', panelData.x + panelData.w - panelData.header, panelData.y, panelData.x + panelData.w, panelData.y + panelData.header, closeColor, 1, SFPro14, 'center', 'center')

    local boxH = (panelData.h - panelData.header) / panelData.boxes
    for i = 1, panelData.boxes do
        local y = panelData.y + panelData.header + boxH * (i-1)

        local hovered = isInArea(panelData.x, y, panelData.w, boxH)

        if hovered then
            hoveredJob = i

            local hoverColor = tocolor(255, 255, 255, alpha)
            if i ~= panelData.boxes then
                dxDrawRectangle(panelData.x, y, panelData.w, boxH, hoverColor)
            else
                dxDrawImage(panelData.x, y + boxH - borderRadius, borderRadius, borderRadius, corner, 270, 0, 0, hoverColor)
                dxDrawImage(panelData.x + panelData.w - borderRadius, y + boxH - borderRadius, borderRadius, borderRadius, corner, 180, 0, 0, hoverColor)

                dxDrawRectangle(panelData.x, y, panelData.w, boxH - borderRadius, hoverColor)
                dxDrawRectangle(panelData.x + borderRadius, y + boxH - borderRadius, panelData.w - borderRadius*2, borderRadius, hoverColor)
            end
        end

        if _jobs[i] then
            local padding = resp(10)
            local nameColor = hovered and tocolor(235, 130, 160, alpha) or tocolor(190, 180, 170, alpha)

            dxDrawText(_jobs[i].name, panelData.x + padding, y, panelData.x + panelData.w - padding, y + boxH, nameColor, 1, SFPro12, 'left', 'center')

            if currentJob == i then
                local padding = resp(10)
                local size = resp(12)
                local stateColor = tocolor(220, 170, 110, alpha)

                drawRoundedRectangle(panelData.x + panelData.w - boxH/2, y + boxH/2 - size/2, size, size, stateColor, size/2)
            end
        end

        if i ~= panelData.boxes then
            local hrColor = tocolor(200, 200, 200, alpha)
            local padding = resp(10)

            dxDrawRectangle(panelData.x, y + boxH, panelData.w, 0.5, hrColor, true)
        end
    end
end