function visLat(OptimParameterSet, data)
% Filter data to plot specific conditions:
indFz = data.Fz > 200 & data.Fz < 1150;    % 667 N
filt = indFz;

% Create data inputs to do a data replay with MFeval and check the fitting
% quality
evalFz1 = ones(100, 1)*222;
evalFz2 = ones(100, 1)*445;
evalFz3 = ones(100, 1)*667;
evalFz4 = ones(100, 1)*889;
evalFz5 = ones(100, 1)*1112;
evalNull = zeros(100, 1);
evalSA = linspace(-1, 2)';
evalSR1 = zeros(100, 1);
evalSR2 = zeros(100, 1) * -0.5;
evalSR3 = zeros(100, 1) * 0.5;
evalVx = ones(100, 1)*11.176;
evalP = ones(100, 1)*83500;


MFinput1 = [evalFz1, evalSR3, evalSA, evalNull, evalNull, evalVx, evalP];
MFinput2 = [evalFz2, evalSR3, evalSA, evalNull, evalNull, evalVx, evalP];
MFinput3 = [evalFz3, evalSR3, evalSA, evalNull, evalNull, evalVx, evalP];
MFinput4 = [evalFz4, evalSR3, evalSA, evalNull, evalNull, evalVx, evalP];
MFinput5 = [evalFz5, evalSR3, evalSA, evalNull, evalNull, evalVx, evalP];

% Call mfeval with the optimized parameters
MFout1 = mfeval(OptimParameterSet,MFinput1,121);
MFout2 = mfeval(OptimParameterSet,MFinput2,121);
MFout3 = mfeval(OptimParameterSet,MFinput3,121);
MFout4 = mfeval(OptimParameterSet,MFinput4,121);
MFout5 = mfeval(OptimParameterSet,MFinput5,121);

% Plot data vs Fitted Model
pg = PlotGroup('rows', 1, 'cols', 1);
pg.handleFigure();
pg.createStaticPlot(data.SA(filt), data.Fy(filt),'o');
pg.createStaticPlot(MFout1(:,8), MFout1(:,2),'-', 'linewidth', 2);
pg.createStaticPlot(MFout2(:,8), MFout2(:,2),'-', 'linewidth', 2);
pg.createStaticPlot(MFout3(:,8), MFout3(:,2),'-', 'linewidth', 2);
pg.createStaticPlot(MFout4(:,8), MFout4(:,2),'-', 'linewidth', 2);
pg.createStaticPlot(MFout5(:,8), MFout5(:,2),'-', 'linewidth', 2);
grid on
xlabel('Slip Angle [rad]')
ylabel('Lateral Force [N]')
title('Fy vs SA')
legend('Data', 'Model: Fz= 667N')

% save('Hoosier16-PureLat.mat', 'OptimParameterSet');
end

