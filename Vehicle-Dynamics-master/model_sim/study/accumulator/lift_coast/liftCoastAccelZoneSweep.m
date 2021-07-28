function [simOuts] = liftCoastAccelZoneSweep(car, makePlot)
    simOuts = {};
    scores = [];
    
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
    
    comp = Competition('accel', false, 'skidpad', false);
    comp.accelCar = car;
    comp.skidpadGGV = baseGGV;
    comp.autocrossGGV = baseGGV;
    comp.enduranceGGV = enduranceGGV;
    
    idx = 1;
    for i = 0.1:0.1:1
        fprintf('Running Accel Percent: %f\n', i);
        
        comp.accelPercent = i;
        simOut = comp.simulate();
        simOut.stats.accelPercent = i;
        simOut.description = sprintf('Accel Percent: %f', i);

        simOuts{idx} = simOut;
        scores(idx) = simOut.scores.total;
        fprintf('Score: %f for Accel Percent: %f\n', scores(idx), i);
        idx = idx + 1;
    end

    if makePlot
        figure
        plot(0.1:0.1:1, scores)
        xlabel('Accel Percent')
        ylabel('Total score')
        title('Lift Coast Accel Percent Sweep')
    end
end
