classdef ParametricMotor < MotorModel
    % Parametric motor with core and resistive losses
    % e.g. amk     = ParametricMotor(0.44, 4.5, 20000, 48)
    % e.g. fischer = ParametricMotor(0.447, 2.2, 20000, 48)
    % e.g. k500100 = ParametricMotor(0.43, 3, 20000, 48)
    % e.g. k500150 = ParametricMotor(0.582, 4.8, 20000, 48)
    % e.g. k500200 = ParametricMotor(0.694, 6.4, 20000, 48)
    % e.g. K500300 = ParametricMotor(1.13, 8.6, 20000, 48)
    % e.g. k127100 = ParametricMotor(0.51, 9.6, 20000, 48)
    % e.g. k127150 = ParametricMotor(0.702, 14.5, 20000, 48)
    % e.g. k127200 = ParametricMotor(0.864, 19.5, 20000, 48)
    % e.g. k127300 = ParametricMotor(1.18, 29, 20000, 48)
    % e.g. g15070  = ParametricMotor(2.5, 100, 4200, 48)
    % e.g. GVK142050L6 = ParametricMotor(1.06, 3 ,16000, 39.6)
    % e.g. GVK142025L6 = ParametricMotor(0.32, 1.5 ,16000, 19.5)
    properties
        MotorConstant
        CoreLossConstant
        NumPoles
        RpmLimit
        TorqueLimit
    end

    methods(Static)
        
        function emrax_208 = Emrax_208()
            emrax_208 = ParametricMotor(4.65, 8.5, true, 0.44, 4.5, 10, 7000, 70);
        end

        function nova_30swk = NOVA_30SWK()
            nova_30swk = ParametricMotor(6.5, 8.5, true, 0.44, 4.5, 10, 7000, 80);
        end

        function gvk142_100eqw = GVK142_100EQW()
            gvk142_100eqw = ParametricMotor(10.5, 8.5, true, 0.44, 4.5, 10, 9500, 85);
        end

        function evo_af130 = EVO_AF130()
            evo_af130 = ParametricMotor(15.25, 8.5, true, 0.44, 4.5, 10, 4000, 175);
        end

        function amk = AMK()
            amk = ParametricMotor(4, 8.5, false, 0.44, 4.5, 10, 20000, 48);
        end

        function fischer = Fischer()
            fischer = ParametricMotor(4, 8.5, false, 0.447, 2.2, 10, 20000, 48);
        end

        function gvk142_050l6 = GVK142_050L6()
            gvk142_050l6 = ParametricMotor(4, 8.5, false, 0.447, 3, 12, 16000, 49.77);
        end

        function gvk142_025l6 = GVK142_025L6()
            gvk142_025l6 = ParametricMotor(2.1, 8.5, false, 0.447, 6, 12, 16000, 24.2);
        end
        
        function dhx = DHX()
            dhx = ParametricMotor(9.5, 8.5, true, 0.44, 4.5, 10, 4400, 80);
        end
        
        %REV7 CONSIDERATIONS
        
        function emrax_188 = Emrax_188()
            emrax_188 = ParametricMotor(7.2, 8.5, true, 0.503, 4.5, 10, 8000, 90);
        end
        
        function emrax_228 = Emrax_228()
            emrax_228 = ParametricMotor(6.15, 8.5, true, 0.974, 4.5, 10, 6500, 115);
        end
        
        function apm = APM()
            apm = ParametricMotor(7, 8.5, true, 0.597, 4.5, 10, 12000, 65);
        end
        
        function evo_af125 = EVO_AF125()
            evo_af125 = ParametricMotor(11, 8.5, true, 0.637, 4.5, 10, 12000, 110);
        end
        
        function gvk210_100dqw = GVK210_100DQW()
            gvk210_100dqw = ParametricMotor(11, 8.5, true, 0.573, 4.5, 12, 8000, 86.5);
        end
        
        function yasa_p400 = YASA_P400()
            yasa_p400 = ParametricMotor(12, 8.5, true, 0.836, 4.5, 10, 8000, 185);
        end

    end

    methods
        function obj = ParametricMotor(mass, gearRatio, inboard, motorConstant, coreLossConstant, numPoles, rpmLimit, torqueLimit)
            obj = obj@MotorModel(mass, gearRatio, inboard);
            obj.MotorConstant = motorConstant;
            obj.CoreLossConstant = coreLossConstant;
            obj.NumPoles = numPoles;
            obj.RpmLimit = rpmLimit;
            obj.TorqueLimit = torqueLimit;
        end

        function [statedot, torque, powerOut, powerLoss, current, saturation] = compute(obj, ~, T, w)
            
            T = T / obj.gearRatio;
            w = w * obj.gearRatio;
            
            % Convert to rpm
            rpm = w * 30/pi;

            T = min(T, obj.TorqueLimit);
            if rpm > obj.RpmLimit
                T =  T / (1 + (rpm - obj.RpmLimit));
            end
            
            powerOut = w * T;
            
            % This must be here after powerOut for return purposes
            torque = T * obj.gearRatio;
                        
            coreLoss = 1.5 * (obj.MotorConstant/(0.75*obj.NumPoles))^2 / 400 * rpm^2;
            resistiveLoss = (1.5/obj.MotorConstant^2) * T^2;

            powerLoss = coreLoss + resistiveLoss;
            
            current = 0;
            saturation = 0;
            statedot = {};
        end

        function [torque] = computeTorque(obj, ~, totalPowerDraw, w)
            rpm = w * 30/pi;
            
            coreLoss = (rpm/1000)^2 * obj.CoreLossConstant;
            torque = roots(obj.MotorConstant, w, ...
                totalPowerDraw - coreLoss);

            torque = min(T, obj.TorqueLimit);
            if rpm > obj.RpmLimit
                torque =  torque / (1 + rpm - obj.RpmLimit);
            end
        end
        
        % Overrides superclass method
        function [maxVelOut] = getMaxVelocity(obj)
            maxVelOut = (obj.RpmLimit * pi/30) / obj.gearRatio;
        end
    end
end
