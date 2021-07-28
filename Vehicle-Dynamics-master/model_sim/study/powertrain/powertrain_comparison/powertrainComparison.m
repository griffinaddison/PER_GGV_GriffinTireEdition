clear

car1 = Rev5Full();

car2 = Rev5Full();
car2.accumulator.maxPower = 80000;
car2.params.mocLossCoef = 0.8;
car2.params.estimatedMocLosses = 5000;
car2.setPowerTrainMasses(3.35, 5.45, 0);

car3 = Rev5Full();
car3.accumulator.maxPower = 80000;
car3.params.mocLossCoef = 0.8;
car3.params.estimatedMocLosses = 5000;
car3.setPowerTrainMasses(2.35, 4.45, 10.2);

car4 = Rev6Full();

car5 = Rev6Full();
% Fisher motors
car5.motors = {ParametricMotor(0.447, 2.2, 20000, 48),
               ParametricMotor(0.447, 2.2, 20000, 48),
               ParametricMotor(0.447, 2.2, 20000, 48),
               ParametricMotor(0.447, 2.2, 20000, 48)};
car3.setPowerTrainMasses(3.398, 3.398, 2.4);
car5.params.gearRatio = 6;

cars = {car1, car2, car3, car4, car5};
carDescriptors = {'GVKs', 'GVKs good MOCs outboard', 'GVKs good MOCs inboard', 'AMKs', 'Fishers'};

simOuts = {};

for i = 1 : length(cars)
    fprintf('Simulating: %s\n', carDescriptors{i});
    car = cars{i};
    car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
    baseGGV = createGGV(car);
    car.params.latAccelFudge = 1.3;
    car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
    enduranceGGV = createGGV(car);

    comp = Competition();
    comp.accelCar = car;
    comp.skidpadGGV = baseGGV;
    comp.autocrossGGV = baseGGV;
    comp.enduranceGGV = enduranceGGV;

    simOut = comp.simulate();
    simOut.description = carDescriptors{i};
    simOuts{end+1} = simOut;
end

pointsVisSim(simOuts);
