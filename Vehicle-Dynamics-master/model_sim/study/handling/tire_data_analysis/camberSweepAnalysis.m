% Looks at sensitivity data for Hoosier 43075 16x7.5-10 R25B 8 

tireData = readTireData(8, 7);
tireData.FZ = tireData.FZ * (-1);
tireData.P = tireData.P * 0.145038; % to PSI

%tireData = readLateral(8, 21);
tireData = filterData(tireData, 'ET', '>', 1650);
tireData = filterData(tireData, 'FZ', '=', 1100, 'eqTolerance', 200);
tireData = filterData(tireData, 'P', '=', 10, 'eqTolerance', 0.5);

figure
scatter(tireData.IA, tireData.FY ./ tireData.FZ, 10, tireData.TSTC);
xlabel('Inclination angle');
ylabel('Lateral friction coefficient');
title('Friction coefficient vs camber sweeps at 250lbs normal, 10PSI')

h = colorbar;
ylabel(h, 'Tire temp (center)');
