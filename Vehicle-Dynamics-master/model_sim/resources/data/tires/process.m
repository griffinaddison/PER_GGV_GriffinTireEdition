% Reads in calspan csvs and outputs slip ratio and Fx data
% This can then be read with the MFGui tool for parameter fitting

SACol = 4;
IACol = 5;
FxCol = 9;
FyCol = 10;
FzCol = 11;
SrCol = 21;
SlCol = 22;

% CALSPAN data comes from a super high friction band
% that gives a peak friction coefficient of over 2.
% We know on asphalt we get around 1.3 so we're scaling
% the data to match that.
longFrictionCoef = 1.5; % Bit higher due to noise in data
latFrictionCoef = 1.3;

% NORMAL LOAD SELECTION: with driver car is about 600 lbs
% -> 150 lbs per wheel -> 667 newtons
% Aero only adds 25 lbs per wheel in cornering so 150 lbs
% is still closer than the next available load (250 lbs)

% SLIP RATIO RESPONSE
disp('Analyzing slip ratio...');
NormalLoad = 667;

rawData = dlmread('B1464run39.dat', '', 3, 0);
filtered = rawData(abs(rawData(:, SACol)) < 0.1 & ...
                   abs(rawData(:, IACol)) < 0.1 & ...
                   abs(rawData(:, FzCol) + NormalLoad) < 40, :);

% The slip ratios and long force that are good for MFGui tool
xdata = filtered(:, SlCol).' * 100;
Fx = filtered(:, FxCol).';
Fx = Fx * longFrictionCoef * (NormalLoad / max(Fx));
save('processed/MFFitLongData.mat', 'xdata', 'Fx', 'NormalLoad');

figure
scatter(xdata, Fx);
xlabel('Slip ratio');
ylabel('Longitudinal force');

fprintf('Normal load: %f\n', NormalLoad);
fprintf('Num data points: %f\n', size(filtered, 1));

% SLIP ANGLE RESPONSE
disp('Analyzing slip ratio...');
NormalLoad = 667;

rawData = dlmread('B1464run20.dat', '', 3, 0);
filtered = rawData(abs(rawData(:, SrCol)) < 0.1 & ...
                   abs(rawData(:, IACol)) < 0.1 & ...
                   abs(rawData(:, FzCol) + NormalLoad) < 40, :);

% IT'S ACTUALLY FY, HAD TO CALL FX TO LOAD INTO MFGUI TOOL
xdata = -filtered(:, SACol).';
Fx = filtered(:, FyCol).';
Fx = Fx * latFrictionCoef * (NormalLoad / max(Fx));
save('processed/MFFitLatData.mat', 'xdata', 'Fx', 'NormalLoad');

figure
scatter(xdata, Fx);
xlabel('Slip angle');
ylabel('Lateral force');

fprintf('Normal load: %f\n', NormalLoad);
fprintf('Num data points: %f\n', size(filtered, 1));
