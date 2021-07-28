function [IDs, messages] = zeroPhaseFilter(messages, IDs, oldChannelID, newChannelID, newName, filterWidth)

    newChannel.time = messages{oldChannelID}.time;
    newChannel.val = filtfilt(ones(1, filterWidth)/filterWidth, 1, messages{oldChannelID}.val);
    messages{newChannelID} = newChannel;
    
    IDs(newName) = newChannelID;
end