% Merge Test Runs
load('2020lateral.mat', 'data') % Drive data

% Load a TIR file as a starting point for the fitting
InitialParameterSet = mfeval.readTIR('FSAE_Defaults.tir');

% Set nominal parameters of the model (DO NOT CHANGE AFTER)
% Unloaded tire radius, 18": 0.2286 meters, 16": 0.2032 meters
InitialParameterSet.UNLOADED_RADIUS = 0.2032;
InitialParameterSet.FNOMIN = 667; % Nominal load
InitialParameterSet.LONGVL = 11.176; % Nominal reference speed in meters per second
InitialParameterSet.NOMPRES = 83500; % Nominal inflation pressure

% Create the initial parameters for the fitting (seeds)

% Every coeff has a unique name so this is ugly

% LATERAL COEFFICIENTS
x0(1)  = InitialParameterSet.PCY1;   %Shape factor Cfy for lateral forces
x0(2)  = InitialParameterSet.PDY1;   %Lateral friction Muy
x0(3)  = InitialParameterSet.PDY2;   %Variation of friction Muy with load
x0(4)  = InitialParameterSet.PDY3;   %Variation of friction Muy with squared camber
x0(5)  = InitialParameterSet.PEY1;   %Lateral curvature Efy at Fznom
x0(6)  = InitialParameterSet.PEY2;   %Variation of curvature Efy with load
x0(7)  = InitialParameterSet.PEY3;   %Zero order camber dependency of curvature Efy
x0(8)  = InitialParameterSet.PEY4;   %Variation of curvature Efy with camber
x0(9)  = InitialParameterSet.PEY5;   %Variation of curvature Efy with camber squared
x0(10) = InitialParameterSet.PKY1;   %Maximum value of stiffness Kfy/Fznom
x0(11) = InitialParameterSet.PKY2;   %Load at which Kfy reaches maximum value
x0(12) = InitialParameterSet.PKY3;   %Variation of Kfy/Fznom with camber
x0(13) = InitialParameterSet.PKY4;   %Curvature of stiffness Kfy
x0(14) = InitialParameterSet.PKY5;   %Peak stiffness variation with camber squared
x0(15) = InitialParameterSet.PKY6;   %Fy camber stiffness factor
x0(16) = InitialParameterSet.PKY7;   %Vertical load dependency of camber stiffness
x0(17) = InitialParameterSet.PHY1;   %Horizontal shift Shy at Fznom
x0(18) = InitialParameterSet.PHY2;   %Variation of shift Shy with load
x0(19) = InitialParameterSet.PVY1;   %Vertical shift in Svy/Fz at Fznom
x0(20) = InitialParameterSet.PVY2;   %Variation of shift Svy/Fz with load
x0(21) = InitialParameterSet.PVY3;   %Variation of shift Svy/Fz with camber
x0(22) = InitialParameterSet.PVY4;   %Variation of shift Svy/Fz with camber and load
x0(23) = InitialParameterSet.PPY1;   %influence of inflation pressure on cornering stiffness
x0(24) = InitialParameterSet.PPY2;   %influence of inflation pressure on dependency of nominal tyre load on cornering stiffness
x0(25) = InitialParameterSet.PPY3;   %linear influence of inflation pressure on lateral peak friction
x0(26) = InitialParameterSet.PPY4;   %quadratic influence of inflation pressure on lateral peak friction
x0(27) = InitialParameterSet.PPY5;   %Influence of inflation pressure on camber stiffness

% Declare the anonymous function (Cost function) for the fitting
% The @ operator creates the handle, and the parentheses () immediately
% after the @ operator include the function input arguments
fun = @(X) pureFyError(X, data, InitialParameterSet);

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
OptimParameterSet.PCY1 = X_OPTIM(1);
OptimParameterSet.PDY1 = X_OPTIM(2);
OptimParameterSet.PDY2 = X_OPTIM(3);
OptimParameterSet.PDY3 = X_OPTIM(4);
OptimParameterSet.PEY1 = X_OPTIM(5);
OptimParameterSet.PEY2 = X_OPTIM(6);
OptimParameterSet.PEY3 = X_OPTIM(7);
OptimParameterSet.PEY4 = X_OPTIM(8);
OptimParameterSet.PEY5 = X_OPTIM(9);
OptimParameterSet.PKY1 = X_OPTIM(10);
OptimParameterSet.PKY2 = X_OPTIM(11);
OptimParameterSet.PKY3 = X_OPTIM(12);
OptimParameterSet.PKY4 = X_OPTIM(13);
OptimParameterSet.PKY5 = X_OPTIM(14);
OptimParameterSet.PKY6 = X_OPTIM(15);
OptimParameterSet.PKY7 = X_OPTIM(16);
OptimParameterSet.PHY1 = X_OPTIM(17);
OptimParameterSet.PHY2 = X_OPTIM(18);
OptimParameterSet.PVY1 = X_OPTIM(19);
OptimParameterSet.PVY2 = X_OPTIM(20);
OptimParameterSet.PVY3 = X_OPTIM(21);
OptimParameterSet.PVY4 = X_OPTIM(22);
OptimParameterSet.PPY1 = X_OPTIM(23);
OptimParameterSet.PPY2 = X_OPTIM(24);
OptimParameterSet.PPY3 = X_OPTIM(25);
OptimParameterSet.PPY4 = X_OPTIM(26);
OptimParameterSet.PPY5 = X_OPTIM(27);

% Scale friction
% OptimParameterSet.LMUX = 0.6;
% OptimParameterSet.LMUY = 0.6;

% *****************************VISUALIZE***************************************
visLat(OptimParameterSet, data);

% save('Hoosier16-PureLat-v2.mat', 'OptimParameterSet');
