imports = {
    exports.core:getFunction('isInArea'),
    exports.core:getFunction('registerEvent'),
    exports.core:getFunction('resp'),
    exports.core:getFunction('drawInput'),
    exports.core:getFunction('loadTexture'),
}

pcall(loadstring(table.concat(imports, '\n')))

sx, sy = guiGetScreenSize()
mx, my = sx / 2, sy / 2

padding = resp(5)

lastAttempt = 0

currentAccount = false

freezed = false

addEventHandler('onClientResourceStart', root,
    function(res)
        if res == resource or res == getResourceFromName('core') then
            SFPro17 = exports.core:getFont('SFPro', resp(17))
            SFPro13 = exports.core:getFont('SFPro', resp(13))
            SFPro10 = exports.core:getFont('SFPro', resp(10))

            if res ~= resource then return end

            triggerServerEvent('accounts.clientLoaded', localPlayer)
        end
    end
)

registerEvent('accounts.openLogin', localPlayer,
    function()
        if login.visible then return end

        login.visible = true
        
        login.fade = getTickCount()

        setTime(12, 0)

        setCameraMatrix(unpack(LOGIN_BACKGROUND))
        fadeCamera(true)

        addEventHandler('onClientRender', root, login.render)
        addEventHandler('onClientKey', root, login.key)
    end
)

registerEvent('accounts.closeLogin', localPlayer,
    function()
        if not login.visible then return end
        
        login.visible = false

        login.fade = getTickCount()

        removeEventHandler('onClientKey', root, login.key)
    end
)

registerEvent('accounts.successfulLogin', localPlayer,
    function(account)
        freezed = false

        outputChatBox(exports.core:getServerTag('info') .. 'Sikeresen bejelentkeztél, dik.', 0, 0, 0, true)

        currentAccount = account
    end
)

function executeLogin(username, password)
    local tick = getTickCount()

    if (tick - lastAttempt) < 500 then
        outputChatBox(exports.core:getServerTag('error') .. 'Várj egy kicsit!', 0, 0, 0, true)
        return
    end

    lastAttempt = tick

    if #username:gsub(' ', '') < 1 or #password:gsub(' ', '') < 1 then
        outputChatBox(exports.core:getServerTag('error') .. 'Minden mező kitöltése kötelező!', 0, 0, 0, true)
        return
    end

    freezed = true

    triggerServerEvent('accounts.executeLogin', localPlayer, username, password)
end

addCommandHandler('alogin',
    function()
        triggerEvent('accounts.openLogin', localPlayer)
    end
)