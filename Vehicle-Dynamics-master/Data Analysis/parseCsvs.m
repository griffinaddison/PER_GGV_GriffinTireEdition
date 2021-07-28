function [IDs, allMessages] = parseCsvs(foldername)
    listing = dir (strcat(foldername, '/*.csv'));
    for n=1:length(listing)
        clearvars IDs messages
        [IDs, messages] = parseCsv(strcat(foldername, '/', listing(n).name));
        if ~(isempty(IDs) || isempty(messages ))
            k = keys(IDs);
            v = cell2mat(values(IDs));
            for m = 2:length(k)
                if n == 1
                    ret.time = messages{v(m)}.time;
                    ret.val = messages{v(m)}.val;
                    allMessages{v(m)} = ret;
                else
                    clearvars ret
                    ret.time = [allMessages{v(m)}.time; messages{v(m)}.time];
                    ret.val = [allMessages{v(m)}.val; messages{v(m)}.val];
                    allMessages{v(m)} = ret;
                end
            end
        end
    end
end