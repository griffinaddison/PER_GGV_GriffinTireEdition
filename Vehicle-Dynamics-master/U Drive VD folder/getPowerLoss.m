function [totalLoss, totalPower] = getPowerLoss(mph , storqueRQ)

    torqueRQ = abs(storqueRQ);

    RATIO = 9;
    WHEEL_DIAMETER = 18; % in
    WHEEL_CIRCUMFERENCE = WHEEL_DIAMETER * 3.141;
    N = RATIO * mph * (5280 * 12/60) / WHEEL_CIRCUMFERENCE; %rpm
    w = N *2* 3.141 / 60;
    frontTorque = torqueRQ * 20;
    rearTorque = torqueRQ * 34.5;
    
    maxTorque = 80000 / w;

    totalTorque = 2*rearTorque + 2*frontTorque;
    if (totalTorque > maxTorque)
        overLimitPercentage = totalTorque/maxTorque;
        frontTorque = frontTorque/overLimitPercentage;
        rearTorque = rearTorque/overLimitPercentage;
    end
    
    %convert input to lb-ft
    outF = GVK142_025L6_sat(frontTorque/.0254/4.448, w); 
    frontI = outF(2);
    frontDraw = outF(3);
    frontLoss = outF(5);
    
    %convert input to lb-ft
    outR = GVK142_050M6_sat(rearTorque/.0254/4.438, w);
    rearI = outR(2);
    rearDraw = outR(3);
    rearLoss = outR(5);
    
    frontInverterLoss = (3*((0.00927932*frontI^2+0.942941*frontI+4.46138)/pi*270/250*2/3 + 0.011*frontI^2));
    rearInverterLoss = (3*((0.00927932*rearI^2+0.942941*rearI+4.46138)/pi*270/250*2/3 + 0.011*rearI^2));
    
    totalLoss = (frontLoss + frontInverterLoss) * 2 + (rearInverterLoss + rearLoss) * 2;
    totalLoss = totalLoss * 4.44 * 0.0254;
    totalPower = 2*frontDraw + 2 * rearDraw;
    totalPower = 4.44 * 0.0254 * totalPower;
    totalPower = totalPower * sign(storqueRQ);
end