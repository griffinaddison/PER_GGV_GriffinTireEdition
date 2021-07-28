function [IDs, messages] = parseBrokenCsv(filename)

    t = cputime;
    fileID = fopen(filename);

    fprintf('opening: %s" ', filename) 
    date_time = textscan(fileID, '%s %s %s %s %f %f %f %f %f %f %s', 1, 'Delimiter', {' ', '/', ':'});
    month = date_time(5);
    day = date_time(6);
    year = date_time(7);
    hour = date_time(8);
    minute = date_time(9);
    second = date_time(10);
    dayHalf = date_time(11);
    isPM = strcmp(dayHalf{1} , 'PM');
    if (hour{1} == 12)
        if isPM
            militaryTimeHour = 12;
        else
            militaryTimeHour = 0;
        end
    else
        militaryTimeHour = hour{1}+isPM*12;
    end
    millisSince2000 = etime([year{1} month{1} day{1} militaryTimeHour minute{1} second{1}], [2000 0 0 0 0 0]) * 1000;
    fclose(fileID);
    
    fileID = fopen(filename);

    clearvars raw_data
    raw_data = textscan(fileID, '%s %s %u', 'HeaderLines',1, 'Delimiter', {'(', '): '});

    IDs = containers.Map({''}, [4]);
    %messages = containers.Map({3}, [0]);
    fclose(fileID);
    fclose('all');

    for n = 1:length(raw_data{1})
        if(strcmp(raw_data{1}{n}(1:3), 'Val'))
            IDs(strrep(raw_data{2}{n}, ':', '')) = raw_data{3}(n);
        end 
    end

%     fileID = fopen(filename);
%     clearvars raw_values
%     raw_values = textscan(fileID, '%f %f %s', 'HeaderLines',1+length(IDs), 'Delimiter', {' ', ','});

%     for i=1:length(raw_values{3})
%         num = str2double(raw_values{3}(i));
%         if isnan(num)
%             num = 0;
%         end
%         vals(i) = num;
%     end
    
    try
        k = keys(IDs);
        v = cell2mat(values(IDs));
        %mergedValues = [raw_values{1}, raw_values{2}, transpose(vals)];

        load('../../Vehicle-Dynamics-Data/MATLAB VARS/MERGED_VALUES.mat')
        backupMergedValues = mergedValues;
        brokenCsvParseScript
        
        for n = 1:length(k)
            filteredValues = mergedValues(mergedValues(:, 2) == v(n), :); 
            ret.time = filteredValues(:, 1) + millisSince2000;
            [~, ia, ~] = unique(ret.time);
            ret.val = filteredValues(:, 3);
            ret.time = ret.time(ia);
            ret.val = ret.val(ia);

            messages{v(n)} = ret;
        end
        fclose('all');
        fprintf('took %f seconds \n', cputime - t');
    catch error
        IDs = containers.Map;
        messages = cell(0);
        disp('parsing error');
    end
end