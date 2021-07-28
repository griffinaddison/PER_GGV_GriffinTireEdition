function [ pg1, pg2 ] = createDynamicPlots(simOut, makeSubPlots, useTime)
    if nargin == 1
        makeSubPlots = true;
        useTime = true;
    end
    if nargin == 2
        useTime = true;
    end
    
    pg1 = PlotGroup('makeSubPlots', makeSubPlots, ...
                   'rows', 3, 'cols', 3);
    set(0, 'DefaultLineLineWidth', 2);

    dv = simOut.dynamicVars;
    
    
    % Plot slip ratio
    pg1.handleFigure();
    pg1.createDynamicPlot(simOut.t, dv.srs(:, 1), 'r');
    pg1.createDynamicPlot(simOut.t, dv.srs(:, 2), 'b');
    pg1.createDynamicPlot(simOut.t, dv.srs(:, 3), 'g');
    pg1.createDynamicPlot(simOut.t, dv.srs(:, 4), 'm');
    title('Slip ratios');
    xlabel('Time (s)');
    ylabel('Slip ratio');
    pg1.handleLegend({'FL', 'FR', 'RR', 'RL'});

    % Plot slip angle
    pg1.handleFigure();
    pg1.createDynamicPlot(simOut.t, dv.sas(:, 1), 'r');
    pg1.createDynamicPlot(simOut.t, dv.sas(:, 2), 'b');
    pg1.createDynamicPlot(simOut.t, dv.sas(:, 3), 'g');
    pg1.createDynamicPlot(simOut.t, dv.sas(:, 4), 'm');
    title('Slip angles');
    xlabel('Time (s)');
    ylabel('Slip angles');
    pg1.handleLegend({'FL', 'FR', 'RR', 'RL'});

    % Wheel angles and wheel velocity dirs
    pg1.handleFigure();
    pg1.createDynamicPlot(simOut.t, dv.wheelAnglesB(:, 1), 'r');
    pg1.createDynamicPlot(simOut.t, dv.wheelAnglesB(:, 2), 'b');
    pg1.createDynamicPlot(simOut.t, dv.wheelAnglesB(:, 3), 'g');
    pg1.createDynamicPlot(simOut.t, dv.wheelAnglesB(:, 4), 'm');
    pg1.createDynamicPlot(simOut.t, dv.wheelVelocityDirsB(:, 1), '--r');
    pg1.createDynamicPlot(simOut.t, dv.wheelVelocityDirsB(:, 2), '--b');
    pg1.createDynamicPlot(simOut.t, dv.wheelVelocityDirsB(:, 3), '--g');
    pg1.createDynamicPlot(simOut.t, dv.wheelVelocityDirsB(:, 4), '--m');
    title('Wheel angles & velocity dirs');
    xlabel('Time (s)');
    ylabel('Angle');
    pg1.handleLegend({'FL', 'FR', 'RR', 'RL'});

    % Plot tire forces
    pg1.handleFigure();
    pg1.createDynamicPlot(simOut.t, dv.fzs(:, 1), 'r');
    pg1.createDynamicPlot(simOut.t, dv.fzs(:, 2), 'b');
    pg1.createDynamicPlot(simOut.t, dv.fzs(:, 3), 'g');
    pg1.createDynamicPlot(simOut.t, dv.fzs(:, 4), 'm');
    title('Tire normal forces');
    xlabel('Time (s)');
    ylabel('Force (N)');
    pg1.handleLegend({'FL', 'FR', 'RR', 'RL'});

    pg1.handleFigure();
    pg1.createDynamicPlot(simOut.t, dv.fxsT(:, 1), 'r');
    pg1.createDynamicPlot(simOut.t, dv.fxsT(:, 2), 'b');
    pg1.createDynamicPlot(simOut.t, dv.fxsT(:, 3), 'g');
    pg1.createDynamicPlot(simOut.t, dv.fxsT(:, 4), 'm');
    title('Tire longitudinal forces');
    xlabel('Time (s)');
    ylabel('Force (N)');
    pg1.handleLegend({'FL', 'FR', 'RR', 'RL'});

    pg1.handleFigure();
    pg1.createDynamicPlot(simOut.t, dv.fysT(:, 1), 'r');
    pg1.createDynamicPlot(simOut.t, dv.fysT(:, 2), 'b');
    pg1.createDynamicPlot(simOut.t, dv.fysT(:, 3), 'g');
    pg1.createDynamicPlot(simOut.t, dv.fysT(:, 4), 'm');
    title('Tire lateral forces');
    xlabel('Time (s)');
    ylabel('Force (N)');
    pg1.handleLegend({'FL', 'FR', 'RR', 'RL'});

    % Motor power
    pg1.handleFigure();

    pg1.createDynamicPlot(simOut.t, dv.powerDelivered, '--k');
    pg1.createDynamicPlot(simOut.t, dv.mocLosses, '--c');

    pg1.createDynamicPlot(simOut.t, dv.motorPowers(:, 1), 'r');
    pg1.createDynamicPlot(simOut.t, dv.motorPowers(:, 2), 'b');
    pg1.createDynamicPlot(simOut.t, dv.motorPowers(:, 3), 'g');
    pg1.createDynamicPlot(simOut.t, dv.motorPowers(:, 4), 'm');
  
    totalPowers = dv.motorPowers + dv.motorLosses;
    pg1.createDynamicPlot(simOut.t, totalPowers(:, 1), '--r');
    pg1.createDynamicPlot(simOut.t, totalPowers(:, 2), '--b');
    pg1.createDynamicPlot(simOut.t, totalPowers(:, 3), '--g');
    pg1.createDynamicPlot(simOut.t, totalPowers(:, 4), '--m');

    title('Motor power (with and without loss)');
    xlabel('Time (s)');
    ylabel('Motor power (Watts)');
    pg1.handleLegend({'Total delivered', 'MOC losses', 'FL', 'FR', 'RR', 'RL', 'FL w/ loss'});

    % Motor torque
    pg1.handleFigure();
    pg1.createDynamicPlot(simOut.t, dv.motorTorques(:, 1), 'r');
    pg1.createDynamicPlot(simOut.t, dv.motorTorques(:, 2), 'b');
    pg1.createDynamicPlot(simOut.t, dv.motorTorques(:, 3), 'g');
    pg1.createDynamicPlot(simOut.t, dv.motorTorques(:, 4), 'm');
%     pg1.createDynamicPlot(simOut.t, dv.inputTorques(:, 1), '--r');
%     pg1.createDynamicPlot(simOut.t, dv.inputTorques(:, 2), '--b');
%     pg1.createDynamicPlot(simOut.t, dv.inputTorques(:, 3), '--g');
%     pg1.createDynamicPlot(simOut.t, dv.inputTorques(:, 4), '--m');
    title('Motor torque');
    xlabel('Time (s)');
    ylabel('Torque (Nm)');

    ylim([0, 400])
    pg1.handleLegend({'FL', 'FR', 'RR', 'RL', ...
                     'FL Commanded', 'FR Commanded', ...
                     'RR Commanded', 'RL Commanded'});

    pg2 = PlotGroup('makeSubPlots', makeSubPlots, ...
                   'rows', 3, 'cols', 3);

    % Plot position & speed
    pg2.handleFigure();
    if useTime
        pg2.createDynamicPlot(simOut.t, dv.x, 'r');
        xlabel('Time (s)')
        ylabel('X position (m)');
    else
        pg2.createDynamicPlot(dx.x, dv.y, 'r');
        axis equal
        xlabel('X position (m)');
        ylabel('Y position (m)');
    end
    title('Position');

    pg2.handleFigure();
    if useTime
        pg2.createDynamicPlot(simOut.t, dv.carVelocityB(:, 1), 'r');
        xlabel('Time (s)');
        ylabel('Long velocity (m/s)');
    else
        pg2.createDynamicPlot(dv.carVelocityB(:, 1), dv.carVelocityB(:, 2), 'r');
        axis equal
        xlabel('Long velocity (m/s)');
        ylabel('Lat velocity (m/s)');
    end
    title('Velocity');

    pg2.handleFigure();
    if useTime
        pg2.createDynamicPlot(simOut.t,...
                              dv.FSumB(:, 1) / simOut.car.params.mass, 'r');
        xlabel('Time (s)');
        ylabel('Long acceleration (m/s^2)');
    else
        pg2.createDynamicPlot(dv.FSumB(:, 1) / simOut.car.params.mass, ...
                              dv.FSumB(:, 2) / simOut.car.params.mass, 'r');
        axis equal
        xlabel('Long acceleration (m/s^2)');
        ylabel('Lat acceleration (m/s^2)');
    end
    title('Acceleration');
    
    % Heading and velocitydir
    pg2.handleFigure();
    pg2.createDynamicPlot(simOut.t, dv.h, 'r');
    pg2.createDynamicPlot(simOut.t, dv.carVelocityDirW, 'b');
    title('Heading & Velocity Dir');
    xlabel('Time');
    ylabel('Angle (rads)');
    pg2.handleLegend({'Heading', 'Velocity dir'});

    % Plot angles
    pg2.handleFigure();
    title('Body slip angle');
    pg2.createDynamicPlot(simOut.t, dv.carSA, 'b');
    xlabel('Time (s)');
    ylabel('Angle (rad)');
    pg2.handleLegend({'Body slip angle'});

    % Plot forces
    pg2.handleFigure();
    pg2.createDynamicPlot(simOut.t, dv.FSumB(:, 1), 'r');
    pg2.createDynamicPlot(simOut.t, dv.FSumB(:, 2), 'b');
    title('Body forces');
    xlabel('Time (s)');
    ylabel('Force (N)');
    pg2.handleLegend({'X', 'Y'});

end

