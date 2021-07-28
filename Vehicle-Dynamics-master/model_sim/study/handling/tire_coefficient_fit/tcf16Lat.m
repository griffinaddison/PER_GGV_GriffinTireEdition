% Writes data to load into MFGuiTool
% Currently is examining lateral force data for 43075 16x7.5-10 R25B 8 (Rev6 Tires)
round = 6;
run = 20;
runs = 25;
for run = run:runs
    

    try
            tireData = readTireData(round, run);
    end
    tireData.FZ = tireData.FZ * (-1); 

    % Filter warmup rounds
    %tireData = filterData(tireData, 'ET', '>', 235);

    NormalLoad = 650;

    % Get 150lb normal force data, 0 IA, 12 PSI
    tireData = filterData(tireData, 'FZ', '=', NormalLoad, 'eqTolerance', 50);
    tireData = filterData(tireData, 'IA', '=', 4, 'eqTolerance', 0.2);
    tireData = filterData(tireData, 'P', '=', 82.7371, 'eqTolerance', 3.44738);

    % Scale to account for difference between clean band and actual track
    % Based off of estimates from TTC forums, plus target friction coefficient of roughly 0.6

    % Needed to call it Fx because that's what MFGui expects

    data.Fz = tireData.FZ;
    data.SR = zeros(size(tireData.FY, 1), 1);
    % deg -> rad
    data.SA = deg2rad(tireData.SA);
    % deg -> rad
    data.IA = deg2rad(tireData.IA);
    data.Phit = zeros(size(tireData.FY, 1), 1);
    % kph -> m/s
    data.Vx = tireData.V / 3.6;
    % kPa -> Pa
    data.P = tireData.P * 1000;
    data.Fy = tireData.FY;
    data.Fx = tireData.FX;
    data.W = zeros(size(tireData.FY, 1), 1);

    coeff = (tireData.FY./tireData.FZ).*0.6;


    figure(run);

    %scatter(tireData.ET, tireData.FZ)
    camberData = tireData.IA;
    slipAngleData = tireData.SA;
    scatter(slipAngleData, coeff);
    grid on
    xlabel('Slip Angle [deg]')
    ylabel('Y Coefficient of Friction [-]')
    title("CoeffY vs SA - round " + round + " run " + run + " camber = 4")
    try %try cause if theres no data, the below text labels break
        text(0, max(coeff), "Max: " + max(coeff));
        text(0, min(coeff), "Min: " + min(coeff))
    end
    path = 'C:\Users\griff\Documents\Vehicle-Dynamics-master\model_sim\tireGraphs\testing2';
    saveas(run, fullfile(path, "round"+round+"run"+run),'png');
end



% xlabel('Time [s]')
% ylabel('Normal Force [N]')
% title("FZ vs Time - round " + round + " run " + run)








% save('2020lateral.mat', 'data');

% Next step: go into MFGuiTool (in plugins), load the data
% Fit it and make sure to output parameters to a file
% The parameters are gonna give wild results outside the
% data range, you have to reload them and tune them manually
