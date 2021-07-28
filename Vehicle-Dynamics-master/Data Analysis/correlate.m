function [xVal, yVal] = correlate(messages, xID, yID)
   xVal = messages{xID}.val;
   xTime = messages{xID}.time;
   yTime = messages{yID}.time;
   yPoints = messages{yID}.val;
   yVal = interp1(yTime, yPoints, xTime, 'linear', 0);
   %figure;
   plot(xVal, yVal, '-');
end
