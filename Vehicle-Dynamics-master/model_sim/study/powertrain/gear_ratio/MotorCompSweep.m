function [simOuts] = MotorCompSweep(car, motors, gearRatios)
    simOuts = {};
    scores = [];

    for i = 1:length(motors)
        fprintf('Running motor: %s\n', motors{i});
        car.motors = {DeadMotor(), DeadMotor(), ParametricMotor.(motors{i})(), ParametricMotor.(motors{i})()};
        car.setPowerTrainMasses(0.725, 0.725, 10);
        for k = 1:length(gearRatios(i))
            ratio = gearRatios(i);
            fprintf('Running Gear Ratio: %f\n', ratio(k));
            for j = 3:4
                    car.motors{j}.gearRatio = ratio(k);
            end
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

            disp(car.params.mass);

            comp = Competition();
            comp.accelCar = car;
            comp.skidpadGGV = baseGGV;
            comp.autocrossGGV = baseGGV;
            comp.enduranceGGV = enduranceGGV;

            simOut = comp.simulate();
            simOut.stats.(motors{i}) = gearRatios(i);
            simOut.description = sprintf('%s: %f', motors{i}, ratio(k));

            simOuts{i} = simOut;
            scores(i) = simOut.scores.total;
            fprintf('Score: %f for %s: %f\n', scores(i), motors{i}, ratio(k));
        end
    end
% 
%     if makePlot
%         figure
%         plot(paramValues, scores)
%         xlabel(parameter)
%         ylabel('Total score')
%         title('Competition parameter sweep')
%     end
end
