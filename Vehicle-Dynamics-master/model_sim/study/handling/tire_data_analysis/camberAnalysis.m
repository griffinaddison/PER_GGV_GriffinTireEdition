% Looks at sensitivity data for Hoosier 43075 16x7.5-10 R25B 8 

tireData = readTireData(8, 6);
tireData.FZ = tireData.FZ * (-1);
tireData.P = tireData.P * 0.145038; % to PSI

%tireData = readLateral(8, 21);
tireData = filterData(tireData, 'ET', '>', 235);
tireData = filterData(tireData, 'FZ', '=', 650, 'eqTolerance', 50);
tireData = filterData(tireData, 'P', '=', 14, 'eqTolerance', 0.5);

figure
scatter(tireData.SA, tireData.FY ./ tireData.FZ, 10, tireData.IA);
xlabel('Slip angle');
ylabel('Lateral friction coefficient');

h = colorbar;
ylabel(h, 'Inclination Angle');

title('7.5 inches')
%title('6 inches')
