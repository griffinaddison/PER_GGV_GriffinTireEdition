function plotSweep(varargin)
    p = inputParser;
    p.addRequired('sweepOut');
    p.addOptional('regenWattage', 0);
    p.parse(varargin{:});

    sweepOut = p.Results.sweepOut;
    [powers, massDeltas, enduranceEnergies, points, rmsPowers, brakeTimes, enduranceTimes] = parseData(sweepOut);

    enduranceEnergies = enduranceEnergies - brakeTimes * p.Results.regenWattage;
    
    enduranceEnergies = enduranceEnergies / 3.6e6;
    
    points = reshape(points, [length(sweepOut.powers), ...
                              length(sweepOut.massDeltas)]);

    surf(sweepOut.massDeltas, ...
        enduranceEnergies(1:length(sweepOut.powers)), ...
        points);
    %surf(sweepOut.massDeltas, ...
        %sweepOut.powers, ...
        %points);

    xlabel('Mass delta (kg)');
    ylabel('Total endurance energy consumption (kWh)');
    zlabel('Dynamic points competition');
end


% dynamics model --> ode solver --> accel run
% dynamics model --> ode solver --> GGV diagram