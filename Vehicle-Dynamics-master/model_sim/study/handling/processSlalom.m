function [data] = processSlalom(xs, ys)
%     % First roughly rotate data along x axis
%     slalomLine = polyfit(xs, ys, 1);
%     rotData = rotMat2D(-atan(slalomLine(1))) * [xs.'; ys.'];
% 
%     % Second pass is needed to flatten peaks
%     [~, loc] = findpeaks(rotData(2, :));
%     rotPeaks = rotData(:, loc);
%     peaksLine = polyfit(rotPeaks(1, :), rotPeaks(2, :), 1);
%     rotData = rotMat2D(-atan(peaksLine(1))) * rotData;
% 
%     % Center data vertically
%     rotData(2, :) = rotData(2, :) - ...
%                 (min(rotData(2, :)) + max(rotData(2, :))) / 2;
%     
%     data.xs = rotData(1, :).';
%     data.ys = rotData(2, :).';
    
    data.xs = xs;
    data.ys = ys;
end
