function trackVis(track, pg)
    sectorLength = 1;
    [xs, ys, ~, ~] = createSectors(track.distances, track.radii, sectorLength);
    if isequal(pg, [])
        pg = PlotGroup('rows', 1, 'cols', 1);
        pg.handleFigure();
        title('Track')
    end
    pg.createStaticPlot(xs, ys);

end

