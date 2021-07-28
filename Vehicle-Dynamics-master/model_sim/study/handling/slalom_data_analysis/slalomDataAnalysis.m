loadData = false;
doParseLaps = false;

if loadData
    fullInertiaData = readRun('testing_08_03_19', 'full_yaw_inertia');
    halfInertiaData = readRun('testing_08_03_19', 'half_yaw_inertia');
    lowInertiaData = readRun('testing_08_03_19', 'low_yaw_inertia');
    lowMassData = readRun('testing_08_03_19', 'low_weight_1');
end

if doParseLaps
    fullInertiaLaps = parseLaps(fullInertiaData, [18, 21], ...
        'lapStartTrigger', [-6.7, 11]);
    halfInertiaLaps = parseLaps(halfInertiaData, [17, 21], ...
        'lapStartTrigger', [-6.7, 11]);
    lowInertiaLaps = parseLaps(lowInertiaData, [17, 21], ...
        'lapStartTrigger', [-6.7, 11]);
    lowMassLaps = parseLaps(lowMassData, [15, 21], ...
        'lapStartTrigger', [-6.7, 11]);

    % Remove sweeparound detection
    halfInertiaLaps([2,4,8]) = [];
    lowInertiaLaps([10]) = [];
    lowMassLaps([2,4,6,10]) = [];

    %Remove bad laps
    fullInertiaLaps([1,2]) = []; % Practice laps
    halfInertiaLaps([3]) = []; % Hit cones
    lowInertiaLaps([1,2,3,5]) = []; % Weights in bad position, chris couldn't drive; missed slaloms

    fullInertiaLapTimes = getLapTimes(fullInertiaLaps);
    halfInertiaLapTimes = getLapTimes(halfInertiaLaps);
    lowInertiaLapTimes = getLapTimes(lowInertiaLaps);
    lowMassLapTimes = getLapTimes(lowMassLaps);
end

marker = 's';
markerSize = 120;

plotLapTimes = false;

if plotLapTimes
    figure
    hold on
    scatter(fullInertiaLapTimes, getAverageTireTemps(fullInertiaLaps), ...
            markerSize, marker, 'filled');
    scatter(halfInertiaLapTimes, getAverageTireTemps(halfInertiaLaps), ...
            markerSize, marker, 'filled');
    scatter(lowInertiaLapTimes, getAverageTireTemps(lowInertiaLaps), ...
            markerSize, marker, 'filled');
    scatter(lowMassLapTimes, getAverageTireTemps(lowMassLaps), ...
            markerSize, marker, 'filled');

    xlabel('Lap time');
    ylabel('Average tire temp');

    legend('Full inertia', 'Half inertia', 'Low inertia', 'Low mass');
end

if true
    % Takes 0.24 secs to reach peak yaw rate affter peak steer input
    plotRunResponse(fullInertiaLaps{1});
    title('Full inertia response')

    % Takes 0.12 secs to reach peak yaw rate
    plotRunResponse(halfInertiaLaps{1});
    title('Half inertia response')

    % Takes 0.15 secs to reach peak yaw rate
    plotRunResponse(lowInertiaLaps{1});
    title('Low inertia response')

    % Takes 0.16 secs to reach peak yaw rate
    plotRunResponse(lowMassLaps{1});
    title('Low mass response')
end

fullInertiaResponses = findSteerResponseTimes(fullInertiaLaps);
halfInertiaResponses = findSteerResponseTimes(halfInertiaLaps);
lowInertiaResponses = findSteerResponseTimes(lowInertiaLaps);
lowMassResponses = findSteerResponseTimes(lowMassLaps);

figure
hold on

scatter(ones(size(fullInertiaResponses)) * 0, fullInertiaResponses, 50, 'filled');
scatter(ones(size(halfInertiaResponses)) * 1, halfInertiaResponses, 50, 'filled');
scatter(ones(size(lowInertiaResponses)) * 2, lowInertiaResponses, 50, 'filled');
%scatter(ones(size(lowMassResponses)) * 3, lowMassResponses, 50, 'filled');

ylabel('Lag between peak steer and peak yaw rate (s)');

legend('Full inertia', 'Half inertia', 'Low inertia');
%legend('Full inertia', 'Half inertia', 'Low inertia', 'Low mass');
%
set(gca,'FontSize', 20);

fprintf('Full inertia mean response: %f\n', mean(fullInertiaResponses));
fprintf('Half inertia mean response: %f\n', mean(halfInertiaResponses));
fprintf('Low inertia mean response: %f\n', mean(lowInertiaResponses));
fprintf('Low mass mean response: %f\n', mean(lowMassResponses));

fprintf('Full inertia median response: %f\n', median(fullInertiaResponses));
fprintf('Half inertia median response: %f\n', median(halfInertiaResponses));
fprintf('Low inertia median response: %f\n', median(lowInertiaResponses));
fprintf('Low mass median response: %f\n', median(lowMassResponses));

function dts = findSteerResponseTimes(laps)
    dts = [];
    for runOut = laps
        runOut = runOut{1};
        runData1 = sliceRunTime(runOut.runData, 0, 6);
        runData2 = sliceRunTime(runOut.runData, 12, 30);

        dts1 = findSteerResponseTimesSliced(runData1);
        dts2 = findSteerResponseTimesSliced(runData2);
        
        dts = [dts, dts1, dts2];
    end

    dts = dts(dts > 0 & dts < 0.35);
end

function [dts] = findSteerResponseTimesSliced(runOut)
    times = linspace(runOut.runData.t(1), runOut.runData.t(end), 1000);

    steer = abs(interp1(runOut.runData.t, smooth(runOut.runData.steer), times, 'spline'));
    hdot = abs(interp1(runOut.runData.t, smooth(runOut.runData.hdot), times, 'spline'));

    [steerVals, steerPeaks] = findpeaks(steer);
    steerPeaks = steerPeaks(steerVals > 0.1);
    [~, hdotPeaks] = findpeaks(hdot);
    
    steerPeakTimes = times(steerPeaks);
    hdotPeakTimes = times(hdotPeaks);
    
    dts = [];
    for i = 1 : length(steerPeakTimes)
        if i <= length(hdotPeakTimes)
            steerPeakTime = steerPeakTimes(i);
            [~, idx] = min(abs(hdotPeakTimes - steerPeakTime));
            hdotPeakTime = hdotPeakTimes(idx);
            dts = [dts, hdotPeakTime - steerPeakTime];
        end
    end
end

function plotRunResponse(runOut)
    figure
    hold on
    yyaxis left
    plot(runOut.runData.t, smooth(runOut.runData.steer));
    ylabel('Steer (uncalibrated)');
    yyaxis right
    plot(runOut.runData.t, smooth(runOut.runData.hdot));
    ylabel('Yaw rate (rad / s)');

    legend('steer', 'yaw rate');
    xlabel('Time (s)');
end

function lapTimes = getLapTimes(laps)
    lapTimes = cellfun(@(lap) lap.stats.finishTime, laps);
end

function averageTireTemps = getAverageTireTemps(laps)
    averageTireTemps = cellfun(@(lap) mean(lap.runData.tireTempRr), laps);
end
