function fullVisSim(simOut)
    % To visualize the car itself
    visParams.dt = 0.03;
    visParams.pauseFactor = 1;

    ca = CarAnimator(simOut);
    vis = Visualizer(visParams, ca, simOut.t, simOut.dynamicVars);

    % Add the dynamic plots
    [pg1, pg2] = fullDynamicPlots(simOut);
    vis.addDynamicPlots(pg1.convertDynamicPlots());
    vis.addDynamicPlots(pg2.convertDynamicPlots());

    % Run the visualization
    vis.visualize();
end

