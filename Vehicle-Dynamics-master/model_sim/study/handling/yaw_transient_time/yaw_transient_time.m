car = Rev5Full();

speed = 15;

controller = FullCorneringController(0.2, speed, 0, 0);

yawInertias = 20:4:60;
times = zeros(size(yawInertias));

for i = 1 : length(yawInertias)
    car.params.I = yawInertias(i);
    car.init('weightTransfer', 'numeric', 'useWheelVelocity', true);

    simOut = fullSim('car', car, 'controller', controller, ...
                     'time', 5, 'xstop', inf, 'v0', speed);

    [m, index] = max(simOut.dynamicVars.FSumB(:, 2) / car.params.mass);

    times(i) = simOut.t(index);

    fprintf('Time to hit max lat acceleration: %f\n', simOut.t(index));
end

figure;
plot(yawInertias, times);
xlabel('Yaw inertia (kg m^2)');
ylabel('Time to hit apex lat accel in corner');
title(sprintf('Yaw inertia effects at %fmps \n', speed));
