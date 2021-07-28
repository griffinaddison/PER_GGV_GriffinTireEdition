clear

pcar = Rev6Full();

rwd = 1;

nominalMass = pcar.params.mass;
nominalPower = pcar.accumulator.maxPower;
nominalLatAccelFudge = pcar.params.latAccelFudge;

% powers = 25000 : 5000 : nominalPower;
powers = [50000, 60000, 70000, 80000];
massDeltas = -10: 1 : 10;
% massDeltas = 0;

emsweep.powers = powers;
emsweep.massDeltas = massDeltas;
simOuts = cell(length(massDeltas));

tic
parfor i = 1:length(massDeltas)
    car = Rev6Full();
    if rwd 
        car.motors{1} = DeadMotor();
        car.motors{2} = DeadMotor();
    end
    massDelta = massDeltas(i);
    fprintf('Testing mass delta: %f (%d)\n', massDelta, i);

    disp('Generating base ggv');
    car.accumulator.maxPower = nominalPower;
    car.params.latAccelFudge = nominalLatAccelFudge;
    car.params.mass = nominalMass + massDelta;

    car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
    baseGGV = createGGV(car);

    powerOuts = {}
    for j = 1 : length(powers)
        power = powers(j);
        fprintf('Testing power: %f (%d)\n', power, j);

        car.accumulator.maxPower = power;
        % Reduce driving ability
        car.params.latAccelFudge = 1.2;

        car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
        enduranceGGV = createGGV(car);
        
        car.accumulator.maxPower = nominalPower;
        car.params.latAccelFudge = nominalLatAccelFudge;

        comp = Competition();
        comp.accelCar = car;
        comp.skidpadGGV = baseGGV;
        comp.autocrossGGV = baseGGV;
        comp.enduranceGGV = enduranceGGV;
        
        simOut = comp.simulate();
        enduranceRun = simOut.dynamicEvents.endurance.simOut.runData;
        rmsPower = sqrt([enduranceRun.powerDelivered].' .^ 2 * ...
            [0; diff([enduranceRun.t])] / max([enduranceRun.t]));
        simOut.dynamicEvents.endurance.simOut.stats.rmsPower = rmsPower;
        simOut.massDelta = massDelta;
        simOut.power = power;
        simOut.description = sprintf('massdelta %f, power: %f', massDelta, power);
        powerOuts{j} = simOut
    end
    simOuts{i} = powerOuts
end
simOuts = simOuts(:,1);
simOuts = vertcat(simOuts{:});
simOuts = simOuts(:);

emsweep.simOuts = simOuts;
if rwd 
    save('emsweep_rwd', 'emsweep');
else
    save('emsweep_4wd', 'emsweep');
end
toc
