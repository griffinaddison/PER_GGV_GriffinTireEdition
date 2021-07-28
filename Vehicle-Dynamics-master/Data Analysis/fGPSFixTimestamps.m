fGpsMillisID = 8307;
overflowCounter = 0;
lastGPSTime = 0;
gpsMillisOffset = 240;
error = [];
errorTimestamp = 2146907;
for i = 1:length(mergedValues(:, 2))
   
    if (mergedValues(i, 2) == fGpsMillisID)
    
        GPSTime = mergedValues(i, 3);
        if GPSTime < lastGPSTime
            %fps millis overflow, increment to next second
            overflowCounter = overflowCounter + 1;
        end
        lastGPSTime = GPSTime;
        mergedValues(i, 3) = overflowCounter*1000 + GPSTime - gpsMillisOffset;
        error = [error; mergedValues(i, 3)-mergedValues(i, 1)];
        dT = (GPSTime - lastGPSTime)/(i - lastI);
        
        for j = lastI:i
            
            mergedValues(j, 1) = (j-lastI)*dT + overflowCounter*1000 + lastGPSTime - gpsMillisOffset;
            
        end
                lastI = i;

    end
    
end