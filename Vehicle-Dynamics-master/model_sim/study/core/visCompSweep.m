for i=1:length(simOuts)
    desc = sprintf('dragCoef: %f downCoef: %f', simOuts{i}.stats.dragCoef, simOuts{i}.stats.downforceCoef);
    simOuts{i}.description = 'dragCoef: %f'
end