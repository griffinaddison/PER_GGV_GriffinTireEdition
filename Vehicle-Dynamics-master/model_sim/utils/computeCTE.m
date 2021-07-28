function [cte, inc] = computeCTE(h, carPos, p1, p2)
    a = carPos - p1;
    b = p2 - p1;
    c = carPos - p2;    
    d = rotMat2D(h - pi/2) * [1; 0];
    % Vector projection
    proj = dot(a, b) / norm(b)^2;
    errorPos = p1 + proj * b;
    cte = norm(carPos - errorPos);
    if proj > 1
        inc = fix(proj);
    else
        inc = 0;
    end
    if dot(d, c) < 0
         cte = -cte;
    end
end

