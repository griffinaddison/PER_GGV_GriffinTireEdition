function [x, y, dist] = arcPoints(angles, x0, y0, r)
    t = angles;
    x = x0 + r*cos(t);
    y = y0 + r*sin(t);
    dist = (t - angles(1)) * r;
end
