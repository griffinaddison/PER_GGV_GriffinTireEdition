function out = MMD(car, plotColor)
v = car.speed0;
hold on
i = 0;
%constant slip lines
%figure
global runCount
runCount = 0;
for b = linspace(-deg2rad(15), deg2rad(15), 31)
    for a = linspace(-deg2rad(20), deg2rad(20), 100)
        i = i+1;
        %[x, y, heading, v, bodySA, w, Fx, Fy, Tz]
        %control in -> [steer angle, drive, brake]
        Fy = 100; %first Fy guess
        guessFy = 100;
        goodGuess = 0;
        guessError = 0;
        j = 0;
        residuals = [];
        residualsw = [];
        learnRate = .25;
        state.wWheel = {v/car.wheelRad v/car.wheelRad v/car.wheelRad v/car.wheelRad};
        
        while(~goodGuess)
            guessFy = guessFy + guessError*learnRate;
            %state in-> [x, y, heading, v, bodySA, w, Fx, Fy, Tz]
            %control in -> [steer angle, drive, brake]
            state.speed = v;
            state.bodySA = b;
            state.w = (guessFy/car.m)/v;
            state.guessFy = guessFy;
            state.guessFx = 0;
            modelOut = carModel3(state, [a, 0, 0], car);
            wWheelLearnRate = .001;
            state.wWheel{1} = state.wWheel{1} + wWheelLearnRate* modelOut(4);
            state.wWheel{2} = state.wWheel{2} + wWheelLearnRate* modelOut(5);
            state.wWheel{3} = state.wWheel{3} + wWheelLearnRate* modelOut(6);
            state.wWheel{4} = state.wWheel{4} + wWheelLearnRate* modelOut(7);
            Fy = modelOut(2);
            guessError = Fy - guessFy;
            goodGuess = abs(guessError) < 5 && abs(modelOut(4)) < 1 && abs(modelOut(5)) < 1 && abs(modelOut(6)) < 1 && abs(modelOut(7)) < 1;
            j = j+1;
            if j > 2000
                learnRate = .0001;
            end
            if j>5000
                3
            end
            residualsw(j) = modelOut(4);
            %  residuals(j) = Fy - guessFy;
            % hold off
            %plot(residuals);
            % hold on
            % plot(residualsw);
            % drawnow
        end
        runCount = runCount+1;
        ay(i) = modelOut(2)/car.m;
        cn(i) = modelOut(3);
        
    end
    plot(ay, cn, 'Color', plotColor);
    ay = [];
    cn = [];
    i = 0;
end
%figure
ay = [];
cn = [];

i = 0;
%constant steer lines
runCount = 0;
for a = linspace(-deg2rad(15), deg2rad(15), 31)
    %for a = [deg2rad(10)]
    for b = linspace(-deg2rad(20), deg2rad(20), 100)
        i = i+1;
        %[x, y, heading, v, bodySA, w, Fx, Fy, Tz]
        %control in -> [steer angle, drive, brake]
        Fy = 100; %first Fy guess
        guessFy = 100;
        goodGuess = 0;
        guessError = 0;
        j = 0;
        residuals = [];
        learnRate = .25;
        state.wWheel = {v/car.wheelRad v/car.wheelRad v/car.wheelRad v/car.wheelRad};
        
        while(~goodGuess)
            guessFy = guessFy + guessError*learnRate;
            %state in-> [x, y, heading, v, bodySA, w, Fx, Fy, Tz]
            %control in -> [steer angle, drive, brake]
            state.speed = v;
            state.bodySA = b;
            state.w = (guessFy/car.m)/v;
            state.guessFy = guessFy;
            state.guessFx = 0;
            modelOut = carModel3(state, [a, 0, 0], car);
            wWheelLearnRate = .001;
            state.wWheel{1} = state.wWheel{1} + wWheelLearnRate* modelOut(4);
            state.wWheel{2} = state.wWheel{2} + wWheelLearnRate* modelOut(5);
            state.wWheel{3} = state.wWheel{3} + wWheelLearnRate* modelOut(6);
            state.wWheel{4} = state.wWheel{4} + wWheelLearnRate* modelOut(7);
            Fy = modelOut(2);
            guessError = Fy - guessFy;
            goodGuess = abs(guessError) < 5 && abs(modelOut(4)) < 1 && abs(modelOut(5)) < 1 && abs(modelOut(6)) < 1 && abs(modelOut(7)) < 1;
            j = j+1;
            if j > 2000
                learnRate = .0001;
            end
            if j>5000
                3
            end
            %residuals(j) = Fy - guessFy;
            %hold off
            %plot(residuals);
            %drawnow
        end
        runCount = runCount+1;
        ay(i) = modelOut(2)/car.m;
        cn(i) = modelOut(3);
    end
    plot(ay, cn, 'Color', plotColor);
    ay = [];
    cn = [];
    i = 0;
end

end