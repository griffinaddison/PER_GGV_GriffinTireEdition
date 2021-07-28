function [powers, massDeltas, enduranceEnergies, rmsPowers, brakeTimes, enduranceTimes, accelTimes, endurancePoints, accelPoints, skidpadPoints, autocrossPoints, points] = parseData(sweepOut)
    powers = [];
    massDeltas = [];
    enduranceEnergies = [];
    rmsPowers = [];
    brakeTimes = [];
    enduranceTimes = [];
    accelTimes = [];

    endurancePoints = [];
    accelPoints = [];
    skidpadPoints = [];
    autocrossPoints = [];
    points = [];

    for i = 1 : length(sweepOut.simOuts)
        simOut = sweepOut.simOuts{i};
        stats = simOut.dynamicEvents.endurance.simOut.stats;
    
        %{
        powers(i) = simOut.power;
        massDeltas(i) = simOut.massDelta;
        points(i) = simOut.scores.total;
        enduranceEnergies(i) = stats.energyDelivered * 15;
        rmsPowers(i) = stats.rmsPower;
        brakeTimes(i) = stats.brakeTime * 15;
        enduranceTimes(i) = simOut.dynamicEvents.endurance.rawTime;
        %}


        powers(end+1) = simOut.power;
        massDeltas(end+1) = simOut.massDelta;
        enduranceEnergies(end+1) = stats.energyDelivered * 15;
        rmsPowers(end+1) = stats.rmsPower;
        brakeTimes(end+1) = stats.brakeTime * 15;
        enduranceTimes(end+1) = simOut.dynamicEvents.endurance.rawTime;
        accelTimes(end+1) = simOut.dynamicEvents.accel.rawTime;

        endurancePoints(end+1) = simOut.scores.endurance;
        accelPoints(end+1) = simOut.scores.accel;
        skidpadPoints(end+1) = simOut.scores.skidpad;
        autocrossPoints(end+1) = simOut.scores.autocross;
        points(end+1) = simOut.scores.total;
    end
end
