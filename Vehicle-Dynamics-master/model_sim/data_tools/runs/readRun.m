function [runOut] = readRun(varargin)
    p = inputParser;
    p.addRequired('session');
    p.addRequired('runName');
    p.addOptional('filterGps', true);
    p.addOptional('correctAxes', true);
    p.addOptional('calibrateSteer', true);
    p.parse(varargin{:});

    session = p.Results.session;
    runName = p.Results.runName;

    runPath = strcat(rootPath(), '/resources/data/runs/', session, '/', runName, '.csv');
    schemaPath = strcat(rootPath(), '/resources/data/runs/', session, '/schema.json');

    schema = jsondecode(fileread(schemaPath));
    columns = schema.columns;
    rawData = dlmread(runPath, ',', 1, 0);


    assert(length(columns) == size(rawData, 2), ...
           'Must have same number of columns');

    latCol = find(ismember(columns, 'lat'));
    longCol = find(ismember(columns, 'long'));
    
    if p.Results.filterGps
        % Remove rows with zero lat or long
        nonzeroIndices = find(rawData(:, latCol) & ...
                           rawData(:, longCol));
        rawData = rawData(nonzeroIndices,:);
    end


    % Ignore duplicate timestamps
    [~, ia, ~] = uniquetol(rawData(:, 1), 1e-4);
    rawData = rawData(ia, :);

    
    if p.Results.filterGps
        % Ingore duplicate positions
        [~, latIa, ~] = uniquetol(rawData(:, latCol), 1e-10);
        [~, longIa, ~] = uniquetol(rawData(:, longCol), 1e-10);
        rawData = rawData(intersect(latIa, longIa), :);
    end

    % Start data at t=0
    rawData(:, 1) = rawData(:, 1) - rawData(1, 1);
    
    for i = 1 : size(rawData, 1)
        for j = 1 : size(rawData, 2)
            runData(i).(columns{j}) = rawData(i, j);
        end

        if i == 1
            initialEnergy = runData(1).remainingCapacity * runData(1).voltage;
        end
        
        runData(i).energyDelivered = initialEnergy - ...
            runData(i).remainingCapacity * runData(i).voltage;
    end

    [xs, ys] = grn2eqa([runData.lat], [runData.long], ...
        [runData(1).lat, runData(1).long], referenceEllipsoid('earth'));

    dists = [0; cumsum(hypot(diff(xs), diff(ys)))];

    for i = 1 : size(rawData, 1)
        runData(i).x = xs(i);
        runData(i).y = ys(i);
        runData(i).dist = dists(i);
        
        if runData(i).longVel > 0
            runData(i).bodySA = atan2(runData(i).latVel, runData(i).longVel);
        else
            runData(i).bodySA = 0;
        end
    end

    runData = structArrayToVecStruct(runData);

    if p.Results.correctAxes
        % VectorNav data is x forward, y right, z down
        % Sim convention is x forward, y left, z up

        runData.latVel = -runData.latVel;
        runData.latAccel = -runData.latAccel;
        runData.zVel = -runData.zVel;
        runData.zAccel = -runData.zAccel;
        runData.pitch = -runData.pitch;
        runData.pitchdot = -runData.pitchdot;
        runData.h = -runData.h;
        runData.hdot = -runData.hdot;
    end

    if p.Results.calibrateSteer
        % Convert to radians
        runData.steer = -runData.steer * 0.436 / 72;
    end

    runOut.runData = runData;
    runOut.stats.finishTime = max([runData.t]);
    runOut.stats.energyDelivered = max([runData.energyDelivered]);
end
