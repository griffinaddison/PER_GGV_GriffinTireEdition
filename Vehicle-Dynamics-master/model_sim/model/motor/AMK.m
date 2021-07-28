classdef AMK < MotorModel
    properties
        maxVel = 2094;
    end
    methods
        function [statedot, torque, powerOut, powerLoss, current, saturation] = compute(obj, ~, T, w)
            
            T = T / obj.gearRatio;
            w = w * obj.gearRatio;
            
            Tpk = 21;
            w_lim = 2094; %rad/s limit
            
            if T > Tpk && w <= w_lim
                T = Tpk;
            end
            
            %modeling the peak power vs rpm curve
            if w <= 1675
                Pmax = 21*w;
            elseif w <= w_lim
                Pmax = 1675*21;
            elseif w > w_lim
                Pmax = 0;
            end 
            
            Prequest = T*w; %requested power
            
            %determine actual output power based on peak power curve
            if Prequest > Pmax
                powerOut = Pmax;
            else
                powerOut = Prequest;
            end
            
            torque = powerOut/w * obj.gearRatio;
            current = -190.96*log(-torque/49.649+1);
            %This is a curve to model saturation. Derived in the
            %following method:
            %Let T(I) be T as a function of I. We desire that T(105) = 21
            %because Ipk = 105 and Tpk = 21. We also desire that T(0) = 0
            %and T'(0) = 0.26, since the torque constant is 0.26.
            %Determined a function of the form T = a - b*exp(c*I) that fit
            %these parameters.
            %The function type is rather arbitrary, but it is intended
            %to give an approximation for power input into the motors (I*600 V).
            
            %powerLoss = current*600 - powerOut;

            % Some bullshit approximation
            powerLoss = current * 20;

            saturation = 0;
            statedot = {};
        end
    end
end
