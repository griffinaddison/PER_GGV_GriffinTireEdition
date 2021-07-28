% Writes data to load into MFGuiTool
% Examining lateral force data for 18" R25B (Rev5 Tires)
round = 6; %round number
run = 35; %first run number (of desired range)
runs = 39; %last run number

% ERROR NOTES: i often repeatedly got error Reference to non-existent field
% 'SL' for round 6, run 34, runs 65. Then i changed run from 34 to one of
% the later runs like 40, it worked and generated the remaining graphs,
% then i plugged in 34 again and it worked. i changed no code. I just ran a
% test with a different number first and matlab liked it better. This has
% convinced me that matlab is quite temperamental, or that i have short
% term memory loss.

for run = run:runs
     
     try
           tireData = readTireData(round, run, 'cornering', false);
     end
     tireData.FZ = tireData.FZ * (-1);
 
     %Filter warmup rounds
%      tireData = filterData(tireData, 'ET', '>', 235);
 
     maxLoad = 2000;
     upperMin = 1000;
     lowerMax = 800;
     FzCol = 11;
     tireData = filterData(tireData, 'FZ', '<', maxLoad);
%      fields = fieldnames(tireData);
%      is = tireData.FZ < lowerMax | tireData.FZ > upperMin;
%      for i = 1 : numel(fields)
%              field = fields{i};
%              tireData.(field) = tireData.(field)(is);
%      end
%     tireData = filterData(tireData, 'SA', '=', 0, 'eqTolerance', 0.05);
     NormalLoad = 650;
     tireData = filterData(tireData, 'FZ', '=', NormalLoad, 'eqTolerance', 50);
     tireData = filterData(tireData, 'IA', '=', 4, 'eqTolerance', 0.2);
     tireData = filterData(tireData, 'P', '=', 82.7371, 'eqTolerance', 3.44738);
 
     data.Fz = tireData.FZ;
     data.SR = tireData.SL;
     %deg -> rad
     data.SA = deg2rad(tireData.SA);
     %deg -> rad
     data.IA = deg2rad(tireData.IA);
     data.Phit = zeros(size(tireData.FY, 1), 1);
     %kph -> m/s
     data.Vx = tireData.V / 3.6;
     %kPa -> Pa
     data.P = tireData.P * 1000;
     data.Fy = tireData.FY;
     data.Fx = tireData.FX;
     data.W = tireData.N * 2 * pi / 60;
 
     %save('18R25Brun39_SL_F_SA_v2.mat', 'data');
     
     %%plotting
     figure(run);
     Fx = tireData.FX * 0.6; %scale long. forces by 0.6 since testing surface 3Mite is grippier than road surface
     %%data for long. coeff. of friction
     coeff = Fx./tireData.FZ;
     
     %%data for camber
     camberData = tireData.IA; %which is provided in degrees
     
     %%data for slip ratio
     fxData = tireData.SL;
     
     %%what we are plotting
     scatter(fxData, coeff);
     grid on
 
     %%plotting titles (CHANGE DEPENDING ON DATA \/ \/)
     xlabel('Slip Ratio [-]')
     ylabel('X Coefficient of Friciton [-]')
     title("CoeffX vs SR - round " + round + " run " + run)
     
     try %try cause if theres no data, the below text labels break
             text(0, max(coeff), "Max: " + max(coeff));
             text(0, min(coeff), "Min: " + min(coeff))
     end
      path = 'C:\Users\griff\Documents\PER_GGV_GriffinTireEdition\Vehicle-Dynamics-master\model_sim\tireGraphs';
      saveas(run, fullfile(path, "round"+round+"run"+run),'png');
 end

% Next step: go into MFGuiTool (in plugins), load the data
% Fit it and make sure to output parameters to a file
% The parameters are gonna give wild results outside the
% data range, you have to reload them and tune them manually
