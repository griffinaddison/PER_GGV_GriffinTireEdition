car = Rev6Full();
masses = 240:10:360;
simOuts = singleCompParameterSweep(car, 'params', 'mass', masses, true);
