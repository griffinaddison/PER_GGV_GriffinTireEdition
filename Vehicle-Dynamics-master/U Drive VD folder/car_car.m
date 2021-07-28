function [ car ] = car_car()
R25B_205_70_13_6 = 'GAAAAAAAAIAAAAAAAAAAKHEMAAAAAIODAAAAADBEAAILIIHEOIHELKPDBJGNICAMMIONPFODIPFCHCBEOJDCEBODPAHJAJPDPOBPGCOLPJHPIBOLKGBLAECECLBOOHPDJNAPGIAEKCKPDCLLHOLLHAMLCPBGOCOLKJEPLCNDGEMDDPNDENLFAPODLLNOIHODMNLEDDPDBFBHKJPDFBAEAMNDPPKEFBPLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFILBCDMLDKHGDBLDAAJEEBNDBHADPMNDFBOCIEAENNHKMMNLBNMLEEPLAAAAAAAANCEHIOODOJFIDKAEAAAAAAAAAAAAAAAALKFEGACEMIJHJNOLJEKOCIPLHPGBGBODIJENPMKLMLDEFNOLNENJMOPLAAAAAAAAIHKHBANDBKFPPOMLBIMGHCAMEKACDPODHKAGOOCMEMKAEFDEKAAHPHDMEIECNOOLELBLMNAMGMBLBJPDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPD';

fzs = 0:20:400;
fxs_LC0_180_60_10_7 = [0;58.45172;114.0114;166.679;216.4545;263.338;307.3293;348.4286;386.636;421.9512;454.3743;483.9054;510.5444;534.2914;555.1462;545.2155;491.0384;444.1269;401.7704;362.767;326.3108];


% Build up car structure
car.t   = [45.5; 47.0];
car.wb  = 60.2;

car.wdr = .50;
car.h   = 10;

car.w   = 400 + 150;

car.camber_static = [-1; -1];
car.toe_static = [0 0];
car.camber_ride_gain = [.25; .25]; % [deg/deg] positive means camber loss in roll
car.camber_steer_gain = .05; % [deg/deg] this is a function of castor and kingpin
car.coeffs = R25B_205_70_13_6;
car.N_mag = .50; % LLTD percent front
car.roll_grad = .8; % deg/G
car.pressure = 12; % psi
car.mu = .6;

% calculations
car.a = (1-car.wdr)*car.wb; % this is longitudinal distance from rear axle to CoG

car.b = (car.wdr)*car.wb; % this is longitudinal distance from CoG to front axle


car.M = car.w/32.2;
car.Fz_static = -0.5 * car.w .* [car.wdr; car.wdr; 1 - car.wdr; 1 - car.wdr];

% Wheel and Tire are springs in series
car.wheel_rate = [148.515; 142.857]; % [lbf/in]
car.tire_rate = 253.1; % [lbf/in]
car.ride_rate = (car.tire_rate .* car.wheel_rate) ./ (car.tire_rate + car.wheel_rate);

% Aero
% Some of these are driven by track calculations above
car.aero.devices = {'total'};

car.aero.total.C_l = 2.5;
car.aero.total.C_d = 1.0;
car.aero.total.area = (car.t(1) - 6)*28 + ...   % rear
                      (car.t(2) + 6)*22;        % front

car.aero.total.Cp_x = 4;

car.aero.total.Cp_z = -16;

% car.aero.devices = {'front', 'rear'};
% car.aero.front.C_l = 2.5;
% car.aero.front.C_d = 1;
car.aero.front.span = car.t(2) + 6; %[in]
car.aero.front.chord = 22; %[in]
car.aero.front.area = car.aero.front.span * car.aero.front.chord;

% car.aero.front.Cp_x = 62;
% car.aero.front.Cp_z = -5;
% 
% car.aero.rear.C_l = 2.5;
% car.aero.rear.C_d = 1;
car.aero.rear.span = car.t(1) - 7; %[in]
car.aero.rear.chord = 28; %[in]
car.aero.rear.area = car.aero.rear.span * car.aero.rear.chord;

% car.aero.rear.Cp_x = -25;
% car.aero.rear.Cp_z = -36;

%Additional Longitudinal Sweep Params

car.tire_peakfxfz = @(fz) interp1(fzs,fxs_LC0_180_60_10_7.*car.mu,fz,'linear','extrap');


car.I_drive = 4000;%lbm in^2
car.tire_r = 8.5;%in

car.effective_mass = car.w + car.I_drive/car.tire_r^2;
car.pdr = .625;
car.max_power = 79999/4.448/.0254;%lbin/sec
car.motor_power = [car.pdr*car.max_power/2; (1-car.pdr)*car.max_power/2];


end

