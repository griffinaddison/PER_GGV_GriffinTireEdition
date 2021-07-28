function topSpeedVisSim(varargin)
    p = inputParser;
    p.addRequired('simOuts');
    p.parse(varargin{:});

    simOuts = p.Results.simOuts;
    
    labels = {};
    barData = [];
    for i = 1:length(simOuts)
        barData(i, 1) = max(simOuts{i}.dynamicEvents.accel.simOut.dynamicVars.xdot) * 2.23694;
        labels{i} = simOuts{i}.description;
    end
    labels = reordercats(categorical(labels), string(labels));
    
    figure;
    h = bar(labels, barData, 'stacked');
    ylim([0, 80]);
    ylabel('Top Speed [mph]');
    xlabel('Motor w/ Gear Ratio');
    title('Accel Top Speed Motor Sweep [Imperial]');
    legend(h, 'accel');

    for i=1:size(barData,1)
        for j=1:size(barData,2)
            if barData(i,j)>0
                labels_stacked = num2str(barData(i,j),'%.1f');
                hText = text(i, sum(barData(i,1:j),2), labels_stacked);
                set(hText, 'VerticalAlignment','top', 'HorizontalAlignment', 'center','FontSize',10, 'Color','w');
            end
        end
    end
end
