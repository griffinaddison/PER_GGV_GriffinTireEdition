function [xVal, yVal] = correlate(messages, xID, yID, zID)
   xVal = messages{xID}.val;
   xTime = messages{xID}.time;
   yTime = messages{yID}.time;
   yPoints = messages{yID}.val;
   zTime = messages{zID}.time;
   zPoints = messages{zID}.val;

   yVal = interp1(yTime, yPoints, xTime, 'linear', 0);
   zVal = interp1(zTime, zPoints, xTime, 'linear', 0);

   figure;
   scatter(xVal, yVal, [], zVal, '.');
end
