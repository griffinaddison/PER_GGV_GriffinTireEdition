classdef Visualizer < handle
    properties
        visParams % A struct of parameters for running the visualization
        animator
        animFig
        dynamicPlots
        
        simTimes
        visTimes % interpolated version of simTimes
        dynamicVars
        interpolateDynamics
        
        time % The time of the simulation
        tIndex % The counter corresponding to the index in the time vector
        isPaused
    end
    
    methods
        function obj = Visualizer(varargin)
            p = inputParser;
            p.addRequired('visParams');
            p.addRequired('animator', @(x) isa(x, 'Animator'));
            p.addRequired('times');
            p.addRequired('dynamicVars');
            p.addParameter('interpolateDynamics', true);
            p.parse(varargin{:});

            obj.visParams = p.Results.visParams;
            obj.animator = p.Results.animator;

            obj.time = 0;
            obj.tIndex = 1;
            obj.isPaused = false;
          
            obj.simTimes = p.Results.times;
            if p.Results.interpolateDynamics
                % Interpolate all the dynamics variables at the appropriate times
                visTimes = 0 : obj.visParams.dt : obj.simTimes(end);
                fields = fieldnames(p.Results.dynamicVars);
                for k = 1:length(fields)
                    if isvector(k)
                        dv.(fields{k}) = interp1(obj.simTimes, p.Results.dynamicVars.(fields{k}), visTimes);
                    end
                end
                obj.visTimes = visTimes;
            else
                obj.visTimes = obj.simTimes;
            end
            
            obj.dynamicVars = dv;
            obj.interpolateDynamics = p.Results.interpolateDynamics;
        end
        
        function addDynamicPlots(obj, plots)
            obj.dynamicPlots = plots;
        end
         
        function visualize(obj)
            % Initialize the figure if it hasn't been created yet
            if isempty(obj.animFig) || ~isvalid(obj.animFig)
                initializeFigure(obj);
            end
            
            obj.animator.init(obj.animFig);

            for dynamicPlot = obj.dynamicPlots
                dynamicPlot.precalcInterp(obj.simTimes, obj.visTimes);
            end
            
            while isvalid(obj.animFig)
                % Render the animation
                for dynamicPlot = obj.dynamicPlots
                    dynamicPlot.updateTimeMarker(obj.tIndex);
                end
                 
                fields = fieldnames(obj.dynamicVars);
                for k = 1:length(fields)
                    if isvector(k)
                        state.(fields{k}) = obj.dynamicVars.(fields{k})(obj.tIndex);
                    end
                end
                
                obj.animator.render(obj.time, state);
                
                % Increment the time
                if ~obj.isPaused
                    % If the dynamics are already interpolated, use first incrementation scheme
                    % Otherwise time jumps
                    if obj.interpolateDynamics
                        obj.tIndex = obj.tIndex + 1;
                        if obj.tIndex > length(obj.visTimes)
                            break;
                        end
                        obj.time = obj.visTimes(obj.tIndex);
                    else
                        obj.time = obj.time + obj.visParams.dt;
                        if obj.time > obj.visTimes(end);
                            break;
                        end
                        while obj.tIndex <= length(obj.visTimes) && obj.time >= obj.visTimes(obj.tIndex)
                            obj.tIndex = obj.tIndex + 1;
                        end
                    end
                end
                
                % Pause the playback slightly
                pause(obj.visParams.dt * obj.visParams.pauseFactor);
            end
           
            obj.time = 0;
            obj.tIndex = 1;
        end
        
        function resetVisualization(obj)
            if obj.time ~= 0
                obj.time = 0;
                obj.tIndex = 1;
            else
                obj.visualize();
            end
        end
        
        function togglePause(obj)
            obj.isPaused = ~obj.isPaused;
        end
    end
    
    methods (Access = private)
        function initializeFigure(obj)
            obj.animFig = figure();
            toolbar = uitoolbar(obj.animFig);
            % Prevent clf from clearing the toolbar
            toolbar.HandleVisibility = 'off';
            
            % Add rewind button
            [img,map] = imread('rewind.gif');
            p = uipushtool(toolbar, 'TooltipString', 'Replay animation', ...
                  'ClickedCallback', @(im, e) obj.resetVisualization());
            icon = ind2rgb(img, map);
            p.CData = icon;
            
            % Add pause/play button
            [img,~] = imread('pauseplay.png', 'BackGroundColor', [0.95 0.95 0.95]);
            p = uipushtool(toolbar, 'TooltipString', 'Pause/play animation', ...
                  'ClickedCallback', @(im, e) obj.togglePause());
            p.CData = img;
        end
    end
end

