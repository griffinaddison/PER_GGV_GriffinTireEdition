%% Grid Search Optimization of Rev 3 Ax
%  Vehicle Model: Calculates Accel Time 
clear
%close all
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
fxs_LC0_180_60_10_7  = @(mu) mu*[0;58.45172;114.0114;166.679;216.4545;263.338;307.3293;348.4286;386.636;421.9512;454.3743;483.9054;510.5444;534.2914;555.1462;545.2155;491.0384;444.1269;401.7704;362.767;326.3108];
fxs_R25B_180_75_10_7 = @(fz) -.0035*fz^2 + 3.1854*fz;

%% Construct Cars
REV3 = REV3_car();

sp = {...
      %'pdr',                {.05:.25:.8};...
      %'tire',               {[1,2]};...
      %'h',                 {9:.5:11};...
      %'mu'                  {.65};...
      'gear_ratio_rear',      {7:.25:8.5};...
      'gear_ratio_front',      {7:.25:8.5}...
      %'aero_C_d',         {1.0:.1:1.3};...
      %'aero_C_l',              {2:.25:3}...
      };
nparams = size(sp,1); %number of parameters
s = zeros(nparams,2);
ncars = 1;
for c = 1:nparams
    s(c,:) = size(sp{c,2}{1});% calculates size of each swept parameter 
    ncars = ncars*s(c,1)*s(c,2);
end
disp([num2str(ncars) ' cars to run.'])
disp('--- Building parameters ---');
P = zeros(nparams,ncars);
for ii = 1:nparams
    aa = repmat(sp{ii,2}{1},ncars/prod(s(1:ii,2)),1);
    bb = reshape(aa,1,[]);
    P(ii,:) = repmat(bb,1,ncars/prod(s(ii:end,2)));
end
%% Construct Environment
env.mu = .6;
env.rho_air = 0.0765/12^3; % lbm/in3
env.g = 386.4;%in/s/s
%% 
disp('--- Building cars ---');
%cars = repmat(REV3, [ncars, 1]);
ax = zeros(ncars,2);
ii = 1;
tic;
parfor ii = 1:ncars
        car = REV3;
        for jj = 1:nparams
            car.(sp{jj,1}) = P(jj,ii);
        %eval(['car.' sp{jj,1} ' = P(jj,ii);']);
        end
        %update dependent variables 
        
        car.a = (1-car.wdr)*car.wb;
        car.b = (car.wdr)*car.wb;
        car.M = car.w / 32.2;
        car.Fz_static = -0.5 * car.w .* [car.wdr; car.wdr; 1 - car.wdr; 1 - car.wdr];
        car.effective_mass = car.w + car.I_drive/car.tire_r^2 + (car.tire-1)*10;
        car.power_limit = [car.pdr*car.max_power/2; (1-car.pdr)*car.max_power/2];
        car.tire_peakfxfz = {@(fz) interpolate(fzs,fxs_LC0_180_60_10_7(car.mu),fz); @(fz) fxs_R25B_180_75_10_7(fz)*car.mu};
        car.motor_params = @(T,w)[GVK142_050M6_sat(T(1)/car.gear_ratio_rear,w(1)*car.gear_ratio_rear);...
                          GVK142_025L6_sat(T(2)/car.gear_ratio_front,w(2)*car.gear_ratio_front)];
        car.t   = [car.t_mean - car.t_rear_delta; car.t_mean + car.t_rear_delta];
        ax(ii,:) = long_accel(car,env,0);
end
T = toc;
disp(['All cars ran in: ' num2str(T) ' seconds.']);




%% Run accel sim for this vehicle

%parpool('local')
ts = zeros(ncars,1);
% parfor jj = 1:(ncars)
%     %tic;
%     ax(jj,:) = long_accel(cars(jj),env,0);
%     %ts(jj) = toc;
%     
%     %meantime = mean(ts(1:jj,1));
%     %carsleft = ncars - jj;
%     %timeleft = carsleft * .5;
%     %disp(['Mean time (set): ' num2str(.5) ' - Cars Remaining: ' num2str(carsleft) ' - Time remaining(very rough): ' num2str(timeleft)]);
% end
% 

%% Plotting
%
figure;
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
[~,I] = sort(ax(:,2)); %min times


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
        grid on
    end
end
%% Sensitivity Plots
%close all;

figure;
ax_time=reshape(ax(:,2),s(:,2)');
surf(aa,bb,ax_time)
xlabel('Rear')
ylabel('Front')

