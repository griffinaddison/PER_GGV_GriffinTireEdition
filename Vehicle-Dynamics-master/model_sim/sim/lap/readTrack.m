function [track] = readTrack(varargin)
    p = inputParser;
    p.addRequired('trackName');
    % Whether to flip the clockwise / counterclockwise direction
    p.addOptional('reverse', false);
    p.parse(varargin{:});

    filePath = strcat(rootPath(), '/resources/data/tracks/', ...
                      p.Results.trackName, '.json');
    track = jsondecode(fileread(filePath));

    if p.Results.reverse
        track.distances = flipud(track.distances);
        track.radii = -flipud(track.radii);
    end
end
