function [] = timePlots(tireData)
    figure
    hold on
    plot(tireData.ET, tireData.SA);
    plot(tireData.ET, tireData.FZ);
    plot(tireData.ET, tireData.IA);
    plot(tireData.ET, tireData.P);

    xlabel('t');
    legend('SA', 'FZ', 'IA', 'P');
end
