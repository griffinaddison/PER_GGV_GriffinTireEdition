function sla = sla_car_fun(rearleft, rearright, frontleft, frontright, desired_ride_travel, desired_steering_travel, plotting)

%% Define some unit conversion constants
m2mm = 1000;
mm2in = 1/25.4;
m2in = m2mm * mm2in;


%% Constant transform used to make plotting in MATLAB more natural
%  upside down z axis wasn't playing nicely with plot3 / view
R = [1 0 0;  0 -1 0;  0 0 -1];

n_step_ride = 20;
n_step_steering = 20;
% desired_ride_travel = 2;
% desired_steering_travel = 0.69;
n_points = 10000;

name = ['sla-t' num2str(desired_ride_travel) '-s' num2str(n_step_ride) '-n' num2str(n_points) '-s' num2str(n_step_steering)];


%% Define static ride-height points 
% !!NOTE MACRO coord-to-clipboard.swp ONLY WORKS ON 3D SKETCHES WITH ORIGIN
% AT CAR ORIGIN!!
% rearleft = [ 0.2032000000, -0.2159000000, -0.2559106802; %1ufibj
%              0.0000000000, -0.4977541898, -0.3192149306; %2uobj
%              -0.0762000000, -0.2159000000, -0.2559106802; %3uribj
%              0.2032000000, -0.2159000000, -0.1140471074; %4lfibj
%              0.0444500000, -0.5415647311, -0.1294506279; %5lobj
%              -0.0508000000, -0.2159000000, -0.1140471074; %6lribj
%              0.0000000000, -0.5804320255, -0.2158671174; %7wc
%              0.0000000000, -0.5842000000, 0.0000000000; %8wcp
%              -0.1016000000, -0.2159000000, -0.1140471074; %9tri
%              -0.0444500000, -0.5415647311, -0.1294506279; %10tro
%              0.0144234224, -0.4535307895, -0.3242512268; %11pro
%              0.0977469117, -0.1980541129, -0.3740670246; %12bc pivot
%              0.0856728640, -0.1941161731, -0.3740670246; %13bc axis
%              0.1114282243, -0.1561060823, -0.4364514551; %14bc shock
%              0.0904433591, -0.2204474063, -0.3728687164; %15bc arb
%              0.0916162588, -0.2168511996, -0.4236073135; %16bc pushrod
%              0.0919264916, -0.2159000000, -0.2788498758; %17arb link pt
%              0.1300264916, -0.2159000000, -0.2788498758; %18arb pivot
%              0.1300264916, 0.00000000000, -0.2788498758; %19arb axis
%              0.1561100289, -0.0191079918, -0.3345333038; %20shock inboard
%              0.0000000000, -0.6058320255, -0.2163104760  %21wheel spindle ref 
%              ].*m2in;
% 
% frontleft = [ 1.6306800000, -0.2603500000, -0.2650978360; %ufibj
%               1.5168995728, -0.5024251233, -0.3192964620;
%               1.3671550000, -0.2603500000, -0.2650978360;
%               1.5608225392, -0.2286000000, -0.1071232095; %lfibj
%               1.5343994927, -0.5375920634, -0.1198548338;
%               1.3919200000, -0.2286000000, -0.1107854534;
%               1.5290800000, -0.5804320255, -0.2158671174; %wc
%               1.5290800000, -0.5842000000, 0.0000000000; %wcp 
%               1.5925650785, -0.2286000000, -0.1064349492; %tri
%               1.5705558103, -0.5432794707, -0.1326560424; %tro
%               1.5047154612, -0.4523298227, -0.3243485590; %pro
%               1.4112164801, -0.1996141992, -0.4943806619; %bc pivot
%               1.3993055457, -0.2040209716, -0.4943806619; %bc axis
%               1.4135490116, -0.2059187295, -0.5540319496; %bc shock
%               1.4240910883, -0.2344125961, -0.4983570319; %bc arb
%               1.4249941535, -0.2368534642, -0.5372328410; %bc pushrod
%               1.4477382064, -0.2730500000, -0.0836654706; %arb link pt
%               1.4097000000, -0.2730500000, -0.0814964032; %arb pivot
%               1.4097000000, 0.00000000000, -0.0814964032; %arb axis
%               1.3526904981, -0.0414260580, -0.5737968780; %shock inboard
%               1.5290800000, -0.6058281569, -0.2163104085  %wheel spindle ref 
%               ].*m2in;
%               
% % can flip the y-coord to get the other half of the car
% rearright = rearleft;
% rearright(:,2) = rearright(:,2) .* -1;
% frontright = frontleft;
% frontright(:,2) = frontright(:,2) .* -1;
% 

%% Set up plot of full car
carbox = [-12 85 -30 30 -4 44];
carpos.R = eye(3)*R;
carpos.t = zeros(3,1);


%% Rig suspensions and generate lookup tables for travel
% Rears have no steer effect.  To evaluate 4-wheel steer need to change
% this
rrr = sla_kinematics(rearright, -1, desired_ride_travel, n_step_ride, n_points, carpos);
rrj = sla_kinematics(rearright, 1, desired_ride_travel, n_step_ride, n_points, carpos);
rr_lut = cat(3, rrr(:,:,end:-1:2), rrj);

rl_lut = rr_lut;
rl_lut(:,2,:) = -rl_lut(:,2,:);

% Front wheels are steered at the TRI
step_steering = desired_steering_travel / (n_step_steering - 1);
fr_lut = zeros([size(rr_lut) 2*n_step_steering-1]);
fl_lut = zeros([size(rr_lut) 2*n_step_steering-1]);

frr = sla_kinematics(frontright, -1, desired_ride_travel, n_step_ride, n_points, carpos);
frj = sla_kinematics(frontright, 1, desired_ride_travel, n_step_ride, n_points, carpos);
fr_lut(:,:,:,n_step_steering) = cat(3, frr(:,:,end:-1:2), frj);
frontright_steered = frontright;

flr = sla_kinematics(frontleft, -1, desired_ride_travel, n_step_ride, n_points, carpos);
flj = sla_kinematics(frontleft, 1, desired_ride_travel, n_step_ride, n_points, carpos);
fl_lut(:,:,:,n_step_steering) = cat(3, flr(:,:,end:-1:2), flj);
frontleft_steered = frontleft;


for ii = 2:n_step_steering
    frontright_steered = sla_steer(frontright_steered, step_steering, n_points);
    frontleft_steered = sla_steer(frontleft_steered, step_steering, n_points);
    
    frr = sla_kinematics(frontright_steered, -1, desired_ride_travel, n_step_ride, n_points, carpos);
    frj = sla_kinematics(frontright_steered, 1, desired_ride_travel, n_step_ride, n_points, carpos);
    fr_lut(:,:,:,ii + n_step_steering - 1) = cat(3, frr(:,:,end:-1:2), frj);
    
    flr = sla_kinematics(frontleft_steered, -1, desired_ride_travel, n_step_ride, n_points, carpos);
    flj = sla_kinematics(frontleft_steered, 1, desired_ride_travel, n_step_ride, n_points, carpos);
    fl_lut(:,:,:,ii + n_step_steering - 1) = cat(3, flr(:,:,end:-1:2), flj);
end

frontright_steered = frontright;
frontleft_steered = frontleft;
for ii = 2:n_step_steering
    frontright_steered = sla_steer(frontright_steered, -step_steering, n_points);
    frontleft_steered = sla_steer(frontleft_steered, -step_steering, n_points);
    
    frr = sla_kinematics(frontright_steered, -1, desired_ride_travel, n_step_ride, n_points, carpos);
    frj = sla_kinematics(frontright_steered, 1, desired_ride_travel, n_step_ride, n_points, carpos);
    fr_lut(:,:,:,-ii+1+n_step_steering) = cat(3, frr(:,:,end:-1:2), frj);
    
    flr = sla_kinematics(frontleft_steered, -1, desired_ride_travel, n_step_ride, n_points, carpos);
    flj = sla_kinematics(frontleft_steered, 1, desired_ride_travel, n_step_ride, n_points, carpos);
    fl_lut(:,:,:,-ii+1+n_step_steering) = cat(3, flr(:,:,end:-1:2), flj);
end

% fl_lut = fr_lut;
% fl_lut(:,2,:,:) = -fl_lut(:,2,:,end:-1:1);


%% Calculate geometric parameters for the rig
rr_geo = sla_geometry(rr_lut);
rl_geo = sla_geometry(rl_lut);

fr_geo = sla_geometry(fr_lut);
fl_geo = sla_geometry(fl_lut);


%% Save outputs for future use
sla.rearright = rearright;
sla.rearleft = rearleft;
sla.frontright = frontright;
sla.frontleft = frontleft;
sla.rr = rr_lut;
sla.rl = rl_lut;
sla.fr = fr_lut;
sla.fl = fl_lut;
sla.rr_geo = rr_geo;
sla.rl_geo = rl_geo;
sla.fr_geo = fr_geo;
sla.fl_geo = fl_geo;
sla.carpos = carpos;
sla.carbox = carbox;
sla.n_step_ride = n_step_ride;
sla.n_step_steering = n_step_steering;
sla.n_points = n_points;
sla.desired_ride_travel = desired_ride_travel;
sla.desired_steering_travel = desired_steering_travel;

% clearvars -except sla name n_step_ride n_step_steering
% save([name '.mat']);


%% Actuate suspension through ride range

% plotting = true;
try
if (plotting)
    figure(1); clf; hold on;
    hs.o = PER_plot_origin(sla.carbox, sla.carpos);

    hs.rr_o = PER_plot_SLA(sla.rearright,   sla.carpos);
    hs.rl_o = PER_plot_SLA(sla.rearleft,    sla.carpos);
    hs.fr_o = PER_plot_SLA(sla.frontright,  sla.carpos);
    hs.fl_o = PER_plot_SLA(sla.frontleft,   sla.carpos);

    hs.rr = PER_plot_SLA(sla.rearright,     sla.carpos, 0);
    hs.rl = PER_plot_SLA(sla.rearleft,      sla.carpos, 0);
    hs.fr = PER_plot_SLA(sla.frontright,    sla.carpos, 0);
    hs.fl = PER_plot_SLA(sla.frontleft,     sla.carpos, 0);

    drawnow;
    
    while(plotting)
        for ii = [(2*sla.n_step_ride - 1):-1:2 1:(2*sla.n_step_ride - 1)-1]
        %     disp(ii);
            PER_plot_SLA(sla.rr(:,:,ii), sla.carpos, 0, hs.rr);
            PER_plot_SLA(sla.rl(:,:,ii), sla.carpos, 0, hs.rl);
            PER_plot_SLA(sla.fr(:,:,ii,n_step_steering), sla.carpos, 0, hs.fr);
            PER_plot_SLA(sla.fl(:,:,ii,n_step_steering), sla.carpos, 0, hs.fl);

            drawnow;
        end
    end
end
catch
end


%% Actuate suspension through steered range

% plotting = true;
try
if (plotting)
    figure(1); clf; hold on;
    hs.o = PER_plot_origin(sla.carbox, sla.carpos);
    view(-90,90);

    hs.rr_o = PER_plot_SLA(sla.rearright,   sla.carpos);
    hs.rl_o = PER_plot_SLA(sla.rearleft,    sla.carpos);
    hs.fr_o = PER_plot_SLA(sla.frontright,  sla.carpos);
    hs.fl_o = PER_plot_SLA(sla.frontleft,   sla.carpos);

    hs.rr = PER_plot_SLA(sla.rearright,     sla.carpos, 0);
    hs.rl = PER_plot_SLA(sla.rearleft,      sla.carpos, 0);
    hs.fr = PER_plot_SLA(sla.frontright,    sla.carpos, 0);
    hs.fl = PER_plot_SLA(sla.frontleft,     sla.carpos, 0);

    drawnow;
    
    while(plotting)
        for ii = [(2*sla.n_step_steering - 1):-1:2 1:(2*sla.n_step_steering - 1)-1]
%             disp(ii);
            PER_plot_SLA(sla.rr(:,:,n_step_ride), sla.carpos, 0, hs.rr);
            PER_plot_SLA(sla.rl(:,:,n_step_ride), sla.carpos, 0, hs.rl);
            PER_plot_SLA(sla.fr(:,:,n_step_ride,ii), sla.carpos, 0, hs.fr);
            PER_plot_SLA(sla.fl(:,:,n_step_ride,ii), sla.carpos, 0, hs.fl);

            drawnow;
        end
    end
end
catch
end

end