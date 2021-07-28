function csvExport(sweepOut)
    [powers, massDeltas, enduranceEnergies, rmsPowers, brakeTimes, enduranceTimes, accelTimes, endurancePoints, accelPoints, skidpadPoints, autocrossPoints, points] = ...
        parseData(sweepOut);
    
    cHeader = {'maxPower (watts)', 'massDelta (kg)', ...
               'enduranceEnergy (joules)', ...
        'rmsPower', 'brakeTimePerEnduranceLap (s)', 'enduranceTime (s)', 'accelTime (s)', 'endurancePoints', 'accelPoints', 'skidpadPoints', 'autocrossPoints', 'total points'};

    commaHeader = [cHeader;repmat({','},1,numel(cHeader))]; %insert commaas
    commaHeader = commaHeader(:)';
    textHeader = cell2mat(commaHeader); %cHeader in text with commas
    %write header to file
    fid = fopen('sweep.csv','w'); 
    fprintf(fid,'%s\n',textHeader);
    fclose(fid);

    mat = [powers.', massDeltas.', enduranceEnergies.', rmsPowers.', brakeTimes.', enduranceTimes.', accelTimes.', endurancePoints.', accelPoints.', skidpadPoints.', autocrossPoints.', points.'];
    %write data to end of file
    dlmwrite('sweep.csv', mat, '-append');
end
