function [ error ] = pureFyError(X, Data, ParameterSet)
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
INPUTS = [Data.Fz, Data.SR, Data.SA, Data.IA, Data.Phit, Data.Vx, Data.P];

% Select use mode 211. For more info go to the documentation of MFeval
USE_MODE = 221;

% Unpack the parameters that are being fitted and replace them into the
% ParameterSet.
% LAT
ParameterSet.PCY1	=  X(1)     ;%Shape factor Cfy for lateral forces
ParameterSet.PDY1	=  X(2)     ;%Lateral friction Muy
ParameterSet.PDY2	=  X(3)     ;%Variation of friction Muy with load
ParameterSet.PDY3	=  X(4)  	;%Variation of friction Muy with squared camber
ParameterSet.PEY1	=  X(5)  	;%Lateral curvature Efy at Fznom
ParameterSet.PEY2	=  X(6)   	;%Variation of curvature Efy with load
ParameterSet.PEY3	=  X(7)   	;%Zero order camber dependency of curvature Efy
ParameterSet.PEY4	=  X(8)  	;%Variation of curvature Efy with camber
ParameterSet.PEY5	=  X(9)   	;%Variation of curvature Efy with camber squared
ParameterSet.PKY1	=  X(10)	;%Maximum value of stiffness Kfy/Fznom
ParameterSet.PKY2	=  X(11) 	;%Load at which Kfy reaches maximum value
ParameterSet.PKY3	=  X(12)   	;%Variation of Kfy/Fznom with camber
ParameterSet.PKY4	=  X(13)   	;%Curvature of stiffness Kfy
ParameterSet.PKY5	=  X(14)   	;%Peak stiffness variation with camber squared
ParameterSet.PKY6	=  X(15)   	;%Fy camber stiffness factor
ParameterSet.PKY7	=  X(16)   	;%Vertical load dependency of camber stiffness
ParameterSet.PHY1	=  X(17)  	;%Horizontal shift Shy at Fznom
ParameterSet.PHY2	=  X(18)   	;%Variation of shift Shy with load
ParameterSet.PVY1	=  X(19)  	;%Vertical shift in Svy/Fz at Fznom
ParameterSet.PVY2	=  X(20)   	;%Variation of shift Svy/Fz with load
ParameterSet.PVY3	=  X(21)   	;%Variation of shift Svy/Fz with camber
ParameterSet.PVY4	=  X(22)  	;%Variation of shift Svy/Fz with camber and load
ParameterSet.PPY1	=  X(23)   	;%influence of inflation pressure on cornering stiffness
ParameterSet.PPY2	=  X(24)  	;%influence of inflation pressure on despendency of nominal tyre load on cornering stiffness
ParameterSet.PPY3	=  X(25)   	;%linear influence of inflation pressure on lateral peak friction
ParameterSet.PPY4	=  X(26)   	;%quadratic influence of inflation pressure on lateral peak friction
ParameterSet.PPY5	=  X(27)   	;%Influence of inflation pressure on camber stiffness

% Call MFeval
OUTPUT = mfeval(ParameterSet,INPUTS,USE_MODE);

% Get the Fy from the MF6.1 model
Fy_MFeval = OUTPUT(:,2);

% Calculate error against the data
error = Fy_MFeval - Data.Fy;
end