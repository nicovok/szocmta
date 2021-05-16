function getConfigValue(value)
    if _G[value] then
        return _G[value]
    end
end

function isPlayerDeveloper(player)
    if not isElement(player) then return end

    local serial = getPlayerSerial(player)

    if DEVELOPERS[serial] then
        return true, DEVELOPERS[serial]
    else
        return false
    end
end

function getDeveloperSerials()
    return DEVELOPERS
end

function getServerTag(type)
    return SERVER_TAGS[type] or serverTags.info
end

function findPlayer(player, id)
    if id == '*' then
        return player
    end

    local id = tonumber(id)
    
    if not id then
        if localPlayer then
            outputChatBox(getServerTag('usage') .. 'Az ID csak szám lehet.', 0, 0, 0, true)
        else
            outputChatBox(getServerTag('usage') .. 'Az ID csak szám lehet.', player, 0, 0, 0, true)
        end

        return 'invalid_id'
    end

    local idNumbers = getElementData(resourceRoot, 'disallowedIdNumbers')

    if isElement(idNumbers[id]) then
        return idNumbers[id]
    end

    if localPlayer then
        outputChatBox(getServerTag('info') .. 'A játékos nem található', 0, 0, 0, true)
    else
        outputChatBox(getServerTag('info') .. 'A játékos nem található', player, 0, 0, 0, true)
    end

    return 'cant_find'
end

function getFunction(name)
    if name == 'isInArea' then
        return [[
            local cursorX, cursorY = 0, 0;

            addEventHandler('onClientCursorMove', root,
                function(_, _, x, y)
                    cursorX, cursorY = x, y;
                end
            )

            function isInArea(x, y, w, h)
                return cursorX >= x and cursorY >= y and cursorX <= (x + w) and cursorY <= (y + h)
            end
        ]]
    elseif name == 'registerEvent' then
        return [[
            function registerEvent(name, element, func)
                addEvent(name, true)
                addEventHandler(name, element, func)
            end
        ]]
    elseif name == 'resp' then
        return [[
            local sx = guiGetScreenSize()
            respMultiplier = 0.75 + (sx - 1024) * 0.25 / (1920 - 1080)
            function resp(num)
                return math.ceil(num * respMultiplier)
            end
        ]]
    elseif name == 'drawButton' then
        return [[
            function drawButton(text, x, y, w, h, a, color, font)
                local borderColor = isInArea(x, y, w, h) and tocolor(color[1], color[2], color[3], 255 * a) or tocolor(60, 60, 60, 255 * a)

                dxDrawLine(x, y, x + w, y, borderColor, 1)
                dxDrawLine(x, y + h, x + w, y + h, borderColor, 1)
                dxDrawLine(x, y, x, y + h, borderColor, 1)
                dxDrawLine(x + w, y, x + w, y + h, borderColor, 1)

                local textColor = tocolor(255, 255, 255, 255 * a)
                dxDrawText(text, x, y, x + w, y + h, textColor, 1, font, 'center', 'center')
            end
        ]]
    elseif name == 'drawInput' then
        return [[
            inputs = {}
            local inputBacks = {}
            inputValues = {}
            selectedInput = false

            addEventHandler('onClientKey', root,
                function(key, state)
                    if selectedInput then cancelEvent() end

                    if (key == 'mouse1' and state) then
                        selectedInput = false

                        for key, input in pairs(inputs) do
                            if isInArea(input[1], input[2], input[3], input[4]) then
                                selectedInput = key
                                break
                            end
                        end
                    end
                end
            , _, 'high')

            addEventHandler('onClientCharacter', root,
                function(character)
                    if selectedInput then
                        local value = inputValues[selectedInput]
                        inputValues[selectedInput] = value .. character
                    end
                end
            )

            function drawInput(key, holder, x, y, w, h, a, font, masked)
                if not inputValues[key] then inputValues[key] = '' end
                if not inputBacks[key] then inputBacks[key] = {0, 100} end

                local value = inputValues[key]

                local back = inputBacks[key]
                local state = getKeyState('backspace')
                local tick = getTickCount()
                if selectedInput == key and state then
                    back[2] = back[2] - 1

                    if back[2] < 70 then
                        back[2] = back[2] - 4
                    end

                    if (tick - back[1]) > back[2] then
                        inputValues[key] = string.sub(value, 1, #value - 1)
                        back[1] = tick
                    end
                else
                    back[2] = 100
                end


                local width = dxGetTextWidth(value, 1, font)

                if #value > 0 then
                    local color = tocolor(130, 130, 130, 255 * a)
                    local alignX = width > w - resp(10) and 'right' or 'left'

                    dxDrawText(masked and value:gsub('%d', '*') or value, x + resp(5), y, x + w - resp(10), y + h, color, 1, font, alignX, 'center', true)
                elseif selectedInput == key then
                    local cursorX = math.min(x + width + resp(5), x + w - resp(10))
                    local cursorP = getTickCount() / 1000
                    local cursorA = interpolateBetween(0, 0, 0, 1, 0, 0, cursorP, 'SineCurve')
                    local cursorC = tocolor(130, 130, 130, 255 * cursorA * a)

                    dxDrawText('|', cursorX, y, cursorX, y + h, cursorC, 1, font, 'left', 'center')
                else
                    local color = tocolor(130, 130, 130, 255 * a)

                    dxDrawText(holder, x + resp(5), y, x + w - resp(10), y + h, color, 1, font, 'left', 'center', true)
                end

                inputs[key] = {x, y, w, h}
            end
        ]]
    elseif name == 'loadTexture' then
        return [[
            function loadTexture(path)
                if not fileExists(path) then return end

                return dxCreateTexture(path, 'argb', true, 'clamp')
            end
        ]]
    elseif name == 'deepcopy' then
        return [[
            function deepcopy(orig)
                local orig_type = type(orig)
                local copy
                if orig_type == 'table' then
                    copy = {}
                    for orig_key, orig_value in next, orig, nil do
                        copy[deepcopy(orig_key)] = deepcopy(orig_value)
                    end
                    setmetatable(copy, deepcopy(getmetatable(orig)))
                else -- number, string, boolean, etc
                    copy = orig
                end
                return copy
            end
        ]]
    elseif name == 'drawRoundedRectangle' then
        return [[
            corner = dxCreateTexture(':core/assets/corner.png', 'argb', true, 'clamp')

            function drawRoundedRectangle(x, y, w, h, color, radius, postGUI, subPixelPositioning)
                radius = radius or 5
                color = color or tocolor(0, 0, 0, 200)
                
                dxDrawImage(x, y, radius, radius, corner, 0, 0, 0, color, postGUI)
                dxDrawImage(x, y + h - radius, radius, radius, corner, 270, 0, 0, color, postGUI)
                dxDrawImage(x + w - radius, y, radius, radius, corner, 90, 0, 0, color, postGUI)
                dxDrawImage(x + w - radius, y + h - radius, radius, radius, corner, 180, 0, 0, color, postGUI)
                
                dxDrawRectangle(x, y + radius, radius, h - radius * 2, color, postGUI, subPixelPositioning)
                dxDrawRectangle(x + radius, y, w - radius * 2, h, color, postGUI, subPixelPositioning)
                dxDrawRectangle(x + w - radius, y + radius, radius, h - radius * 2, color, postGUI, subPixelPositioning)
            end
        ]]
    elseif name == 'drawShadowedText' then
        return [[
            function drawShadowedText(text, x, y, x2, y2, color, ...)
                local black = text:gsub('#%x%x%x%x%x%x', '')
                local r, g, b, a = bitExtract(color, 0, 8), bitExtract(color, 8, 8), bitExtract(color, 16, 8), bitExtract(color, 24, 8)

                dxDrawText(black, x, y + 1, x2, y2 + 1, tocolor(0, 0, 0, a), ...)
                dxDrawText(black, x + 1, y, x2 + 1, y2, tocolor(0, 0, 0, a), ...)
                dxDrawText(black, x, y - 1, x2, y2 - 1, tocolor(0, 0, 0, a), ...)
                dxDrawText(black, x - 1, y, x2 - 1, y2, tocolor(0, 0, 0, a), ...)

                dxDrawText(text, x, y, x2, y2, tocolor(r, g, b, a), ...)
            end
        ]]
    elseif name == 'colorInterpolation' then
        return [[
            local colorInterpolationValues = {}
            local lastColorInterpolationValues = {}
            local colorInterpolationTicks = {}

            function colorInterpolation(key, r, g, b, a, duration)
                if not colorInterpolationValues[key] then
                    colorInterpolationValues[key] = {r, g, b, a}
                    lastColorInterpolationValues[key] = r .. g .. b .. a
                end

                if lastColorInterpolationValues[key] ~= (r .. g .. b .. a) then
                    lastColorInterpolationValues[key] = r .. g .. b .. a
                    colorInterpolationTicks[key] = getTickCount()
                end

                if colorInterpolationTicks[key] then
                    local progress = (getTickCount() - colorInterpolationTicks[key]) / (duration or 500)
                    local red, green, blue = interpolateBetween(colorInterpolationValues[key][1], colorInterpolationValues[key][2], colorInterpolationValues[key][3], r, g, b, progress, "Linear")
                    local alpha = interpolateBetween(colorInterpolationValues[key][4], 0, 0, a, 0, 0, progress, "Linear")

                    colorInterpolationValues[key][1] = red
                    colorInterpolationValues[key][2] = green
                    colorInterpolationValues[key][3] = blue
                    colorInterpolationValues[key][4] = alpha

                    if progress >= 1 then
                        colorInterpolationTicks[key] = false
                    end
                end

                return colorInterpolationValues[key][1], colorInterpolationValues[key][2], colorInterpolationValues[key][3], colorInterpolationValues[key][4]
            end
        ]]
    end

    return false
end