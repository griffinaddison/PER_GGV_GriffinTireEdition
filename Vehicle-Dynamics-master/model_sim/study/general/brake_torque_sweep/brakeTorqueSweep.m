car = Rev6Full();
brakeTorque = 300 : 200 : 2000;
simOuts = compParameterSweep(car, 'params', 'totalBrakeTorque', brakeTorque, true);
