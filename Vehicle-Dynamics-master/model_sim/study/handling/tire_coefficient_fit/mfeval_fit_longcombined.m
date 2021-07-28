% Merge Test Runs
load('18R25Brun39_SL_F_SA.mat', 'data') % Drive data

% Load pure fit
load('Hoosier16-18-SL-Pure-v3.mat', 'OptimParameterSet');
InitialParameterSet = OptimParameterSet;

% Set nominal parameters of the model (DO NOT CHANGE AFTER)
% Unloaded tire radius, 18": 0.2286, 16": 0.2032
InitialParameterSet.UNLOADED_RADIUS = 0.2286;
InitialParameterSet.FNOMIN = 667; % Nominal load
InitialParameterSet.LONGVL = 11.176; % Nominal reference speed
InitialParameterSet.NOMPRES = 83500; % Nominal inflation pressure

% Create the initial parameters for the fitting (seeds)

% Every coeff has a unique name so this is ugly

% LONG
x0(1)  = InitialParameterSet.RBX1;
x0(2)  = InitialParameterSet.RBX2;
x0(3)  = InitialParameterSet.RBX3;
x0(4)  = InitialParameterSet.RCX1;
x0(5)  = InitialParameterSet.REX1;
x0(6)  = InitialParameterSet.REX2;
x0(7)  = InitialParameterSet.RHX1;

% Declare the anonymous function (Cost function) for the fitting
% The @ operator creates the handle, and the parentheses () immediately
% after the @ operator include the function input arguments
fun = @(X) combinedFxError(X, data, InitialParameterSet);

% Options for the fitting function lsqnonlin
% options = optimoptions(@lsqnonlin, 'FunctionTolerance', 1e-8, 'OptimalityTolerance', 1e-08, ...
%     'StepTolerance', 1e-8, 'MaxFunctionEvaluations', 9999, 'MaxIterations', 999);
options.TolFun = 1e-08;
options.MaxFunEvals = 33333;
options.MaxIter = 3333;
options.Display = 'iter';
% options.Algorithm = 'levenberg-marquardt';

% Non-linear least squares fitting formula
% lsqnonlin will try to minimize the output of the cost function (error).
% Go to the cost function "costFyPure" to check how this is performed
X_OPTIM = lsqnonlin(fun,x0,[],[],options);

% Create a copy of the initial parameters and replace the fitted parameters
OptimParameterSet = InitialParameterSet;

% LONG
OptimParameterSet.RBX1 = X_OPTIM(1);
OptimParameterSet.RBX2 = X_OPTIM(2);
OptimParameterSet.RBX3 = X_OPTIM(3);
OptimParameterSet.RCX1 = X_OPTIM(4);
OptimParameterSet.REX1 = X_OPTIM(5);
OptimParameterSet.REX2 = X_OPTIM(6);
OptimParameterSet.RHX1 = X_OPTIM(7);

% *****************************VISUALIZE***************************************
visLong(OptimParameterSet, data);

% save('Hoosier16-18-SL-CombLong.mat', 'OptimParameterSet');