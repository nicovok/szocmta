local renderTarget = dxCreateRenderTarget(1, 1)

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

    local elementX, elementY = targetW/2 -playerX/div, targetH/2 + playerY/div
    local startX, startY = elementX - mapW/2, elementY - mapH/2

    dxSetRenderTarget(renderTarget, true)

        dxDrawRectangle(0, 0, targetW, targetH, waterColor)
        dxDrawImage(startX, startY, mapW, mapH, map, camRot, (playerX/div), -(playerY/div), tocolor(255, 255, 255, 255))

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