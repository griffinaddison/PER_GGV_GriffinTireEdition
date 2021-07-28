function [ error ] = pureFxError(X, Data, ParameterSet)
%COSTFYPURE calls MFeval and calculates the error between the model and the
%input data.
%
% error = costFyPure(X, Data, ParameterSet)
%
% X: Is a structure that contains the FyPure parameters that are being
%       fitted. X is changing all the time when lsqnonlin is calling this
%       function.
% Data: Is a Table that contains the Data used to measure the error
%       of the model that is being fitted.
% ParameterSet: Is a structure of MF6.1 parameters. The parameters are used
%       only to call MFeval without errors.
%
% Example:
% error = costFyPure(Xstructure, TableData, ParameterSet)

% Create the Inputs for MFeval
INPUTS = [Data.Fz, Data.SR, Data.SA, Data.IA, Data.Phit, Data.Vx, Data.P, Data.W];

% Select use mode 221. For more info go to the documentation of MFeval
USE_MODE = 221;

% Unpack the parameters that are being fitted and replace them into the
% ParameterSet.
% LONG
ParameterSet.PCX1 = X(1);
ParameterSet.PDX1 = X(2);
ParameterSet.PDX2 = X(3);
ParameterSet.PDX3 = X(4);
ParameterSet.PEX1 = X(5);
ParameterSet.PEX2 = X(6);
ParameterSet.PEX3 = X(7);
ParameterSet.PEX4 = X(8);
ParameterSet.PKX1 = X(9);
ParameterSet.PKX2 = X(10);
ParameterSet.PKX3 = X(11);
ParameterSet.PHX1 = X(12);
ParameterSet.PHX2 = X(13);
ParameterSet.PVX1 = X(14);
ParameterSet.PVX2 = X(15);
ParameterSet.PPX1 = X(16);
ParameterSet.PPX2 = X(17);
ParameterSet.PPX3 = X(18);
ParameterSet.PPX4 = X(19);

% Call MFeval
warning('off','all')
OUTPUT = mfeval(ParameterSet,INPUTS,USE_MODE);
warning('on','all')

% Get the Fy from the MF6.1 model
Fx_MFeval = OUTPUT(:,1);

% Calculate error against the data
error = Data.Fx - Fx_MFeval;
end