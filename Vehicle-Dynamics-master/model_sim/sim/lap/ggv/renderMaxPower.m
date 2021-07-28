function renderMaxPower(ggv)
    powerFind = @(i) max([ggv.planes(i).ggvPoints.powerDelivered]);
    powers = arrayfun(powerFind, 1:length(ggv.vs));
    
    figure
    plot(ggv.vs, real(powers));
    xlabel('Velocity (m/s)');
    ylabel('Max delivered power (W)');
end
