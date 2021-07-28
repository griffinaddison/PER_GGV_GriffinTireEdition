classdef IdealMotor < MotorModel
    % IdealMotor a perfect motor
    %   Perfectly matches the desired output torque
    %   No power loss, no internal state
    methods
        function [statedot, torque, powerOut, powerLoss, current, saturation] = compute(obj, ~, T, w)
            T = T / obj.gearRatio;
            w = w * obj.gearRatio;
            % Seems redundant but is necessary
            torque = T * obj.gearRatio;
            powerOut = T * w;
            powerLoss = 0;
            current = 0;
            saturation = 0;

            statedot = {};
        end

        function [maxVelOut] = getMaxVelocity()
            maxVelOut = inf;
        end
    end
end
