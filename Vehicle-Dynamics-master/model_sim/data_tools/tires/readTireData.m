function [tireData] = readTireData(varargin)
    p = inputParser;
    p.addRequired('round');
    p.addRequired('run');
    p.addOptional('cornering', true);
    p.parse(varargin{:});

    round = p.Results.round;
    run = p.Results.run;
    if p.Results.cornering
        type = 'cornering';
    else
        type = 'drive_brake';
    end

    schemaPath = strcat(rootPath(), '/resources/data/tires/round', num2str(round), ...
                     '/', type, '/schema.json');

    schema = jsondecode(fileread(schemaPath));
    columns = schema.columns;

    runPath = strcat(rootPath(), '/resources/data/tires/round', num2str(round), ...
                     '/', type, '/', schema.prefix, num2str(run), '.dat');

    rawData = dlmread(runPath, '\t', 3, 0);

    assert(length(columns) == size(rawData, 2), ...
            'Must have same number of columns');

    for i = 1 : size(rawData, 2)
        tireData.(columns{i}) = rawData(:, i);
    end
end
