function plotSweep(varargin)
    p = inputParser;
    p.addRequired('sweepOut');
    p.parse(varargin{:});

    sweepOut = p.Results.sweepOut;
    
    points = reshape(sweepOut.points, ...
                     [length(sweepOut.cls), ...
                      length(sweepOut.cds)]);

    surf(sweepOut.cls, ...
        sweepOut.cds, ...
        points);

    xlabel('CL');
    ylabel('CD');
    zlabel('Dynamic points competition');
end

