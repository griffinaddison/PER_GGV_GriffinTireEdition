car = Rev5Full();
maxPowers = 40000 : 5000 : 80000;
simOuts = compParameterSweep(car, 'accumulator', 'maxPower', maxPowers, true)
