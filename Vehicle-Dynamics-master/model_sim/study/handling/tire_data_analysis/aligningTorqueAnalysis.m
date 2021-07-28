% Hoosier 43075 16x7.5-10 R25B 8 

tireData = readTireData(8, 6);
tireData.FZ = tireData.FZ * (-1);
tireData.P = tireData.P * 0.145038; % to PSI

%tireData = readLateral(8, 21);
tireData = filterData(tireData, 'ET', '>', 235);
tireData = filterData(tireData, 'FZ', '=', 650, 'eqTolerance', 50);
tireData = filterData(tireData, 'IA', '=', 0, 'eqTolerance', 0.05);
tireData = filterData(tireData, 'P', '=', 10, 'eqTolerance', 0.05);
tireData = filterData(tireData, 'MZ', '>', -40);
tireData = filterData(tireData, 'MZ', '<', 40);

figure
scatter(tireData.SA, tireData.FY ./ tireData.FZ, 10, tireData.MZ);
xlabel('Slip angle');
ylabel('Lateral friction coefficient');

h = colorbar;
ylabel(h, 'Aligning torque');
