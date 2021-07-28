function ggV = createGGVDiagram()

    ggV = [];

    maxSpeed = 50; %m/s
    cl = 2.4;
    cd = 1.3;
    rho = 1.223; %kg/m^3
    A = 1; %m^2
    mass = 250; %kg
    gravity = 9.8; %m/s^2
    cof = 1.3;
    %TODO: eventually calculate until longitudinal accel = 0
    %loop over every speed
    weightOnDrivenWheels = .65;
    gearRatio = 10;
    wheelRadius = .23; %m
    
    [speeds, lateralAccelerations] = meshgrid(0:.25:40, -50:.03:50);
    
    for i = 1:size(speeds, 2)
        
        %downforce is positive

        for j = 1:size(speeds, 1)
            
            %find wheel torque limited by motor
             speed = speeds(j, i);
             wheelSpeed = speed/wheelRadius;
             motorSpeed = gearRatio*wheelSpeed;
             out = emrax207(motorSpeed);
             motorTorque = out(4);
             wheelMotorTorqueLimit = motorTorque*gearRatio;
             wheelMotorForceLimit = wheelMotorTorqueLimit/wheelRadius;
             
             lateralAccel = lateralAccelerations(j, i);
            downforce = 0.5*A*rho*cl*speed^2;
            drag = 0.5*A*rho*cd*speed^2;
            
            %if achieveable, calculate max longitudinal accel
            
            %point mass approach
            normalLoad = mass*gravity + downforce; %car gives positive normal los
            lateralForce = mass*lateralAccel;
            %if requested lateral acceleration greater than limites of car,
            %return nan
            if (abs(normalLoad*cof) > abs(lateralForce) )
                
               %maxMotorForce
                
                maxTractiveForwardForce = sqrt( (normalLoad*cof)^2 - lateralForce^2)*weightOnDrivenWheels;
                maxTractiveBrakingForce = -sqrt( (normalLoad*cof)^2 - lateralForce^2);
                
                maxForwardForce = min([wheelMotorForceLimit, maxTractiveForwardForce]);
                
                %to do, find motor losses based on this motor torque
                motorTorque = maxForwardForce*wheelRadius/gearRatio;
                satModelOut = emrax207_sat(motorTorque, motorSpeed);
                
                maxForwardAccel = (maxForwardForce - drag)/mass;
                maxBrakingAccel = (maxTractiveBrakingForce - drag)/mass;
                
                positiveLongAccel(j, i) = maxForwardAccel;
                negativeLongAccel(j, i) = maxBrakingAccel;
                powerUsed(j, i) = satModelOut(3);
                powerLoss(j, i) = satModelOut(5);
                powerOut(j, i) = satModelOut(1);
                brakingPower(j, i) = speed*maxBrakingAccel*mass;
            else
                positiveLongAccel(j, i) = nan;
                negativeLongAccel(j, i) = nan;
                powerUsed(j, i) = 0;
                powerLoss(j, i) = 0;
                powerOut(j, i) = 0;
                brakingPower(j, i) = 0;
            end
             
        end
        
    end
    
    ggV.speeds = speeds;
    ggV.lateralAccelerations = lateralAccelerations;
    ggV.positiveLongAccel = positiveLongAccel;
    ggV.negativeLongAccel = negativeLongAccel;
    ggV.powerUsed = powerUsed;
    ggV.powerLoss = powerOut;
    ggV.brakingPower = brakingPower;
    ggV.powerOut = powerOut;
    
    figure
    hold on
    s1 = surf(lateralAccelerations/9.8, positiveLongAccel/9.8, speeds*2.237);
    s2 = surf(lateralAccelerations/9.8, negativeLongAccel/9.8, speeds*2.237);
    s1.EdgeColor = 'None';
    s2.EdgeColor = 'None';
    xlabel('Lateral Acceleration, gs')
    ylabel('Longitudinal Acceleration, gs')
    zlabel('Speed, mph')
    
    figure
    hold on
    s1 = surf(lateralAccelerations/9.8, powerLoss, speeds*2.237);
    s1.EdgeColor = 'None';
    s2.EdgeColor = 'None';
    xlabel('Lateral Acceleration, gs')
    ylabel('powerLoss, W')
    zlabel('Speed, mph')
    
     figure
    hold on
    s1 = surf(positiveLongAccel/9.8, powerLoss, speeds*2.237);
    s1.EdgeColor = 'None';
    s2.EdgeColor = 'None';
    xlabel('Long Acceleration, gs')
    ylabel('powerLoss, W')
    zlabel('Speed, mph')
    
end