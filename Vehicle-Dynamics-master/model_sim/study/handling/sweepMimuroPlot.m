function sweepMimuroPlot(car, subsystem, parameter, paramValues, sweepVelocity)

    %CZ: NOTE: if sweepVelocity is true, only use a single param value!!

    legend_str = {};
    
    if sweepVelocity
        Vs = 22:4:45;
    else
        Vs = 22; % V = 22m/s = 80kph
    end
    
    plots = zeros(max(size(paramValues, 2), size(sweepVelocity, 2)), 4);
    
    for i = 1:length(paramValues)
        car.(subsystem).(parameter) = paramValues(i);
        car.init('weightTransfer', 'numeric', 'useWheelVelocity', true);
        cp = car.params;
        tireF = car.tires{1};
        tireR = car.tires{4};
        
        % No aero effects
        fzF = (cp.mass * cp.gravity * cp.comDistribution) / 2;
        fzR = (cp.mass * cp.gravity * (1 - cp.comDistribution)) / 2;
        
        %TODO: refactor to clean up and move calcs to helper
        for j = 1:length(Vs)
            V = Vs(j);
            q = max(i, j);
            inputsF = [fzF, 0, 0, 0, 0, V, tireF.pressure];
            inputsR = [fzR, 0, 0, 0, 0, V, tireR.pressure];

            mfOutputsF = mfeval(tireF.mfParams, inputsF, 121);
            mfOutputsR = mfeval(tireR.mfParams, inputsR, 121);

            Cf = -mfOutputsF(:, 26);
            Cr = -mfOutputsR(:, 26);
            Lf = (1 - cp.comDistribution) * cp.wheelbase;
            Lr = cp.comDistribution * cp.wheelbase;
            I = (cp.mass * cp.comDistribution * Lf^2) + (cp.mass * (1 - cp.comDistribution) * Lr^2);
            K = cp.mass * (Lr * Cr - Lf * Cf) / (cp.wheelbase^2 * Cf * Cr);
            yawGain = V / (cp.wheelbase * (1 + K * V^2) * cp.steerRatio);
            fn = (cp.wheelbase / (pi * V)) * sqrt(Cf * Cr * (1 + K * V^2) / (I * cp.mass)); % Natural frequency
            dampingRatio = (1 / (2 * cp.wheelbase)) * (I * (Cf + Cr) + cp.mass * (Lf^2 * Cf + Lr^2 * Cr)) ...
                           / sqrt(I * cp.mass * Cf * Cr * (1 + K * V^2));
            phaseLag = rad2deg(atan(Lf * cp.wheelbase * Cr / (cp.wheelbase * Cr * V / (2 * pi) - pi * I * V)) ...
                       - atan(2 * dampingRatio * fn / (fn^2 - 1)));
            points = [fn, phaseLag, dampingRatio, yawGain];
            plots(q, :) = points;
            if sweepVelocity
                legend_str{q} = num2str(V);
            else
                legend_str{q} = num2str(paramValues(q));
            end
        end
    end
    if sweepVelocity
        spider_plot(plots, 'AxesLimits', [1, -100, 0, 0; 4, -10, 3, 15], ...
            'AxesLabels', {'fn', 'Ⲫ', 'ζ', 'a1'}, 'Marker', 'none', 'LineWidth', 0.35, ...
            'AxesInterval', 1);
        title('Mimuro velocity sweep');
    else
        spider_plot(plots, 'AxesLimits', [2.25, -35, 0.95, 4; 3.25, -20, 1.15, 8], ...
            'AxesLabels', {'fn', 'Ⲫ', 'ζ', 'a1'}, 'Marker', 'none', 'LineWidth', 0.35, ...
            'AxesInterval', 1);
        title(strcat('Mimuro', {' '}, parameter, ' sweep'));
    end
    legend(legend_str, 'Location', 'bestoutside');
end

