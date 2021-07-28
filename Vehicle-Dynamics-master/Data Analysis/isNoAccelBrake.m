function isNoAccelBrake = isNoAccelBrake(inputs)
    
    %inputs 1 is accel
    %inputs 2 is brake front
    %inputs 3 is brake rear
    
    isNoAccelBrake = (inputs(1) < 10) && ((inputs(2) + inputs(3)) < 200);
end