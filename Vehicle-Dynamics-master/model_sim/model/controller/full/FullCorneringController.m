classdef FullCorneringController
    properties
        steer 
        targetVel
        fbTransferCoef
        lrTransferCoef
    end

    methods
        function obj = FullCorneringController(steer, targetVel, ...
                                  fbTransferCoef, lrTransferCoef)
            obj.steer = steer;
            obj.targetVel = targetVel;
            obj.fbTransferCoef = fbTransferCoef;
            obj.lrTransferCoef = lrTransferCoef;
        end
        
        function [controlOut] = control(obj, time, state)
            xdot = state(2);
            ydot = state(4);
            vel = sqrt(xdot^2 + ydot^2);
            err = obj.targetVel - vel;
            totalTorque = err * 40;

            torques = (totalTorque / 4) * ones(1, 4);
            fbTransfer = obj.fbTransferCoef * totalTorque / 4;
            lrTransfer = -obj.lrTransferCoef * obj.steer * totalTorque / 4;
            
            torques = torques + [-fbTransfer + lrTransfer, ...
                                 -fbTransfer - lrTransfer, ...
                                  fbTransfer - lrTransfer, ...
                                  fbTransfer + lrTransfer];
            torques = max(torques, 0);
            
            controlOut = [obj.steer, 0, torques];
        end
    end
end
