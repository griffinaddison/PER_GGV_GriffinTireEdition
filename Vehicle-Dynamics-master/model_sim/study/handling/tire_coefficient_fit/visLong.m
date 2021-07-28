function visLong(OptimParameterSet, data)
% Filter data to plot specific conditions:
indFz = data.Fz > 225 & data.Fz < 1600;
indSA1 = rad2deg(data.SA) > -0.25 & rad2deg(data.SA) < 0.25;
indSA2 = rad2deg(data.SA) > -3.25 & rad2deg(data.SA) < -2.75;
indSA3 = rad2deg(data.SA) > -6.25 & rad2deg(data.SA) < -5.75;
filt = indFz & indSA1;

% Create data inputs to do a data replay with MFeval and check the fitting
% quality
evalFz1 = ones(100, 1)*225;
evalFz3 = ones(100, 1)*667;
evalFz4 = ones(100, 1)*1112;
evalNull = zeros(100, 1);
evalSA1 = zeros(100, 1);
evalSA2 = ones(100, 1)*deg2rad(-3);
evalSA3 = ones(100, 1)*deg2rad(-6);
evalSA4 = ones(100, 1)*deg2rad(6);
evalSR = linspace(-1, 2)';
evalVx = ones(100, 1)*11.176;
evalP = ones(100, 1)*83500;


MFinput1 = [evalFz1, evalSR, evalSA1, evalNull, evalNull, evalVx, evalP];
MFinput3 = [evalFz3, evalSR, evalSA1, evalNull, evalNull, evalVx, evalP];
MFinput4 = [evalFz4, evalSR, evalSA1, evalNull, evalNull, evalVx, evalP];

% Call mfeval with the optimized parameters
MFout1 = mfeval(OptimParameterSet,MFinput1,121);
MFout3 = mfeval(OptimParameterSet,MFinput3,121);
MFout4 = mfeval(OptimParameterSet,MFinput4,121);


% Plot data vs Fitted Model
pg = PlotGroup('rows', 1, 'cols', 1);

pg.handleFigure();
pg.createStaticPlot(data.SR(filt), data.Fx(filt),'o');
pg.createStaticPlot(MFout1(:,7), MFout1(:,1),'-', 'linewidth', 2);
pg.createStaticPlot(MFout3(:,7), MFout3(:,1),'-', 'linewidth', 2);
pg.createStaticPlot(MFout4(:,7), MFout4(:,1),'-', 'linewidth', 2);
grid on
xlabel('Slip Ratio')
ylabel('Longitudinal Force [N]')
title('[New] Fx vs SL, -6 deg Slip Angle')
legend('Test Data', '50lbs', '150lbs', '250lbs')

end