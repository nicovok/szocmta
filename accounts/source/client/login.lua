login = {
    visible = false,

    size = {
        x = resp(311),
        y = resp(382),
    },

    remember = true,

    fade = 0,
}

login.position = {
    x = mx - login.size.x / 2,
    y = my - login.size.y / 2
}

login.components = {
    background = loadTexture('assets/login-background.png'),
    remember = loadTexture('assets/login-checkbox.png'),
}

function login.render()
    local x, y, w, h
    local color
    local font

    local progress = (getTickCount() - login.fade) / 750
    local alpha = interpolateBetween(login.visible and 0 or 1, 0, 0, login.visible and 1 or 0, 0, 0, progress, 'OutQuad')

    if not login.visible and progress > 1 then
        inputs['login.username'] = nil
        inputs['login.password'] = nil

        removeEventHandler('onClientRender', root, login.render)
        return
    end

    color = tocolor(117, 109, 88, 200 * alpha)
    dxDrawRectangle(0, 0, sx, sy, color)

    --> Background
    local margin = resp(7)
    x, y, w, h = login.position.x - margin, login.position.y - margin, login.size.x + margin * 2, login.size.y + margin * 2
    color = tocolor(255, 255, 255, 255 * alpha)

    dxDrawImage(x, y, w, h, login.components.background, 0, 0, 0, color)

    --> Inputs
    local padding = resp(5)
    x, w, h = login.position.x + resp(30), resp(250), resp(40)

    y = login.position.y + resp(111)
    drawInput('login.username', 'Felhasználónév', x + padding, y + padding, w - padding * 2, h - padding * 2, alpha, SFPro13)

    y = login.position.y + resp(171)
    drawInput('login.password', 'Jelszó', x + padding, y + padding, w - padding * 2, h - padding * 2, alpha, SFPro13)

    --> Remember
    if login.remember then
        x, y, w, h = login.position.x + resp(33.68), login.position.y + resp(235.78), resp(12.65), resp(9.43)
        color = tocolor(255, 255, 255, 255 * alpha)

        dxDrawImage(x, y, w, h, login.components.remember, 0, 0, 0, color)
    end
end

function login.key(key, state)
    if freezed then return end
    if not state then return end

    local x, y, w, h = login.position.x + resp(30), login.position.y + resp(265), resp(250), resp(47)
    if (key == 'mouse1' and isInArea(x, y, w, h)) or key == 'enter' then
        local username = inputValues['login.username']
        local password = inputValues['login.password']

        executeLogin(username, password)
        return;
    end

    if key ~= 'mouse1' then return end

    local x, y, w, h = login.position.x + resp(30), login.position.y + resp(230), resp(20), resp(20)
    if isInArea(x, y, w, h) then
        login.remember = not login.remember
        return;
    end
end