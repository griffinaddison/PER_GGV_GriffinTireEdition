classdef OldAccelController
    properties
        car
        
        % Boolean if should limit power to car max power
        powerLimit
    end

    methods
        function obj = OldAccelController(car, powerLimit)
            obj.car = car;
            obj.powerLimit = powerLimit;
        end
        
        function [control] = control(obj, ~, state)
            car = obj.car;

            state = car.stateCollector.unpack(state);
            carState = state{1};
            motorfState = state{2};
            motorrState = state{3};
            
            pfdot = carState.w(1);
            prdot = carState.w(3);

            carSpeed = sqrt(carState.xdot^2 + carState.ydot^2);

            % Simple slip ratio P-controller
            srf = pfdot * car.params.radius / carSpeed - 1;
            srr = prdot * car.params.radius / carSpeed - 1;
            
            % Assuming peak tire performance is at SR ~0.15
            torquef = 500 * (0.15 - srf) * 55;
            torquer = 800 * (0.15 - srr) * 55; 

            if obj.powerLimit
                availablePower = car.accumulator.maxPower - ...
                                 car.params.estimatedMocLosses;

                [~, ~, powerr, ~, ~, ~] =  ...
                    car.motors{3}.compute({}, torquer, prdot);
                
                if powerr* 2 > availablePower
%                     disp('powerlimit');
                    powerr = availablePower / 2;
                    torquer = min(torquer, powerr / prdot);
                end
                
                availablePower = availablePower - 2 * powerr;
                
                powerf = availablePower / 2;
                torquef = min(torquef, powerf / pfdot);
            end

            torquer = max(torquer, 0);
            torquef = max(torquef, 0);
            
            % Keep car going straight
            steer = -carState.hdot * 5;

            control =  [steer, 0, torquef, torquef, torquer, torquer];
        end
    end
end