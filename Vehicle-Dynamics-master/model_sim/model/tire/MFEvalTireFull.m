classdef MFEvalTireFull < TireModel
    % MFGuiTireFull uses the MFEval MF6.1 combined slip calculation for
    % longitudinal and lateral force independently. 
    
    %   loadLinear is a boolean that specifies whether the output
    %   longitudinal force should be linear in Fz (allows for explicit solving
    %   of Fz for car dynamics).
    properties
        tireParams % MF 6.1 parameters
        pressure % in Pa
        loadLinear % Linearizes the magic formula solver wrt load

        totalFrictionLimit % Max combined coefficient of friction (can be inf)

        hasLoadSensitivity
        loadSensitivityFunc
        
        % Only precomputes x friction coefficient if useSR is false
        useSR
        xCoef
    end

    methods(Static)
        function tire = hoosier16R25B(useLoadSensitivity, ~, frictionBound)
            load('Hoosier16-18-SL-CombLong-v3.mat', 'OptimParameterSet');
            OptimParameterSet.LMUX = 0.6;
            OptimParameterSet.LMUY = 0.6;


            pressure = 12 * 6894.76; % psi -> Pa
            
            if frictionBound
                % Mostly determined qualitatively by looking
                % at combined steer/drive data
                totalFrictionLimit = 1.88;
            else
                totalFrictionLimit = inf;
            end

            if useLoadSensitivity
                % Fit to calspan load sensitivity data
                loadSensitivityCoef = 0.0003;
                loadSensitivityBias = 600;
            else
                loadSensitivityCoef = 0;
                loadSensitivityBias = 0;
            end
            
            % CZ: trying loadLinear false
            tire = MFEvalTireFull(OptimParameterSet, pressure,...
                    'loadLinear', false, 'totalFrictionLimit', totalFrictionLimit, ...
                    'loadSensitivityCoef', loadSensitivityCoef, ...
                    'loadSensitivityBias', loadSensitivityBias);
        end
    end

    methods
        function obj = MFEvalTireFull(varargin)
            p = inputParser;
            p.addRequired('params');
            p.addOptional('pressure', 12 * 6894.76);
            p.addOptional('loadLinear', false);
            p.addOptional('totalFrictionLimit', inf);
            p.addOptional('loadSensitivityCoef', 0);
            p.addOptional('loadSensitivityBias', 0);
            p.parse(varargin{:});
            obj = obj@TireModel();

            obj.tireParams = p.Results.params;
            obj.pressure = p.Results.pressure;
            obj.loadLinear = p.Results.loadLinear;

            obj.totalFrictionLimit = p.Results.totalFrictionLimit;
            obj.hasLoadSensitivity = p.Results.loadSensitivityCoef ~= 0;

            % Friction coef scaling function:
            % cos(coef * (Fz - bias)) for Fz > bias, with Fz in Newtons
            % 1 for Fz < bias
            % Bias is usually the normal load where the data was fitted
            % @(fz) -> [loadSensitivity (0 <-> 1)]
            
            % CZ: interpl does not handle symbolic variables, so updated
            obj.loadSensitivityFunc = @(fz) (1 - p.Results.loadSensitivityCoef * ...
                                       (fz - p.Results.loadSensitivityBias));
        end

        function init(obj)
            fxMax = 0;
            for sr = 0:0.005:1
                [~, F] = obj.compute({}, 1, 0, sr, 15);
                fxMax = max(fxMax, F(1));
            end
            obj.xCoef = fxMax;
        end

        function [statedot, F] = compute(obj, ~, fz, sa, sr, vx)
            % CZ: MFEval throws a bunch of warnings when limiting coeffs
            warning('off','all')
            % NOTE: this outputs proper RCVD convention for y axis
            flip = -sign(sa);
            assert(flip * sa <= 0);
            if obj.loadLinear
                inputs = [1, sr, flip * sa, 0, 0, vx, obj.pressure];
            else
                inputs = [fz, sr, flip * sa, 0, 0, vx, obj.pressure];
            end
            outputs = mfeval(obj.tireParams, inputs, 121);
            
            
            if obj.loadLinear
                Fxy = [fz * outputs(:, 1), flip * fz * outputs(:, 2)];
            else
                Fxy = [outputs(:, 1), flip * outputs(:, 2)];
            end
            
%             Fxy = Fxy * 0.6;
            
            %CZ: need to check if still needed, MFEval limits innately
%             if obj.hasLoadSensitivity
%                 Fxy = Fxy * obj.loadSensitivityFunc(fz);
%             end
% 
            [fx, fy] = obj.frictionLimitForces(Fxy(1), Fxy(2), fz);
            F = [fx, fy, fz];

%             F = [Fxy(1), Fxy(2), fz];

            statedot = {};
            warning('on','all') 
        end
        
        function [statedot, F] = computeNoSR(obj, ~, fz, sa, fxCommanded, vx)
            % CZ: MFEval throws a bunch of warnings when limiting coeffs
            warning('off','all')
            if obj.loadLinear
                inputs = [1, 0, -sa, 0, 0, vx, obj.pressure];
            else
                inputs = [fz, 0, -sa, 0, 0, vx, obj.pressure];
            end
            
            % 121: limit inputs to stable; 221: no limit checks
            outputs = mfeval(obj.tireParams, inputs, 121);
            
            if obj.loadLinear
                fy = fz * outputs(:, 2);
            else
                fy = outputs(:, 2);
            end
            
            assert(~isempty(obj.xCoef), 'Need to init tires!');
            % CZ: removed loadsensitivity
            tractionLimit = fz * obj.xCoef;
            fx = min(tractionLimit, max(-tractionLimit, fxCommanded));

            [fx, fy] = obj.frictionLimitForces(fx, fy, fz);
            F = [fx, fy, fz];

            statedot = {};
            warning('on','all')
        end

        % TODO: clean and vectorize
        function [fx, fy] = frictionLimitForces(obj, fx, fy, fz)
            Fxy = [fx, fy];

            if obj.totalFrictionLimit ~= inf
                maxForce = obj.totalFrictionLimit * fz;
%                 if obj.hasLoadSensitivity 
%                     maxForce = maxForce * obj.loadSensitivityFunc(fz);
%                 end
                if ~isequal(class(maxForce), 'sym')
                    if norm(Fxy) > maxForce
                        Fxy = Fxy * maxForce / norm(Fxy);
                    end
                end
            end

            fx = Fxy(1);
            fy = Fxy(2);
        end
    end
end
