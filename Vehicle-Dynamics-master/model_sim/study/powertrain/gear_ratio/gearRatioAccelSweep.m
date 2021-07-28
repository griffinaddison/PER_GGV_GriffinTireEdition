function [accelTimes] = gearRatioAccelSweep(car, paramValues, difRatios, makePlot)
    accelTimes = zeros(size(paramValues));
    controller = OldAccelController(car, 80000);
    %controller = FullAccelController(car, true);
    
    if difRatios
        for i = 1:length(paramValues)
            car.motors{1}.gearRatio = paramValues(i);
            car.motors{2}.gearRatio = paramValues(i);
            for j = 1:length(paramValues)
                car.motors{3}.gearRatio = paramValues(j);
                car.motors{4}.gearRatio = paramValues(j);
                car.init('weightTransfer', 'numeric', 'useWheelVelocity', true);
                simOut = fullSim(car, controller, 'v0', 0.01, 'xstop', 75, 'time', 7);
                accelTime = simOut.stats.finishTime;
                fprintf('Parameter: %f front - %f rear, accel time: %f\n', ...
                    paramValues(i), paramValues(j), accelTime);
                accelTimes(i, j) = accelTime;
            end
        end
        if makePlot
            figure
            surf(paramValues, paramValues, accelTimes)
            xlabel('Front Gear Ratio')
            ylabel('Rear Gear Ratio')
            zlabel('75 meter accel time')
            title('Split Accel Parameter Sweep')
        end
    else
        for i = 1:length(paramValues)
            for j = 1:4
                car.motors{j}.gearRatio = paramValues(i);
            end
            car.init('weightTransfer', 'numeric', 'useWheelVelocity', true);
            disp(car.params.mass);
            simOut = fullSim(car, controller, 'v0', 0.01, 'xstop', 75, 'time', 5);
            
            accelTime = simOut.stats.finishTime;
            fprintf('Parameter: %f, accel time: %f\n', paramValues(i), accelTime);
            accelTimes(i) = accelTime;
        end
        if makePlot
            figure
            plot(paramValues, accelTimes)
            xlabel('Gear Ratio')
            ylabel('75 meter accel time')
            title('Accel parameter sweep [EVO AF125]')
        end
    end
end

