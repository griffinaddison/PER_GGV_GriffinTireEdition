function p = getAutocrossScore(autocross)
    if autocross.isFinished == false
        autocross.score = 0;
    else
        autocross.adjustedTime = autocross.rawTime + autocross.cones * 2 + autocross.offCourse * 20;
        autocross.minTime = min(autocross.minTime, autocross.adjustedTime);
        maxTime = 1.45 * autocross.minTime;
        if autocross.adjustedTime <= maxTime
            autocross.score = 118.5 * (((maxTime / autocross.adjustedTime) - 1) / ...
                ((maxTime / autocross.minTime) - 1)) + 6.5;
        else 
        autocross.score = 6.5;
        end
    end
    p = autocross.score;
end
