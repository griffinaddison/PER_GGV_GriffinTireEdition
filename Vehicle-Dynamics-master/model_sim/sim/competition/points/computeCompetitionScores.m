function scoreStruct = computeCompetitionScores(dynamicEvents)

    scoreStruct.total = 0;
    
    if ~isequal(dynamicEvents.accel, [])
        %dynamicEvents.accel.minTime = 3.6870;
        dynamicEvents.accel.minTime = 3.6;
        scoreStruct.accel = getAccelScore(dynamicEvents.accel);
        scoreStruct.total = scoreStruct.total + scoreStruct.accel;
    else
        scoreStruct.accel = 0;
    end
    if ~isequal(dynamicEvents.skidpad, [])
        dynamicEvents.skidpad.minTime = 5.3030;
        scoreStruct.skidpad = getSkidpadScore(dynamicEvents.skidpad);
        scoreStruct.total = scoreStruct.total + scoreStruct.skidpad;
    else
        scoreStruct.skidpad = 0;
    end
    if ~isequal(dynamicEvents.autocross, [])
        dynamicEvents.autocross.minTime = 63.2360;
        scoreStruct.autocross = getAutocrossScore(dynamicEvents.autocross);
        scoreStruct.total = scoreStruct.total + scoreStruct.autocross;
    else
        scoreStruct.autocross = 0;
    end
    if ~isequal(dynamicEvents.endurance, [])
        dynamicEvents.endurance.minTime = 1701.963;
        scoreStruct.endurance = getEnduranceScore(dynamicEvents.endurance);
        scoreStruct.total = scoreStruct.total + scoreStruct.endurance;
    else
        scoreStruct.endurance = 0;
    end
    
end 
