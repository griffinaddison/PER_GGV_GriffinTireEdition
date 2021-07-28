function [ car ] = REV3_car()
R25B_180_60_10_7 = 'GAAAAAAAAIAAAAAAAAAAKHEMGGGGGGODAAAAADBEAAILIIHEBODNDMPDCKNOHBAMGEAKOHODCIDMCGBENIJJENODMGMAHKNLCAGOPBODCFAPDDODOAOOBGCEOMPMLCAEHDCMPFBEEENJKJLLJANDONKLGPKLMKNLMNMENHNDKBCPAFLLLPLAIJPLAOFMHNODHMCGCNPDBKBGKAAEKIFEABOLNOJNOFNDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANLDPOGMLLICHAEMDJGPLLBODFIFIJLODFLNJANAEGELLCPPLOMMLKOPLAAAAAAAAAFHOKLODPDKPHOAEAAAAAAAAAAAAAAAAONKMLOBENOAKJCPDBBDIEKPLLHPAFCODMHOCJHNLLDLNNEAMNFHGMACEAAAAAAAAMLFCLCNLAEAOGLLDDGMHINPLBEPBJFNLKBNLCAAMICLIBEAMOPKPOCBMIGDFFMOLOLFMFPPDOIMPEFPDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPD';
LC0_180_60_10_7  = 'GAAAAAAAAIAAAAAAAAAAKHEMGGGGGGODAAAAADBEAAILIIHECKEBILODGBJFEKAMEMPEFIODJEKEHCBEAMBGAMOLFBNBAIODCMJKILOLPLKBAJNLCFNHCACECBINAKPDPLJEKBBEFHEJCKLLCACKAFLLBMEEKPNLGGGHFCNDFFAFPAMDGCPHHAPLHAOGAFNLEKIOCDPDBGCBHKPDOKFLIMNLHAHOPKNLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKJDHOGMLGKPHHOLDPKMDFMODLMAHMIMLCDFPPFAEKIIKDFNDILNLBPNDAAAAAAAAIFKFKKODEFALEFAMAAAAAAAAAAAAAAAAPAEEFNAEALDEEJNDEFLPFIPLFNMKFDODKEPFILLLMACMCLPLIIDBFDBEAAAAAAAALBGBKMLLLPFHONLLJFMJCMPLJNJAGLODGANEDPBMIDKIMBBMLMMKIKBMLHBPCJODICLLKHBMPMCEMHPDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPD';
R25B_180_75_10_7 = 'GAAAAAAAAIAAAAAACPOMGKEMCOMPNGODFOANCDBEMIIJBKHEELCKKOPDGGGGGCAMOJNOPPODOGNIAHBEECMNCJODKFHNADPLGIPAHAMLKGEMABBECPJHCOBEAHGPEKPDBBNDBNBEAGELMCLLIAJIKPKLCLNHNKNLCDJDIPMDCHOKNKNDEMKNLOPLAGAIBDAMLCHMNNODJEFNOJPDEFJFLKOLGAEDMIPLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEIENBILDAAHJMJMDADINNBODPBNNDCPLJKHKMIAEBGCOILPDFGJDNCAMAAAAAAAAHNCIMKPDJFGPFHPDAAAAAAAAAAAAAAAAPGEHOIBEALDBMEPDLHHAKHPDBPBBEDODMJBBLINLGJDFIEODHNGMHDBEAAAAAAAAFIJHDIMDFHNBFENDNOFHMAAMNNKBAAPLBONIFDCMMECBGDDMACCCFBEMEGMPAEPLBPGHOJBEBOHMIFPDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAAAAAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPDAAAAAIPD';
fzs = 0:20:400;
fxs_LC0_180_60_10_7  = @(mu) mu*[0;58.45172;114.0114;166.679;216.4545;263.338;307.3293;348.4286;386.636;421.9512;454.3743;483.9054;510.5444;534.2914;555.1462;545.2155;491.0384;444.1269;401.7704;362.767;326.3108];
fxs_R25B_180_75_10_7 = @(fz) -.0035*fz^2 + 3.1854*fz;
sr_R25B_180_75_10_7 = [-6.6835e-13, 7.30777e-10, -2.7246e-7, 3.59717e-5, -5.399e-4, .08];

% Build up car structure
car.name = 'REV3';
car.t_mean = 46;
car.t_rear_delta = 0;
car.wb   = 60.2;
car.wdr = .5;
car.h   = 10;
car.w   = 405 + 150;
car.camber_static = [-1; -1];
car.toe_static = [0;0];
car.camber_roll_gain = [-.5;-1]; % [deg/deg] positive means camber loss in roll
car.camber_steer_gain = .05; % [deg/deg] this is a function of castor and kingpin
car.coeffs = R25B_180_75_10_7;
% car.coeffs = LC0_180_60_10_7;
% car.coeffs = R25B_180_60_10_7;
car.mu = .65;
car.tire = 2;
car.tire_peakfxfz = {@(fz) interpolate(fzs,fxs_LC0_180_60_10_7(car.mu),fz); @(fz) fxs_R25B_180_75_10_7(fz)*car.mu};
car.tire_SR = {@(fz) 0;@(fz) polyval(sr_R25B_180_75_10_7,fz)};
car.N_mag = .54; % LLTD percent front
car.roll_grad = 0.5; % deg/G
car.pressure = 11; % psi
car.I_drive = 4000;%lbm in^2
car.tire_r = 8.5;%in
car.effective_mass = car.w + car.I_drive/car.tire_r^2;%mass plus effective rotational mass
car.pdr = .05;%rear power distribution
car.comp_power_limit = 79999;%W
car.max_power = car.comp_power_limit/4.448/.0254;%lbin/sec
car.v_bus = 250;
car.power_limit = [car.pdr*car.max_power/2; (1-car.pdr)*car.max_power/2];
car.gear_ratio_front = 8.5;%gearbox ratio
car.gear_ratio_rear  = 8.5;
car.motor_params = @(T,w)[GVK142_050M6_sat(T(1)/car.gear_ratio_rear,w(1)*car.gear_ratio_rear);...
                          GVK142_025L6_sat(T(2)/car.gear_ratio_front,w(2)*car.gear_ratio_front)];
car.drivetrain_eff = .9; %efficiency of motor and gearbox (speed dependent)
car.max_w = 1650;% rad/s peak motor speed
car.powertrain_loss = @(Irms) ...
    (3*((0.00927932*Irms^2+0.942941*Irms+4.46138)/pi*car.v_bus/250*2/3 + 0.011*Irms^2))/4.448/.0254;%[power lost to cables (10ft (5ft x2) of 8awg cable), fuse (fwh-100a), connectors]     
% p_bus    [power at DC input]    p_motor/eff_motor + p_inverter
%p_transmit = 0.01*((p_motor/eff_motor + 3*((.0172765*Irms_motor^2+1.3584*Irms_motor+214.5)/pi * (v_bus/300) + 0.0161*Irms_motor^2))/v_bus)^2; 
car.steer_linear_m = .01;
car.camber_compliance = 0.1;
% calculations
car.t   = [car.t_mean - car.t_rear_delta; car.t_mean + car.t_rear_delta];
car.a = (1-car.wdr)*car.wb; % this is longitudinal distance from rear axle to CoG
car.b = (car.wdr)*car.wb; % this is longitudinal distance from CoG to front axle

car.M = car.w / 32.2;
car.Fz_static = -0.5 * car.w .* [car.wdr; car.wdr; 1 - car.wdr; 1 - car.wdr];

% Wheel and Tire are springs in series
car.wheel_rate = [145; 140]; % [lbf/in]
car.tire_rate = 225; % [lbf/in]
car.ride_rate = (car.tire_rate .* car.wheel_rate) ./ (car.tire_rate + car.wheel_rate);

% Aero
% Some of these are driven by track calculations above


% car.aero.devices = {'front', 'rear'};
% car.aero.front.C_l = 2.5;
% car.aero.front.C_d = 1;
% car.aero.front.span = car.t(2) + 6; %[in]
car.aero.front.chord = 22; %[in]
% car.aero.front.area = car.aero.front.span * car.aero.front.chord;
% car.aero.front.Cp_x = 62;
% car.aero.front.Cp_z = -5;
% 
% car.aero.rear.C_l = 2.5;
% car.aero.rear.C_d = 1;
% car.aero.rear.span = car.t(1) - 7; %[in]
car.aero.rear.chord = 26; %[in]
% car.aero.rear.area = car.aero.rear.span * car.aero.rear.chord;
% car.aero.rear.Cp_x = -25;
% car.aero.rear.Cp_z = -36;
car.aero.devices = {'total'};

car.aero.total.C_l = 3;
car.aero_C_l = 3;
car.aero.total.C_d = 1.3;
car.aero_C_d = 1.3;
car.aero.total.area = (car.t(1) - 6)*car.aero.rear.chord + ...   % rear
                      (car.t(2) + 6)*car.aero.front.chord;        % front
car.aero.total.Cp_x = 6;
car.aero.total.Cp_z = -16;

%% Suspension Parameters for SLASIM
m2mm = 1000;
mm2in = 1/25.4;
m2in = m2mm * mm2in;
car.susp.rearleft = [   0.2032000000, -0.2159000000, -0.2559106802; %1ufibj
                        0.0000000000, -0.4977541898, -0.3192149306; %2uobj
                        -0.0762000000, -0.2159000000, -0.2559106802; %3uribj
                        0.2032000000, -0.2159000000, -0.1140471074; %4lfibj
                        0.0444500000, -0.5415647311, -0.1294506279; %5lobj
                        -0.0508000000, -0.2159000000, -0.1140471074; %6lribj
                        0.0000000000, -0.5804320255, -0.2158671174; %7wc
                        0.0000000000, -0.5842000000, 0.0000000000; %8wcp
                        -0.1016000000, -0.2159000000, -0.1140471074; %9tri
                        -0.0444500000, -0.5415647311, -0.1294506279; %10tro
                        0.0144234224, -0.4535307895, -0.3242512268; %11pro
                        0.0977469117, -0.1980541129, -0.3740670246; %12bc pivot
                        0.0856728640, -0.1941161731, -0.3740670246; %13bc axis
                        0.1114282243, -0.1561060823, -0.4364514551; %14bc shock
                        0.0904433591, -0.2204474063, -0.3728687164; %15bc arb
                        0.0916162588, -0.2168511996, -0.4236073135; %16bc pushrod
                        0.0919264916, -0.2159000000, -0.2788498758; %17arb link pt
                        0.1300264916, -0.2159000000, -0.2788498758; %18arb pivot
                        0.1300264916, 0.00000000000, -0.2788498758; %19arb axis
                        0.1561100289, -0.0191079918, -0.3345333038; %20shock inboard
                        0.0000000000, -0.6058320255, -0.2163104760  %21wheel spindle ref 
                    ].*m2in;

car.susp.frontleft = [ 1.6306800000, -0.2603500000, -0.2650978360; %ufibj
              1.5168995728, -0.5024251233, -0.3192964620;
              1.3671550000, -0.2603500000, -0.2650978360;
              1.5608225392, -0.2286000000, -0.1071232095; %lfibj
              1.5343994927, -0.5375920634, -0.1198548338;
              1.3919200000, -0.2286000000, -0.1107854534;
              1.5290800000, -0.5804320255, -0.2158671174; %wc
              1.5290800000, -0.5842000000, 0.0000000000; %wcp 
              1.5925650785, -0.2286000000, -0.1064349492; %tri
              1.5705558103, -0.5432794707, -0.1326560424; %tro
              1.5047154612, -0.4523298227, -0.3243485590; %pro
              1.4112164801, -0.1996141992, -0.4943806619; %bc pivot
              1.3993055457, -0.2040209716, -0.4943806619; %bc axis
              1.4135490116, -0.2059187295, -0.5540319496; %bc shock
              1.4240910883, -0.2344125961, -0.4983570319; %bc arb
              1.4249941535, -0.2368534642, -0.5372328410; %bc pushrod
              1.4477382064, -0.2730500000, -0.0836654706; %arb link pt
              1.4097000000, -0.2730500000, -0.0814964032; %arb pivot
              1.4097000000, 0.00000000000, -0.0814964032; %arb axis
              1.3526904981, -0.0414260580, -0.5737968780; %shock inboard
              1.5290800000, -0.6058281569, -0.2163104085  %wheel spindle ref 
              ].*m2in;
car.susp.rearright = car.susp.rearleft;
car.susp.rearright(:,2) = car.susp.rearright(:,2) .* -1;
car.susp.frontright = car.susp.frontleft;
car.susp.frontright(:,2) = car.susp.frontright(:,2) .* -1;
          
car.susp.ride_travel = 2;% total
car.susp.steer_travel = .69;%one sided
end

