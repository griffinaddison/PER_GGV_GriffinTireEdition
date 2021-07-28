function [xs, ys, dists, curvatures, straightDists] = createSectors(...
        distances, radii, sectorLength)

    if length(radii) ~= length(distances)
        error('Need same length radii and distances');
    end
    
    xs = [];
    ys = [];
    dists = [];
    curvatures = [];
    straightDists = [];
    
    pos = [0; 0];
    h = 0;
    for i = 1:length(distances)
        curvature = 1 / radii(i);
        
        % Check for straight
        if abs(curvature) < 1/10000
            straightDists = [straightDists, distances(i)];
        end
        numPoints = distances(i) / sectorLength;
        
        center = pos + rotMat2D(h + pi/2) * [radii(i); 0]; % Set turn center
        travelStart = h + pi/2 + pi * sign(radii(i)); % figure 8
        travelRads = distances(i) / radii(i); % arc length / r
        
        angles = linspace(travelStart, travelStart + travelRads, numPoints);
        
        [x, y, dist] = arcPoints(angles, center(1), center(2), radii(i)); 
        % dists = individual distances for this segment
        
        pos = [x(end); y(end)];
        h = h + travelRads;

        curvatures = [curvatures, curvature * ones(size(x(min(i, 2): end)))];
        xs = [xs, x(min(i, 2): end)];
        ys = [ys, y(min(i, 2): end)];
        
        if isempty(dists)
            lastdist = 0;
        else
            lastdist = dists(end);
        end
%         if abs(curvature) < 1/10000
%             disp(length(dists));
%         end
        dists = [dists, dist(min(i, 2):end) + lastdist];
        
    end
end
