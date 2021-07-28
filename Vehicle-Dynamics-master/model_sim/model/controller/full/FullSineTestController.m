classdef FullSineTestController
    properties
        amplitude
        frequency
        driveTorque
    end

    methods
        function obj = FullSineTestController(amplitude, frequency, driveTorque)
            obj.amplitude = amplitude;
            obj.frequency = frequency;
            obj.driveTorque = driveTorque;
        end
        
        function [controlOut] = control(obj, time, state)
            controlOut = [obj.amplitude * sin(obj.frequency * time * 2 * pi), 0, obj.driveTorque, ...
                          obj.driveTorque, obj.driveTorque, obj.driveTorque];
        end
    end
end
