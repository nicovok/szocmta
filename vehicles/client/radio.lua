local currentVehicle = false

local radioSoundElements = {}

addEventHandler('onClientResourceStart', resourceRoot,
    function()
        local function delayedLoad()
            local vehicles = getElementsByType('vehicle')
            for _, vehicle in pairs(vehicles) do
                local track = getElementData(vehicle, 'vehicle.radioTrack')
                if track ~= 0 then
                    local path = ':items/client/tracks/' .. track .. '.mp3'
                    if fileExists(path) then
                        local x, y, z = getElementPosition(vehicle)
                        radioSoundElements[vehicle] = playSound3D(path, x, y, z, true)
                        setSoundMinDistance(radioSoundElements[vehicle], getPedOccupiedVehicle(localPlayer) == vehicle and 999 or 5)
                        setSoundMaxDistance(radioSoundElements[vehicle], 30)

                        local position = (getElementData(vehicle, 'vehicle.radioPlayStamp') - getRealTime().timestamp) % getSoundLength(radioSoundElements[vehicle])
                        setSoundPosition(radioSoundElements[vehicle], position)
                    end
                end
            end
        end

        setTimer(delayedLoad, 3000, 1)
    end
)

addEventHandler('onClientResourceStop', resourceRoot,
    function()
        for _, sound in pairs(radioSoundElements) do
            if isElement(sound) then
                destroyElement(sound)
            end
        end
    end
)

addEventHandler('onClientElementDataChange', resourceRoot,
    function(key, _, value)
        if key == 'vehicle.radioTrack' then
--          if isElementStreamedIn(source) then
                if isElement(radioSoundElements[source]) then
                    destroyElement(radioSoundElements[source])
                end

                if value ~= 0 then
                    local path = ':items/client/tracks/' .. value .. '.mp3'
                    if fileExists(path) then
                        local x, y, z = getElementPosition(source)
                        radioSoundElements[source] = playSound3D(path, x, y, z, true)
                        setSoundMinDistance(radioSoundElements[source], getPedOccupiedVehicle(localPlayer) == source and 999 or 5)
                        setSoundMaxDistance(radioSoundElements[source], 30)
                    end
                end
--          end
        end
    end
)

addEventHandler('onClientVehicleEnter', resourceRoot,
    function(ped)
        if ped == localPlayer then
            if isElement(radioSoundElements[source]) then
                setSoundMinDistance(radioSoundElements[source], 999)
            end
        end
    end
)

addEventHandler('onClientVehicleExit', resourceRoot,
    function(ped)
        if ped == localPlayer then
            if isElement(radioSoundElements[source]) then
                setSoundMinDistance(radioSoundElements[source], 5)
            end
        end
    end
)

addEventHandler('onClientPreRender', root,
    function()
        for vehicle, sound in pairs(radioSoundElements) do
            if isElement(vehicle) and isElement(sound) then
                local x, y, z = getElementPosition(vehicle)
                local x2, y2, z2 = getElementPosition(sound)

                if x ~= x2 or y ~= y2 or z ~= z2 then
                    setElementPosition(sound, x, y, z)
                end
            end
        end
    end
)

addCommandHandler('settrack',
    function(_, track)
        setElementData(
            getPedOccupiedVehicle(localPlayer),
            'vehicle.radioTrack', 
            tonumber(track)
        )
    end
)