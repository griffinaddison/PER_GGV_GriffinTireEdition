function pointsVisSim(varargin)
    p = inputParser;
    p.addRequired('simOuts');
    p.parse(varargin{:});

    simOuts = p.Results.simOuts;
    
    labels = {};
    barData = [];
    for i = 1:length(simOuts)
        barData(i, 1) = simOuts{i}.scores.accel;
        barData(i, 2) = simOuts{i}.scores.skidpad;
        barData(i, 3) = simOuts{i}.scores.autocross;
        barData(i, 4) = simOuts{i}.scores.endurance;
        labels{i} = simOuts{i}.description;
    end
    labels = reordercats(categorical(labels), string(labels));
    
    figure;
    h = bar(labels, barData, 'stacked');
    ylabel('Points');
    xlabel('Motor w/ Gear Ratio');
    title('Full Competition Motor Sweep');
    legend(h, {'accel', 'skidpad', 'autocross', 'endurance'});

    for i=1:size(barData,1)
        for j=1:size(barData,2)
            if barData(i,j)>0
                labels_stacked = num2str(barData(i,j),'%.1f');
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
