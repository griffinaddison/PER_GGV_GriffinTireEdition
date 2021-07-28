pcmTime = 8212;
lastPCMTime = 0;
error = [];
errorTimestamp = 2146907;
lastI =1;


for i = 2:length(mergedValues(:, 2))
    
    if (pcmTime == mergedValues(i, 2) && (lastPCMTime ~= mergedValues(i, 3)) )
    
        if mergedValues(i, 3) - lastPCMTime ~= 1
            mergedValues(i, 3) = lastPCMTime + 1;
        end 
        
        PCMTime = mergedValues(i, 3);
        %error = [error; mergedValues(i, 3)-mergedValues(i, 1)];
        dT = (PCMTime - lastPCMTime)/(i - lastI);
        
        for j = lastI:i
            
            mergedValues(j, 1) = ((j-lastI)*dT  + lastPCMTime)*1000;
            
        end
                lastI = i;
        lastPCMTime = PCMTime;
    end
    
end