imports = {
    exports.core:getFunction('resp'),
    exports.core:getFunction('drawRoundedRectangle'),
    exports.core:getFunction('registerEvent'),
}

pcall(loadstring(table.concat(imports, '\n')))

elements = {}
bubbles = {}
localCamera = getCamera()

addEventHandler('onClientResourceStart', root,
    function(res)
        local core = getResourceFromName('core')
        if not (res == resource or res == core) then return end

        SFPro15 = exports.core:getFont('SFPro', resp(15))

        if res ~= resource then return end

        local players = getElementsByType('player')
        local peds = getElementsByType('ped')

        for _, player in pairs(players) do elements[player] = true; bubbles[player] = {} end
        for _, ped in pairs(peds) do elements[ped] = true end
    end
)

addEventHandler('onClientElementStreamIn', root,
    function()
        local type = getElementType(source)

        if type == 'player' or type == 'ped' then
            elements[source] = true
            if type == 'player' then bubbles[source] = {} end
        end
    end
)

addEventHandler('onClientElementStreamOut', root,
    function()
        local type = getElementType(source)

        if type == 'player' or type == 'ped' then
            if isPedInVehicle(source) then return end

            elements[source] = nil
            bubbles[source] = nil
        end
    end
)

registerEvent('addBubble', root,
    function(message)
        if not bubbles[source] then return end
        table.insert(bubbles[source], {
            message = message,
            duration = math.min(math.max(#message * 300, 3000), 10000),
            tick = getTickCount(),
        })
    end
)

function renderElement(element)
    if not isElement(element) then
        elements[element] = nil
        bubbles[element] = nil
        return
    end

    local type = getElementType(element)

    local camX, camY, camZ = getElementPosition(localCamera)
    local boneX, boneY, boneZ = getPedBonePosition(element, 5)

    if not isLineOfSightClear(camX, camY, camZ, boneX, boneY, boneZ, true, not isPedInVehicle(element), false, true) then return end

    local headX, headY, dist = getScreenFromWorldPosition(boneX, boneY, boneZ + 0.38)

    if not headX then return end
    if dist > 30 then return end

    local scale = interpolateBetween(1, 0, 0, 0, 0, 0, dist / 30, 'Linear')
    local alpha = interpolateBetween(255, 0, 0, 100, 0, 0, dist / 30, 'InQuad')

    local text, icons = processElement(element, type)

    local textW = dxGetTextWidth(text, scale, SFPro15, true)
    local textH = dxGetFontHeight(scale, SFPro15)
    local textX = headX - textW * 0.5

    local white = tocolor(255, 255, 255, alpha)
    local black = tocolor(0, 0, 0, alpha)

    dxDrawText(text:gsub('#%x%x%x%x%x%x', ''), textX + 1, headY + 1, 0, headY + 1, black, scale, SFPro15, 'left', 'top', false, false, false, true)
    dxDrawText(text, textX, headY, 0, headY, white, scale, SFPro15, 'left', 'top', false, false, false, true)

    local iconSize = textH

    for i, path in pairs(icons) do
        local iconX = textX - iconSize * i

        dxDrawImage(iconX + 1, headY + 1, iconSize, iconSize, path, 0, 0, 0, black)
        dxDrawImage(iconX, headY, iconSize, iconSize, path, 0, 0, 0, white)
    end

    if not getElementData(element, 'adminDuty') then
        if bubbles[element] then
            local tick = getTickCount()
            for i, bubble in pairs(bubbles[element]) do
                local alpha = 0

                local fadeIn = (tick - bubble.tick) / 500
                local fadeOut = (tick - bubble.tick - 500 - bubble.duration) / 500

                if fadeIn > 0 then
                    alpha = interpolateBetween(0, 0, 0, 1, 0, 0, fadeIn, 'Linear')
                end

                if fadeOut > 0 then
                    alpha = interpolateBetween(1, 0, 0, 0, 0, 0, fadeOut, 'Linear')

                    if fadeOut > 1 then
                        table.remove(bubbles[element], i)
                    end
                end

                local textW = dxGetTextWidth(bubble.message, scale, SFPro15, true)
                local backW = textW + resp(10)
                local backH = textH + resp(10)
                local backX = headX - backW/2
                local backY = headY - resp(40) - (backH + resp(5)) * (i-1)

                local backC = tocolor(10, 10, 10, 150 * alpha)
                local textC = tocolor(255, 255, 255, 255 * alpha)

                drawRoundedRectangle(backX, backY, backW, backH, backC)

                dxDrawText(bubble.message, backX, backY, backX + backW, backY + backH, textC, scale, SFPro15, 'center', 'center')
            end
        end
    end
end

function processElement(element, type)
    local text = ''
    local icons = {}

    if type == 'player' then
        if getElementData(element, 'adminDuty') then
            text = text .. getAdminTitle(element) .. ' #ffffff'
            text = text .. getElementData(element, 'account.username')
        else
            text = text .. getElementData(element, 'character.fullname')
        end

        text = text .. ' (' .. getElementData(element, 'player.id') .. ')'

        if getElementData(element, 'adminDuty') then
            icons[#icons + 1] = getElementData(element, 'account.adminlevel') >= 5 and 'client/icons/dev.png' or 'client/icons/admin.png'
        end

        if isPedInVehicle(element) then
            if getPedOccupiedVehicleSeat(element) == 0 then
                icons[#icons + 1] = 'client/icons/driving.png'
            end
        end

        if getElementData(element, 'typing') then
            icons[#icons + 1] = 'client/icons/typing.png'
        elseif getElementData(element, 'consoling') then
            icons[#icons + 1] = 'client/icons/consoling.png'
        end
    elseif type == 'ped' then
        text = text .. (getElementData(element, 'ped.name') or 'Ismeretlen')
        text = text .. ' [#d46d5e' .. (getElementData(element, 'ped.type') or 'Típustalan') .. '#ffffff]'
    end

    return text, icons
end

function getAdminTitle(player)
    local admin = getElementData(player, 'account.adminlevel')

    if admin >= 5 then
        return '#d17560 (Dev)'
    elseif admin >= 4 then
        return '#d17560 (Manager)'
    elseif admin >= 3 then
        return '#f4d266 (Admin)'
    elseif admin >= 2 then
        return '#dbAb6b (Staff II.)'
    elseif admin >= 1 then
        return '#dbAb6b (Staff I.)'
    end

    return ''
end

typing = false
setElementData(localPlayer, 'typing', typing)

consoling = false
setElementData(localPlayer, 'consoling', consoling)

function check()
    local inputActive = isChatBoxInputActive()
    local consoleState = isConsoleActive()

    if typing ~= inputActive then
        typing = inputActive
        setElementData(localPlayer, 'typing', typing)
    end

    if consoling ~= consoleState then
        consoling = consoleState
        setElementData(localPlayer, 'consoling', consoling)
    end
end

setTimer(check, 300, 0)

addEventHandler('onClientRender', root,
    function()
        if not isElement(SFPro15) then return end

        for element in pairs(elements) do
            renderElement(element)
        end
    end
)