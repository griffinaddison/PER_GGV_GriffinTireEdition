function [slicedRunOut] = sliceRunIndex(runData, startIndex, endIndex)
    runData = vecStructToStructArray(runData);
    slicedData = runData(startIndex : endIndex);
    
    initialTime = slicedData(1).t;
    initialDist = slicedData(1).dist;
    initialEnergy = slicedData(1).energyDelivered;
    for j = 1 : length(slicedData)
        slicedData(j).t = slicedData(j).t - initialTime;
        slicedData(j).dist = slicedData(j).dist - initialDist;
        slicedData(j).energyDelivered = slicedData(j).energyDelivered ...
           - initialEnergy;
    end

    slicedRunOut.runData = structArrayToVecStruct(slicedData);
    slicedRunOut.stats.finishTime = max([slicedData.t]);
    slicedRunOut.stats.energyDelivered = max([slicedData.energyDelivered]);
end
