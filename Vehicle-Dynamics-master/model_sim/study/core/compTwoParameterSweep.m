function [simOuts] = compParameterSweep(car, subsystem1, subsystem2, parameter1, param1Values, parameter2, param2Values)
    simOuts = cell(length(param1Values), length(param2Values));
    for i = 1:length(param1Values)
        cars = {};
        for j = 1:length(param2Values)
            cars{j} = copy(car);
        end
        parfor j = 1:length(param2Values)
            fprintf('Running %f %f\n', param1Values(i), param2Values(j));
            c_car = cars{j};
            c_car.(subsystem1).(parameter1) = param1Values(i);
            c_car.(subsystem2).(parameter2) = param2Values(j);

            latAccelFudgeSave = c_car.params.latAccelFudge;
            % Simulate bad average driver performance
            c_car.params.latAccelFudge = c_car.params.latAccelFudge * 0.8;
            c_car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
            baseGGV = createGGV(c_car);

            % Simulate even worse average driver performance for endurance
            c_car.params.latAccelFudge = c_car.params.latAccelFudge * 0.9;
            c_car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
            enduranceGGV = createGGV(c_car);
            c_car.params.latAccelFudge = latAccelFudgeSave;

            comp = Competition();
            comp.accelCar = c_car;
            comp.skidpadGGV = baseGGV;
            comp.autocrossGGV = baseGGV;
            comp.enduranceGGV = enduranceGGV;

            simOut = comp.simulate();
            simOut.stats.(parameter1) = param1Values(i);
            simOut.stats.(parameter2) = param2Values(j);
            simOut.description = sprintf('%s: %f, %s: %f', parameter1, param1Values(i), parameter2, param2Values(j));

            simOuts{i, j} = simOut;
            fprintf('Got score: %f for parameter: %f %f\n', simOut.scores.total, param1Values(i), param2Values(j));
        end
    end
end
