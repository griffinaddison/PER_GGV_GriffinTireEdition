function [IDs, messages] = differentialChannel(messages, IDs, newName, newID, oldID)
    
    derivativeValues = diff(messages{oldID}.val) ./ diff(messages{oldID}.time);
    derivativeValues = [derivativeValues; 0];
    
    combinedTimeVal = [messages{oldID}.time derivativeValues];
    %for interpolation, times need to be strictly monotomically increasing
    combinedTimeVal = sortrows(combinedTimeVal);
    [~, ia, ~] = unique(combinedTimeVal(:, 1));

    messages{newID}.time = combinedTimeVal(ia, 1);
    messages{newID}.val = combinedTimeVal(ia, 2);
    
    IDs(newName) = newID;
end