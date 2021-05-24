local radioTimers = {}

addEventHandler('onElementDataChange', resourceRoot,
    function(key, _, value)
        if key == 'vehicle.radioTrack' then
            if isTimer(radioTimers[source]) then
                killTimer(radioTimers[source])
            end

            if value ~= 0 then
                setElementData(source, 'vehicle.radioPlayStamp', getRealTime().timestamp)
            end
        end
    end
)