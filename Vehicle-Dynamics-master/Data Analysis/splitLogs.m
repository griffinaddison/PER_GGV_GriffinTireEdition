function filteredMessages = splitLogs(messages, IDs, cursorData1, cursorData2)
        t = cputime;

        t1 = cursorData1.Position(1);
        t2 = cursorData2.Position(1);
    v = cell2mat(values(IDs));
    for k = 1:length(v)
        clearvars times val functionInput logicalChannel
        if (isstruct(messages{v(k)}))

            times = messages{v(k)}.time;
                
            logicalChannel = zeros(length(times), 1);
            for j = 1:length(times)
              logicalChannel(j) = ( (times(j) > t1) && (times(j) < t2) );
            end
            
            logicalChannel = logical(logicalChannel);
            sum(logicalChannel);
            filteredMessages{v(k)}.time = messages{v(k)}.time(transpose(logicalChannel));
            filteredMessages{v(k)}.val = messages{v(k)}.val(transpose(logicalChannel));
        end
    end
    (cputime - t)
end