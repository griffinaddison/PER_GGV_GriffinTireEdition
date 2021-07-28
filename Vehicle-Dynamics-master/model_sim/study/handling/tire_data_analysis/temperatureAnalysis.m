% Hoosier 43075 16x7.5-10 R25B 8 

tireData = readTireData(8, 15);
tireData.FZ = tireData.FZ * (-1);
tireData.P = tireData.P * 0.145038; % to PSI

tireData = filterData(tireData, 'ET', '<', 110);
tireData = filterData(tireData, 'FZ', '=', 1100, 'eqTolerance', 200);
tireData = filterData(tireData, 'IA', '=', 0, 'eqTolerance', 0.05);
tireData = filterData(tireData, 'P', '=', 12, 'eqTolerance', 0.5);

figure
scatter(tireData.SA, tireData.FY ./ tireData.FZ, 10, tireData.TSTO);
%scatter(tireData.SA, tireData.FY, 10, tireData.TSTC);
xlabel('Slip angle');
ylabel('Lateral friction force');

h = colorbar;
ylabel(h, 'Tire temp');
