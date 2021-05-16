function clearChat()
    for i = 1, getChatboxLayout().chat_lines - 1 do
        outputChatBox('')
    end

    outputChatBox(exports.core:getServerTag('info') .. 'Kiürítetted a chated.', 0, 0, 0, true)
end

addCommandHandler('cc', clearChat)
addCommandHandler('clear', clearChat)
addCommandHandler('clearc', clearChat)
addCommandHandler('clearchat', clearChat)