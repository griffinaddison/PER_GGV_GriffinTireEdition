function [runOuts] = parseLaps(varargin)
    % Takes in run data with multiple laps, outputs laps as separate runs
    % Time estimate is a vector of the form [25, 50] which contain
    % rough estimates for how long a lap should be (in seconds)
    % triggerTolerance is how close a point should be to the lap start trigger
    % to be considered as the lap starting point
    % lapStartTrigger is an [x,y] position where every lap should be restarted
    % default just takes the first datapoint
    p = inputParser;
    p.addRequired('runOut');
    p.addRequired('timeEstimate');
    p.addOptional('lapStartTrigger', [-1, -1]);
    p.addOptional('triggerTolerance', 10);
    p.parse(varargin{:});

    laps = [];

    runData = vecStructToStructArray(p.Results.runOut.runData);
    timeEstimate = p.Results.timeEstimate;

    if p.Results.lapStartTrigger == [-1, -1]
        lapStartTrigger = [runData(1).x, runData(1).y]; 
    else
        lapStartTrigger = p.Results.lapStartTrigger; 
    end

    % Add metadata to make segmentation easier
    for i = 1 : length(runData)
        runData(i).idx = i;
    end

    % Find all positions close to lap start trigger
    idx = rangesearch([[runData.x].', [runData.y].'], ...
        lapStartTrigger, p.Results.triggerTolerance);
    nearTrigger = runData(idx{1});
    [~, idx] = sort([nearTrigger.t]);
    nearTrigger = nearTrigger(idx);

    % Cluster them by time to figure out which lap they're on
    clusters = zeros(length(nearTrigger), 1);
    clusterCount = 1;
    clusterStartTime = nearTrigger(1).t;
    for i = 1 : length(nearTrigger)
        if nearTrigger(i).t - clusterStartTime > timeEstimate(1) * 0.75
            clusterCount = clusterCount + 1;
            clusterStartTime = nearTrigger(i).t;
        end
        clusters(i) = clusterCount;
    end
   
    % For each cluster, get point closest to lapStartTrigger
    for i = 1 : clusterCount
        cluster = nearTrigger(clusters == i);

        closest = knnsearch([[cluster.x].', [cluster.y].'], lapStartTrigger, 'k', 1);
        closest = cluster(closest);
        
        % Repeat data point at start and stop of lap
        if i > 1
            laps = [laps; lapStartIndex, closest.idx];
        end
        lapStartIndex = closest.idx;
    end
    
    % Cut out laps which are not valid
    removeIndices = [];
    for i = 1:size(laps, 1)
        lapTime = runData(laps(i, 2)).t - runData(laps(i, 1)).t;
        if lapTime <= timeEstimate(1) || lapTime >= timeEstimate(2) 
            removeIndices(end+1) = i;
        end
    end
    laps(removeIndices, :) = [];

    rmfield(runData, 'idx');

    runOuts = {};
    for i = 1:size(laps, 1)
        runOuts{i} = sliceRunIndex(structArrayToVecStruct(runData), laps(i, 1), laps(i, 2));

        % Set origin to lap start trigger
        runOuts{i}.runData.x = runOuts{i}.runData.x - lapStartTrigger(1);
        runOuts{i}.runData.y = runOuts{i}.runData.y - lapStartTrigger(2);
    end
end
