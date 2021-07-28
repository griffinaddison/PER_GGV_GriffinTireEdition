classdef FullAccelController < handle
    properties
        car
        trackX
        trackY
        prevWP
        nextWP
        
        srPeak = 0.15;
        ke = 8;
        
        maxSteer = 0.6;
        
        % Boolean if should limit power to car max power
        powerLimit
    end

    methods
        function obj = FullAccelController(car, track, powerLimit)
            obj.car = car;
            sectorLength = 1;
            [obj.trackX, obj.trackY, ~, ~] = createSectors(track.distances, track.radii, sectorLength);
            obj.prevWP = 1;
            obj.nextWP = 2;
            obj.powerLimit = powerLimit;
        end
        
        function [control] = control(obj, ~, state)
            car = obj.car;
            
            state = car.stateCollector.unpack(state);
            carState = state{1};
            
            cp = car.params;
            xf = carState.x + cp.wheelbase * (1 - cp.comDistribution) * cos(carState.h);
            yf = carState.y + cp.wheelbase * (1 - cp.comDistribution) * sin(carState.h);
            
            %STEERING CONTROL
            p1 = [obj.trackX(obj.prevWP), obj.trackY(obj.prevWP)];
            p2 = [obj.trackX(obj.nextWP), obj.trackY(obj.nextWP)];

            % Compute cross track error and check waypoint
            [cte, inc] = computeCTE(carState.h, [xf, yf], p1, p2);
            
            % Compute heading error
            headingError = computeHeadingError(carState.h, p1, p2);
            carSpeed = sqrt(carState.xdot^2 + carState.ydot^2);
            steer = headingError + atan2(obj.ke * cte, carSpeed);
            steer = max(-obj.maxSteer, min(steer, obj.maxSteer));
            
            if inc >= 1
                obj.prevWP = min(length(obj.trackX) - 1, obj.prevWP + inc);
                obj.nextWP = min(length(obj.trackX), obj.nextWP + inc);
            end
            
%             disp(steer);

%             %SWERVE
%             if carState.x > 100 && carState.x < 105
%                 steer = 0.6;
%             end
%             if carState.x >= 105
%                 steer = 0;
%             end
          
%             steer = -carState.hdot * 5;
            
            % TORQUE CONTROL
            
            pfdot = carState.w(1);
            prdot = carState.w(3);
            
            srf = pfdot * cp.radius / carSpeed - 1;
            srr = prdot * cp.radius / carSpeed - 1;
            
            % Assuming peak tire performance is at SR ~0.15
            torquef = 500 * (obj.srPeak) * 55;
            torquer = 800 * (obj.srPeak) * 55; 

            if obj.powerLimit
                availablePower = car.accumulator.maxPower - ...
                                 car.params.estimatedMocLosses;

                [~, ~, powerr, ~, ~, ~] =  ...
                    car.motors{3}.compute({}, torquer, prdot);
                
                if powerr * 2 > availablePower
                    powerr = availablePower / 2;
                    disp('powerlimit');
                    torquer = min(torquer, powerr / prdot);
                end
                
                availablePower = availablePower - 2 * powerr;
                
                powerf = (availablePower) / 2;
                torquef = min(torquef, powerf / pfdot);
            end

            torquer = max(torquer, 0);
            torquef = max(torquef, 0);
            brake = 0;
            
%             %SWERVE
%             if carState.x > 100
%                 torquef = 0;
%                 torquer = 0;
% %                 brake = 0.1;
%             end
            
            control =  [steer, brake, torquef, torquef, torquer, torquer];
        end
    end
end
