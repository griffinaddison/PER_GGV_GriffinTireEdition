function [ggvPoints] = steerSweep(state, steers, brake, torqueMap, car)
    for i = 1:length(steers)
        steer = steers(i);
        
        control.steer = steer;
        control.brake = brake;

        control.inputTorques = torqueMap(steer);

        [statedot, debug] = car.dynamics(...
            car.stateCollector.pack(state), ...
            car.controlDescriptor.pack(control));

        statedot = car.stateCollector.unpack(statedot);
        % Include only car and accumulator statedots
        statedot = catstruct(statedot{1}, statedot{10});

        statedot.xddot = statedot.xdot;
        statedot.xdot = statedot.x;
        statedot = rmfield(statedot, 'x');

        statedot.yddot = statedot.ydot * car.params.latAccelFudge;
        statedot.ydot = statedot.y;
        statedot = rmfield(statedot, 'y');
        
        statedot.hddot = statedot.hdot;
        statedot.hdot = statedot.h;
        statedot = rmfield(statedot, 'h');
        
        % Right now this is just repetitive with power
        statedot = rmfield(statedot, 'energyDelivered');

        debug = rmfield(debug, 'xddot');
        debug = rmfield(debug, 'yddot');
        
        ggvPoints(i) = catstruct(statedot, debug);
    end
end

