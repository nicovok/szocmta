function adminDuty(player)
    local duty = getElementData(player, 'adminDuty')
    local username = getElementData(player, 'account.username')
    local tag = exports.core:getServerTag('admin')

    if not duty then
        if getElementData(player, 'account.adminlevel') <= 0 then return end

        setElementData(player, 'adminDuty', true)

        outputChatBox(tag .. username .. ' adminszolgálatba lépett.', root, 0, 0, 0, true)
    else
        setElementData(player, 'adminDuty', false)

        outputChatBox(tag .. username .. ' kilépett az adminszolgálatból.', root, 0, 0, 0, true)
    end
end

addCommandHandler('aduty', adminDuty)
addCommandHandler('adminduty', adminDuty)
addCommandHandler('aduty', adminDuty)