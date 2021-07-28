% Writes data to load into MFGuiTool
% Currently is examining lateral force data for 18" R25B (Rev5 Tires)

tireData = readTireData(5, 20);  %round, run (if i remember correctly hehe)
tireData.FZ = tireData.FZ * (-1);
% Filter warmup rounds
tireData = filterData(tireData, 'ET', '>', 391);

NormalLoad = 650;

% Get 150lb normal force data, 0 IA, 10 PSI
tireData = filterData(tireData, 'FZ', '=', NormalLoad, 'eqTolerance', 50);  %range of normal force FZ
tireData = filterData(tireData, 'IA', '=', 0, 'eqTolerance', 0.2);
tireData = filterData(tireData, 'P', '=', 82.7371, 'eqTolerance', 3.44738); %tire pressure

% Scale to account for difference between clean band and actual track
% Based off of estimates from TTC forums, plus target friction coefficient of roughly 0.6
% Needed to call it Fx because that's what MFGui expects
Fx = tireData.FY * 0.6;
xdata = -tireData.SA;

data.Fz = tireData.FZ;
data.SR = tireData.SR;
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
data.W = tireData.N;

save('18R25Brun20.mat', 'data');

scatter(xdata, Fx);

% Next step: go into MFGuiTool (in plugins), load the data
% Fit it and make sure to output parameters to a file
% The parameters are gonna give wild results outside the
% data range, you have to reload them and tune them manually
