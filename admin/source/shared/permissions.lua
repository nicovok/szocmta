-- 1. Staff I.
-- 2. Staff II.
-- 3. Admin
-- 4. Manager
-- 5. Dev

permissions = {
    ['admin.fly'] = {1, 3},
    ['admin.setalevel'] = {4, 4},
    ['admin.setdimension'] = {1, 3},

    ['vehicles.createvehicle'] = {3, 3},
    ['vehicles.nearbyvehicles'] = {1, 1},
}

function hasPermissionTo(player, key)
    if exports.core:isPlayerDeveloper(player) then return true end
    if not permissions[key] then return end

    local adminLVL = getElementData(player, 'account.adminlevel')
    local duty = getElementData(player, 'adminDuty')

    if (adminLVL >= permissions[key][1] and duty) or adminLVL >= permissions[key][2] then
        return true
    else
        local prefix = exports.core:getServerTag('admin')
        local content = prefix .. 'Nincsen jogosultságod a funkció használatára, vagy nem vagy adminisztrátori szolgálatban.'

        if localPlayer then
            outputChatBox(content, 0, 0, 0, true)
        else
            outputChatBox(content, player, 0, 0, 0, true)
        end
    end
end