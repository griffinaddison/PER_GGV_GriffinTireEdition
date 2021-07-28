figure
hold on
 plot(split{8302}.time, -split{8302}.val);
ylim([-2000 2000]);
yyaxis right
 plot(split{8607}.time, split{8607}.val);

ylim([-100 100]);