function out = emrax207(w)

    maxTorque = 140; %Nm
    maxSpeed = 6000; %rpm
    maxPower = 80000; %W

    powerLimitedTorque = maxPower/w;
    
    T = min(maxTorque, powerLimitedTorque);
    Pout = 0;
    Pdraw = 0;
    Ploss = 0;
    I = 0;
    out = [Pout, I, Pdraw, T, Ploss];

end