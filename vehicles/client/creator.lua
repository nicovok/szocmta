loadstring(exports.dgs:dgsImportFunction())()

local visible = false
local guis = {}
local players = {}

addCommandHandler('createvehicle',
    function()
        if visible then return end

        createGuis()
    end
)

function createGuis()
    visible = true

    players = getElementData(
        getResourceRootElement(getResourceFromName('core')),
        'disallowedIdNumbers'
    )

    local w, h = resp(400), resp(500)

    guis.window = dgsCreateWindow(mx - w/2, my - h/2, w, h, 'Jármű létrehozás', false)
    dgsWindowSetSizable(guis.window, false)

    guis.model = dgsCreateEdit(
        resp(10),
        resp(10),
        resp(70),
        resp(35),
        '',
        false,
        guis.window
    )

    guis.modelLabel = dgsCreateLabel(
        resp(90),
        resp(10),
        resp(410),
        resp(35),
        'Jármű modell',
        false,
        guis.window,
        tocolor(255, 255, 255),
        _, _,
        _, _, _,
        'left', 'center'
    )

    guis.userSelector = dgsCreateComboBox(
        resp(10),
        resp(55),
        resp(250),
        resp(35),
        'Játékos',
        false,
        guis.window
    )

    for i = 1, 30 do
        for id, player in pairs(players) do
            local name = getElementData(player, 'character.fullname')
            dgsComboBoxAddItem(guis.userSelector, '#' .. id .. ' ' .. name)
        end
    end

    addEventHandler('onDgsWindowClose', guis.window,
        function()
            outputChatBox('close')
            visible = false
            destroyGuis()
        end
    )
end

function destroyGuis()
end

createGuis()