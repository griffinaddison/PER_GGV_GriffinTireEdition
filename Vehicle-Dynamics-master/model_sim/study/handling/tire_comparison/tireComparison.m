clear

car1 = Rev6Full();
car1.params.latAccelFudge = car1.params.latAccelFudge * 0.8;

car2 = Rev6Full();
tires = {MFGuiTireFull.hoosier18R25B(true, true, true), ...
         MFGuiTireFull.hoosier18R25B(true, true, true), ...
         MFGuiTireFull.hoosier18R25B(true, true, true), ...
         MFGuiTireFull.hoosier18R25B(true, true, true)};
car2.params.latAccelFudge = car2.params.latAccelFudge * 0.8;
car2.tires = tires;
car2.params.radius = 0.228;
car2.params.mass = car2.params.mass + 3;

carDescriptors = {'New tires', 'Old tires'};

cars = {car1, car2};
simOuts = {};

for i = 1 : length(cars)
    fprintf('Simulating: %s\n', carDescriptors{i});
    car = cars{i};
    car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
    baseGGV = createGGV(car);
    car.params.latAccelFudge = car.params.latAccelFudge * 0.8;
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
