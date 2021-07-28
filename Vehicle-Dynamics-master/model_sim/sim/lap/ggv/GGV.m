classdef GGV < handle
    properties
        ggvPoints
        hullGGVPoints
        
        vs
        planes

        maxLongVelocity

        car
    end

    methods
        function obj = GGV(varargin)
            p = inputParser;
            p.addRequired('vs');
            p.addRequired('planes');
            p.addRequired('car');
            p.parse(varargin{:});
            
            obj.vs = p.Results.vs;
            obj.planes = p.Results.planes;
            obj.car = p.Results.car;

            obj.process();
        end
        
        function process(obj)
            obj.hullGGVPoints = [];
            for p = obj.planes
                obj.hullGGVPoints = [obj.hullGGVPoints, ...
                                     p.hullGGVPoints];

                if max([p.hullGGVPoints.xddot]) > 0
                    obj.maxLongVelocity = p.v;
                end
            end

            obj.maxLongVelocity = min(obj.maxLongVelocity, obj.car.getMaxVelocity());

            obj.ggvPoints = [];
            for p = obj.planes
                obj.ggvPoints = [obj.ggvPoints, p.ggvPoints];
            end
        end

        function [ggvPoint] = latAccelLookup(obj, v, longAccel)
            ggvPoint = obj.combinedLookup(min(v, obj.maxLongVelocity), longAccel, false, 2);
        end

        function [ggvPoint] = longAccelLookup(obj, v, latAccel)
            [v, I] = min([v, obj.maxLongVelocity]);
            % If hit velocity limit, don't accelerate any more
            if I == 2
                v = 0;
            end
            ggvPoint = obj.combinedLookup(v, latAccel, true, 2);
        end

        function [ggvPoint] = longBrakeLookup(obj, v, latAccel)
            ggvPoint = obj.combinedLookup(min(v, obj.maxLongVelocity), latAccel, true, 1);
        end

        function [ggvPoint] = pointLookup(obj, v, longAccel, latAccel)
            v = min(v, obj.maxLongVelocity);
            vLowIndex = find(obj.vs < v, 1, 'last');
            [ggvPointLow] = obj.planeInterp( ...
                obj.planes(vLowIndex), longAccel, latAccel);
            [ggvPointHigh] = obj.planeInterp( ...
                obj.planes(vLowIndex + 1), longAccel, latAccel);
            
            interp = (v - obj.vs(vLowIndex)) / ...
                (obj.vs(vLowIndex + 1) - obj.vs(vLowIndex));

            ggvPoint = obj.interpPoints(ggvPointHigh, ggvPointLow, interp);
        end
    end

    methods (Access = protected)
        function [ggvPoint] = planeInterp(obj, plane, longAccel, latAccel)
            fields = fieldnames(plane.interpolants);
            for k = 1:numel(fields)
                interpolant = plane.interpolants.(fields{k});
                ggvPoint.(fields{k}) = interpolant(longAccel, latAccel);
            end 
        end

        function [ggvPoint] = combinedLookup(obj, v, accel, isLongLookup, intersectIndex)
            vLowIndex = find(obj.vs < v, 1, 'last');
            [ggvPointLow] = obj.planeIntersect( ...
                obj.planes(vLowIndex), accel, isLongLookup, intersectIndex);
            [ggvPointHigh] = obj.planeIntersect( ...
                obj.planes(vLowIndex + 1), accel, isLongLookup, intersectIndex);
            
            interp = (v - obj.vs(vLowIndex)) / ...
                (obj.vs(vLowIndex + 1) - obj.vs(vLowIndex));

            ggvPoint = obj.interpPoints(ggvPointHigh, ggvPointLow, interp);
        end

        function [ggvPoint] = planeIntersect( ...
                obj, plane, accel, isLongLookup, intersectIndex)
            % Intersects a desired lateral / longitudinal acceleration line with a ggv plane
            % Returns either the first or second point found
            xddots = [plane.hullGGVPoints.xddot];
            yddots = [plane.hullGGVPoints.yddot];
            
            % From geom2D library
            if isLongLookup
                % accel value is lateral
                line = createLine([0, accel], [1, accel]);
            else
                % accel value is longitudnal
                line = createLine([accel, 0], [accel, 1]);
            end

            polygon = [xddots; yddots].';

            [intersects, k] = intersectLinePolygon(line, polygon);
            
            % Sometimes desired acceleration is just outside boundary
            % Meaning we just need to move inwards until we're good
            accelFrac = 1;
            while length(k) ~= 2
                line = line * 0.99;
                accelFrac = accelFrac * 0.99;
                [intersects, k] = intersectLinePolygon(line, polygon);
                assert(accelFrac > 0.9, 'too much accel shrinkage required');
            end

            intersect = intersects(intersectIndex, :);
            lineseg = k(intersectIndex);
            prevPoint = [xddots(lineseg), yddots(lineseg)];
            if lineseg + 1 <= length(polygon)
                nextPoint = [xddots(lineseg+1), yddots(lineseg+1)];
            else
                nextPoint = [xddots(1), yddots(1)];
            end
            
            d1 = norm(intersect - prevPoint);
            d2 = norm(intersect - nextPoint);
            interp = d2 / (d1 + d2);
            
            prevGGVPoint = plane.hullGGVPoints(lineseg);
            if lineseg + 1 <= length(plane.hullGGVPoints)
                nextGGVPoint = plane.hullGGVPoints(lineseg + 1);
            else
                nextGGVPoint = plane.hullGGVPoints(1);
            end

            ggvPoint = obj.interpPoints(prevGGVPoint, nextGGVPoint, interp);
        end

        function [ggvPoint] = interpPoints(obj, ggvPoint1, ggvPoint2, interp)
            % Here, statedots and debugdots contain exactly 2 points
            % Interp is a linear interpolation factor, 0 to 1
            interpFunc = @(field) interp * field(1) + (1 - interp) * field(2);

            ggvPoints(1) = ggvPoint1;
            ggvPoints(2) = ggvPoint2;

            ggvPoint = obj.nonScalarStructCombine(ggvPoints, interpFunc);
        end

        function outputStruct = nonScalarStructCombine(obj, inputStructs, func)
            C = fieldnames(inputStructs);
            outputStruct = struct(); % scalar structure
            for k = 1:numel(C)
                F = C{k};
                outputStruct.(F) = func([inputStructs.(F)]);
            end
        end
    end
end
