function renderRun(varargin)
    p = inputParser;
    p.addRequired('runOut'); % Run or sim out
    p.addOptional('viewQuantity', 't');
    p.parse(varargin{:});
    
    data = p.Results.runOut.runData;
    
    figure
    scatter3(data.x, data.y, data.(p.Results.viewQuantity), ...
        60, data.(p.Results.viewQuantity), 'filled');

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
