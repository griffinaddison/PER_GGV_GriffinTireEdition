classdef MotorModel < Component
    % MotorModel base class for electric motors
    properties
        gearRatio
        mass
        isInboard
    end
    methods (Abstract)
        % Output: statedot, torque, powerOut, powerLoss, current, saturation
        compute(obj, state, torque, w)
        getMaxVelocity(obj)
    end

    methods
        function obj = MotorModel(mass, ratio, inboard, varargin)
            obj = obj@Component(varargin{:});
            obj.mass = mass;
            obj.gearRatio = ratio;
            obj.isInboard = inboard;
        end

        function [baseMotorTorque] = getBaseTorque(obj, torque)
            baseMotorTorque = torque / obj.gearRatio;
        end
    end
end
