
function maxAccel = getMaxAccel(ggV, radius, speed)
    
    lateralAcceleration = speed^2/radius;
    
    if ( isreal(speed))
        
        maxAccel = interp2(ggV.speeds, ggV.lateralAccelerations, ggV.positiveLongAccel, speed, lateralAcceleration);
    else
        maxAccel = nan;
    end
end