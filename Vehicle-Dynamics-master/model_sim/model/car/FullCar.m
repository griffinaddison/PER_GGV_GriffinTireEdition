classdef FullCar < CarModel
    properties
        fzSolver

        % The actual components being used, each cell array of 4
        % FL, FR, RR, RL
        tires
        motors

        accumulator
        
        % Possible alternative way of computing longitudinal forces
        % (e.g. don't use wheel velocity / slip ratio)
        tireForceFunction
        useWheelVelocity

        detailedDebugging % Outputs a bunch of individual output variables
    end

    
    methods
% *******************CONSTRUCTOR*******************************************
        function obj = FullCar(carParams, ...
                               tires, motors, accumulator)
            state = {'x', 1, 'xdot', 1, 'y', 1, 'ydot', 1, ...
                     'h', 1, 'hdot', 1, 'w', 4};
            control = {'steer', 1, 'brake', 1, 'inputTorques', 4};
            
            % Model only works if tires are stateless, therefore
            % only register the motor models with the parent class
            obj = obj@CarModel(carParams, ...
                               Descriptor(state), Descriptor(control), ...
                               [tires(:)', motors(:)', {accumulator}]);
            
            obj.tires = tires;
            obj.motors = motors;
            obj.accumulator = accumulator;
        end

% *******************GETS MAX OVERALL VELOCITY****************************
        function maxVel = getMaxVelocity(obj)
            % The max velocity given by motors
            maxVel = inf;
            for i = 1:4
                motor = obj.motors{i};
                maxVel = min(maxVel, motor.getMaxVelocity());
                
            end
            maxVel = maxVel * obj.params.radius;
        end

% ************COMPUTE WHEEL ANGLES RELATIVE TO CENTERLINE******************
        function [wheelAnglesB] = computeWheelAnglesB(obj, steer)
            cp = obj.params;
            % FL, FR, RR, RL
            % Equation: https://iopscience.iop.org/article/10.1088/1757-899X/393/1/012128/pdf
            wheelAnglesB = [steer - cp.frontToe + cp.ackerman * steer^2, ...
                            steer + cp.frontToe - cp.ackerman * steer^2, ...
                            cp.rearToe, -cp.rearToe];
        end 

% ********COMPUTES WHEEL POS IN BODY FRAME RELATIVE TO COM*****************
        function [wheelPositionsB] = computeWheelPositionsB(obj)
            cp = obj.params;
            % FL, FR, RR, RL
            wheelPositionsB = [cp.wheelbase * (1 - cp.comDistribution), cp.trackwidth / 2, 0;
                               cp.wheelbase * (1 - cp.comDistribution), -cp.trackwidth / 2, 0;
                               -cp.wheelbase * cp.comDistribution, -cp.trackwidth / 2, 0;
                               -cp.wheelbase * cp.comDistribution, cp.trackwidth / 2, 0];
        end
    end

    
    methods (Access=protected)
% *******************GENERAL INIT*******************************************
        function obj = doInit(obj, varargin)
            % weightTransfer: specify the solver mode. 'analytic' results in faster evaluations, but
            % requires nicely formulated tire / component dynamics. 'numeric' is slower but more flexible.
            % useWheelVelocity: if true, uses wheel velocity / slip ratio to generate longitudinal forces
            % (for full sim / response sim). Otherwise takes theoretical traction limit of tires
            % to limit drive / braking force
            p = inputParser;
            p.addOptional('weightTransfer', 'numeric');
            p.addOptional('useWheelVelocity', false);
            p.addOptional('detailedDebugging', false);
            p.parse(varargin{:});

            obj.useWheelVelocity = p.Results.useWheelVelocity;

            if strcmp(p.Results.weightTransfer, 'analytic') && ~p.Results.useWheelVelocity
                error(['Analytic model must use wheel velocity ', ...
                       '(long force capping is not analytically solvable)']);
            end

            for tire = obj.tires
                tire{1}.init()
            end
            
            if p.Results.useWheelVelocity
                obj.tireForceFunction = @calculateWheelSpeedTireForcesT;
            else
                obj.tireForceFunction = @calculateLimitTireForcesT;
            end

            if strcmp(p.Results.weightTransfer, 'analytic')
                obj.analyticInit();
            else
                obj.numericInit();
            end

            obj.detailedDebugging = p.Results.detailedDebugging;
        end
        
% *******************INIT FOR ANALYTIC WEIGHT TRANSFER**********************
        function analyticInit(obj)
            cp = obj.params;

            % Simplest set of state variables to describe dynamic evolution of car
            % WA = wheel angle, Fz = normal force, SA = slip angle, SR = slip ratio
            syms Fzfl Fzfr Fzrr Fzrl SAfl SAfr SArr SArl SRfl SRfr SRrr SRrl V WAfl WAfr WArr WArl 
            WABs = [WAfl WAfr WArr WArl];
            Fzs = [Fzfl Fzfr Fzrr Fzrl];
            SAs = [SAfl SAfr SArr SArl];
            SRs = [SRfl SRfr SRrr SRrl];
            
            [FwzB, FwxB] = obj.calculateAeroForcesB(V);
            [FxsT, FysT] = obj.tireForceFunction(obj, Fzs, SAs, SRs, [], wheelVelocitiesDirected);
            [FxsB, FysB] = obj.transformTireForces(FxsT, FysT, WABs, true);
            
            % Downforce is negative, so need to negate sign
            averageWeightF = (cp.mass * cp.gravity * cp.comDistribution - FwzB * cp.copDistribution) / 2;
            averageWeightR = (cp.mass * cp.gravity * (1 - cp.comDistribution) - FwzB * (1 - cp.copDistribution)) / 2;
        
            % RCVD 684
            deltaWeightX = (FxsB(1) + FxsB(2) + FxsB(3) + FxsB(4) + FwxB) * cp.height / (cp.wheelbase);
            
            % RCVD 683
            H = cp.height - cp.rollCenterHeightF;
            deltaWeightYF = (fysB(1) + fysB(2) + fysB(3) + fysB(4)) / cp.trackwidth ...
                            * (H * cp.rollRateF / (cp.rollRateF + cp.rollRateR) ...
                            + cp.comDistribution * cp.rollCenterHeightF);
            deltaWeightYR = (fysB(1) + fysB(2) + fysB(3) + fysB(4)) / cp.trackwidth ...
                            * (H * cp.rollRateR / (cp.rollRateF + cp.rollRateR) ...
                            + (1 - cp.comDistribution) * cp.rollCenterHeightR); 

            % CZ: Fixed Equation according to RCVD chapter 18 (/2 and h)
            dynamicsEqns = [Fzfl == averageWeightF - deltaWeightX - deltaWeightYF, ...
                            Fzfr == averageWeightF - deltaWeightX + deltaWeightYF, ...
                            Fzrr == averageWeightR + deltaWeightX + deltaWeightYR, ...
                            Fzrl == averageWeightR + deltaWeightX - deltaWeightYR, ...
                            2 * averageWeightF + 2 * averageWeightR == Fzfl + Fzfr + Fzrr + Fzrl];
            disp('solving symbolic...');
            fzSoln = solve(dynamicsEqns, [Fzfl, Fzfr, Fzrr, Fzrl]);
            disp('solved!');
            fzSolve = matlabFunction(fzSoln.Fzfl, fzSoln.Fzfr, fzSoln.Fzrr, fzSoln.Fzrl);
            obj.fzSolver = @(carState, control, sa1, sa2, sa3, sa4, sr1, sr2, sr3, sr4, V, ...
                             wa1, wa2, wa3, wa4, vx1, vx2, vx3, vx4) fzSolve(sa1, sa2, sa3, sa4, ...
                             sr1, sr2, sr3, sr4, V, wa1, wa2, wa3, wa4);
        end
        

% *******************INIT FOR NUMERIC WEIGHT TRANSFER**********************
        function numericInit(obj)
            obj.fzSolver = @(carState, control, sa1, sa2, sa3, sa4, sr1, sr2, sr3, sr4, V, ...
                             wa1, wa2, wa3, wa4, vx1, vx2, vx3, vx4) numericFzSolve(obj, carState, control, ...
                             [sa1 sa2 sa3 sa4], [sr1 sr2 sr3 sr4], V, [wa1 wa2 wa3 wa4], [vx1, vx2, vx3, vx4]);
        end

% *******************NUMERIC SOLVER FOR Fz*********************************
        function [fzfl, fzfr, fzrr, fzrl] = numericFzSolve(obj, ...
                carState, control, sas, srs, carSpeed, wheelAnglesB, wheelVelocitiesDirected)
            cp = obj.params;
            options = optimoptions('fsolve', 'Algorithm', 'levenberg-marquardt', 'Display', 'none');
            
            motorStates = {{}, {}, {}, {}};
            [~, motorTorques, brakeTorques, ~, ~] = ...
                obj.computeWheelDynamics(carState, motorStates, control.inputTorques, control.brake);
            fxsCommandedT = (motorTorques - brakeTorques) / cp.radius;

            fz0 = ones(1,4) * (cp.mass * cp.gravity / 4);
            fz = fsolve(@(fzs) fzResidual(obj, ...
                        sas, srs, fxsCommandedT, carSpeed, wheelAnglesB, wheelVelocitiesDirected, fzs), ...
                        fz0, options);

            t = num2cell(fz);
            [fzfl, fzfr, fzrr, fzrl] = deal(t{:});
        end
        
% *******************NUMERIC SYSTEM OF EQUATIONS****************************
        function residual = fzResidual(obj, sas, srs, fxsCommandedT, carSpeed, wheelAnglesB, ...
                wheelVelocitiesDirected, fzs)
            cp = obj.params;

            [fwzB, fwxB] = obj.calculateAeroForcesB(carSpeed);
            [fxsT, fysT] = obj.tireForceFunction(obj, fzs, sas, srs, fxsCommandedT, wheelVelocitiesDirected);
            [fxsB, fysB] = obj.transformTireForces(fxsT, fysT, wheelAnglesB, false);
            
            averageWeightF = (cp.mass * cp.gravity * cp.comDistribution - fwzB * cp.copDistribution) / 2;
            averageWeightR = (cp.mass * cp.gravity * (1 - cp.comDistribution) - fwzB * (1 - cp.copDistribution)) / 2;

            deltaWeightX = (fxsB(1) + fxsB(2) + fxsB(3) + fxsB(4) + fwxB) * cp.height / (cp.wheelbase);
            
            % RCVD 683
            H = cp.height - cp.rollCenterHeightF;
            deltaWeightYF = (fysB(1) + fysB(2) + fysB(3) + fysB(4)) / cp.trackwidth ...
                            * (H * cp.rollRateF / (cp.rollRateF + cp.rollRateR) ...
                            + cp.comDistribution * cp.rollCenterHeightF);
            deltaWeightYR = (fysB(1) + fysB(2) + fysB(3) + fysB(4)) / cp.trackwidth ...
                            * (H * cp.rollRateR / (cp.rollRateF + cp.rollRateR) ...
                            + (1 - cp.comDistribution) * cp.rollCenterHeightR);
              
%             % OLD WEIGHT TRANSFER
%             deltaWeightX = (fxsB(1) + fxsB(2) + fxsB(3) + fxsB(4) + fwxB) * cp.height / (cp.wheelbase);
%             deltaWeightYF = (fysB(1) + fysB(2) + fysB(3) + fysB(4)) * cp.height / (cp.trackwidth); 
%             deltaWeightYR = (fysB(1) + fysB(2) + fysB(3) + fysB(4)) * cp.height / (cp.trackwidth); 

            residual = [-fzs(1) + averageWeightF - deltaWeightX - deltaWeightYF, ...
                        -fzs(2) + averageWeightF - deltaWeightX + deltaWeightYF, ...
                        -fzs(3) + averageWeightR + deltaWeightX + deltaWeightYR, ...
                        -fzs(4) + averageWeightR + deltaWeightX - deltaWeightYR, ...
                        - 2 * averageWeightF - 2 * averageWeightR + fzs(1) + fzs(2) + fzs(3) + fzs(4)];
        end
        
% *******************THIS COMPUTES DYNAMICS********************************
        function [statedot, debug] = computeDynamics(obj, state, control)
            % T = individual tire frames, B = body frame, W = world frame
            % Tire frame: X forward, Y right, Z down
            % Body frame: X forward, Y left, Z up (opposite RCVD convention)
            % World frame: X forward, Y left, Z up

            carState = state{1};
            motorStates = state(2:5);
            tireStates = state(6:9);
            accumulatorState = state(10);

            cp = obj.params;

            % Car velocity angle in world frame
            carVelocityDirW = atan2(carState.ydot, carState.xdot);
            carSA = cleanAngle(carVelocityDirW - carState.h); % β in RCVD
%             fprintf('carSA: %d', carSA);
            carSpeed = sqrt(carState.xdot^2 + carState.ydot^2);
            % Car velocity in body frame
            carVelocityB = [cos(carSA) * carSpeed, sin(carSA) * carSpeed, 0];
            carAngularVelocityW = [0, 0, carState.hdot];

            steer = control.steer;
            brake = control.brake;
            inputTorques = control.inputTorques;

            % FL, FR, RR, RL
            % Wheel angles relative to body centerline
            wheelAnglesB = obj.computeWheelAnglesB(steer);
            % Wheel positions in body frame (relative to COM)
            wheelPositionsB = obj.computeWheelPositionsB();
            % Wheel translational velocities in body frame
            wheelVelocitiesB = cross(repmat(carAngularVelocityW,4,1), wheelPositionsB) ...
                                   + repmat(carVelocityB,4,1);
            % Wheel velocity angles in body frame
            wheelVelocityDirsB = atan2(wheelVelocitiesB(:,2), wheelVelocitiesB(:, 1)).';
            
            % For debugging calculate approximate wheel velocity
            if ~obj.useWheelVelocity
                carState.w = vecnorm(wheelVelocitiesB.') / cp.radius;
            end
            carState.w = max(carState.w, 0);
            
            % Slip angles
            sas = wheelVelocityDirsB - wheelAnglesB;
            
%             % CZ: Drift hack
%             if abs(sas(3)) > deg2rad(15) || abs(sas(4)) > deg2rad(15)
%                 brake = 0;
%                 inputTorques = ones(1, 4) * 20;
%             end
            
            % Longitudinal x component of wheel velocities
            wheelVelocitiesDirected = vecnorm(wheelVelocitiesB, 2, 2).' .* cos(sas);
%             disp([wheelVelocityDirsB; wheelAnglesB]);
%             assert(all(wheelVelocitiesDirected > 0), 'sas: %d %d %d %d', sas(1), sas(2), sas(3), sas(4));
            
            % Slip Ratios
            % CZ: should change to effective radius from test data (rev/mile)
            srs = carState.w * cp.radius ./ wheelVelocitiesDirected - 1;
            
            % Normal reaction force on each tire
            [fzfl, fzfr, fzrr, fzrl] = obj.fzSolver(carState, control, ...
                        sas(1), sas(2), sas(3), sas(4), ...
                        srs(1), srs(2), srs(3), srs(4), carSpeed, ...
                        wheelAnglesB(1), wheelAnglesB(2), wheelAnglesB(3), wheelAnglesB(4), ...
                        wheelVelocitiesDirected(1), wheelVelocitiesDirected(2), ...
                        wheelVelocitiesDirected(3), wheelVelocitiesDirected(4));
            fzs = [fzfl, fzfr, fzrr, fzrl];
            
            % Compute wheel dynamics
            [motorStatedots, motorTorques, brakeTorques, motorPowers, motorLosses] = ...
                obj.computeWheelDynamics(carState, motorStates, inputTorques, brake);
            
            % Gets raw motor torques (removes gearing effects)
            baseMotorTorques = zeros(1, 4);
            for i = 1:4
                motor = obj.motors{i};
                baseMotorTorques(i) = motor.getBaseTorque(motorTorques(i));
            end
            
            % TODO: combine this with torqueMap function
            mocLosses = sum(cp.mocLossCoef * (baseMotorTorques .^ 2));
            powerDelivered = sum(motorPowers + motorLosses) + mocLosses;
            accumulatorStatedot = obj.accumulator.compute(accumulatorState, powerDelivered, brake);

            % Commanded Traction
            % FxsTCommanded is just for case where not using wheel velocity
            fxsCommandedT = (motorTorques - brakeTorques) / cp.radius;
            [fxsT, fysT] = obj.tireForceFunction(obj, fzs, sas, srs, fxsCommandedT, wheelVelocitiesDirected);

            % Transform tire forces to body frame
            [fxsB, fysB] = obj.transformTireForces(fxsT, fysT, wheelAnglesB, false); 
            tireForcesB = [fxsB, fysB, zeros(4, 1)];
            
            wdot = (motorTorques - brakeTorques - cp.radius * fxsT) / cp.wheelI;
            [~, fwxB] = obj.calculateAeroForcesB(carSpeed);
            
            FSumB = sum(tireForcesB) + [fwxB, 0, 0];
            FSumW = rotMat3D(carState.h) * FSumB.';
            
            xddot = FSumW(1) / cp.mass;
            yddot = FSumW(2) / cp.mass;
            
            % CZ: Update Yaw moment to include understeer/oversteer effects
            yawMoment = sum(cross(wheelPositionsB, tireForcesB));
            yawMoment = yawMoment(3);

            carStatedot.x = carState.xdot;
            carStatedot.xdot = xddot;
            carStatedot.y = carState.ydot; 
            carStatedot.ydot = yddot;
            carStatedot.h = carState.hdot;
            carStatedot.hdot = yawMoment / cp.I;
            carStatedot.w = wdot;
            
%             disp(steer);
            
%             disp([carState.w; carStatedot.w]);
%             assert(all(carState.w >= 0), 'w: %d %d %d %d', carState.w(1), carState.w(2), carState.w(3), carState.w(4));
            
            % Tires must be stateless for this model
            statedot = [{carStatedot}, motorStatedots(:)', {{}}, {{}}, {{}}, {{}}, {accumulatorStatedot}];
            
            if obj.detailedDebugging
                motorTorqueFl = motorTorques(1);
                motorTorqueFr = motorTorques(2);
                motorTorqueBr = motorTorques(3);
                motorTorqueBl = motorTorques(4);

                wheelSpeedFl = carState.w(1);
                wheelSpeedFr = carState.w(2);
                wheelSpeedRr = carState.w(3);
                wheelSpeedRl = carState.w(4);
            end
            
            fxsB = fxsB.';
            fysB = fysB.';
            FSumW = FSumW.';
            debugVars = setdiff(who, ...
                 {'state', 'carState', 'motor', 'motorStates', 'tireStates', ...
                  'accumulatorState', ...
                  'statedot', 'carStatedot', 'motorStatedots', ...
                  'accumulatorStatedot', 'fxsCommandedT', ...
                  'wheelPositionsB', 'wheelVelocitiesB', ...
                  'frontBrakeTorque', 'rearBrakeTorque', ...
                  'tireForcesB', 'cp', 'control', 'obj', 'i'});

            for k = 1:length(debugVars)
                debug.(debugVars{k}) = eval(debugVars{k});
            end
        end

% *******************THIS COMPUTES WHEEL DYNAMICS********************************
        function [motorStatedots, motorTorques, brakeTorques, motorPowers, motorLosses] = ...
                computeWheelDynamics(obj, carState, motorStates, inputTorques, brake)
            cp = obj.params;

            motorStatedots = {};
            motorTorques = zeros(1, 4);
            motorPowers = zeros(1, 4);
            motorLosses = zeros(1, 4);

            for i=1:4
                motor = obj.motors{i};
                [motorStatedots{i}, motorTorques(i), motorPowers(i), motorLosses(i), ~, ~] = ...
                    motor.compute(motorStates{i}, inputTorques(i), carState.w(i));
            end
            
            frontBrakeTorque = brake * cp.totalBrakeTorque * (1 - cp.brakeBias) / 2;
            rearBrakeTorque = brake * cp.totalBrakeTorque * (cp.brakeBias) / 2;
            brakeTorques = [frontBrakeTorque, frontBrakeTorque, ...
                            rearBrakeTorque, rearBrakeTorque];

            % Reduce brake torques near wheel velocities = 0 to prevent backwards
            brakeTorques = brakeTorques .* max(tanh(carState.w), 0);
        end

% **************THIS CALCULATES AERO FORCES IN BODY COORDINATE FRAME**************
        function [fwzB, fwxB] = calculateAeroForcesB(obj, v)
            cp = obj.params;
            fwxB = -0.5 * cp.airDensity * cp.frontalArea * cp.dragCoef * v^2;
            fwzB = -0.5 * cp.airDensity * cp.frontalArea * cp.downforceCoef * v^2;
        end
        
% ****THIS CALCULATES TIRE FORCES IN TIRE COORDINATE FRAME USING SLIP RATIO*******
% FOR WHEN USING WHEEL VELOCITY
        function [fxsT, fysT] = calculateWheelSpeedTireForcesT(...
                obj, fzsT, sas, srs, ~, vx)
            for i = 1:4
                tire = obj.tires{i};
                [~, F] = tire.compute({}, fzsT(i), sas(i), srs(i), vx(i));
                fxsT(i) = F(1);
                fysT(i) = F(2);
            end
        end

% ****THIS CALCULATES TIRE FORCES IN TIRE COORDINATE FRAME LIMITED BY LONGITUDINAL COEFF*******
%(NO SLIP RATIO) FOR WHEN NOT USING WHEEL VELOCITY
        function [fxsT, fysT] = calculateLimitTireForcesT(...
                obj, fzsT, sas, ~, fxsTCommanded, vx)
            
            %CZ: NOT YET WORKING FOR MFEVAL
            for i = 1:4
                tire = obj.tires{i};
                [~, F] = tire.computeNoSR({}, fzsT(i), sas(i), fxsTCommanded(i), vx(i));
                %{
                tractionLimit = fzsT(i) * tire.loadSensitivityFunc(fzsT(i)) * tireXCoefs(i);
                fx = min(tractionLimit, max(-tractionLimit, fxsTCommanded(i)));
                [~, F] = tire.compute({}, fzsT(i), sas(i), 0);
                %}
                
                % CZ: traction limit already called in computeNoSR
                fxsT(i) = F(1);
                fysT(i) = F(2);
            end
        end

% *************TRANSFORMS TIRE FORCES FROM WORLD TO BODY FRAME***************
        function [FxsB, FysB] = transformTireForces(...
                ~, FxsT, FysT, WABs, isSym)
            % Put tire frame forces into body frame
            if isSym
                FxsB = sym(zeros(4, 1));
                FysB = sym(zeros(4, 1));
            else
                FxsB = zeros(4, 1);
                FysB = zeros(4, 1);
            end
            % CZ: TODO: check if rotation here is correct
            for i = 1:4
                FB = rotMat3D(WABs(i)) * [FxsT(i);FysT(i);0];
                FxsB(i) = FB(1);
                FysB(i) = FB(2);
            end
        end
    end
end
