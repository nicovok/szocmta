local resources = {
	'core',
	'streamer',

	'accounts',

	'hud',
	'alerts',
	'interactions',

	'jobs',
	'chat',
	'admin',
	'damage',
	'nametag',
	'vehicles',
}

addEventHandler("onResourceStart", getResourceRootElement(),
	function()
		for i = 1, #resources do
			local resName = resources[i]
			local res = getResourceFromName(resName)
			if res then
				setTimer(
					function()
						local meta = xmlLoadFile(":" .. resName .. "/meta.xml")
						if meta then
							local dpg = xmlFindChild(meta, "download_priority_group", 0)
							local download_priority_group = 0 - i
							if dpg then
								print(1)
								xmlNodeSetValue(dpg, tostring(download_priority_group))
							else
								print(2)
								dpg = xmlCreateChild(meta, "download_priority_group")
								xmlNodeSetValue(dpg, tostring(download_priority_group))
							end
							--print(resName .. " download_priority_group changed to -> " .. tostring(download_priority_group))
							xmlSaveFile(meta)
							xmlUnloadFile(meta)
						end
					end,
				1000, 1)
			end
		end
	end)