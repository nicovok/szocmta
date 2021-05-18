local renderTarget = dxCreateRenderTarget(1, 1)
local blipTarget = dxCreateRenderTarget(3000, 3000, true)

local map = loadTexture('client/images/map.png')
local mapW, mapH = dxGetMaterialSize(map)

local waterColor = tocolor(110, 158, 204)

renders.radar = function(self)
    local radius = resp(10)
    local border = resp(2)
    local footerH = resp(37)
    local footerY = self.y + self.h - footerH

    local radarW, radarH = self.w - border*2, self.h - border*2
    local targetW, targetH = dxGetMaterialSize(renderTarget)

    if targetW ~= radarW or targetH ~= radarH then
        destroyElement(renderTarget)
        renderTarget = dxCreateRenderTarget(radarW, radarH)
    end

    --> Map
    local div = 6000 / mapW

    local playerX, playerY, playerZ = getElementPosition(localPlayer)

    local _, _, camRot = getElementRotation(getCamera())

    local elementX, elementY = targetW/2 - playerX/div, targetH/2 + playerY/div
    local startX, startY = elementX - mapW/2, elementY - mapH/2

    dxSetRenderTarget(blipTarget, true)

        for blip, data in pairs(blipCache) do
            local blipX, blipY = getElementPosition(blip)

            local size = 30
            local x, y = 1500 + blipX/2, 1500 - blipY/2

            dxDrawImage(x - size/2, y - size/2, size, size, 'client/images/blips/' .. data.icon .. '.png', -camRot)
        end

    dxSetRenderTarget(renderTarget, true)

        dxDrawRectangle(0, 0, targetW, targetH, waterColor)
        dxDrawImage(startX, startY, mapW, mapH, map, camRot, (playerX/div), -(playerY/div), tocolor(255, 255, 255, 255))
        dxDrawImage(startX, startY, mapW, mapH, blipTarget, camRot, (playerX/div), -(playerY/div), tocolor(255, 255, 255, 255))

    dxSetRenderTarget()

    dxDrawImage(self.x + border, self.y + border, radarW, radarH, renderTarget) -- Radar

    --> Border
    local color = tocolor(30, 30, 30, 190)

    dxDrawRectangle(self.x, self.y, border, self.h, color)
    dxDrawRectangle(self.x + self.w - border, self.y, border, self.h, color)
    dxDrawRectangle(self.x + border, self.y, self.w - border*2, border, color)
    dxDrawRectangle(self.x + border, self.y + self.h - border, self.w - border*2, border, color)

    --> Vignetta
    local color = tocolor(30, 30, 30, 200)

    dxDrawImage(self.x + border, self.y + border, radarW, radarH, ':core/assets/vin.png', 0, 0, 0, color)

    --> Zone name
    local footerH = resp(28)
    local bgColor = tocolor(30, 30, 30, 200)
    local zoneColor = tocolor(255, 255, 255)

    local x, y, w, h = self.x + border, self.y + self.h - border - footerH, self.w - border*2, footerH

    dxDrawRectangle(x, y, w, h, bgColor)

    dxDrawText('Heavy City', x, y, x + w, y + h, zoneColor, 1, RobotoM13, 'center', 'center')

    --> Target
    local size = resp(22)
    local x, y = self.x + self.w/2 - size/2, self.y + self.h/2 - size/2

    local _, _, playerRot = getElementRotation(localPlayer)
    local _, _, cameraRot = getElementRotation(getCamera())

    dxDrawImage(x, y, size, size, 'client/images/arrow.png', -playerRot + cameraRot)
end

--> Blips
blipCache = {}

addEventHandler('onClientResourceStart', resourceRoot,
    function()
        local gs = createBlip(-2445.0876464844, 974.73699951172, 50.3046875)---2445.0876464844, 974.73699951172, 50.3046875
        setElementData(gs, 'blip.icon', 'gasstation')

        local hosp = createBlip(-2659.38671875, 632.03253173828, 14.453125)---2445.0876464844, 974.73699951172, 50.3046875
        setElementData(hosp, 'blip.icon', 'hospital')

        local blips = getElementsByType('blip')
        for i, blip in pairs(blips) do
            blipCache[blip] = {
                important = getElementData(blip, 'blip.important'),
                icon = getElementData(blip, 'blip.icon') or 'default',
            }
        end
    end
)

addEventHandler('onClientElementDataChange', root,
    function(key, _, value)
        if getElementType(source) == 'blip' then
            if not blipCache[source] then
                return
            end

            if key == 'blip.important' then
                blipCache[source].important = value
            elseif key == 'blip.icon' then
                blipCache[source].icon = value or 'default'
            end
        end
    end
)

addEventHandler('onClientElementStreamIn', root,
    function(key, _, value)
        if getElementType(source) == 'blip' then
            blipCache[source] = {
                important = getElementData(source, 'blip.important'),
                icon = getElementData(source, 'blip.icon') or 'default',
            }
        end
    end
)