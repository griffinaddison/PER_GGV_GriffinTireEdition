% Merge Test Runs
load('16R25Brun6_F.mat', 'data') % Drive data

% Load pure fit
load('Hoosier16-18-Pure.mat', 'OptimParameterSet');
InitialParameterSet = OptimParameterSet;

% Set nominal parameters of the model (DO NOT CHANGE AFTER)
% Unloaded tire radius, 18": 0.2286, 16": 0.2032
InitialParameterSet.UNLOADED_RADIUS = 0.2032;
InitialParameterSet.FNOMIN = 667; % Nominal load
InitialParameterSet.LONGVL = 11.176; % Nominal reference speed
InitialParameterSet.NOMPRES = 83500; % Nominal inflation pressure

% Create the initial parameters for the fitting (seeds)

% Every coeff has a unique name so this is ugly

% LATERAL COEFFICIENTS
x0(1)  = InitialParameterSet.RBY1;
x0(2)  = InitialParameterSet.RBY2;
x0(3)  = InitialParameterSet.RBY3;
x0(4)  = InitialParameterSet.RBY4;
x0(5)  = InitialParameterSet.RCY1;
x0(6)  = InitialParameterSet.REY1;
x0(7)  = InitialParameterSet.REY2;
x0(8)  = InitialParameterSet.RHY1;
x0(9)  = InitialParameterSet.RHY2;
x0(10)  = InitialParameterSet.RVY1;
x0(11)  = InitialParameterSet.RVY2;
x0(12)  = InitialParameterSet.RVY3;
x0(13)  = InitialParameterSet.RVY4;
x0(14)  = InitialParameterSet.RVY5;
x0(15)  = InitialParameterSet.RVY6;


% Declare the anonymous function (Cost function) for the fitting
% The @ operator creates the handle, and the parentheses () immediately
% after the @ operator include the function input arguments
fun = @(X) combinedFyError(X, data, InitialParameterSet);

% Options for the fitting function lsqnonlin
% options = optimoptions(@lsqnonlin, 'FunctionTolerance', 1e-8, 'OptimalityTolerance', 1e-08, ...
%     'StepTolerance', 1e-8, 'MaxFunctionEvaluations', 9999, 'MaxIterations', 999);
options.TolFun = 1e-08;
options.MaxFunEvals = 33333;
options.MaxIter = 3333;
options.Display = 'iter';

% Non-linear least squares fitting formula
% lsqnonlin will try to minimize the output of the cost function (error).
% Go to the cost function "costFyPure" to check how this is performed
X_OPTIM = lsqnonlin(fun,x0,[],[],options);

% Create a copy of the initial parameters and replace the fitted parameters
OptimParameterSet = InitialParameterSet;

% LAT
OptimParameterSet.RBY1 = X_OPTIM(1);
OptimParameterSet.RBY2 = X_OPTIM(2);
OptimParameterSet.RBY3 = X_OPTIM(3);
OptimParameterSet.RBY4 = X_OPTIM(4);
OptimParameterSet.RCY1 = X_OPTIM(5);
OptimParameterSet.REY1 = X_OPTIM(6);
OptimParameterSet.REY2 = X_OPTIM(7);
OptimParameterSet.RHY1 = X_OPTIM(8);
OptimParameterSet.RHY2 = X_OPTIM(9);
OptimParameterSet.RVY1 = X_OPTIM(10);
OptimParameterSet.RVY2 = X_OPTIM(11);
OptimParameterSet.RVY3 = X_OPTIM(12);
OptimParameterSet.RVY4 = X_OPTIM(13);
OptimParameterSet.RVY5 = X_OPTIM(14);
OptimParameterSet.RVY6 = X_OPTIM(15);

% Scale friction
% OptimParameterSet.LMUX = 0.6;
% OptimParameterSet.LMUY = 0.6;

% *****************************VISUALIZE***************************************
visLat(OptimParameterSet, data);
