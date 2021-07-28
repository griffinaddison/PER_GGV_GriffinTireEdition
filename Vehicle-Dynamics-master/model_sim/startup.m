scriptPath = mfilename('fullpath');
[rootDir, ~, ~] = fileparts(scriptPath);

addpath(strcat(rootDir, '/sim/full'));
addpath(strcat(rootDir, '/sim/competition'));
addpath(strcat(rootDir, '/sim/competition/points'));
addpath(strcat(rootDir, '/sim/lap'));
addpath(strcat(rootDir, '/sim/lap/ggv'));
addpath(strcat(rootDir, '/model'));
addpath(strcat(rootDir, '/model/car'));
addpath(strcat(rootDir, '/model/tire'));
addpath(strcat(rootDir, '/model/motor'));
addpath(strcat(rootDir, '/model/controller'));
addpath(strcat(rootDir, '/model/controller/full'));
addpath(strcat(rootDir, '/model/accumulator'));
addpath(strcat(rootDir, '/vis/core'));
addpath(strcat(rootDir, '/vis/run'));
addpath(strcat(rootDir, '/vis/mmd'));
addpath(strcat(rootDir, '/study/core'));
addpath(strcat(rootDir, '/study/handling'));
addpath(strcat(rootDir, '/utils'));

addpath(strcat(rootDir, '/data_tools/runs'));
addpath(strcat(rootDir, '/data_tools/tires'));

addpath(strcat(rootDir, '/plugins'));
addpath(strcat(rootDir, '/plugins/ode'));
addpath(strcat(rootDir, '/plugins/catstruct'));
addpath(strcat(rootDir, '/plugins/MFeval'));
addpath(strcat(rootDir, '/plugins/MF_Tire_GUI_V2a'));
addpath(strcat(rootDir, '/plugins/legendflex'));
addpath(strcat(rootDir, '/plugins/legendflex/legendflex'));
addpath(strcat(rootDir, '/plugins/legendflex/setgetpos_V1.2'));

addpath(strcat(rootDir, '/plugins/geom2d/geom2d'));
addpath(strcat(rootDir, '/plugins/geom2d/polygons2d'));
addpath(strcat(rootDir, '/plugins/geom2d/polynomialCurves2d'));
addpath(strcat(rootDir, '/plugins/geom2d/utils'));
