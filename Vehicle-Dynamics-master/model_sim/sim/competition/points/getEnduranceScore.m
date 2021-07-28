function p = getEnduranceScore(endurance)
    if endurance.isFinished == false
        endurance.score = endurance.lapsCompleted;
    else
        endurance.adjustedTime = endurance.rawTime + endurance.cones * 2 + endurance.offCourse * 20 + ...
            endurance.penalty;
        endurance.minTime = min(endurance.minTime, endurance.adjustedTime);
        maxTime = 1.45 * endurance.minTime;
        if endurance.adjustedTime <= maxTime
            endurance.score = 250 * (((maxTime / endurance.adjustedTime) - 1) / ...
                ((maxTime / endurance.minTime) - 1)) + 25;
        else 
            endurance.score = 25;
        end
    end
    p = endurance.score;
end
