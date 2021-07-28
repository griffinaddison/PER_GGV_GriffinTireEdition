function [simOuts] = compParameterSweep(car, subsystem, parameter, paramValues)
    simOuts = cell(length(paramValues), 1);
    cars = {};
    for j = 1:length(paramValues)
        cars{j} = copy(car);
    end
    parfor j = 1:length(paramValues)
        fprintf('Running %f\n', paramValues(j));
        c_car = cars{j};
        c_car.(subsystem).(parameter) = paramValues(j);

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
        simOut.stats.(parameter) = paramValues(j);
        simOut.description = sprintf('%s: %f', parameter, paramValues(j))

        simOuts{j} = simOut;
        fprintf('Got score: %f for parameter: %f\n', simOut.scores.total, paramValues(j));
    end
end
