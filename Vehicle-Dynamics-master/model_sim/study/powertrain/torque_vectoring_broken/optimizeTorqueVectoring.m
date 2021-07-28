car = Rev5Full();
car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
cp = car.params;

v = 14;
w = (v / cp.radius) * ones(1, 4);

hold on

fbTransferCoefs = 0.1 : 0.05 : 0.3;
lrTransferCoefs = 1 : 0.8 : 5; % Since it's multiplied by steer gotta be scaled

fbTransferCoefs = 0.25;

% ROUGHLY OPTIMAL:
% fbTransferCoefs = 0.25;
% lrTransferCoefs = 3.2;

for fbTransferCoef = fbTransferCoefs
    for lrTransferCoef = lrTransferCoefs
        state = struct('x', 0, 'xdot', v, 'y', 0, 'ydot', 0, ...
                       'h', 0, 'hdot', 0, 'w', w);

        steers = -0.15 : 0.01 : 0.15;
        brake = 0;

        tm = @(steer) torqueMap(steer, 1, ...
            fbTransferCoef, lrTransferCoef, cp, w);

        [xddots, yddots] = steerSweep(state, steers, brake, tm, car);

        scatter(yddots, xddots, 60, ...
            ones(size(yddots)) * lrTransferCoef, 'filled');
    end
end
