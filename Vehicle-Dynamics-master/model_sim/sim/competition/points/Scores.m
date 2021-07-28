%Parameters to fill in (Penn's results for 2019 Lincoln)
accel.isFinished = false;
accel.rawTime = NaN;
accel.cones = NaN;

skidpad.isFinished = true;
skidpad.rawTime = 6.2310;
skidpad.cones = 0;

autocross.isFinished = true;
autocross.rawTime = 63.7680;
autocross.cones = 0;
autocross.offCourse = 0;

endurance.isFinished = true;
endurance.rawTime = 1718.3;
endurance.cones = 3;
endurance.offCourse = 5;
endurance.penalty = 30;

dynamicEvents = struct('accel', accel, 'skidpad', skidpad, 'autocross', autocross, ...
    'endurance', endurance);

computeCompetitionScores(dynamicEvents)
