classdef DynamicPlot < handle
    properties
        basePlot % The base plot (2D)
        markerPlot % The marker plot
        markerXs
        markerYs
    end
    
    methods
        function obj = DynamicPlot(plot)
            obj.basePlot = plot;
        end
        
        function precalcInterp(obj, simTimes, visTimes)
            obj.markerXs = interp1(simTimes, obj.basePlot.XData, visTimes);
            obj.markerYs = interp1(simTimes, obj.basePlot.YData, visTimes);
        end

        function updateTimeMarker(obj, tIndex)
            markerX = obj.markerXs(tIndex);
            markerY = obj.markerYs(tIndex);
            if isempty(obj.markerPlot)
                hold(obj.basePlot.Parent, 'on');
                marker = plot(obj.basePlot.Parent, markerX, markerY, 'o');
                marker.Color = obj.basePlot.Color;
                obj.markerPlot = marker;
            else
                obj.markerPlot.XData = markerX;
                obj.markerPlot.YData = markerY;
            end
        end
    end
end

