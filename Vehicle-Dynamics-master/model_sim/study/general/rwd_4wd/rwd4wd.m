cars = {};
carDescriptors = {};

for baseMass = 240:20:300
    for comD = 0.4:0.05:0.55
        for comH = 0.25:0.05:0.35
            car = Rev5Full();
            car.accumulator.maxPower = 80000;
            car.params.mocLossCoef = 0.8;
            car.params.estimatedMocLosses = 5000;
            car.params.baseMass = baseMass;
            car.params.comDistribution = comD;
            car.params.height = comH;
            car.setPowerTrainMasses(3.35, 5.45, 0);

            cars{end + 1} = car;
            desc = sprintf('Rev5 (%.2f kg, %.2f comD, %.2f comH)', car.params.mass, ...
                                    car.params.comDistribution, car.params.height);
            carDescriptors{end + 1} = desc;
        end
    end
end

for baseMass = 240:20:300
    for comD = 0.4:0.05:0.55
        for comH = 0.25:0.05:0.35
            car = Rev5Full();
            car.accumulator.maxPower = 80000;
            car.params.mocLossCoef = 0.8;
            car.params.estimatedMocLosses = 5000;
            car.params.baseMass = baseMass;
            car.params.comDistribution = comD;
            car.params.height = comH;
            car.setPowerTrainMasses(3.35, 5.45, 0);

            car.motors{1} = IdealMotor();
            car.motors{2} = IdealMotor();
            car.motors{3} = IdealMotor();
            car.motors{4} = IdealMotor();
    
            cars{end + 1} = car;
            desc = sprintf('Rev5 Ideal (%.2f kg, %.2f comD, %.2f comH)', car.params.mass, ...
                                    car.params.comDistribution, car.params.height);
            carDescriptors{end + 1} = desc;
        end
    end
end

for baseMass = 240:20:300
    for comD = 0.4:0.05:0.55
        for comH = 0.25:0.05:0.35
            car = Rev5Full();
            car.accumulator.maxPower = 80000;
            car.params.mocLossCoef = 0.8;
            car.params.estimatedMocLosses = 5000;
            car.params.baseMass = baseMass;
            car.params.comDistribution = comD;
            car.params.height = comH;
            car.setPowerTrainMasses(0.1, 0.1, 8);

            car.motors{1} = DeadMotor();
            car.motors{2} = DeadMotor();
    
            cars{end + 1} = car;
            desc = sprintf('Rev5 RWD (%.2f kg, %.2f comD, %.2f comH)', car.params.mass, ...
                                    car.params.comDistribution, car.params.height);
            carDescriptors{end + 1} = desc;
        end
    end
end

for baseMass = 240:20:300
    for comD = 0.4:0.05:0.55
        for comH = 0.25:0.05:0.35
            car = Rev5Full();
            car.accumulator.maxPower = 80000;
            car.params.mocLossCoef = 0.8;
            car.params.estimatedMocLosses = 5000;
            car.params.baseMass = baseMass;
            car.params.comDistribution = comD;
            car.params.height = comH;
            car.setPowerTrainMasses(0.1, 0.1, 8);

            car.motors{1} = DeadMotor();
            car.motors{2} = DeadMotor();
            car.motors{3} = IdealMotor();
            car.motors{4} = IdealMotor();
    
            cars{end + 1} = car;
            desc = sprintf('Rev5 RWD Ideal (%.2f kg, %.2f comD, %.2f comH)', car.params.mass, ...
                                    car.params.comDistribution, car.params.height);
            carDescriptors{end + 1} = desc;
        end
    end
end

