streamerThreads = {}
streamedOutElements = {}

addEventHandler("onClientResourceStart", getResourceRootElement(),
	function ()
		engineSetAsynchronousLoading(true, true)

		for elementType in pairs(STREAM_ELEMENT_TYPES) do
			streamedOutElements[elementType] = {}
			streamerThreads[elementType] = coroutine.create(processStream)
			
			if streamerThreads[elementType] then
				coroutine.resume(streamerThreads[elementType], elementType)
			end
		end
	end
)

addEventHandler("onClientResourceStop", getResourceRootElement(),
	function ()
		for elementType in pairs(STREAM_ELEMENT_TYPES) do
			for element, dimension in pairs(streamedOutElements[elementType]) do
				if isElement(element) then
					setElementDimension(element, dimension)
				end
			end
		end
	end
)