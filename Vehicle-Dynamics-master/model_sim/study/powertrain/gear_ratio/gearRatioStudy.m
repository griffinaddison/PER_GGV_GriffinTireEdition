car = Rev6Full();
car.motors = {DeadMotor(), DeadMotor(), ParametricMotor.Emrax_188(), ParametricMotor.Emrax_188()};
car.setPowerTrainMasses(0.725, 0.725, 10);
gearRatios = 3:0.5:7;
gearRatioAccelSweep(car, gearRatios, false, true);
