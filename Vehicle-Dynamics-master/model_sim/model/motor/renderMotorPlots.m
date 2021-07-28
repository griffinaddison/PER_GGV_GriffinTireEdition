function [pg] = renderMotorPlots(varargin)
    p = inputParser;
    p.addRequired('motor');
    p.addParameter('plotGroup', PlotGroup('rows', 1, 'cols', 2))
    p.parse(varargin{:});
    res = p.Results;

    ws = 0 : 10 : 2000;
    rpms = ws * 9.549297;
    torqueOut = zeros(size(ws));
    currentOut = zeros(size(ws));
    powerOut = zeros(size(ws));
    powerLossOut = zeros(size(ws));

    for i = 1:length(ws)
        w = ws(i) / res.motor.gearRatio;
        [~, torque, power, powerLoss, current, ~] =  ...
            res.motor.compute({}, 1000000, w);
        torqueOut(i) = torque;
        powerOut(i) = power;
        powerLossOut(i) = powerLoss;
        currentOut(i) = current;
    end
    
    pg = res.plotGroup;
    pg.handleFigure();

    pg.createStaticPlot(rpms, torqueOut);
    pg.createStaticPlot(rpms, currentOut);
    pg.createStaticPlot(rpms, powerOut ./ 1000);
    pg.createStaticPlot(rpms, powerLossOut ./ 1000);
    xlabel('Rpm');
    ylabel('Motor torque (Nm) / current (A) / powerOut (kW) / powerLoss (kW)');
    title('Geared motor output vs car velocity at maximum requested torque');
    pg.handleLegend({'Torque', 'Current', 'Power Out', 'Power Loss'})

    w = 500 / res.motor.gearRatio;
    torquesRequested = (0 : 5 : 80);
    torqueOut = zeros(size(torquesRequested));
    currentOut = zeros(size(torquesRequested));
    powerOut = zeros(size(torquesRequested));
    powerLossOut = zeros(size(torquesRequested));

    for i = 1:length(torquesRequested)
        [~, torque, power, powerLoss, current, ~] =  ...
            res.motor.compute({}, torquesRequested(i), w);
        torqueOut(i) = torque;
        powerOut(i) = power;
        powerLossOut(i) = powerLoss;
        currentOut(i) = current;
    end

    pg.handleFigure()
    pg.createStaticPlot(torquesRequested, torqueOut)
    pg.createStaticPlot(torquesRequested, currentOut)
    pg.createStaticPlot(torquesRequested, powerOut ./ 1000)
    pg.createStaticPlot(torquesRequested, powerLossOut ./ 1000)
    xlabel('Requested torque');
    ylabel('Motor torque (Nm) / current (A) / powerOut (kW) / powerLoss (kW)');
    title(sprintf('Geared motor output as a function of requested torque at %f rpm', w * 9.549));
    pg.handleLegend({'Torque', 'Current', 'Power Out', 'Power Loss'})
    
end
