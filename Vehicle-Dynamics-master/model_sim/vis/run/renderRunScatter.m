function renderRunScatter(varargin)
    p = inputParser;
    p.addRequired('runOut');
    p.addOptional('xQuantity', 'dist');
    p.addOptional('yQuantity', 'longVel');
    p.parse(varargin{:});
    
    data = p.Results.runOut.runData;
    xQuant = p.Results.xQuantity;
    yQuant = p.Results.yQuantity;
    
    figure
    hold on
    scatter(data.(xQuant), data.(yQuant))
    xlabel(xQuant);
    ylabel(yQuant);
end
