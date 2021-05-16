addEventHandler('onClientKey', root,
    function(key, state)
        if key == 'm' and state then
            showCursor(not isCursorShowing())
        end
    end
)

fonts = {}

function getFont(name, size)
    local ttf = 'assets/fonts/' .. name .. '.ttf'
    local otf = 'assets/fonts/' .. name .. '.otf'

    if not fonts[name .. size] then
        fonts[name .. size] = dxCreateFont(ttf or otf, size, false, 'cleartype_natural') or 'default-bold'
    end

    return fonts[name .. size]
end