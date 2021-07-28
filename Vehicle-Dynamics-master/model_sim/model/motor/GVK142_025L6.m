classdef GVK142_025L6 < MotorModel
    % GVK142_025L6 Very basic model based on peak torque
    properties
        % Simulated data says 1677rad/s, datasheet says 9500rpm
        % Parker said 12k rpm should be save
        maxVel = 1256;
    end
    methods
        function obj = GVK142_025L6(ratio, inboard, varargin)
            mass = 2.1;
            obj = obj@MotorModel(mass, ratio, inboard, varargin{:});
        end
        function [statedot, torque, powerOut, powerLoss, current, saturation] = compute(obj, ~, T, w)
            % semi complete model
            % missing voltage effects, only accounted for in Pmax (from 250V)
            T = T / obj.gearRatio;
            w = w * obj.gearRatio;
            Tpk = 24.2;
            kt = 0.155; %Nm/Arms
            r = 0.100947; %ohm
            Tf = 0.02435;%Friction torque
            B = 1.0838e-4;%viscous torque constant
            % Where is this coming from?
            T_sat_poly = [-.000512 .223 -2.313]; %ax2 + bx + c
            % 2166080 = I * w at field weakening onset
            ki_fw = (2166080/60)*(2*pi); %I = ki/w % field weakening current limit
            kt_fw = [-0.0102; 32.3];

            % TODO: sensible maxing behavior
            w_lim = 1677; %rad/s limit
%             w_lim = 4000; %rad/s limit

            % Need to figure out where 11 is coming from
            if T<=11 %Torque saturation begins
                I = T/kt;
            elseif T<=Tpk %peak torque 
                % Need to figure out where poly is coming from
                a = roots([T_sat_poly(1:2) T_sat_poly(3)-T]);
                I = a(end);
            else
                T = Tpk;
                % Where is this I coming from?
                I = 281.2; % Suraj set to 280, should be 281.2 from datasheet?
            end
            
            if I>(ki_fw/w) %field weakening range
                % Need to figure out where ki and kt are coming from
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
