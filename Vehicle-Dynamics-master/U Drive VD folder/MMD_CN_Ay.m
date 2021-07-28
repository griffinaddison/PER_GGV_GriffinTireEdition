function [outdata] = MMD_CN_Ay(car, env, betas, deltas, V, h, debug)
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


%% Correct track widths if t_mean or offset have been updated
car.t   = [car.t_mean - car.t_rear_delta; car.t_mean + car.t_rear_delta];



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



%% Resolve locations of tire frame origins in body frame
% Body frame located at vehicle CoM, oriented x along body of vehicle
X_i = [-car.a; -car.a; car.b; car.b];
Y_i = [-car.t(1)/2; car.t(1)/2; -car.t(2)/2; car.t(2)/2];



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

% keyboard;

%% Sweep car parameter space
for ii = 1:nn
    beta = betas(ii);
    delta = deltas(ii);
    if debug > 0
        disp(['-- beta = ' num2str(beta) '    delta = ' num2str(delta) ' --']);
    end
    
    % Initialize solved parameters
    Axb_guess = 0;
    Ayb_guess = 0;
    CNb_guess = 0;
    iter = 0;
    hist = [];
    Ayv_guess = Ayb_guess.*cosd(beta) - Axb_guess.*sind(beta);
    omega_guess = Ayv_guess ./ V;
        
    % Steering rack transfer function
    if isfield(car,'steer_linear_m')
        % Use linear approx. to ackerman percentage
        delta_i = [ 0; 0; % no rear steer
                   -car.steer_linear_m.*delta.^2 + delta;   % FL
                   car.steer_linear_m.*delta.^2 + delta];   % FR
    else 
        % Parallel steer assumption
        delta_i = [ 0; 0; delta; delta; ];
    end
    
    % superimpose static toe
    delta_i = delta_i + [ car.toe_static(1); -car.toe_static(1); car.toe_static(2); -car.toe_static(2) ];
       
    
    while (1 == 1)
        iter = iter + 1;       
        
        % Slip calculations
        beta_i = atand( ( V.*sind(beta) + omega_guess.*X_i ) ./ ( V.*cosd(beta) - omega_guess.*Y_i ) );
        alpha_i = beta_i - delta_i;
        
        % Weight Transfer Calculations
        % Transfer due to acceleration and aero
        Fz_i = car.Fz_static +...
                aero_drag .* [-deltaFzf_deltaDb;  -deltaFzf_deltaDb;   deltaFzf_deltaDb;  deltaFzf_deltaDb] +...
               -aero_lift .* [ deltaFzr_deltaLb;   deltaFzr_deltaLb;   deltaFzf_deltaLb;  deltaFzf_deltaLb] +...
               Axb_guess .* [-deltaFzf_deltaAxb; -deltaFzf_deltaAxb;  deltaFzf_deltaAxb; deltaFzf_deltaAxb] +...
               Ayb_guess .* [-deltaFzr_deltaAyb;  deltaFzr_deltaAyb; -deltaFzf_deltaAyb; deltaFzf_deltaAyb];
%         keyboard;
        
        % Constrain such that tire cannot pull on road (only push)
        no_contact = (Fz_i > 0);
        if (no_contact(1))
            Fz_i(1) = 0;
            Fz_i(2) = sum(car.Fz_static(1:2));
        elseif  (no_contact(2))
            Fz_i(2) = 0;
            Fz_i(1) = sum(car.Fz_static(1:2));
        end

        if (no_contact(3))
            Fz_i(3) = 0;
            Fz_i(4) = sum(car.Fz_static(1:2));
        elseif  (no_contact(4))
            Fz_i(4) = 0;
            Fz_i(3) = sum(car.Fz_static(1:2));
        end

        % Chassis roll angle in degrees
        % positive roll in positive (right hand) turn
        
        
        % in right hand turn, if camber gain is pos (lose camber in roll)
        % then we should add phi*gain to static camber for RL
        % For RR we should gain camber (subtract positive phi*gain)
        
        
        phi = car.roll_grad * Ayb_guess; 
        camber_dyn = ...
            [ phi + car.camber_static(1) + phi .* car.camber_roll_gain(1);
             -phi + car.camber_static(1) - phi .* car.camber_roll_gain(1);
              phi + car.camber_static(2) + phi .* car.camber_roll_gain(2) + delta .* car.camber_steer_gain;
             -phi + car.camber_static(2) - phi .* car.camber_roll_gain(2) - delta .* car.camber_steer_gain];

        % Evaluate Tire Model
%         keyboard;
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
        
%         Fxb = sum( (Fxti .* cosd(delta_i)) - (Fyti .* sind(delta_i)) );
%         Fyb = sum( (Fxti .* sind(delta_i)) + (Fyti .* cosd(delta_i)) );
%         Mzb = sum( (X_i.*Fxti.*sind(delta_i)) - (Y_i.*Fxti.*cosd(delta_i)) +...
%                    (Y_i.*Fyti.*sind(delta_i)) + (X_i.*Fyti.*cosd(delta_i)) )...
%                    + sum(Mzti);
%         keyboard; 
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

        % Debug Plotting
        if (debug > 1)
            if (iter == 2) % need to create the plots
                figure(10); clf;
                suptitle(['Debug - Iteration info for Beta = ' num2str(beta) ', Delta = ' num2str(delta)]);
                nsr = 4;
                nsc = 4;
                
                % Tire Info
                subplot(nsr,nsc,1); hdi = plot(hist(:,3:6), '.-');    ylabel('\delta_i'); legend('RL', 'RR', 'FL', 'FR');
                subplot(nsr,nsc,2); hbi = plot(hist(:,7:10), '.-');   ylabel('\beta_i'); 
                subplot(nsr,nsc,3); hai = plot(hist(:,11:14), '.-');  ylabel('\alpha_i');
                subplot(nsr,nsc,4); hnci = plot(hist(:,19:22), '.-'); ylabel('no contact_i');

                % Tire forces and moments
                subplot(nsr,nsc,5); hfzi = plot(hist(:,15:18), '.-'); ylabel('F_{z,i}^b');
                subplot(nsr,nsc,6); hfxi = plot(hist(:,27:30), '.-'); ylabel('F_{x,i}^b');
                subplot(nsr,nsc,7); hfyi = plot(hist(:,23:26), '.-'); ylabel('F_{y,i}^b');
                subplot(nsr,nsc,8); hmzi = plot(hist(:,31:34), '.-'); ylabel('M_{z,i}^b');

                % Body forces and moments
                subplot(nsr,nsc,9); hfxb = plot(hist(:,35), '.-'); ylabel('F_x^b');
                subplot(nsr,nsc,10); hfyb = plot(hist(:,36), '.-'); ylabel('F_y^b');
                subplot(nsr,nsc,11); hmzb = plot(hist(:,37), '.-'); ylabel('M_z');
                subplot(nsr,nsc,12); hmwc = plot(hist(:,41), '.-'); ylabel('\omega');

                % Velocity Frame Outputs
                subplot(nsr,nsc,13); haxv = plot(hist(:,38), '.-'); ylabel('A_x^v');
                subplot(nsr,nsc,14); hayv = plot(hist(:,39), '.-'); ylabel('A_y^v');
                subplot(nsr,nsc,15); hcnv = plot(hist(:,40), '.-'); ylabel('CN^v');

                % Residual
                subplot(nsr,nsc,16); hres = semilogy(abs(hist(:,43)), '.-'); ylabel('Conv Crit');
                drawnow();
                
            elseif (iter > 2) % just update the handles to include new info
%                 keyboard;
                for ll = 1:4
                    set(hdi(ll), 'Ydata', hist(:,3+ll-1));
                    set(hbi(ll), 'Ydata', hist(:,7+ll-1));
                    set(hai(ll), 'Ydata', hist(:,11+ll-1));
                    set(hnci(ll), 'Ydata', hist(:,19+ll-1));
                    set(hfzi(ll), 'Ydata', hist(:,15+ll-1));
                    set(hfxi(ll), 'Ydata', hist(:,27+ll-1));
                    set(hfyi(ll), 'Ydata', hist(:,23+ll-1));
                    set(hmzi(ll), 'Ydata', hist(:,31+ll-1));
                end
                
                set(hfxb, 'Ydata', hist(:,35));
                set(hfyb, 'Ydata', hist(:,36));
                set(hmzb, 'Ydata', hist(:,37));
                set(hmwc, 'Ydata', hist(:,41));
                
                set(haxv, 'Ydata', hist(:,38));
                set(hayv, 'Ydata', hist(:,39));
                set(hcnv, 'Ydata', hist(:,40));
                
                set(hres, 'Ydata', abs(hist(:,43)));
                
                drawnow();
            end
        end
        
        
        % Check for convergence and exit iteration loop if converged
        if (abs(residual) < 1e-6 || iter > 100)
            if debug > 0
                disp([num2str(Ayb_guess) ' - ' num2str(Ayb_current) ' - ' num2str(abs(Ayb_current - Ayb_guess))]);
                % disp(Fz_i);
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
end


outdata.CN = reshape(out(:,40), size(betas));
outdata.AY = reshape(out(:,39), size(betas));
outdata.AX = reshape(out(:,38), size(betas));
outdata.betas_actual = reshape(out(:,1), size(betas));
outdata.deltas_actual = reshape(out(:,2), size(betas));

outdata.data = out;
outdata.betas = betas;
outdata.deltas = deltas;
outdata.type = 'CN_Ay';
outdata.constant = 'speed';
outdata.car = car;
outdata.env = env;
outdata.env.V = V .* in2m;
  