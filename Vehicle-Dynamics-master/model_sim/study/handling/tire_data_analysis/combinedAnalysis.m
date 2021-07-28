% Analyze 43075 16x7.5-10 R25B 8 combined corner / accel data
% Get rough estimate of how much doing both limits traction

tireData = readTireData(5, 39, 'cornering', false);
tireData.FZ = tireData.FZ * (-1);
tireData.P = tireData.P * 0.145038; % to PSI
tireData = filterData(tireData, 'ET', '>', 391);
tireData = filterData(tireData, 'FZ', '=', 690, 'eqTolerance', 50);
tireData = filterData(tireData, 'IA', '=', 0, 'eqTolerance', 0.2);
tireData = filterData(tireData, 'P', '=', 12, 'eqTolerance', 0.5);

totalFric = sqrt((tireData.FY ./ tireData.FZ) .^ 2 + ...
                 (tireData.FX ./ tireData.FZ) .^ 2);

figure
scatter3(tireData.FY ./ tireData.FZ, ...
    tireData.FX ./ tireData.FZ, totalFric);
xlabel('Lat fric');
ylabel('Long fric');
zlabel('Total friction');
title('Slip ratio sweep, fixed SA=6degrees');
