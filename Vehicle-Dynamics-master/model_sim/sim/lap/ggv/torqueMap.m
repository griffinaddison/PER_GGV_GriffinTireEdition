function [torques] = torqueMap(steer, powerUsage, driveStyle, car, w)
    powerScale = 1.0;
    torques = getTorques(car.accumulator.maxPower * powerUsage * powerScale, w, driveStyle, steer);
    
    while getPowerConsumption(torques, car, w) >= car.accumulator.maxPower
        powerScale = powerScale - 0.01;
        torques = getTorques(car.accumulator.maxPower * powerUsage * powerScale, w, driveStyle, steer);
    end
end

function torques = getTorques(availablePower, w, driveStyle, steer)
    fbTransferCoef = driveStyle.fbTransferCoef;
    lrTransferCoef = driveStyle.lrTransferCoef;

    totalTorque = availablePower / (w(1));
    torques = (totalTorque / 4) * ones(1, 4);
    fbTransfer = fbTransferCoef * totalTorque / 4;
    lrTransfer = -lrTransferCoef * steer * totalTorque / 4;
    
    torques = torques + [-fbTransfer + lrTransfer, ...
                         -fbTransfer - lrTransfer, ...
                          fbTransfer - lrTransfer, ...
                          fbTransfer + lrTransfer];
    
    torques = max(torques, 0);
end

function power = getPowerConsumption(torques, car, w)
    for i = 1:4
        motor = car.motors{i};
        [~, torques(i), motorPowers(i), motorLosses(i), ~, ~] = ...
            motor.compute({}, torques(i), w(i));
    end
    
    mocLosses = car.params.mocLossCoef * (torques .^ 2);
    power = sum(motorPowers) + sum(motorLosses) + sum(mocLosses);
end
