classdef PlotGroup < handle
    properties
        makeSubPlots
        rows
        cols
        posIndex

        staticPlots
        dynamicPlots
    end

    methods
        function obj = PlotGroup(varargin)
            p = inputParser;
            p.addParameter('makeSubPlots', true);
            p.addParameter('rows', 1);
            p.addParameter('cols', 1);
            p.parse(varargin{:});
            
            obj.makeSubPlots = p.Results.makeSubPlots;
            obj.rows = p.Results.rows;
            obj.cols = p.Results.cols;
            obj.posIndex = 1;
            obj.staticPlots = {};
            obj.dynamicPlots = {};

            if obj.makeSubPlots
                figure;
            end
        end

        function handleFigure(obj)
            if obj.makeSubPlots
                subplot(obj.rows, obj.cols, obj.posIndex);
                obj.posIndex = obj.posIndex + 1;
                %set(gca,'FontSize', 20);
            else
                figure;
            end
            hold on;
        end

        function handleLegend(obj, labels)
            if obj.makeSubPlots
                legendflex(labels);
            else
                legendflex(labels, 'fontsize', 40);
            end
        end
        
        function addStatic(obj, chart)
            obj.staticPlots{end+1} = chart;
        end

        function addDynamic(obj, chart)
            obj.dynamicPlots{end+1} = chart;
        end

        function createStaticPlot(obj, varargin)
            obj.addStatic(plot(varargin{:}))
        end

        function createDynamicPlot(obj, varargin)
            obj.addDynamic(plot(varargin{:}))
        end

        function [plots] = convertDynamicPlots(obj)
            plots = DynamicPlot.empty;
            for plot = obj.dynamicPlots
                plots(end+1) = DynamicPlot(plot{1});
            end
        end
    end
end
