imports = {
    exports.core:getFunction('registerEvent'),
    exports.core:getFunction('resp')
}

pcall(loadstring(table.concat(imports, '\n')))

sx, sy = guiGetScreenSize()
mx, my = sx/2, sy/2

local engineStartTimer = false
local preEngineStart = false
local engineSound = false

local beltTick = 0

registerEvent('vehicles.engineDamageAlert', root,
    function()
        exports.alerts:alert('Lerobbant a járműved.')
    end
)

registerEvent('vehicles.doorLockAlert', root,
    function()
        exports.alerts:alert('Nem szállhatsz ki a járműből, ameddig az zárva van.')
    end
)

registerEvent('vehicles.seatbeltAlert', root,
    function()
        exports.alerts:alert('Nem szállhatsz ki a járműből bekötött biztonsági övvel.')
    end
)

addEventHandler('onClientKey', root,
    function(key, state)
        if not (key == 'j' or key == 'space' or key == 'F5') then return end
        if not isPedInVehicle(localPlayer) then return end

        local vehicle = getPedOccupiedVehicle(localPlayer)
        local model = getElementModel(vehicle)

--      if not nonSeatBeltsVehicle[model] then
            if key == 'F5' and state and getTickCount() - beltTick > 1000 then
                local belt = not getElementData(localPlayer, 'player.seatbelt')
                setElementData(localPlayer, 'player.seatbelt', belt)

                playSound('client/sounds/belt' .. (belt and 'in' or 'out') .. '.mp3')
                beltTick = getTickCount()
            end
--      end

        if getVehicleType(vehicle) == 'BMX' then return end
        if getVehicleOccupant(vehicle) ~= localPlayer then return end
        if not exports.core:isPlayerDeveloper(localPlayer) and not exports.items:hasItem(localPlayer, 1, getElementData(vehicle, 'vehicle.id')) then return end

        if key == 'j' then
            if state then
                if not getElementData(vehicle, 'vehicle.engine') then
                    preEngineStart = true
                else
                    setElementData(vehicle, 'vehicle.engine', false)
                end
            else
                preEngineStart = false
            end

            return
        end

        if not preEngineStart then return end

        if state then
            checkTimerAndSound()

            engineSound = playSound('client/sounds/starter.mp3')

            if getElementHealth(vehicle) <= 320 then
                engineStartTimer = setTimer(outputChatBox, 1000, 1, exports.core:getServerTag('error') .. 'Túlságosan meg van sérülve a járműved.', 0, 0, 0, true)
                setTimer(checkTimerAndSound, 1000, 1)
                return
            end

            setVehicleDamageProof(vehicle, false)
            engineStartTimer = setTimer(setElementData, 1000, 1, vehicle, 'vehicle.engine', true)
        else
            checkTimerAndSound()
        end
    end
)

function checkTimerAndSound()
    if isTimer(engineStartTimer) then
        killTimer(engineStartTimer)
    end

    if isElement(engineSound) then
        destroyElement(engineSound)
    end
end