function createMotorPlots(motor, gearRatio, makeSubPlots)
    if nargin < 3
        makeSubPlots = true;
    end
    if nargin < 2
        gearRatio = 1;
    end

    function handlePlot(subPlotIndex)
        if makeSubPlots
            subplot(1, 1, subPlotIndex);
        else
            figure;
        end
        hold on
    end

    function handleLegend(labels)
        if ~makeSubPlots
            set(gca,'fontsize', 40);
            legendflex(labels, 'fontsize', 40);
        else
            legendflex(labels);
        end
    end
    
    handlePlot(1);
    rpms = 0:5:20000;
    ws = rpms / 9.549;
    [torqueOut, debugOut] = arrayfun(@(w) motor.motorOutput(25, w * gearRatio), ws);
    torqueOut = torqueOut .* gearRatio;
    currentOut = [debugOut.current];
    powerOut = [debugOut.powerOut];
    powerLoss = [debugOut.powerLoss];

    plot(rpms, torqueOut);
    plot(rpms, currentOut);
    plot(rpms, powerOut ./ 1000);
    plot(rpms, powerLoss ./ 1000);
    xlabel('Rpm');
    ylabel('Motor torque (Nm) / current (A) / powerOut (kW) / powerLoss (kW)');
    title('Geared motor output vs car velocity at maximum requested torque');
    handleLegend({'Torque', 'Current', 'Power Out', 'Power Loss'})
end
