classdef TireModel < Component
    % TireModel an abstract representation of a single tire
    methods (Abstract)
        % Output: statedot, forces vector
        compute(obj, state, fz, sa, sr, vx)

        % Output: statedot, forces vector
        % Attempts to match fxCommanded, unless it's outside
        % the friction limit
        computeNoSR(obj, state, fz, sa, fxCommanded, vx)

        % useSR: whether the tire model should base forward tractive forces
        % off of slip ratios or off of precalculated x coefficients
        init()
    end

    methods
        function obj = TireModel(varargin)
            obj = obj@Component(varargin{:})
        end
    end
end

