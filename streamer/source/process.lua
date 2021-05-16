function processStream(elementType)
	while true do
		if elementType then
			local cameraX, cameraY, cameraZ = getCameraMatrix()
			local playerX, playerY, playerZ = getElementPosition(localPlayer)
		
			if elementType == "vehicle" then
				local streamedVehicles = {}
				
				for k,v in ipairs(getElementsByType(elementType, getRootElement(), true)) do
					if not streamedOutElements[elementType][v] and not getVehicleOccupant(v) and getElementModel(v) ~= 577 then
						local elementX, elementY, elementZ = getElementPosition(v)
						local _, _, elementRotation = getElementRotation(v)
						
						if getDistanceBetweenPoints3D(playerX, playerY, playerZ, elementX, elementY, elementZ) > STREAM_ELEMENT_TYPES[elementType] then
							streamedOutElements[elementType][v] = getElementDimension(v)
							setElementDimension(v, STREAM_OUT_DIMENSION)
							streamedVehicles[v] = true
						elseif not isElementVisible(cameraX, cameraY, cameraZ, elementX, elementY, elementZ, elementRotation, getElementRadius(v) * 2) then
							streamedOutElements[elementType][v] = getElementDimension(v)
							setElementDimension(v, STREAM_OUT_DIMENSION)
							streamedVehicles[v] = true
						end
					end
				end
				
				for k,v in pairs(streamedOutElements[elementType]) do
					if isElement(k) then
						if not getVehicleOccupant(k) then
							local elementX, elementY, elementZ = getElementPosition(k)
							local _, _, elementRotation = getElementRotation(k)
							
							if not streamedVehicles[k] and getDistanceBetweenPoints3D(playerX, playerY, playerZ, elementX, elementY, elementZ) <= STREAM_ELEMENT_TYPES[elementType] and isElementVisible(cameraX, cameraY, cameraZ, elementX, elementY, elementZ, elementRotation, getElementRadius(k) * 2) then
								setElementDimension(k, v)
								streamedOutElements[elementType][k] = nil
							end
						else
							setElementDimension(k, v)
							streamedOutElements[elementType][k] = nil
						end
					else
						streamedOutElements[elementType][k] = nil
					end
				end
			elseif elementType == "object" then
				local streamedObjects = {}
				
				for k,v in ipairs(getElementsByType(elementType, getRootElement(), true)) do
					if not streamedOutElements[elementType][v] then
						local objectX, objectY, objectZ = getElementPosition(v)
						
						if getDistanceBetweenPoints3D(playerX, playerY, playerZ, objectX, objectY, objectZ) > STREAM_ELEMENT_TYPES[elementType] then
							streamedOutElements[elementType][v] = getElementDimension(v)
							setElementDimension(v, STREAM_OUT_DIMENSION)
							streamedObjects[v] = true
						end
					end
				end
				
				for k,v in pairs(streamedOutElements[elementType]) do
					if isElement(k) then
						local objectX, objectY, objectZ = getElementPosition(k)
						
						if not streamedObjects[k] and getDistanceBetweenPoints3D(playerX, playerY, playerZ, objectX, objectY, objectZ) <= STREAM_ELEMENT_TYPES[elementType] then
							setElementDimension(k, v)
							streamedOutElements[elementType][k] = nil
						end
					else
						streamedOutElements[elementType][k] = nil
					end
				end
			end
			
			setTimer(
				function(eType)
					coroutine.resume(streamerThreads[eType], eType)
				end,
			500, 1, elementType)

			coroutine.yield()
		end
	end
end