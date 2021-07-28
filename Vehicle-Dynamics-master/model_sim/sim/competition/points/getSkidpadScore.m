function p = getSkidpadScore(skidpad)
    if skidpad.isFinished == false
        skidpad.score = 0;
    else
        skidpad.adjustedTime = skidpad.rawTime + skidpad.cones * 0.125;
        skidpad.minTime = min(skidpad.minTime, skidpad.adjustedTime);
        maxTime = 1.25 * skidpad.minTime;
        if skidpad.adjustedTime <= maxTime
            skidpad.score = 71.5 * (((maxTime / skidpad.adjustedTime)^2 - 1) / ...
                ((maxTime / skidpad.minTime)^2 - 1)) + 3.5;
        else 
        skidpad.score = 3.5;
        end
    end
    p = skidpad.score;
end

  
