% Simulates a sinusoidal steering curve like in a slalom

speed = 15;

car = Rev5Full();
car.init('weightTransfer', 'numeric', 'useWheelVelocity', true);
controller = FullSineTestController(0.2, 0.8, 50);

simOut = fullSim('car', car, 'controller', controller, ...
                 'time', 5, 'xstop', inf, 'v0', speed);

fullVisSim(simOut);
