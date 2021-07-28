function [ error ] = combinedFyError(X, Data, ParameterSet)

% Create the Inputs for MFeval
INPUTS = [Data.Fz, Data.SR, Data.SA, Data.IA, Data.Phit, Data.Vx, Data.P];

% Select use mode 211. For more info go to the documentation of MFeval
USE_MODE = 211;

% Unpack the parameters that are being fitted and replace them into the
% ParameterSet.
% LAT
ParameterSet.RBY1	=  X(1);
ParameterSet.RBY2	=  X(2);
ParameterSet.RBY3	=  X(3);
ParameterSet.RBY4	=  X(4);
ParameterSet.RCY1	=  X(5);
ParameterSet.REY1	=  X(6);
ParameterSet.REY2	=  X(7);
ParameterSet.RHY1	=  X(8);
ParameterSet.RHY2	=  X(9); 
ParameterSet.RVY1	=  X(10);
ParameterSet.RVY2	=  X(11);
ParameterSet.RVY3	=  X(12);
ParameterSet.RVY4	=  X(13);
ParameterSet.RVY5	=  X(14);  
ParameterSet.RVY6	=  X(15); 	

% Call MFeval
OUTPUT = mfeval(ParameterSet,INPUTS,USE_MODE);

% Get the Fy from the MF6.1 model
Fy_MFeval = OUTPUT(:,2);

% Calculate error against the data
error = Fy_MFeval - Data.Fy;
end