function correctSteerAngle = correctSteerAngle(inputs)
    %inputs 1 is raw steer angle
    rawSteerAngle = inputs(1);
    centerAngle = -157;

    %raw values become less negative when wheel is turned
    %clockwise for right turn
    
    %become more negative and wrap around for left hand turn
    
    if (rawSteerAngle > 0)
        rawSteerAngle = rawSteerAngle - 360;
    end
    correctSteerAngle = rawSteerAngle - centerAngle;
end