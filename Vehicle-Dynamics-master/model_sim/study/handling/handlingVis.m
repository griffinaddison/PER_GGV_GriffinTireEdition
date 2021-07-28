function handlingVis(varargin)
    p = inputParser;
    p.StructExpand = false;
    p.addRequired('simOut');
    p.addOptional('simOut2', []);
    p.addOptional('track', []);
    p.parse(varargin{:});
    
    simOut = p.Results.simOut;
    simOut2 = p.Results.simOut2;
    comparison = ~isequal(simOut2, []);
    
    track = p.Results.track;
    plotTrack = ~isequal(track, []);
    
    set(0, 'DefaultLineLineWidth', 2);
    set(0, 'DefaultFigureColor', [240 240 240]/255);
    pg = PlotGroup('rows', 3, 'cols', 2);
    pg.handleFigure();

    data = simOut.dynamicVars;
    if comparison
        data2 = simOut2.dynamicVars;
    end
    
    if comparison
        x = 0:0.25:min(max(data.x.'), max(data2.x.'));
        t = 0:0.05:min(max(simOut.t.'), max(simOut2.t.'));
    else
        x = 0:0.25:max(data.x.');
        t = 0:0.001:max(simOut.t.');
    end

    % Path of travel
    for i = 1 : length(size(data.x, 1))
        grid on
        pg.createStaticPlot(data.x.', data.y.');
        if comparison
            pg.createStaticPlot(data2.x.', data2.y.');
        end
        if plotTrack
            trackVis(track, pg);
        end
        xlabel('X Position [m]');
        ylabel('Y Position [m]');
        title('Simulated Path of Travel');
        legend('New Model', 'Old Model', 'Track');
    end
    if comparison
        y1 = interp1(data.x.', data.y.', x); 
        y2 = interp1(data2.x.', data2.y.', x);
        delta = abs(y1 - y2);
        idx = find(y2 ~= 0 | y1 ~=0);
        percentDiff = delta(:, idx) ./ max(abs(y2(:, idx)), abs(y1(:, idx)));
        meanPercentDiff = mean(percentDiff);
        fprintf('Percentage Diff Path: %f\n', meanPercentDiff);
    end
    
    

%     %Steer vs Time
%     pg.handleFigure();
%     for i = 1 : length(size(data.x, 1))
%         grid on
%         pg.createStaticPlot(simOut.t.', data.steer.');
%         if comparison
%             pg.createStaticPlot(simOut2.t.', data2.steer.');
%         end
%         xlabel('Time [s]');
%         ylabel('Steer [rad]');
%         title('Steer vs Time');
%         legend('New Model', 'Old Model');
%     end
    
    
    % FxsT vs X Pos
    pg.handleFigure();
    for i = 1 : length(size(data.x, 1))
        grid on
%         pg.createStaticPlot(simOut.t.', data.fxsT(:, 1).');
%         pg.createStaticPlot(data.x.', data.fxsT(:, 2).');
%         pg.createStaticPlot(data.x.', data.fxsT(:, 3).');
        pg.createStaticPlot(simOut.t.', data.fxsT(:, 4).');
        if comparison
%             pg.createStaticPlot(simOut2.t.', data2.fxsT(:, 1).');
%             pg.createStaticPlot(data2.x.', data2.fxsT(:, 2).');
%             pg.createStaticPlot(data2.x.', data2.fxsT(:, 3).');
            pg.createStaticPlot(simOut2.t.', data2.fxsT(:, 4).');
        end
%         xlabel('X Position [m]');
        xlabel('Time [s]');
        ylabel('Tire Fx [N]');
        title('Longitudinal Tire Force vs Time');
        legend('[New] RL', '[Old] RL');
    end
    
    % FysT vs X Pos
    pg.handleFigure();
    for i = 1 : length(size(data.x, 1))
        grid on
%         pg.createStaticPlot(simOut.t.', data.fysT(:, 1).');
%         pg.createStaticPlot(data.x.', data.fysT(:, 2).');
%         pg.createStaticPlot(data.x.', data.fysT(:, 3).');
        pg.createStaticPlot(simOut.t.', data.fysT(:, 4).');
        if comparison
%             pg.createStaticPlot(simOut2.t.', data2.fysT(:, 1).');
%             pg.createStaticPlot(data2.x.', data2.fysT(:, 2).');
%             pg.createStaticPlot(data2.x.', data2.fysT(:, 3).');
            pg.createStaticPlot(simOut2.t.', data2.fysT(:, 4).');
        end
%         xlabel('X Position [m]');
        xlabel('Time [s]');
        ylabel('Tire Fy [N]');
        title('Lateral Tire vs Time');
        legend('[New] RL', '[Old] RL');
%         xlim([1.25 1.5])
    end

    %Velocity vs X Pos
%     pg.handleFigure();
%     for i = 1 : length(size(data.x, 1))
%         grid on
%         pg.createStaticPlot(data.x.', sqrt(data.xdot.^2 + data.ydot.^2).');
%         xlabel('X Position');
%         ylabel('Velocity');
%         title('Velocity vs X Position');
%     end
    
    % SA vs X Pos
    pg.handleFigure();
    for i = 1 : length(size(data.x, 1))
        grid on
%         pg.createStaticPlot(simOut.t.', data.sas(:, 1).');
%         pg.createStaticPlot(simOut.t.', data.sas(:, 2).');
%         pg.createStaticPlot(simOut.t.', data.sas(:, 3).');
        pg.createStaticPlot(simOut.t.', data.sas(:, 4).');
        if comparison
%             pg.createStaticPlot(simOut2.t.', data2.sas(:, 1).');
%             pg.createStaticPlot(data2.x.', data2.sas(:, 2).');
%             pg.createStaticPlot(data2.x.', data2.sas(:, 3).');
            pg.createStaticPlot(simOut2.t.', data2.sas(:, 4).');
        end
%         xlabel('X Position [m]');
        xlabel('Time [s]');
        ylabel('Slip Angle [rad]');
        title('Slip Angle vs Time');
        legend('[New] RL', '[Old] RL');
    end
%     y1 = interp1(data.x.', data.sas(:, 1).', x); 
%     y2 = interp1(data2.x.', data2.sas(:, 1).', x);
%     delta = abs(y1 - y2);
%     idx = find(y2 ~= 0 | y1 ~=0);
%     percentDiff = delta(:, idx) ./ max(abs(y2(:, idx)), abs(y1(:, idx)));
%     meanPercentDiff = mean(percentDiff);
%     fprintf('Percentage Diff SA: %f\n', meanPercentDiff);
    
%     % SR vs Time
%     pg.handleFigure();
%     for i = 1 : length(size(data.x, 1))
%         grid on
%         pg.createStaticPlot(simOut.t.', data.srs(:, 1).');
%         pg.createStaticPlot(simOut.t.', data.srs(:, 2).');
%         pg.createStaticPlot(simOut.t.', data.srs(:, 3).');
%         pg.createStaticPlot(simOut.t.', data.srs(:, 4).');
%         if comparison
%             pg.createStaticPlot(simOut2.t.', data2.srs(:, 1).');
%             pg.createStaticPlot(simOut2.t.', data2.srs(:, 2).');
%             pg.createStaticPlot(simOut2.t.', data2.srs(:, 3).');
%             pg.createStaticPlot(simOut2.t.', data2.srs(:, 4).');
%         end
%         xlabel('Time [s]');
%         ylabel('Slip Ratio');
%         title('Slip Ratio vs Time');
%         legend('[New] FL', '[New] FR', '[New] RR', '[New] RL', ...
%             '[Old] FL', '[Old] FR', '[Old] RR', '[Old] RL');
%     end
%     if comparison
%         y1 = interp1(simOut.t.', data.srs(:, 3).', t); 
%         y2 = interp1(simOut2.t.', data2.srs(:, 3).', t);
%         delta = abs(y1 - y2);
%         idx = find(y2 ~= 0 | y1 ~=0);
%         percentDiff = delta(:, idx) ./ max(abs(y2(:, idx)), abs(y1(:, idx)));
%         meanPercentDiff = mean(percentDiff);
%         fprintf('Percentage Diff SR: %f\n', meanPercentDiff);
%     end
    
    % W vs X Position
    pg.handleFigure();
    for i = 1 : length(size(data.x, 1))
        grid on
%         pg.createStaticPlot(simOut.t.', data.w(:, 1).');
%         pg.createStaticPlot(simOut.t.', data.w(:, 2).');
%         pg.createStaticPlot(simOut.t.', data.w(:, 3).');
        pg.createStaticPlot(simOut.t.', data.w(:, 4).');
        if comparison
%             pg.createStaticPlot(simOut2.t.', data2.w(:, 1).');
%             pg.createStaticPlot(simOut2.t.', data2.w(:, 2).');
%             pg.createStaticPlot(simOut2.t.', data2.w(:, 3).');
            pg.createStaticPlot(simOut2.t.', data2.w(:, 4).');
        end
%         xlabel('X Position [m]');
        xlabel('Time [s]');
        ylabel('Wheel Angular Vel. [rad/s]');
        title('Wheel Angular Vel. vs Time');
        legend('[New] RL', '[Old] RL');
    end
    
%     % WheelvelocitiesDirected vs Time
%     pg.handleFigure();
%     for i = 1 : length(size(data.x, 1))
%         grid on
%         pg.createStaticPlot(simOut.t.', data.wheelVelocitiesDirected(:, 1).');
%         pg.createStaticPlot(simOut.t.', data.wheelVelocitiesDirected(:, 2).');
%         pg.createStaticPlot(simOut.t.', data.wheelVelocitiesDirected(:, 3).');
%         pg.createStaticPlot(simOut.t.', data.wheelVelocitiesDirected(:, 4).');
%         if comparison
%             pg.createStaticPlot(simOut2.t.', data2.w(:, 1).');
%             pg.createStaticPlot(simOut2.t.', data2.w(:, 2).');
%             pg.createStaticPlot(simOut2.t.', data2.w(:, 3).');
%             pg.createStaticPlot(simOut2.t.', data2.w(:, 4).');
%         end
%         xlabel('Time [s]');
%         ylabel('Wheel Vel D. [rad/s]');
%         title('Wheel Vel D. vs Time');
%         legend('[New] FL', '[New] FR', '[New] RR', '[New] RL', ...
%             '[Old] FL', '[Old] FR', '[Old] RR', '[Old] RL');
%     end

    %Yaw Moment vs X Pos
    pg.handleFigure();
    for i = 1 : length(size(data.x, 1))
        grid on
        pg.createStaticPlot(simOut.t.', data.yawMoment.');
        if comparison
            pg.createStaticPlot(simOut2.t.', data2.yawMoment.');
        end
%         xlabel('X Position [m]');
        xlabel('Time [s]');
        ylabel('Yaw Moment [Nm]');
%         title('Yaw Moment vs X Position');
        title('Yaw Moment vs Time');
        legend('New Model', 'Old Model');
    end
    if comparison
        y1 = interp1(data.x.', data.yawMoment.', x); 
        y2 = interp1(data2.x.', data2.yawMoment.', x);
        delta = abs(y1 - y2);
        idx = find(y2 ~= 0 | y1 ~=0);
        percentDiff = delta(:, idx) ./ max(abs(y2(:, idx)), abs(y1(:, idx)));
        meanPercentDiff = mean(percentDiff);
        fprintf('Percentage Diff Yaw Moment: %f\n', meanPercentDiff);
    end
    
%     % Wheel velocities directed
%     pg.handleFigure();
%     for i = 1 : length(size(data.x, 1))
%         grid on
%         pg.createStaticPlot(simOut.t.', data.wheelVelocitiesDirected(:, 1).');
%         pg.createStaticPlot(simOut.t.', data.wheelVelocitiesDirected(:, 2).');
%         pg.createStaticPlot(simOut.t.', data.wheelVelocitiesDirected(:, 3).');
%         pg.createStaticPlot(simOut.t.', data.wheelVelocitiesDirected(:, 4).');
%         xlabel('Time [s]');
%         ylabel('Vx [m/s]');
%         title('Vx vs Time');
%         legend('FL', 'FR', 'RR', 'RL');
%     end

    %Accel Time
    fprintf('Time to finish [New]: %f\n', simOut.t(end));
    if comparison
        fprintf('Time to finish [Old]: %f\n', simOut2.t(end));
    end

    hold off

end

