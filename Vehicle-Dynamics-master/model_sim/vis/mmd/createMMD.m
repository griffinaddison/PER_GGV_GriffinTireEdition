function [mmd] = createMMD(varargin)
    p = inputParser;
    p.addRequired('car');
    p.addOptional('v', 15);
    p.addOptional('driveStyle', struct('fbTransferCoef', 0.25, ...
        'lrTransferCoef', 3.2, 'startPower', 1, 'powerUsage', 1, 'brakeUsage', 1));
    p.addOptional('mmdStyle', MMDStyle.Constant);
    p.parse(varargin{:});
 
    car = p.Results.car;
    v = p.Results.v;
    driveStyle = p.Results.driveStyle;
    mmdStyle = p.Results.mmdStyle;
    
    w = (v / car.params.radius) * ones(1, 4);
    
    switch(mmdStyle)
        case MMDStyle.Accel
            tm = @(steer) torqueMap(steer, 1, driveStyle, car, w);
        case MMDStyle.Brake
            driveStyle = struct('fbTransferCoef', 0, 'lrTransferCoef', 0);
            tm = @(steer) torqueMap(steer, 0, driveStyle, car, w);
        case MMDStyle.Neutral
            driveStyle = struct('fbTransferCoef', 0, 'lrTransferCoef', 0);
            tm = @(steer) torqueMap(steer, 0, driveStyle, car, w);
        case MMDStyle.Constant
            powerUsage = 1;
            tm = @(steer) torqueMap(steer, powerUsage, driveStyle, car, w);
            while straightLineAccel(v, tm, car) > 0
                powerUsage = powerUsage - 0.005;
                tm = @(steer) torqueMap(steer, powerUsage, driveStyle, car, w);
            end
    end
    
    bodySAs = linspace(-0.15, 0.15, 41);
    steers = linspace(-0.35, 0.35, 31);
    statedots = {{}};
    debugs = {{}};

    for i = 1 : length(bodySAs) 
        bodySA = bodySAs(i);

        for j = 1 : length(steers) 
            steer = steers(j);

            carState = struct('x', 0, 'xdot', v, 'y', 0, 'ydot', 0, ...
                      'h', bodySA, 'hdot', 0, 'w', w);
            accumulatorState = struct('energyDelivered', 0, 'energyRegened', 0);
            state = {carState, {}, {}, {}, {}, {}, {}, {}, {}, accumulatorState};

            control.steer = steer;

            if mmdStyle == MMDStyle.Brake
                control.brake = 1;
            else
                control.brake = 0;
            end

            control.inputTorques = tm(steer);

            [statedot, debug] = car.dynamics(...
                car.stateCollector.pack(state), ...
                car.controlDescriptor.pack(control));

            statedot = car.stateCollector.unpack(statedot);
            statedots{i, j} = statedot{1};
            debugs{i, j} = debug;
        end
    end
    
    mmd.bodySAs = bodySAs;
    mmd.steers = steers;
    mmd.statedots = statedots;
    mmd.debugs = debugs;

    [hullStatedots, hullDebugs] = convHull(mmd);
    mmd.hullStatedots = hullStatedots;
    mmd.hullDebugs = hullDebugs;
end

function [hullStatedots, hullDebugs] = convHull(mmd)
    yddots = parseField(mmd.statedots, 'ydot');
    hddots = parseField(mmd.statedots, 'hdot');

    yddots = yddots(:);
    hddots = hddots(:);

    k = convhull(yddots, hddots);
    
    flatStatedots = mmd.statedots(:);
    flatDebugs = mmd.debugs(:);
    
    hullStatedots = flatStatedots(k);
    hullDebugs = flatDebugs(k);
end

function accel = straightLineAccel(v, tm, car)
    w = (v / car.params.radius) * ones(1, 4);
    carState = struct('x', 0, 'xdot', v, 'y', 0, 'ydot', 0, ...
              'h', 0, 'hdot', 0, 'w', w);
    accumulatorState = struct('energyDelivered', 0, 'energyRegened', 0);
    state = {carState, {}, {}, {}, {}, {}, {}, {}, {}, accumulatorState};

    control.steer = 0;
    control.brake = 0;

    control.inputTorques = tm(control.steer);

    [statedot, debug] = car.dynamics(...
        car.stateCollector.pack(state), ...
        car.controlDescriptor.pack(control));

    statedot = car.stateCollector.unpack(statedot);
    accel = statedot{1}.xdot;
end
