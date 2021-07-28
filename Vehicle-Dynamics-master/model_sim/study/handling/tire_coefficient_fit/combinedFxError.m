function [ error ] = combinedFxError(X, Data, ParameterSet)

% Create the Inputs for MFeval
INPUTS = [Data.Fz, Data.SR, Data.SA, Data.IA, Data.Phit, Data.Vx, Data.P, Data.W];

% Select use mode 211. For more info go to the documentation of MFeval
USE_MODE = 221;

% Unpack the parameters that are being fitted and replace them into the
% ParameterSet.
% LONG
ParameterSet.RBX1	=  X(1);
ParameterSet.RBX2	=  X(2);
ParameterSet.RBX3	=  X(3);
ParameterSet.RCX1	=  X(4);
ParameterSet.REX1	=  X(5);
ParameterSet.REX2	=  X(6);
ParameterSet.RHX1	=  X(7);

% Call MFeval
warning('off','all')
OUTPUT = mfeval(ParameterSet,INPUTS,USE_MODE);
warning('on','all')

% Get the Fy from the MF6.1 model
Fx_MFeval = OUTPUT(:,1);

% Calculate error against the data
error = Fx_MFeval - Data.Fx;
end