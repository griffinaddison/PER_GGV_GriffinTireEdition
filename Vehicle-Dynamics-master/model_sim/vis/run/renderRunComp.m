function renderRunComp(varargin)
    p = inputParser;
    p.addRequired('runs');
    p.addOptional('legend', [])
    p.addOptional('xQuantity', 'dist');
    p.addOptional('yQuantity', 'longVel');
    p.parse(varargin{:});

    xQuant = p.Results.xQuantity;
    yQuant = p.Results.yQuantity;
    
    figure
    hold on
    for i=1:length(p.Results.runs)
        r = p.Results.runs{i};
        data = r.runData;
        plot(data.(xQuant), data.(yQuant));
    end
    if length(p.Results.legend) > 0
    end
    xlabel(xQuant);
    ylabel(yQuant);
end
