classdef FullSlalomController
    properties
        targetVel
        steerAmplitude
        steerFrequency
        fbTransferCoef
        lrTransferCoef
    end

    methods
        function obj = FullSlalomController(targetVel, steerAmplitude, steerFrequency,...
                                  fbTransferCoef, lrTransferCoef)
            obj.targetVel = targetVel;
            obj.steerAmplitude = steerAmplitude;
            obj.steerFrequency = steerFrequency;
            obj.fbTransferCoef = fbTransferCoef;
            obj.lrTransferCoef = lrTransferCoef;
        end
        
        function [controlOut] = control(obj, time, state)
            x = state(1);
            xdot = state(2);
            y = state(3);
            ydot = state(4);
            vel = sqrt(xdot^2 + ydot^2);
            err = obj.targetVel * 1.2 - vel;
            totalTorque = err * 40;

            steer = obj.steerAmplitude * sin(obj.steerFrequency * time * 2 * pi);

            torques = (totalTorque / 4) * ones(1, 4);
            fbTransfer = obj.fbTransferCoef * totalTorque / 4;
            lrTransfer = -obj.lrTransferCoef * steer * totalTorque / 4;
            
            torques = torques + [-fbTransfer + lrTransfer, ...
                                 -fbTransfer - lrTransfer, ...
                                  fbTransfer - lrTransfer, ...
                                  fbTransfer + lrTransfer];
            torques = max(torques, 0);

            controlOut = [steer, 0, torques];
        end
    end
end
