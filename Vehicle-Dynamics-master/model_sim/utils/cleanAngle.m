%converts angle to between -pi and pi
function cleanedAngle = cleanAngle(angle)
    cleanedAngle = mod(angle, 2*pi);
    if cleanedAngle > pi
        cleanedAngle = cleanedAngle - 2*pi;
    end
end