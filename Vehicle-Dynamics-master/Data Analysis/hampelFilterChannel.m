function [IDs, messages] = hampelFilterChannel(messages, IDs, oldChannelID, newChannelID, newName, hampelWidth)

    newChannel.time = messages{oldChannelID}.time;
    newChannel.val = hampel(messages{oldChannelID}.val, hampelWidth);
    messages{newChannelID} = newChannel;
    
    IDs(newName) = newChannelID;
end