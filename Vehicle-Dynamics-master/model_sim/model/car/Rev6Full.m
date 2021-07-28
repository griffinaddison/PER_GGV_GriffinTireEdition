classdef Rev6Full < FullCar
    methods
        function obj = Rev6Full(varargin)
            % adjustTires: whether or not fitted tire coefficients
            % should be modified to produce realistic large/low slip
            % behavior
            p = inputParser;
            p.addOptional('loadSensitiveTires', true);
            p.addOptional('adjustTires', true);
            p.addOptional('boundTires', true);
            p.parse(varargin{:});

            cp = Rev6Full.createCarParams();
            tires = Rev6Full.createTires(p.Results.loadSensitiveTires, p.Results.adjustTires, p.Results.boundTires);

            motors = Rev6Full.createMotors(8.5, 8.5, [false, false, false, false]);
            accumulator = AccumulatorModel(80000, 15000);
            
            obj = obj@FullCar(cp, tires, motors, accumulator);

            obj.setPowerTrainMasses(0.725, 0.725, 10);
        end
    end

    methods
        function setPowerTrainMasses(obj, uprightMassF, uprightMassR, inboardMocMass)
            cp = obj.params;
            outboardMass = 2 * (uprightMassF + uprightMassR);
            inboardMass = inboardMocMass;
            for i = 1:4
                if obj.motors{i}.isInboard
                    inboardMass = inboardMass + obj.motors{i}.mass;
                else
                    outboardMass = outboardMass + obj.motors{i}.mass;
                end
            end
            obj.params.I = cp.baseInertia + hypot(cp.wheelbase / 2, cp.trackwidth / 2) * ...
                outboardMass + cp.wheelbase * 0.4 * inboardMass;
            obj.params.mass = cp.baseMass + outboardMass + inboardMass;
        end
    end

    methods(Static)
        function cp = createCarParams()
            % Initialize car parameters
            cp.wheelbase = 1.529; % Front-back distance between centers of tires
            cp.trackwidth = 1.168; % Side-to-side distance between centers of tires
            cp.height = 0.253; % COM height above ground
            cp.radius = 0.203; % Wheel radius
            cp.baseMass = 255; % Mass of car + 50kg driver
            cp.gravity = 9.8;
            cp.wheelI = 0.2;
            cp.baseInertia = 90;

            cp.frontToe = deg2rad(0);
            cp.rearToe = deg2rad(1);    
            cp.ackerman = 0.78;
            
            cp.frontCamber = deg2rad(-1);
            cp.rearCamber = deg2rad(-1);
            
            cp.rollRateF = 400;
            cp.rollRateR = 410;
            cp.rollCenterHeightF = 0.038;
            cp.rollCenterHeightR = 0.038;
            
            cp.steerRatio = 2.62;
            
            cp.comDistribution = 0.47; % Percent of weight on front tires

            % If inertia is changed, add this time to each slalom
            % (empirically determined from testing)
            cp.slalomLoss = @(I) 0.07 * exp(0.09 * (I - cp.baseInertia));

            % TODO: should go in aero
            cp.airDensity = 1.224;
            cp.frontalArea = 1.14;
            cp.dragCoef = 1.58;
            cp.downforceCoef = 2.99;

            cp.copDistribution = 0.558; % Percent of aero on front tires
            
            cp.totalBrakeTorque = 1300; % Total torque distributed between wheels
            cp.brakeBias = 0.313; % Percent of brake in rear tires
            
            % Coefficient to the equation:
            % power_loss = a * (torque)^2 for each motor
            % Chosen so that at 20nm of torque gives roughly 5kW power loss
            cp.mocLossCoef = 0.4;
            % Must be manually analyzed for accel run to keep in power limit
            cp.estimatedMocLosses = 2000;

            % GGV sim doesn't take into account the yaw dynamics
            % Empirically determined that lateral accelerations
            % are too small by the following factor
            cp.latAccelFudge = 1.75;
        end

        function tires = createTires(loadSensitiveTires, adjustTires, boundTires)
%             % Old tire model
%             tires = {MFGuiTireFull.hoosier16R25B(loadSensitiveTires, adjustTires, boundTires), ...
%                      MFGuiTireFull.hoosier16R25B(loadSensitiveTires, adjustTires, boundTires), ...
%                      MFGuiTireFull.hoosier16R25B(loadSensitiveTires, adjustTires, boundTires), ...
%                      MFGuiTireFull.hoosier16R25B(loadSensitiveTires, adjustTires, boundTires)};
                 
            % New tire model
            tires = {MFEvalTireFull.hoosier16R25B(loadSensitiveTires, adjustTires, boundTires), ...
                     MFEvalTireFull.hoosier16R25B(loadSensitiveTires, adjustTires, boundTires), ...
                     MFEvalTireFull.hoosier16R25B(loadSensitiveTires, adjustTires, boundTires), ...
                     MFEvalTireFull.hoosier16R25B(loadSensitiveTires, adjustTires, boundTires)};

        end

        function motors = createMotors(frontRatio, backRatio, inboard)
            motors = {GVK142_025L6(frontRatio, inboard(1)), GVK142_025L6(frontRatio, inboard(2)), ...
                      GVK142_050L6(backRatio, inboard(3)), GVK142_050L6(backRatio, inboard(4))};
        end
    end
end
