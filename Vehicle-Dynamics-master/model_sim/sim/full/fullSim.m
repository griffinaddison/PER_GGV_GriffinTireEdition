function [simOut] = fullSim(varargin)
    p = inputParser;
    p.addOptional('car', Rev6Full().init(...
        'weightTransfer', 'numeric', 'useWheelVelocity', true));
    p.addOptional('controller', FullSineTestController(0.1, 0.5, 50));
    p.addOptional('time', 5);
    p.addOptional('xstop', 75);
    p.addOptional('v0', 15.0);
    p.addOptional('display', false);
    p.parse(varargin{:});

    car = p.Results.car;
    controller = p.Results.controller;

    vx0 = p.Results.v0;
    vy0 = 0;

    wI = norm([vx0, vy0]) / car.params.radius;
    carStateI = [0; vx0; 0; vy0; atan2(vy0, vx0); 0; wI; wI; wI; wI];
    motorStatesI = [];
    tireStatesI = [];
    accumulatorStateI = [0; 0];
    
    if p.Results.display
        disp('Integrating car dynamics...');
    end
    tic
    
    opts = odeset('Events', @(t,x) terminateEvent(t, x, p.Results.xstop, car), ...
                'OutputFcn', @odephas2, 'OutputSel', [1, 3], 'RelTol', 1e-2, 'AbsTol', 1e-3);
    [t, y] = ode23tb(@(t, state) car.dynamics(state, controller.control(t, state)), ...
                [0, p.Results.time], [carStateI; motorStatesI; tireStatesI; accumulatorStateI].', opts);
    elapsedTime = toc;
    if p.Results.display
        fprintf('Finished integrating with time: %f\n', elapsedTime);
        fprintf('Took %d time steps\n', length(t));
    end

    simOut.t = t;
    simOut.car = car;
    simOut.stats.finishTime = max(t);
    simOut.dynamicVars = car.stateCollector.unpack(y);
    % Only keep the car & accumulator dynamic vars
    simOut.dynamicVars = catstruct(simOut.dynamicVars{1}, ...
                                   simOut.dynamicVars{10});
                               
    % Copy all the dynamics debug output into simulation output
    for i = 1:length(t)
        [~, debug] = car.dynamics(y(i, :)', controller.control(t(i), y(i, :)'));
        f = fieldnames(debug);
        for k = 1:length(f)
            simOut.dynamicVars.(f{k})(i, :) = debug.(f{k});
        end
    end
end

% This function stops integration when xstop is reached (value hits 0)
function [value, isterminal, direction] = terminateEvent(t, state, xstop, car)
    state = car.stateCollector.unpack(state);
    carState = state{1};
    value = carState.x - xstop;
    isterminal = 1;   % Stop the integration
    direction = 0;
end

