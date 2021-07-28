function renderGGVPlane(varargin)
    p = inputParser;
    p.addRequired('ggvPlane');
    p.addOptional('viewQuantity', 'powerDelivered');
    p.parse(varargin{:});

    ggvPoints = p.Results.ggvPlane.ggvPoints;
    
    figure
    scatter3([ggvPoints.yddot], [ggvPoints.xddot], ...
            [ggvPoints.(p.Results.viewQuantity)], 60, ...
            [ggvPoints.(p.Results.viewQuantity)], 'filled')

    xlabel('Lateral Acceleration (m/s^2)');
    ylabel('Longitudinal Acceleration (m/s^2)');
    zlabel(p.Results.viewQuantity);

    view(0, 90)
    axis square
    h = colorbar;
    ylabel(h, p.Results.viewQuantity);
end
