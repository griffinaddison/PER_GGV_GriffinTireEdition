function [simOuts] = doSims(simOuts, cars, carDescriptors, startI, endI)

for i = startI:endI
    fprintf("Simulating %s", carDescriptors{i});
    car = cars{i};
    car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
    baseGGV = createGGV(car);
    car.params.latAccelFudge = 1.2;
    car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
    enduranceGGV = createGGV(car);

    disp("GGVs created, running sims");
    
    comp = Competition();
    comp.accelCar = car;
    comp.skidpadGGV = baseGGV;
    comp.autocrossGGV = baseGGV;
    comp.enduranceGGV = enduranceGGV;

    simOut = comp.simulate();
    simOut.description = carDescriptors{i};
    simOut.car = cars{i};
    simOuts{end+1} = simOut;
end

end