imports = {
    exports.core:getFunction('isInArea'),
    exports.core:getFunction('resp'),
    exports.core:getFunction('deepcopy'),
    exports.core:getFunction('drawRoundedRectangle'),
}

pcall(loadstring(table.concat(imports, '\n')))

sx, sy = guiGetScreenSize()
mx, my = sx / 2, sy / 2

default_huds = {
    radar = {
        visible = true,
        name = 'Radar',

        x = resp(10),
        y = sy - resp(210),
        w = resp(300),
        h = resp(200)
    },

    stats = {
        visible = true,
        name = 'Karakter adatok',

        x = sx - 310,
        y = 10,
        w = 300,
        h = 90,
    },
}

huds = deepcopy(default_huds)

animTime = 300

function loadFonts()
    SFPro16 = exports.core:getFont('SFPro', resp(16))
end

addEventHandler('onClientResourceStart', resourceRoot,
    function()
        loadFonts()

        setPlayerHudComponentVisible('all', false)
    end
)

addEventHandler('onClientResourceStart', getResourceRootElement(getResourceFromName('core')), loadFonts)