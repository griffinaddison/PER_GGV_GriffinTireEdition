% Merge Test Runs
load('18R25Brun39_SL_F.mat', 'data') % Drive data

% Load lateral fit
load('Hoosier16-PureLat-v2.mat', 'OptimParameterSet');
InitialParameterSet = OptimParameterSet;

% InitialParameterSet = mfeval.readTIR('FSAE_Defaults.tir');

% Set nominal parameters of the model (DO NOT CHANGE AFTER)
% Unloaded tire radius, 18": 0.2286, 16": 0.2032
InitialParameterSet.UNLOADED_RADIUS = 0.2286;
InitialParameterSet.FNOMIN = 667; % Nominal load
InitialParameterSet.LONGVL = 11.176; % Nominal reference speed
InitialParameterSet.NOMPRES = 83500; % Nominal inflation pressure

% Tweaks to initial conditions

% % SR Tweaks
% InitialParameterSet.PEX1 = -0.001;
% InitialParameterSet.PCX1 = 1.51;

% SL Tweaks
% InitialParameterSet.PEX1 = -1;
InitialParameterSet.PCX1 = 1.8;
InitialParameterSet.PDX1 = 3.05;

% Create the initial parameters for the fitting (seeds)

% Every coeff has a unique name so this is ugly

% LONGITUDINAL COEFFICIENTS
x0(1) = InitialParameterSet.PCX1;   
x0(2) = InitialParameterSet.PDX1;   
x0(3) = InitialParameterSet.PDX2;  
x0(4) = InitialParameterSet.PDX3; 
x0(5) = InitialParameterSet.PEX1; 
x0(6) = InitialParameterSet.PEX2; 
x0(7) = InitialParameterSet.PEX3; 
x0(8) = InitialParameterSet.PEX4;
x0(9) = InitialParameterSet.PKX1;
x0(10) = InitialParameterSet.PKX2;
x0(11) = InitialParameterSet.PKX3;
x0(12) = InitialParameterSet.PHX1;
x0(13) = InitialParameterSet.PHX2;
x0(14) = InitialParameterSet.PVX1;
x0(15) = InitialParameterSet.PVX2;
x0(16) = InitialParameterSet.PPX1;
x0(17) = InitialParameterSet.PPX2;
x0(18) = InitialParameterSet.PPX3;
x0(19) = InitialParameterSet.PPX4;

% Declare the anonymous function (Cost function) for the fitting
% The @ operator creates the handle, and the parentheses () immediately
% after the @ operator include the function input arguments
fun = @(X) pureFxError(X, data, InitialParameterSet);

% Options for the fitting function lsqnonlin
% options = optimoptions(@lsqnonlin, 'FunctionTolerance', 1e-8, 'OptimalityTolerance', 1e-08, ...
%     'StepTolerance', 1e-8, 'MaxFunctionEvaluations', 9999, 'MaxIterations', 999);
options.TolFun = 1e-08;
options.MaxFunEvals = 20000;
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
OptimParameterSet.PCX1 = X_OPTIM(1);
OptimParameterSet.PDX1 = X_OPTIM(2);
OptimParameterSet.PDX2 = X_OPTIM(3);
OptimParameterSet.PDX3 = X_OPTIM(4);
OptimParameterSet.PEX1 = X_OPTIM(5);
OptimParameterSet.PEX2 = X_OPTIM(6);
OptimParameterSet.PEX3 = X_OPTIM(7);
OptimParameterSet.PEX4 = X_OPTIM(8);
OptimParameterSet.PKX1 = X_OPTIM(9);
OptimParameterSet.PKX2 = X_OPTIM(10);
OptimParameterSet.PKX3 = X_OPTIM(11);
OptimParameterSet.PHX1 = X_OPTIM(12);
OptimParameterSet.PHX2 = X_OPTIM(13);
OptimParameterSet.PVX1 = X_OPTIM(14);
OptimParameterSet.PVX2 = X_OPTIM(15);
OptimParameterSet.PPX1 = X_OPTIM(16);
OptimParameterSet.PPX2 = X_OPTIM(17);
OptimParameterSet.PPX3 = X_OPTIM(18);
OptimParameterSet.PPX4 = X_OPTIM(19);

% *****************************VISUALIZE***************************************
visLong(OptimParameterSet, data);

% save('Hoosier16-18-SL-Pure-v2.mat', 'OptimParameterSet');
