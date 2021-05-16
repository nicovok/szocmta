registerEvent('manager.requestResources', root,
    function()
        local _resources = getResources()
        local resources = {}

        for _, resource in pairs(_resources) do
            table.insert(resources, {
                resourceElement = resource,
                
                name = getResourceName(resource),
                state = getResourceState(resource),
                author = getResourceInfo(resource, ''),
                description = getResourceInfo(resource, 'description') or false,
            })
        end

        triggerClientEvent(client, 'manager.returnResources', root, resources)
    end
)