function [IDs, messages] = mathChannel(messages, IDs, newName, newID, IDlist, mathFunction)
    t = cputime;
    sampleTimes = [];
    for n = 1:length(IDlist)
        sampleTimes = [sampleTimes; messages{IDlist(n)}.time];
    end
    
    for i = 1:length(IDlist)
            times{i} = messages{IDlist(i)}.time;
            values{i} = messages{IDlist(i)}.val;
            functionInput(:, i) = interp1(times{i}, values{i}, sampleTimes, 'linear', 0);
    end
    mathChannel = zeros(length(sampleTimes), 1);
    for j = 1:length(sampleTimes)
       mathChannel(j) = mathFunction(functionInput(j, :));
    end
 
    combinedTimeVal = [sampleTimes mathChannel];
    %for interpolation, times need to be strictly monotomically increasing
    combinedTimeVal = sortrows(combinedTimeVal);
    [~, ia, ~] = unique(combinedTimeVal(:, 1));

    messages{newID}.time = combinedTimeVal(ia, 1);
    messages{newID}.val = combinedTimeVal(ia, 2);
    
    IDs(newName) = newID;
    (cputime - t)
end
