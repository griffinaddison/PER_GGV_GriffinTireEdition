car = Rev6Full();
motors = {'Emrax_188', 'Emrax_228', 'APM', 'EVO_AF125', 'GVK210_100DQW', 'YASA_P400'};
gearRatios = [5, 3.5, 6, 6.5, 5, 4.5];
% motors = {'Emrax_188', 'Emrax_228'};
% gearRatios = [4.5, 3.5];
simOuts = MotorCompSweep(car, motors, gearRatios);
pointsVisSim(simOuts);
topSpeedVisSim(simOuts);

% simOutsOld = singleCompParameterSweep(car, 'params', 'mass', car.params.mass, false);
% simOut = simOutsOld{1};