car = Rev6Full();
car.params.latAccelFudge = 1.2;
car.init('weightTransfer', 'numeric', 'useWheelVelocity', false, 'detailedDebugging', true);
%ggv = createGGV(car);

track = readTrack('lincoln_endurance_2019');

simOut = lapSim(ggv, track, 'startVel', inf);

enduranceRun = simOut.runData;

rmsPower = getRms(enduranceRun.powerDelivered, enduranceRun.t)

frontTorque = (enduranceRun.motorTorqueFl + enduranceRun.motorTorqueFr) / 2;
rearTorque = (enduranceRun.motorTorqueBr + enduranceRun.motorTorqueBl) / 2;

rmsFrontTorque = getRms(frontTorque, enduranceRun.t)
rmsRearTorque = getRms(rearTorque, enduranceRun.t)

frontWheelVel = (enduranceRun.wheelSpeedFl + enduranceRun.wheelSpeedFr) / 2;
rearWheelVel = (enduranceRun.wheelSpeedRr + enduranceRun.wheelSpeedRl) / 2;

rmsFrontWheelVel = getRms(frontWheelVel, enduranceRun.t)
rmsRearWheelVel = getRms(rearWheelVel, enduranceRun.t)

function rmsVal = getRms(val, t)
    rmsVal = sqrt(val.' .^ 2 * ...
        [0; diff(t)] / max(t));
end
