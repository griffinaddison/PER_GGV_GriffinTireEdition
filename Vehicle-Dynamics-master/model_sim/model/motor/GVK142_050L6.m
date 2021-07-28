classdef GVK142_050L6 < MotorModel
    % GVK142_050L6 Very basic model based on peak torque
    properties
        % Simulated data says 1677rad/s, datasheet says 9500rpm
        % Parker said 12k rpm should be save
        maxVel = 1256;
    end
    methods
        function obj = GVK142_050L6(ratio, inboard, varargin)
            mass = 4.0;
            obj = obj@MotorModel(mass, ratio, inboard, varargin{:});
        end
        function [statedot, torque, powerOut, powerLoss, current, saturation] = compute(obj, ~, T, w)
            % semi complete model
            % missing voltage effects, only accounted for in Pmax (from 250V)
            T = T / obj.gearRatio;
            w = w * obj.gearRatio;
            Tpk = 49.77;
            kt = .310; %Nm/Arms
            r = .1405; %ohm
            Tf = .0487;%Friction torque
            B = 2.168e-4;%viscous torque constant
            T_sat_poly = [-.001024 .446 -4.626];%ax2 + bx + c
            ki_fw = 1850400/60*(2*pi); %I = ki/w % field weakening current limit

            %kt_fw = [-0.0024793 * 60 / (2 * pi); 59.0664];
            kt_fw = [-0.0024793 * 60 / (2 * pi); 61.9];

            % TODO: sensible maxing behavior
            w_lim = 1677;%rad/s limit
%             w_lim = 3000;%rad/s limit
            
            if T<=22 %Torque saturation begins
                I = T/kt;
            elseif T<=Tpk %peak torque 
                a = roots([T_sat_poly(1:2) T_sat_poly(3)-T]);
                I = a(end);
            else
                T = Tpk;
                I = 385.5;
            end

            if I>(ki_fw/w) %field weakening range
                I = ki_fw/w;
                T = kt_fw(1)*w + kt_fw(2);
            end
            
            if w > w_lim %speed limit
                T = T / (1 + (w - w_lim) * 30/pi);
            end

            torque = T * obj.gearRatio;
            powerOut = T*w;%W
            powerLoss = real(w*(Tf+3*B*w/(100*pi))+I^2*r); %moving&resistive losses
            current = I;
            saturation = 1-(T/(kt*I));

            statedot = {};
        end

        function [maxVelOut] = getMaxVelocity(obj)
            maxVelOut = obj.maxVel / obj.gearRatio;
        end
    end
end
