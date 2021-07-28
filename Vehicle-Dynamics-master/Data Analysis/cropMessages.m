function filteredMessages = cropMessages(messages, IDs, tmin, tmax)
    %tmin and tmax in milliseconds from 200
            t = cputime;

    v = cell2mat(values(IDs));
    %iterate over all channels
    for k = 1:length(v)
        clearvars times val functionInput logicalChannel
        if (isstruct(messages{v(k)}))
            sampleTimes = messages{v(k)}.time;
            
            logicalChannel = zeros(length(sampleTimes), 1);
            for j = 1:length(sampleTimes)
              logicalChannel(j) = (sampleTimes(j) > tmin) && (sampleTimes(j) < tmax);
            end
            
            %filter messages in channel based on logicals
            logicalChannel = logical(logicalChannel);
            filteredMessages{v(k)}.time = messages{v(k)}.time(transpose(logicalChannel));
            filteredMessages{v(k)}.val = messages{v(k)}.val(transpose(logicalChannel));
        end
    end
    (cputime - t)
end