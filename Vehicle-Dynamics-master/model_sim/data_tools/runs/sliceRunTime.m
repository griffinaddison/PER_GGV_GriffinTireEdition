function [slicedRunOut] = sliceRunTime(runData, startTime, endTime)
    startIndex = find(runData.t >= startTime, 1);
    endIndex = find(runData.t <= endTime, 1, 'last');
    
    slicedRunOut = sliceRunIndex(runData, startIndex, endIndex);
end
