function timesVisSim(varargin)
    p = inputParser;
    p.addRequired('simOuts');
    p.parse(varargin{:});

    simOuts = p.Results.simOuts;
    
    labels = {};
    barData = [];
    for i = 1:length(simOuts)
%         barData(i, 1) = simOuts{i}.dynamicEvents.accel.rawTime;
%         barData(i, 2) = simOuts{i}.dynamicEvents.skidpad.rawTime;
        barData(i, 1) = simOuts{i}.dynamicEvents.autocross.simOut.stats.energyDelivered;
        barData(i, 2) = simOuts{i}.dynamicEvents.endurance.simOut.stats.energyDelivered;
        labels{i} = simOuts{i}.description;
    end
    labels = reordercats(categorical(labels), string(labels));
    
    figure;
    h = bar(labels, barData, 'stacked');
    ylabel('Time [s]');
    xlabel('Accel Percentage of Straight');
    title('Accel Percentage Time Sweep');
%     legend(h, {'accel', 'skidpad', 'autocross', 'endurance'});
    legend(h, {'autocross', 'endurance'});

    for i=1:size(barData,1)
        for j=1:size(barData,2)
            if barData(i,j)>0
                labels_stacked = num2str(barData(i,j),'%.3f');
                hText = text(i, sum(barData(i,1:j),2), labels_stacked);
                set(hText, 'VerticalAlignment','top', 'HorizontalAlignment', 'center','FontSize',10, 'Color','w');
                if j == 4
                    tText = text(i, sum(barData(i,1:j),2) + 10, num2str(simOuts{i}.scores.total, '%.1f'));
                    set(tText, 'VerticalAlignment','top', 'HorizontalAlignment', 'center','FontSize',10, 'Color','k');
                end
            end
        end
    end
end
