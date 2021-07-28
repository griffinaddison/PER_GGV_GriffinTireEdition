function [] = renderTrack(radii, distances)
    pos = [0; 0];
    direction = 3 * pi / 2 - 0.6;
    
    hold on
    for i = 1:length(radii)
        center = pos + rotMat2D(direction + pi/2) * [radii(i); 0];
        travel_start = direction + pi/2 + pi * sign(radii(i));
        travel_rads = distances(i) / (radii(i));

        terminal = plot_arc(travel_start, travel_start + travel_rads, ...
                 center(1), center(2), radii(i));
        pos = terminal;
        direction = direction + travel_rads;
    end

    axis equal
end

function terminal = plot_arc(a, b, x0, y0, r)
a1 = a;  % A random direction
a2 = b;
t = linspace(a1,a2);
x = x0 + r*cos(t);
y = y0 + r*sin(t);
plot(x,y,'k-', 'linewidth', 3)
terminal = [x(end); y(end)];
end
