function powerConsumption = getPowerConsumption(car, speed, acceleration)
    
    maintainForce = .5*car.rho*car.cd*car.area*speed^2;
    
    accelerationForce = acceleration * car.mass;
    
    powerConsumption = speed*(maintainForce + accelerationForce) / car.effeciency;
    powerConsumption = max(0, powerConsumption);
end