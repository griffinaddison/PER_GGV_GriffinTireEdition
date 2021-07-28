clear

yawInertias = 60:5:180;
speeds = 13:0.5:24;

car = Rev5Full('boundTires', false);

% Add small safety margin
desiredLatDisplacement = car.params.trackwidth / 2 + 0.05;

results = {};

for i = 1 : length(yawInertias)
    yawInertia = yawInertias(i);

    fprintf('Yaw inertia: %f\n', yawInertia);
    car.params.I = yawInertia;
    car.init('weightTransfer', 'analytic', ...
             'useWheelVelocity', true);

    for j = 1 : length(speeds)
        speed = speeds(j);
        fprintf('Speed: %f\n', speed);

        % Steering frequency is proportional to speed
        % And also some yaw inertia factored in as well
        % Hand tuned to get about 20m long motion / period
        % With roughly the same period
        steerFreq = 0.95 * speed / 20 + 0.007 * yawInertia / 100;
        % Roughly optimal at all speed values
        steerAmp = 0.2;
        % Gives us 4-5 slaloms
        simTime = 80.0 / speed;

        controller = FullSlalomController(speed, steerAmp, steerFreq, 0, 0);

        simOut = fullSim('car', car, 'controller', controller, ...
                         'time', simTime, 'xstop', inf, 'v0', speed);

        dv = simOut.dynamicVars;
        results{i,j} = processSlalom(dv.x, dv.y);

        if max(abs(results{i,j}.ys)) > 3 || min(results{i,j}.ys ) >= 0
            results{i,j}.fail = true;
        else
            results{i,j}.fail = false;
        end
    end
end

% CONFIRM THAT ALL PLOTS HERE HAVE ROUGHLY THE SAME PERIOD 

pg = PlotGroup('rows', 1, 'cols', 1);
pg.handleFigure();

legends = {};
for i = 1 : length(yawInertias)
    for j = 1 : length(speeds)
        data = results{i,j};
        
        pg.createStaticPlot(data.xs, data.ys);
        legends{(i-1) * length(speeds) + j} = strcat('I: ', num2str(yawInertias(i)), ...
                            ' V: ', num2str(speeds(j)));
    end
end

pg.handleLegend(legends)

dispacements = [];
maxSpeeds = [];

for i = 1 : length(yawInertias)
    for j = 1 : length(speeds)
        data = results{i,j};
        [pksHigh] = findpeaks(data.ys);
        [pksLow] = findpeaks(-data.ys);
        displacement = mean([pksLow; pksHigh]);
        
        if data.fail
            %displacements(i, j) = inf;
            displacements(i, j) = displacement;
        else
            displacements(i, j) = displacement;
        end

        if displacement >= desiredLatDisplacement && ~data.fail
            maxSpeeds(i) = speeds(j);
        end
    end
end

figure
surf(speeds, yawInertias, displacements);
xlabel('Speed (m/s)');
ylabel('Yaw Inertia (kg m^2)');
zlabel('Slalom displacement');

figure
plot(yawInertias, maxSpeeds);
xlabel('Yaw Inertia (kg m^2)');
ylabel('Max slalom speed (m/s)');
