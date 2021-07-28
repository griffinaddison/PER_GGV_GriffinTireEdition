function p = getAccelScore(accel)
    if accel.isFinished == false
        accel.score = 0;
    else
        accel.adjustedTime = accel.rawTime + accel.cones * 2;
        accel.minTime = min(accel.minTime, accel.adjustedTime);
        maxTime = 1.5 * accel.minTime;
        if accel.adjustedTime <= maxTime
            accel.score = 95.5 * (((maxTime / accel.adjustedTime) - 1) / ((maxTime / accel.minTime) - 1)) + 4.5;
        else 
        accel.score = 4.5;
        end
    end
    p = accel.score;
end
