function [outdata] = MMD_CN_Ay_vect(car, env, betas, deltas, V, h, debug)
% car is in in. lb. sec. units. mass in slugs.
% tire model will be evaluated with correct converted units and will return
% lbf.
% use SAE coordinate system.  X forward, Y right, Z down
% EXCEPT VELOCITY IN M/S
% if there are pairs, they correspond to [rear, front]
% if there are quads, they correspond to [rear left, rear right, front left, front right]

% Reference Frames:
% Body Frame        - Located at car CoM, x along car body
% Velocity Frame    - Located at car CoM, x along direction of travel
% Tire Frame i      - Located at tire i contact patch, oriented along
%                     center plane of tire
%
% Body frame related to velocity frame by rotz,beta
% Tire frame i related to body frame by delta_i


%% Preallocate space for results
nn = length(betas(:));
out = [];



%% Unit Conversion Factors
lbf2N = 4.44822162;
psi2Pa = 6894.75729;
in2m = .0254;
kgm3Tolbin3 = 3.61273e-5;
% Correct Velocity Units from m/s to in/s
V = V / in2m;



%% Resolve aero device parameters for the car
if isfield(car,'aero') && isfield(car.aero,'devices')
    n = length(car.aero.devices);
    car.aero.Cp_x = zeros(n,2);
    car.aero.Cp_z = zeros(n,2);
    car.aero.scale_L = zeros(n,1);
    car.aero.scale_D = zeros(n,1);
    
    for ii = 1:n
        car.aero.scale_L(ii) = car.aero.(car.aero.devices{ii}).C_l .* ...
                               car.aero.(car.aero.devices{ii}).area;
        car.aero.scale_D(ii) = car.aero.(car.aero.devices{ii}).C_d .* ...
                               car.aero.(car.aero.devices{ii}).area;
        
        car.aero.Cp_x(ii,:) = car.aero.scale_L(ii) .* ...
                             [car.aero.(car.aero.devices{ii}).Cp_x, 1];
        car.aero.Cp_z(ii,:) = car.aero.scale_D(ii) .* ...
                             [car.aero.(car.aero.devices{ii}).Cp_z, 1];
    end
    
    car.aero.Cp_x = sum(car.aero.Cp_x(:,1)) ./ sum(car.aero.Cp_x(:,2));
    if (isnan(car.aero.Cp_x)) 
        car.aero.Cp_x = 0;
    end
    
    car.aero.Cp_z = sum(car.aero.Cp_z(:,1)) ./ sum(car.aero.Cp_z(:,2));
    if (isnan(car.aero.Cp_z))
        car.aero.Cp_z = 0;
    end
    
    car.aero.scale_L = sum(car.aero.scale_L);
    car.aero.scale_D = sum(car.aero.scale_D);
else
    car.aero.Cp_x = 0;
    car.aero.Cp_z = 0;
    car.aero.scale_L = 0;
    car.aero.scale_D = 0;
end
% Resolve dynamic pressure.  Since this is a constant-velocity diagram,
% dynamic pressure is also constant
% Keeping dynamic pressure in SI units!  Should be Pa
env.Q = .5* env.rho_air * (V * in2m)^2;

% Aero forces and moments (doing these calculations in SI then
% converting back to LBF for now)
aero_drag = -((car.aero.scale_D * in2m^2) * env.Q) / lbf2N; % in -x direction
aero_lift = ((car.aero.scale_L * in2m^2) * env.Q) / lbf2N; % in +z direction
% keyboard;





%% Calculate Acceleration and Aero Gains
% Due to Ax - Can derive this by taking sum of moments about either front or rear
% tires in side view. half of the total load transfer is on each side.
deltaFzf_deltaAxb = .5 .* (car.h*car.w) / car.wb;

% Due to Ay - depends on LLTD and track widths
deltaFzf_deltaAyb = (car.h*car.w*car.N_mag) / (car.t(2));
deltaFzr_deltaAyb = (car.h*car.w*(1-car.N_mag)) / (car.t(1));

% Due to drag, very similar to Ax
deltaFzf_deltaDb  = .5 * (car.aero.Cp_z) ./ car.wb;
deltaFzf_deltaLb  = .5 * (car.a + car.aero.Cp_x) ./ car.wb;
deltaFzr_deltaLb  = .5 * (car.b - car.aero.Cp_x) ./ car.wb;


%% Vectorization Initializations
s = size(betas);

Axb_guess = zeros(s);
Ayb_guess = zeros(s);
CNb_guess = zeros(s);
iter = 0;
hist = [];

Ayv_guess = Ayb_guess .* cosd(betas) - Axb_guess .* sind(betas);
omega_guess = Ayv_guess ./ V;

% Get load transfer gains ready for vectorization
aero_drag_gain = repmat(permute([-deltaFzf_deltaDb,  -deltaFzf_deltaDb,   deltaFzf_deltaDb,  deltaFzf_deltaDb], [1,3,2]), s);
aero_lift_gain = repmat(permute([ deltaFzr_deltaLb,   deltaFzr_deltaLb,   deltaFzf_deltaLb,  deltaFzf_deltaLb], [1,3,2]), s);
Axb_guess_gain = repmat(permute([-deltaFzf_deltaAxb, -deltaFzf_deltaAxb,  deltaFzf_deltaAxb, deltaFzf_deltaAxb], [1,3,2]), s);
Ayb_guess_gain = repmat(permute([-deltaFzr_deltaAyb,  deltaFzr_deltaAyb, -deltaFzf_deltaAyb, deltaFzf_deltaAyb], [1,3,2]), s);


%% Resolve locations of tire frame origins in body frame
% Body frame located at vehicle CoM, oriented x along body of vehicle
X_i = repmat(permute([-car.a, -car.a, car.b, car.b], [1,3,2]), s);
Y_i = repmat(permute([-car.t(1)/2, car.t(1)/2, -car.t(2)/2, car.t(2)/2], [1,3,2]), s);


%% Steering
% Apply steering transfer function to input deltas
if isfield(car,'steer_linear_m')
    % Use linear approx. to ackerman steer (can be modified by factor)
    delta_i = cat(3, zeros(s), zeros(s), ... % no rear steer
                  -car.steer_linear_m .* deltas.^2 + deltas,... % FL
                   car.steer_linear_m .* deltas.^2 + deltas);
else 
    % Parallel steer assumption
    delta_i = cat(3, zeros(s), zeros(s), deltas, deltas);
end

% Superimpose static toe on steered angles
delta_i = delta_i + repmat( cat(3, car.toe_static(1), -car.toe_static(1), car.toe_static(2), -car.toe_static(2)), [s 1] );


%% Iterative solution
while (1 == 1)
    iter = iter + 1;       

    % Slip calculations
    beta_i = atand( ( repmat(V.*sind(betas), [1,1,4]) + repmat(omega_guess,[1,1,4]).*X_i ) ./ ( repmat(V.*cosd(betas), [1,1,4]) - repmat(omega_guess,[1,1,4]).*Y_i ) );
    alpha_i = beta_i - delta_i;

    % Weight Transfer Calculations
    % Transfer due to acceleration and aero
    Fz_i = repmat(permute(car.Fz_static', [1,3,2]), s) +...
           aero_drag .* aero_drag_gain +...
          -aero_lift .* aero_lift_gain +...
           repmat(Axb_guess, [1 1 4]) .* Axb_guess_gain +...
           repmat(Ayb_guess, [1 1 4]) .* Ayb_guess_gain;

    % Constrain such that tire cannot pull on road (only push)
    no_contact = (Fz_i > 0);
    keyboard;
    % this is wrong - only works when Ax = 0
%     if (no_contact(1))
%         Fz_i(1) = 0;
%         Fz_i(2) = sum(car.Fz_static(1:2));
%     elseif  (no_contact(2))
%         Fz_i(2) = 0;
%         Fz_i(1) = sum(car.Fz_static(1:2));
%     end
% 
%     if (no_contact(3))
%         Fz_i(3) = 0;
%         Fz_i(4) = sum(car.Fz_static(1:2));
%     elseif  (no_contact(4))
%         Fz_i(4) = 0;
%         Fz_i(3) = sum(car.Fz_static(1:2));
%     end

    % Chassis roll angle in degrees
    % positive roll in positive (right hand) turn
    % in right hand turn, if camber gain is pos (lose camber in roll)
    % then we should add phi*gain to static camber for RL
    % For RR we should gain camber (subtract positive phi*gain)
    phi = car.roll_grad .* Ayb_guess;
    camber_dyn = ...
        [car.camber_static(1) + phi .* car.camber_ride_gain(1);
         car.camber_static(1) - phi .* car.camber_ride_gain(1);
         car.camber_static(2) + phi .* car.camber_ride_gain(2) + delta .* car.camber_steer_gain;
         car.camber_static(2) - phi .* car.camber_ride_gain(2) - delta .* car.camber_steer_gain];

    % Evaluate Tire Model
    Fyti = [ h.CalculateFy(Fz_i(1)*lbf2N,  alpha_i(1), 0, camber_dyn(1), 0, car.pressure*psi2Pa, car.coeffs);...
            -h.CalculateFy(Fz_i(2)*lbf2N, -alpha_i(2), 0, camber_dyn(2), 0, car.pressure*psi2Pa, car.coeffs);...
             h.CalculateFy(Fz_i(3)*lbf2N,  alpha_i(3), 0, camber_dyn(3), 0, car.pressure*psi2Pa, car.coeffs);...
            -h.CalculateFy(Fz_i(4)*lbf2N, -alpha_i(4), 0, camber_dyn(4), 0, car.pressure*psi2Pa, car.coeffs)]...
            .* env.mu ./ lbf2N;

    Fxti = zeros(4,1);

    Mzti = [ h.CalculateMz(Fz_i(1)*lbf2N,  alpha_i(1), 0, camber_dyn(1), 0, car.pressure*psi2Pa, car.coeffs);...
            -h.CalculateMz(Fz_i(2)*lbf2N, -alpha_i(2), 0, camber_dyn(2), 0, car.pressure*psi2Pa, car.coeffs);...
             h.CalculateMz(Fz_i(3)*lbf2N,  alpha_i(3), 0, camber_dyn(3), 0, car.pressure*psi2Pa, car.coeffs);...
            -h.CalculateMz(Fz_i(4)*lbf2N, -alpha_i(4), 0, camber_dyn(4), 0, car.pressure*psi2Pa, car.coeffs)]...
             .* env.mu ./ (lbf2N * in2m);

    % Trim tires which are not in contact
    Fxti(no_contact) = 0;
    Fyti(no_contact) = 0;
    Mzti(no_contact) = 0;

    % Sum forces and moments on the car
    cdi = cosd(delta_i);
    sdi = sind(delta_i);

%     Fxb = sum( (Fxti .* cosd(delta_i)) - (Fyti .* sind(delta_i)) );
%     Fyb = sum( (Fxti .* sind(delta_i)) + (Fyti .* cosd(delta_i)) );
%     Mzb = sum( (X_i.*Fxti.*sind(delta_i)) - (Y_i.*Fxti.*cosd(delta_i)) +...
%                (Y_i.*Fyti.*sind(delta_i)) + (X_i.*Fyti.*cosd(delta_i)) )...
%                + sum(Mzti);
%     keyboard; 
    Fxb = (Fxti' * cdi) - (Fyti' * sdi);
    Fyb = (Fxti' * sdi) + (Fyti' * cdi);
    Mzb = ((X_i .* Fxti)' * sdi) - ((Y_i .* Fxti)' * cdi) +...
          ((Y_i .* Fyti)' * sdi) + ((X_i .* Fyti)' * cdi) + sum(Mzti);

    Axb_current = Fxb ./ car.w;
    Ayb_current = Fyb ./ car.w;
    CNb_current = Mzb ./ (car.w * car.wb);

    % Translate accelerations to velocity frame
    % This is just the 2d rotation about Z by beta
    Axv = Axb_current.*cosd(beta) + Ayb_current.*sind(beta);
    Ayv = Ayb_current.*cosd(beta) - Axb_current.*sind(beta);
    omega_current = (Ayv * 9.81) ./ (V * in2m);

    residual = Ayb_current - Ayb_guess;
    hist = [hist; beta, delta, delta_i', beta_i', alpha_i', Fz_i', no_contact', Fyti', Fxti', Mzti', Fxb, Fyb, Mzb, Axv, Ayv, CNb_current omega_current, iter, residual];




    % Check for convergence and exit iteration loop if converged
    if (abs(residual) < 1e-6 || iter > 100)
        if debug > 0
            disp([num2str(Ayb_guess) ' - ' num2str(Ayb_current) ' - ' num2str(abs(Ayb_current - Ayb_guess))]);
        end

        out = [out; hist(end,:)];
        break;
    else
        if debug > 2
            disp([num2str(Ayb_guess) ' - ' num2str(Ayb_current) ' - ' num2str(abs(Ayb_current - Ayb_guess))]);
        end
    end

    % Step with relaxation parameter
    p = .4;
    Ayb_guess = p*Ayb_guess + (1-p)*Ayb_current;
    Axb_guess = p*Axb_guess + (1-p)*Axb_current;
    CNb_guess = p*CNb_guess + (1-p)*CNb_current;
    omega_guess = p*omega_guess + (1-p)*omega_current;
end

outdata.data = out;
outdata.betas = betas;
outdata.deltas = deltas;
outdata.type = 'CN_Ay';
outdata.constant = 'speed';
outdata.car = car;
outdata.env = env;
outdata.env.V = V .* in2m;
  