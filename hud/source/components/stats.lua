local stats = huds.stats
local browser = createBrowser(stats.w, stats.h, true, true)

local health = 0

addEventHandler('onClientBrowserCreated', browser,
    function()
        loadBrowserURL(source, 'http://mta/local/source/html/stats.html')
    end
)

addEventHandler('onClientRender', root,
    function()
--      dxDrawLine(stats.x, stats.y, stats.x + stats.w, stats.y)
--      dxDrawLine(stats.x, stats.y + stats.h, stats.x + stats.w, stats.y + stats.h)
--      dxDrawLine(stats.x, stats.y, stats.x, stats.y + stats.h)
--      dxDrawLine(stats.x + stats.w, stats.y, stats.x + stats.w, stats.y + stats.h)

        if health ~= getElementHealth(localPlayer) then
            health = getElementHealth(localPlayer)
            executeBrowserJavascript(browser, 'setBarState(\'health\', ' .. health .. ')')
        end

        dxDrawImage(stats.x, stats.y, stats.w, stats.h, browser)
    end
)