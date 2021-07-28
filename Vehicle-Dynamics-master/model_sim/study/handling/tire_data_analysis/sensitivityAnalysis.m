% Hoosier 43075 16x7.5-10 R25B 8 

tireData = readTireData(8, 6);
tireData.FZ = tireData.FZ * (-1);
tireData.P = tireData.P * 0.145038; % to PSI

tireData = filterData(tireData, 'ET', '>', 235);
tireData = filterData(tireData, 'FZ', '>', 100);
tireData = filterData(tireData, 'IA', '=', 0, 'eqTolerance', 0.05);
tireData = filterData(tireData, 'P', '=', 10, 'eqTolerance', 0.5);

figure
scatter(tireData.SA, tireData.FY ./ tireData.FZ, 10, tireData.FZ);
xlabel('Slip angle');
ylabel('Lateral friction coefficient');
title('Load sensitivity, 10PSI, 0IA')

h = colorbar;
ylabel(h, 'Normal force (N)');

% Manually looking at data points for load sensitivity
figure
plot([200 440 670 870 1100], [2.88 2.71 2.64 2.57 2.47])
xlabel('Normal load (N)')
ylabel('Lateral friction coefficient (tail of curve) (10PSI, 0IA)')
