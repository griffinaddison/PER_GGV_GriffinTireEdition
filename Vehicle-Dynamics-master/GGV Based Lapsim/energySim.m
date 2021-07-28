%list of corners with radii and lengths
%radii = [9999 9.7 81 23.9 24.3 35.6 23.4 9.4 13 9999 19.6 7.5 25.8 17.8 22.9 17.27 31.5 9999 11.2 7.9 9999 12 8.5 20.6 19.1 8.8 27.8 11.8 9999 10.4 9999 19.3 35.2 14.8 9.1 20.2 9999 23.7 20.9 13.9 6.3 21.1 42.3 9 19.8];
%distance = [84 30 20 15 25 15 96 20 17 57 18 15 12 18 30 58 126 36 17 22 71 11 11 13 14 8 22 31 21 17 17 35 43 15 14 17 65 49 14 12 6 14 43 31 24 ];
radii =    [10, -10, 10, -10, 15, -18, 9, -16, 9999, -10, 9999, 2.9, 9999, -18];
distance = [10, 10,  10,  10, 15,  80, 25, 35, 40,    30,  20,   9, 20,    75];
%renderTrack(radii, distance);
fprintf('Total track length: %f \n', sum(distance));

t = cputime;
cornerCount = length(radii);
clearvars speeds
%lapsim based on ggv diagram
%run corners forwards, find maximum forwards acceleration
%run corners backwards, find max braking acceleration

car = ggV;
j = cornerCount;
maxExitSpeed = 9999;
while j > 0
    entrySpeed(j) = getMaxEntrySpeed(car, abs(radii(j)), distance(j), maxExitSpeed);
    maxExitSpeed = getMaxEntrySpeed(car, abs(radii(j)), distance(j), maxExitSpeed);
    j = j-1;
end

k = 1;
maxEntranceSpeed = 0 ;
while k < cornerCount+1
    exitSpeed(k) = getMaxExitSpeed(car, abs(radii(k)), distance(k), maxEntranceSpeed);
    maxEntranceSpeed = getMaxExitSpeed(car, abs(radii(k)), distance(k), maxEntranceSpeed);
    k = k+1;
end

n = 1;
while n < cornerCount +1
    if n == cornerCount
        endSpeed(n) = exitSpeed(n);
    else    
        endSpeed(n) = min(exitSpeed(n), entrySpeed(n+1)); 
    end
    n = n+1;
end

%now have speed of car in entrance and exit of all corners
%find exit and entrance limited speeds for each corner

totalLength = 0;
powerUsed = [];
for i = 1:cornerCount
    if i == 1
        entrySpeed = 0;
    else
        entrySpeed = endSpeed(i-1);
    end
    
    exitSpeed = endSpeed(i);
    cornerLength = distance(i);
    radius = radii(i);
   
    speed = entrySpeed;
     for d = 0:cornerLength
        acceleration = getMaxAccel(car, radius, speed);
        speed = sqrt(speed^2 + 2*acceleration);
        accelLimited(d+1) = speed;
     end
     
     speed = exitSpeed;
     for d = 0:cornerLength
         disp(d);
        decceleration = getMaxDecel(car, radius, speed);
        speed = sqrt(speed^2 - 2*decceleration);
        decelLimited( (cornerLength-d) + 1) = speed;
     end
    
      for d = 0:cornerLength
        isAccelerating = (accelLimited(d+1) < decelLimited(d+1));
        cornerSpeed(d+1) = min( min(accelLimited(d+1), decelLimited(d+1)), getMaxCorneringSpeed(car, radius));
        speeds(totalLength + d + 1) = cornerSpeed(d+1);
        lateralAcceleration = cornerSpeed(d+1)^2/radius;
        power = interp2(ggV.speeds, ggV.lateralAccelerations, ggV.powerUsed, speed, lateralAcceleration);
        powerUsed(totalLength + d + 1) = power;
      end
      
      clearvars cornerSpeed ;
      
      totalLength = totalLength + cornerLength;
end

figure
hold on
plot(speeds);
totalTime = 0;
totalEnergy = 0;

for i = 1:length(speeds)
    
    totalTime = totalTime + 1/speeds(i);
    time(i) = totalTime;

end
cputime - t
totalEnergyUsed = 0;
% for i = 2:length(speeds)
% 
%     dSpeed = speeds(i) - speeds(i-1);
%     dT = (time(i) - time(i-1));
%     powerConsumption(i) = getPowerConsumption(car, speeds(i), dSpeed/dT);
%     totalEnergyUsed = powerConsumption(i) * dT + totalEnergyUsed;
% 
% end
totalTime

figure
plot(powerUsed);
%totalEnergyUsed*16 / 3600 / 1000
%plot(time, powerConsumption);
