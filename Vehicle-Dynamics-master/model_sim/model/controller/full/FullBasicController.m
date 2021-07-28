classdef FullBasicController
    properties
        car
        torquef
        torquer
    end

    methods
        function obj = FullBasicController(car, torquef, torquer)
            obj.car = car;
            obj.torquef = torquef;
            obj.torquer = torquer;
        end
        
        function [control] = control(obj, ~, state)
            car = obj.car;

            state = car.stateCollector.unpack(state);
            carState = state{1};
            
            % Keep car going straight
            steer = -carState.hdot * 1;

            control =  [steer, 0, obj.torquef, obj.torquef, obj.torquer, obj.torquer];
        end
    end
end
