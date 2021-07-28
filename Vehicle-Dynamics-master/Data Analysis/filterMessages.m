function filteredMessages = filterMessages(messages, IDs, filterIDs, filterFunction)
        t = cputime;

    v = cell2mat(values(IDs));
    for k = 1:length(v)
        clearvars times val functionInput logicalChannel
        if (isstruct(messages{v(k)}))
            sampleTimes = messages{v(k)}.time;

            for i = 1:length(filterIDs)
                times{i} = messages{filterIDs(i)}.time;
                val{i} = messages{filterIDs(i)}.val;
                functionInput(:, i) = interp1(times{i}, val{i}, sampleTimes, 'linear', 0);
            end
            logicalChannel = zeros(length(sampleTimes), 1);
            for j = 1:length(sampleTimes)
              logicalChannel(j) = (filterFunction(functionInput(j, :)));
            end
            
            logicalChannel = logical(logicalChannel);
            filteredMessages{v(k)}.time = messages{v(k)}.time(transpose(logicalChannel));
            filteredMessages{v(k)}.val = messages{v(k)}.val(transpose(logicalChannel));
        end
    end
    (cputime - t)
end