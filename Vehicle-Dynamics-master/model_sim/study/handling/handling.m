% clear

speed = 10;

carNew = Rev6Full();
carNew.motors = {ParametricMotor.GVK142_025L6(), ParametricMotor.GVK142_025L6(), ...
                      ParametricMotor.GVK142_050L6(), ParametricMotor.GVK142_050L6()};
carNew.setPowerTrainMasses(0.725, 0.725, 10);
carOld = Rev6Full();
% carOld.tires = {MFGuiTireFull.hoosier16R25B(true, true, true), ...
%                      MFGuiTireFull.hoosier16R25B(true, true, true), ...
%                      MFGuiTireFull.hoosier16R25B(true, true, true), ...
%                      MFGuiTireFull.hoosier16R25B(true, true, true)};
cars = [carNew];
simOuts = {};
accelTrack = readTrack('accel');
twohTrack = readTrack('200m');
slalomTrack = readTrack('slalom');
skidpadTrack = readTrack('lincoln_skidpad_2019');
enduranceTrack = readTrack('lincoln_endurance_2019');
straightTrack = readTrack('endurance_straight');
constantRadiusTrack = readTrack('constant_radius');

for i = 1:length(cars)
    car = cars(i);
%     car.init('weightTransfer', 'numeric', 'useWheelVelocity', false);
    

%     ggv = createGGV(car, 'display', true);
    car.init('weightTransfer', 'numeric', 'useWheelVelocity', true);
%     trackVis(straightTrack, []);
    figure;
    
%     controller = FullSlalomController(speed, 0.5, 1/1.57, 0, 0);
%     simOut = fullSim('car', car, 'controller', controller, ...
%                      'time', 4.5, 'xstop', inf, 'v0', speed, 'display', true);
    
%     controller = FullPathController(car, 10, straightTrack, true, true, ggv);
%     simOut = fullSim('car', car, 'controller', controller, ...
%                      'time', 5, 'xstop', 200, 'v0', 10, 'display', true);


    % CZ: for 75m accel
%     controller = FullAccelController(car, accelTrack, true);
    controller = OldAccelController(car, true);
    simOut = fullSim('car', car, 'controller', controller, ...
                     'time', 7, 'xstop', 75, 'v0', 0.01, 'display', true);
    
    simOuts{i} = simOut;
end
% simOutOld = simOuts{1};
simOutNew = simOuts{1};
handlingVis(simOuts{1}, simOuts{2}, []);
% handlingVis(simOuts{1}, [], []);


