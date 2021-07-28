function [fitresult, gof] = fitSinGyro(gyroTime, gyroVal)
%CREATEFIT(GYROTIME,GYROVAL)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : gyroTime
%      Y Output: gyroVal
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 19-Sep-2017 17:51:31


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( gyroTime, gyroVal );

% Set up fittype and options.
ft = fittype( 'A*sind(w*t+p)', 'independent', 't', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [1000 -180 0];
opts.MaxFunEvals = 10000;
opts.MaxIter = 10000;
opts.StartPoint = [0.489764395788231 0.445586200710899 0.646313010111265];
opts.Upper = [3000 180 0.5];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'untitled fit 1' );
h = plot( fitresult, xData, yData );
legend( h, 'gyroVal vs. gyroTime', 'untitled fit 1', 'Location', 'NorthEast' );
% Label axes
xlabel gyroTime
ylabel gyroVal
grid on


