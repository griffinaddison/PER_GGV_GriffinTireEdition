function [accelTimes] = accelParameterSweep(car, subsystem, parameter, paramValues, makePlot)
    accelTimes = zeros(size(paramValues));
    accelTrack = readTrack('accel');
    %controller = FullAccelController(car, accelTrack, true);
    controller = OldAccelController(car, 80000);
    for i = 1:length(paramValues)
        car.(subsystem).(parameter) = paramValues(i);
        car.init('weightTransfer', 'numeric', 'useWheelVelocity', true);
        simOut = fullSim(car, controller, 'v0', 0.01, 'xstop', 75, 'time', 5);

        accelTime = simOut.stats.finishTime;
        fprintf('Parameter: %f, accel time: %f\n', paramValues(i), accelTime);
        accelTimes(i) = accelTime;
    end
    
    if makePlot
        figure
        plot(paramValues, accelTimes)
        xlabel(parameter)
        ylabel('75 meter accel time')
        title('Accel parameter sweep')
    end
end
