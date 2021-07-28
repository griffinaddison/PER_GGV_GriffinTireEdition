clear

car = Rev6Full('loadSensitiveTires', true);
cls = 0 : 1 : 4;
simOutsCls = compParameterSweep(car, 'params', 'downforceCoef', cls, true)

%car = Rev6Full();
%cds = 0 : 0.5 : 10;
%simOutsCd = compParameterSweep(car, 'params', 'dragCoef', cds, true);

%rrm = RunRenderManager();
%rrm.addRunData(simOutsCd{1}.dynamicEvents.endurance.simOut.runData, 0.4, 'low drag');
%rrm.addRunData(simOutsCd{5}.dynamicEvents.endurance.simOut.runData, 0.4, 'high drag');
%rrm.render('viewQuantity', 'longAccel');
