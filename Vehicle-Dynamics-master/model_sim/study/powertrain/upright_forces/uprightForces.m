car = Rev6Full();
car.init('weightTransfer', 'numerical', 'useWheelVelocity', false);

%vs = linspace(1, 35, 36);
vs = [15];
%bodySAs = quadspace(0, pi/2, 50);
bodySAs = linspace(-0.1, 0.1, 50);
steers = linspace(-0.25, 0.25, 30);

doSweeps = true;

sweepAccel = true;
sweepBrake = true;
sweepNeutral = true;

if doSweeps
    if sweepAccel
        accelStatedots = {{{}}};
        accelDebugs = {{{}}};
    end
    
    if sweepBrake
        brakeStatedots = {{{}}};
        brakeDebugs = {{{}}};
    end
    
    if sweepNeutral
        neutralStatedots = {{{}}};
        neutralDebugs = {{{}}};
    end

    for i = 1 : length(vs)
        disp(i);
        v = vs(i);
        w = (v / car.params.radius) * ones(1, 4);
        

        brakeStyle = struct('fbTransferCoef', 0, 'lrTransferCoef', 0);
        brakeTm = @(steer) torqueMap(steer, 0, brakeStyle, car, w);
        
        %driveStyle = struct('fbTransferCoef', 0.25, ...
            %'lrTransferCoef', 3.2, 'startPower', 1, 'powerUsage', 1, 'brakeUsage', 1);
        driveStyle = struct('fbTransferCoef', 0, ...
            'lrTransferCoef', 0, 'startPower', 1, 'powerUsage', 1, 'brakeUsage', 1);
        accelTm = @(steer) torqueMap(steer, 1, driveStyle, car, w);
        
        for j = 1 : length(bodySAs) 
            bodySA = bodySAs(j);

            for k = 1 : length(steers) 
                steer = steers(k);
                carState = struct('x', 0, 'xdot', v, 'y', 0, 'ydot', 0, ...
                          'h', bodySA, 'hdot', 0, 'w', w);
                accumulatorState = struct('energyDelivered', 0, 'energyRegened', 0);
                state = {carState, {}, {}, {}, {}, {}, {}, {}, {}, accumulatorState};

                % Accel
                if sweepAccel
                    control.steer = steer;
                    control.brake = 0;

                    control.inputTorques = accelTm(steer);

                    [accelStatedot, accelDebug] = car.dynamics(...
                        car.stateCollector.pack(state), ...
                        car.controlDescriptor.pack(control));

                    statedot = car.stateCollector.unpack(accelStatedot);
                    accelStatedots{i, j, k} = statedot{1};
                    accelDebugs{i, j, k} = accelDebug;
                end

                % Decel
                if sweepBrake
                    control.steer = steer;
                    control.brake = 1;

                    control.inputTorques = brakeTm(steer);

                    [brakeStatedot, brakeDebug] = car.dynamics(...
                        car.stateCollector.pack(state), ...
                        car.controlDescriptor.pack(control));

                    statedot = car.stateCollector.unpack(brakeStatedot);
                    brakeStatedots{i, j, k} = statedot{1};
                    brakeDebugs{i, j, k} = brakeDebug;
                end

                % Neutral
                if sweepNeutral
                    control.steer = steer;
                    control.brake = 0;

                    control.inputTorques = brakeTm(steer);

                    [neutralStatedot, neutralDebug] = car.dynamics(...
                        car.stateCollector.pack(state), ...
                        car.controlDescriptor.pack(control));

                    statedot = car.stateCollector.unpack(neutralStatedot);
                    neutralStatedots{i, j, k} = statedot{1};
                    neutralDebugs{i, j, k} = neutralDebug;
                end
            end
        end
    end
end

results.vs = vs;
results.bodySAs = bodySAs;
results.steers = steers;
results.brakeStatedots = brakeStatedots;
results.accelStatedots = accelStatedots;
save('results', 'results');

makePlots = false;
if true
    figure
    hold on
    plotMMD(neutralStatedots, 1);
    plotMMD(brakeStatedots, 1);
    plotMMD(accelStatedots, 1);
end

if makePlots
    yddots = parseField(accelStatedots, 'ydot');
    hddots = parseField(accelStatedots, 'hdot');
    xdots = parseField(accelStatedots, 'x');
    
    field = 'fxsT';
    index = 1;
    val = parseField(accelDebugs, field, index);

    figure
    scatter3(yddots(:), hddots(:), xdots(:), 10, val(:));
    
    xlabel('yddot');
    ylabel('hddot');
    zlabel('V');

    title(strcat(field, ': ', num2str(index)));

    colorbar
end

computeMax = true;
if computeMax
    tires = {'FL', 'FR', 'RR', 'RL'};
    for t = 1 : 4
        extremes.accel.(tires{t}).maxFxT = ...
            getExtremeEntry(accelStatedots, accelDebugs, 'fxsT', t, true);
        extremes.accel.(tires{t}).maxFxB = ...
            getExtremeEntry(accelStatedots, accelDebugs, 'fxsB', t, true);
        extremes.accel.(tires{t}).maxFyT = ...
            getExtremeEntry(accelStatedots, accelDebugs, 'fysT', t, true);
        extremes.accel.(tires{t}).maxFyB = ...
            getExtremeEntry(accelStatedots, accelDebugs, 'fysB', t, true);

        extremes.accel.(tires{t}).minFxT = ...
            getExtremeEntry(accelStatedots, accelDebugs, 'fxsT', t, false);
        extremes.accel.(tires{t}).minFxB = ...
            getExtremeEntry(accelStatedots, accelDebugs, 'fxsB', t, false);
        extremes.accel.(tires{t}).minFyT = ...
            getExtremeEntry(accelStatedots, accelDebugs, 'fysT', t, false);
        extremes.accel.(tires{t}).minFyB = ...
            getExtremeEntry(accelStatedots, accelDebugs, 'fysB', t, false);

        extremes.accel.(tires{t}).Fz = ...
            getExtremeEntry(accelStatedots, accelDebugs, 'fzs', t, true);
        extremes.accel.(tires{t}).SumT = ...
            getExtremeEntrySum(accelStatedots, accelDebugs, ...
                {'fxsT', 'fysT', 'fzs'}, t);
        extremes.accel.(tires{t}).SumB = ...
            getExtremeEntrySum(accelStatedots, accelDebugs, ...
                {'fxsB', 'fysB', 'fzs'}, t);

        extremes.brake.(tires{t}).maxFxT = ...
            getExtremeEntry(brakeStatedots, brakeDebugs, 'fxsT', t, true);
        extremes.brake.(tires{t}).maxFxB = ...
            getExtremeEntry(brakeStatedots, brakeDebugs, 'fxsB', t, true);
        extremes.brake.(tires{t}).maxFyT = ...
            getExtremeEntry(brakeStatedots, brakeDebugs, 'fysT', t, true);
        extremes.brake.(tires{t}).maxFyB = ...
            getExtremeEntry(brakeStatedots, brakeDebugs, 'fysB', t, true);

        extremes.brake.(tires{t}).minFxT = ...
            getExtremeEntry(brakeStatedots, brakeDebugs, 'fxsT', t, false);
        extremes.brake.(tires{t}).minFxB = ...
            getExtremeEntry(brakeStatedots, brakeDebugs, 'fxsB', t, false);
        extremes.brake.(tires{t}).minFyT = ...
            getExtremeEntry(brakeStatedots, brakeDebugs, 'fysT', t, false);
        extremes.brake.(tires{t}).minFyB = ...
            getExtremeEntry(brakeStatedots, brakeDebugs, 'fysB', t, false);

        extremes.brake.(tires{t}).Fz = ...
            getExtremeEntry(brakeStatedots, brakeDebugs, 'fzs', t, true);
        extremes.brake.(tires{t}).SumT = ...
            getExtremeEntrySum(brakeStatedots, brakeDebugs, ...
                {'fxsT', 'fysT', 'fzs'}, t);
        extremes.brake.(tires{t}).SumB = ...
            getExtremeEntrySum(brakeStatedots, brakeDebugs, ...
                {'fxsB', 'fysB', 'fzs'}, t);
    end
end

% Print extremes:
disp('Prints tire forces under various conditions');
disp('Sweeping body SA from 0 to -90 degrees, steer from -0.25 radians to 0.25 radians');
disp('Order: front left, front right, rear right, rear left');

tires = {'FL', 'FR', 'RR', 'RL'};
for t = 1 : 4
    fprintf('\n');
    fprintf('\n');
    fprintf('=========> ANALYZING TIRE: %s <=========\n', tires{t});

    fprintf('\n');
    disp('====> ACCEL');
    disp('-- Max sum (tire frame)');
    printEntry(extremes.accel.(tires{t}).SumT);
    disp('-- Max long (tire frame)');
    printEntry(extremes.accel.(tires{t}).maxFxT);
    disp('-- Min long (tire frame)');
    printEntry(extremes.accel.(tires{t}).minFxT);
    disp('-- Max lat (tire frame)');
    printEntry(extremes.accel.(tires{t}).maxFyT);
    disp('-- Min lat (tire frame)');
    printEntry(extremes.accel.(tires{t}).minFyT);

    disp('-- Max sum (body frame)');
    printEntry(extremes.accel.(tires{t}).SumB);
    disp('-- Max long (body frame)');
    printEntry(extremes.accel.(tires{t}).maxFxB);
    disp('-- Min long (body frame)');
    printEntry(extremes.accel.(tires{t}).minFxB);
    disp('-- Max lat (body frame)');
    printEntry(extremes.accel.(tires{t}).maxFyB);
    disp('-- Min lat (body frame)');
    printEntry(extremes.accel.(tires{t}).minFyB);

    disp('-- Max z');
    printEntry(extremes.accel.(tires{t}).Fz);

    fprintf('\n');
    disp('====> BRAKE');
    disp('-- Max sum (tire frame)');
    printEntry(extremes.brake.(tires{t}).SumT);
    disp('-- Max long (tire frame)');
    printEntry(extremes.brake.(tires{t}).maxFxT);
    disp('-- Min long (tire frame)');
    printEntry(extremes.brake.(tires{t}).minFxT);
    disp('-- Max lat (tire frame)');
    printEntry(extremes.brake.(tires{t}).maxFyT);
    disp('-- Min lat (tire frame)');
    printEntry(extremes.brake.(tires{t}).minFyT);

    disp('-- Max sum (body frame)');
    printEntry(extremes.brake.(tires{t}).SumB);
    disp('-- Max long (body frame)');
    printEntry(extremes.brake.(tires{t}).maxFxB);
    disp('-- Min long (body frame)');
    printEntry(extremes.brake.(tires{t}).minFxB);
    disp('-- Max lat (body frame)');
    printEntry(extremes.brake.(tires{t}).maxFyB);
    disp('-- Min lat (body frame)');
    printEntry(extremes.brake.(tires{t}).minFyB);

    disp('-- Max z');
    printEntry(extremes.brake.(tires{t}).Fz);
end

function printEntry(entry)
    fprintf('V: %f | body SA: %f | steer: %f\n', ...
        entry.statedot.x, entry.debug.carSA, entry.debug.steer);

    fprintf('Total Ax: %f | Ay: %f | Ah: %f\n', ...
        entry.debug.xddot, entry.debug.yddot, entry.statedot.hdot);

    fprintf('FxT: [%8.2f %8.2f %8.2f %8.2f]\n', entry.debug.fxsT(1), ...
             entry.debug.fxsT(2), entry.debug.fxsT(3), ...
             entry.debug.fxsT(4));
    fprintf('FxB: [%8.2f %8.2f %8.2f %8.2f]\n', entry.debug.fxsB(1), ...
             entry.debug.fxsB(2), entry.debug.fxsB(3), ...
             entry.debug.fxsB(4));

    fprintf('FyT: [%8.2f %8.2f %8.2f %8.2f]\n', entry.debug.fysT(1), ...
             entry.debug.fysT(2), entry.debug.fysT(3), ...
             entry.debug.fysT(4));
    fprintf('FyB: [%8.2f %8.2f %8.2f %8.2f]\n', entry.debug.fysB(1), ...
             entry.debug.fysB(2), entry.debug.fysB(3), ...
             entry.debug.fysB(4));

    fprintf('Fz:  [%8.2f %8.2f %8.2f %8.2f]\n', entry.debug.fzs(1), ...
             entry.debug.fzs(2), entry.debug.fzs(3), ...
             entry.debug.fzs(4));
end

function entry = getExtremeEntry(statedots, debugs, fieldName, fieldIndex, getMax)
    values = parseField(debugs, fieldName, fieldIndex);
    if ~getMax
        values = -values;
    end

    maximum = max(values(:));
    [i,j,k] = ind2sub(size(values), find(values==maximum));
    
    entry.statedot = statedots{i,j,k};
    entry.debug = debugs{i,j,k};
end

function entry = getExtremeEntrySum(statedots, debugs, fieldNames, fieldIndex)
    fSum = zeros(size(statedots));
    for i = 1:length(fieldNames)
        f = parseField(debugs, fieldNames{i}, fieldIndex);
        fSum = fSum + abs(f);
    end

    maximum = max(fSum(:));
    [i,j,k] = ind2sub(size(fSum), find(fSum==maximum));
    
    entry.statedot = statedots{i,j,k};
    entry.debug = debugs{i,j,k};
end
