classdef CarAnimator < Animator
    properties
        times
        dynamicVars
        carModel
        chassisPlot
        tirePlots
    end
    
    methods
        function obj = CarAnimator(simOut)
            obj.times = simOut.t;
            obj.dynamicVars = simOut.dynamicVars;
            obj.carModel = simOut.car;
        end
        
        function init(obj, fig)
            % Initialize the figure    
            figure(fig);
            clf;

            hold on;

            obj.chassisPlot = plot(0, 0);
            obj.tirePlots = [plot(0, 0), plot(0, 0), plot(0, 0), plot(0, 0)];
        end
        
        function render(obj, time, state)
            wheelPositionsB = obj.carModel.computeWheelPositionsB();

            % Declare shortcut variables
            ftx = wheelPositionsB(1, 1);
            rtx = wheelPositionsB(4, 1);
            %ftw = wheelPositionsB(1, 2);
            %rtw = wheelPositionsB(2, 2);
            ftw = obj.carModel.params.trackwidth;
            rtw = obj.carModel.params.trackwidth;

            % Plot the chassis
            chassisMat = [ftx, ftx, ftx, rtx, rtx, rtx;
                      -ftw/2, ftw/2, 0, 0, -rtw/2, rtw/2];
            center = repmat([0; 0], 1, 6);
            headingRot = rotMat2D(state.h);
            rotated = headingRot * (chassisMat - center) + center;
            obj.chassisPlot.XData = rotated(1, :) + state.x;
            obj.chassisPlot.YData = rotated(2, :) + state.y;
            obj.chassisPlot.Color = 'k';

            % Plot the tires
            tireMat = [-0.3, 0.3; 0 0];
            wheelAnglesB = obj.carModel.computeWheelAnglesB(state.steer);
            obj.plotTire(rotMat2D(wheelAnglesB(1)) * tireMat, ftx, ftw/2, headingRot, ...
                     state.x, state.y, obj.tirePlots(4));
            obj.plotTire(rotMat2D(wheelAnglesB(2)) * tireMat, ftx, -ftw/2, headingRot, ...
                     state.x, state.y, obj.tirePlots(3));
            obj.plotTire(rotMat2D(wheelAnglesB(3)) * tireMat, -ftx, -ftw/2, headingRot, ...
                     state.x, state.y, obj.tirePlots(1));
            obj.plotTire(rotMat2D(wheelAnglesB(4)) * tireMat, -ftx, ftw/2, headingRot, ...
                     state.x, state.y, obj.tirePlots(2));
            
            cameraWidth = 10;
            % Set the camera
            camArea = [state.x - cameraWidth, state.x + cameraWidth, ...
                       state.y - cameraWidth, state.y + cameraWidth];
            axis(obj.chassisPlot.Parent, camArea);
            % Make axes invisible 
            %set(obj.chassisPlot.Parent, 'visible', 'off');
            axis(obj.chassisPlot.Parent, 'square');
            set(obj.chassisPlot.Parent, 'position', [0.1 0.1 0.8 0.8], 'units', 'normalized');
            track = readTrack('endurance_straight');
            sectorLength = 1;
            [xs, ys, ~, ~] = createSectors(track.distances, track.radii, sectorLength);
            plot(xs, ys);
            grid on
        end
        
        function plotTire(~, tMat, xOff, yOff, headingRot, centerX, centerY, plot)
            transMat(1, :) = tMat(1, :) + xOff;
            transMat(2, :) = tMat(2, :) + yOff;
            rotated = headingRot * transMat;
            plot.XData = rotated(1, :) + centerX;
            plot.YData = rotated(2, :) + centerY;
            plot.Color = 'b';
        end
    end
end

