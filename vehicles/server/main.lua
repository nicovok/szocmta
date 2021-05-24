loadedVehicles = {}

addEventHandler('onResourceStart', resourceRoot,
    function()
        loadVehicles()
    end
)

addEventHandler('onResourceStop', resourceRoot,
    function()
        saveVehicles()
    end
)

addEventHandler('onElementDataChange', root,
    function(key, _, value)
        if getElementType(source) ~= 'vehicle' then return end

        if key == 'vehicle.engine' then
            setVehicleEngineState(source, value)
        elseif key == 'vehicle.locked' then
            setVehicleLocked(source, value)
        end
    end
)

addEventHandler('onVehicleEnter', root,
    function(ped, seat, jacked)
        if seat ~= 0 then return end
        if getVehicleType(source) == 'BMX' then return end

        local engineState = getElementData(source, 'vehicle.engine')
        setVehicleEngineState(source, engineState)
        setVehicleDamageProof(source, false)

        setElementData(ped, 'player.seatbelt', false)
    end
)

addEventHandler('onVehicleStartExit', root,
    function(ped)
        if getElementData(source, 'vehicle.locked') then
            cancelEvent()
            triggerClientEvent(ped, 'vehicles.doorLockAlert', root)
        elseif getElementData(ped, 'player.seatbelt') then
            cancelEvent()
            triggerClientEvent(ped, 'vehicles.seatbeltAlert', root)
        end
    end
)

addEventHandler('onVehicleDamage', root,
    function(loss)
        local health = getElementHealth(source)

        if health < 320 or (health - loss) < 320 then
			setElementHealth(source, 320)
			setVehicleDamageProof(source, true) 
			setElementData(source, "vehicle.engine", false)

			local driver = getVehicleController(source)
			if isElement(driver) then
				triggerClientEvent(driver, 'vehicles.engineDamageAlert', root)
			end
		else
			setVehicleDamageProof(source, false) 
		end
    end
)

addCommandHandler('getveh',
    function(player, cmd, id)
        setElementPosition(loadedVehicles[tonumber(id)], getElementPosition(player))
        setElementRotation(loadedVehicles[tonumber(id)], 0, 0, 0)
        setElementHealth(loadedVehicles[tonumber(id)], 1000)
        fixVehicle(loadedVehicles[tonumber(id)])
    end
)

function loadVehicles()
    dbQuery(
        function(query)
            local result = dbPoll(query, 0)

            if not result then return end
            if #result < 1 then return end

            for i, data in pairs(result) do
                loadVehicle(data)
            end
        end
    , exports.core:getDatabaseConnection(), 'SELECT * FROM `vehicles`')
end

function loadVehicle(data)
    local position = fromJSON(data.position)
    local rotation = fromJSON(data.rotation)

    local vehicle = createVehicle(data.model, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, data.plate)

    setElementInterior(vehicle, position.int)
    setElementDimension(vehicle, position.dim)

    setElementHealth(vehicle, data.health)

    setElementData(vehicle, 'vehicle.id', data.id)
    setElementData(vehicle, 'vehicle.owner', data.id)
    setElementData(vehicle, 'vehicle.engine', false)

    setElementData(vehicle, 'vehicle.radioTrack', 0)
    setElementData(vehicle, 'vehicle.playTick', false)
    setElementData(vehicle, 'vehicle.playLength', false)

    setVehicleFuelTankExplodable(vehicle, false)

    table.insert(loadedVehicles, vehicle)
end

function saveVehicles()
    for _, vehicle in pairs(loadedVehicles) do
        local id = getElementData(vehicle, 'vehicle.id')

        local x, y, z = getElementPosition(vehicle)
        local position = toJSON({
            x = x,
            y = y,
            z = z,
            int = getElementInterior(vehicle),
            dim = getElementDimension(vehicle)
        })

        local x, y, z = getElementRotation(vehicle)
        local rotation = toJSON({
            x = x,
            y = y,
            z = z
        })

        local health = getElementHealth(vehicle)

        dbExec(exports.core:getDatabaseConnection(), 'UPDATE `vehicles` SET `position` = ?, `rotation` = ?, `health` = ? WHERE `id` = ?', position, rotation, health, id)
    end
end