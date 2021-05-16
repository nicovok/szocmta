_fonts = {}

addEventHandler('onClientResourceStart', root,
    function(res)
        if res == resource or getResourceName(res) == 'core' then
            _fonts[20] = exports.core:getFont('SFPro', resp(20))
            _fonts[16] = exports.core:getFont('SFPro', resp(16))
            _fonts[13] = exports.core:getFont('SFPro', resp(13))
            _fonts[14] = exports.core:getFont('SFPro', resp(14))
            _fonts[12] = exports.core:getFont('SFPro', resp(12))
            _fonts.icon16 = exports.core:getFont('FontAwesome', resp(16))
        end
    end
)

function areFontsLoaded()
    for _, font in pairs(_fonts) do
        if not isElement(font) then
            return false
        end
    end

    return true
end