function plane = createGGVPlane(car, v, driveStyle)
    cp = car.params;
    w = (v / cp.radius) * ones(1, 4);
    carState = struct('x', 0, 'xdot', v, 'y', 0, 'ydot', 0, ...
                      'h', 0, 'hdot', 0, 'w', w);
    accumulatorState = struct('energyDelivered', 0, 'energyRegened', 0);
    state = {carState, {}, {}, {}, {}, {}, {}, {}, {}, accumulatorState};

    steers = quadspace(0, 0.12, 9);
    steers = [-flip(steers(2:end)), steers];
    
    ggvPoints = [];
    
    % Quadratically spaced to give more more detail
    % at finer powers
    powerPoints = quadspace(0, getMaxTractivePower(state, driveStyle, car), 5);
    for power = powerPoints
        accelTm = @(steer) torqueMap(steer, power, ...
          driveStyle, car, w);
        [ggvPointsAccel] = steerSweep( ...
            state, steers, 0, accelTm, car);
        
        ggvPoints = [ggvPoints, ggvPointsAccel];
    end

    brakePoints = quadspace(0, driveStyle.brakeUsage, 5);
    for brake = brakePoints
        brakeStyle = struct('fbTransferCoef', 0, 'lrTransferCoef', 0);
        brakeTm = @(steer) torqueMap(steer, 0, brakeStyle, car, w);
        [ggvPointsBrake] = steerSweep( ...
            state, steers, brake, brakeTm, car);

        ggvPoints = [ggvPoints, ggvPointsBrake];
    end
    
    ggvPoints = removeGGVPointVectors(ggvPoints);
    plane = GGVPlane(v, ggvPoints);
end

function [power] = getMaxTractivePower(state, driveStyle, car)
    % Lower power until longitudinal acceleration actually starts dropping
    xddot = getLongAccel(state, driveStyle, car);
    while abs(getLongAccel(state, driveStyle, car) - xddot) < 0.00001
        driveStyle.powerUsage = driveStyle.powerUsage - 0.02;
    end
    power = driveStyle.powerUsage;
end

function [xddot] = getLongAccel(state, driveStyle, car)
    control.steer = 0;
    control.brake = 0;
    control.inputTorques = torqueMap(0, driveStyle.powerUsage, ...
      driveStyle, car, state{1}.w);

    [statedot, debug] = car.dynamics(...
        car.stateCollector.pack(state), ...
        car.controlDescriptor.pack(control));
    statedot = car.stateCollector.unpack(statedot);

    xddot = statedot{1}.xdot;
end

function [ggvPoints] = removeGGVPointVectors(ggvPoints)
    fields = fieldnames(ggvPoints);
    for k = 1:numel(fields)
        d1 = ggvPoints.(fields{k});
        
        % TODO: support vector valued interpolation
        if ~isscalar(d1)
            ggvPoints = rmfield(ggvPoints, fields{k});
        end
    end 
end
