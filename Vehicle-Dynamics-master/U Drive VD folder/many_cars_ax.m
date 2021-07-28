%% Vehicle Model. Calculates Accel Time 
clearvars 
clc;
% car is in in. lb. sec. units. mass in lbm. power in lbin/sec
% tire model will be evaluated with correct converted units and will return
% lbf.
% use SAE coordinate system.  X forward, Y right, Z down
% if there are pairs, they correspond to [rear, front]
% if there are quads, they correspond to [rear left, rear right, front left, front right]

% Tire Models
% These were fit by Dan Shanks in 2016.  They are not very good.
fzs = 0:20:400;
fxs_LC0_180_60_10_7 = [0;58.45172;114.0114;166.679;216.4545;263.338;307.3293;348.4286;386.636;421.9512;454.3743;483.9054;510.5444;534.2914;555.1462;545.2155;491.0384;444.1269;401.7704;362.767;326.3108];


%% Construct Cars
REV3 = REV3_car();

sp = {...%'wb',                    {60};...
      %'pdr',                   {.1:.05:1};...
      %'h',                     {9:.25:12};...
      %'w',                     {[365:10:445] + 150};...
      'gear_ratio.rear',        {7:.25:11};...
      'gear_ratio.front',        {9:.25:13}};

s = zeros(size(sp,1),2);
for ii = 1:size(sp,1)
    s(ii,:) = size(sp{ii,2}{1});
end

disp('--- Building cars ---');
numcars = sum(s(:,2));
cars = repmat(REV3, [numcars, 1]);
ii = 1;
for jj = 1:size(s,1)
    for kk = 1:s(jj,2)
        eval(['cars(ii).' sp{jj,1} ' = sp{jj,2}{1}(kk);']);
        %update dependent variables
        cars(ii).a = (1-cars(ii).wdr)*cars(ii).wb;
        cars(ii).b = (cars(ii).wdr)*cars(ii).wb;
        cars(ii).M = cars(ii).w / 32.2;
        cars(ii).Fz_static = -0.5 * cars(ii).w .* [cars(ii).wdr; cars(ii).wdr; 1 - cars(ii).wdr; 1 - cars(ii).wdr];
        cars(ii).effective_mass = cars(ii).w + cars(ii).I_drive/cars(ii).tire_r^2;
        cars(ii).power_limit = [cars(ii).pdr*cars(ii).max_power/2; (1-cars(ii).pdr)*cars(ii).max_power/2];
        cars(ii).motor_power = @(w)[GVK142_050L6(w*cars(ii).gear_ratio.rear); GVK142_025L6(w*cars(ii).gear_ratio.front)];
        ii = ii + 1;
    end
end
disp('All cars built');


%% Construct Environment
env.mu = .6;
env.rho_air = 0.0765/12^3; % lbm/in3
env.g = 32.2;%ft/s/s

%% Run accel sim for this vehicle
x = size(cars(:), 1);
ax = zeros(x,2);

ts = zeros(numcars,1);
for jj = 1:(x)
    tic;
    ax(jj,:) = long_accel(cars(jj),env,0);
    ts(jj) = toc;
    
    meantime = mean(ts(1:jj,1));
    carsleft = x - jj;
    timeleft = carsleft * meantime;
    disp(['Mean time: ' num2str(meantime) ' - Cars Remaining: ' num2str(carsleft) ' - Time remaining: ' num2str(timeleft)]);
end


%% Plotting
%
a = size(sp,1);
inc = 0;
for i = 1:a
    subplot(a,2,2*i-1)
    h(i,1) = plot(cell2mat(sp{i,2}),ax((s(i,1):s(i,2))+inc,1)');
    xlabel(sp{i,1})
    ylabel('Ax')
    subplot(a,2,2*i)
    h(i,2) = plot(cell2mat(sp{i,2}),ax((s(i,1):s(i,2))+inc,2)');
    xlabel(sp{i,1})
    ylabel('Accel time')
    inc = s(i,2)+inc;
end
%% Sensitivity Plots
%close all;


