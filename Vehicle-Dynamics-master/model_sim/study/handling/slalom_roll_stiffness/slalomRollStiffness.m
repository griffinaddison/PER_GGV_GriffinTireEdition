loadData = true;
doParseLaps = true;

if loadData
    lowMassData = readRun('testing_08_03_19', 'low_weight_1');
end

if doParseLaps
    lowMassLaps = parseLaps(lowMassData, [15, 21], ...
        'lapStartTrigger', [-6.7, 11]);

    % Remove sweeparound detection
    lowMassLaps([2,4,6,10]) = [];
end
