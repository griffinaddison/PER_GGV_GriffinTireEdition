classdef Rev5Full < FullCar
    methods
        function obj = Rev5Full(varargin)
            % adjustTires: whether or not fitted tire coefficients
            % should be modified to produce realistic large/low slip
            % behavior
            % boundTires: whether to induce load sensitivity and max
            % combined friction coefficient
            p = inputParser;
            p.addOptional('loadSensitiveTires', true);
            p.addOptional('adjustTires', true);
            p.addOptional('boundTires', true);
            p.parse(varargin{:});

            cp = Rev5Full.createCarParams();
            tires = Rev5Full.createTires(p.Results.loadSensitiveTires, p.Results.adjustTires, p.Results.boundTires);

            motors = Rev5Full.createMotors();
            accumulator = AccumulatorModel(60000, 15000);
            
            obj = obj@FullCar(cp, tires, motors, accumulator);

            % Estimate 1kg for upright MOCs
            obj.setPowerTrainMasses(3.35, 5.45, 0);
        end

    end
    
    methods
        function setPowerTrainMasses(obj, uprightMassF, uprightMassR, inboardMocMass)
            cp = obj.params;

            obj.params.I = cp.baseInertia + hypot(cp.wheelbase / 2, cp.trackwidth / 2) * ...
                (2 * uprightMassF + 2 * uprightMassR) + cp.wheelbase * 0.4 * inboardMocMass;
            obj.params.mass = cp.baseMass + 2 * uprightMassF + 2 * uprightMassR + inboardMocMass;
        end
    end

    methods(Static)
        function cp = createCarParams()
            % Initialize car parameters
            cp.wheelbase = 1.52; % Front-back distance between centers of tires
            cp.trackwidth = 1.1; % Side-to-side distance between centers of tires
            cp.height = 0.25; % COM height above ground
            cp.radius = 0.22; % Wheel radius
            cp.baseMass = 249.4; % Mass of car
            cp.gravity = 9.8;
            cp.wheelI = 0.2;
            cp.baseInertia = 60;

            cp.frontToe = deg2rad(-1);
            cp.rearToe = degtorad(1);
            cp.ackerman = 1.0;

            cp.comDistribution = 0.508; % Percent of weight on front tires

            % If inertia is changed, add this time to each slalom
            % (empirically determined from testing)
            cp.slalomLoss = @(I) 0.07 * exp(0.09 * (I - cp.baseInertia));

            % TODO: should go in aero
            cp.airDensity = 1.224;
            cp.frontalArea = 1.14;
            cp.dragCoef = 1.52;
            cp.downforceCoef = 3.5;

            cp.copDistribution = 0.548; % Percent of aero on front tires
            
            cp.totalBrakeTorque = 500; % Total torque distributed between wheels
            cp.brakeBias = 0.4; % Percent of brake in rear tires
            
            % TODO: Should go in motors
            cp.gearRatio = 8.5;
            % Coefficient to the equation:
            % power_loss = a * (torque)^2 for each motor
            % Chosen so that at 20nm of torque gives roughly 5kW power loss
            cp.mocLossCoef = 7;
            % Must be manually analyzed for accel run to keep in power limit
            cp.estimatedMocLosses = 16000;

            % GGV sim doesn't take into account the yaw dynamics
            % Empirically determined that lateral accelerations
            % are too small by the following factor
            cp.latAccelFudge = 1.75;
        end

        function tires = createTires(loadSensitiveTires, adjustTires, boundTires)
            tires = {MFGuiTireFull.hoosier18R25B(loadSensitiveTires, adjustTires, boundTires), ...
                     MFGuiTireFull.hoosier18R25B(loadSensitiveTires, adjustTires, boundTires), ...
                     MFGuiTireFull.hoosier18R25B(loadSensitiveTires, adjustTires, boundTires), ...
                     MFGuiTireFull.hoosier18R25B(loadSensitiveTires, adjustTires, boundTires)};
        end

        function motors = createMotors()
            motors = {GVK142_025L6(), GVK142_025L6(), ...
                      GVK142_050L6(), GVK142_050L6()};
        end
    end
end
