function renderMMD(varargin)
    p = inputParser;
    p.addRequired('mmd');
    p.addOptional('justHull', false);
    p.addOptional('uniformColor', false);
    p.addOptional('color', [0, 0, 1]);
    p.addOptional('label', '');
    p.addOptional('decorations', true)
    p.parse(varargin{:});
    
    mmd = p.Results.mmd;
 
    hold on
    if p.Results.justHull
        yddots = parseField(mmd.hullStatedots, 'ydot');
        hddots = parseField(mmd.hullStatedots, 'hdot');
    
        plot(yddots, hddots, 'color', p.Results.color, 'DisplayName', p.Results.label);
    else
        yddots = parseField(mmd.statedots, 'ydot');
        hddots = parseField(mmd.statedots, 'hdot');

        clist = colormap(winter(size(yddots, 1)));
        for i = 1 : size(yddots, 1)
            if p.Results.uniformColor
                if i == 1
                    plot(yddots(i, :), hddots(i, :), '--', 'color', p.Results.color, ...
                         'DisplayName', p.Results.label);
                else
                    pl = plot(yddots(i, :), hddots(i, :), '--', 'color', p.Results.color);
                    set(get(get(pl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                end
            else
                pl = plot(yddots(i, :), hddots(i, :), '--', 'color', clist(i, :));
                set(get(get(pl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            end
        end

        clist = colormap(autumn(size(hddots, 1)));
        for i = 1 : size(yddots, 2)
            if p.Results.uniformColor
                if i == 1
                    plot(yddots(:, i), hddots(:, i), 'color', p.Results.color, ...
                         'DisplayName', p.Results.label);
                else
                    pl = plot(yddots(:, i), hddots(:, i), 'color', p.Results.color);
                    set(get(get(pl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                end
            else
                pl = plot(yddots(:, i), hddots(:, i), 'color', clist(i, :));
                set(get(get(pl,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            end
        end
    end
    
    if p.Results.decorations
        stats = calculateMMDStats(mmd);
        sc = scatter(stats.steadyGrip, 0, 20, p.Results.color);
        set(get(get(sc,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end

    xlabel('Lat accel (m/s^2)');
    ylabel('Yaw accel (rad/s^2)');
    title('MMD | solid <-> const steer | dotted <-> const bodySA')
    grid on
    
    if p.Results.decorations
        annotation('textbox', [.85 .25 .3 .3], 'String', 'oversteer', 'FitBoxToText', 'on');
        annotation('textbox', [.85 .21 .3 .3], 'String', 'understeer', 'FitBoxToText', 'on');
    end
end
