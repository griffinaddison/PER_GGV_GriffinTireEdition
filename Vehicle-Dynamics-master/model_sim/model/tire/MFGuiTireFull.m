classdef MFGuiTireFull < TireModel
    % MFGuiTireFull uses the MFTireGuiFull longitudinal force calculation for both
    % longitudinal and lateral force. loadLinear is a boolean that specifies whether the output
    %   longitudinal force should be linear in Fz (allows for explicit solving
    %   of Fz for car dynamics).
    properties
        longParameters % A vector of magic formula coefficients
        latParameters % A vector of magic formula coefficients
        loadLinear % Linearizes the magic formula solver wrt load

        totalFrictionLimit % Max combined coefficient of friction (can be inf)

        hasLoadSensitivity
        loadSensitivityFunc
        
        % Only precomputes x friction coefficient if useSR is false
        useSR
        xCoef
    end

    methods(Static)
        function tire = hoosier18R25B(useLoadSensitivity, adjustFit, frictionBound)
            % Fitted coefficients (see tire resources)
            longMF52Par = [  4.7746e-02, 2.1609e+04, 3.5138e+01 -1.9104e+00, ... 
                             9.3365e-01 -5.3255e-01 -3.7865e-01, 3.2185e+04, ... 
                            -4.4570e-01 -2.7495e-01, 3.9980e-01 -3.0801e-01, ...
                            -6.3209e-01, 4.5515e-01];

            if adjustFit
                longMF52Par(1) = -1.3;
                longMF52Par(2) = 1540;
                longMF52Par(4) = -0.03;
                longMF52Par(5) = -0.04;
            end

            % Fitted coefficients (see tire resources)
            latMF52Par = [4.4432e-01,  4.0287e+03, -1.1776e+00,  1.0752e+00, ...
                          5.0451e-02,  3.9118e-04, -2.7510e-02,  4.3535e+02, ...
                          3.3266e-03, -2.2958e-02, -3.9039e-03, -1.4310e-02, ...
                         -2.5839e-02, -8.7695e-03];
            

            if adjustFit
                latMF52Par(1) = 1.8;
                latMF52Par(2) = 1470;
                latMF52Par(4) = 0.9;
            end

            if frictionBound
                totalFrictionLimit = 1.75;
            else
                totalFrictionLimit = inf;
            end

            if useLoadSensitivity
                loadSensitivityCoef = 0.0003;
                loadSensitivityBias = 600;
            else
                loadSensitivityCoef = 0;
                loadSensitivityBias = 0;
            end
            
            tire = MFGuiTireFull(longMF52Par, latMF52Par, ...
                    'loadLinear', true, 'totalFrictionLimit', totalFrictionLimit, ...
                    'loadSensitivityCoef', loadSensitivityCoef, ...
                    'loadSensitivityBias', loadSensitivityBias);
        end

        function tire = hoosier16R25B(useLoadSensitivity, adjustFit, frictionBound)
            % Fitted coefficients (see tire resources)
            longMF52Par = [  4.7746e-02, 2.1609e+04, 3.5138e+01 -1.9104e+00, ... 
                             9.3365e-01 -5.3255e-01 -3.7865e-01, 3.2185e+04, ... 
                            -4.4570e-01 -2.7495e-01, 3.9980e-01 -3.0801e-01, ...
                            -6.3209e-01, 4.5515e-01];

            if adjustFit
                longMF52Par(1) = -1.3;
                % Give 16" marginally better perforamce than 18"
                % (Extrapolated since no data)
                longMF52Par(2) = 1580;
                longMF52Par(4) = -0.03;
                longMF52Par(5) = -0.04;
            end

            % Fitted coefficients (see tire resources)
            latMF52Par = [2.4812e-01, 7.8178e+03, 1.0111e-01, 1.1075e+00, ...
                         -8.8849e-03, 5.5549e-03, -1.2308e-02, 4.4921e+02, ...
                         -4.3817e-03, 1.0696e-03, -4.5691e-03, -5.7792e-04, ...
                         -1.2016e-02, 3.3051e-03];
            
            % Fit adjusted for good large SA/SR behavior
            if adjustFit
                latMF52Par(1) = 1.78;
                latMF52Par(2) = 1580;
                latMF52Par(4) = 0.9;
            end

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
            
            tire = MFGuiTireFull(longMF52Par, latMF52Par, ...
                    'loadLinear', true, 'totalFrictionLimit', totalFrictionLimit, ...
                    'loadSensitivityCoef', loadSensitivityCoef, ...
                    'loadSensitivityBias', loadSensitivityBias);
        end

    end

    methods
        function obj = MFGuiTireFull(varargin)
            p = inputParser;
            p.addRequired('longParameters');
            p.addRequired('latParameters');
            p.addOptional('loadLinear', true);
            p.addOptional('totalFrictionLimit', inf);
            p.addOptional('loadSensitivityCoef', 0);
            p.addOptional('loadSensitivityBias', 0);
            p.parse(varargin{:});
            obj = obj@TireModel();

            obj.longParameters = p.Results.longParameters;
            obj.latParameters = p.Results.latParameters;
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
                [~, F] = obj.compute({}, 1, 0, sr);
                fxMax = max(fxMax, F(1));
            end
            obj.xCoef = fxMax;
        end

        function [statedot, F] = compute(obj, ~, fz, sa, sr, ~)
            % NOTE: this outputs proper RCVD convention for y axis
            if obj.loadLinear
                fx = MF52_LongForce_calc(obj.longParameters, sr, 1);
                fx = fz * fx{1};
                
                fy = MF52_LongForce_calc(obj.latParameters, rad2deg(sa), 1);
                fy = fz * fy{1};
            else
                fx = MF52_LongForce_calc(obj.longParameters, sr, fz);
                fx = fx{1};

                fy = MF52_LongForce_calc(obj.latParameters, rad2deg(sa), fz);
                fy = fy{1};
            end

            Fxy = [fx, fy];
            if obj.hasLoadSensitivity
                Fxy = Fxy * obj.loadSensitivityFunc(fz);
            end
            [fx, fy] = obj.frictionLimitForces(Fxy(1), Fxy(2), fz);
            % CZ: flip sign of fy
            F = [fx, -fy, fz];
            statedot = {};
        end

        function [statedot, F] = computeNoSR(obj, ~, fz, sa, fxCommanded, ~)
            if obj.loadLinear
                fy = MF52_LongForce_calc(obj.latParameters, rad2deg(sa), 1);
                fy = fz * fy{1};
            else
                fy = MF52_LongForce_calc(obj.latParameters, rad2deg(sa), fz);
                fy = fy{1};
            end
            
            assert(~isempty(obj.xCoef), 'Need to init tires!');
            tractionLimit = fz * obj.loadSensitivityFunc(fz) * obj.xCoef;
            fx = min(tractionLimit, max(-tractionLimit, fxCommanded));

            [fx, fy] = obj.frictionLimitForces(fx, fy, fz);
            % CZ: flip sign of fy
            F = [fx, -fy, fz];

            statedot = {};
        end

        % TODO: clean and vectorize
        function [fx, fy] = frictionLimitForces(obj, fx, fy, fz)
            Fxy = [fx, fy];

            if obj.totalFrictionLimit ~= inf
                maxForce = obj.totalFrictionLimit * fz;
                if obj.hasLoadSensitivity 
                    maxForce = maxForce * obj.loadSensitivityFunc(fz);
                end
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
