function renderGGV(varargin)
    p = inputParser;
    p.addRequired('ggv');
    p.addOptional('useHull', false);
    p.addOptional('renderHull', false);
    p.addOptional('viewQuantity', 'powerDelivered');
    p.addOptional('transformUnits', false);
    p.parse(varargin{:});
    
    if p.Results.useHull
        ggvPoints = p.Results.ggv.hullGGVPoints;
    else
        ggvPoints = p.Results.ggv.ggvPoints;
    end
    
    if p.Results.transformUnits
        points = [[ggvPoints.yddot].' / 9.8, [ggvPoints.xddot].' / 9.8, [ggvPoints.xdot].' * 2.23];
    else
        points = [[ggvPoints.yddot].', [ggvPoints.xddot].', [ggvPoints.xdot].'];
    end
    
    figure
    set(gcf,'color','w');
    hold on;
    if p.Results.renderHull
        k = boundary(points);
        trisurf(k, points(:,1), points(:,2), points(:,3),...
                zeros(size(points(:, 1))), 'FaceAlpha', 0.8)
    end

    if p.Results.transformUnits
        xlabel('Lateral Acceleration (g)');
        ylabel('Longitudinal Acceleration (g)');
        zlabel('Speed (mph)');
    else
        xlabel('Lateral Acceleration (m/s^2)');
        ylabel('Longitudinal Acceleration (m/s^2)');
        zlabel('Speed (m/s)');
    end

    set(gca, 'FontSize', 14);
    shading interp;
    
    if strcmp(p.Results.viewQuantity, 'none')
        scatter3(points(:, 1), points(:, 2), points(:, 3), 60, 'k', 'filled');
    else
        scatter3(points(:, 1), points(:, 2), points(:, 3), 60, ...
            [ggvPoints.(p.Results.viewQuantity)], 'filled');
        h = colorbar;
        ylabel(h, p.Results.viewQuantity);
    end

    h = get(gca,'DataAspectRatio');
    if h(3)==1
          set(gca,'DataAspectRatio',[1 1 1/max(h(1:2))])
    else
          set(gca,'DataAspectRatio',[1 1 h(3)])
    end

    if p.Results.transformUnits
        xlim([-4 4]);
        ylim([-4 4]);
    else
        xlim([-40 40]);
        ylim([-40 40]);
    end
end
