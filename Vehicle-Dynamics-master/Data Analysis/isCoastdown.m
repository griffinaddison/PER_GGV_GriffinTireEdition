function isCoastdown = isCoastdown(inputs)
    %input 1 is pedal sensor
    %inpit 2 is front brake sensor
    %input 3 is rear brake sensor
    %input 4 is lat accel
    
    pedalNotPressed = (inputs(1) < .05);
    brakesNotPressed = (inputs(2)+inputs(3)) < 8;
    notCornering = (abs(inputs(4)) < .05*4096);
    isCoastdown = pedalNotPressed && brakesNotPressed && notCornering;
end