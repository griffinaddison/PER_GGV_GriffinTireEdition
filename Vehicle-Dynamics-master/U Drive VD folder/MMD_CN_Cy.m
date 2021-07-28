function [out] = MMD_CN_Cy(car, betas, deltas, radius, h, debug)
% car is in in. lb. sec. units. mass in slugs.
% tire model will be evaluated with correct converted units and will return
% lbf.
% use SAE coordinate system.  X forward, Y right, Z down
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
n = length(betas(:));
out = [];


%% Unit Conversion Factors
lbf2N = 4.44822162;
psi2Pa = 6894.75729;
in2m = .0254;


%% Resolve locations of tire frame origins in body frame
% CPatton p.55: Body frame located at vehicle CoM, oriented x along body of
% vehicle
X_i = [-car.a; -car.a; car.b; car.b];
Y_i = [-car.t(1)/2; car.t(1)/2; -car.t(2)/2; car.t(2)/2];


%% Calculate Acceleration Gains
% CPatton p.60, eqns 62-64
deltaFzf_deltaAxb = (car.h*car.w) / (2*car.wb);
deltaFzf_deltaAyb = (car.h*car.w*car.N_mag) / (car.t(2));
deltaFzr_deltaAyb = (car.h*car.w*(1-car.N_mag)) / (car.t(1));


%% Sweep car parameter space
for ii = 1:n
    beta = betas(ii);
    delta = deltas(ii);
    if debug > 0
        disp(['-- beta = ' num2str(beta) '    delta = ' num2str(delta) ' --']);
    end
        
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
    %

    % Slip calculations
    beta_i = atand( ( radius*sind(beta) + X_i ) ./ ( radius*cosd(beta) - Y_i ) );
    alpha_i = beta_i - delta_i;
    
    % Initialize solved parameters
    Axb_guess = 0;
    Ayb_guess = 0;
    CNb_guess = 0;
    iter = 0;
    hist = [];

    while (1 == 1)
        iter = iter + 1;       
        % Weight Transfer Calculations
        % Weight is transferred off 
        Fz_i = car.Fz_static +...
               Axb_guess .* [-deltaFzf_deltaAxb; -deltaFzf_deltaAxb; deltaFzf_deltaAxb; deltaFzf_deltaAxb] +...
               Ayb_guess .* [-deltaFzr_deltaAyb; deltaFzr_deltaAyb; -deltaFzf_deltaAyb; deltaFzf_deltaAyb];

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
            [car.camber_static(1) + phi .* car.camber_ride_gain(1);
             car.camber_static(1) - phi .* car.camber_ride_gain(1);
             car.camber_static(2) + phi .* car.camber_ride_gain(2) + delta .* car.camber_steer_gain;
             car.camber_static(2) - phi .* car.camber_ride_gain(2) - delta .* car.camber_steer_gain];

        % Evaluate Tire Model
%         keyboard;
        Fyti = [ h.CalculateFy(Fz_i(1)*lbf2N,  alpha_i(1), 0, camber_dyn(1), 0, car.pressure*psi2Pa, car.coeffs);...
                -h.CalculateFy(Fz_i(2)*lbf2N, -alpha_i(2), 0, camber_dyn(2), 0, car.pressure*psi2Pa, car.coeffs);...
                 h.CalculateFy(Fz_i(3)*lbf2N,  alpha_i(3), 0, camber_dyn(3), 0, car.pressure*psi2Pa, car.coeffs);...
                -h.CalculateFy(Fz_i(4)*lbf2N, -alpha_i(4), 0, camber_dyn(4), 0, car.pressure*psi2Pa, car.coeffs)]...
                .* car.mu ./ lbf2N;

        Fxti = zeros(4,1);

        Mzti = [ h.CalculateMz(Fz_i(1)*lbf2N,  alpha_i(1), 0, camber_dyn(1), 0, car.pressure*psi2Pa, car.coeffs);...
                -h.CalculateMz(Fz_i(2)*lbf2N, -alpha_i(2), 0, camber_dyn(2), 0, car.pressure*psi2Pa, car.coeffs);...
                 h.CalculateMz(Fz_i(3)*lbf2N,  alpha_i(3), 0, camber_dyn(3), 0, car.pressure*psi2Pa, car.coeffs);...
                -h.CalculateMz(Fz_i(4)*lbf2N, -alpha_i(4), 0, camber_dyn(4), 0, car.pressure*psi2Pa, car.coeffs)]...
                 .* car.mu ./ (lbf2N * in2m);

        % Trim tires which are not in contact
        Fxti(no_contact) = 0;
        Fyti(no_contact) = 0;
        Mzti(no_contact) = 0;

        % Sum forces and moments on the car
        Fxb = sum( (Fxti .* cosd(delta_i)) - (Fyti .* sind(delta_i)) );
        Fyb = sum( (Fxti .* sind(delta_i)) + (Fyti .* cosd(delta_i)) );
        Mzb = sum( (X_i.*Fxti.*sind(delta_i)) - (Y_i.*Fxti.*cosd(delta_i)) +...
                   (Y_i.*Fyti.*sind(delta_i)) + (X_i.*Fyti.*cosd(delta_i)) )...
                   + sum(Mzti);

        Axb_current = Fxb ./ car.w;
        Ayb_current = Fyb ./ car.w;
        CNb_current = Mzb ./ (car.w * car.wb);
        
        % Translate accelerations to velocity frame
        % This is just the 2d rotation about Z by beta
        Axv = Axb_current*cosd(beta) + Ayb_current*sind(beta);
        Ayv = Ayb_current*cosd(beta) - Axb_current*sind(beta);
        
        residual = Ayb_current - Ayb_guess;
        hist = [hist; beta, delta, delta_i', beta_i', alpha_i', Fz_i', no_contact', Fyti', Fxti', Mzti', Fxb, Fyb, Mzb, Axv, Ayv, CNb_current, iter, residual];

        % Debug Plotting
        if (debug > 1)
            if (iter == 2) % need to create the plots
                figure(10); clf;
                suptitle(['Debug - Iteration info for Beta = ' num2str(beta) ', Delta = ' num2str(delta)]);
                                
                % Tire Info
                subplot(4,4,1); hdi = plot(hist(:,3:6), '.-');    ylabel('Delta_i'); legend('RL', 'RR', 'FL', 'FR');
                subplot(4,4,2); hbi = plot(hist(:,7:10), '.-');   ylabel('Beta_i'); 
                subplot(4,4,3); hai = plot(hist(:,11:14), '.-');  ylabel('alpha_i');
                subplot(4,4,4); hnci = plot(hist(:,19:22), '.-'); ylabel('no_contact_i');

                % Tire forces and moments
                subplot(4,4,5); hfzi = plot(hist(:,15:18), '.-'); ylabel('Fz_i');
                subplot(4,4,6); hfxi = plot(hist(:,27:30), '.-'); ylabel('Fx_i');
                subplot(4,4,7); hfyi = plot(hist(:,23:26), '.-'); ylabel('Fy_i');
                subplot(4,4,8); hmzi = plot(hist(:,31:34), '.-'); ylabel('Mz_i');

                % Body forces and moments
                subplot(4,4,9); hfxb = plot(hist(:,35), '.-'); ylabel('Fx_b');
                subplot(4,4,10); hfyb = plot(hist(:,36), '.-'); ylabel('Fy_b');
                subplot(4,4,11); hmzb = plot(hist(:,37), '.-'); ylabel('Mz_b');

                % Velocity Frame Outputs
                subplot(4,4,13); haxv = plot(hist(:,38), '.-'); ylabel('Ax_v');
                subplot(4,4,14); hayv = plot(hist(:,39), '.-'); ylabel('Ay_v');
                subplot(4,4,15); hcnv = plot(hist(:,40), '.-'); ylabel('CN_v');

                % Residual
                subplot(4,4,16); hres = semilogy(abs(hist(:,42)), '.-'); ylabel('Conv Crit');
                set(findobj('type','axes'),'xgrid','on');
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
                
                set(haxv, 'Ydata', hist(:,38));
                set(hayv, 'Ydata', hist(:,39));
                set(hcnv, 'Ydata', hist(:,40));
                
                set(hres, 'Ydata', abs(hist(:,42)));
                
                drawnow();
            end
        end
        
        
        % Check for convergence and exit iteration loop if converged
        if (abs(residual) < 1e-4 || iter > 250)
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
        p = .5;
        Ayb_guess = p*Ayb_guess + (1-p)*Ayb_current;
        Axb_guess = p*Axb_guess + (1-p)*Axb_current;
        CNb_guess = p*CNb_guess + (1-p)*CNb_current;
    end
end
  