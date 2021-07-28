classdef RunRenderManager < handle
    properties
        % Optional image to render against in background
        baseImage
        % The ground truth width of the image (in meters)
        imageWidth 
        % The [x, y] zero point on the image (in pixels)
        % Should correspond with start of lap
        imageZero
        hasImage
        
        % Cell array of run data
        runDatas
        runRots
        descriptions

        % The track (optional)
        track
        % The heading of the car at the start of the lap
        trackHeading
        hasTrack
    end

    methods
        function obj = RunRenderManager(varargin)
            p = inputParser;
            % Path from root directory of project
            p.addOptional('baseImage', []);
            p.addOptional('imageWidth', 0);
            p.addOptional('imageZero', [0, 0]);
            p.parse(varargin{:});
            
            if p.Results.baseImage ~= []
                obj.baseImage = imread(strcat(rootPath(), p.Results.baseImage));
                obj.imageWidth = p.Results.imageWidth;
                obj.imageZero = p.Results.imageZero;
                obj.hasImage = true;
            end

            obj.hasImage = false;
            obj.hasTrack = false;
        end
        
        function setImage(obj, baseImage, imageWidth, imageZero)
            obj.baseImage = imread(strcat(rootPath(), baseImage));
            obj.imageWidth = imageWidth;
            obj.imageZero = imageZero;
            obj.hasImage = true;
        end

        function setTrack(obj, track, trackHeading)
            obj.track = track;
            obj.trackHeading = trackHeading;
            obj.hasTrack = true;
        end
        
        function addRunData(obj, runData, runRot, description)
            % Adds data to plot (can be either sim or actual)
            % Run rot specifies how much to rotate the data to line it up
            % Description is what the associated text label should be
            obj.runDatas{end+1} = runData;
            obj.runRots{end+1} = runRot;
            obj.descriptions{end+1} = description;
        end
        
        function render(obj, varargin)
            p = inputParser;
            p.addOptional('viewQuantity', 'deltat');
            p.parse(varargin{:});
            
            figure
            hold on
        
            if obj.hasImage
                imshow(obj.baseImage);
                [zx, zy] = obj.toImageCoords([0], [0]);
                scatter(zx, zy, 120, 'kd', 'filled');
            end

            if obj.hasTrack
                [txs, tys] = obj.createTrackPoints(0.2);
                if obj.hasImage
                    [ptxs, ptys] = obj.toImageCoords(txs, tys);
                    plot(ptxs, ptys, 'k', 'LineWidth', 2);
                else
                    plot(txs, tys, 'k', 'LineWidth', 2);
                end
            end
            
            shiftFactor = 5;
            for i = 1:length(obj.runDatas)
                data = obj.runDatas{i};
                if strcmp(p.Results.viewQuantity, 'deltat')
                    quantity = [data.t] - [obj.runDatas{1}.t];
                else
                    quantity = [data.(p.Results.viewQuantity)];
                end

                rotated = rotMat2D(obj.runRots{i}) * ...  
                            [data.x.'; data.y.'];
                xs = rotated(1, :);
                ys = rotated(2, :);
                
                % Shift so graphs aren't on top of each other
                [xshift, yshift] = obj.outwardsShift(...
                    xs, ys, shiftFactor * (i-1));

                scatter3(xshift, yshift, quantity, 60, quantity, 'filled');
            end

            % Square x and y axes but not z
            h = get(gca,'DataAspectRatio');
            if h(3)==1
                  set(gca,'DataAspectRatio',[1 1 1/max(h(1:2))])
            else
                  set(gca,'DataAspectRatio',[1 1 h(3)])
            end
            view(0,90)

            h = colorbar;
            ylabel(h, p.Results.viewQuantity);
        end
    end

    methods (Access = protected)
        function [xshifts, yshifts] = outwardsShift(obj, xs, ys, shift)
            % Expands data points outward (think like a shell in CAD)
            xshifts = zeros(size(xs));
            yshifts = zeros(size(ys));

            for i = 2:length(xs)
                delta = [xs(i) - xs(i - 1), ys(i) - ys(i - 1)];
                outwardDir = atan2(delta(2), delta(1));
                shell = rotMat2D(outwardDir) * [0; shift];
                xshifts(i) = xs(i) + shell(1);
                yshifts(i) = ys(i) + shell(2);
                if i == 2
                    xshifts(1) = xs(1) + shell(1);
                    yshifts(1) = ys(1) + shell(2);
                end
            end
        end
        
        function [pixelX, pixelY] = toImageCoords(obj, xs, ys)
            scale = size(obj.baseImage, 2) / obj.imageWidth;
            pixelX = xs * scale + obj.imageZero(1);
            pixelY = -(ys * scale) + obj.imageZero(2);
        end

        function [xs, ys] = createTrackPoints(obj, spacing)
            distances = obj.track.distances;
            radii = obj.track.radii;

            assert(length(radii) == length(distances), ...
                'Need same length radii and distances')
            
            xs = [];
            ys = [];
            
            pos = [0; 0];
            h = obj.trackHeading;
            for i = 1:length(distances)
                numPoints = distances(i) / spacing;

                center = pos + rotMat2D(h + pi/2) * [radii(i); 0];
                travelStart = h + pi/2 + pi * sign(radii(i));
                travelRads = distances(i) / radii(i);

                angles = linspace(travelStart, travelStart + travelRads, numPoints);
                
                [x, y, ~] = arcPoints(...
                         angles, center(1), center(2), radii(i));

                pos = [x(end); y(end)];
                h = h + travelRads;

                xs = [xs, x];
                ys = [ys, y];
            end
        end
    end
end
