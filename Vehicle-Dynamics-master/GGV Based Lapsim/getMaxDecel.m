function maxDecel = getMaxDecel(ggV, radius, speed)
    
    lateralAcceleration = speed^2/radius;
    
    if ( isreal(speed))
    
        maxDecel = interp2(ggV.speeds, ggV.lateralAccelerations, ggV.negativeLongAccel, speed, lateralAcceleration);
    else
       maxDecel = nan; 
    end
end
