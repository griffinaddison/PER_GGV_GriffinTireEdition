clear

speed = 10;

car = Rev5Full('boundTires', false);

amplitudes = 0.1 : 0.03 : 0.3;
results = {};

for i = 1 : length(amplitudes)
    fprintf('Simulating: %f\n', amplitudes(i));
    car.init('weightTransfer', 'analytic', ...
             'useWheelVelocity', true);
    controller = FullSlalomController(speed, amplitudes(i), 1, 0, 0);

    simOut = fullSim('car', car, 'controller', controller, ...
                     'time', 3, 'xstop', inf, 'v0', speed);
    %fullVisSim(simOut);

    dv = simOut.dynamicVars;
    results{i} = processSlalom(dv.x, dv.y);
end

pg = PlotGroup('rows', 1, 'cols', 1);
pg.handleFigure();

legends = {};
for i = 1 : length(results)
    data = results{i};

    pg.createStaticPlot(data.xs, data.ys);
    legends{i} = strcat('Amplitude: ', num2str(amplitudes(i)));
end

pg.handleLegend(legends)

