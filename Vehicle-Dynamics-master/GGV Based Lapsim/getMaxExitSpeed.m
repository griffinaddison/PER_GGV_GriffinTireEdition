%finds how fast car can exit corner based on how fast it enters
%and how fast it can accelerate

function maxExitSpeed = getMaxExitSpeed(car, radius, cornerLength, maxEntranceSpeed)
    
    speed = maxEntranceSpeed;
    for d = 0:.1:cornerLength
        acceleration = getMaxAccel(car, radius, speed);
        speed = sqrt(speed^2 + 2*acceleration*.1);
    end
    maxExitSpeed = min(speed, getMaxCorneringSpeed(car, radius));

end