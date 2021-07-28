classdef FullPathController < handle
    properties
        car
        targetVel
        trackX
        trackY
        prevWP
        nextWP
        ggvVels
        useGGV
        
        srPeak = 0.15;
        kp = 0.8;
%         kd = 0.001;
        ke = 8;
        
        maxSteer = 0.6;
        steerRate = 3 * pi;
        prevSteer = 0;
        prevError = 0;
        prevTime = 0;
        
        dela;
        windowSize = 25;
        windowRear;
        windowFront;
        
        % Boolean if should limit power to car max power
        powerLimit
    end

    methods
        function obj = FullPathController(car, targetVel, track, powerLimit, generateGGV, ggv)
            obj.car = car;
            obj.targetVel = targetVel;
            sectorLength = 0.5;
            [xs, ys, dists, curvatures] = createSectors(track.distances, track.radii, sectorLength);
            obj.trackX = xs;
            obj.trackY = ys;
            obj.dela = delaunayn([xs.', ys.']);
            obj.windowRear = 1;
            obj.windowFront = obj.windowRear + obj.windowSize;
            obj.prevWP = 1;
            obj.nextWP = 2;
            obj.powerLimit = powerLimit;
            if generateGGV
                obj.generateGGV(xs, ys, dists, curvatures, 1.001, inf, ggv);
            end
        end
        
        function generateGGV(obj, xs, ys, dists, curvatures, startVel, endVel, ggv)
%             ggv = createGGV(obj.car, 'display', true);
            ggvSafetyFactor = 0.92;
            numSectors = length(xs);
            cornerVs = 1 : 1 : ggv.maxLongVelocity;
            cornerVs(1) = 1.001;
            for i = 1:length(cornerVs)
                v = cornerVs(i);
                ggvPoint = ggv.latAccelLookup(v, 0);
                maxCurvatures(i) = ggvPoint.yddot / v^2;
            end
            maxCornerVel = @(curvature) ...
                interp1(maxCurvatures, cornerVs, curvature, 'linear');
            startVel = min(startVel, maxCornerVel(abs(curvatures(1))) * ggvSafetyFactor);

            % GET ACCELERATION VELOCITIES
            accelVs(1) = startVel;

            startLatAccel = curvatures(1) * accelVs(1)^2;
            accelGGVPoints(1) = ggv.longAccelLookup(accelVs(1), startLatAccel);

            for i = 2 : numSectors
                v = accelVs(i-1);

                latAccel = curvatures(i - 1) * v^2;
                ggvPoint = ggv.longAccelLookup(v, latAccel);
                longAccel = ggvPoint.xddot;

                % v^2 = v_0^2 + 2ad
                vn = sqrt(v^2 + 2 * longAccel * (dists(i) - dists(i-1)));
                vn = min(vn, ggv.maxLongVelocity);

                % Check if next velocity limited
                [vn, minIndex] = min([vn, maxCornerVel(abs(curvatures(i))) * ggvSafetyFactor]);

                accelVs(i) = vn;

                if minIndex == 1
                    accelGGVPoints(i) = ggvPoint;
                else
                    longAccel = (vn^2 - v^2) / (2 * (dists(i) - dists(i-1)));
                    accelGGVPoints(i) = ggv.pointLookup(vn, longAccel, latAccel);
                end
                assert(accelGGVPoints(i).powerDelivered < 90000);
            end

            % GET BRAKE VELOCITIES
            brakeVs = zeros(size(accelVs));
            brakeVs(end) = min([accelVs(end), endVel, maxCornerVel(abs(curvatures(1)))]);

            endLatAccel = curvatures(end) * brakeVs(end)^2;
            brakeGGVPoints(length(brakeVs)) = ggv.longBrakeLookup(brakeVs(end), endLatAccel);

            for i = numSectors - 1 : -1 : 1
                v = brakeVs(i + 1);

                latAccel = curvatures(i + 1) * v^2;
                ggvPoint = ggv.longBrakeLookup(v, latAccel);
                longBrakeAccel = -ggvPoint.xddot;

                vn = sqrt(v^2 + 2 * longBrakeAccel * (dists(i + 1) - dists(i)));
                vn = min(vn, ggv.maxLongVelocity);
                [vn, minIndex] = min([vn, maxCornerVel(abs(curvatures(i))) * ggvSafetyFactor]);

                brakeVs(i) = vn;

                if minIndex == 1
                    brakeGGVPoints(i) = ggvPoint;
                else
                    longAccel = (v^2 - vn^2) / (2 * (dists(i + 1) - dists(i)));
                    brakeGGVPoints(i) = ggv.pointLookup(vn, longAccel, latAccel);
                end
            end

            vs = min([accelVs; brakeVs], [], 1);
            vs = smoothdata(vs, 'gaussian', 25);
            obj.ggvVels = vs;
            obj.useGGV = true;
            
%             figure;
%             scatter3(xs, ys, smoothdata(vs, 'gaussian', 25), [], smoothdata(vs, 'gaussian', 25));
%             title('gaussian');
%             caxis([0, 30]);
%             colorbar;
            
        end
        
        function [control] = control(obj, t, state)
            tic
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
            deltaTime = t - obj.prevTime;
            obj.prevTime = t;
            deltaSteer = obj.steerRate * deltaTime;
            steer = max(obj.prevSteer - deltaSteer, min(steer, obj.prevSteer + deltaSteer));
            steer = max(-obj.maxSteer, min(steer, obj.maxSteer));
            obj.prevSteer = steer;
            
%             if inc >= 1
%                 obj.prevWP = min(length(obj.trackX) - 1, obj.prevWP + inc);
%                 obj.nextWP = min(length(obj.trackX), obj.nextWP + inc);
%             end


            ind = dsearchn([obj.trackX.' , obj.trackY.'], obj.dela, [xf, yf]);
%             ind = dsearchn([obj.trackX(obj.windowRear:obj.windowFront).' , ...
%                 obj.trackY(obj.windowRear:obj.windowFront).'], [xf, yf]);
            pn = [obj.trackX(min(length(obj.trackX), ind + 1)), obj.trackY(min(length(obj.trackY), ind + 1))];
            pp = [obj.trackX(max(1, ind - 1)), obj.trackY(max(1, ind - 1))];
            pos = [xf, yf];
            if norm(pp - pos) < norm(pn - pos)
                obj.prevWP = max(1, ind - 1);
                obj.nextWP = ind;
            else
                obj.prevWP = ind;
                obj.nextWP = min(length(obj.trackX), ind + 1);
            end
            obj.windowRear = max(1, obj.prevWP - fix(obj.windowSize / 2));
            obj.windowFront = min(length(obj.trackX), obj.prevWP + fix(obj.windowSize / 2));
            
            % TORQUE CONTROL
            if obj.useGGV
                velError = obj.kp * (obj.ggvVels(obj.nextWP) - carSpeed);
%                 disp(velError);
            else
                velError = obj.kp * (obj.targetVel - carSpeed);
            end
%             if deltaTime > 0
%                 dError = obj.kd * (velError - obj.prevError) / deltaTime;
%             else
%                 dError = 0;
%             end
%             obj.prevError = velError;
            
            torquef = (velError) * 300;
            torquer = torquef * 1.6; 
            
            if velError < 0
                brake = max(-velError - 0.5, 0) / 3;
            else
                brake = 0;
            end
            
            torquer = max(torquer, 0);
            torquef = max(torquef, 0);
            brake = min(brake, 1);
            
%             disp(dError);
%             disp([obj.ggvVels(obj.nextWP); carSpeed; velError; torquef; brake]);

%             disp(obj.ggvVels(obj.nextWP));
            
            pfdot = carState.w(1);
            prdot = carState.w(3);

            if obj.powerLimit
                availablePower = car.accumulator.maxPower - ...
                                 car.params.estimatedMocLosses;

                [~, ~, powerRR, ~, ~, ~] =  ...
                    car.motors{3}.compute({}, torquer, prdot);
                [~, ~, powerRL, ~, ~, ~] =  ...
                    car.motors{4}.compute({}, torquer, prdot);
                powerr = max(powerRR, powerRL);
                
                if powerr * 2 > availablePower
                    powerr = availablePower / 2;
                    disp('powerlimit');
                    torquer = min(torquer, powerr / prdot);
                end
                
                availablePower = availablePower - 2 * powerr;
                
                powerf = (availablePower) / 2;
                torquef = min(torquef, powerf / pfdot);
            end

            control =  [steer, brake, torquef, torquef, torquer, torquer];
            disp(toc);
        end
    end
end
