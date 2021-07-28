%% Grid Search Optimization of Rev 3 Ax
%  Vehicle Model: Calculates Accel Time 
clear
close all
clc;
plot_generic = 0; %plot generic graphs (useless in n-D grid search)
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

sp = {'wdr',                {.4:.05:.6};...
      'pdr',                {.25:.25:.75};...
      'gear_ratio(1)',      {8:.5:12};...
      'gear_ratio(2)',      {8:.5:12};...
      'aero.total.C_d',         {.8:.1:1.3};...
      'aero.total.C_l',              {2:.2:3}};
nparams = size(sp,1); %number of parameters
s = zeros(nparams,2);
ncars = 1;
for c = 1:nparams
    s(c,:) = size(sp{c,2}{1});% calculates size of each swept parameter 
    ncars = ncars*s(c,1)*s(c,2);
end
disp('--- Building parameters ---');
P = zeros(nparams,ncars);
for ii = 1:nparams
    aa = repmat(sp{ii,2}{1},ncars/prod(s(1:ii,2)),1);
    bb = reshape(aa,1,[]);
    P(ii,:) = repmat(bb,1,ncars/prod(s(ii:end,2)));
end


disp('--- Building cars ---');

cars = repmat(REV3, [ncars, 1]);

ii = 1;
for jj = 1:size(s,1)
    for kk = 1:s(jj,2)
        eval(['cars(ii).' sp{jj,1} ' = sp{jj,2}{1}(kk);']);
        %update dependent variables 
        % find a way to FCKN GET RID OF THIS SHT!
        cars(ii).a = (1-cars(ii).wdr)*cars(ii).wb;
        cars(ii).b = (cars(ii).wdr)*cars(ii).wb;
        cars(ii).M = cars(ii).w / 32.2;
        cars(ii).Fz_static = -0.5 * cars(ii).w .* [cars(ii).wdr; cars(ii).wdr; 1 - cars(ii).wdr; 1 - cars(ii).wdr];
        cars(ii).effective_mass = cars(ii).w + cars(ii).I_drive/cars(ii).tire_r^2;
        cars(ii).power_limit = [cars(ii).pdr*cars(ii).max_power/2; (1-cars(ii).pdr)*cars(ii).max_power/2];
        cars(ii).motor_params = @(w)[GVK142_050L6(w*cars(ii).gear_ratio(1));...
                                     GVK142_025L6(w*cars(ii).gear_ratio(2))];
        cars(ii).t   = [cars(ii).t_mean - cars(ii).t_rear_delta; cars(ii).t_mean + cars(ii).t_rear_delta];
        
        ii = ii + 1;
    end
end
disp('All cars built');

%% Construct Environment
env.mu = .6;
env.rho_air = 0.0765/12^3; % lbm/in3
env.g = 386.4;%in/s/s

%% Run accel sim for this vehicle
ax = zeros(ncars,2);
%parpool('local')
ts = zeros(ncars,1);
parfor jj = 1:(ncars)
    %tic;
    ax(jj,:) = long_accel(cars(jj),env,0);
    %ts(jj) = toc;
    
    %meantime = mean(ts(1:jj,1));
    %carsleft = ncars - jj;
    %timeleft = carsleft * .5;
    %disp(['Mean time (set): ' num2str(.5) ' - Cars Remaining: ' num2str(carsleft) ' - Time remaining(very rough): ' num2str(timeleft)]);
end


%% Plotting
%
if plot_generic
a = size(sp,1);
inc = 0;
for ii = 1:a
    subplot(a,2,2*ii-1)
    h(ii,1) = plot(cell2mat(sp{ii,2}),ax((s(ii,1):s(ii,2))+inc,1)');
    xlabel(sp{ii,1})
    ylabel('Ax')
    subplot(a,2,2*ii)
    h(ii,2) = plot(cell2mat(sp{ii,2}),ax((s(ii,1):s(ii,2))+inc,2)');
    xlabel(sp{ii,1})
    ylabel('Accel time')
    inc = s(ii,2)+inc;
end
end
figure();
nmax = 3;
[~,I] = sort(ax(:,2));


for ii = 1:nmax 
    pos = I(ii);
    disp([ 'Min ' num2str(ii) ': ' num2str(ax(pos,2)) ' sec'])
    for jj = 1:nparams
        subplot(nmax,nparams,nparams*(ii-1)+jj)
        c = 1:nparams;
        c(jj) = [];
        [~,ind1] = ismember(P(c,pos)',P(c,:)','rows');
        q = prod(s(jj:end,2))/s(jj,2);
        ind = ((1:s(jj,2))-1)*q+ind1;
        plot(cell2mat(sp{jj,2}),ax(ind,2));
        hold on
        plot(P(jj,pos),ax(pos,2),'r.')
        title(sp{jj,1})
    end
end
%% Sensitivity Plots
%close all;


