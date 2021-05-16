addEvent('onPlayerUseItem', true)

registerEvent('items.eatUseServer', root,
    function(player, item)
        setPedAnimation(player, "FOOD", "eat_pizza", 2000, false, true, true, false)
        outputChatBox(getPlayerName(player) .. " eszik egy falat "..getItemName(item.itemID).."-t")
    end
)