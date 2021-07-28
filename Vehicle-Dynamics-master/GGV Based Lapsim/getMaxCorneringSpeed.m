function maxSpeed = getMaxCorneringSpeed(ggV, radius)
    
    
   % plot(speeds, maxAccel)
    %iterate to find max allowable speed
    speed = 0;
    residual = .1;
    iterations = 0;
    while (abs(residual) > .001) 
    iterations = iterations+1;
        lateralAcceleration = interp1(ggV.flattenedSpeeds, ggV.maxLateral, speed);
        residual = speed^2/radius - lateralAcceleration;
        speed = speed - residual*.5;
    end
   %iterations
    maxSpeed = speed;
    %handle speeds above top speeds better
    if (radius > 50)
        maxSpeed = 9999;
    end
end