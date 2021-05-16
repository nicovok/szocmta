imports = {
    exports.core:getFunction('resp'),
}

pcall(loadstring(table.concat(imports, '\n')))

sx, sy = guiGetScreenSize()
mx, my = sx/2, sy/2

local death = false

local deathTick = 0
local deathDuration = 0.5 * 60000
local deathTimer = false

local screenSource = false
local screenShader = false

addEventHandler('onClientPlayerWasted', localPlayer,
    function(killer, weapon, bodypart, stealth)
        death = false
        deathTick = getTickCount()

        screenSource = dxCreateScreenSource(sx, sy)
        screenShader = dxCreateShader('client/shaders/blackwhite.fx')
        dxSetShaderValue(screenShader, 'screenSource', screenSource)

        showChat(false)

        addEventHandler('onClientRender', root, renderDeathScene)

        deathTimer = setTimer(endDeathScene, deathDuration, 1, true)
    end
)

function endDeathScene(hospital)
    death = false

    if isTimer(deathTimer) then
        killTimer(deathTimer)
    end

    triggerServerEvent('damage.spawnPlayer', localPlayer, hospital)

    setCameraTarget(localPlayer)
    showChat(true)

    removeEventHandler('onClientRender', root, renderDeathScene)
end

function renderDeathScene()
    if getElementHealth(localPlayer) > 0 then
        endDeathScene()
        return
    end

    if screenSource then
        dxUpdateScreenSource(screenSource)
    end

    --> Screen shader
    dxDrawImage(0, 0, sx, sy, screenShader)
    
    --> Vin
    local black = tocolor(0, 0, 0)
    dxDrawImage(0, 0, sx, sy, 'client/images/vin.png', 0, 0, 0, black)

    --> Cam animation
    local x, y, z = getElementPosition(localPlayer)

    local progress = (getTickCount() - deathTick) / 25000
    local z = interpolateBetween(z + 1.5, 0, 0, 100, 0, 0, progress, 'InOutQuad')

    setCameraMatrix(x, y, z, x, y, z - 1)
end

addEventHandler('onClientKey', root,
    function(key, state)
        if death then
            cancelEvent()
        end
    end
, _, 'high')