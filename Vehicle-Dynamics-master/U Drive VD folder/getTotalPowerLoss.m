totalPLoss = 0;
totalPUsed = 0;
totalActualP = 0;

for i=2:9152
    [pLoss, pUsed] = getPowerLoss(endourance{i, 'MPH'}, endourance{i, 'torqueRQ'});
    dT = endourance{i, 'seconds'} - endourance{i-1, 'seconds'};
    totalPLoss = totalPLoss + dT * pLoss / 1000 / 3600;
    totalPUsed = totalPUsed + dT * pUsed / 1000 / 3600;
    totalActualP = totalActualP + dT * endourance{i, 'AMSPower'} / 3600;
end