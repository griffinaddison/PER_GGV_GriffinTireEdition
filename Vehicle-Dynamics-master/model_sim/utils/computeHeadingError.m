function [error] = computeHeadingError(h, p1, p2)
    b = p2 - p1;
    pathH = atan2(b(2), b(1));
    h = mod(h, 2 * pi);
    if h > pi
        h = mod(h, -2 * pi);
    end
    error = mod(pathH - h, 2 * pi);
    if error > pi
        error = mod(error, -2 * pi);
    end
end

