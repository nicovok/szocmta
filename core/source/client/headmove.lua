addEvent('headmove.syncPlayersHead', true)
addEventHandler('headmove.syncPlayersHead', root,
    function(targetX, targetY, targetZ)
        if source ~= localPlayer then
            setPedLookAt(source, targetX, targetY, targetZ)
        end
    end
)

local screenSize_X, screenSize_Y = guiGetScreenSize()

function pedLookAt()
   local x, y, z = getWorldFromScreenPosition(screenSize_X / 2, screenSize_Y / 2, 15)
   setPedLookAt(localPlayer, x, y, z, -1, 0)
   triggerServerEvent('headmove.syncPlayersHead', localPlayer, x, y, z)
end
setTimer(pedLookAt, 120, 0)