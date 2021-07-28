classdef GGVPlane < handle
    properties
        v
        
        ggvPoints
        hullGGVPoints
        interpolants
    end

    methods
        function obj = GGVPlane(v, ggvPoints)
            obj.v = v;
            obj.ggvPoints = ggvPoints;
        end

        function createHull(obj)
            k = convhull([obj.ggvPoints.xddot], ...
                         [obj.ggvPoints.yddot]);
            obj.hullGGVPoints = obj.ggvPoints(k);
            
            points = [[obj.hullGGVPoints.xddot]; ...
                      [obj.hullGGVPoints.yddot]].';
            [~, k, ~] = uniquetol(points, 'ByRows', true);

            obj.hullGGVPoints = obj.hullGGVPoints(sort(k));
        end

        function createInterpolants(obj)
            X = [[obj.ggvPoints.xddot]; [obj.ggvPoints.yddot]];
            
            warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId')

            fields = fieldnames(obj.ggvPoints);
            for k = 1:numel(fields)
                data = [obj.ggvPoints.(fields{k})];
                obj.interpolants.(fields{k}) = scatteredInterpolant(X.', data.');
            end 
        end
    end
end
