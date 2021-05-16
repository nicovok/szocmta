local vehicleLockTick = 0

function getTitle(element, type)
    local title = ''

    if type == 'player' then
        if getElementData(element, 'adminDuty') then
            title = title .. getElementData(element, 'account.username')
        else
            title = title .. getElementData(element, 'character.fullname')
        end
    elseif type == 'ped' then
        title = title .. (getElementData(element, 'ped.name') or 'Ismeretlen')
        
        local pedType = getElementData(element, 'ped.type')
        if pedType then
            title = title .. (' (%s)'):format(pedType)
        end
    elseif type == 'vehicle' then
        title = title .. getVehicleName(element)

        title = title .. (' (#%s)'):format(getElementData(element, 'vehicle.id'))
    end

    return title
end

function getInteractions(element, type)
    local interactions = {}

    if type == 'player' then
    elseif type == 'ped' then
        if getElementData(element, 'ped.type') == 'job' then
            table.insert(interactions, {
                icon = '',
                name = 'Munkavállalás',
                use = function(element)
                    exports.jobs:openPanel()
                    stopInteraction()
                end,
            })

            if getElementData(localPlayer, 'character.job') > 0 then
                table.insert(interactions, {
                    icon = '',
                    name = 'Felmondás',
                    use = function(element, index)
                        exports.alerts:alert('Sikeresen felmondtál.')
                        setElementData(localPlayer, 'character.job', 0)

                        table.remove(_interactions, index)
                    end,
                })
            end
        end
    elseif type == 'vehicle' then
        table.insert(interactions, {
            icon = '',
            name = 'Csomagtartó',
            use = function(element)
                --> csomagtartónál állás tesztelése
                exports.items:openInventory(element)
                stopInteraction()
            end,
        })

        table.insert(interactions, {
            icon = getElementData(element, 'vehicle.locked') and '' or '',
            name = getElementData(element, 'vehicle.locked') and 'Jármű kinyitása' or 'Jármű bezárása',
            use = function(element, index)
                if getTickCount() - vehicleLockTick < 500 then
                    return
                end

                vehicleLockTick = getTickCount()

                local id = getElementData(element, 'vehicle.id')
                if not id then
                    return
                end

                if not exports.items:hasItem(localPlayer, 1, id) and not exports.core:isPlayerDeveloper(localPlayer) then
                    outputChatBox(exports.core:getServerTag('error') .. 'Nincsen kulcsod ehez a járműhöz.', 0, 0, 0, true)
                    return
                end

                local locked = getElementData(element, 'vehicle.locked') or false
                setElementData(element, 'vehicle.locked', not locked)

                _interactions[index].name = locked and 'Jármű kinyitása' or 'Jármű bezárása'
                _interactions[index].icon = locked and '' or ''

                stopInteraction()
            end,
        })
    end

    table.insert(interactions, {
        icon = '',
        name = 'Bezárás',
        use = function(element)
            stopInteraction()
        end,
    })

    return interactions
end