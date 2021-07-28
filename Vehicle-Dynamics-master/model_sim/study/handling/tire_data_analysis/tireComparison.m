% 16 inch analysis
%{
tires = ["43075 16x7.5-10 R25B 7", ...  
         "43075 16x7.5-10 R25B 8", ...
         "43070 16x6.0-10 R25B 6", ...
         "43070 16x6.0-10 R25B 7", ... 
         "43075 16x7.5-10 LCO 8", ... 
         "43075 16x7.5-10 LCO 7", ... 
         "43070 16x6.0-10 LCO 6", ... 
         "43070 16x6.0-10 LCO 7"];

rounds = [8, 8, 8, 8, 8, 8, 8, 8];
runs = [2, 6, 9, 12, 15, 18, 21, 24];
%}
%
%18 inch analysis
%{
tires = ["18.0 x 6.0 - 10 R25B 6", ...
         "18.0 x 6.0 - 10 R25B 7", ... % Rev5 Tire
         "6.0 / 18.0 - 10 LCO 6", ...
         "6.0 / 18.0 - 10 LCO 7"];

round = [5, 5, 5, 5];
runs = [18, 20, 22, 24];
%}

% R25Bs analysis
%{
tires = ["43075 16x7.5-10 R25B 7", ...  
         "43075 16x7.5-10 R25B 8", ...
         "43070 16x6.0-10 R25B 6", ...
         "43070 16x6.0-10 R25B 7", ...
         "18.0 x 6.0 - 10 R25B 6", ...
         "18.0 x 6.0 - 10 R25B 7"]; % Rev5 Tire
         
rounds = [8, 8, 8, 8, 5, 5];
runs = [2, 6, 9, 12, 18, 20];
%}

% Focused analysis
tires = ["43075 16x7.5-10 R25B 8", ...
         "18.0 x 6.0 - 10 R25B 6", ...
         "18.0 x 6.0 - 10 R25B 7"]; % Rev5 Tire
         
rounds = [8, 5, 5];
runs = [6, 18, 20];

figure
hold on

cmap = jet(length(runs));

for i = 1 : length(runs)
    tireData = processData(rounds(i), runs(i));
     scatter(tireData.SA, tireData.FY ./ tireData.FZ, 25, cmap(i, :), 'filled');
    %plot(tireData.SA, tireData.FY ./ tireData.FZ, 'color', cmap(i, :), 'linewidth', 4);
    xlabel('Slip angle');
    ylabel('Lateral friction coefficient');
end

legend(tires)

title('Tire comparisons')

function [tireData] = processData(round, run)
    tireData = readTireData(round, run);
    tireData.FZ = tireData.FZ * (-1);
    tireData.P = tireData.P * 0.145038; % to PSI

    % Filter warmup data
    if round == 5
        tireData = filterData(tireData, 'ET', '>', 391);
        tireData = filterData(tireData, 'FZ', '=', 690, 'eqTolerance', 50);
    elseif round == 8
        tireData = filterData(tireData, 'ET', '>', 235);
        tireData = filterData(tireData, 'FZ', '=', 650, 'eqTolerance', 50);
    end

    tireData = filterData(tireData, 'IA', '=', 0, 'eqTolerance', 0.2);
    tireData = filterData(tireData, 'P', '=', 10, 'eqTolerance', 0.5);
end
