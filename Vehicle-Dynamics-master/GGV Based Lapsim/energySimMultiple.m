baseline.cof = 1.4;
baseline.percentWeightDriving = .76;%
baseline.mass = 260; %kg
baseline.cl = 2.4;
baseline.cd = 1.3;
baseline.area = 1.1; %m^2
baseline.wheelTorque = 760; %Nm
baseline.wheelRadius = .23; %m
baseline.maxPower = 80000; %W
baseline.effeciency = .85;
baseline.rho = 1.225; %kg/m^3

REV3 = baseline;
REV3NoAero = baseline;
REV3NoAero.cl = 0;
REV3NoAero.cd = .8;

REV4 = baseline;
REV4.wheelTorque = 1200;
REV4.percentWeightDriving = 1;

REV4Heavy = REV4;
REV4Heavy.mass = 265;

REV4LowPowerLim = REV4;
REV4LowPowerLim.maxPower = 60000;

car = REV4;
energySim
car = REV4LowPowerLim;
energySim