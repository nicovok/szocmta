renders.stats = function(self)
    local barH = resp(10)
    local icon = resp(20)

    local bars = {
        {
            value = getElementHealth(localPlayer) / 100,
            color = {215, 89, 89},
            icon = '',
        },
        {
            value = getElementData(localPlayer, 'character.hunger') / 100,
            color = {223, 181, 81},
            icon = '',
        },
        {
            value = getElementData(localPlayer, 'character.thirst') / 100,
            color = {97, 226, 252},
            icon = '',
        },
    }

    local border = tocolor(10, 10, 10, 230)
    local thin = resp(2.5)

    for i, bar in pairs(bars) do
        local background = tocolor(bar.color[1] * 0.75, bar.color[2] * 0.75, bar.color[3] * 0.75, 155)
        local color = tocolor(bar.color[1], bar.color[2], bar.color[3], 170)

        local y = self.y + (barH * 1.8) * (i - 1)

        local progress = self.w * bar.value

        drawBorder(self.x + icon, y, self.w - icon, barH, math.ceil(resp(2.2)), tocolor(0, 0, 0, 255))
        dxDrawRectangle(self.x + icon, y, self.w - icon, barH, background)
        dxDrawRectangle(self.x + icon, y, progress - icon, barH, color)
    end
end

function drawBorder(x, y, w, h, t, c)
    dxDrawRectangle(x - t, y - t, w + t*2, t, c)
    dxDrawRectangle(x - t, y + h, w + t*2, t, c)
    dxDrawRectangle(x - t, y, t, h, c)
    dxDrawRectangle(x + w, y, t, h, c)
end