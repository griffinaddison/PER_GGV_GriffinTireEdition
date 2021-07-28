function [simOuts] = singleCompParameterSweep(car, subsystem, parameter, paramValues, makePlot)
    simOuts = {};
    scores = [];

    for i = 1:length(paramValues)
        fprintf('Running %s: %f\n', parameter, paramValues(i));
        
        car.(subsystem).(parameter) = paramValues(i);
        latAccelFudgeSave = car.params.latAccelFudge;
        % Simulate bad average driver performance
        car.params.latAccelFudge = car.params.latAccelFudge * 0.8;
        car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
        baseGGV = createGGV(car, 'display', true);
        % Simulate even worse average driver performance for endurance
        car.params.latAccelFudge = car.params.latAccelFudge * 0.9;
        car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
        enduranceGGV = createGGV(car, 'display', true);
        car.params.latAccelFudge = latAccelFudgeSave;
       
        comp = Competition();
        comp.accelCar = car;
        comp.skidpadGGV = baseGGV;
        comp.autocrossGGV = baseGGV;
        comp.enduranceGGV = enduranceGGV;
        
        simOut = comp.simulate();
        simOut.stats.(parameter) = paramValues(i);
        simOut.description = sprintf('%s: %f', parameter, paramValues(i));

        simOuts{i} = simOut;
        scores(i) = simOut.scores.total;
        fprintf('Score: %f for %s: %f\n', scores(i), parameter, paramValues(i));
    end

    if makePlot
        figure
        plot(paramValues, scores)
        xlabel(parameter)
        ylabel('Total score')
        title('Competition parameter sweep')
    end
end
