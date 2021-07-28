figure
names = {'DHX HAWK40', 'Emrax 188', 'Emrax 208', 'Emrax 228', 'APM 120R', 'EVO AF125', 'EVO AF130', ...
    'GVK142-100EQW', 'GVK210-100DQW', 'NOVA 30 S WK', 'YASA P400'};
gear_ratios = [3.5, 4.5, 5, 4, 5.5, 5.5, 2, 6, 5, 4.5, 4.5];
x = 1:length(gear_ratios);
accel_times = [4.439, 3.93, 4.023, 3.937, 3.934, 3.922, 3.937, 3.918, 3.946, 3.966, 3.943];
masses = [19, 14.4, 9.3, 12.3, 14, 22, 30.5, 21, 22, 13, 24];
% [hAx, d1, d2] = plotyy(x, [accel_times.', zeros(11, 1)], x, [zeros(11, 1), gear_ratios.'], @bar, @bar);
% set(hAx(2),'xtick',[]) 
% set(hAx(1), 'xticklabel', names);


% ylabel(hAx(2),'Optimal Gear Ratio');
% ylabel(hAx(1),'Best Accel Time [s]');
% ylim(hAx(1), [0, 6.5]);
% ylim(hAx(2), [0, 6.5]);
% legend([d1(1), d2(2)], 'Accel Time', 'Gear Ratio');
bar(masses);
title('Motor Mass');
xticklabels(names);
xtickangle(45)
ylabel('Mass [kg]')