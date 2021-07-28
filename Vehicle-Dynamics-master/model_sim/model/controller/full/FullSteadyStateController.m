classdef FullSteadyStateController
    properties
        steer 
        brake
        torques
    end

    methods
        function obj = FullSteadyStateController(steer, brake, torques)
            obj.steer = steer;
            obj.brake = brake;
            obj.torques = torques;
        end
        
        function [controlOut] = control(obj, time, state)
            controlOut = [obj.steer, obj.brake, obj.torques];
        end
    end
end
