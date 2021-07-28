track = readTrack('testing_autocross_2019', 'reverse', true);

car = Rev6Full();
%car.params.latAccelFudgeFactor = 1.8;
ggv = createGGV(car);
simOut = lapSim(ggv, track, 'startVel', 15);

% Parse the laps, indicating that they should
% be between 25 and 50 seconds in length
runOut = readRun('testing_06_15_19', 'autocross');
laps = parseLaps(runOut, [25, 50], 'lapStartTrigger', [0.39, 1.14]);
lapOut = laps{2};

% Display velocity profiles overlayed around track
% Sim data is shifted outwards (track is not actually bigger)
rrm = RunRenderManager();
rrm.addRunData(simOut.runData, 0.4, 'sim');
rrm.addRunData(lapOut.runData, 0, 'run');
rrm.render('viewQuantity', 'longVel');

% Display velocity profiles vs distance
renderRunComp({simOut, lapOut}, 'yQuantity', 'longVel')
