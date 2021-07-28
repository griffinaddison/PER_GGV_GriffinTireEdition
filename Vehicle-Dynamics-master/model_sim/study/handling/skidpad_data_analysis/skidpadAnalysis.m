%aeroRunOut = readRun('testing_07_21_19', 'driving_aero');
%noAeroRunOut = readRun('testing_07_21_19', 'driving_no_aero');

aeroSkidpad = sliceRunTime(aeroRunOut.runData, 80, 300);
noAeroSkidpad = sliceRunTime(noAeroRunOut.runData, 0, 200);

figure
hold on
scatter(aeroSkidpad.runData.longVel, abs(aeroSkidpad.runData.latAccel));
scatter(noAeroSkidpad.runData.longVel, abs(noAeroSkidpad.runData.latAccel));
legend('With aero', 'Without aero');
xlabel('Long vel (m/s)');
ylabel('Lat accel (m/s^2)');
title('Skidpad data with aero');

aeroLaps = parseLaps(aeroSkidpad, [5, 10], 'lapStartTrigger', [-14.4, 49]);
aeroLaps = aeroLaps(2:6);

noAeroLaps = parseLaps(noAeroSkidpad, [5, 10], 'lapStartTrigger', [-12.8, 10.22]);
noAeroLaps = noAeroLaps(1:8);

aeroTimes = [];
for i = 1:length(aeroLaps)
    aeroTimes(i) = aeroLaps{i}.stats.finishTime;
end

noAeroTimes = [];
for i = 1:length(noAeroLaps)
    noAeroTimes(i) = noAeroLaps{i}.stats.finishTime;
end

[~, i] = min(aeroTimes);
bestAeroLap = aeroLaps{i};

track.distances = 75.5;
track.radii = -12.1;
track.numslaloms = 0;

carAero = Rev5Full();
ggvAero = createGGV(carAero);
aeroSimOut = lapSim(ggvAero, track, 'startVel', inf);

carNoAero = Rev5Full();
carNoAero.params.dragCoef = 1;
carNoAero.params.downforceCoef = 0;
ggvNoAero = createGGV(carNoAero);
noAeroSimOut = lapSim(ggvNoAero, track, 'startVel', inf);

rrm = RunRenderManager();
rrm.addRunData(bestAeroLap.runData, 0, 'run');
rrm.addRunData(aeroSimOut.runData, 4, 'sim');
rrm.render('viewQuantity', 'latAccel');

rrm2 = RunRenderManager();
rrm2.addRunData(aeroSimOut.runData, 4, 'sim');
rrm2.addRunData(noAeroSimOut.runData, 4, 'sim');
rrm2.render('viewQuantity', 'latAccel');

