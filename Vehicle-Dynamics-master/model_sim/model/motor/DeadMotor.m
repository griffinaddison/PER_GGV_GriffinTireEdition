classdef DeadMotor < MotorModel
    % DeadMotor no motor at all 
    methods
        function obj = DeadMotor(varargin)
            obj = obj@MotorModel(0, 1, true, varargin{:});
        end
        function [statedot, torque, powerOut, powerLoss, current, saturation] = compute(~, ~, T, w)
            torque = 0;
            powerOut = 0;
            powerLoss = 0;
            current = 0;
            saturation = 0;

            statedot = {};
        end

        function [maxVelOut] = getMaxVelocity(obj)
            maxVelOut = inf;
        end
    end
end
