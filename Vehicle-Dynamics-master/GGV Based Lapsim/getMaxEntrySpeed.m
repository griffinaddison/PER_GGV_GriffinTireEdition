%find how fast car can enter corner based on how fast it can exit
%and how hard it can brake

function maxEntrySpeed = getMaxEntrySpeed(car, radius, cornerLength, maxExitSpeed)
   
    speed = maxExitSpeed;
    for d = 0:.1:cornerLength
        decceleration = getMaxDecel(car, radius, speed);
        speed = sqrt(speed^2 + 2*decceleration*.1);
    end
    maxEntrySpeed = min(speed, getMaxCorneringSpeed(car, radius));

end
