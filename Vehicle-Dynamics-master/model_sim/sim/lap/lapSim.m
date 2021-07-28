function [simOut, longVel, longAccel] = lapSim(varargin)
    p = inputParser;
    p.addRequired('ggv');
    p.addRequired('track');
    p.addOptional('startVel', 1.001);
    p.addOptional('endVel', inf);
    % Makes sure end velocity doesn't exceed max curvature of next lap start
    p.addOptional('loop', false);
    % Adds empiral adjustment per slalom, expects "slaloms" property on track
    p.addOptional('addSlalomLoss', true);
    p.addOptional('plotProfile', false);
    p.addOptional('accelZone', 0.3);
    p.addOptional('car', Rev6Full());
    p.parse(varargin{:});

    assert(p.Results.startVel > 1, 'Starting velocity must be atleast 1');

    ggv = p.Results.ggv;
    track = p.Results.track;
    car = p.Results.car;
    car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
    cp = car.params;

    % Based on Queens lapsim paper (see resources)
    sectorLength = 1;
    ggvSafetyFactor = 0.95; % Avoid interpolation putting us outside the ggv boundary

    [xs, ys, dists, curvatures, straightDists] = createSectors(track.distances, track.radii, sectorLength);
    numSectors = length(xs);

    % GET MAX CORNER CURVATURE LIMITS FOR EACH SPEED
    % Can't include 0 because ggv diagram doesn't go that far
    cornerVs = 1 : 1 : ggv.maxLongVelocity;
    cornerVs(1) = 1.001;
    for i = 1:length(cornerVs)
        v = cornerVs(i);
        ggvPoint = ggv.latAccelLookup(v, 0);
        maxCurvatures(i) = ggvPoint.yddot / v^2;
    end
    
    % GET MAX CORNER VELOCITY GIVEN TRACK CURVATURE
    maxCornerVel = @(curvature) ...
        interp1(maxCurvatures, cornerVs, curvature, 'linear');
    
    startVel = min(p.Results.startVel, maxCornerVel(abs(curvatures(1))) * ggvSafetyFactor);

    % GET ACCELERATION VELOCITIES
    accelVs(1) = startVel; % v_0
    
    startLatAccel = curvatures(1) * accelVs(1)^2; % a = v^2 / r
    accelGGVPoints(1) = ggv.longAccelLookup(accelVs(1), startLatAccel); % starting ggv point
    
    % THIS WAS MADE AT 4AM SO ITS SCUFFED AS HELL, WILL REFACTOR LATER
    straightIdx = 1;
    i = 2;
    while i <= numSectors
        if abs(curvatures(i - 1)) < 1/10000
            % Edge case
            if i - 1 == 1
                numPoints = straightDists(straightIdx);
            else
                numPoints = straightDists(straightIdx) - 1;
            end
            straightIdx = straightIdx + 1;
            accelNumPoints = floor(numPoints * p.Results.accelZone);
            coastNumPoints = numPoints - accelNumPoints;
            % Accel Zone
            for j = i : min(i + accelNumPoints - 1, numSectors) % hacky way to do this
                v = accelVs(end);
                latAccel = curvatures(j - 1) * v^2;
                ggvPoint = ggv.longAccelLookup(v, latAccel);
                longAccel = ggvPoint.xddot;
                vn = sqrt(v^2 + 2 * longAccel * (dists(j) - dists(j-1)));
                vn = min(vn, ggv.maxLongVelocity);
                [vn, minIndex] = min([vn, maxCornerVel(abs(curvatures(j))) * ggvSafetyFactor]);
                if j == numSectors && p.Results.loop
                    [vn, minIndex] = min([vn, maxCornerVel(abs(curvatures(1))) * ggvSafetyFactor]);
                end
                accelVs(end + 1) = vn;
                if minIndex == 1
                    accelGGVPoints(end + 1) = ggvPoint;
                else
                    longAccel = (vn^2 - v^2) / (2 * (dists(j) - dists(j-1)));
                    accelGGVPoints(end + 1) = ggv.pointLookup(vn, longAccel, latAccel);
                end
                assert(accelGGVPoints(end).powerDelivered < 90000);
            end
            i = i + accelNumPoints;
            
            % Coast Zone
            for k = i : min(i + coastNumPoints - 1, numSectors)
                v = accelVs(end);
                fwxB = -0.5 * cp.airDensity * cp.frontalArea * cp.dragCoef * v^2;
                longAccel = fwxB / cp.mass;
                ggvPoint = ggv.latAccelLookup(v, longAccel);
                latAccel = ggvPoint.yddot;
                % CZ: Add drag and tire friction effects later
                vn = sqrt(v^2 + 2 * longAccel * (dists(k) - dists(k-1)));
                vn = min(vn, ggv.maxLongVelocity);
                if k >= numSectors && p.Results.loop
                    [vn, minIndex] = min([vn, maxCornerVel(abs(curvatures(1))) * ggvSafetyFactor]);
                else
                    [vn, minIndex] = min([vn, maxCornerVel(abs(curvatures(k))) * ggvSafetyFactor]);
                end
                accelVs(end + 1) = vn;
                if minIndex == 1
                    accelGGVPoints(end + 1) = ggvPoint;
                else
                    longAccel = (vn^2 - v^2) / (2 * (dists(k) - dists(k-1)));
                    accelGGVPoints(end + 1) = ggv.pointLookup(vn, longAccel, latAccel);
                end
                assert(accelGGVPoints(end).powerDelivered < 90000);
            end
            i = i + coastNumPoints;  
        else
            v = accelVs(end);
        
            latAccel = curvatures(i - 1) * v^2; 
            ggvPoint = ggv.longAccelLookup(v, latAccel);
            longAccel = ggvPoint.xddot;

            % v_n^2 = v_0^2 + 2ad
            vn = sqrt(v^2 + 2 * longAccel * (dists(i) - dists(i-1)));
            vn = min(vn, ggv.maxLongVelocity);

            % Check if vn limited by max safe corner velocity
            [vn, minIndex] = min([vn, maxCornerVel(abs(curvatures(i))) * ggvSafetyFactor]);

            if i == numSectors && p.Results.loop
                [vn, minIndex] = min([vn, maxCornerVel(abs(curvatures(1))) * ggvSafetyFactor]);
            end

            accelVs(end + 1) = vn;

            if minIndex == 1 % if vn was not limited
                accelGGVPoints(end + 1) = ggvPoint;
            else
                longAccel = (vn^2 - v^2) / (2 * (dists(i) - dists(i-1)));
                accelGGVPoints(end + 1) = ggv.pointLookup(vn, longAccel, latAccel);
            end
            assert(accelGGVPoints(end).powerDelivered < 90000);
            i = i + 1;
        end
    end
    assert(length(accelGGVPoints) == numSectors);
    

    % GET BRAKE VELOCITIES (REVERSE RUN VELOCITIES)
    brakeVs = zeros(size(accelVs));
    brakeVs(end) = min([accelVs(end), p.Results.endVel, maxCornerVel(abs(curvatures(end)))]);

    endLatAccel = curvatures(end) * brakeVs(end)^2;
    brakeGGVPoints(length(brakeVs)) = ggv.longBrakeLookup(brakeVs(end), endLatAccel);

    for i = numSectors - 1 : -1 : 1
        v = brakeVs(i + 1);
        
        latAccel = curvatures(i + 1) * v^2;
        ggvPoint = ggv.longBrakeLookup(v, latAccel);
        longBrakeAccel = -ggvPoint.xddot;

        vn = sqrt(v^2 + 2 * longBrakeAccel * (dists(i + 1) - dists(i)));
        vn = min(vn, ggv.maxLongVelocity);
        [vn, minIndex] = min([vn, accelVs(i), maxCornerVel(abs(curvatures(i))) * ggvSafetyFactor]);

        brakeVs(i) = vn;
        
        if minIndex == 1
            brakeGGVPoints(i) = ggvPoint;
        else
            longAccel = (v^2 - vn^2) / (2 * (dists(i + 1) - dists(i)));
            brakeGGVPoints(i) = ggv.pointLookup(vn, longAccel, latAccel);
        end
    end
    
    % SMOOTH
    windowSize = 20;
    if p.Results.loop
        brakeVs = [brakeVs, ones(1, floor(windowSize / 2)) * maxCornerVel(abs(curvatures(1))) * ggvSafetyFactor];
    end
    brakeVs = smoothdata(brakeVs, 'gaussian', windowSize);
    accelGGVPoints = brakeGGVPoints;

    for i = 2 : numSectors
        v = brakeVs(i-1);
        latAccel = curvatures(i - 1) * v^2; 
        longAccel = (brakeVs(i)^2 - v^2) / (2 * (dists(i) - dists(i-1)));
        accelGGVPoints(i) = ggv.pointLookup(brakeVs(i), longAccel, latAccel);
    end

%     [~, k] = min([accelVs; brakeVs], [], 1);

    % Hack to fix single erronous braking-to-cornering issues
%     i = 2;
%     while i < length(k) - 1
%         if k(i) == 2 && k(i+1) == 1
%             k(i+1) = 2;
%             i = i + 1;
%         end
% 
%         if k(i) == 1 && k(i+1) == 2
%             k(i) = 2;
%         end
%         i = i + 1;
%     end
    
    % Assign ggvPoints to struct
%     ggvPoints(k == 1) = accelGGVPoints(k == 1);
%     ggvPoints(k == 2) = brakeGGVPoints(k == 2);

    ggvPoints = accelGGVPoints;
    
    % Add metadata to ggvPoints
    ggvPoints(1).energyDelivered = 0;
    ggvPoints(1).t = 0;
    ggvPoints(1).x = xs(1);
    ggvPoints(1).y = ys(1);
    ggvPoints(1).dist = dists(1);
    ggvPoints(1).curvature = curvatures(1);

    accelTime = 0;
    brakeTime = 0;

    % LAPTIME
    for i = 2 : length(ggvPoints)
        ggvPoints(i).x = xs(i);
        ggvPoints(i).y = ys(i);

        ggvPoints(i).dist = dists(i);
        ggvPoints(i).curvature = curvatures(i);
        dt = 2 * (ggvPoints(i).dist - ggvPoints(i-1).dist) ...
               / (ggvPoints(i).xdot + ggvPoints(i-1).xdot); % d / avg(v)
        ggvPoints(i).t = ggvPoints(i-1).t + dt;
        ggvPoints(i).energyDelivered = ggvPoints(i-1).energyDelivered ...
            + dt * ggvPoints(i).powerDelivered;
        ggvPoints(i).energyRegened = ggvPoints(i-1).energyRegened ...
            + dt * ggvPoints(i).energyRegened;

        if ggvPoints(i).brake > 0
            brakeTime = brakeTime + dt;
        else
            accelTime = accelTime + dt;
        end
    end

    longVel = [];
    longAccel = [];
%     longVelReverse = [];
%     longAccelReverse = [];
    
    % These are more aptly named as longVel / latVel etc
    for i = 1 : length(ggvPoints)
        ggvPoints(i).longVel = ggvPoints(i).xdot;
        ggvPoints(i).latVel = ggvPoints(i).ydot;
        ggvPoints(i).longAccel = ggvPoints(i).xddot;
        ggvPoints(i).latAccel = ggvPoints(i).yddot;
        
        longVel = [longVel, ggvPoints(i).longVel];
        longAccel = [longAccel, ggvPoints(i).longAccel];
%         longVel = [longVel, accelGGVPoints(i).xdot];
%         longVelReverse = [longVelReverse, brakeGGVPoints(i).xdot];
%         longAccel = [longAccel, accelGGVPoints(i).xddot];
%         longAccelReverse = [longAccelReverse, brakeGGVPoints(i).xddot];
    end
    ggvPoints = rmfield(ggvPoints, {'xdot', 'ydot', 'xddot', 'yddot'});
    
    simOut.runData = structArrayToVecStruct(ggvPoints);
    simOut.ggv = ggv;
    simOut.stats.finishTime = max([ggvPoints.t]);
    simOut.stats.energyDelivered = max([ggvPoints.energyDelivered]);
    simOut.stats.energyRegened = max([ggvPoints.energyRegened]);
    simOut.stats.accelTime = accelTime;
    simOut.stats.brakeTime = brakeTime;

    if p.Results.addSlalomLoss
        simOut.stats.slalomTimeLoss = track.numslaloms * ...
            ggv.car.params.slalomLoss(ggv.car.params.I);
        simOut.stats.finishTime = simOut.stats.finishTime + ...
            simOut.stats.slalomTimeLoss;
    end
    
    % Plot profile
    if p.Results.plotProfile
        figure;
        scatter3(xs, ys, longVel, [], longVel);
        hold on;
        plot3(xs, ys, zeros(size(xs)));
        hold off;
        title('Long. Velocity Smoothed Lift & Coast');
        caxis([0, 30]);
        colorbar;
        
        figure;
        scatter3(xs, ys, longAccel, [], longAccel);
        hold on;
        plot3(xs, ys, zeros(size(xs)));
        hold off;
        title('Long. Accel Smoothed Lift & Coast');
        caxis([-15, 15]);
        colorbar;
        
%         figure;
%         scatter3(xs, ys, longVelReverse, [], longVelReverse);
%         hold on;
%         plot3(xs, ys, zeros(size(xs)));
%         hold off;
%         title('Long. Velocity Reverse');
%         caxis([0, 30]);
%         colorbar;
%                 
%         figure;
%         scatter3(xs, ys, longAccelReverse, [], longAccelReverse);
%         hold on;
%         plot3(xs, ys, zeros(size(xs)));
%         hold off;
%         title('Long. Accel Reverse');
%         caxis([-15, 15]);
%         colorbar;
    end
    
end
